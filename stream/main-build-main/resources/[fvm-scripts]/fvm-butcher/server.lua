RegisterServerEvent('fvm-butcher:chicken')
AddEventHandler('fvm-butcher:chicken', function(itemname)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local chicken = Player.Functions.GetItemByName("alive_chicken")
    if Player.Functions.AddItem("alive_chicken", Config.ChickensToCatch) then
        TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["alive_chicken"], "add")
    else
        TriggerClientEvent('FvMain:Notify', src, 'You can\'t carry any more..', 'error')
    end   
end)

RegisterServerEvent('fvm-butcher:slaughter')
AddEventHandler('fvm-butcher:slaughter', function(src) 
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local alive_chicken = Player.Functions.GetItemByName('alive_chicken')
    if alive_chicken ~= nil and alive_chicken.amount > 0 then
        Player.Functions.RemoveItem('alive_chicken', 1)----change this
		Player.Functions.AddItem('slaughtered_chicken', Config.HowManySlaughteredYouGet)-----change this
        TriggerClientEvent("inventory:client:ItemBox", source, FvMain.Shared.Items['alive_chicken'], "remove")
		TriggerClientEvent("inventory:client:ItemBox", source, FvMain.Shared.Items['slaughtered_chicken'], "add")
        TriggerClientEvent('FvMain:Notify', src, "Chicken slaughtered.")
    else
        TriggerClientEvent('FvMain:Notify', src, "No chicken to cut.")
    end
end)

RegisterNetEvent("fvm-butcher:packing")
AddEventHandler("fvm-butcher:packing", function(item, count)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local slaughtered_chicken = Player.Functions.GetItemByName("slaughtered_chicken")
    
    if slaughtered_chicken ~= nil and slaughtered_chicken.amount >= Config.RequiredForPacking then
        Player.Functions.RemoveItem('slaughtered_chicken', Config.RequiredForPacking)
		Player.Functions.AddItem('packaged_chicken', Config.HowManyPackagesYouGet)
        TriggerClientEvent("inventory:client:ItemBox", source, FvMain.Shared.Items['slaughtered_chicken'], "remove")
		TriggerClientEvent("inventory:client:ItemBox", source, FvMain.Shared.Items['packaged_chicken'], "add")
        TriggerClientEvent('FvMain:Notify', src, "Chickens packed.")
    else
        TriggerClientEvent('FvMain:Notify', src, "Not enough chickens to pack.")
    end
end)

RegisterServerEvent("fvm-butcher:sell")
AddEventHandler("fvm-butcher:sell", function()
    local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	local price = 0
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if Player.PlayerData.items[k].name == "packaged_chicken" then 
                    price = price + (Config.ItemsForSale["packaged_chicken"]["price"] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem("packaged_chicken", Player.PlayerData.items[k].amount, k)
                else
                    TriggerClientEvent('FvMain:Notify', src, "You don\'t have packages to sell.")
                end
            end
        end
        Player.Functions.AddMoney("cash", price, "chicken-packages")
		TriggerClientEvent('FvMain:Notify', src, "You sold your packages.")
	end
end)
