ItemFactory = {}

function ItemFactory.New(Name, Droppable, QuestItem, Quantity)
    local Item = {}

    Item.Name = Name
    Item.Droppable = Droppable
    Item.QuestItem = QuesuesttItem
    Item.Quantity = Quantity

    return Item
end

return ItemFactory