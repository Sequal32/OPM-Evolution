CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")

Events = RP.Events.General

OngoingQuests = require(SS.Stats.OngoingPlayerQuests)
Inventory = require(RP.Modules.InventorySystem.Inventory)
ItemFactory = require(RP.Modules.InventorySystem.Item)
Inventories = {}

function UpdateQuest(Player, ItemName)
    local QuestItem

    for Index,Quest in pairs(OngoingQuests[Player]) do
        if ItemName == Quest.ObjectiveName then
            Quest:IncrementCompletion()
            QuestItem = true
        end
    end

    return QuestItem
end

function CheckVaidPartAsItem(Part)
    return Part and CS:HasTag(Part, "Item")
end

function Events.InventoryChange.OnServerInvoke(Player, Type, Item)
    if Type == "Add" then
        if not CheckVaidPartAsItem(Item) then return end

        local IsQuestItem = UpdateQuest(Player, Item.Name)
        local NewItem = ItemFactory.New(Item.Name, not IsQuestItem, IsQuestItem, Item.Quantity.Value)

        Inventories[Player]:AddItem(NewItem)

        return NewItem
    elseif Type == "Remove" then
        Inventories[Player]:RemoveItem(Item)
        return true
    end
end

game.Players.PlayerAdded:Connect(function(Player)
    Inventories[Player] = Inventory.New()
end)

game.Players.PlayerRemoving:Connect(function(Player)
    Inventories[Player] = nil
end)