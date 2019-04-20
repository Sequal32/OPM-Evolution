local Explosion = {}

CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")

ProjectilesFolder = workspace.Projectiles

DefaultExplosionObject = RP.Resources.General.Explosion
DefaultExplosionSize = Vector3.new(30, 30, 30)
DefaultExplosionTime = 0.2

function Explosion.Place(CF)
	local ExplosionObject = Explosion.Object:Clone()
	
	ExplosionObject.Parent = ProjectilesFolder
	
	local Tween
	
	if ExplosionObject:IsA("Model") then
		ExplosionObject:SetPrimaryPartCFrame(CF)
		for i,part in pairs(ExplosionObject:GetChildren()) do
			CS:AddTag(part, "ProjectileIgnore")
			
			Tween = TS:Create(part, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Quad), {["Size"] = Explosion.Size[i]})
			TS:Create(part, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, Explosion.Time), {["Transparency"] = 1}):Play()
			Tween:Play()
		end
	else
		ExplosionObject.CFrame = CF
		CS:AddTag(ExplosionObject, "ProjectileIgnore")
		
		Tween = TS:Create(ExplosionObject, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Quad), {["Size"] = Explosion.Size})
		TS:Create(ExplosionObject, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, Explosion.Time), {["Transparency"] = 1}):Play()
		Tween:Play()
	end
	
	Tween.Completed:Connect(function()
		if ExplosionObject:IsA("Model") then
			for _,part in pairs(ExplosionObject:GetChildren()) do
				Tween = TS:Create(part, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Linear), {["Transparency"] = 1})
				Tween:Play()
			end
		else
			Tween = TS:Create(ExplosionObject, TweenInfo.new(Explosion.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, Explosion.Time), {["Transparency"] = 1})
			Tween:Play()
		end
		
		Tween.Completed:Connect(function()
			ExplosionObject:Destroy()
		end)
	end)
end

function Explosion.New(Color, Object, Sizes, Time)
	Explosion.Object = Object or DefaultExplosionObject:Clone()
	Explosion.Size = Sizes or DefaultExplosionSize
	Explosion.Time = Time or DefaultExplosionTime
	if Color then Explosion.Object.Color = Color end
end

return Explosion
