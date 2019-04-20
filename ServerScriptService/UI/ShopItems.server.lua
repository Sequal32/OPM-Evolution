-- Variables
local rep_storage = game:GetService("ReplicatedStorage")
local ui_data = rep_storage:WaitForChild("UI_Data")
local ui_remotes = ui_data:WaitForChild("UI_Shop_Remotes")

ShopItems = {
	YenItems = {
		{
			ProductId = 516132571
		},
		{
			ProductId = 516154938
		},
		{
			ProductId = 516155030
		},
		{
			ProductId = 516155318
		},
		{
			ProductId = 516155440
		},
		{
			ProductId = 516155550
		},
		{
			ProductId = 516155697
		},
	},
	ClassItems = {
		{
			Name = "Cyborg",
			ImageUrl = nil,
			Yen = nil,
			Robux = nil
		},
		{
			Name = "Ninja",
			ImageUrl = nil,
			Yen = nil,
			Robux = nil
		},
		{
			Name = "SuperHuman",
			ImageUrl = nil,
			Yen = nil,
			Robux = nil
		}
	}
}

_G.YenProductIds = {
	["516132571"] = 1250,
	["516154938"] = 2500,
	["516155030"] = 5000,
	["516155318"] = 10000,
	["516155440"] = 25000,
	["516155550"] = 50000,
	["516155697"] = 100000
}

function ui_remotes.ReturnShopItems.OnServerInvoke()
	return ShopItems
end

