-- Server script that handles UI functionality

-- Variables
local rep_storage = game:GetService("ReplicatedStorage")
local ui_data = rep_storage:WaitForChild("UI_Data")
local ui_remotes = ui_data:WaitForChild("UI_Remotes")

-- Intro
game.Players.PlayerAdded:Connect(function(player)
	ui_remotes.PlayerAdded:FireClient(player)
end)

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		char.Humanoid.Died:Connect(function()
			print("Z")
			wait(6)
			ui_remotes.CharacterAdded:FireClient(player)
		end)
	end)
end)

function returnPlayerCurrentLevel()
	-- need data store
end

ui_remotes.GetPlayerCurrentLevel.OnServerInvoke  = returnPlayerCurrentLevel

-- Character Customization
function AddAccessory(player,character,accessory)
	wait(1)
	for i,v in pairs(game.ReplicatedStorage:GetChildren()) do
		print(v.Name)
	end
	local folder = game.ReplicatedStorage:FindFirstChild(player.Name.."_CC")
	local accessory2 = folder:FindFirstChild(accessory)
	local char2 = folder:FindFirstChild(character)
	if accessory2 and char2 then
		char2.Parent = workspace
		accessory2.Parent = character
		char2.Humanoid:AddAccessory(accessory)
		return character
	end
end

ui_remotes.AddAccessory.OnServerInvoke = AddAccessory
