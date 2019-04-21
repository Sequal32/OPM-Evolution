local AI = {}

CS = game:GetService("CollectionService")
SD = game:GetService("ServerStorage")
SS = game:GetService("ServerScriptService")
RP = game:GetService("ReplicatedStorage")
Players = game:GetService("Players")

NumGen = Random.new()

--Paths
Updates = SS.Updates
AIObjects = SD.AIModels
Resources = RP.Resources.General

Cooldown = 0

SpawnPositions = workspace.AISpawnLocations:GetChildren()

AIModels = {
	{"StrongThug", AIObjects.StrongThug},
	{"WeakThug", AIObjects.WeakThug},
	{"Villain", AIObjects.Villain}
}

AIStats = require(SS.MobTypes)
LoadAnimation = require(RP.General.LoadAnimation)

function AI.PickSpawnLocation()
	return SpawnPositions[NumGen:NextInteger(1, #SpawnPositions)].Position
end

function AI.Spawn(AIModel, Position)
	local AIName, Model = AIModel[1], AIModel[2]:Clone()
	local Position = Position or AI.PickSpawnLocation()
    
    AI.Spawnpoint = Position
    AI.Died = false
	AI.Stats = AIStats[AIName]
	AI.Model = Model
	
	CS:AddTag(Model, "AttackableMob")
	
	-- Initialize values
	local Event = Instance.new("BindableFunction", Model)
	Event.Name = "Die"
	local HealthValue = Instance.new("IntValue", Model)
	HealthValue.Name = "Health"
	HealthValue.Value = AI.Stats.Level*100
	local MaxHealthValue = Instance.new("IntValue", Model)
	MaxHealthValue.Name = "MaxHealth"
	MaxHealthValue.Value = AI.Stats.Level*100
	
	-- Put billboard gui
	local Gui = Resources.Info:Clone()
	Gui.CharacterName.Text = AIName
	Gui.Health.Text.Text = MaxHealthValue.Value.."/"..MaxHealthValue.Value
	Gui.Parent = Model.Head
	
	-- Stats effects
	Model.Humanoid.WalkSpeed = 0.064257 * AI.Stats.Level + 15.935743
	
	Updates.RegisterRagdoll:Fire(Model)
	Model:SetPrimaryPartCFrame(CFrame.new(Position))
	Model.Parent = workspace
	
	AI.Finished = false
	AI.BasicAttack = require(RP.SharedSkills.BasicAttack:Clone())
	AI.BasicAttack.New({["Character"] = Model}, 3064549303, 3064548076, AI.Stats.Range or 2)
	
	AI.WalkAnim = LoadAnimation(Model.Humanoid, 507777826)
	AI.IdleAnim = LoadAnimation(Model.Humanoid, 507766388)
	
	function AI.Model.Die.OnInvoke()
		AI.Model.Humanoid.Health = 0
		AI.Died = true
		CS:RemoveTag(Model, "AttackableMob")
        
        if AI.Stats.OnDied then AI.Stats.OnDied(AI.Model) end

        spawn(function()
			wait(AI.Stats.DeathTime or 0)
			AI.Model:Destroy()
		end)
		spawn(function()
			wait(AI.Stats.RespawnTime or 0)
			AI.Finished = true
		end)

		return MaxHealthValue.Value/20
    end
    
    -- AI.Model.Health:GetPropertyOnChangedSignal("Value"):Connect(function()
    --     AI.Aggro = true
    -- end)
end

function AI.SpawnRandomModel(Position)
	AI.Spawn(AIModels[NumGen:NextInteger(1, #AIModels)], Position)
end

function AI.FindDistanceToPlayer(Player)
	return (Player.Character.PrimaryPart.Position-AI.Model.PrimaryPart.Position).magnitude
end

function AI.FindNearestPlayer()
	local ClosestDistance, ClosestPlayer = math.huge, nil
	for _,player in pairs(Players:GetChildren()) do
		if player and player.Character and player.Character.PrimaryPart then
			local Distance = AI.FindDistanceToPlayer(player)
			
			if Distance < ClosestDistance and player.Character.Humanoid.Health ~= 0 then
				ClosestDistance = Distance
				ClosestPlayer = player
			end
		end
	end
	
	return ClosestPlayer, ClosestDistance
end

function AI.DamagePlayer(Player)
--	AI.WalkAnim:Stop()
	AI.BasicAttack.Animate()
	Updates.HealthChange:Invoke(Player, -AI.Stats.Level*2.5)
end

function AI.Loop()
	local Player, Distance = AI.FindNearestPlayer()
	
	if Distance < (AI.Stats.AttackingDistance or 4) then
        if Cooldown <= 0 then 
            AI.WalkAnim:Stop() 
            AI.DamagePlayer(Player) 
            Cooldown = 1 
        end
	elseif Distance < 90 then 
        if not AI.WalkAnim.IsPlaying then 
            AI.WalkAnim:Play() 
            AI.IdleAnim:Stop()
        end

        AI.Model.Humanoid:MoveTo(Player.Character.PrimaryPart.Position)
    elseif (AI.Model.PrimaryPart.Position-AI.Spawnpoint).magnitude > 2000 then
        AI.Model:SetPrimaryPartCFrame(CFrame.new(AI.Spawnpoint))
    else
        AI.Model.Humanoid:MoveTo(AI.Spawnpoint) -- Stop the AI's movement
        if not AI.IdleAnim.IsPlaying then
			AI.WalkAnim:Stop()
			AI.IdleAnim:Play()
		end
	end
	
	Cooldown = Cooldown-0.1
end

return AI