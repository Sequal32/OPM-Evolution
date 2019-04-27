ItemFactory = {}

function Item.New()
    local Item = {}

    Item.Name = ""
    Item.Droppable = false
    Item.QuestItem = false
    Item.Quantity = 0

    return Item
end

return ItemFactory