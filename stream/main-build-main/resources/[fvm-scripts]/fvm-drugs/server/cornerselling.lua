FvMain.Functions.CreateCallback('fvm-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    local AvailableDrugs = {}
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = FvMain.Shared.Items[item.name]["label"]
            })
        end
    end

    if next(AvailableDrugs) ~= nil then
        cb(AvailableDrugs)
    else
        cb(nil)
    end
end)

RegisterServerEvent('fvm-drugs:server:sellCornerDrugs')
AddEventHandler('fvm-drugs:server:sellCornerDrugs', function(item, amount, price)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)

    if Config.ReceiveMarkedBills then
        Player.Functions.AddItem('markedbills', price)
    else
        Player.Functions.AddMoney('cash', price, "sold-cornerdrugs")
    end

    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items[item], "remove")

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = FvMain.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('fvm-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)

RegisterServerEvent('fvm-drugs:server:robCornerDrugs')
AddEventHandler('fvm-drugs:server:robCornerDrugs', function(item, amount, price)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)

    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items[item], "remove")

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = FvMain.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('fvm-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)