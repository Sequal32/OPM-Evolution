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
QuestKill = require(SS.Modules.QuestKill)

OnGoingPlayerQuests = {}

Events.QuestProgression.OnServerEvent:Connect(function(Player, RequestType, Data)
    if RequestType == "Start" then
        local PlayerData = Updates.GetPlayerData:Invoke(Player)
        -- GetQuestForLevel(Player, PlayerData.Level, QuestGiver)
        local NewQuest = QuestKill.New(Data, function() end, PlayerData.Level, OnGoingPlayerQuests[Player] or {})
        print(NewQuest.NeedToComplete, NewQuest.ObjectiveName, NewQuest.Type, NewQuest.Rewards)
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