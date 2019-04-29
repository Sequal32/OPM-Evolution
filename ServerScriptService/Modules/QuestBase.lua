Quest = {}
Quest.__index = Quest

SS = game:GetService("ServerScriptService")
HS = game:GetService("HttpService")

Quest.QuestStats = require(SS.Stats.QuestStats)
Quest.QuestGiverStats = require(SS.Stats.QuestGiverStats)

function Quest.New(QuestGiver, CompletedCallback, QuestsArray, OngoingQuests)
    local NewQuest = {}

    setmetatable(NewQuest, Quest)

    -- NewQuest.Type = ""
    -- NewQuest.Completed = 0
    -- NewQuest.NeedToComplete = 0
    -- NewQuest.Rewards = 0
    NewQuest.QuestID = HS:GenerateGUID(false)
    NewQuest.Callback = CompletedCallback
    NewQuest.QuestGiver = QuestGiver

    for _,Q in pairs(QuestsArray) do
        print("hello?")
        if not Quest:Conflicting(QuestsArray, OngoingQuests) then
            print("come on")
            NewQuest.NeedToComplete = math.random(5, Q.MaximumNumber)
            NewQuest.ObjectiveName = Q.ObjectiveName
            NewQuest.ReadableName = Q.ReadableName
            NewQuest.Type = Quest.Type
            NewQuest.Rewards = math.floor(Q.BaseRewards*NeedToComplete)
        end
    end

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
    
    if self.Completed == self.NeedToComplete then self.Callback() end
end

function Quest:DistributeRewards()

end

return Quest