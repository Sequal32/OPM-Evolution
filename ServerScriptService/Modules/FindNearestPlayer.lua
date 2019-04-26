local Players = game.Players

function FindNearestPlayer(Position)
	local ClosestDistance, ClosestPlayer = math.huge, nil
	for _,Player in pairs(Players:GetChildren()) do
		if Player and Player.Character and Player.Character.PrimaryPart then
			local Distance = (Player.Character.PrimaryPart.Position-Position).magnitude
			
			if Distance < ClosestDistance then
				ClosestDistance = Distance
				ClosestPlayer = Player
			end
		end
	end
	
	return ClosestPlayer, ClosestDistance
end

return FindNearestPlayer