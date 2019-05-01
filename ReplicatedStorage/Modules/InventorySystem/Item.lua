ItemFactory = {}

function Item.New(Name, Droppable, QuestItem, Quantity)
    local Item = {}

    Item.Name = Name
    Item.Droppable = Droppable
    Item.QuestItem = QuestItem
    Item.Quantity = Quantity

    return Item
end

return ItemFactory