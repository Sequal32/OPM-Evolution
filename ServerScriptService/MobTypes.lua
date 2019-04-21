local RP = game:GetService("ReplicatedStorage")
local Misc = require(RP.General.Misc)
local MobTypes = {}

MobTypes.Kelp = {
	["StrengthLevel"] = 100,
	["AgilityLevel"] = 100,
	["DefenseLevel"] = 100,
	["StaminaLevel"] = 100,
    ["Level"] = 100,
    ["DeathTime"] = 0
}

MobTypes.StrongThug = {
	["StrengthLevel"] = 15,
	["AgilityLevel"] = 15,
	["DefenseLevel"] = 15,
	["StaminaLevel"] = 15,
    ["Level"] = 15,
    ["DeathTime"] = 3
}

MobTypes.WeakThug = {
	["StrengthLevel"] = 5,
	["AgilityLevel"] = 5,
	["DefenseLevel"] = 5,
	["StaminaLevel"] = 5,
    ["Level"] = 5,
    ["DeathTime"] = 3
}

MobTypes["[Boss] Vaccine Man"] = {
	["StrengthLevel"] = 300,
	["AgilityLevel"] = 300,
	["DefenseLevel"] = 300,
	["StaminaLevel"] = 300,
    ["Level"] = 300,
	["Range"] = 15,
	["DeathTime"] = 7,
    ["RespawnTime"] = 15,
    ["AttackingDistance"] = 10
}

return MobTypes
