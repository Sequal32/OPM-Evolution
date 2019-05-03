local SS = game:GetService("ServerScriptService")
local RP = game:GetService("ReplicatedStorage")

Updates = SS.Updates
Events = RP.Events.General

PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.New(Player, StatsArray)
    local NewPlayerStats = {}

    setmetatable(NewPlayerStats, PlayerStats)
    
    NewPlayerStats.Player = Player
    NewPlayerStats.Level = StatsArray.Level or 1
    NewPlayerStats.StrengthLevel = StatsArray.StrengthLevel or 1
    NewPlayerStats.StaminaLevel = StatsArray.StaminaLevel or 1
    NewPlayerStats.AgilityLevel = StatsArray.AgilityLevel or 1
    NewPlayerStats.PowerLevel = StatsArray.PowerLevel or 1
    NewPlayerStats.DefenseLevel = StatsArray.DefenseLevel or 1
    NewPlayerStats.SkillPoints = StatsArray.SkillPoints or 0
    NewPlayerStats.Yen = StatsArray.Yen or 0
    NewPlayerStats.EXP = StatsArray.EXP or 0

    NewPlayerStats.Relationships = StatsArray.Relationships or {}
    
    NewPlayerStats:CalculateVars()

    return NewPlayerStats
end

-- Change stats
function PlayerStats:CalculateVars()
    self.EXPNeeded = math.ceil(1.11^self.Level)
    self.MaxHealth = self.DefenseLevel*10
    self.Health = self.MaxHealth
end

function PlayerStats:IncrementStrength(Delta)
    self.StrengthLevel = self.StrengthLevel+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"StrengthLevel", self.StrengthLevel})
end

function PlayerStats:IncrementAgility(Delta)
    self.AgilityLevel = self.AgilityLevel+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"AgilityLevel", self.AgilityLevel})
end

function PlayerStats:IncrementDefense(Delta)
    self.DefenseLevel = self.DefenseLevel+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"DefenseLevel", self.IncrementDefense})
end

function PlayerStats:IncrementPower(Delta)
    self.PowerLevel = self.PowerLevel+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"PowerLevel", self.PowerLevel})
end

function PlayerStats:IncrementStamina(Delta)
    self.StaminaLevel = self.StaminaLevel+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"StaminaLevel", self.StaminaLevel})
end

function PlayerStats:IncrementSkillPoints(Delta)
    self.SkillPoints = self.SkillPoints+Delta
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"SkillPoints", self.SkillPoints})
end

function PlayerStats:IncrementYen(Delta)
    self.Yen = self.Yen+Delta

    Events.StatsClient:FireClient(self.Player, "Yen", {"Yen", self.Yen})
end

function PlayerStats:IncrementEXP(Delta)
    self.EXP = self.EXP+Delta

    if self.EXP >= self.EXPNeeded then
        self:IncrementLevel()
        return
    end

    Events.StatsClient:FireClient(self.Player, "SINGLE", {"EXP", self.EXP})
end

function PlayerStats:IncrementHealth(Delta, FinishedDying)
    self.Health = math.clamp(self.Health+Delta, 0, self.MaxHealth)
    Events.StatsClient:FireClient(self.Player, "SINGLE", {"Health", self.Health, FinishedDying})
end

function PlayerStats:IncrementLevel()
    self.EXP = self.EXP-self.EXPNeeded
    self.Level = self.Level+1
    CalculateVars()

    Events.StatsClient:FireClient(self.Player, "ALL", self)
end

function PlayerStats:IncrementRelationship(Name, Points)
    self.Relationships[Name] = self.Relationships[Name]+Points
end

function PlayerStats:BulkChange(ChangeArray)
    for Index,Value in pairs(ChangeArray) do
        self[Index] = Value
    end
end

-- Datastore
function PlayerStats.NewFromDatastore(Player)
    local Data, FirstTime = Updates.GetData:Invoke("Stats", Player)

    if not Data then return end

    NewPlayerStats = PlayerStats.New(Player, Data)

    return NewPlayerStats, FirstTime
end

function PlayerStats:SaveStats()
    return Updates.SaveData:Invoke("Stats", self.Player, {
        ["Yen"] = self.Yen,
        ["EXP"] = self.EXP,
        ["StrengthLevel"] = self.StrengthLevel,
        ["StaminaLevel"] = self.StaminaLevel,
        ["DefenseLevel"] = self.DefenseLevel,
        ["AgilityLevel"] = self.AgilityLevel,
        ["Level"] = self.Level,
        ["Relationships"] = self.Relationships
    })
end

return PlayerStats