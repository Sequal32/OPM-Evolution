Inventory = {}

function Inventory:AddItem(Item, Quantity)
    if Inventory[Item.Name] then
        Inventory[Item.Name].Quantity = Inventory[Item.Name].Quantity+Quantity
    else
        Inventory[Item.Name] = Item
    end
end

function Inventory:RemoveItem(Item, Quantity)
    if Inventory[Item.Name].Quantity-Quantity <= 0 then
        Inventory[Item.Name] = nil
    else
        Inventory[Item.Name].Quantity = Inventory[Item.Name].Quantity-Quantity
    end
end