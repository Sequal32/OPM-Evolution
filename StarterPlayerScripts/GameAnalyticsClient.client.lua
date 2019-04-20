--Variables
local GameAnalyticsFiltering = game:GetService("ReplicatedStorage"):WaitForChild("GameAnalyticsFiltering")
--local GameAnalyticsSendMessage = game:GetService("ReplicatedStorage"):WaitForChild("GameAnalyticsSendMessage")

--Services
local GS = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local RP = game:GetService("ReplicatedStorage")

--Functions
function getPlatform()

    if (GS:IsTenFootInterface()) then
        return "Console"
    elseif (UIS.TouchEnabled and not UIS.MouseEnabled) then
        return "Mobile"
    else
        return "Desktop"
    end
end

--Filtering
GameAnalyticsFiltering.OnClientInvoke = getPlatform

-- debug stuff
--GameAnalyticsSendMessage.OnClientEvent:Connect(function(chatProperties)
--    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", chatProperties)
--end)

if not game:GetService("RunService"):IsStudio() then
	game:GetService("LogService").MessageOut:Connect(function(message, messageType)
		if messageType ~= Enum.MessageType.MessageError then return end
		RP.Events.General.LogError:FireServer(message, messageType)
	end)
end