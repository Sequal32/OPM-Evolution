local SuperHuman = {}

RP = game:GetService("ReplicatedStorage")
CAS = game:GetService("ContextActionService")
CS = game:GetService("CollectionService")
TS = game:GetService("TweenService")
Debris = game:GetService("Debris")

-- Paths
Effects = RP.Effects
Events = RP.Events.SuperHuman
GeneralEvents = RP.Events.General
Resources = RP.Resources.SuperHuman
ProjectilesFolder = workspace.Projectiles
SharedSkills = RP.SharedSkills

-- Objects
Fist = Resources.Fist
Boulder = Resources.Boulder
Rock = Resources.Rock
AimObject = Resources.Sight
ShockwaveObject = Resources.Shockwave

-- Requires
Misc = require(RP.General.Misc)
Explosion = require(Effects.Explosion)
BasicAttack = SharedSkills.BasicAttack
Jump = SharedSkills.Jump
Sprint = SharedSkills.Sprint

-- Using Variables
Character = nil
PrimaryPart = nil
Stats = nil

-- Misc
InvokePlayer = game.Players.LocalPlayer

function TweenNewFist(StartCFrame, EndCFrame)
	local CFValue = Instance.new("CFrameValue")
	local Fist = SuperHuman.Fist:Clone()
	local Connection
	CFValue.Value = StartCFrame
		
	Fist.Parent = workspace.Projectiles
	Fist:SetPrimaryPartCFrame(StartCFrame)
		
	local Tween = TS:Create(CFValue, TweenInfo.new(0.1), {["Value"] = EndCFrame})
	Tween:Play()
	
	for _,part in pairs(Fist:GetChildren()) do
		TS:Create(part, TweenInfo.new(0.5*(1-part.Transparency)), {["Transparency"] = 1}):Play()
	end
	
	CS:AddTag(Fist, "ProjectileIgnore")
		
	Connection = game["Run Service"].RenderStepped:Connect(function()
		Fist:SetPrimaryPartCFrame(CFValue.Value)
	end)
	
	Tween.Completed:connect(function()
		Connection:Disconnect()
	end)
	
	return Tween, Fist
end

function HideArms()
	Character.LeftHand.Transparency = 1
	Character.LeftLowerArm.Transparency = 1
	Character.LeftUpperArm.Transparency = 1
	Character.RightHand.Transparency = 1
	Character.RightLowerArm.Transparency = 1
	Character.RightUpperArm.Transparency = 1
end

function ShowArms()
	Character.LeftHand.Transparency = 0
	Character.LeftLowerArm.Transparency = 0
	Character.LeftUpperArm.Transparency = 0
	Character.RightHand.Transparency = 0
	Character.RightLowerArm.Transparency = 0
	Character.RightUpperArm.Transparency = 0
end

-- FIRST MOVE --

function SuperHuman.Punch(Position)
	local Initial = CFrame.new(PrimaryPart.Position, Position)
	local RandomOffset = Vector3.new(Misc.NumberGen:NextNumber(-1, 1), 0, Misc.NumberGen:NextNumber(-1, 1))
	local StartCFrame = Initial + Initial.lookVector + RandomOffset
	local EndCFrame = StartCFrame + Initial.lookVector*13 + RandomOffset
	
	-- Inform server about the skill
	if Self then 
		Events.Punch:FireServer(Position, SuperHuman)
		RP.Events.General.DoDamage:FireServer("Ray", true, false, StartCFrame.p, EndCFrame.p, 13, Stats.SuperHuman.RangedPunch.Damage()) 
		RP.Events.General.EXPAttack:FireServer("Punch")
	end
	
	local Tween, Fist = TweenNewFist(StartCFrame, EndCFrame)
	Tween.Completed:Connect(function()
		Fist:Destroy()
	end)
	
--	SuperHuman.PointToPos(TargetPosition)
end

function SuperHuman.StartPunch()
	Character.Humanoid.AutoRotate = false
	HideArms()
end

function SuperHuman.StopPunch()
	Character.Humanoid.AutoRotate = true
	ShowArms()
end

-- END FIRST MOVE --

function SuperHuman.RangedPunch(TargetPosition)
	local Initial = CFrame.new(PrimaryPart.Position, TargetPosition) * CFrame.new(-4.5, -3, 0)
	local MoreInitial = Initial * CFrame.new(2.5, 2, 0)
	
	-- Inform server about the skill
	if Self then Events.RangedPunch:FireServer(TargetPosition, SuperHuman) end

	HideArms()
	
	local CollisionPositions = {}
	for i=0, 12 do
		local StartCFrame = (Initial + Initial.lookVector*3) * CFrame.new((i % 4 * 3) + Misc.NumberGen:NextNumber(-1, 1), (i % 3 * 3) + Misc.NumberGen:NextNumber(-1, 1), 0)
		local EndCFrame = StartCFrame + Initial.lookVector*10
		
		local Tween, Fist = TweenNewFist(StartCFrame, EndCFrame)
		local Part, Position = Misc.FindCollisionPart(StartCFrame.p, (MoreInitial + MoreInitial.lookVector*40).p, Character, 1000)
		
		if Part then table.insert(CollisionPositions, Position) end
	end
	
	ShowArms()
	
	for _,position in pairs(CollisionPositions) do
		spawn(function()
			local Distance = (PrimaryPart.Position-position).magnitude
			wait(Distance*0.0005555555555)
			
			Explosion.Place(CFrame.new(position))
			if Self then RP.Events.General.DoDamage:FireServer("Radius", true, position, Explosion.Size.X, Stats.SuperHuman.RangedPunch.Damage()) end
		end)
	end
end

function SuperHuman.RockSmash(LookVector, NumberOfRocks)
	local StartCFrame = PrimaryPart.CFrame
	local RingStartCFrame = PrimaryPart.CFrame * CFrame.Angles(math.rad(90), 0, 0) - Vector3.new(0, 3, 0)
	local Parts = {}
	
	if Self then Events.RockSmash:FireServer(LookVector, NumberOfRocks, SuperHuman) end
	
	for i=0, 2, 1 do
		local Ring = Resources["Ring"..i]:Clone()
		table.insert(Parts, Ring)
		
		Ring.CFrame = RingStartCFrame + Vector3.new(0, i*2, 0)
		Ring.Parent = workspace.Projectiles
		TS:Create(Ring, TweenInfo.new(1), {["Transparency"] = 1, ["CFrame"] = Ring.CFrame+Vector3.new(0, 0.5, 0)}):Play()
		wait()
	end
	
	for i=1, NumberOfRocks, 1 do
		local Rock = Rock:Clone()
		local BricksTouching = {}
		
		Rock.CFrame = StartCFrame + Vector3.new(LookVector.X, 0, LookVector.Z)*i*Rock.Size.X - Vector3.new(0, Rock.Size.X*1.4, 0)
		table.insert(Parts, Rock)
		
		local Tween = TS:Create(Rock, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {["CFrame"] = Rock.CFrame * CFrame.Angles(math.rad(Misc.NumberGen:NextNumber(-45, 45)), 0, 0) * CFrame.Angles(0, 0, math.rad(Misc.NumberGen:NextNumber(-45, 45))) + Vector3.new(0, Rock.Size.X, 0)})
		Tween:Play()
		
		Tween.Completed:Connect(function()
			if Self then RP.Events.General.DoDamage:FireServer("Radius", true, Rock.Position, Rock.Size.X, Stats.SuperHuman.RockSmash.Damage()) end
			wait(2.5)
			Tween = TS:Create(Rock, TweenInfo.new(0.5), {["CFrame"] = Rock.CFrame - Vector3.new(0, Rock.Size.X, 0), ["Transparency"] = 1}):Play()
		end)
		
		Rock.Parent = workspace.Projectiles
		wait()
	end
	
	wait(3.7)
	table.foreach(Parts, function(_, Part)
		Part:Destroy()
	end)
end

-- EMBODY BURROW
BurrowCFValue = Instance.new("CFrameValue")
Burrowing = nil
BurrowingTick = 0

function SuperHuman.SpawnRock(CF)
	local Rock = Rock:Clone()
	CS:AddTag(Rock, "ProjectileIgnore")
	Rock.Size = Vector3.new(5, 5, 5)
	Rock.CFrame = CF
	Rock.Parent = workspace.Projectiles
	--Inform server about the skill
	if Self then Events.SpawnRock:FireServer(CF, SuperHuman) end
	
	TS:Create(Rock, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1), {["CFrame"] = Rock.CFrame - Vector3.new(0, Rock.Size.X, 0), ["Transparency"] = 1}):Play()
	Debris:AddItem(Rock, 1.5)
end

function SuperHuman.EndBurrow()
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Character.Humanoid
	-- Find spot to put the character back
	local Part, Position = Misc.FindCollisionPart(PrimaryPart.Position+Vector3.new(0, 600, 0), Character.PrimaryPart.Position, Character, 650)
	Character:SetPrimaryPartCFrame(CFrame.new(Position))
	
	PrimaryPart.Anchored = false
	Burrowing:Disconnect()
end

function SuperHuman.Burrow(LookVector)
--	if not Burrowing then return false end
	
	local Part, Position = Misc.FindCollisionPart(PrimaryPart.Position-Vector3.new(0, 50, 0), PrimaryPart.Position+Vector3.new(0, 100, 0), nil, 100)
	TS:Create(BurrowCFValue, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {["Value"] = CFrame.new(Position.X+LookVector.X*50, Position.Y-14, Position.Z+LookVector.Z*50)}):Play()
	
	if BurrowingTick % 2 == 0 then
		SuperHuman.SpawnRock(Character.Above.CFrame * CFrame.Angles(math.rad(Misc.NumberGen:NextNumber(-45, 45)), 0, 0) * CFrame.Angles(0, 0, math.rad(Misc.NumberGen:NextNumber(-45, 45))))
	end
	
	BurrowingTick = BurrowingTick+1
	
--	return true
end

function SuperHuman.StartBurrow()
	local Camera = workspace.CurrentCamera
	
	Camera.CameraType = Enum.CameraType.Track
	Camera.CameraSubject = Character.Above
	
	PrimaryPart.Anchored = true
	BurrowingTick = 0
	
	local Part, Position = Misc.FindCollisionPart(PrimaryPart.Position-Vector3.new(0, 50, 0), PrimaryPart.Position+Vector3.new(0, 100, 0), nil, 100)
	BurrowCFValue.Value = CFrame.new(Position.X, Position.Y-14, Position.Z)
	
	Burrowing = game:GetService("RunService").RenderStepped:Connect(function()
		Character:SetPrimaryPartCFrame(BurrowCFValue.Value)
	end)
end

AimSpot = nil
Ending = false

function SuperHuman.EndBullet()
	Ending = true
	PrimaryPart.Anchored = false
	Character.Humanoid.JumpPower = 16
	
	if AimSpot == nil or PrimaryPart.Anchored then return end

	local BV = Instance.new("BodyVelocity", PrimaryPart)
	BV.MaxForce = Vector3.new(10000000, 10000000, 10000000)
	
	local Ticks = 0
	
	local Done = false
	local Connection
	
	Connection = game["Run Service"].Heartbeat:Connect(function()
		local Direction = CFrame.new(PrimaryPart.Position, AimSpot.Position).lookVector
		if (PrimaryPart.Position-AimSpot.Position).magnitude <= 10 or Done then
			local Part, Position = Misc.FindCollisionPart(PrimaryPart.Position+Vector3.new(0, 400, 0), Character.PrimaryPart.Position, Character, 650)
			Character:SetPrimaryPartCFrame(CFrame.new(Position+Vector3.new(0, 2, 0), Position+Direction*5))
			Done = true
		else
			Ticks = Ticks+wait()
			BV.Velocity = Direction*(Ticks*500+100)
		end
	end)
	
	repeat wait() until Done
	Connection:Disconnect()
	
	AimSpot:Destroy()
	
	PrimaryPart.Anchored = true
	BV.Velocity = Vector3.new()
	PrimaryPart.Velocity = Vector3.new()
	PrimaryPart.RotVelocity = Vector3.new()
	
	if Self then RP.Events.General.DoDamage:FireServer("Radius", true, PrimaryPart.Position, 30, Stats.SuperHuman.RockSmash.Damage()) end
	
	wait(0.2)
	BV:Destroy()
	PrimaryPart.Anchored = false
end

function SuperHuman.AimBullet(LookVector)
	if not AimSpot then return end

	local Part, Position = Misc.FindCollisionPart(PrimaryPart.Position, PrimaryPart.Position+LookVector*100, nil, 10000)
	
	if not Part then return end
	
	TS:Create(AimSpot, TweenInfo.new(0.2), {["CFrame"] = CFrame.new(Position)}):Play()
end

function SuperHuman.StartBullet()
	Ending = false
	-- Shockwave
	local Shockwave = ShockwaveObject:Clone()
	Shockwave.Parent = workspace.Projectiles
	Shockwave:SetPrimaryPartCFrame(PrimaryPart.CFrame-Vector3.new(0, -3, 0))
	local Tween = TS:Create(Shockwave.Part1, TweenInfo.new(2, Enum.EasingStyle.Linear), {["Size"] = Vector3.new(20.867, 1.513, 20.338), ["Transparency"] = 1})
	Tween:Play()
	TS:Create(Shockwave.Part2, TweenInfo.new(2, Enum.EasingStyle.Linear), {["Size"] = Vector3.new(20.56, 1.454, 20.051), ["Transparency"] = 1}):Play()
	
	Tween.Completed:Connect(function()
		Shockwave:Destroy()
	end)
	
	-- Launches character into the air
	if not Self then return end 
	
	Events.StartBullet:FireServer(SuperHuman)
	
	Character.Humanoid.JumpPower = 600
	Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	repeat
		wait()
	until PrimaryPart.Velocity.Y <= 100 or Ending
	
	Shockwave:Destroy()
	
	if Ending then return end
	
	PrimaryPart.Anchored = true
	
	AimSpot = AimObject:Clone()
	AimSpot.Parent = workspace.Projectiles
	CS:AddTag(AimSpot, "ProjectileIgnore")
end

--function SuperHuman.BoulderToss(TargetPosition)
--	
--	local Boulder = SuperHuman.Boulder:Clone()
--	local Boulder1, Boulder2 = Boulder.Rock1, Boulder.Rock2
--	
--	local Done = false
--	
--	local ContactConnection
--	-- Inform server about the skill
--	if Self then Events.BoulderToss:FireServer(TargetPosition, SuperHuman) end
--	
--	local StartCFrame = CFrame.new(PrimaryPart.Position+Vector3.new(0, -10, 0))
--	local FrontCFrame = CFrame.new(PrimaryPart.Position+Vector3.new(0, 5, 0), TargetPosition)
--	FrontCFrame = FrontCFrame+FrontCFrame.lookVector*10
--	StartCFrame = StartCFrame+PrimaryPart.CFrame.lookVector*10
--	
--	PrimaryPart.Anchored = true
--	
--	Boulder.Parent = workspace.Projectiles
--	Boulder:SetPrimaryPartCFrame(StartCFrame)
--	
--	local Tween = TS:Create(Boulder1, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {["CFrame"] = FrontCFrame})
--	TS:Create(Boulder2, TweenInfo.new(0.5), {["CFrame"] = FrontCFrame}):Play()
--	Tween:Play()
--	Tween.Completed:wait()
--	
--	Boulder1.Anchored = false
--	Boulder1.Velocity = FrontCFrame.lookVector*200
--	
--	-- DAMAGE
--	spawn(function()
--		while Boulder.Parent do
--			if Self then GeneralEvents.DoDamage:FireServer("Radius", Boulder2.Position, Boulder2.Size, 5, Stats.SuperHuman.BoulderToss.Damage()) end
--			wait(0.2)
--		end
--	end)
--	
--	ContactConnection = Boulder2.Touched:Connect(function(Hit)
--		if not Boulder then return end
--		
--		Boulder2.BrickImpactEmitter.Rate = 5000
--		Boulder2.BrickImpactEmitter.Size = NumberSequence.new(2)
--		
--		Tween = TS:Create(Boulder1, TweenInfo.new(1), {["Size"] = Vector3.new(1, 1, 1)})
--		TS:Create(Boulder2, TweenInfo.new(1), {["Size"] = Vector3.new(1, 1, 1)}):Play()
--		
--		Tween:Play()
--		wait(0.5)
--		if not Boulder2:FindFirstChild("BrickImpactEmitter") then return end
--		
--		Boulder2.BrickImpactEmitter.Rate = 40
--		Tween.Completed:wait()
--		
--		Boulder:Destroy()
--	end)
--	PrimaryPart.Anchored = false
--	Done = true
--end

function SuperHuman.PointToPos(Position)
	
--	TS:Create(Character.LowerTorso, TweenInfo.new(0.03), {["CFrame"] = CFrame.new(Character.LowerTorso.Position, Vector3.new(Position.X, 0, Position.Z))}):Play()
	Character.LowerTorso.CFrame = CFrame.new(Character.LowerTorso.Position, Position)
--	Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPart.Position+Vector3.new(0, 0.5, 0), position))
end

function SuperHuman.New(Plr)
	Character = Plr.Character
	PrimaryPart = Plr.PrimaryPart
	Stats = Plr.Stats
	
	SuperHuman.InvokeParameters = {Plr}
	Self = InvokePlayer == Plr.Object
	
	SuperHuman.Fist = Fist:Clone()
	
	SuperHuman.Explosion = Explosion.New(Color3.fromRGB(255, 255, 255))
	
	SuperHuman.Boulder = Boulder:Clone()
    
    if not Self then return end -- None of the skills below are going to be replicated
	SuperHuman.Jump = require(Jump:Clone())
	SuperHuman.Jump.New(Plr, nil, nil, false)
	
	SuperHuman.Sprint = require(Sprint:Clone())
	SuperHuman.Sprint.New(Plr)
	
	SuperHuman.BasicAttack = require(BasicAttack:Clone())
	SuperHuman.BasicAttack.New(Plr, 3064549303, 3064548076)
end

return SuperHuman
