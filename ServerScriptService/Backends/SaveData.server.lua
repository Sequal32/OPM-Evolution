local DS = game:GetService("DataStoreService")
local RP = game:GetService("ReplicatedStorage")
local SS SD = game:GetService("ServerScriptService")

Events = RP.Events.General

StatsDS = DS:GetDataStore("Stats")
CharacterDS = DS:GetDataStore("Characters")
HistoryDS = DS:GetDataStore("PurchaseHistory")

Updates = SD.Updates

StatsData = {
	["Yen"] = 0,
	["EXP"] = 0,
	["StrengthLevel"] = 1,
	["StaminaLevel"] = 1,
	["DefenseLevel"] = 1,
	["AgilityLevel"] = 1,
	["AttributePoints"] = 0,
	["Level"] = 1
}

CharacterData = {
	["Class"] = "SuperHuman",
	["Appearance"] = {
		["Shirt"] = nil,
		["Pant"] = nil,
		["Face"] = nil,
		["Hair"] = nil, -- Default value
		["Hair2"] = nil,
		["Accessories"] = {}
	}
}

-- Private Methods

function SaveData(Datastore, Key, Data)
	local success, message = pcall(function()
		Datastore:SetAsync(Key, Data)
	end)
	
	if not success then
		warn("Saving errored. Code "..message)
		return false
	end
	
	return true 
end

function GetData(Datastore, Key)
	local Data
	local success, message = pcall(function()
		Data = Datastore:GetAsync(Key)
	end)

	if not success then
		warn("Saving errored. Code "..message)
		return false
	end
	
	return Data
end

function UpdateData(Datastore, Key, Function)
	local Data
	local success, message = pcall(function()
		Data = Datastore:UpdateAsync(Key, Function)
	end)
	
	if not success then
		warn("Updating errored. Code "..message)
		return false
	end
	
	return true
end

function IncrementData(Datastore, Key, Delta)
	local Data
	local success, message = pcall(function()
		Data = Datastore:IncrementAsync(Key, Delta)
	end)
	
	if not success then
		warn("Incremental saving errored. Code "..message)
		return false
	end
	
	return Data
end

function CreateNewData(Type, Key)
	if Type == "Stats" then
		local NewStats = StatsData
		SaveData(StatsDS, Key, StatsData)
		return StatsData
	elseif Type == "Character" then
		SaveData(CharacterDS, Key, CharacterData)
		return CharacterData
	end
end

Updates.GetData.OnInvoke = function(DatastoreName, Key)
	local Datastore = (DatastoreName == "Stats" and StatsDS) or (DatastoreName == "Character" and CharacterDS) or (DatastoreName == "History" and HistoryDS) or nil
	if not Datastore then return nil end
	
	local Data = GetData(Datastore, Key)
--	local Data

	if Data then
		return Data
	else
		return CreateNewData(DatastoreName, Key), true -- Returns data along with whether a new data was created
	end
end

Updates.SaveData.OnInvoke = function(DatastoreName, Key, Data)
	local Datastore = (DatastoreName == "Stats" and StatsDS) or (DatastoreName == "Character" and CharacterDS) or (DatastoreName == "History" and HistoryDS) or nil
	
	if not Datastore then return nil end
	
	return SaveData(Datastore, Key, Data)
end

Updates.UpdateData.OnInvoke = function(DatastoreName, Key, Function)
	local Datastore = (DatastoreName == "Stats" and StatsDS) or (DatastoreName == "Character" and CharacterDS) or (DatastoreName == "History" and HistoryDS) or nil
	
	if not Datastore then return nil end
	
	return UpdateData(Datastore, Key, Function)
end

RP.UI_Data.UI_Remotes.ResetUserData.OnServerEvent:Connect(function(Player)
	local Data = GetData(StatsDS, "PlayerKeyAlphaZulu_"..Player.UserId)
	local Yen = 0
	local Key = "PlayerKeyAlphaZulu_"..Player.UserId
	
	if Data then
		Yen = Data.Yen
	end
	
	local NewStats = StatsData
	NewStats.Yen = Yen
	
	SaveData(StatsDS, Key, NewStats)
	CreateNewData("Character", Key)
end)

-- Public Methods

--function SaveStats(PlayerID, Health, Stamina, EXP, Level, Strength, Agility, RemainingPoints)
--	return SaveData(Datastore, "PlayerKeyAlphaZulu_"..PlayerID, {Health, Stamina, EXP, Level, Strength, Agility, RemainingPoints})
--end
