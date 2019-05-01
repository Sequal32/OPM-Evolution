RP = game:GetService("ReplicatedStorage")
SS = game:GetService("ServerScriptService")

Events = RP.Events.General

Inventory = require(RP.Modules.InventorySystem.Inventory)
Inventories = {}

function Events.InventoryChange.OnServerInvoke(Player, Type, Item)
    if Type == "Add" then
        Inventories[Player]:AddItem(Item)
    elseif Type == "Remove" then
        Inventories[Player]:RemoveItem(Item)
    end
end

game.Players.PlayerAdded:Connect(function(Player)
    Inventories[Player] = Inventory.New()
end)

game.Players.PlayerRemoving:Connect(function(Player)
    Inventories[Player] = nil
end)