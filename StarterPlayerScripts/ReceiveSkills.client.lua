RP = game:GetService("ReplicatedStorage")
Player = game.Players.LocalPlayer
-- Paths
Characters = RP.Characters
Events = RP.Events
General = Events.General

local Characters = {
	-- ["Ninja"] = {require(Characters.Ninja:Clone()), Events.Ninja},
	-- ["Cyborg"] = {require(Characters.Cyborg:Clone()), Events.Cyborg},
	["SuperHuman"] = {require(Characters.SuperHuman:Clone()), Events.SuperHuman}
}

function Replicate(CharacterName, EventName, Args)
	local Info = Args[#Args]
	local Params = Info.InvokeParameters
	local Character = Characters[CharacterName][1]
	
	Character.New(Params[1], Params[2], Params[3], Params[4], Params[5])
	
--	for index,var in pairs(Info) do
--		Character[index] = var
--	end
	
	Character[EventName](Args[1], Args[2], Args[3], Args[4], Args[5])
end

for Name,Character in pairs(Characters) do
	for _,Event in pairs(Character[2]:GetChildren()) do
		Event.OnClientEvent:connect(function(...)
			Replicate(Name, Event.Name, {...})
		end)
	end
end