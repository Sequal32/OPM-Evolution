Player = game.Players.LocalPlayer
Mouse = Player:GetMouse()

CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")

-- Paths
PickupItemUI = Player.PlayerGui:WaitForChild("MainUI"):WaitForChild("GameUI"):WaitForChild("PickupItem")
Events = RP.Events.General
-- Requires
SkillTrigger = RP.General.SkillTrigger
InventoryFactory = require(RP.Modules.InventorySystem.Inventory)
-- Running Variables
Target = Mouse.Target

function PickupItem()
    if not Target then return end
    local NewItem = Events.InventoryChange:InvokeServer("Add", Target)
    if NewItem then
        Inventory:AddItem(NewItem)
    end
end

-- Create pickup button
Pickup = require(SkillTrigger:Clone())
Pickup.New("Interact", Enum.KeyCode.E, false, "Press", {}, {
    Main = PickupItem  
})

-- Create inventory
Inventory = InventoryFactory.new()

while wait() do
    Target = Mouse.Target
    if Target and CS:HasTag(Target, "Item") then
        if PickupItemUI.Visible then
            TS:Create(PickupItemUI, TweenInfo.new(0.1), {Position = UDim2.new(0, Mouse.X+2, 0, Mouse.Y)}):Play()
        else
            PickupItemUI.Position = UDim2.new(0, Mouse.X+2, 0, Mouse.Y)
        end
        PickupItemUI.ItemText.Text = "[E] Pickup "..Target.Name
        PickupItemUI.Visible = true
    else
        PickupItemUI.Visible = false
    end
end