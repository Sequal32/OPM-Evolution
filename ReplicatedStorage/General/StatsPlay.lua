local Stats = {}

RP = game:GetService("ReplicatedStorage")


-- COMMUNICATION
UIEvents = RP.UI_Data.UI_Events
Events = RP.Events.General
Player = game.Players.LocalPlayer
SkillDisableTime = Player.PlayerScripts:WaitForChild("RunningVars"):WaitForChild("SkillDisableTime")

repeat wait() until Player.Character

function Stats.UpdateStat(Stat, Value) -- WILL USE ATTRIBUTE POINTS, ALL OTHER STATS ARE HANDLED BY, AND ONLY THE SERVER
	return Events.StatsServer:InvokeServer("UPDATE", Stat, Value)
end

function ImplementStats(Data)
	Stats.Max.Health = Data.MaxHealth
	Stats.Max.Stamina = Data.StaminaLevel*10
	Stats.Current.Damage = Data.StrengthLevel
    Stats.Current.Speed = Data.AgilityLevel * 0.000043 + 32
    	
	for stat,value in pairs(Data) do
		Stats.Current[stat] = value
	end
	
	Player.Character.Humanoid.WalkSpeed = Stats.All.Sprint.Speed()
	
	UpdateUIStats()
end

function UpdateUIStats()
	if not Stats.Current.AgilityLevel then return end
	-- UI
	UIEvents.ChangeAgilityStats:Fire(Stats.Current.AgilityLevel, Stats.Max.AgilityLevel)
	UIEvents.ChangeStrengthStats:Fire(Stats.Current.StrengthLevel, Stats.Max.StrengthLevel)
	UIEvents.ChangeStaminaStats:Fire(Stats.Current.StaminaLevel, Stats.Max.StaminaLevel)
	UIEvents.ChangeDefenseStats:Fire(Stats.Current.DefenseLevel, Stats.Max.DefenseLevel)
	UIEvents.ChangeAttributeStats:Fire(Stats.Current.AttributePoints)
	UIEvents.ChangeEXP:Fire(Stats.Current.EXP, Stats.Current.EXPNeeded)
	UIEvents.ChangeLevel:Fire(Stats.Current.Level)
	UIEvents.ChangeYen:Fire(Stats.Current.Yen)
end

-- ACTUAL
Stats.All = {["BasicAttack"] = {}, ["Sprint"] = {}}
Stats.SuperHuman = {["RangedPunch"] = {}, ["Punch"] = {}, ["Blast"] = {}, ["BoulderToss"] = {}, ["Jump"] = {}, ["RockSmash"] = {}, ["Burrow"] = {}, ["Bullet"] = {}}

Stats.Max = {
	["StaminaLevel"] = 250,
	["DefenseLevel"] = 250,
	["AgilityLevel"] = 250,
	["StrengthLevel"] = 250,
	["Health"] = 0,
	["Stamina"] = 0,
	["Level"] = 500
}

Stats.Current = {["Stamina"] = 0, ["Health"] = Stats.Max.Health}
Stats.InCombat = false

NumGen = Random.new()
	
-- Recieve Stats
Stats.Connection = Events.StatsClient.OnClientEvent:connect(function(Type, Data)
	if Type == "ALL" then
		ImplementStats(Data)
	elseif Type == "SINGLE" then -- Data[1] is the name of the stat, Data[2] is the value of the stat
		if Data[1] == "Health" and Data[3] then -- If the character finished dying
			Stats.Current.Stamina = Stats.Max.Stamina
		else
			Stats.Current[Data[1]] = Data[2]
		end
	
		UpdateUIStats()
	end
end)
-- Handle server disabling client skills
Events.DisableSkills.OnClientEvent:Connect(function(Length)
    SkillDisableTime.Value = Length
end)
-- Stat functions

function Stats.ChangeHealth(Value)
	Stats.Current.Health = Stats.Current.Health-Value
end

function Stats.SubtractStamina(Value)
	Stats.Current.Stamina = Stats.Current.Stamina-Value
	return Stats.Current.Stamina
end

function Stats.SubtractStaminaWithChecking(Value)
	if Stats.Current.Stamina-Value < 0 then return false end
		
	Stats.SubtractStamina(Value)
	return true
end

function GetHundrethPercentage(Stat)
	return Stats.Current[Stat]/Stats.Max[Stat]
end

function GetTenthPercentage(Stat)
	return Stats.Current[Stat]/Stats.Max[Stat]
end

function GetFifthPercentage(Stat)
	return Stats.Current[Stat]/Stats.Max[Stat]
end

function RNGCorrected(Value)
	if Value >= 10 and Value < 100 then
		return Value + NumGen:NextInteger(3, 5)
	elseif Value >= 100 and Value < 1000 then
		return Value + NumGen:NextInteger(5, 10)
	elseif Value >= 1000 then
		return Value + NumGen:NextInteger(15, 25)
	else return Value
	end
end

-- All Stats
function Stats.All.BasicAttack.Damage()
	return RNGCorrected(7 * Stats.Current.StrengthLevel)
end

function Stats.All.BasicAttack.StaminaRate()
	return Stats.Max.Stamina/100
end

function Stats.All.Sprint.Speed()
	return 0.064257 * Stats.Current.AgilityLevel + 15.935743
end

-- Superhuman Stats

function Stats.SuperHuman.Punch.StaminaRate()
	return 2.5 + GetTenthPercentage("StrengthLevel") * 20
end

function Stats.SuperHuman.Punch.Cooldown()
	return 0.09
end

function Stats.SuperHuman.Punch.Damage()
	return RNGCorrected(2.7 * Stats.Current.StrengthLevel)
end

function Stats.SuperHuman.Burrow.StaminaRate()
	return Stats.Max.Stamina*0.02
end

function Stats.SuperHuman.RockSmash.StaminaRate()
	return 150
end

function Stats.SuperHuman.RockSmash.NumberOfRocks()
    return math.floor(Stats.Current.StrengthLevel/50) * 3 + 3
end

function Stats.SuperHuman.RockSmash.Cooldown()
	return 15 + GetTenthPercentage("StaminaLevel") * -3.75 + GetTenthPercentage("StrengthLevel") * -3.75
end

function Stats.SuperHuman.RockSmash.Damage()
	return RNGCorrected(25 * Stats.Current.StrengthLevel)
end

function Stats.SuperHuman.RangedPunch.StaminaRate()
	return Stats.Max.Stamina*0.2
end

function Stats.SuperHuman.RangedPunch.Damage()
	return RNGCorrected(2 * Stats.Current.StrengthLevel)
end

function Stats.SuperHuman.RangedPunch.Cooldown()
	return 5 + GetTenthPercentage("StaminaLevel") * -1.75 + GetTenthPercentage("StrengthLevel") * -1.75
end

function Stats.SuperHuman.Jump.ChargeMaxHeight()
	return 30 + GetTenthPercentage("AgilityLevel") * 90 -- Base of 30, max of 120 -> scales to 90 + 30 
end

function Stats.SuperHuman.Jump.AirMaxHeight()
	return GetTenthPercentage("AgilityLevel") * 20 -- Base of 5, max of 20 -> scales to 15 + 5
end

function Stats.SuperHuman.Jump.StaminaRate(Height)
	return 0.1 * Height/Stats.SuperHuman.Jump.ChargeMaxHeight() * Stats.Max.Stamina
end

-- Initialize the Interface --
ImplementStats(Events.StatsServer:InvokeServer("FETCH"))
Stats.Current.Stamina = Stats.Max.Stamina

-- AUTOMATICALLY REGEN STAMINA
spawn(function()
	while true do
		local StaminaAmountIncrease = Stats.Max.Stamina * 0.025
		Stats.Current.Stamina = Stats.Current.Stamina+StaminaAmountIncrease <= Stats.Max.Stamina and math.ceil(Stats.Current.Stamina+StaminaAmountIncrease) or Stats.Max.Stamina
        Events.UnlockLevel:Fire(Stats.Current.Level)
        SkillDisableTime.Value = SkillDisableTime.Value-0.5
		wait(0.5)
	end
end)

spawn(function()
	while wait() do
		UIEvents.ChangeInGameStamina:Fire(Stats.Current.Stamina, Stats.Max.Stamina)
		UIEvents.ChangeHealth:Fire(Stats.Current.Health, Stats.Max.Health)
		UIEvents.ChangeEXP:Fire(Stats.Current.EXP, Stats.Current.EXPNeeded)
	end
end)

return Stats
