CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")

NumGen = Random.new()

QuestGivers = {workspace.Genos}

LevelQuests = {
    {160, "VaccineMan", "Vaccine Man"},
    {30, "KelpMonster", "Kelp Monster"},
    {20, "StrongThug", "Strong Thug"},
    {10, "WeakThug", "Weak Thug"} -- Model name, human readable name
}

OnGoingPlayerQuests = {}

function GetQuestForLevel(Level)
    for _,Quest in pairs(LevelQuests) do
        local LevelRequirement, ModelName, ReadableName = Quest[1], Quest[2], Quest[3]
        if Level <= LevelRequirement then
            local NeedToComplete = NumGen:NextInteger(5, 15)
            OnGoingPlayerQuests[Player] = {ModelName, 0, NeedToComplete} -- ModelName (For tracking), Completed, NeedToComplete
        end
    end
end