local Interface = {}

RP = game:GetService("ReplicatedStorage")

StatsPath = RP.PlayerStats
Events = RP.Events.General

function Interface.UpdateStat(Stat, Value) -- WILL USE ATTRIBUTE POINTS, ALL OTHER STATS ARE HANDLED BY, AND ONLY THE SERVER
	return Events.StatsServer:InvokeServer("UPDATE", Stat, Value)
end

function FetchStats()
	Interface.Stats = Events.StatsServer:InvokeServer("FETCH")
end

-- Initialize the Interface --
Interface.FetchStats()
	
-- Recieve Stats
Interface.Connection = Events.StatsClient.OnClientEvent:connect(function(Type, Data)
	if Type == "ALL" then
		Interface.Stats = Data
	elseif Type == "SINGLE" then -- Data[1] is the name of the stat, Data[2] is the value of the stat
		Interface.Stats[Data[1]] = Data[2]
	end
end)

return Interface
