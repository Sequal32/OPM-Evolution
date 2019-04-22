CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")
DS = game:GetService("DataStoreService")
MS = game:GetService("MarketplaceService")

Analytics = require(SD.GameAnalytics)

NumGen = Random.new()

Updates = SS.Updates
Events = RP.Events
General = Events.General

PlayerCurrentStats = {}
LastSaves = {}
PlayerCharacters = {}
HealthRegenCooldowns = {}

function General.StatsServer.OnServerInvoke(Player, RequestType, Data)
	local PlayerStats = PlayerCurrentStats[Player]
	if RequestType == "FETCH" then
		local NewData, FirstTime
		
		if not PlayerStats then
			NewData, FirstTime = Updates.GetData:Invoke("Stats", "PlayerKeyAlphaZulu_"..Player.UserId)
            PlayerStats = NewData
			
			if FirstTime then -- Analytics
				Analytics:addProgressionEvent(Player.UserId, {
					progressionStatus = Analytics.EGAProgressionStatus.Start,
					progression01 = "level0-10"
				})
			end
            
            PlayerStats.EXP = PlayerStats.EXP or 0
			PlayerStats.EXPNeeded = math.ceil(1.12^NewData.Level * 125)
			PlayerStats.MaxHealth = NewData.DefenseLevel*100 + (NewData.Level-1) * 100
			PlayerStats.Health = PlayerStats.MaxHealth
			
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
	elseif RequestType == "UPDATE" then
		-- Check if a valid amount is being added
		local TotalSpending = 0
		for _,Value in pairs(Data) do
			TotalSpending = TotalSpending+Value
		end
		if TotalSpending > PlayerStats.AttributePoints then return end
		-- Apply attributes
		for Attribute,Value in pairs(Data) do
			PlayerCurrentStats[Player][Attribute] = PlayerCurrentStats[Player][Attribute]+Value 
        end
        PlayerStats.MaxHealth = PlayerStats.DefenseLevel*100 + (PlayerStats.Level-1) * 100
		PlayerStats.AttributePoints = PlayerStats.AttributePoints-TotalSpending
		General.StatsClient:FireClient(Player, "ALL", PlayerStats)
		PlayerCurrentStats[Player] = PlayerStats
		return true
	end
end

function General.CharacterServer.OnServerInvoke(Player, RequestType, Data)
	if RequestType == "FETCH" then
		return Updates.GetData:Invoke("Character", "PlayerKeyAlphaZulu_"..Player.UserId)
	elseif RequestType == "UPDATE" then
		return Updates.SaveData:Invoke("Character", "PlayerKeyAlphaZulu_"..Player.UserId, Data)
	end
end

function Updates.HealthChange.OnInvoke(Player, Change)  -- RETURNS WHETHER THE PLAYER DIED
	PlayerCurrentStats[Player].Health = math.clamp(PlayerCurrentStats[Player].Health+Change, 0, math.huge)
	General.StatsClient:FireClient(Player, "SINGLE", {"Health", PlayerCurrentStats[Player].Health})
	
	HealthRegenCooldowns[Player] = 3
	-- VISUAL
	local UI = Player.Character.Head.Info
	UI.Health.Fill.Size = UDim2.new(PlayerCurrentStats[Player].Health/PlayerCurrentStats[Player].MaxHealth, 0, 1, 0)
	UI.Health.Text.Text = PlayerCurrentStats[Player].Health.."/"..PlayerCurrentStats[Player].MaxHealth
	-- DETECT DEAD
	if PlayerCurrentStats[Player].Health <= 0 and Player.Character.Humanoid.Health ~= 0 then
		Player.Character.Humanoid.Health = 0
		CS:RemoveTag(Player.Character, "AttackablePlayer")
		return PlayerCurrentStats[Player].Level
	end
	
	return false
end

function Updates.GetPlayerData.OnInvoke(Player)
    return PlayerCurrentStats[Player]
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
end

General.LoadCharacter.OnServerEvent:Connect(LoadCharacter)

Updates.Stats.IncrementEXP.Event:Connect(function(Player, EXP)
	local PlayerStats = PlayerCurrentStats[Player]
	
	PlayerStats.EXP = PlayerStats.EXP + (MS:UserOwnsGamePassAsync(Player.UserId, 6170581) and EXP*2 or EXP) -- IF USER OWNS 2x EXP gamepass
	
	if PlayerStats.EXP >= PlayerStats.EXPNeeded then
		-- Grant Level
		PlayerStats.EXP = PlayerStats.EXP-PlayerStats.EXPNeeded
		PlayerStats.Level = PlayerStats.Level+1
		PlayerStats.EXPNeeded = math.ceil(1.12^PlayerStats.Level * 125)
		PlayerStats.MaxHealth = PlayerStats.DefenseLevel*100 + (PlayerStats.Level-1) * 100
		
		-- Analytics
		if PlayerStats.Level % 10 == 0 then
			Analytics:addProgressionEvent(Player.UserId, {
				progressionStatus = Analytics.EGAProgressionStatus.Complete,
				progression01 = "level"..tostring(PlayerStats.Level-10).."-"..tostring(PlayerStats.Level)
			})
			Analytics:addProgressionEvent(Player.UserId, {
				progressionStatus = Analytics.EGAProgressionStatus.Start,
				progression01 = "level"..tostring(PlayerStats.Level).."-"..tostring(PlayerStats.Level+10)
			})
		end
		
		-- Attribute level giving
		if PlayerStats.Level % 100 == 0 then
			PlayerStats.AttributePoints = PlayerStats.AttributePoints+25
		else
			PlayerStats.AttributePoints = PlayerStats.AttributePoints+2
		end
		-- Level up each skill one level
		PlayerStats.StaminaLevel = PlayerStats.StaminaLevel+1
		PlayerStats.DefenseLevel = PlayerStats.DefenseLevel+1
		PlayerStats.StrengthLevel = PlayerStats.StrengthLevel+1
		PlayerStats.AgilityLevel = PlayerStats.AgilityLevel+1
		
		PlayerCurrentStats[Player] = PlayerStats
		
		General.StatsClient:FireClient(Player, "ALL", PlayerStats)
	else
		General.StatsClient:FireClient(Player, "SINGLE", {"EXP", PlayerStats.EXP})
	end
end)

Updates.Stats.IncrementYen.Event:Connect(function(Player, Yen)
	PlayerCurrentStats[Player].Yen = PlayerCurrentStats[Player].Yen + (MS:UserOwnsGamePassAsync(Player.UserId, 6193640) and Yen*2 or Yen) -- IF USER OWNS 2x EXP gamepass
	General.StatsClient:FireClient(Player, "SINGLE", {"Yen", PlayerCurrentStats[Player].Yen})
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
    PlayerCurrentStats[Player].Strength = Strength or PlayerCurrentStats[Player].Strength
    PlayerCurrentStats[Player].Stamina = Stamina or PlayerCurrentStats[Player].Stamina
    PlayerCurrentStats[Player].Defense = Defense or PlayerCurrentStats[Player].Defense
    PlayerCurrentStats[Player].Agility = Agility or PlayerCurrentStats[Player].Agility
    PlayerCurrentStats[Player].Level = Level or  PlayerCurrentStats[Player].Level
    PlayerCurrentStats[Player].EXP = EXP or PlayerCurrentStats[Player].EXP
    PlayerCurrentStats[Player].Yen = Yen or PlayerCurrentStats[Player].Yen
    PlayerCurrentStats[Player].AttributePoints = AttributePoints or PlayerCurrentStats[Player].AttributePoints

    General.StatsClient:FireClient(Player, "ALL", PlayerCurrentStats[Player])

    SaveCurrentStats(Player)
end)

-- Save data upon player leaving and removes unneeded data
function SaveCurrentStats(Player)
    local PlayerStats = PlayerCurrentStats[Player]
    if PlayerStats then
        Updates.SaveData:Invoke("Stats", "PlayerKeyAlphaZulu_"..Player.UserId, {
            ["Yen"] = PlayerStats.Yen,
            ["EXP"] = PlayerStats.EXP,
            ["StrengthLevel"] = PlayerStats.StrengthLevel,
            ["StaminaLevel"] = PlayerStats.StaminaLevel,
            ["DefenseLevel"] = PlayerStats.DefenseLevel,
            ["AgilityLevel"] = PlayerStats.AgilityLevel,
            ["Level"] = PlayerStats.Level,
            ["AttributePoints"] = PlayerStats.AttributePoints
        })
    end
end

game.Players.PlayerRemoving:Connect(function(Player)
	if PlayerCurrentStats[Player] then
		SaveCurrentStats(Player)
		
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
					PlayerStats.Health = math.clamp(PlayerStats.Health+PlayerStats.MaxHealth * 0.01, 0, PlayerStats.MaxHealth)
					General.StatsClient:FireClient(Player, "SINGLE", {"Health", PlayerStats.Health})
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
					
					PlayerStats.Health = PlayerStats.MaxHealth
					General.StatsClient:FireClient(Player, "SINGLE", {"Health", PlayerStats.Health, true})
					
					repeat wait(2) LoadCharacter(Player, PlayerCharacters[Player]) until Player.Character
				end)
			end
			
			-- Save data automatically every minute
			if LastSaves[Player] and LastSaves[Player] >= 60 then
				LastSaves[Player] = 0
				SaveCurrentStats(Player)
			else
				LastSaves[Player] = LastSaves[Player]+0.5
			end
			
			PlayerCurrentStats[Player] = PlayerStats
			
		end
	end
end