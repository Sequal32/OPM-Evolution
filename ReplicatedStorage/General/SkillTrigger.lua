local Trigger = {}

CAS = game:GetService("ContextActionService")
Player = game.Players.LocalPlayer

SkillDisableTime = Player.PlayerScripts:WaitForChild("RunningVars"):WaitForChild("SkillDisableTime")

function EmptyFunction()
	return 0
end

function DisableHold()
	Trigger.Held = false
	Trigger.FunctionDisableCallback(Trigger.FunctionDisable())
end

function DisableToggle()
	Trigger.Toggled = false
	Trigger.FunctionDisableCallback(Trigger.FunctionDisable())
end

function SkillAvailable()
    return SkillDisableTime.Value <= 0
end

function Hold(ActionName, InputState, InputObj)
	local CurrentTime = os.time()
	if InputState == Enum.UserInputState.Begin then
        Trigger.Cancelling = false
        
		if SkillIsAvailable() or CurrentTime-Trigger.TriggeredAt < Trigger.CooldownLength() then return end
		
		Trigger.FunctionEnableCallback()
		spawn(function() Trigger.FunctionEnable(Trigger.FunctionGetInfo()) end)

		Trigger.Held = true
		
		spawn(function()
			if Trigger.FunctionMain2 == EmptyFunction then return end

			while Trigger.Held do
				wait()
				Trigger.FunctionMain2(Trigger.FunctionGetInfo())
			end
		end)
		
		while Trigger.Held do
			if Trigger.Cancelling then if Trigger.DisableIfCancel then DisableHold() end break end
			Trigger.TriggeredAt = os.time()
			Trigger.FunctionMainCallback(Trigger.FunctionMain(Trigger.FunctionGetInfo()), Trigger.LastCall)
			Trigger.LastCall = wait(Trigger.CooldownMain())
		end
		
	elseif InputState == Enum.UserInputState.End then
		wait()
		DisableHold()
	end
end

function HoldOnce(ActionName, InputState, InputObj)
	local CurrentTime = os.time()
    if InputState == Enum.UserInputState.Begin then
		Trigger.Cancelling = false
		if SkillIsAvailable() or CurrentTime-Trigger.TriggeredAt < Trigger.CooldownLength() then return end

		Trigger.FunctionEnableCallback(Trigger.FunctionEnable(Trigger.FunctionGetInfo()))
		
		if Trigger.Cancelling then DisableHold() return end
		
		Trigger.TriggeredAt = os.time()
		Trigger.FunctionMainCallback(Trigger.FunctionMain(Trigger.FunctionGetInfo()))
		Trigger.LastCall = wait(Trigger.CooldownMain())
		
	elseif InputState == Enum.UserInputState.End then
		wait()
		DisableHold()
	end
end

function Toggle(ActionName, InputState, InputObj)
	local CurrentTime = os.time()
	if InputState == Enum.UserInputState.Begin then
		Trigger.Cancelling = false
		if Trigger.Toggled then
			Trigger.Toggled = false
			Trigger.FunctionDisableCallback(Trigger.FunctionDisable())
		else
			if CurrentTime-Trigger.TriggeredAt < Trigger.CooldownLength() then return end
			
			Trigger.Toggled = true
			Trigger.FunctionEnableCallback(Trigger.FunctionEnable())
			
			while Trigger.Toggled do
				if Trigger.Cancelling then DisableToggle() break end
				Trigger.TriggeredAt = CurrentTime
				Trigger.FunctionMainCallback(Trigger.FunctionMain(Trigger.FunctionGetInfo()), Trigger.LastCall)
				Trigger.LastCall = wait(Trigger.CooldownMain())
			end
		end
	end
end

function Press(ActionName, InputState, InputObj)
	if InputState == Enum.UserInputState.Begin then
		local CurrentTime = os.time()
		Trigger.Cancelling = false
		
		if SkillIsAvailable() or CurrentTime-Trigger.TriggeredAt > Trigger.CooldownLength() then
			Trigger.FunctionEnableCallback(Trigger.FunctionEnable())
	
			if Trigger.Cancelling then return end
			
			Trigger.TriggeredAt = os.time()
			Trigger.FunctionMainCallback(Trigger.FunctionMain(Trigger.FunctionGetInfo()))
		end
	end
end

function Trigger.ChangeBinding()
	
end

function Trigger.ResetCooldown()
--	Trigger.TriggeredAt = 0
end

function Trigger.Cancel()
	Trigger.Cancelling = true
end

function Trigger.New(Name, Input, CreateTouchButton, TriggerType, Cooldowns, Functions, DisableIfCancel)
    CAS:UnbindAction(Name) -- Make sure we're overwriting the previous action if there is one

	if TriggerType == "Hold" then
		CAS:BindAction(Name, Hold, CreateTouchButton, Input)
		Trigger.Held = false
	elseif TriggerType == "HoldOnce" then
		CAS:BindAction(Name, HoldOnce, CreateTouchButton, Input)
		Trigger.Held = false
	elseif TriggerType == "Press" then
		CAS:BindAction(Name, Press, CreateTouchButton, Input)
	elseif TriggerType == "Toggle" then
		CAS:BindAction(Name, Toggle, CreateTouchButton, Input)
		Trigger.Toggled = false
	end
	
	Trigger.FunctionEnableCallback = Functions.EnableCallback or EmptyFunction
	Trigger.FunctionMainCallback = Functions.MainCallback or EmptyFunction
	Trigger.FunctionDisableCallback = Functions.DisableCallback or EmptyFunction
	Trigger.FunctionEnable = Functions.Enable or EmptyFunction
	Trigger.FunctionDisable = Functions.Disable or EmptyFunction
	Trigger.FunctionMain2 = Functions.Main2 or EmptyFunction
	Trigger.FunctionMain = Functions.Main or EmptyFunction
	Trigger.FunctionGetInfo = Functions.Info or EmptyFunction
	Trigger.CooldownLength = Cooldowns.Length or EmptyFunction
	Trigger.CooldownMain = Cooldowns.Main or EmptyFunction
	Trigger.Cancelling = false
	Trigger.LastCall = 0
	Trigger.TriggeredAt = 0
	Trigger.DisableIfCancel = DisableIfCancel
end

return Trigger
