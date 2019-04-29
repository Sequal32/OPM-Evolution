Modules = game:GetService("ServerScriptService").Modules
Quest = require(Modules.QuestBase)
NumberDictionary = require(Modules.NumberDictionary)
QuestKill = {}
QuestKill.__index = QuestKill

function QuestKill.New(QuestGiver, CompletedCallback, Level, OngoingQuests)
    print(OngoingQuests)
    local NewKillQuest = Quest.New(QuestGiver, CompletedCallback, Quest.QuestStats.Kill, OngoingQuests)
    
    setmetatable(NewKillQuest, Quest)

    return NewKillQuest
    -- if NumberDictionary(OngoingQuests) >= 2 then return false end
end

return QuestKill