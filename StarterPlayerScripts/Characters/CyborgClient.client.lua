RP = game:GetService("ReplicatedStorage")
UIS = game:GetService("UserInputService")

PlayerObject = game.Players.LocalPlayer
Mouse = PlayerObject:GetMouse()

-- TODO, implement stats
Events = RP.Events.Cyborg

-- Paths
Characters = RP.Characters
General = RP.General
Resources = RP.Resources.Cyborg

Trigger = General.SkillTrigger

Misc = require(RP.General.Misc)

-- INITIALIZE EVERYTHING
Player = require(General.Player)
StatsA = Player.Stats
StatsB = StatsA.Cyborg
Cyborg = require(Characters.Cyborg)
Cyborg.New(Player)

RP.Events.General.CharacterSelected:FireServer("Cyborg")

UnlockLevels = {
	[5] = UnlockBulletStorm,
	[15] = UnlockHover,
	[10] = UnlockJump,
	[25] = UnlockUltimate
}

--Name, Input, CreateTouchButton, TriggerType, CooldownType, CooldownLength, FunctionEnable, FunctionMain, FunctionDisable, FunctionGetInfo, FunctionCallback
local BasicAttack = require(Trigger:Clone())
	BasicAttack.New("BasicAttack", "c", false, "Press", {
		["Length"] = function()
			return 0.5
		end 
		}, {
		["Enable"] = Cyborg.BasicAttack.Use,
		["Main"] = Cyborg.BasicAttack.Use,
})

function UnlockBulletStorm()
	Bullets = require(Trigger:Clone())
	Bullets.New("FireBulletStorm", "1", false, "Hold", {
		["Main"] = StatsB.Pellets.Cooldown 
		}, {
		["Enable"] = Cyborg.PelletStorm, 
		["Main"] = Cyborg.PelletStorm, 
		["Info"] = function() 
			return Misc.GetTargetMousePos(Mouse)
		end,
		["MainCallback"] = function()
			if StatsA.SubtractStaminaWithChecking(StatsB.Pellets.StaminaRate()) then return end
			Bullets.Cancel()
		end
	})
end

function UnlockUltimate()
	local FireUltimate = require(Trigger:Clone())
	FireUltimate.New("FireUltimate", "3", false, "Hold", {["Length"] = StatsB.Blast.Cooldown}, {
		["Enable"] = Cyborg.Blast, 
		["Main"] = Cyborg.FollowMouse, 
		["Disable"] = Cyborg.CancelBlast, 
		["Info"] = function()
			return Misc.GetTargetMousePos(Mouse)
		end,
		["EnableCallback"] = function()
			if not StatsA.SubtractStaminaWithChecking(StatsB.Blast.StaminaRate()) then FireUltimate.Cancel() end
		end
	})
end

function UnlockHover()
	local Hover = require(Trigger:Clone())
	Hover.New("Hover", "2", false, "Toggle", {}, {
		["Enable"] = Cyborg.Hover,
		["Main"] = Cyborg.UpdateHover, 
		["Disable"] = Cyborg.StopHover, 
		["Info"] = function()
			local VerticalComponent
			
			if UIS:IsKeyDown(Enum.KeyCode.R) then 
				VerticalComponent = 1
			elseif UIS:IsKeyDown(Enum.KeyCode.F) then
				VerticalComponent = -1
			else
				VerticalComponent = 0
			end
			
			local LateralSpeed, VerticalSpeed = StatsB.Hover.Speed()
			
			return LateralSpeed, VerticalSpeed*VerticalComponent
		end,
		["MainCallback"] = function(Return, LastCall)
			if not StatsA.SubtractStaminaWithChecking(StatsB.Hover.StaminaRate() * LastCall) then Hover.Cancel() end
		end
	})
end

function UnlockJump()
	local Jump = require(Trigger:Clone())
	Jump.New("ChargedJump", Enum.KeyCode.Space, false, "Hold", {}, {
		["Enable"] = Cyborg.Jump.StartJump,
		["Main"] = Cyborg.Jump.ChargeJump,
		["Disable"] = Cyborg.Jump.FinishJump,
		["Info"] = function()
			return StatsB.Jump.ChargeMaxHeight()
		end,
		["DisableCallback"] = function(Height)
			if not StatsA.SubtractStaminaWithChecking(StatsB.Jump.StaminaRate(Cyborg.Jump.CurrentHeight)) then Jump.Cancel() end
		end
	})
end

UnlockBulletStorm()
UnlockHover()
UnlockJump()
UnlockUltimate()