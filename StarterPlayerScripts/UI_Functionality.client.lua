-- Local script that handles UI Functionality

-- Services
local RP = game:GetService("ReplicatedStorage")
local RPF = game:GetService("ReplicatedFirst")
local MS = game:GetService("MarketplaceService")
local CP = game:GetService("ContentProvider")
local TS = game:GetService("TweenService")

-- Variables
Player = game.Players.LocalPlayer
Starting = false

-- Paths
MainUI = RPF.MainUI
Intro = MainUI:WaitForChild("Intro")
Shop = MainUI:WaitForChild("Shop")
ItemShop = Shop:WaitForChild("ShopBG")
StatsFrame = MainUI:WaitForChild("Stats")
SettingsFrame = MainUI:WaitForChild("Settings"):WaitForChild("SettingsBG")
AttributesFrame = StatsFrame:WaitForChild("StatsBG"):WaitForChild("AttributesFrame")
QuestFrame = MainUI:WaitForChild("Quests"):WaitForChild("QuestsBG")
QuestInfoFrame = MainUI:WaitForChild("QuestInfo")

GeneralEvents = RP:WaitForChild("Events"):WaitForChild("General")

ui_data = RP:WaitForChild("UI_Data")
ui_remotes = ui_data:WaitForChild("UI_Remotes")
ui_events = ui_data:WaitForChild("UI_Events")

UI_Data = RP:WaitForChild("UI_Data")
Resources = UI_Data:WaitForChild("Resources")
Startup = Player:WaitForChild("PlayerScripts"):WaitForChild("Startup")

CameraScript = Startup:WaitForChild("InitialCamera")

-- After variables
CurrentCharacter = GeneralEvents.CharacterServer:InvokeServer("FETCH")
CharacterAppearance = CurrentCharacter.Appearance
--print(game.HttpService:JSONEncode(CurrentCharacter))

--AttributeStuff
AttributePointsCurrent = 0
AttributePointsToSpend = 0

local CharacterItems = RP.CharacterItems

Characters = {
    ["Cyborg"] = {
        ["PelletStorm"] = "1",
        ["Hover"] = "2",
        ["Jump"] = "Space",
        ["Blast"] = "3"
    },
    ["Ninja"] = {
        ["Shuriken"] = "1",
        ["Slash"] = "2",
        ["Dash"] = "Shift",
        ["ChargedJump/AirStep"] = "Space",
    },
    ["SuperHuman"] = {
	    ["Punch"] = "1",
	    ["RangedPunch"] = "2",
	    ["BoulderToss"] = "3"
    }
}

-- Intro
spawn(function()
	MainUI.Parent = Player.PlayerGui
	-- Begin Intro Sequence
	MainUI.Intro.Visible = true
	-- Fade in Intro Text
	for i = 1,10 do
		MainUI.Intro.Text.TextTransparency = MainUI.Intro.Text.TextTransparency - 0.1
		wait()
	end
	wait(3)
	-- Fade Intro Text out, wait 2 seconds and fade in Game Name Text
	for i = 1,10 do
		MainUI.Intro.Text.TextTransparency = MainUI.Intro.Text.TextTransparency + 0.1
		wait()
	end
	wait(2)
	for i = 1,10 do
		MainUI.Intro.GameName.TextTransparency = MainUI.Intro.GameName.TextTransparency - 0.1
		MainUI.Intro.Fist.ImageTransparency = MainUI.Intro.Fist.ImageTransparency - 0.1
		MainUI.Intro.LoadingBG.BackgroundTransparency = MainUI.Intro.LoadingBG.BackgroundTransparency - 0.1
		wait()
	end	
	-- Put flashing code in fist and start loading
	
	local fc = Startup.FlashingCode:Clone()
	fc.Parent = MainUI.Intro.Fist
	fc.Disabled = false
	
	repeat wait() until CP.RequestQueueSize == 0
	CameraScript.Disabled = false
	-- Fade out intro and animate in main menu UI elements
	fc.Disabled = true
	fc:remove()
	-- create blur
	local blur = Instance.new("BlurEffect", workspace.CurrentCamera)
	blur.Name = "UI_Blur"
	blur.Enabled = true
	blur.Size = 80
	
	for i = 1,10 do
		MainUI.Intro.BackgroundTransparency = MainUI.Intro.BackgroundTransparency + 0.1
		MainUI.Intro.GameName.TextTransparency = MainUI.Intro.GameName.TextTransparency + 0.1
		MainUI.Intro.Fist.ImageTransparency = MainUI.Intro.Fist.ImageTransparency + 0.1
		MainUI.Intro.LoadingBG.BackgroundTransparency = MainUI.Intro.LoadingBG.BackgroundTransparency + 0.1		
		wait()
	end	
	-- Animate in Main Menu UI elements	
	MainUI.MainMenu.Visible = true
	MainUI.MainMenu.Header:TweenPosition(UDim2.new(0.271, 0,0.171, 0),"Out","Quad",0.3)
	MainUI.MainMenu.CCButton:TweenPosition(UDim2.new(0.405, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.PlayButton:TweenPosition(UDim2.new(0.472, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.SettingsButton:TweenPosition(UDim2.new(0.54, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.NewGameButton:TweenPosition(UDim2.new(0.443, 0,0.631, 0),"Out","Quad",0.3)
	MainUI.MainMenu.LoadGameButton:TweenPosition(UDim2.new(0.443, 0,0.705, 0),"Out","Quad",0.3)
	-- Animate in Main Menu UI elements	
	MainUI.MainMenu.Visible = true
	MainUI.MainMenu.Header:TweenPosition(UDim2.new(0.271, 0,0.171, 0),"Out","Quad",0.3)
	MainUI.MainMenu.CCButton:TweenPosition(UDim2.new(0.405, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.PlayButton:TweenPosition(UDim2.new(0.472, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.SettingsButton:TweenPosition(UDim2.new(0.54, 0,0.45, 0),"Out","Quad",0.3)
	MainUI.MainMenu.NewGameButton:TweenPosition(UDim2.new(0.443, 0,0.631, 0),"Out","Quad",0.3)
    MainUI.MainMenu.LoadGameButton:TweenPosition(UDim2.new(0.443, 0,0.705, 0),"Out","Quad",0.3)
    -- General stuff
    SettingsFrame.CurrentVersion.Text = "V "..GeneralEvents.GetServerVersion:InvokeServer()
end)

-- Buttons
MainUI.GameUI.StoreButton.MouseButton1Click:Connect(function()
	if MainUI.Shop.Visible == false then
		-- Open
		MainUI.Shop.Visible = true
		MainUI.Shop:TweenPosition(UDim2.new(0, 0, 0, 0),"Out","Quad",0.3)
	else
		-- Close
		MainUI.Shop:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		MainUI.Shop.Visible = false
	end 
end)

MainUI.GameUI.ProgressButton.MouseButton1Click:Connect(function()
	if StatsFrame.Visible == false then
		-- Open
		ResetAttributeLeveling()
		StatsFrame.Visible = true
		StatsFrame:TweenPosition(UDim2.new(0, 0, 0, 0),"Out","Quad",0.3)
	else
		-- Close
		StatsFrame:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)	
		StatsFrame.Visible = false
	end 
end)

MainUI.GameUI.SettingsButton.MouseButton1Click:Connect(function()
	if MainUI.Settings.Visible == false then
		-- Open
		MainUI.Settings.Visible = true
		MainUI.Settings:TweenPosition(UDim2.new(0, 0, 0, 0),"Out","Quad",0.3)
	else
		-- Close
		MainUI.Settings:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		MainUI.Settings.Visible = false
	end 
end)

MainUI.Shop.ShopBG.CloseButton.MouseButton1Click:Connect(function()
	if MainUI.Shop.Visible == true then
		-- Close
		MainUI.Shop:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		MainUI.Shop.Visible = false
	end 	
end)

MainUI.Settings.SettingsBG.CloseButton.MouseButton1Click:Connect(function()
	if MainUI.Settings.Visible == true then
		-- Close
		MainUI.Settings:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		MainUI.Settings.Visible = false
	end 	
end)

StatsFrame.StatsBG.CloseButton.MouseButton1Click:Connect(function()
	if StatsFrame.Visible == true then
		-- Close
		StatsFrame:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		StatsFrame.Visible = false
	end 	
end)

MainUI.MainMenu.PlayButton.MouseButton1Click:Connect(function()
	local data, FirstTime = GeneralEvents.StatsServer:InvokeServer("FETCH")

    if FirstTime then
        Starting = true
        beginCustomizeProcess()
        repeat wait() until MainUI.CharacterCustomize.Visible
    elseif Starting then
        return
    end
    Starting = true
    
    repeat wait() until not MainUI.CharacterCustomize.Visible

    IntroSequence()

    Starting = false
end)

MainUI.MainMenu.SettingsButton.MouseButton1Click:Connect(function()
	if MainUI.Settings.Visible == false then
		MainUI.Settings.Visible = true
		MainUI.Settings:TweenPosition(UDim2.new(0, 0, 0, 0),"Out","Quad",0.3)
	else
		-- Close
		MainUI.Settings:TweenPosition(UDim2.new(-1, 0, 0, 0),"Out","Quad",0.3)
		wait(0.3)
		MainUI.Settings.Visible = false
	end 	
end)

MainUI.MainMenu.CCButton.MouseButton1Click:Connect(function()
    beginCustomizeProcess()
    MainUI.MainMenu.Visible = true
end)

-- Bars
ui_events.ChangeHealth.Event:Connect(function(health, maxHealth)
	MainUI.GameUI.HealthBar.Progress:TweenSize(UDim2.new(health/maxHealth, 0, 1, 0),"Out","Quad",0.2)
	MainUI.GameUI.CurrentHealth.Text = health
end)

ui_events.ChangeDefenseStats.Event:Connect(function(stat,maxLevel)
	local Percentage = stat/maxLevel
	StatsFrame.StatsBG.DefenseBar.Progress.Size = UDim2.new(1, 0, Percentage, 0)
	StatsFrame.StatsBG.DefenseBar.Progress.Position = UDim2.new(0, 0, 1-Percentage, 0)
	StatsFrame.StatsBG.DefenseBar.Level.Text = stat
end)

ui_events.ChangeStrengthStats.Event:Connect(function(stat,maxLevel)
	local Percentage = stat/maxLevel
	StatsFrame.StatsBG.StrengthBar.Progress.Size = UDim2.new(1, 0, Percentage, 0)
	StatsFrame.StatsBG.StrengthBar.Progress.Position = UDim2.new(0, 0, 1-Percentage, 0)
	StatsFrame.StatsBG.StrengthBar.Level.Text = stat
end)

ui_events.ChangeAgilityStats.Event:Connect(function(stat,maxLevel)
	local Percentage = stat/maxLevel
	StatsFrame.StatsBG.AgilityBar.Progress.Size = UDim2.new(1, 0, Percentage, 0)
	StatsFrame.StatsBG.AgilityBar.Progress.Position = UDim2.new(0, 0, 1-Percentage, 0)
	StatsFrame.StatsBG.AgilityBar.Level.Text = stat
end)

ui_events.ChangeAttributeStats.Event:Connect(function(stat)
	AttributePointsCurrent = stat
end)

ui_events.ChangeStaminaStats.Event:Connect(function(stat,maxLevel)
	local Percentage = stat/maxLevel
	StatsFrame.StatsBG.StaminaBar.Progress.Size = UDim2.new(1, 0, Percentage, 0)
	StatsFrame.StatsBG.StaminaBar.Progress.Position = UDim2.new(0, 0, 1-Percentage, 0)
	StatsFrame.StatsBG.StaminaBar.Level.Text = stat
end)

ui_events.ChangeInGameStamina.Event:Connect(function(stat,maxLevel)
	MainUI.GameUI.StaminaBar.Progress.Size = UDim2.new(stat/maxLevel, 0, 1, 0)
	MainUI.GameUI.CurrentStamina.Text = stat.."/"..maxLevel
end)

ui_events.ChangeEXP.Event:Connect(function(exp, expNeeded)
	MainUI.GameUI.EXPBar.Progress:TweenSize(UDim2.new(exp/expNeeded ,0, 1, 0),"Out","Quad",0.2)
	MainUI.GameUI.EXPBar.EXPText.Text = exp.."/"..expNeeded
end)

ui_events.ChangeLevel.Event:Connect(function(Level)
	StatsFrame.StatsBG.CurrentLevel.Text = "Level "..Level
	MainUI.GameUI.EXPBar.LevelText.Text = "Level "..Level
end)

ui_events.ChangeYen.Event:Connect(function(Yen)
	MainUI.GameUI.CurrentYen.Amount.Text = Yen.." YEN"
	ItemShop.CurrentYen.Text = Yen.." YEN"
end)

-- Shop Section

-- Prompt Purchase Functions
function PromptPurchase(YenPrice, RobuxPrice, ShopItem)
	local ConfirmPurchase = Shop.ConfirmPurchase
	local Connection1, Connection2
	
	if ConfirmPurchase.Visible then return end
	ConfirmPurchase.Visible = true
	
	local function EndPurchase(WaitTime)
		Connection1:Disconnect()
		Connection2:Disconnect()
		wait(WaitTime)
		ConfirmPurchase.Visible = false
	end
	
	if YenPrice and RobuxPrice then
		ConfirmPurchase.Robux.Visible = true
		ConfirmPurchase.Yen.Visible = true
		ConfirmPurchase.Robux.Size = UDim2.new(0.5, 0, 0.3, 0)
		ConfirmPurchase.Robux.Position = UDim2.new(0.5, 0, 0.7, 0)
		ConfirmPurchase.Yen.Size = UDim2.new(0.5, 0, 0.3, 0)
		ConfirmPurchase.Yen.Position = UDim2.new(0, 0, 0.7, 0)
		ConfirmPurchase.Robux.Text.Text = "Pay with "..RobuxPrice.." Robux"
		ConfirmPurchase.Yen.Text.Text = "Pay with "..YenPrice.." Yen"
	elseif YenPrice then
		ConfirmPurchase.Robux.Visible = false
		ConfirmPurchase.Yen.Visible = true
		ConfirmPurchase.Yen.Size = UDim2.new(1, 0, 0.3, 0)
		ConfirmPurchase.Yen.Position = UDim2.new(0, 0, 0.7, 0)
		ConfirmPurchase.Yen.Text.Text = "Pay with "..YenPrice.." Yen"
	elseif RobuxPrice then
		ConfirmPurchase.Robux.Visible = true
		ConfirmPurchase.Yen.Visible = false
		ConfirmPurchase.Robux.Size = UDim2.new(1, 0, 0.3, 0)
		ConfirmPurchase.Robux.Position = UDim2.new(0, 0, 0.7, 0)
		ConfirmPurchase.Robux.Text.Text = "Pay with "..RobuxPrice.." Robux"
	end
	
	Connection1 = ConfirmPurchase.Robux.Text.Activated:Connect(function()
		MS:PromptProductPurchase(Player, ShopItem.ProductId)
		EndPurchase(0)
	end)
	
	Connection2 = ConfirmPurchase.Yen.Text.Activated:Connect(function()
		local Success = GeneralEvents.PurchaseWithYen:InvokeServer(YenPrice, ShopItem)
		if not Success then
			ConfirmPurchase.Yen.Text.Text = "Insufficient Funds"
		else
			ConfirmPurchase.Yen.Text.Text = "Success!"
		end
		EndPurchase(2)
	end)
	
	ConfirmPurchase.Close.MouseButton1Click:Connect(function()
		EndPurchase(0)
	end)
end

function ClearShop()
	for _,Page in pairs(ItemShop.Container:GetChildren()) do
		if Page:IsA("GuiBase2d") then
			Page:Destroy()
		end
	end
end

function LoadShopItems(ShopItems)
	local Pages = math.floor(#ShopItems/9) > 0 and math.floor(#ShopItems/9) or 1
	for PageNumber=1, Pages, 1 do
		
		local PageFrame = Resources.Page:Clone()
		
		for ItemNumber=1, 9, 1 do
			local Item = ShopItems[ItemNumber*PageNumber]
			if not Item then break end
			
			local ItemFrame = Resources.Item:Clone()
			
			if Item.ProductId then
				local Info = MS:GetProductInfo(Item.ProductId, Enum.InfoType.Product)
				ItemFrame.ItemName.Text = Info.Name
				ItemFrame.Thumbnail.Image = "rbxassetid://"..Info.IconImageAssetId
				ItemFrame.Yen.Value = Item.Yen
				ItemFrame.Robux.Value = Info.PriceInRobux
				ItemFrame.ProductId.Value = Item.ProductId
				
				if Item.Yen then
					ItemFrame.PurchaseText.Text = string.format("%d Yen/%d Robux", Item.Yen, Item.Robux)
					ItemFrame.PurchaseButton.MouseButton1Click:Connect(function()
						PromptPurchase(Item.Yen, Info.PriceInRobux, Info)
					end)
				elseif Item.Robux then
					ItemFrame.PurchaseText.Text = Info.PriceInRobux.." Robux"
					
					ItemFrame.PurchaseButton.MouseButton1Click:Connect(function()
						PromptPurchase(nil, Info.PriceInRobux, Info)
					end)
				end
			else
				ItemFrame.ItemName.Text = Item.Name or ""
				ItemFrame.Thumbnail.Image = Item.ImageURL or ""
				ItemFrame.Yen.Value = Item.Yen or ""
				ItemFrame.PurchaseText.Text = Item.Yen or ""
				
				if Item.Yen then
					ItemFrame.PurchaseButton.MouseButton1Click:Connect(function()
						PromptPurchase(Item.Yen, nil, Item)
					end)
				end
			end
			
			ItemFrame.Name = "Item"..ItemNumber
			ItemFrame.Parent = PageFrame
		end
		
		PageFrame.Name = "Page"..PageNumber
		PageFrame.Parent = ItemShop.Container
	end
end
local AllItems = ui_data.UI_Shop_Remotes.ReturnShopItems:InvokeServer()
local YenItems = AllItems.YenItems
local ClassItems = AllItems.ClassItems

MainUI.Shop.ShopBG.BuyYen.MouseButton1Click:Connect(function()
	ClearShop()
	LoadShopItems(YenItems)
end)

MainUI.Shop.ShopBG.Classes.MouseButton1Click:Connect(function()
	ClearShop()
	LoadShopItems(ClassItems)
end)

-- Character Customization Section

-- Display items in CC

function weldAttachments(attach1, attach2)
    local weld = Instance.new("Weld")
    weld.Part0 = attach1.Parent
    weld.Part1 = attach2.Parent
    weld.C0 = attach1.CFrame
    weld.C1 = attach2.CFrame
    weld.Parent = attach1.Parent
    return weld
end
 
local function buildWeld(weldName, parent, part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Name = weldName
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = parent
    return weld
end
 
local function findFirstMatchingAttachment(model, name)
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("Attachment") and child.Name == name then
            return child
        elseif not child:IsA("Accoutrement") and not child:IsA("Tool") then -- Don't look in hats or tools in the character
            local foundAttachment = findFirstMatchingAttachment(child, name)
            if foundAttachment then
                return foundAttachment
            end
        end
    end
end
 
function addAccoutrement(character, accoutrement)  
    accoutrement.Parent = character
    local handle = accoutrement:FindFirstChild("Handle")
    if handle then
        local accoutrementAttachment = handle:FindFirstChildOfClass("Attachment")
        if accoutrementAttachment then
            local characterAttachment = findFirstMatchingAttachment(character, accoutrementAttachment.Name)
            if characterAttachment then
                weldAttachments(characterAttachment, accoutrementAttachment)
            end
        else
            local head = character:FindFirstChild("Head")
            if head then
                local attachmentCFrame = CFrame.new(0, 0.5, 0)
                local hatCFrame = accoutrement.AttachmentPoint
                buildWeld("HeadWeld", head, head, handle, attachmentCFrame, hatCFrame)
            end
        end
    end
end

local function CFrameAccessoryToCharacter(characterModel, accessory)
	local accessoryAttachment = accessory:FindFirstChildWhichIsA("Attachment", true)
	if not accessoryAttachment then
		warn("No attachments found in accessory. Accessory was not attached.")
		return
	end
	
	local attachmentName = accessoryAttachment.Name
	local attachTo = characterModel:FindFirstChild(attachmentName, true)
	if not attachTo or not attachTo:IsA("Attachment") then
		warn(string.format("No attachment named %s found in character. Accessory was not attached.", attachmentName))
		return
	end
	
	local Handle = accessory:FindFirstChild("Handle")
	if not Handle then
		warn("Attachment has no handle. Accessory was not attached.")
		return
	end
	
	accessory.Parent = characterModel
	
	Handle.CFrame = attachTo.WorldCFrame * accessoryAttachment.CFrame:Inverse()
end

function loadHairOneItems()
	local ShopItems = CharacterItems.Hair:GetChildren()
	if ShopItems and ShopItems ~= nil then
		--print("T2")
		-- Clear all previous pages
		if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
			for t,a in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
				a:remove()
			end
		end
		MainUI.CharacterCustomize.CurrentPage.Value = "HairOne"
		local maxItems = #ShopItems
		local categoryItemsTable = {}
		--print("T3")
		-- Store all items with this category in the table above this line
		categoryItemsTable = ShopItems
		-- Get max items of categoryItemsTable and then make pages and store it in "Pages" folder
		local maxTempItems = #categoryItemsTable
		if maxTempItems == 0 then
			-- Do nothing, there is no items
		elseif maxTempItems < 13 then
			-- Only one page of items, 12 items per page
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page1"
			cClone.Visible = false
			
			for index = 1,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
			end
		elseif maxTempItems > 12 then
			-- More then one page of items
			local currentNum = 1
			local currentPageCount = 1
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			
			for index = currentNum,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentPageCount = currentPageCount + 1
					break
				end
			end
			repeat
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			local currentItemNum = 1
			for index = currentNum+1,maxTempItems do		
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentItemNum = currentItemNum + 1				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentItemNum = 1
					currentPageCount = currentPageCount + 1
					break	
				end		
			end	
			until currentNum == maxTempItems
			--
		end
	end
	-- Show page 1
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		MainUI.CharacterCustomize.Pages["Page1"].Visible = true
	end
	-- Add click event to items
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		for p,s in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
			for x,item in pairs(s:GetChildren()) do
				if string.sub(item.Name,1,4) == "Item" then
					item.PurchaseButton.MouseButton1Click:Connect(function()
						if MainUI.CharacterCustomize.isCharacterLoaded.Value == true then
							-- Put in code to wear this item for Character Customization
								local hair = CharacterItems.Hair:FindFirstChild(item.ItemName.Text)
								if hair then
									for l,o in pairs(MainUI.CharacterCustomize.CharacterFrame.BlankCharacter:GetChildren()) do
										if string.sub(o.Name,1,2) == "1_" then
											if o:IsA("Accessory") then
												o:remove()
											end
										end
									end
									local hairClone = hair:Clone()
									hairClone.Name = "1_"..hairClone.Name
									--hairClone.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
									local char = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
									CFrameAccessoryToCharacter(char, hairClone)
								end
								--for a,x in pairs(char:GetChildren()) do
								--	if x:IsA("BasePart") then
								--		x.Anchored = true
								--	end
								--end
								--char.Parent = workspace
								--addAccoutrement(char,hairClone)
								--wait()
								--char.Parent = MainUI.CharacterCustomize.CharacterFrame
								--for z,t in pairs(char:GetChildren()) do
								--	if t:IsA("BasePart") then
								--		t.Anchored = false
								--	end
								--end								
								--MainUI.CharacterCustomize.BlankCharacter.Parent = MainUI.CharacterCustomize.CharacterFrame
							--[[if item.PaymentType.Value == "Robux" or item.PaymentType.Value == "robux" then
								-- use marketplace service
								local ms = MS
								MS:PromptProductPurchase(Player, item.ProductId.Value)
							elseif item.PaymentType.Value == "Yen" or item.PaymentType.Value == "yen" then
								game.ReplicatedStorage.Player_DS_Data.SubtractLocalPlayerYen:FireServer(item.Price.Value)
							end]]--
						end
					end)
				end
			end
		end
	end
	--
end
			
function loadShirtItems()
	local ShopItems = CharacterItems.Shirts:GetChildren()
	if ShopItems and ShopItems ~= nil then
		--print("T2")
		-- Clear all previous pages
		if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
			for t,a in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
				a:remove()
			end
		end
		MainUI.CharacterCustomize.CurrentPage.Value = "Shirt"
		local maxItems = #ShopItems
		local categoryItemsTable = {}
		--print("T3")
		-- Store all items with this category in the table above this line
		categoryItemsTable = ShopItems
		-- Get max items of categoryItemsTable and then make pages and store it in "Pages" folder
		local maxTempItems = #categoryItemsTable
		if maxTempItems == 0 then
			-- Do nothing, there is no items
		elseif maxTempItems < 13 then
			-- Only one page of items, 12 items per page
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page1"
			cClone.Visible = false
			
			for index = 1,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
			end
		elseif maxTempItems > 12 then
			-- More then one page of items
			local currentNum = 1
			local currentPageCount = 1
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			
			for index = currentNum,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentPageCount = currentPageCount + 1
					break
				end
			end
			repeat
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			local currentItemNum = 1
			for index = currentNum+1,maxTempItems do		
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentItemNum = currentItemNum + 1				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentItemNum = 1
					currentPageCount = currentPageCount + 1
					break	
				end		
			end	
			until currentNum == maxTempItems
			--
		end
	end
	-- Show page 1
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		MainUI.CharacterCustomize.Pages["Page1"].Visible = true
	end
	-- Add click event to items
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		for p,s in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
			for x,item in pairs(s:GetChildren()) do
				if string.sub(item.Name,1,4) == "Item" then
					item.PurchaseButton.MouseButton1Click:Connect(function()
						if MainUI.CharacterCustomize.isCharacterLoaded.Value == true then
							-- Put in code to wear this item for Character Customization
								local shirt = CharacterItems.Shirts:FindFirstChild(item.ItemName.Text)
								if shirt then
									MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Shirt.ShirtTemplate = "rbxassetid://"..shirt.Value
								end
								--hairClone.Handle.Position = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Position
								--hairClone.Handle.AccessoryWeld.Part0 = hairClone.Handle
								--hairClone.Handle.AccessoryWeld.Part1 = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head
								--hairClone.Handle.AccessoryWeld.C0 = CFrame.new(0,0.25,0)
								--addAccoutrement(MainUI.CharacterCustomize.CharacterFrame.BlankCharacter,hairClone)
							--[[if item.PaymentType.Value == "Robux" or item.PaymentType.Value == "robux" then
								-- use marketplace service
								local ms = MS
								MS:PromptProductPurchase(Player, item.ProductId.Value)
							elseif item.PaymentType.Value == "Yen" or item.PaymentType.Value == "yen" then
								game.ReplicatedStorage.Player_DS_Data.SubtractLocalPlayerYen:FireServer(item.Price.Value)
							end]]--
						end
					end)
				end
			end
		end
	end
	--
end			

function loadPantsItems()
	local ShopItems = CharacterItems.Pants:GetChildren()
	if ShopItems and ShopItems ~= nil then
		--print("T2")
		-- Clear all previous pages
		if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
			for t,a in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
				a:remove()
			end
		end
		MainUI.CharacterCustomize.CurrentPage.Value = "Pants"
		local maxItems = #ShopItems
		local categoryItemsTable = {}
		--print("T3")
		-- Store all items with this category in the table above this line
		categoryItemsTable = ShopItems
		-- Get max items of categoryItemsTable and then make pages and store it in "Pages" folder
		local maxTempItems = #categoryItemsTable
		if maxTempItems == 0 then
			-- Do nothing, there is no items
		elseif maxTempItems < 13 then
			-- Only one page of items, 12 items per page
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page1"
			cClone.Visible = false
			
			for index = 1,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
			end
		elseif maxTempItems > 12 then
			-- More then one page of items
			local currentNum = 1
			local currentPageCount = 1
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			
			for index = currentNum,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentPageCount = currentPageCount + 1
					break
				end
			end
			repeat
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			local currentItemNum = 1
			for index = currentNum+1,maxTempItems do		
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentItemNum = currentItemNum + 1				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentItemNum = 1
					currentPageCount = currentPageCount + 1
					break	
				end		
			end	
			until currentNum == maxTempItems
			--
		end
	end
	-- Show page 1
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		MainUI.CharacterCustomize.Pages["Page1"].Visible = true
	end
	-- Add click event to items
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		for p,s in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
			for x,item in pairs(s:GetChildren()) do
				if string.sub(item.Name,1,4) == "Item" then
					item.PurchaseButton.MouseButton1Click:Connect(function()
						if MainUI.CharacterCustomize.isCharacterLoaded.Value == true then
							-- Put in code to wear this item for Character Customization
								local shirt = CharacterItems.Pants:FindFirstChild(item.ItemName.Text)
								if shirt then
									MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Pants.PantsTemplate = "rbxassetid://"..shirt.Value
								end
								--hairClone.Handle.Position = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Position
								--hairClone.Handle.AccessoryWeld.Part0 = hairClone.Handle
								--hairClone.Handle.AccessoryWeld.Part1 = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head
								--hairClone.Handle.AccessoryWeld.C0 = CFrame.new(0,0.25,0)
								--addAccoutrement(MainUI.CharacterCustomize.CharacterFrame.BlankCharacter,hairClone)
							--[[if item.PaymentType.Value == "Robux" or item.PaymentType.Value == "robux" then
								-- use marketplace service
								local ms = MS
								MS:PromptProductPurchase(Player, item.ProductId.Value)
							elseif item.PaymentType.Value == "Yen" or item.PaymentType.Value == "yen" then
								game.ReplicatedStorage.Player_DS_Data.SubtractLocalPlayerYen:FireServer(item.Price.Value)
							end]]--
						end
					end)
				end
			end
		end
	end
	--
end			

function loadFaceItems()
	local ShopItems = CharacterItems.Faces:GetChildren()
	if ShopItems and ShopItems ~= nil then
		--print("T2")
		-- Clear all previous pages
		if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
			for t,a in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
				a:remove()
			end
		end
		MainUI.CharacterCustomize.CurrentPage.Value = "Faces"
		local maxItems = #ShopItems
		local categoryItemsTable = {}
		--print("T3")
		-- Store all items with this category in the table above this line
		categoryItemsTable = ShopItems
		-- Get max items of categoryItemsTable and then make pages and store it in "Pages" folder
		local maxTempItems = #categoryItemsTable
		if maxTempItems == 0 then
			-- Do nothing, there is no items
		elseif maxTempItems < 13 then
			-- Only one page of items, 12 items per page
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page1"
			cClone.Visible = false
			
			for index = 1,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
			end
		elseif maxTempItems > 12 then
			-- More then one page of items
			local currentNum = 1
			local currentPageCount = 1
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			
			for index = currentNum,maxTempItems do
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentPageCount = currentPageCount + 1
					break
				end
			end
			repeat
			local container = MainUI.CharacterCustomize.Container
			local cClone = container:Clone()
			cClone.Parent = MainUI.CharacterCustomize.Pages
			cClone.Name = "Page"..currentPageCount
			cClone.Visible = false
			local currentItemNum = 1
			for index = currentNum+1,maxTempItems do		
				-- Fill information
				local item = categoryItemsTable[index]
				cClone["Item"..index].ItemName.Text = item.Name
				
				currentItemNum = currentItemNum + 1				
				currentNum = currentNum + 1
				-- If currentNum is a multiple of nine then fill info one last time
				if currentNum % 12 == 0 then
				local item2 = categoryItemsTable[index+1]
				cClone["Item"..index].ItemName.Text = item2.Name										
					currentItemNum = 1
					currentPageCount = currentPageCount + 1
					break	
				end		
			end	
			until currentNum == maxTempItems
			--
		end
	end
	-- Show page 1
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		MainUI.CharacterCustomize.Pages["Page1"].Visible = true
	end
	-- Add click event to items
	if #MainUI.CharacterCustomize.Pages:GetChildren() > 0 then
		for p,s in pairs(MainUI.CharacterCustomize.Pages:GetChildren()) do
			for x,item in pairs(s:GetChildren()) do
				if string.sub(item.Name,1,4) == "Item" then
					item.PurchaseButton.MouseButton1Click:Connect(function()
						if MainUI.CharacterCustomize.isCharacterLoaded.Value == true then
							-- Put in code to wear this item for Character Customization
								local shirt = CharacterItems.Faces:FindFirstChild(item.ItemName.Text)
								if shirt then
									MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Face:remove()
									local Face = shirt:Clone()
									Face.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head
									Face.Name = "Face"
									--MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Face.Texture = "rbxassetid://"..shirt.Value
								end
								--hairClone.Handle.Position = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Position
								--hairClone.Handle.AccessoryWeld.Part0 = hairClone.Handle
								--hairClone.Handle.AccessoryWeld.Part1 = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head
								--hairClone.Handle.AccessoryWeld.C0 = CFrame.new(0,0.25,0)
								--addAccoutrement(MainUI.CharacterCustomize.CharacterFrame.BlankCharacter,hairClone)
							--[[if item.PaymentType.Value == "Robux" or item.PaymentType.Value == "robux" then
								-- use marketplace service
								local ms = MS
								MS:PromptProductPurchase(Player, item.ProductId.Value)
							elseif item.PaymentType.Value == "Yen" or item.PaymentType.Value == "yen" then
								game.ReplicatedStorage.Player_DS_Data.SubtractLocalPlayerYen:FireServer(item.Price.Value)
							end]]--
						end
					end)
				end
			end
		end
	end
	--
end			

--loadHairOneItems()
loadFaceItems()

function beginCustomizeProcess() -- Run this when C button or new game button has been clicked in main menu
	local blankChar = RP.BlankCharacter:Clone()
    blankChar.Parent = MainUI.CharacterCustomize.CharacterFrame
    -- Open CharacterCustomize MainUI
	MainUI.MainMenu.Visible = false
    MainUI.CharacterCustomize.Visible = true
    -- Load blank character from ServerStorage to view port frame
    local viewportCamera = Instance.new("Camera")
    MainUI.CharacterCustomize.CharacterFrame.CurrentCamera = viewportCamera
    viewportCamera.Parent = MainUI.CharacterCustomize.CharacterFrame
    
    viewportCamera.CFrame = CFrame.new(blankChar.HumanoidRootPart.CFrame:toWorldSpace(CFrame.new(0,1,-6)).p, blankChar.HumanoidRootPart.CFrame.p)
    
    -- Get current character and begin customize process
	if CharacterAppearance then
		-- Put current items from chracterInfo on the character
		print(game.HttpService:JSONEncode(CharacterAppearance))
		for key,value in pairs(CharacterAppearance) do
			if key == "Shirt" then
				if CharacterItems.Shirts:FindFirstChild(value) then
					local shirt = CharacterItems.Shirts:FindFirstChild(value)
					if blankChar:FindFirstChild("Shirt") then
						MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Shirt.ShirtTemplate = "rbxassetid://"..shirt.Value
					end
				end
			elseif key == "Pant" then
				if CharacterItems.Pants:FindFirstChild(value) then
					local pant = CharacterItems.Pants:FindFirstChild(value)
					if blankChar:FindFirstChild("Pants") then
						MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Pants.PantsTemplate = "rbxassetid://"..pant.Value
					end
				end	
			elseif key == "Face" then
				if CharacterItems.Faces:FindFirstChild(value) then
					local face = CharacterItems.Faces:FindFirstChild(value)
					if blankChar.Head:FindFirstChild("Face") then
						MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head.Face:remove()
						local face2 = face:Clone()
						face.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter.Head
						face.Name = "Face"
					end
				end	
			elseif key == "Hair" then
				if CharacterItems.Hair:FindFirstChild(value) then
					local hair = CharacterItems.Hair:FindFirstChild(value)
					if hair then
						local hairClone = hair:Clone()
						hairClone.Name = "1_"..hairClone.Name
						--hairClone.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
						local char = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
						CFrameAccessoryToCharacter(char, hairClone)
					end		
				end	
			elseif key == "Hair2" then
				if CharacterItems.Hair:FindFirstChild(value) then
					local hair = CharacterItems.Hair:FindFirstChild(value)
					if hair then
						local hairClone = hair:Clone()
						hairClone.Name = "2_"..hairClone.Name
						--hairClone.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
						local char = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
						CFrameAccessoryToCharacter(char, hairClone)
					end				
				end	
			elseif key == "Accessories" then
				for i,v in pairs(value) do
					if CharacterItems.Accessories:FindFirstChild(value) then
					local Accessory = CharacterItems.Accessories:FindFirstChild(value)
						if Accessory then
							local hairClone = Accessory:Clone()
							--hairClone.Parent = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
							local char = MainUI.CharacterCustomize.CharacterFrame.BlankCharacter
							CFrameAccessoryToCharacter(char, hairClone)
						end	
					end
				end	
				--													
			end
        end
    end
		
    -- Now let the user add to and customize the character (by enable isCharacterLoaded value)
    MainUI.CharacterCustomize.isCharacterLoaded.Value = true
    
    -- Add event for the finish button and store the new character info a dictionary
    MainUI.CharacterCustomize.Finish.MouseButton1Click:Connect(function()
        -- cc > dictionary code (runs when finish button is clicked)
        
        -- Get Shirt
        if blankChar:FindFirstChild("Shirt") then
        local ShirtID = blankChar.Shirt.ShirtTemplate
            for i,v in pairs (CharacterItems.Shirts:GetChildren()) do
                    if v:IsA("NumberValue") then 
                        if "rbxassetid://"..v.Value == ShirtID then
                                -- match found
                            CharacterAppearance.Shirt = ShirtID
                                --for key,value in pairs(CurrentCharacter) do
                                --      if key == "Shirt" then 
                                --           value = v.Name
                                --      end
                                -- end
                        end
                    end
            end
        end
        
        
        -- Get Pants
        if blankChar:FindFirstChild("Pants") then
        local PantID = blankChar.Pants.PantsTemplate
        
        for I,v in pairs (CharacterItems.Pants:GetChildren()) do
                if v:IsA("NumberValue") then 
                    if "rbxassetid://"..v.Value == PantID then
                            -- match found
                        CharacterAppearance.Pant = PantID
                            -- for key,value in pairs(CurrentCharacter) do
                            --       if key == "Pant" then 
            --print("TR")
                            --               value = v.Name
                            --       end
                            -- end
                    end
                end
        end
        end
        
        
        -- Get Face
        if blankChar.Head:FindFirstChild("Face") then
            local FaceID = blankChar.Head.Face.Texture
            CharacterAppearance.Face = FaceID
        end
        
        --[[
        -- Get Hair1
        for z,t in pairs (blankChar:GetChildren()) do
                if t:IsA("Accessory") then
                        if string.sub(t.Name,1,2) == "1_" then
                            local accessoryName = string.sub(t.Name, 3)
                            if CharacterItems.Hair:FindFirstChild(accessoryName) then
                                for key,value in pairs(CurrentCharacter) do
                                        if key == "Hair1" then
                                            value = accessoryName
                                        end
                                end
                            end
                        if string.sub(t.Name,1,2) == "2_" then
                            local accessoryName = string.sub(t.Name, 3)
                            if CharacterItems.Hair:FindFirstChild(accessoryName) then
                                for key,value in pairs(CurrentCharacter) do
                                        if key == "Hair2" then
                                            value = accessoryName
                                        end
                                end
                            end
                    end
        
                            if string.sub(t.Name,1,2) ~= "2_" and string.sub(t.Name,1,2) ~= "1_" then
                            local accessoryName = string.sub(t.Name, 3)
                            if CharacterItems.Hair:FindFirstChild(accessoryName) then
                                for key,value in pairs(CurrentCharacter) do
                                        if key == "Accessories" then
                                            table.insert(value,accessoryName)
                                        end
                                end
                            end
                    end
        
                    end
                end
        end	]]--
        
        --for k,v in pairs(CurrentCharacter) do
        --	if k ~= "Accessories" then
        --		print(k.." - "..v)
        --	end
        --end
        
    -- Send the dictionary to PlayerData and get it stored in the player's data store
    
    CurrentCharacter.Appearance = CharacterAppearance
    local Success = GeneralEvents.CharacterServer:InvokeServer("UPDATE", CurrentCharacter)
    
    MainUI.CharacterCustomize.Visible = false
    end)
end

-- The isCharacterLoaded value is for the Character Customize code to know if there is a character to modify or it will try to modify nothing and error

MainUI.CharacterCustomize.NextCustoPage.MouseButton1Click:Connect(function()
	if MainUI.CharacterCustomize.CurrentPage.Value == "Faces" then
		loadShirtItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "Shirt" then
		loadPantsItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "Pants" then
		--loadHairOneItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "HairOne" then
		loadFaceItems()
	end
end)

MainUI.CharacterCustomize.PreviousCustoPage.MouseButton1Click:Connect(function()
	if MainUI.CharacterCustomize.CurrentPage.Value == "Faces" then
		--loadHairOneItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "Shirt" then
		loadFaceItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "Pants" then
		loadShirtItems()
	elseif MainUI.CharacterCustomize.CurrentPage.Value == "HairOne" then
		loadPantsItems()
	end
end)

-- Music

local songs = {342393207, 1595651255}

wait(1)

local sound = Instance.new("Sound")

function NewSong()
	sound.SoundId = "rbxassetid://"..songs[Random.new():NextInteger(1, #songs)]
	
	game:GetService("SoundService"):PlayLocalSound(sound)
	sound:Play()
	
	sound.Ended:connect(NewSong)
end

MainUI.GameUI.MuteButton.MouseButton1Click:Connect(function()
	if sound.IsPlaying == true then
		sound:Pause()
	else
		sound:Play()
	end
end)

function IntroSequence()
    MainUI.MainMenu.NewGameWarning.Visible = false
	-- Fade out main menu
    MainUI.MainMenu.ZIndex = 5
    
    local Tween = TS:Create(MainUI.MainMenu, TweenInfo.new(0.5), {["BackgroundTransparency"] = 0})
    Tween:Play()
    Tween.Completed:wait()

	MainUI.GameUI.Visible = true
	MainUI.MainMenu.PlayButton.Visible = false
	MainUI.MainMenu.SettingsButton.Visible = false
	MainUI.MainMenu.CCButton.Visible = false
	MainUI.MainMenu.NewGameButton.Visible = false
	MainUI.MainMenu.LoadGameButton.Visible = false
	MainUI.MainMenu.Header.Visible = false
	
	Startup.Stop:Fire()
	GeneralEvents.LoadCharacter:FireServer(CurrentCharacter)

    local Tween = TS:Create(workspace.CurrentCamera.UI_Blur, TweenInfo.new(0.5), {Size = 0})
    Tween:Play()
    Tween.Completed:wait()
    workspace.CurrentCamera.UI_Blur:Destroy()

	local Tween = TS:Create(MainUI.MainMenu, TweenInfo.new(0.5), {["BackgroundTransparency"] = 1})
    Tween:Play()
    Tween.Completed:wait()

	MainUI.MainMenu.Visible = false
    MainUI.MainMenu.ZIndex = 1
end

-- New Game btn
MainUI.MainMenu.NewGameButton.MouseButton1Click:Connect(function()
	MainUI.MainMenu.NewGameWarning.Visible = true
end)

MainUI.MainMenu.NewGameWarning.ContinueButton.MouseButton1Click:Connect(function()
    print("Pressed")
    if Starting then return end
    print("starting")
	Starting = true
    
    -- Allow user to customize characterdata
    beginCustomizeProcess()
    ui_remotes.ResetUserData:FireServer()
    repeat wait() until MainUI.CharacterCustomize.Visible
    repeat wait() until not MainUI.CharacterCustomize.Visible
	IntroSequence()
	
	Starting = false
end)

-- CUSTOMIZE CHARARCTER IN SETTINGS
SettingsFrame.Customize.MouseButton1Click:Connect(function()
    if not workspace.CurrentCamera:FindFirstChild("UI_Blur") then
        local blur = Instance.new("BlurEffect", workspace.CurrentCamera)
        blur.Name = "UI_Blur"
        blur.Enabled = true
        blur.Size = 80
    end

    MainUI.GameUI.Visible = false
    SettingsFrame.Visible = false

    beginCustomizeProcess()
    repeat wait() until MainUI.CharacterCustomize.Visible
    repeat wait() until not MainUI.CharacterCustomize.Visible
	IntroSequence()
end)

-- ATTRIBUTE LEVELING
local AddValues = AttributesFrame.AddValues
local AttributeFuture = {
	["StaminaLevel"] = 0,
	["DefenseLevel"] = 0,
	["StrengthLevel"] = 0,
	["AgilityLevel"] = 0	
}

function GetTotalAttributePointsInvested()
	local Total = 0
	for _,Value in pairs(AttributeFuture) do
		Total = Total+Value
	end
	return Total
end

function ResetAttributeLeveling()
	AttributePointsToSpend = AttributePointsCurrent
	AttributeFuture = {
		["StaminaLevel"] = 0,
		["DefenseLevel"] = 0,
		["StrengthLevel"] = 0,
		["AgilityLevel"] = 0	
	}
	
	AttributesFrame.Points.Text = AttributePointsToSpend.." Available Points"
	
	for Attribute,_ in pairs(AttributeFuture) do
		local Frame = AddValues[Attribute]
		Frame.Delta.Text = 0
	end
end

for Attribute,_ in pairs(AttributeFuture) do
	local Frame = AddValues[Attribute]
	Frame.Add.Activated:Connect(function()
		if AttributePointsToSpend <= 0 then return end
		AttributePointsToSpend = AttributePointsToSpend-1
		AttributeFuture[Attribute] = AttributeFuture[Attribute]+1 
		AttributesFrame.Points.Text = AttributePointsToSpend.." Available Points"
		Frame.Delta.Text = AttributeFuture[Attribute]
		if GetTotalAttributePointsInvested() > 0 then AddValues.Confirm.Text = "Confirm" else AddValues.Confirm.Text = "Waiting" end
	end)
	
	Frame.Subtract.Activated:Connect(function()
		if AttributeFuture[Attribute] <= 0 then return end
		AttributePointsToSpend = AttributePointsToSpend+1
		AttributeFuture[Attribute] = AttributeFuture[Attribute]-1
		AttributesFrame.Points.Text = AttributePointsToSpend.." Available Points"
		Frame.Delta.Text = AttributeFuture[Attribute]
		if GetTotalAttributePointsInvested() > 0 then AddValues.Confirm.Text = "Confirm" else AddValues.Confirm.Text = "Waiting" end
	end)
end

AddValues.Confirm.Activated:Connect(function()
	if GetTotalAttributePointsInvested() == 0 then return end
	GeneralEvents.StatsServer:InvokeServer("UPDATE", AttributeFuture)
	AddValues.Confirm.Text = "Success!"
	wait(2)
	AddValues.Confirm.Text = "Waiting"
end)

-- FEEDBACK SECTION
NextSendTime = 0
FeedbackFrame = SettingsFrame.FeedbackFrame
FeedbackButton = FeedbackFrame.SendFeedback
BugButton = FeedbackFrame.SendBug
CanButton = true

function VerifyBody(Body)
	local CharacterCount = string.len(Body)
	if CharacterCount < 50 or CharacterCount > 600 then return false end
	return true
end

SettingsFrame.Feedback.Activated:Connect(function()
	FeedbackFrame.Visible = true
end)

FeedbackButton.Activated:Connect(function()
	local Text = FeedbackFrame.FeedbackFrame.Body.Text
	
	CanButton = false
	
	if tick()-NextSendTime > 0 then 
		if VerifyBody(Text) then
			GeneralEvents.PostFeedback:FireServer(Text)
			NextSendTime = tick()+180
			
			FeedbackButton.Text = "Success!"
			wait(1)
			FeedbackButton.Text = "Send Feedback"
		else
			FeedbackButton.Text = "Not meeting char limit (> 50 < 600)"
			wait(1)
			FeedbackButton.Text = "Send Feedback"
		end
	else
		FeedbackButton.Text = "On Cooldown"
		wait(1)
		FeedbackButton.Text = "Send Feedback"
	end
	
	CanButton = true
end)

BugButton.Activated:Connect(function()
	local Text = FeedbackFrame.BugFrame.Body.Text
	
	CanButton = false
	
	if tick()-NextSendTime > 0 then 
		if VerifyBody(Text) then
			GeneralEvents.PostFeedback:FireServer(Text)
			NextSendTime = tick()+180
			
			FeedbackButton.Text = "Success!"
			wait(1)
			FeedbackButton.Text = "Send Feedback"
		else
			BugButton.Text = "Not meeting char limit (> 50 < 600)"
			wait(1)
			BugButton.Text = "Send Bug Report"
		end
	else
		BugButton.Text = "On Cooldown"
		wait(1)
		BugButton.Text = "Send Bug Report"
	end
	
	CanButton = true
end)


-- QUEST SYSTEM
QuestBars = QuestInfoFrame:WaitForChild("BG")
OngoingQuests = {}
OngoingQuestsIDs = {}

AcceptButtonPositions = {
    Left = UDim2.new(0.203, 0, 0.875, 0),
    Center = UDim2.new(0.377, 0, 0.875, 0)
}

function FindViewIndexFromID(QuestID)
    for Index,ID in pairs(OngoingQuestsIDs) do
        if ID == QuestID then
            return Index
        end
    end
end

function UpdateQuestView(QuestID)
    local QuestData = OngoingQuests[QuestID]

    if QuestData then
        local Fraction = QuestData.Completed/QuestData.NeedToComplete
        TS:Create(QuestInfoFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, -0.1, 0)}):Play()
        TS:Create(QuestBars.ProgressBar.Progress, TweenInfo.new(0.5), {Size = UDim2.new(Fraction, 0, 1, 0)}):Play()
        
        QuestInfoFrame.CompleteOutOfTotal.Text = QuestData.Completed.."/"..QuestData.NeedToComplete
        QuestInfoFrame.PercentageComplete.Text = tostring(math.floor(Fraction*100)).."% Done"
        QuestInfoFrame.QuestDescription.Text = string.upper("Kill "..QuestData.NeedToComplete.." "..QuestData.ReadableName)
        QuestInfoFrame.QuestName.Text = "Kill Order"
        QuestInfoFrame.QuestRewards.Text = QuestData.Rewards.." XP".." + "..QuestData.Rewards.." YEN"

        if #OngoingQuestsIDs > 1 then
            local Index = FindViewIndexFromID(QuestID)
            local Connection
            if Index == 2 then
                QuestBars.Left.Visible = true
                QuestBars.Right.Visible = false
                
                Connection = QuestBars.Left.Activated:Connect(function()
                    UpdateQuestView(OngoingQuestsIDs[1])
                    Connection:Disconnect()
                end)
            elseif Index == 1 then
                QuestBars.Left.Visible = false
                QuestBars.Right.Visible = true

                Connection = QuestBars.Right.Activated:Connect(function()
                    UpdateQuestView(OngoingQuestsIDs[2])
                    Connection:Disconnect()
                end)
            end
        else
            QuestBars.Left.Visible = false
            QuestBars.Right.Visible = false
        end
    else
        if #OngoingQuestsIDs > 0 then
            UpdateQuestView(OngoingQuestsIDs[1])
        else
            TS:Create(QuestInfoFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Position = UDim2.new(0, 0, 0.2, 0)}):Play()
        end
    end
end

GeneralEvents.QuestProgression.OnClientEvent:Connect(function(State, Data)
    if State == "Start" then
        if #OngoingQuestsIDs >= 2 then return end -- redundancy checking

        local Connection, Connection2
        QuestFrame.QuestName.Text = "Kill Order"
        QuestFrame.QuestDescription.Text = string.upper("Kill "..Data.NeedToComplete.." "..Data.ReadableName)
        QuestFrame.Container.EXPReward.Text = Data.Rewards.." EXP"
        QuestFrame.Container.YenReward.Text = Data.Rewards.." Yen"
        QuestFrame.AcceptButton.Position = AcceptButtonPositions.Left
        QuestFrame.DeclineButton.Visible = true
        QuestFrame.Visible = true

        Connection = QuestFrame.AcceptButton.Activated:Connect(function()
            OngoingQuests[Data.QuestID] = Data
            table.insert(OngoingQuestsIDs, Data.QuestID)
            UpdateQuestView(Data.QuestID)

            Startup.DoneAccepting:Fire()
            QuestFrame.Visible = false

            Connection:Disconnect()
        end)

        Connection2 = QuestFrame.DeclineButton.Activated:Connect(function()
            GeneralEvents.QuestProgression:FireServer("Cancel", {QuestID = Data.QuestID})
            QuestFrame.Visible = false
            Startup.DoneAccepting:Fire()
            Connection2:Disconnect()
        end)
    elseif State == "Progress" then
        OngoingQuests[Data.QuestID].Completed = Data.Completed
        UpdateQuestView(Data.QuestID)
    elseif State == "Complete" then
        local QuestInfo = OngoingQuests[Data.QuestID]
        local Connection

        QuestFrame.Visible = true
        QuestFrame.QuestName.Text = "Quest Complete"
        QuestFrame.QuestDescription.Text = string.upper("Kill "..QuestInfo.NeedToComplete.." "..QuestInfo.ReadableName)
        QuestFrame.Container.EXPReward.Text = QuestInfo.Rewards.." EXP"
        QuestFrame.Container.YenReward.Text = QuestInfo.Rewards.." Yen"
        QuestFrame.DeclineButton.Visible = false
        QuestFrame.AcceptButton.Position = AcceptButtonPositions.Center

        Connection = QuestFrame.AcceptButton.Activated:Connect(function()
            QuestFrame.Visible = false
            Connection:Disconnect()
        end)

        -- Remove info so that nothing updates anymore
        OngoingQuests[Data.QuestID] = nil
        for Index,ID in pairs(OngoingQuestsIDs) do
            if ID == Data.QuestID then
                table.remove(OngoingQuestsIDs, Index)
                break
            end
        end

        UpdateQuestView(Data.QuestID)
    end
end)