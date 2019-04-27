CS = game:GetService("CollectionService")
HS = game:GetService("HttpService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")

NumGen = Random.new()


Events = RP.Events.General
Updates = SS.Updates
QuestStats = require(SS.Stats.QuestStats)
QuestGiverStats = require(SS.Stats.QuestGiverStats)

OnGoingPlayerQuests = {}

function GiveKillQuest(Player, Level)
    for _,Quest in pairs(QuestStats) do
        -- Detect if the player has already accepted a quest with the same mob
        local SameMob
        local NumberOfQuests = 0
        for _,QuestA in pairs(OnGoingPlayerQuests[Player]) do
            if QuestA.ModelName == Quest.ModelName then
                SameMob = true
            end
            NumberOfQuests = NumberOfQuests+1
        end

        if Level >= Quest.StartLevel and NumberOfQuests < 2 and not SameMob then
            local NeedToComplete = NumGen:NextInteger(5, Quest.MaximumNumber)
            local QuestID = HS:GenerateGUID(false)

            OnGoingPlayerQuests[Player][QuestID] = {
                ModelName = Quest.ModelName, 
                ReadableName = Quest.ReadableName,
                Type = Quest.Type,
                Completed = 0, 
                NeedToComplete = NeedToComplete, 
                Rewards = math.floor(Quest.BaseRewards*NeedToComplete)
            }

            Events.QuestProgression:FireClient(Player, "Start", {
                Type = Quest.Type,
                Rewards = math.floor(Quest.BaseRewards*NeedToComplete),
                ReadableName = Quest.ReadableName,
                Completed = 0,
                NeedToComplete = NeedToComplete,
                QuestID = QuestID
            })
            break
        end
    end
end

function GetQuestForLevel(Player, Level, QuestGiver)
    if not OnGoingPlayerQuests[Player] then OnGoingPlayerQuests[Player] = {} end

    
end

Events.QuestProgression.OnServerEvent:Connect(function(Player, RequestType, Data)
    if RequestType == "Start" then
        local PlayerData = Updates.GetPlayerData:Invoke(Player)
        GetQuestForLevel(Player, PlayerData.Level, QuestGiver)
    elseif RequestType == "Cancel" then
        OnGoingPlayerQuests[Player][Data.QuestID] = nil
    end
end)

Updates.MobDied.Event:Connect(function(Perp, Mob)
    for Player,PlayerQuests in pairs(OnGoingPlayerQuests) do
        for Index,Quest in pairs(PlayerQuests) do
            if Mob.Name == Quest.ModelName and Perp == Player then
                PlayerQuests[Index].Completed = PlayerQuests[Index].Completed+1

                if PlayerQuests[Index].Completed >= PlayerQuests[Index].NeedToComplete then
                    Events.QuestProgression:FireClient(Player, "Complete", {QuestID = Index})
                    Updates.Stats.IncrementEXP:Fire(Player, PlayerQuests[Index].Rewards)
                    Updates.Stats.IncrementYen:Fire(Player, PlayerQuests[Index].Rewards)
                    OnGoingPlayerQuests[Player][Index] = nil
                else
                    Events.QuestProgression:FireClient(Player, "Progress", {
                        Completed = PlayerQuests[Index].Completed,
                        QuestID = Index
                    })
                end
            end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(Player)
    local Data = Updates.GetData:Invoke("Quests", Player)
    if not Data then return end

    for _,Quest in pairs(Data) do
        local QuestID = HS:GenerateGUID(false)
        OnGoingPlayerQuests[Player] = {}
        OnGoingPlayerQuests[Player][QuestID] = Quest

        Events.QuestProgression:FireClient(Player, "Start", {
            Type = Quest.Type,
            Rewards = Quest.Rewards,
            ReadableName = Quest.ReadableName,
            Completed = Quest.Completed,
            NeedToComplete = Quest.NeedToComplete,
            Ongoing = true,
            QuestID = QuestID
        })

    end
end)

game.Players.PlayerRemoving:Connect(function(Player)
    local CurrentQuests = {}

    for _,Quest in pairs(OnGoingPlayerQuests[Player]) do
        table.insert(CurrentQuests, Quest)
    end

    OnGoingPlayerQuests[Player] = nil

    Updates.SaveData:Invoke("Quests", Player, CurrentQuests)
end)