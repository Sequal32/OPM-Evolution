CS = game:GetService("CollectionService")
SS = game:GetService("ServerScriptService")

AI = SS.AI

ActiveMobs = {}

AIObjects = game:GetService("ServerStorage").AIModels
AIUniqueLocations = workspace.AIUniqueSpawnLocations
AIUnique = {
    {"Kelp", AIObjects["KelpMonster"], AIUniqueLocations.Kelp1},
    {"Kelp", AIObjects["KelpMonster"], AIUniqueLocations.Kelp2},
    {"Kelp", AIObjects["KelpMonster"], AIUniqueLocations.Kelp3},
    {"[Boss] Vaccine Man", AIObjects.VaccineMan, AIUniqueLocations.VaccineMan}
}

-- Handling punching bags
for _,bag in pairs(workspace.PunchingBags:GetChildren()) do
	CS:AddTag(bag, "AttackableMob")
	CS:AddTag(bag, "TrainingDummy")
end

while wait() do
	-- pcall(function()
		for _,Location in pairs(workspace.AISpawnLocations:GetChildren()) do
			if not Location.Occupied.Value then
				
				local Mob = require(AI:Clone())
				Mob.SpawnRandomModel(Location.Position)
				Location.Occupied.Value = true
				
				table.insert(ActiveMobs, {Mob, Location})
			end
		end
		
		for _,Data in pairs(AIUnique) do
			local Name, Model, Loc = Data[1], Data[2], Data[3]
			
			if not Loc.Occupied.Value then
				local Mob = require(AI:Clone())
				Mob.Spawn(Data, Loc.Position)
				Loc.Occupied.Value = true
				
				table.insert(ActiveMobs, {Mob, Loc})
			end
		end
		
		for Index,Active in pairs(ActiveMobs) do
			local Mob, Location = Active[1], Active[2]
			
			if Mob.Finished then
				table.remove(ActiveMobs, Index)
				Location.Occupied.Value = false
			else
				Mob.Loop()
			end
		end
	-- end)
end