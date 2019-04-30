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
QuestBase = require(SS.Modules.QuestBase)

OnGoingPlayerQuests = {}

Events.QuestProgression.OnServerEvent:Connect(function(Player, RequestType, Data)
    if RequestType == "Start" then
        local PlayerData = Updates.GetPlayerData:Invoke(Player)
        
        local NewQuest = QuestBase.NewFromGenerator(Data, function() 
            OnGoingPlayerQuests[Player][NewQuest.QuestID] = nil 
            Events.QuestProgression:FireClient(Player, "Complete", {QuestID = Index})
        end, PlayerData.Level, QuestStats.Kill, OnGoingPlayerQuests[Player] or {})
        
        if not NewQuest then return end

        Events.QuestProgression:FireClient(Player, "Start", NewQuest)
        OnGoingPlayerQuests[Player][NewQuest.QuestID] = NewQuest
        print(NewQuest.NeedToComplete, NewQuest.ObjectiveName, NewQuest.Type, NewQuest.Rewards)

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