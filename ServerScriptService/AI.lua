local AI = {}

CS = game:GetService("CollectionService")
SD = game:GetService("ServerStorage")
SS = game:GetService("ServerScriptService")
RP = game:GetService("ReplicatedStorage")
Players = game:GetService("Players")

NumGen = Random.new()

--Paths
Updates = SS.Updates
Modules = SS.Modules
AIObjects = SD.AIModels
Resources = RP.Resources.General

Cooldown = 0

SpawnPositions = workspace.AISpawnLocations:GetChildren()

AIModels = {
	{"StrongThug", AIObjects.StrongThug},
	{"WeakThug", AIObjects.WeakThug},
	{"Villain", AIObjects.Villain}
}

-- Requires
AIStats = require(SS.MobTypes)
FindNearestPlayer = require(Modules.FindNearestPlayer)
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
	HealthValue.Value = AI.Stats.DefenseLevel*100
	local MaxHealthValue = Instance.new("IntValue", Model)
	MaxHealthValue.Name = "MaxHealth"
	MaxHealthValue.Value = AI.Stats.DefenseLevel*100
	
	-- Put billboard gui
	local Gui = Resources.Info:Clone()
	Gui.CharacterName.Text = AIName
	Gui.Health.Text.Text = MaxHealthValue.Value.."/"..MaxHealthValue.Value
	Gui.Parent = Model.Head
	
	-- Stats effects
	Model.Humanoid.WalkSpeed = 0.064257 * AI.Stats.AgilityLevel + 15.935743
	
	Updates.RegisterRagdoll:Fire(Model)
	Model:SetPrimaryPartCFrame(CFrame.new(Position))
	Model.Parent = workspace
	
    AI.Finished = false
	AI.BasicAttack = require(RP.SharedSkills.BasicAttack:Clone())
	AI.BasicAttack.New({["Character"] = Model}, 3064549303, 3064548076, AI.Stats.Range or 2)
	
	AI.WalkAnim = LoadAnimation(Model.Humanoid, 507777826)
    AI.IdleAnim = LoadAnimation(Model.Humanoid, 507766388)
    
    -- Put inital cooldown stuff

    AI.Cooldowns = {} -- For skills
    if AI.Stats.Skills then
        for Index,Skill in pairs(AI.Stats.Skills) do
            AI.Cooldowns[Index] = Skill.Cooldown
        end
    end
	
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
    
	HealthValue:GetPropertyChangedSignal("Value"):Connect(function()
		-- local Distance, Player = AI.FindNearestPlayer()
		-- if Distance then AI.Aggro = true end
        AI.Aggro = true
        AI.Returning = false
    end)
end


function AI.SpawnRandomModel(Position)
	AI.Spawn(AIModels[NumGen:NextInteger(1, #AIModels)], Position)
end

function AI.FindNearestPlayer()
    return FindNearestPlayer(AI.Model.PrimaryPart.Position)
end

function AI.DamagePlayer(Player)
--	AI.WalkAnim:Stop()
	AI.BasicAttack.Animate()
	Updates.HealthChange:Invoke(Player, -AI.Stats.Level*2.5)
end

function AI.Loop(DeltaTime)
    local Player, Distance = AI.FindNearestPlayer()
    local DistanceToSpawn = (AI.Model.PrimaryPart.Position-AI.Spawnpoint).magnitude

	if Player and Distance < (AI.Stats.AttackingDistance or 4) then
        AI.WalkAnim:Stop()
        AI.Returning = false 
		if Cooldown <= 0 then 
			AI.DamagePlayer(Player) 
			Cooldown = 0.7
		end
	elseif Player and (Distance < 90 or AI.Aggro) and (DistanceToSpawn < 300 and not AI.Returning) then 
		if not AI.WalkAnim.IsPlaying then
			AI.WalkAnim:Play() 
			AI.IdleAnim:Stop()
        end

		AI.Model.Humanoid:MoveTo(Player.Character.PrimaryPart.Position)
    elseif DistanceToSpawn > 2000 then
		AI.Model:SetPrimaryPartCFrame(CFrame.new(AI.Spawnpoint))
		AI.Aggro = false
	elseif DistanceToSpawn > 20 then
        if not AI.WalkAnim.IsPlaying then 
            AI.WalkAnim:Play() 
            AI.IdleAnim:Stop()
        end
        if DistanceToSpawn > 300 then
            AI.Returning = true
        end
		AI.Model.Humanoid:MoveTo(AI.Spawnpoint) -- Stop the AI's movement
		AI.Aggro = false
    else
        AI.WalkAnim:Stop() 
		AI.Model.Health.Value = math.clamp(AI.Model.Health.Value+AI.Model.MaxHealth.Value*0.02, 0, AI.Model.MaxHealth.Value)
		AI.Aggro = false
	end
    
    -- Skills
    Cooldown = Cooldown-DeltaTime

    for Index,Cooldown in pairs(AI.Cooldowns) do
        AI.Cooldowns[Index] = Cooldown-DeltaTime
    end

    if not AI.Stats.Skills or not Player then return end
    for Index,Skill in pairs(AI.Stats.Skills) do
        if AI.Cooldowns[Index] <= 0 and Distance <= AI.Stats.Skills[Index].Range then
            AI.WalkAnim:Stop() 
            AI.Cooldowns[Index] = AI.Stats.Skills[Index].Cooldown
            AI.Stats.Skills[Index].Function(AI.Model, Player)
        end
    end
end

return AI