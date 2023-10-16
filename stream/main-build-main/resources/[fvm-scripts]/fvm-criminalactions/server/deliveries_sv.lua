RegisterServerEvent('fvm-weapondealer:server:updateDealerItems')
AddEventHandler('fvm-weapondealer:server:updateDealerItems', function(itemData, amount, dealer)
    WP.Dealers[dealer]["products"][itemData.slot].amount = WP.Dealers[dealer]["products"][itemData.slot].amount - amount
    TriggerClientEvent('fvm-weapondealer:client:setDealerItems', -1, itemData, amount, dealer)
end)

RegisterServerEvent('fvm-weapondealer:server:giveDeliveryItems')
AddEventHandler('fvm-weapondealer:server:giveDeliveryItems', function()
    FvMain.Functions.BanInjection(source, 'fvm-weapondealer (giveDeliveryItems)')
end)

FvMain.Functions.CreateCallback('fvm-weapondealer:giveDeliveryItems', function(source, cb, amount)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    Player.Functions.AddItem('explosive', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["explosive"], "add")
end)

FvMain.Functions.CreateCallback('fvm-weapondealer:server:RequestConfig', function(source, cb)
    cb(WP.Dealers)
end)

RegisterServerEvent('fvm-weapondealer:server:succesDelivery')
AddEventHandler('fvm-weapondealer:server:succesDelivery', function(deliveryData, inTime)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local curRep = Player.PlayerData.metadata["wepdealerrep"]

    if inTime then
        if Player.Functions.GetItemByName('explosive') ~= nil and Player.Functions.GetItemByName('explosive').amount >= deliveryData["amount"] then
            Player.Functions.RemoveItem('explosive', deliveryData["amount"])
            local cops = GetCurrentCops()
            local price = 3000
            if cops == 1 then
                price = 4000
            elseif cops == 2 then
                price = 5000
            elseif cops >= 3 then
                price = 6000
            end
            if curRep < 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 8), "dilvery-guns")
            elseif curRep >= 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 10), "dilvery-guns")
            elseif curRep >= 20 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 12), "dilvery-guns")
            elseif curRep >= 30 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 15), "dilvery-guns")
            elseif curRep >= 40 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 18), "dilvery-guns")
            end

            TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["explosive"], "remove")
            TriggerClientEvent('FvMain:Notify', src, 'The order has been delivered complete', 'success')
            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('fvm-weapondealer:client:sendDeliveryMail', src, 'perfect', deliveryData)
                Player.Functions.SetMetaData('wepdealerrep', (curRep + 1))
            end)
        else
            TriggerClientEvent('FvMain:Notify', src, 'This does not match the order...', 'error')
            if Player.Functions.GetItemByName('explosive').amount >= 0 then
                Player.Functions.RemoveItem('explosive', Player.Functions.GetItemByName('explosive').amount)
                Player.Functions.AddMoney('cash', (Player.Functions.GetItemByName('explosive').amount * 6000 / 100 * 5))
            end
            TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["explosive"], "remove")
            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('fvm-weapondealer:client:sendDeliveryMail', src, 'bad', deliveryData)
                if curRep - 1 > 0 then
                    Player.Functions.SetMetaData('wepdealerrep', (curRep - 1))
                else
                    Player.Functions.SetMetaData('wepdealerrep', 0)
                end
            end)
        end
    else
        TriggerClientEvent('FvMain:Notify', src, 'You are too late...', 'error')
        Player.Functions.RemoveItem('explosive', deliveryData["amount"])
        Player.Functions.AddMoney('cash', (deliveryData["amount"] * 6000 / 100 * 4), "dilvery-guns-too-late")
        TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["explosive"], "remove")
        SetTimeout(math.random(5000, 10000), function()
            TriggerClientEvent('fvm-weapondealer:client:sendDeliveryMail', src, 'late', deliveryData)
            if curRep - 1 > 0 then
                Player.Functions.SetMetaData('wepdealerrep', (curRep - 1))
            else
                Player.Functions.SetMetaData('wepdealerrep', 0)
            end
        end)
    end
end)

RegisterServerEvent('fvm-methlab:givekey')
AddEventHandler('fvm-methlab:givekey', function()
    local xPlayer = FvMain.Functions.GetPlayer(source)
    xPlayer.Functions.AddItem("labkey", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, FvMain.Shared.Items['labkey'], "add")
end)

function GetCurrentCops()
    local amount = 0
    for k, v in pairs(FvMain.Functions.GetPlayers()) do
        local Player = FvMain.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "sheriff") and Player.PlayerData.job.onduty then
                amount = amount + 1
            end
        end
    end
    return amount
end