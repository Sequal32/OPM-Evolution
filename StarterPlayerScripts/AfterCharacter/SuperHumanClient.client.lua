CAS = game:GetService("ContextActionService")
RP = game:GetService("ReplicatedStorage")

PlayerObject = game.Players.LocalPlayer
Mouse = PlayerObject:GetMouse()

-- TODO, implement stats
Events = RP.Events.SuperHuman
GeneralEvents = RP.Events.General

-- Paths
Characters = RP.Characters
General = RP.General
Resources = RP.Resources.Ninja

Trigger = General.SkillTrigger

Misc = require(RP.General.Misc)

-- INITIALIZE EVERYTHING
Player = require(General.Player)
StatsA = Player.Stats
StatsB = StatsA.SuperHuman
SuperHuman = require(Characters.SuperHuman:Clone())
SuperHuman.New(Player)

RP.Events.General.CharacterSelected:FireServer("SuperHuman")

-- Name, Input, CreateTouchButton, TriggerType, Coo ldowns, Functions

local BasicAttack = require(Trigger:Clone())
	BasicAttack.New("BasicAttack", Enum.UserInputType.MouseButton1, false, "Press", {
		["Length"] = function()
			return 0.5
		end 
		}, {
		["Main"] = SuperHuman.BasicAttack.Use,
}, true)

function UnlockPunch(SkillName)
	local Punch = require(Trigger:Clone())
	Punch.New(SkillName, Enum.KeyCode.Z, false, "Hold", {
		["Main"] = StatsB.Punch.Cooldown
		}, {
		["Enable"] = SuperHuman.StartPunch,
		["Main"] = SuperHuman.Punch,
		["Main2"] = SuperHuman.PointToPos,
		["Disable"] = SuperHuman.StopPunch,
		["Info"] = Misc.GetTargetMousePos,
--		["Info"] = Misc.GetCameraLookVector,
		["MainCallback"] = function()
			if not StatsA.SubtractStaminaWithChecking(StatsB.Punch.StaminaRate()) then Punch.Cancel() end
		end
	}, true)
end

function UnlockRangedPunch(SkillName)
	local RangedPunch = require(Trigger:Clone())
	RangedPunch.New(SkillName, Enum.KeyCode.X, false, "Press", {
		["Length"] = StatsB.RangedPunch.Cooldown
		}, {
		["Main"] = SuperHuman.RangedPunch,
		["Info"] = Misc.GetTargetMousePos,
--		["Info"] = Misc.GetCameraLookVector,
		["EnableCallback"] = function()
			if not StatsA.SubtractStaminaWithChecking(StatsB.RangedPunch.StaminaRate()) then RangedPunch.Cancel() end
		end
	}, true)
end

--function UnlockBoulderToss()
--	local BoulderToss = require(Trigger:Clone())
--	BoulderToss.New(SkillName, "3", false, "Press", {
--		["Length"] = StatsB.BoulderToss.Cooldown
--		}, {
--		["Main"] = SuperHuman.BoulderToss,
--		["Info"] = function()
--			return Misc.GetTargetMousePos(Mouse)
--		end,
--		["EnableCallback"] = function()
--			if not StatsA.SubtractStaminaWithChecking(StatsB.BoulderToss.StaminaRate()) then BoulderToss.Cancel() end
--		end
--	})
--end

function UnlockRockSmash(SkillName)
	local RockSmash = require(Trigger:Clone())
	RockSmash.New(SkillName, Enum.KeyCode.C, false, "Press", {
		["Length"] = StatsB.RockSmash.Cooldown
        }, {
        ["Main"] = SuperHuman.RockSmash,
    --	["Info"] = Misc.GetTargetMousePos,
        ["Info"] = function()
            return Misc.GetCameraLookVector(), StatsB.RockSmash.NumberOfRocks()
        end,
        ["EnableCallback"] = function()
            if not StatsA.SubtractStaminaWithChecking(StatsB.RockSmash.StaminaRate()) then RockSmash.Cancel() end
        end
        }, true)
end

function UnlockJump(SkillName)
	local Jump = require(Trigger:Clone())
	Jump.New(SkillName, Enum.KeyCode.V, false, "Hold", {}, {
		["Enable"] = SuperHuman.Jump.StartJump,
		["Main"] = SuperHuman.Jump.ChargeJump,
		["Disable"] = SuperHuman.Jump.FinishJump,
		["Info"] = StatsB.Jump.ChargeMaxHeight,
		["DisableCallback"] = function(Height)
			if not StatsA.SubtractStaminaWithChecking(StatsB.Jump.StaminaRate(SuperHuman.Jump.CurrentHeight)) then Jump.Cancel() end
		end
	}, true)
end

function UnlockSprint(SkillName)
	local Sprint = require(Trigger:Clone())
	Sprint.New(SkillName, Enum.KeyCode.LeftControl, false, "HoldOnce", {}, {
		["Enable"] = SuperHuman.Sprint.Enable,
		["Disable"] = SuperHuman.Sprint.Disable,
		["Info"] = StatsA.All.Sprint.Speed
	}, true)
end

function UnlockBurrow(SkillName)
	local Burrow = require(Trigger:Clone())
	Burrow.New(SkillName, Enum.KeyCode.F, false, "Hold", {}, {
		["Enable"] = SuperHuman.StartBurrow,
		["Main"] = SuperHuman.Burrow,
		["Disable"] = SuperHuman.EndBurrow,
        ["Info"] = Misc.GetCameraLookVector,
        ["EnableCallback"] = function()
            if not Part or math.abs(Player.Character.PrimaryPart.Position.Y-Position.Y) > 10 then Burrow.Cancel() end
        end,
		["MainCallback"] = function(Burrowing)
			local Part, Position = Misc.FindCollisionPart(Player.Character.PrimaryPart, Player.Character.PrimaryPart-Vector3.new(0, -20, 0))
			local Grounded = true
			if not StatsA.SubtractStaminaWithChecking(StatsB.Burrow.StaminaRate()) and StatsA.Current.Stamina/StatsA.Max.Stamina > 0.2 then Burrow.Cancel() end
		end
	}, false)
end

function UnlockBullet(SkillName)
	local Bullet = require(Trigger:Clone())
	Bullet.New(SkillName, Enum.KeyCode.R, false, "Hold", {
		["Length"] = function() return 5 end
		}, {
		["Enable"] = SuperHuman.StartBullet,
		["Main"] = SuperHuman.AimBullet,
		["Disable"] = SuperHuman.EndBullet,
		["Info"] = Misc.GetCameraLookVector,
		["EnableCallback"] = function()
			if Player.Character.PrimaryPart.Position.Y > 40 then Bullet.Cancel() end
		end
	}, false)
end

Player.Character.Humanoid.Died:Connect(function()
    -- Unbind all skills after player death
    CAS:UnbindAction("BasicAttack")
    for _,Skill in pairs(UnlockLevels) do
        CAS:UnbindAction(Skill[3])
    end
end)

UnlockLevels = {  -- Function, Unlocked (boolean)
	["1"] = {UnlockSprint, false, "Sprint"},
	["5"] = {UnlockPunch, false, "RapidPunch"},
	["10"] = {UnlockJump, false, "ChargedJump"},
	["15"] = {UnlockRangedPunch, false, "ExplosiveRangedPunch"},
	["25"] = {UnlockRockSmash, false, "RockSmash"},
	["50"] = {UnlockBurrow, false, "Burrow"},
	["75"] = {UnlockBullet, false, "Bullet"}
}

GeneralEvents.UnlockLevel.Event:Connect(function(NewLevel)
	for Level,Unlock in pairs(UnlockLevels) do
		local LevelNumber = tonumber(Level)
		local UnlockSkill, Unlocked, SkillName = Unlock[1], Unlock[2], Unlock[3]
		
		if NewLevel >= LevelNumber and not Unlocked then
			UnlockLevels[Level][2] = true
			UnlockSkill(SkillName)
		end
	end
end)