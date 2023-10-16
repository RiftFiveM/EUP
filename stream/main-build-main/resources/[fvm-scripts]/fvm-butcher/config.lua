
Config = {}
Config.ChickensToCatch = math.random(1, 2) -- how many chickens you get after catching
Config.HowManySlaughteredYouGet = 4 -- after slaughtering chicken you get 4 slaugtered chickens
Config.RequiredForPacking = 4 -- how many slaugtered chickens required for packing
Config.HowManyPackagesYouGet = 1 -- how many packages you get
Config.ItemsForSale = {
    ["packaged_chicken"] = {
        ["price"] = math.random(70, 120)
    },
}

Config.Chickens = { -- Locations where you Catch Chickens
	vector3(-62.78, 6241.76, 31.09),
    --vector3(-62.78, 6241.76, 31.09),
}

Config.Locations = {
    ["butcher"] = { -- cut chickens
        label = "Butcher",
        coords = {x = -96.007, y = 6206.92, z = 31.02, h = 318.07},
    },
    ["packing"] = { 
        label = "Chicken packing",
        coords = {x = -101.9, y = 6208.54, z = 31.10, h = 235.17},
    },
    ["sell"] = {
        label = "Chicken selling",
        coords = {x = -592.68, y = -881.78, z = 25.92, h = 89.92},
    },
}

Config.NPCEnable = true --To Enable NPC at Locations
Config.NPC = {
    { x = -77.88, y = 6229.09, z = 30.20, h = 302.73 , npc = 233415434},             -----Butcher
    { x = -101.9, y = 6208.54, z = 30.10, h = 235.17, npc = 233415434},              -----Packer of Chicken
    { x = -592.68, y = -881.78, z = 24.92, h = 89.92, npc = 233415434},              -----Buyer of Chicken Fillets

}
