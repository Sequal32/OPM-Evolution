local Jump = {}

CAS = game:GetService("ContextActionService")
RP = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")

ProjectilesFolder = workspace.Projectiles

function Jump.ChargeJump(MaxHeight)
	-- Play animation 
	Jump.CurrentHeight = Jump.CurrentHeight+1 < MaxHeight and Jump.CurrentHeight+1 or Jump.CurrentHeight
	return Jump.CurrentHeight
end

function Jump.StartJump()
	local Character = Jump.Character
	local Grounded = Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall
	
	Jump.CurrentHeight = 0

	if not Grounded and tick()-Jump.Cooldown > 0 and Jump.CanAirstep then -- Detect if the player is falling and hasn't activated yet
		Character.HumanoidRootPart.Anchored = true
		Jump.AirStepping = true
--	elseif Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
----		Jump.AirStepped = false
	end
end

function Jump.FinishJump()
	local Character = Jump.Character
	local Grounded = Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall
	
	if Grounded or Jump.AirStepping then
		local ChargedJump = Jump.CurrentHeight > 0
		
		Character.Humanoid.JumpPower = ChargedJump and Jump.CurrentHeight*1.38+56.67 or 50 
		Jump.Cooldown = ChargedJump and tick()+Jump.CurrentHeight/10+0.5 or Jump.Cooldown
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		wait()
		Character.Humanoid.JumpPower = 50
		return Jump.CurrentHeight
	end
	
	if Jump.AirStepping then
		Character.HumanoidRootPart.Anchored = false
--		Jump.AirStepped = true
		DisplayModel()
	end
	
	Jump.AirStepping = false
end

function DisplayModel()
	local AirStep = Jump.Object:Clone()
	local Tween
	
	if AirStep:IsA("Model") then
		AirStep:SetPrimaryPartCFrame((Jump.Character.PrimaryPart.CFrame+Vector3.new(0, -5, 0)) * CFrame.Angles(0, math.rad(90), 0))
		for _,part in pairs(AirStep:GetChildren()) do
			Tween = TS:Create(part, TweenInfo.new(0.5), {["Transparency"] = 1})
		end
	else
		Tween = TS:Create(AirStep, TweenInfo.new(0.5), {["Transparency"] = 1})
		AirStep.CFrame = (Jump.Character.PrimaryPart.CFrame+Vector3.new(0, -5, 0)) * CFrame.Angles(0, math.rad(90), 0)
	end
	
	Tween:Play()
	AirStep.Parent = ProjectilesFolder
	
	Tween.Completed:Connect(function()
		AirStep:Destroy()
	end)
end

function Jump.New(Plr, Model, FunctionCheck, CanAirstep)
	Jump.AirStepped = false
	Jump.AirStepping = false
	Jump.CanAirstep = CanAirstep
	Jump.Character = Plr.Character
	
	Jump.CheckAvailable = FunctionCheck
	
	Jump.Cooldown = 0
	Jump.LastJump = 0
	
	Jump.CurrentHeight = 0
	Jump.Object = Model
end

return Jump
