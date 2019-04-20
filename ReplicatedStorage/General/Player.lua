local Player = {}

General = script.Parent

function Player.New(Plr)
	Player.Object = game.Players.LocalPlayer
	Player.Character = Plr.Character
	Player.PrimaryPart = Plr.Character.PrimaryPart
	Player.Stats = require(General.StatsPlay)
end

return Player
