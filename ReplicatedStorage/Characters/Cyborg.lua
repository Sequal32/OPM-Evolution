local Cyborg = {}

RP = game:GetService("ReplicatedStorage")
CS = game:GetService("CollectionService")
TS = game:GetService("TweenService")
Debris = game:GetService("Debris")


-- Paths
Resources = RP.Resources.Cyborg
Events = RP.Events.Cyborg
GeneralEvents = RP.Events.General
Effects = RP.Effects
ProjectilesFolder = workspace.Projectiles

-- Objects
Blast = Resources.Blast
AirStep = Resources.AirStep
Hover = Resources.Hover
Pellet = Resources.Pellet
ExplosionObject = Resources.Explosion

Explosion = Effects.Explosion

-- Requires
Misc = require(RP.General.Misc)
BasicAttack = require(RP.SharedSkills.BasicAttack)
Jump = require(RP.SharedSkills.Jump)

-- TweenPositions
ChargeSizes = {
	Vector3.new(27.223, 14.2, 2.67), -- Blast1
	Vector3.new(28.477, 15.228, 3.677), -- Blast 2
	Vector3.new(1.192, 25.66, 32.784) -- Cross
}

-- Misc
InvokePlayer = game.Players.LocalPlayer

function Cyborg.CancelBlast()
	if Cyborg.CanCancel then 
		-- Inform server about the skill
		if Self then Events.CancelBlast:FireServer(Cyborg) end
		Cyborg.Player.PrimaryPart.Anchored = false
		Cyborg.CurrentBlast:Destroy()
	end
end

function Cyborg.FollowMouse(Position)
	if Cyborg.FollowMouseBool then
		-- Inform server about the skill
		if Self then Events.FollowMouse:FireServer(Position, Cyborg) end
		
		local Character = Cyborg.Player.Character
		local PrimaryPart = Cyborg.Player.PrimaryPart
		
		Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPart.Position, Position))
		Cyborg.CurrentBlast:SetPrimaryPartCFrame(CFrame.new(PrimaryPart.Position+PrimaryPart.CFrame.lookVector*5+Vector3.new(0, 2.5, 0), Position))
	end
end

function Cyborg.Blast()
	local Character = Cyborg.Player.Character
	local PrimaryPart = Cyborg.Player.PrimaryPart
	
	-- Inform server about the skill
	if Self then Events.Blast:FireServer(Cyborg) end
	
	Cyborg.FollowMouseBool = true
	Cyborg.CanCancel = true
	
	Cyborg.CurrentBlast = Cyborg.BlastObject:Clone()
	PrimaryPart.Anchored = true
	local Blast = Cyborg.CurrentBlast
	
	pcall(function()
	local Blast1, Blast2 = Blast.Blast1, Blast.Blast2
	local Cloud1, Cloud2, Cloud3, Cloud4, Cloud5, Cloud6 = Blast.Cloud1, Blast.Cloud2, Blast.Cloud3, Blast.Cloud4, Blast.Cloud5, Blast.Cloud6
	local Wrap1, Wrap2 = Blast.Wrap1, Blast.Wrap2
	local Cross = Blast.Cross
	
	local CurrentLookDirection = PrimaryPart.CFrame.lookVector
	
	Blast.Parent = workspace.Projectiles
	
	-- Cross tweens
	local Tween = TS:Create(Cross, TweenInfo.new(1), {["Size"] = ChargeSizes[3]})
	Tween:Play()
	Tween.Completed:wait()
	TS:Create(Cross, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2), {["Transparency"] = 1}):Play()
	Cyborg.CanCancel = false
	-- Blast tweens
	Tween = TS:Create(Blast1, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {["Transparency"] = 0, ["Size"] = ChargeSizes[1]})
	TS:Create(Blast2, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {["Transparency"] = 0.25, ["Size"] = ChargeSizes[2]}):Play()
	TS:Create(Blast2.ParticleEmitter, TweenInfo.new(0.75), {["Rate"] = 5000}):Play()
	
	-- Fires HERE
	local StartingCFrame = Cyborg.CurrentBlast.PrimaryPart.CFrame
	Tween:Play()
	Tween.Completed:wait()
	Cyborg.FollowMouseBool = false
	-- Final blast tweens & thinning
	local FinalSize1, FinalSize2 = Vector3.new(Blast1.Size.X, Blast1.Size.Y, 903.67), Vector3.new(Blast2.Size.X, Blast2.Size.Y, 904.677)
	local FinalCFrame1, FinalCFrame2 = Blast1.CFrame+PrimaryPart.CFrame.lookVector*450, Blast2.CFrame+PrimaryPart.CFrame.lookVector*450
	local FinalTInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
	
	Tween = TS:Create(Blast1, FinalTInfo, {["Size"] = FinalSize1, ["CFrame"] = FinalCFrame1})
	TS:Create(Blast2, FinalTInfo, {["Size"] = FinalSize2, ["CFrame"] = FinalCFrame2}):Play()
	Tween:Play()
	
	-- Wraps
	Wrap1.Transparency, Wrap2.Transparency = 0, 0
	TS:Create(Wrap1, FinalTInfo, {["Position"] = FinalCFrame1.p,["Size"] = Vector3.new(900.996, 19.525, 31.414)}):Play()
	TS:Create(Wrap2, FinalTInfo, {["Position"] = FinalCFrame2.p,["Size"] = Vector3.new(900.996, 19.525, 29.414)}):Play()
	
	-- Clouds  
	TS:Create(Cloud1, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {["Transparency"] = 0.5}):Play()
	TS:Create(Cloud2, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.05), {["Transparency"] = 0.5}):Play()
	TS:Create(Cloud3, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.10), {["Transparency"] = 0.5}):Play()
	TS:Create(Cloud4, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.15), {["Transparency"] = 0.5}):Play()
	TS:Create(Cloud5, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.20), {["Transparency"] = 0.5}):Play()
	TS:Create(Cloud6, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25), {["Transparency"] = 0.5}):Play()
	wait(0.3)
	TS:Create(Cloud1, TweenInfo.new(1), {["Position"] = Cloud1.Position+Cloud1.CFrame.lookVector*5}):Play()
	TS:Create(Cloud2, TweenInfo.new(1), {["Position"] = Cloud2.Position+Cloud2.CFrame.lookVector*5}):Play()
	TS:Create(Cloud3, TweenInfo.new(1), {["Position"] = Cloud3.Position+Cloud3.CFrame.lookVector*5}):Play()
	TS:Create(Cloud4, TweenInfo.new(1), {["Position"] = Cloud4.Position+Cloud4.CFrame.lookVector*5}):Play()
	TS:Create(Cloud5, TweenInfo.new(1), {["Position"] = Cloud5.Position+Cloud5.CFrame.lookVector*5}):Play()
	TS:Create(Cloud6, TweenInfo.new(1), {["Position"] = Cloud6.Position+Cloud6.CFrame.lookVector*5}):Play()
	
	-- Detect Collision
	local Collisions = Misc.FindCollisionParts(
		Cyborg.Player.PrimaryPart.CFrame.p, 
		(Cyborg.CurrentBlast.PrimaryPart.CFrame+Cyborg.CurrentBlast.PrimaryPart.CFrame.lookVector*3000).p, 
		Character)
	
	for _,collision in pairs(Collisions) do
		Cyborg.Explosion.Place(CFrame.new(collision[2]))
	end
	-- Inform server about the projectile
--	GeneralEvents.Projectile:FireServer("Single", PrimaryPart.CFrame, PrimaryPart.)
	
	Tween.Completed:wait()
	
	PrimaryPart.Anchored = false
	
	Tween = TS:Create(Blast1, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {["Size"] = Vector3.new(2.477, 1.228, 903.67), ["CFrame"] = FinalCFrame1})
	TS:Create(Blast2, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {["Size"] = Vector3.new(3.731, 2.256, 903.67), ["CFrame"] = FinalCFrame2}):Play()
	Tween:Play()
	-- Clouds tweens
	
	TS:Create(Cloud1, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.25), {["Transparency"] = 1}):Play()
	TS:Create(Cloud2, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.20), {["Transparency"] = 1}):Play()
	TS:Create(Cloud3, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15), {["Transparency"] = 1}):Play()
	TS:Create(Cloud4, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.10), {["Transparency"] = 1}):Play()
	TS:Create(Cloud5, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.05), {["Transparency"] = 1}):Play()
	TS:Create(Cloud6, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {["Transparency"] = 1}):Play()
	
	wait(0.2)
	
	Tween = TS:Create(Blast1, TweenInfo.new(1), {["Transparency"] = 1})
	Tween:Play()
	TS:Create(Blast2, TweenInfo.new(1), {["Transparency"] = 1}):Play()
	TS:Create(Wrap1, TweenInfo.new(1), {["Transparency"] = 1}):Play()
	TS:Create(Wrap2, TweenInfo.new(1), {["Transparency"] = 1}):Play()
	Blast2.ParticleEmitter.Enabled = false
	
	Tween.Completed:wait()
	Cyborg.CanCancel = true
	end)
end

-- EMBODY HOVER

function Cyborg.UpdateHover(Speed, VerticalComponent)
	local PrimaryPart = Cyborg.Player.PrimaryPart
	-- Calculate NewVelocity
	Speed = VerticalComponent > 0 and Speed/2 or Speed
	
	TS:Create(PrimaryPart.BodyVelocity, TweenInfo.new(PrimaryPart.BodyVelocity.Velocity.magnitude*0.1), {["Velocity"] = Cyborg.Player.Character.Humanoid.MoveDirection*Speed+Vector3.new(0, VerticalComponent, 0)}):Play()
end

function Cyborg.StopHover()
	local PrimaryPart = Cyborg.Player.PrimaryPart
	
	-- Inform server about the skill
	if Self then Events.StopHover:FireServer(Cyborg) end
	
	PrimaryPart.Hover:Destroy()
	PrimaryPart.BodyVelocity:Destroy()
end

function Cyborg.Hover()
	local PrimaryPart = Cyborg.Player.PrimaryPart
	local Character = Cyborg.Player.Character
	-- Inform server about the skill
	if Self then Events.Hover:FireServer(Cyborg) end
	-- Attaches particles
	local Particles = Hover:Clone()
	Particles.CFrame = Cyborg.Player.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
	Particles.Parent = PrimaryPart
	
	Misc.WeldInPlace(Particles, PrimaryPart)
	
	-- Attach velocity
	local BV = Instance.new("BodyVelocity", PrimaryPart)
	BV.MaxForce = Vector3.new(4000000000, 4000000000, 4000000000)
	BV.Velocity = PrimaryPart.Velocity
end

-- END HOVER

-- EMBODY PELLETS

function Cyborg.PelletStorm(TargetPosition)
	local PrimaryPart = Cyborg.Player.PrimaryPart
	local Character = Cyborg.Player.Character
	
	local Initial = CFrame.new(PrimaryPart.Position, TargetPosition)
	local RandomOffset = Vector3.new(Misc.NumberGen:NextInteger(-3, 3), 0, Misc.NumberGen:NextInteger(-3, 3))
	local StartCFrame = Initial + Initial.lookVector*3 + RandomOffset
	
	-- Inform server about the skill
	if Self then Events.PelletStorm:FireServer(TargetPosition, Cyborg) end
	
	local Pellet = Cyborg.PelletObject:Clone()
	Pellet.CFrame = StartCFrame
	Pellet.Parent = ProjectilesFolder
	Pellet.BodyVelocity.Velocity = StartCFrame.lookVector*200
	Pellet.Anchored = false
	
	Cyborg.PointToPos(TargetPosition)
	
	-- Detect collision
	Misc.DetectCollision(StartCFrame.p, TargetPosition, Character, Pellet, function()
		local Tween = TS:Create(Pellet, TweenInfo.new(0.5), {["Transparency"] = 1})
		Tween.Completed:wait()
		Pellet:Destroy()
	end)
	
	Debris:AddItem(Pellet, 10)
end

-- END PELLETS

function Cyborg.PointToPos(Position)
	-- Inform server about the skill
	if Self then Events.PointToPos:FireServer(Position, Cyborg) end
	
	Cyborg.Player.Character:SetPrimaryPartCFrame(CFrame.new(Cyborg.Player.PrimaryPart.Position, Position))
end

function Cyborg.New(Plr)
	Cyborg.Player = Plr
	Cyborg.InvokeParameters = {Plr}
	-- Objects
	Cyborg.BlastObject = Blast:Clone()
	Cyborg.AirStepObject = AirStep:Clone()
	Cyborg.PelletObject = Pellet:Clone()
	Cyborg.HoverObject = Hover:Clone()
	
	Cyborg.CanCancel = true
	
	Cyborg.Explosion = require(Explosion)
	Cyborg.Explosion.New(nil, ExplosionObject, {Vector3.new(100, 100, 100), Vector3.new(105.2, 104.2, 104.2)}, 1.5)
	-- Additional Skills
	Cyborg.Jump = Jump
	Cyborg.Jump.New(Plr, Resources.AirStep)
	
	Cyborg.BasicAttack = BasicAttack
	Cyborg.BasicAttack.New(Plr, 3064549303, 3064548076)
	
	Self = InvokePlayer == Cyborg.Player.Object
end

return Cyborg
