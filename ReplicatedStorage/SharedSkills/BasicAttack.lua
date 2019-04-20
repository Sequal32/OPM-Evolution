local Attack = {}

RP = game:GetService("ReplicatedStorage")
LoadAnimation = require(RP.General.LoadAnimation)
Stat = nil
Misc = require(RP.General.Misc)

function Attack.Animate()
	if Attack.Alternate then 
		Attack.Alternate = false
		Attack.LeftAnimation:Play()
	else 
		Attack.Alternate = true
		Attack.RightAnimation:Play() 
	end
end

function Attack.Use()
	local PrimaryPart = Attack.Player.PrimaryPart
	
	Attack.Animate()
	
	local Origin = PrimaryPart.CFrame + PrimaryPart.CFrame.lookVector
	
	RP.Events.General.DoDamage:FireServer("Radius", false, Origin.p, Vector3.new(10, 5, 10), nil, Stat.All.BasicAttack.Damage())
	RP.Events.General.EXPAttack:FireServer("BasicAttack")
end

function Attack.New(Plr, LeftAnimationId, RightAnimationId)
	Attack.Player = Plr
	
	Attack.LeftAnimation = LoadAnimation(Plr.Character.Humanoid, LeftAnimationId)
	Attack.RightAnimation = LoadAnimation(Plr.Character.Humanoid, RightAnimationId)
	
	Attack.Alternate = false
	
	if Plr.Object then Stat = require(RP.General.StatsPlay) end
end

return Attack