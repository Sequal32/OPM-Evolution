Inventory = {}
Inventory.__index = Inventory

SS = game:GetService("ServerScriptService")
Items = require(SS.Stats.Items)

function Inventory.New()
    local NewInventory = {}

    setmetatable(NewInventory, Inventory)

    return NewInventory
end

function Inventory:AddItem(Item)
    if self[Item.Name] then
        self[Item.Name].Quantity = self[Item.Name].Quantity+Item.Quantity
    else
        self[Item.Name] = Item
    end
end

function Inventory:RemoveItem(Item, Quantity)
    if self[Item.Name].Quantity-Quantity <= 0 then
        self[Item.Name] = nil
    else
        self[Item.Name].Quantity = self[Item.Name].Quantity-Item.Quantity
    end
end

return Inventory