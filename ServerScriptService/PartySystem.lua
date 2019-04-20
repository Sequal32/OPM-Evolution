local PartySystem = {}

Parties = {}
PlayerIndexes = {}

-- Private Methods
function UpdatePlayerIndexes(LeaderId)
	for Index,PlayerId in Parties[LeaderId] do
		PlayerIndexes[PlayerId] = {LeaderId, Index}
	end
end

-- Public Methods

function PartySystem.CreateParty(PlayerId)
	Parties[PlayerId] = {}
end

function PartySystem.JoinParty(LeaderId, JoiningId)
	if PartySystem.IsInParty() then return false end -- Make sure the player is in a party
	
	local PartyIndex = #Parties[LeaderId]+1
	
	PlayerIndexes[JoiningId] = {LeaderId, PartyIndex} -- [1] Who's party you're in [2] Which index of the part you're in
	table.insert(Parties[LeaderId], PartyIndex, JoiningId)
end

function PartySystem.LeaveParty(LeavingId)
	if PartySystem.IsInParty() then return false end -- Make sure the player is in a party
	
	local LeavingIndex = PlayerIndexes[LeavingId]
	table.remove(Parties[LeavingIndex[1]], LeavingIndex[2]) -- Remove them from the party

	UpdatePlayerIndexes(LeavingIndex[1]) -- Update indexes to make sure everything is okay
end

-- Private Checks
function PartySystem.GetAllParties()
	return Parties
end

-- Public Checks

function PartySystem.IsInParty(PlayerId)
	return PlayerIndexes[PlayerId] ~= nil
end

function PartySystem.IsPartyLeader(PlayerId)
	return Parties[PlayerId] ~= nil
end

function PartySystem.GetParty(PlayerId)
	local PlayerIndex = PlayerIndexes[PlayerId]
	return Parties[PlayerIndex[1]]
end


return PartySystem
