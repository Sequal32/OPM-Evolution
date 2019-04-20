HS = game:GetService("HttpService")
LS = game:GetService("LogService")
RP = game:GetService("ReplicatedStorage")
SD = game:GetService("ServerStorage")

Settings = require(SD.GameAnalytics.Settings)

function LogMessage(message, messageType, isServer)
	if messageType ~= Enum.MessageType.MessageError then return end
	HS:PostAsync("https://triggers.losant.com/webhooks/7dviUjnMy9HOG1cTW1sJ_PTu1QBCaXKETDVAIk6DaA1$", HS:JSONEncode({
		Message = message,
		IsServer = isServer,
		Server_Version = Settings.Build
	}))
end

if not game:GetService("RunService"):IsStudio() then
	RP.Events.General.LogError.OnServerEvent:Connect(function(Player, message, messageType)
		LogMessage(message, messageType, false)
	end)
	
	LS.MessageOut:Connect(function(message, messageType)
		LogMessage(message, messageType, true)
	end)
end