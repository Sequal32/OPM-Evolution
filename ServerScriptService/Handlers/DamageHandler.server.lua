CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
PS = game:GetService("PhysicsService")
SS = game:GetService("ServerStorage")
TS = game:GetService("TweenService")
Debris = game:GetService("Debris")

PS:CreateCollisionGroup("Projectiles")
PS:CreateCollisionGroup("Players")

Misc = require(RP.General.Misc)

Updates = game:GetService("ServerScriptService").Updates
Events = RP.Events.General

NumGen = Random.new()

IsPlayer = Misc.IsPlayer
IsNPC = Misc.IsNPC

--[[**
    Uses Type to determine the targets of the attack and then does damage accordingly to the information passed

    @param [t:Type] Type The type of target aquiration
	Touch: (Part, Value, Position)
	Ray: (Multi, Origin, Target, Range, Damage)
	RayToRadius: (Origin, Target, Range, Damage, Size, Offset)
	Radius: (Position, Size, Offset, Damage)

    @returns void
**--]]
RP.Events.General.DoDamage.OnServerEvent:connect(function(Player, Type, IsSkillAttack, ...)
	local Params = {...}
	
	if Type == "Physics" then
		local Object = Params[1]
		if Object.ClassName == "Model" then
			for _,part in pairs(Object:GetChildren()) do
				part.Transparency = 1
			end
			Object.PrimaryPart.Touched:connect(function(Hit)
				DoDamagePart(Hit, Params[2])
			end)
		else
			Object.Touched:connect(function(Hit)
				DoDamagePart(Hit, Params[2])
			end)
		end
		
		Object.Parent = workspace
	elseif Type == "Touch" then
		DoDamagePart(Params[1], Params[2], Params[3]) -- Part, Value, Position
	elseif Type == "Ray" then
		local Multi = Params[1]
		local Origin, Target, Range, Damage = Params[2], Params[3], Params[4], Params[5]
		
		if Multi then
			local Collisions = Misc.FindCollisionParts(Origin, Target, Player.Character)
		else
			local Part, Position = Misc.FindCollisionPart(Origin, Target, Player.Character, Range)
			
			if not Part then return end
			
			DoDamagePart(Part, Damage, Position, Player, IsSkillAttack)
		end
	elseif Type == "RayToRadius" then
		local Origin, Target, Range, Damage, Size = Params[1], Params[2], Params[3], Params[4], Params[5]
		local Part, Position = Misc.FindCollisionPart(Origin, Target, Player.Character, Range)
		local Characters = Misc.FindCharactersInVicinity(Position, Size)
		
		DoDamageCharacters(Characters, Damage, Player)
	elseif Type == "Radius" then
		local Position, Size, Damage = Params[1], Params[2], Params[3]
		local Characters = Misc.FindCharactersInVicinity(Position, Size)
		DoDamageCharacters(Characters, Damage, Player)
	end
end)

-- CHECKS



-- DAMAGE GIVERS

function DamageIndicator(Position, Value)
	local Damage = SS.HitDamage:Clone()
	Damage.Parent = workspace.Projectiles
	Damage.Position = Position

	if Value > 0 then	
		Damage.UI.Damage.Text = Value
	else
		Damage.UI.Damage.Text = "Blocked"
		Damage.UI.Damage.TextColor3 = Color3.fromRGB(0, 0, 255)
	end

	TS:Create(Damage, TweenInfo.new(1), {["Position"] = Damage.Position + Vector3.new(1, 2, 1) * NumGen:NextNumber(-2, 2)}):Play()
	TS:Create(Damage.UI.Damage, TweenInfo.new(1), {["TextTransparency"] = 1}):Play()
	Debris:AddItem(Damage, 2)
end

function DamagePlayer(Player, Damage, AttackingPlayer)
	local EXP = Updates.HealthChange:Invoke(Player, -Damage)
	
	if EXP then
		Updates.Stats.IncrementEXP:Fire(AttackingPlayer, EXP)
		Updates.Stats.IncrementYen:Fire(AttackingPlayer, EXP)
	end
end

function DamageNPC(Character, Damage, Perp, IsSkillAttack)
	-- Detect Training Dummy
	if CS:HasTag(Character, "TrainingDummy") then
		if not IsSkillAttack then Updates.Stats.IncrementEXP:Fire(Perp, 5) end
	else
		Character.Health.Value = math.clamp(Character.Health.Value-Damage, 0, math.huge)
		if Character.Health.Value <= 0 then
            local EXPGain = Character.Die:Invoke()
            Updates.MobDied:Fire(Perp, Character)
			Updates.Stats.IncrementEXP:Fire(Perp, EXPGain)
			Updates.Stats.IncrementYen:Fire(Perp, EXPGain)
		end
		-- VISUAL
		local UI = Character.Head.Info
		UI.Health.Fill.Size = UDim2.new(Character.Health.Value/Character.MaxHealth.Value, 0, 1, 0)
		UI.Health.Text.Text = Character.Health.Value.."/"..Character.MaxHealth.Value
	end
end

function DoDamageCharacters(CharacterArray, Value, AttackingPlayer)
    for _,Array in pairs(CharacterArray) do
        local Character, Type = Array[1], Array[2]
        if Type == "Player" and Character ~= AttackingPlayer.Character then
            DamagePlayer(game.Players:GetPlayerFromCharacter(Character), Value, AttackingPlayer)
            DamageIndicator(Character.PrimaryPart.Position, Value)
        elseif Type == "Mob" then
            DamageNPC(Character, Value, AttackingPlayer)
            DamageIndicator(Character.PrimaryPart.Position, Value)
        end
    end
end


function DoDamagePart(Hit, Value, Position, AttackingPlayer, IsSkillAttack)
	if not Hit then return end
	
	local Player = IsPlayer(Hit)
	local MobCharacter = IsNPC(Hit)
	
	if Player then -- Detects player
		
        if Player ~= AttackingPlayer and VerifyHit(Position, Player) then 
			DamagePlayer(Player, Value, AttackingPlayer)
		end
		
	elseif MobCharacter then
		DamageNPC(MobCharacter, Value, AttackingPlayer, IsSkillAttack)
	else 
		return false
	end
	
	-- VISUAL
	DamageIndicator(Hit.Position, Value)
	
	return true
end

PastPositions = {}

-- DAMAGE VERIFICATION --
function VerifyHit(HitPosition, SupposedPlayer)
	local Distances = {}
	for _,Position in pairs(PastPositions[SupposedPlayer]) do
		table.insert(Distances, (Position-HitPosition).magnitude)
	end
	
	table.sort(Distances)
	
	if Distances[1] < 10 then
		return true
	else
		return false
	end
end

while wait(0.2) do
	for _,Player in pairs(game.Players:GetChildren()) do
		if not PastPositions[Player] then PastPositions[Player] = {} end
		if Player.Character then
			table.insert(PastPositions[Player], Player.Character.PrimaryPart.Position)
			if #PastPositions > 3 then table.remove(PastPositions[Player], 1) end
		end
	end
end