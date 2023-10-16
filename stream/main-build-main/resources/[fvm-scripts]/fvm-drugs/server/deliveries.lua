RegisterServerEvent('fvm-drugs:server:updateDealerItems')
AddEventHandler('fvm-drugs:server:updateDealerItems', function(itemData, amount, dealer)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    if Config.Dealers[dealer]["products"][itemData.slot].amount - 1 >= 0 then
        Config.Dealers[dealer]["products"][itemData.slot].amount = Config.Dealers[dealer]["products"][itemData.slot].amount - amount
        TriggerClientEvent('fvm-drugs:client:setDealerItems', -1, itemData, amount, dealer)
    else
        Player.Functions.RemoveItem(itemData.name, amount)
        Player.Functions.AddMoney('cash', amount * Config.Dealers[dealer]["products"][itemData.slot].price)

        TriggerClientEvent("FvMain:Notify", _src, "This item is not available.. You've got an refund.", "error")
    end
end)

RegisterServerEvent('fvm-drugs:server:giveDeliveryItems')
AddEventHandler('fvm-drugs:server:giveDeliveryItems', function(amount)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    Player.Functions.AddItem('weed_brick', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["weed_brick"], "add")
end)

FvMain.Functions.CreateCallback('fvm-drugs:server:RequestConfig', function(source, cb)
    cb(Config.Dealers)
end)

RegisterServerEvent('fvm-drugs:server:succesDelivery')
AddEventHandler('fvm-drugs:server:succesDelivery', function(deliveryData, inTime)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local curRep = Player.PlayerData.metadata["dealerrep"]

    if inTime then
        if Player.Functions.GetItemByName('weed_brick') ~= nil and Player.Functions.GetItemByName('weed_brick').amount >= deliveryData["amount"] then
            Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
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
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 8), "dilvery-drugs")
            elseif curRep >= 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 10), "dilvery-drugs")
            elseif curRep >= 20 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 12), "dilvery-drugs")
            elseif curRep >= 30 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 15), "dilvery-drugs")
            elseif curRep >= 40 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 18), "dilvery-drugs")
            end

            TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["weed_brick"], "remove")
            TriggerClientEvent('FvMain:Notify', src, 'The order has been delivered completely', 'success')

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('fvm-drugs:client:sendDeliveryMail', src, 'perfect', deliveryData)

                Player.Functions.SetMetaData('dealerrep', (curRep + 1))
            end)
        else
            TriggerClientEvent('FvMain:Notify', src, 'This doesn\'t meet the order...', 'error')

            if Player.Functions.GetItemByName('weed_brick').amount >= 0 then
                Player.Functions.RemoveItem('weed_brick', Player.Functions.GetItemByName('weed_brick').amount)
                Player.Functions.AddMoney('cash', (Player.Functions.GetItemByName('weed_brick').amount * 6000 / 100 * 5))
            end

            TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["weed_brick"], "remove")

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('fvm-drugs:client:sendDeliveryMail', src, 'bad', deliveryData)

                if curRep - 1 > 0 then
                    Player.Functions.SetMetaData('dealerrep', (curRep - 1))
                else
                    Player.Functions.SetMetaData('dealerrep', 0)
                end
            end)
        end
    else
        TriggerClientEvent('FvMain:Notify', src, 'You\'re too late...', 'error')

        Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
        Player.Functions.AddMoney('cash', (deliveryData["amount"] * 6000 / 100 * 4), "dilvery-drugs-too-late")

        TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["weed_brick"], "remove")

        SetTimeout(math.random(5000, 10000), function()
            TriggerClientEvent('fvm-drugs:client:sendDeliveryMail', src, 'late', deliveryData)

            if curRep - 1 > 0 then
                Player.Functions.SetMetaData('dealerrep', (curRep - 1))
            else
                Player.Functions.SetMetaData('dealerrep', 0)
            end
        end)
    end
end)

RegisterServerEvent('fvm-drugs:server:callCops')
AddEventHandler('fvm-drugs:server:callCops', function(streetLabel, coords)
    local msg = "A suspicious situation has been located at "..streetLabel..", possibly drug dealing."
    local alertData = {
        title = "Drug Dealing",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = msg
    }
    for k, v in pairs(FvMain.Functions.GetPlayers()) do
        local Player = FvMain.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "sheriff") and Player.PlayerData.job.onduty then
                TriggerClientEvent("fvm-drugs:client:robberyCall", Player.PlayerData.source, msg, streetLabel, coords)
                TriggerClientEvent("fvm-phone:client:addPoliceAlert", Player.PlayerData.source, alertData)
            end
        end
	end
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

FvMain.Commands.Add("placedealer", "Place a dealer", {
    {name = "name", help = "Dealer name"},
    {name = "min", help = "Minimum time"},
    {name = "max", help = "Maximum time"},
}, true, function(source, args)
    local dealerName = args[1]
    local mintime = tonumber(args[2])
    local maxtime = tonumber(args[3])

    TriggerClientEvent('fvm-drugs:client:CreateDealer', source, dealerName, mintime, maxtime)
end, "admin")

FvMain.Commands.Add("removedealer", "Remove a dealer", {
    {name = "name", help = "Dealers name"},
}, true, function(source, args)
    local dealerName = args[1]
    
    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `dealers` WHERE `name` = '"..dealerName.."'", function(result)
        if result[1] ~= nil then
            FvMain.Functions.ExecuteSql(false, "DELETE FROM `dealers` WHERE `name` = '"..dealerName.."'")
            Config.Dealers[dealerName] = nil
            TriggerClientEvent('fvm-drugs:client:RefreshDealers', -1, Config.Dealers)
            TriggerClientEvent('FvMain:Notify', source, "You deleted Dealer "..dealerName.."!", "success")
        else
            TriggerClientEvent('FvMain:Notify', source, "Dealer "..dealerName.." doesn\'t exist..", "error")
        end
    end)
end, "admin")

FvMain.Commands.Add("dealers", "Get an overview of all Dealers", {}, false, function(source, args)
    local DealersText = ""
    if Config.Dealers ~= nil and next(Config.Dealers) ~= nil then
        for k, v in pairs(Config.Dealers) do
            DealersText = DealersText .. "Name: " .. v["name"] .. "<br>"
        end
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>List of all dealers: </strong><br><br> '..DealersText..'</div></div>',
            args = {}
        })
    else
        TriggerClientEvent('FvMain:Notify', source, 'No dealers have been placed.', 'error')
    end
end, "admin")

FvMain.Commands.Add("dealergoto", "Teleport to dealer location", {{name = "name", help = "Dealer name"}}, true, function(source, args)
    local DealerName = tostring(args[1])

    if Config.Dealers[DealerName] ~= nil then
        TriggerClientEvent('fvm-drugs:client:GotoDealer', source, Config.Dealers[DealerName])
    else
        TriggerClientEvent('FvMain:Notify', source, 'This dealer doesn\'t exist.', 'error')
    end
end, "admin")

Citizen.CreateThread(function()
    Wait(500)
    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `dealers`", function(dealers)
        if dealers[1] ~= nil then
            for k, v in pairs(dealers) do
                local coords = json.decode(v.coords)
                local time = json.decode(v.time)

                Config.Dealers[v.name] = {
                    ["name"] = v.name,
                    ["coords"] = {
                        ["x"] = coords.x,
                        ["y"] = coords.y,
                        ["z"] = coords.z,
                    },
                    ["time"] = {
                        ["min"] = time.min,
                        ["max"] = time.max,
                    },
                    ["products"] = Config.Products,
                }
            end
        end
        TriggerClientEvent('fvm-drugs:client:RefreshDealers', -1, Config.Dealers)
    end)
end)

RegisterServerEvent('fvm-drugs:server:CreateDealer')
AddEventHandler('fvm-drugs:server:CreateDealer', function(DealerData)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `dealers` WHERE `name` = '"..DealerData.name.."'", function(result)
        if result[1] ~= nil then
            TriggerClientEvent('FvMain:Notify', src, "A dealer already exists with this name..", "error")
        else
            FvMain.Functions.ExecuteSql(false, "INSERT INTO `dealers` (`name`, `coords`, `time`, `createdby`) VALUES ('"..DealerData.name.."', '"..json.encode(DealerData.pos).."', '"..json.encode(DealerData.time).."', '"..Player.PlayerData.citizenid.."')", function()
                Config.Dealers[DealerData.name] = {
                    ["name"] = DealerData.name,
                    ["coords"] = {
                        ["x"] = DealerData.pos.x,
                        ["y"] = DealerData.pos.y,
                        ["z"] = DealerData.pos.z,
                    },
                    ["time"] = {
                        ["min"] = DealerData.time.min,
                        ["max"] = DealerData.time.max,
                    },
                    ["products"] = Config.Products,
                }

                TriggerClientEvent('fvm-drugs:client:RefreshDealers', -1, Config.Dealers)
            end)
        end
    end)
end)

function GetDealers()
    return Config.Dealers
end