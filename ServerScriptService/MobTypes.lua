local RP = game:GetService("ReplicatedStorage")
local Misc = require(RP.General.Misc)
local MobTypes = {}

MobTypes.Kelp = {
	["StrengthLevel"] = 100,
	["AgilityLevel"] = 100,
	["DefenseLevel"] = 100,
	["StaminaLevel"] = 100,
    ["Level"] = 100,
    ["OnDied"] = function(Character)
        Misc.WeldWithC1(Character.Head, Character.Features.Kelp, CFrame.new(-0.633468628, -1.39546204, -6.08973694, 0.99619472, 0.0871557891, 0, -0.0871557966, 0.99619472, 0, 0, 0, 1)).Parent = Character.Head
    end
}

MobTypes.StrongThug = {
	["StrengthLevel"] = 15,
	["AgilityLevel"] = 15,
	["DefenseLevel"] = 15,
	["StaminaLevel"] = 15,
	["Level"] = 15
}

MobTypes.WeakThug = {
	["StrengthLevel"] = 5,
	["AgilityLevel"] = 5,
	["DefenseLevel"] = 5,
	["StaminaLevel"] = 5,
	["Level"] = 5
}

return MobTypes
