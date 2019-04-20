CAS = game:GetService("ContextActionService")
RP = game:GetService("ReplicatedStorage")

PlayerObject = game.Players.LocalPlayer
Mouse = PlayerObject:GetMouse()

-- Paths
Characters = RP.Characters
General = RP.General
Resources = RP.Resources.Ninja

Trigger = General.SkillTrigger

Misc = require(RP.Misc)

-- INITIALIZE EVERYTHING
Player = require(General.Player)
StatsA = Player.Stats
StatsB = StatsA.Ninja
Ninja = require(Characters.Ninja)
Ninja.New(Player, 0, Color3.new(255, 255, 255))

RP.Events.General.CharacterSelected:FireServer("Ninja")

UnlockLevels = {
	[5] = UnlockShuriken,
	[15] = UnlockDash,
	[10] = UnlockJump,
	[25] = UnlockSlash
}

-- Defining buttons
-- Name, Input, CreateTouchButton, TriggerType, Cooldowns, Functions

local BasicAttack = require(Trigger:Clone())
	BasicAttack.New("BasicAttack", "c", false, "Press", {
		["Length"] = function()
			return 0.5
		end 
		}, {
		["Enable"] = Ninja.BasicAttack.Use,
		["Main"] = Ninja.BasicAttack.Use,
})

function UnlockDash()
	local Dash = require(Trigger:Clone())
	Dash.New("NinjaDash", Enum.KeyCode.LeftShift, false, "Hold", {}, {
		["Enable"] = Ninja.StartDash, 
		["Disable"] = Ninja.EndDash}
	)
end

function UnlockSlash()
	local Slash = require(Trigger:Clone())
	Slash.New("NinjaSlash", "1", false, "Press", {}, {
		["Enable"] = Ninja.Slash,
		["Info"] = function()
			return Misc.GetTargetMousePos(Mouse), StatsB.Slash.HitsRequired()
		end,
		["MainCallback"] = function()
			if not StatsA.SubtractStaminaWithChecking(StatsB.Shuriken.StaminaRate()) then Slash.Cancel() end
		end
	})
end

function UnlockShuriken()
	local Shuriken = require(Trigger:Clone())
	Shuriken.New("NinjaShuriken", "2", false, "Press", {
		["Length"] = StatsB.Shuriken.Cooldown
		}, {
		["Enable"] = Ninja.Shuriken,
		["Info"] = function()
			return Misc.GetTargetMousePos(Mouse), false
		end,
		["MainCallback"] = function()
			if not StatsA.SubtractStaminaWithChecking(StatsB.Shuriken.StaminaRate()) then Shuriken.Cancel() end
		end
	})
end

function UnlockJump()
	local Jump = require(Trigger:Clone())
	Jump.New("ChargedJump", Enum.KeyCode.Space, false, "Hold", {}, {
		["Enable"] = Ninja.Jump.StartJump,
		["Main"] = Ninja.Jump.ChargeJump,
		["Disable"] = Ninja.Jump.FinishJump,
		["Info"] = function()
			return StatsB.Jump.ChargeMaxHeight(StatsB.Jump.ChargeMaxHeight())
		end,
		["DisableCallback"] = function(Height)
			if not StatsA.SubtractStaminaWithChecking(StatsB.Jump.StaminaRate(Ninja.Jump.CurrentHeight)) then Jump.Cancel() end
		end
	})
end