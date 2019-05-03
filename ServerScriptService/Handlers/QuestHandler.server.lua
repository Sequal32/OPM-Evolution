CS = game:GetService("CollectionService")
HS = game:GetService("HttpService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")

NumGen = Random.new()


Events = RP.Events.General
Updates = SS.Updates

NumberDictionary = require(SS.Modules.NumberDictionary)

QuestStats = require(SS.Stats.QuestStats)
PlayerStats = require(SS.Stats.CurrentPlayerStats)
OnGoingPlayerQuests = require(SS.Stats.OngoingPlayerQuests)
QuestGiverStats = require(SS.Stats.QuestGiverStats)
QuestBase = require(SS.Modules.QuestBase)

Events.QuestProgression.OnServerEvent:Connect(function(Player, RequestType, Data)
    if RequestType == "Start" then
        local PlayerData = PlayerStats[Player]
        local NewQuest

        Action = QuestGiverStats.TierQuests[1][1]
        local function CompleteQuest()
            OnGoingPlayerQuests[Player][NewQuest.QuestID] = nil 
        end
        NewQuest = QuestBase.NewFromGenerator(Data, CompleteQuest, PlayerData.Level, Action, OnGoingPlayerQuests[Player] or {}, Player)
        
        if not NewQuest then return end

        Events.QuestProgression:FireClient(Player, "Start", NewQuest:GetClientData())
        OnGoingPlayerQuests[Player][NewQuest.QuestID] = NewQuest
    elseif RequestType == "Cancel" then
        OnGoingPlayerQuests[Player][Data.QuestID] = nil
    end
end)

Updates.MobDied.Event:Connect(function(Perp, Mob)
    for Player,PlayerQuests in pairs(OnGoingPlayerQuests) do
        for Index,Quest in pairs(PlayerQuests) do
            if Mob.Name == Quest.ObjectiveName and Perp == Player then
                PlayerQuests[Index]:IncrementCompletion()
            end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(Player)
    local Data = Updates.GetData:Invoke("Quests", Player)
    OnGoingPlayerQuests[Player] = {}
    if not Data then return end

    for _,Quest in pairs(Data) do
        local NewQuest = QuestBase.NewFromExisting(Quest)
        OnGoingPlayerQuests[Player][NewQuest.QuestID] = NewQuest

        Events.QuestProgression:FireClient(Player, "Start", NewQuest)
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