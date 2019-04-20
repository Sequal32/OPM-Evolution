TS = game:GetService("TeleportService")

local ReservedServer = TS:ReserveServer(3030517857)

game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message == "TPPrivate" and (player.UserId == 24037121 or player.UserId == 90517190) then
			TS:TeleportToPrivateServer(3030517857, ReservedServer, {player})
		end
	end)
end)
