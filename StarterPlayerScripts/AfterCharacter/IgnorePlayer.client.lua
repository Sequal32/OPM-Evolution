CS = game:GetService("CollectionService")

Character = game.Players.LocalPlayer.Character

for _,Part in pairs(Character:GetChildren()) do
	if Part:IsA("BasePart") then
		CS:AddTag(Part, "ProjectileIgnore")
	end
end

for _,Part in pairs(Character:GetDescendants()) do
	if Part:IsA("BasePart") then
		CS:AddTag(Part, "ProjectileIgnore")
	end
end