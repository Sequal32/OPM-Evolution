CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")

-- Paths
Events = RP.Events
Updates = SS.Updates

local Events = {
	["Ninja"] = Events.Ninja,
	["Cyborg"] = Events.Cyborg,
	["SuperHuman"] = Events.SuperHuman
}

function FireEveryoneExceptPlayer(Player, Event, ...)
	local args = {...}
	for _,player in pairs(game.Players:GetChildren()) do
		if player ~= Player then
			Event:FireClient(player, args[1], args[2], args[3], args[4], args[5], args[6], args[7])
		end
	end
end

for Name,EventPath in pairs(Events) do
	for _,Event in pairs(EventPath:GetChildren()) do
		Event.OnServerEvent:connect(function(Player, ...)
			HandleSpecialEvents(Event)
			FireEveryoneExceptPlayer(Player, Event, ...)
		end)
	end
end

-- SPECIAL CONDITIONS --
function HandleSpecialEvents(Event)
	if Event:FindFirstChild("Projectile") then
		local Folder = Event.Projectile
		
	end
end

-- EXP ATTACKS --
Attacks = {
	Punch = 1,
	BasicAttack = 1
}
RP.Events.General.EXPAttack.OnServerEvent:Connect(function(Player, Attack)
	SS.Updates.Stats.IncrementEXP:Fire(Player, Attacks[Attack])
end)
