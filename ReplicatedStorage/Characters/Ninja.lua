local Ninja = {}

RP = game:GetService("ReplicatedStorage")
CS = game:GetService("CollectionService")
SS = game:GetService("ServerScriptService")
TS = game:GetService("TweenService")
Debris = game:GetService("Debris")


-- Cosmetics
Shurikens = {"rbxassetid://3039421744", "rbxassetid://3039440319", "rbxassetid://3039435156"}

-- Paths
Effects = RP.Effects
Events = RP.Events.Ninja
Resources = RP.Resources.Ninja
ProjectilesFolder = workspace.Projectiles

-- Objects
Shuriken = Resources.Shuriken
Slash = Resources.Slash
AirStep = Resources.AirStep
Trails = Resources.Trails

-- Requires
Misc = require(RP.General.Misc)
BasicAttack = require(RP.SharedSkills.BasicAttack)
Jump = require(RP.SharedSkills.Jump)
Explosion = require(Effects.Explosion)

-- Misc
InvokePlayer = game.Players.LocalPlayer


--[[**
    Fires a Shuriken in the direction of the TargetPosition and at the speed of the ThrowingSpeed
	Sticks to an object upon contact

    @param [t:Vector3] TargetPosition Where the shuriken should be thrown
    @param [t:Number] Throwing Speed The speed at which the shuriken should be thrown

    @returns void
**--]]
function Ninja.Shuriken(TargetPosition, Exploding)
	if Ninja.Dashing then return end
	local Shuriken = Ninja.ShurikenObject:Clone()
	local Character = Ninja.Player.Character
	local PrimaryPart = Ninja.Player.PrimaryPart
	
	local Connection
	-- Inform server about the skill
	if InvokePlayer == Ninja.Player.Object then Events.Shuriken:FireServer(TargetPosition, Exploding, Ninja) end
	-- Shuriken spawns in front of the player --
	local StartingCFrame = CFrame.new(PrimaryPart.Position, TargetPosition) 
		* CFrame.Angles(0, 0, math.rad(90)) 
		+ PrimaryPart.CFrame.lookVector*3
	Shuriken.CFrame = StartingCFrame
	-- Gives a velocity based on the throwingspeed to the shuriken --
	Shuriken.BodyVelocity.Velocity = CFrame.new(Shuriken.CFrame.p, TargetPosition).lookVector*200
	Shuriken.Parent = workspace
	Shuriken.Anchored = false
	-- Adds a tag to be ignored in all projectiles --
	CS:AddTag(Shuriken, "ProjectileIgnore")
	
	-- Detect collision
	Misc.DetectCollision(StartingCFrame.p, TargetPosition, Character, Shuriken, function(Touched)
		-- Destroys all movable bodies --
		Shuriken.BodyVelocity:Destroy()
		Shuriken.Torque:Destroy()
		
		if Exploding then
			Explosion.Place(Shuriken.CFrame)
			Shuriken:Destroy()
		else
			-- Attaches shuriken to object --
			Shuriken.Velocity = Vector3.new()
			Misc.WeldInPlace(Shuriken, Touched)
			-- Schedules removal after 10 seconds --
			Debris:AddItem(Shuriken, 10)
		end
	end)
end

--[[**
    Triggers a slash projectile coming out of the front of the player towards TargetPosition and at a velocity of Speed

    @param [t:Vector3] TargetPosition Where the slash should head to
    @param [t:Number] Speed The speed at which the slash should move at

    @returns void
**--]]
function Ninja.Slash(TargetPosition, HitsNeeded)
	if Ninja.Dashing then return end
	if HitsNeeded-Ninja.SlashHits > 0 then Ninja.SlashHits = Ninja.SlashHits+1 return end
	local Slash = Ninja.SlashObject:Clone()
	local Character = Ninja.Player.Character
	local PrimaryPart = Ninja.Player.PrimaryPart
	
	-- Inform server about the skill
	if InvokePlayer == Ninja.Player.Object then Events.Slash:FireServer(TargetPosition, 0, Ninja) end
	
	local StartingCFrame = CFrame.new(PrimaryPart.Position 
		+ PrimaryPart.CFrame.lookVector*3, TargetPosition)
		* CFrame.Angles(0, math.rad(90), 0)
		* CFrame.Angles(Ninja.SlashFlip and math.rad(165) or math.rad(15), 0 ,0)
	Slash.CFrame = StartingCFrame
	local lookVector = CFrame.new(Slash.CFrame.p, TargetPosition).lookVector
		
	Slash.Anchored = false
	Slash.BodyVelocity.Velocity = lookVector*200
	Slash.Parent = ProjectilesFolder
	
	if Ninja.SlashFlip then Ninja.SlashFlip = false else Ninja.SlashFlip = true end
	
	TS:Create(Slash, TweenInfo.new(2), {["Transparency"] = 1}):Play()
	TS:Create(Slash.BodyVelocity, TweenInfo.new(2), {["Velocity"] = Slash.BodyVelocity.Velocity+lookVector*50}):Play()
	TS:Create(Slash, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.2), {["Size"] = Vector3.new(50, 1.35, 16.384)}):Play()
	
	CS:AddTag(Slash, "ProjectileIgnore")
	
	-- Detect collision
	local CollidingPart, Position = Misc.DetectCollision(StartingCFrame.p, TargetPosition, Character, Slash, function(Touch)
		Explosion.Place(Slash.CFrame)
		Slash:Destroy()
	end)
	
	Debris:AddItem(Slash, 5)
	Ninja.SlashHits = 0
end

function Ninja.StartDash()
	local Trails = Trails:Clone()
	local Character = Ninja.Player.Character
	
	-- Inform server about the skill
	if InvokePlayer == Ninja.Player.Object then Events.StartDash:FireServer(Ninja) end
	
	Ninja.Dashing = true
	Character.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed*2
	
	Trails.Left.Attachment0 = Character.LeftHand.LeftGripAttachment
	Trails.Left.Attachment1 = Character.LeftHand.LeftWristRigAttachment
	Trails.Right.Attachment0 = Character.RightHand.RightGripAttachment
	Trails.Right.Attachment1 = Character.RightHand.RightWristRigAttachment
	Trails.UpperLeft.Attachment0 = Character.LeftUpperArm.LeftShoulderAttachment
	Trails.UpperLeft.Attachment1 = Character.LeftUpperArm.LeftShoulderRigAttachment
	Trails.UpperRight.Attachment0 = Character.RightUpperArm.RightShoulderAttachment
	Trails.UpperRight.Attachment1 = Character.RightUpperArm.RightShoulderRigAttachment
	Trails.Center.Attachment0 = Character.Head.NeckRigAttachment
	Trails.Center.Attachment1 = Character.HumanoidRootPart.RootRigAttachment
	Trails.Parent = Character
	
	for _,part in pairs(Character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

function Ninja.EndDash()
	local Character = Ninja.Player.Character
	
	-- Inform server about the skill
	if InvokePlayer == Ninja.Player.Object then Events.EndDash:FireServer(Ninja) end
	
	Ninja.Dashing = false
	Character.Trails:Destroy()
	Character.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed/2
	
	for _,part in pairs(Ninja.Player.Character:GetChildren()) do
		if part:IsA("BasePart") and part ~= Ninja.Player.PrimaryPart then
			part.Transparency = 0
		end
	end
end

function Ninja.ChangeAura(Color)
	Explosion.Color3 = Color
	Slash.Color3 = Color
end

function Ninja.ChangeShuriken(ShurikenType)
	Ninja.ShurikenObject.MeshId = Shuriken[ShurikenType]
end

function Ninja.AirStep()
	if Ninja.Dashing then return end
	local AirStep = Ninja.AirStepObject:Clone()
	
	TS:Create(AirStep, TweenInfo.new(0.5), {["Transparency"] = 1}):Play()
	
	AirStep:SetPrimaryPartCFrame((Ninja.Player.PrimaryPart.CFrame+Vector3.new(0, -5, 0)) * CFrame.Angles(0, math.rad(90), 0))
	AirStep.Parent = ProjectilesFolder
end

function Ninja.New(Plr, ShurikenType, ObjectColors)
	Ninja.Player = Plr
	Ninja.InvokeParameters = {Plr, ShurikenType, ObjectColors}
	
	-- Initialize objects
	Ninja.ShurikenObject = Shuriken:Clone()
--	Ninja.ShurikenObject.MeshId = Shurikens[ShurikenType]
	
	Ninja.SlashObject = Slash:Clone()
	Ninja.SlashObject.Color = ObjectColors
	
	Ninja.Explosion = Explosion.New(ObjectColors)
	
	Ninja.AirStepObject = AirStep:Clone()
	
	Ninja.Trails = Trails:Clone()
	
	Ninja.Jump = Jump
	Ninja.Jump.New(Plr, Resources.AirStep)
	
	Ninja.BasicAttack = BasicAttack
	Ninja.BasicAttack.New(Plr, 3064549303, 3064548076)
	
	-- Varibles
	Ninja.SlashFlip = false
	Ninja.SlashHits = 0
	Ninja.Dashing = false
end

return Ninja
