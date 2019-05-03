Quest = {}
Quest.__index = Quest

RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
HS = game:GetService("HttpService")

Updates = SS.Updates

Quest.QuestStats = require(SS.Stats.QuestStats)
Quest.QuestGiverStats = require(SS.Stats.QuestGiverStats)

Events = RP.Events.General

function Quest.NewFromGenerator(QuestGiver, CompletedCallback, Level, QuestType, OngoingQuests, Player)
    local NewQuest = {}
    local FoundQuest = false

    setmetatable(NewQuest, Quest)

    NewQuest.Completed = 0
    NewQuest.QuestID = HS:GenerateGUID(false)
    NewQuest.Callback = CompletedCallback
    NewQuest.QuestGiver = QuestGiver
    NewQuest.Player = Player
    NewQuest.Type = QuestType

    for _,Q in pairs(Quest.QuestStats[QuestType]) do
        if not Quest:Conflicting(QuestsArray, OngoingQuests) then
            NewQuest.NeedToComplete = math.random(Q.MinimumNumber, Q.MaximumNumber)
            NewQuest.ObjectiveName = Q.ObjectiveName
            NewQuest.ReadableName = Q.ReadableName
            NewQuest.Type = Q.Type
            NewQuest.Rewards = math.floor(Q.BaseRewards*NewQuest.NeedToComplete)
            FoundQuest = true
        end
    end
    -- If all the requirements are met and found the quest
    if not FoundQuest then return end

    return NewQuest
end

function Quest.NewFromExisting(ExistingArray)
    local NewQuest = {}

    setmetatable(NewQuest, Quest)

    for Index,Value in ExistingArray do
        NewQuest[Index] = Value
    end

    NewQuest.Ongoing = true

    return NewQuest
end

function Quest:Conflicting(SearchArray, OngoingQuests)
    for _,Q in pairs(SearchArray) do
        local Conflict

        for _,QuestA in pairs(OngoingQuests) do
            if QuestA.ObjectiveName == Q.ObjectiveName then
                Conflict = true
            end
        end

    end

    return Conflict
end

function Quest:IncrementCompletion()
    self.Completed = self.Completed+1
    
    Events.QuestProgression:FireClient(self.Player, "Progress", {
        Completed = self.Completed,
        QuestID = self.QuestID
    })

    if self.Completed >= self.NeedToComplete then 
        self.Callback()
        -- Distributes rewards
        Events.QuestProgression:FireClient(Player, "Complete", {QuestID = self.QuestID})
        Updates.Stats.IncrementEXP:Fire(self.Player, self.Rewards)
        Updates.Stats.IncrementYen:Fire(self.Player, self.Rewards)
    end
end

function Quest:GetClientData()
    return {
        Type = self.QuestType,
        Rewards = self.Rewards,
        NeedToComplete = self.NeedToComplete,
        QuestID = self.QuestID,
        Completed = self.Completed,
        ReadableName = self.ReadableName
    }
end

return Quest