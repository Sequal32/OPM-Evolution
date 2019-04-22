local _S = {}

CS = game:GetService("CollectionService")
Debris = game:GetService("Debris")
Camera = workspace.CurrentCamera

_S.NumberGen = Random.new()

function _S.WeldWithC1(a, b, c1)
   --Make a new Weld and Parent it to a.
	local weld = Instance.new("Weld", a)
	--Get the CFrame of b relative to a.
	weld.C1 = c1
	--Set the Part0 and Part1 properties respectively
	weld.Part0 = a
	weld.Part1 = b
	--Return the reference to the weld so that you can change it later.
	return weld
end

function _S.WeldInPlace(a, b)
	--Make a new Weld and Parent it to a.
	local weld = Instance.new("Weld", a)
	--Get the CFrame of b relative to a.
	weld.C0 = a.CFrame:inverse() * b.CFrame
	--Set the Part0 and Part1 properties respectively
	weld.Part0 = a
	weld.Part1 = b
	--Return the reference to the weld so that you can change it later.
	return weld
end

function _S.IsSelf(Character, Part)
	return Part:IsDescendantOf(Character) or CS:HasTag(Part, "ProjectileIgnore")
end

function _S.GetCharacterParts(Character)
	local Array = {}
	if Character then
		for _,Part in pairs(Character:GetChildren()) do
			if Part:IsA("BasePart") then
				table.insert(Array, Part)
			end
		end
		
		for _,Part in pairs(Character:GetDescendants()) do
			if Part:IsA("BasePart") then
				table.insert(Array, Part)
			end
		end
	end
	return Array
end

function _S.FindCollisionParts(Origin, TargetPosition, Character)
	local Ignore = {}
	local Collisions = {}
	
	if Character then
		Ignore = _S.GetCharacterParts(Character)
	end
	
	for _,entry in pairs(CS:GetTagged("ProjectileIgnore")) do
		table.insert(Ignore, entry)
	end
	
	local Part, Position
	local ray = Ray.new(Origin, CFrame.new(Origin, TargetPosition).lookVector*3000)
	
	repeat
		Part, Position = workspace:FindPartOnRayWithIgnoreList(ray, Ignore)
		if Part then
			table.insert(Collisions, {Part, Position})
			table.insert(Ignore, Part)
		end
	until not Part
	
	return Collisions
end

function _S.FindCollisionPart(Origin, TargetPosition, Character, Range)
	local Ignore = {}
	
	if Character then
		Ignore = _S.GetCharacterParts(Character)
	end

	for _,entry in pairs(CS:GetTagged("ProjectileIgnore")) do
		table.insert(Ignore, entry)
	end
	
	Range = Range or 3000
	
	local ray = Ray.new(Origin, CFrame.new(Origin, TargetPosition).lookVector*Range)

	return workspace:FindPartOnRayWithIgnoreList(ray, Ignore)
end

function _S.FindCharactersInVicinity(Position, Size, OnlyPlayers)
    Characters = {}

    if not OnlyPlayers then
        for _,Character in pairs(CS:GetTagged("AttackableMob")) do
            if (Character.PrimaryPart.Position-Position).magnitude <= Size then
                table.insert(Characters, {Character, "Mob"})
            end
        end
    end

    for _,Character in pairs(CS:GetTagged("AttackablePlayer")) do
        if (Character.PrimaryPart.Position-Position).magnitude <= Size then
            table.insert(Characters, {Character, "Player"})
        end
    end
    
    return Characters
end

function _S.DetectCollision(Origin, TargetPosition, Character, Part, FunctionWhenHit)
	local Connection
	
	local CollidingPart, Position = _S.FindCollisionPart(Origin, TargetPosition, Character)
	
	Connection = Part.Touched:connect(function(HitPart)
		if HitPart == CollidingPart then FunctionWhenHit(HitPart) Connection:Disconnect() end
	end)
end

function _S.GetTargetMousePos()
	local Player = game.Players.LocalPlayer
	local Mouse = Player:GetMouse()
	local Target = Mouse.Hit

	local CF = CFrame.new(Player.Character.PrimaryPart.Position, Mouse.Origin.p+Mouse.Origin.lookVector*1000)
	return CF.lookVector*1000 + CF.Position
end

function _S.GetCameraLookVector()
	return Camera.CFrame.LookVector
end

function _S.IsPlayer(Hit)
	for _,Character in pairs(CS:GetTagged("AttackablePlayer")) do
		if Hit:IsDescendantOf(Character) then
			return game.Players:GetPlayerFromCharacter(Character)
		end
	end
	return false
end

function _S.IsNPC(Hit)
	for _,Character in pairs(CS:GetTagged("AttackableMob")) do
		if Hit:IsDescendantOf(Character) then
			return Character
		end
	end
	
	return false
end

return _S
