CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")
DS = game:GetService("DataStoreService")
MS = game:GetService("MarketplaceService")

Analytics = require(SD.GameAnalytics)
PlayerStatsSystem = require(SS.Modules.PlayerStats)

NumGen = Random.new()

-- Paths
Updates = SS.Updates
Events = RP.Events
General = Events.General

PlayerCurrentStats = require(SS.Stats.CurrentPlayerStats)
LastSaves = {}
PlayerCharacters = {}
HealthRegenCooldowns = {}

function General.StatsServer.OnServerInvoke(Player, RequestType, Data)
	local PlayerStats = PlayerCurrentStats[Player]
	if RequestType == "FETCH" then
		local NewData, FirstTime
		
		if not PlayerStats then
			PlayerStats = PlayerStatsSystem.NewFromDatastore(Player)
			
			HealthRegenCooldowns[Player] = 0
			LastSaves[Player] = 0
			PlayerCurrentStats[Player] = PlayerStats
		end
        
        if not PlayerStats then -- If there still isn't any data then kick the player
            Player:Kick("Error loading data, rejoin and if it still isn't loading, please send a bug report in the discord!")
        end

		return PlayerStats, FirstTime
		
	elseif RequestType == "SINGLE" then
		return PlayerCurrentStats[Player][Data]
	elseif RequestType == "UPDATE" then -- Update stats using attribute points
		-- -- Check if a valid amount is being added
		-- local TotalSpending = 0
		-- for _,Value in pairs(Data) do
		-- 	TotalSpending = TotalSpending+Value
		-- end
		-- if TotalSpending > PlayerStats.AttributePoints then return end
		-- -- Apply attributes
		-- PlayerCurrentStats[Player]:BulkChange(Data)
		-- PlayerCurrentStats[Player]:CalculateVars()
		-- General.StatsClient:FireClient(Player, "ALL", PlayerStats)
		return true
	end
end

function General.CharacterServer.OnServerInvoke(Player, RequestType, Data)
	if RequestType == "FETCH" then
		return Updates.GetData:Invoke("Character", Player)
	elseif RequestType == "UPDATE" then
		return Updates.SaveData:Invoke("Character", Player, Data)
	end
end

function Updates.HealthChange.OnInvoke(Player, Change)  -- RETURNS WHETHER THE PLAYER DIED
	local PlayerStats = PlayerCurrentStats[Player]

	PlayerStats:IncrementHealth(Change)
	
	HealthRegenCooldowns[Player] = 3
	-- VISUAL
	local UI = Player.Character.Head.Info
	UI.Health.Fill.Size = UDim2.new(PlayerStats.Health/PlayerStats.MaxHealth, 0, 1, 0)
	UI.Health.Text.Text = PlayerStats.Health.."/"..PlayerStats.MaxHealth
	-- DETECT DEAD
	if PlayerStats.Health <= 0 and Player.Character.Humanoid.Health ~= 0 then
		Player.Character.Humanoid.Health = 0
		CS:RemoveTag(Player.Character, "AttackablePlayer")
		return PlayerStats.Level
	end
	
	return false
end

-- LOADING CHARACTER
function LoadCharacter(Player, CharacterData)
	local Character = RP.BlankCharacter:Clone()
	local CharacterItems = RP.CharacterItems
	local CharacterAppearance = CharacterData.Appearance

    if CharacterAppearance then -- Load appearance if it exists
        -- Check to see the clothes exist or just don't set it at all
        if CharacterAppearance.Shirt then Character.Shirt.ShirtTemplate = CharacterAppearance.Shirt end
        if CharacterAppearance.Pant then Character.Pants.PantsTemplate = CharacterAppearance.Pant end
        if CharacterAppearance.Face then Character.Head.Face.Texture = CharacterAppearance.Face end

        -- local Hair = CharacterItems:FindFirstChild(CharacterAppearance["Hair"])
        -- local Hair2 = CharacterItems:FindFirstChild(CharacterAppearance["Hair2"])

        -- if Hair then Character.Humanoid:AddAccessory(Hair:Clone()) end
        -- if Hair2 then Character.Humanoid:AddAccessory(Hair2:Clone()) end

        for _,Accessory in pairs(CharacterAppearance.Accessories) do
            Character.Humanoid:AddAccessory(CharacterItems[Accessory]:Clone())
        end

        pcall(function()
            local Appearance = game.Players:GetCharacterAppearanceAsync(Player.UserId)

            for _,Part in pairs(Appearance:GetChildren()) do
                if Part:IsA("Accessory") then
                    Part.Parent = Character
                    Part.Handle.Anchored = false
                end
            end
        end)
    end

--	if not Success then warn("Unable to get appearance for "..Player.UserId) end
	
	--Spawn the characters
	local SpawnLocs = CS:GetTagged("Spawn")
	
	Character:SetPrimaryPartCFrame(SpawnLocs[NumGen:NextInteger(1, #SpawnLocs)].CFrame+Vector3.new(0, 5, 0))
	Character.PrimaryPart.Anchored = false
	Character.Parent = workspace
	Character.Name = Player.Name
	
	local Info = RP.Resources.General.Info:Clone()
	Info.Parent = Character.Head
	Info.CharacterName.Text = Player.Name
	
	PlayerCharacters[Player] = CharacterData
	
	Player.Character = Character

	spawn(function()
		print(Player.Character)
		while not Player.Character do wait(5) LoadCharacter(Player, PlayerCharacters[Player]) end
	end)
end

General.LoadCharacter.OnServerEvent:Connect(LoadCharacter)

Updates.Stats.IncrementEXP.Event:Connect(function(Player, EXP)
	local PlayerStats = PlayerCurrentStats[Player]
	
	PlayerStats:IncrementEXP(MS:UserOwnsGamePassAsync(Player.UserId, 6170581) and EXP*2 or EXP) -- IF USER OWNS 2x EXP gamepass
end)

Updates.Stats.IncrementYen.Event:Connect(function(Player, Yen)
	PlayerCurrentStats[Player]:IncrementYen(MS:UserOwnsGamePassAsync(Player.UserId, 6193640) and Yen*2 or Yen) -- IF USER OWNS 2x EXP gamepass
end)

-- MARKETPLACE HANDLING --
repeat wait() until _G.YenProductIds
local YenIds = _G.YenProductIds

function MS.ProcessReceipt(Receipt)
	local SavableReceiptData = Receipt
	SavableReceiptData["CurrencyType"] = nil
	
	local ProductString = tostring(Receipt.ProductId)
	local Player = game.Players:GetPlayerByUserId(Receipt.PlayerId)
	
	if Player then
		-- Grant rewards
		Analytics:ProcessReceiptCallback(Receipt) -- Analytics
		
		if YenIds[ProductString] then
			PlayerCurrentStats[Player].Yen = PlayerCurrentStats[Player].Yen+YenIds[ProductString]
			General.StatsClient:FireClient(Player, "SINGLE", {"Yen", PlayerCurrentStats[Player].Yen})
		end
		-- Log data
		Updates.UpdateData:Invoke("History", "PlayerKeyAlphaZulu_"..Receipt.PlayerId, function(OldData)
			if OldData then table.insert(OldData, Receipt) else OldData = {Receipt} end
			return OldData
		end)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- ADMIN PANEL
RP.Events.Admin.AppendData.OnServerEvent:Connect(function(Player, Level, Strength, Agility, Stamina, EXP, Yen, AttributePoints)
	local PlayerStats = PlayerCurrentStats[Player]
	PlayerStats:BulkChange({
		Strength = Strength or PlayerStats.StrengthLevel,
		Stamina = Stamina or PlayerStats.StaminaLevel,
		Defense = Defense or PlayerStats.DefenseLevel,
		Agility = Agility or PlayerStats.AgilityLevel,
		Level = Level or PlayerStats.Level,
		EXP = EXP or PlayerStats.EXP,
		Yen = Yen or PlayerStats.Yen,
	})

    PlayerStats:SaveStats()
end)

game.Players.PlayerRemoving:Connect(function(Player)
	if PlayerCurrentStats[Player] then
		PlayerCurrentStats[Player]:SaveStats()
		
		PlayerCurrentStats[Player] = nil
		LastSaves[Player] = nil
		PlayerCharacters[Player] = nil
		HealthRegenCooldowns[Player] = nil
	end
end)

-- Main loop function of the script - handles death, regen health, saving
while wait(0.5) do
	for _,Player in pairs(game.Players:GetChildren()) do
		local CharacterLoaded = Player.Character ~= nil
		local PlayerStats = PlayerCurrentStats[Player]
		
		if PlayerStats then
			-- Health regen
			if PlayerStats and CharacterLoaded then
				if HealthRegenCooldowns[Player] <= 0 and Player.Character.Humanoid.Health ~= 0 then
					PlayerStats:IncrementHealth(PlayerStats.MaxHealth * 0.01)
			
					local UI = Player.Character.Head.Info
					UI.Health.Fill.Size = UDim2.new(PlayerStats.Health/PlayerStats.MaxHealth, 0, 1, 0)
					UI.Health.Text.Text = PlayerStats.Health.."/"..PlayerStats.MaxHealth
				elseif HealthRegenCooldowns[Player] > 0 then
					HealthRegenCooldowns[Player] = HealthRegenCooldowns[Player]-0.5
				end
			end
			-- Death detection & handling
			if CharacterLoaded and Player.Character.Humanoid.Health == 0 and Player.Character:FindFirstChild("Animate") then
				Player.Character.Animate:Destroy()
				spawn(function()
					wait(5)
					
					PlayerStats:IncrementHealth(PlayerStats.MaxHealth, true)
					
					repeat wait(2) LoadCharacter(Player, PlayerCharacters[Player]) until Player.Character
				end)
			end
			
			-- Save data automatically every minute
			if LastSaves[Player] and LastSaves[Player] >= 60 then
				LastSaves[Player] = 0
				PlayerStats:SaveStats()
			else
				LastSaves[Player] = LastSaves[Player]+0.5
			end
			
		end
	end
end