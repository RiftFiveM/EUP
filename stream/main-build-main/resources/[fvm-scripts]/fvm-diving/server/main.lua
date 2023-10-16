RegisterServerEvent('fvm-diving:server:SetBerthVehicle')
AddEventHandler('fvm-diving:server:SetBerthVehicle', function(BerthId, vehicleModel)
    TriggerClientEvent('fvm-diving:client:SetBerthVehicle', -1, BerthId, vehicleModel)
    
    FVMBoatshop.Locations["berths"][BerthId]["boatModel"] = boatModel
end)

RegisterServerEvent('fvm-diving:server:SetDockInUse')
AddEventHandler('fvm-diving:server:SetDockInUse', function(BerthId, InUse)
    FVMBoatshop.Locations["berths"][BerthId]["inUse"] = InUse
    TriggerClientEvent('fvm-diving:client:SetDockInUse', -1, BerthId, InUse)
end)

FvMain.Functions.CreateCallback('fvm-diving:server:GetBusyDocks', function(source, cb)
    cb(FVMBoatshop.Locations["berths"])
end)

RegisterServerEvent('fvm-diving:server:BuyBoat')
AddEventHandler('fvm-diving:server:BuyBoat', function(boatModel, BerthId)
    local BoatPrice = FVMBoatshop.ShopBoats[boatModel]["price"]
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local PlayerMoney = {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank,
    }
    local missingMoney = 0
    local plate = "LUAL"..math.random(1111, 9999)

    if PlayerMoney.cash >= BoatPrice then
        Player.Functions.RemoveMoney('cash', BoatPrice, "bought-boat")
        TriggerClientEvent('fvm-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    elseif PlayerMoney.bank >= BoatPrice then
        Player.Functions.RemoveMoney('bank', BoatPrice, "bought-boat")
        TriggerClientEvent('fvm-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    else
        if PlayerMoney.bank > PlayerMoney.cash then
            missingMoney = (BoatPrice - PlayerMoney.bank)
        else
            missingMoney = (BoatPrice - PlayerMoney.cash)
        end
        TriggerClientEvent('FvMain:Notify', src, 'You don\'t have enough money, you are missing $'..missingMoney, 'error', 4000)
    end
end)

function InsertBoat(boatModel, Player, plate)
    FvMain.Functions.ExecuteSql(false, "INSERT INTO `player_boats` (`citizenid`, `model`, `plate`) VALUES ('"..Player.PlayerData.citizenid.."', '"..boatModel.."', '"..plate.."')")
end

FvMain.Functions.CreateUseableItem("jerry_can", function(source, item)
    local Player = FvMain.Functions.GetPlayer(source)

    TriggerClientEvent("fvm-diving:client:UseJerrycan", source)
end)

FvMain.Functions.CreateUseableItem("diving_gear", function(source, item)
    local Player = FvMain.Functions.GetPlayer(source)

    TriggerClientEvent("fvm-diving:client:UseGear", source, true)
end)

RegisterServerEvent('fvm-diving:server:RemoveItem')
AddEventHandler('fvm-diving:server:RemoveItem', function(item, amount)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)
end)

FvMain.Functions.CreateCallback('fvm-diving:server:GetMyBoats', function(source, cb, dock)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `boathouse` = '"..dock.."'", function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

FvMain.Functions.CreateCallback('fvm-diving:server:GetDepotBoats', function(source, cb, dock)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `state` = '0'", function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('fvm-diving:server:SetBoatState')
AddEventHandler('fvm-diving:server:SetBoatState', function(plate, state, boathouse)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            FvMain.Functions.ExecuteSql(false, "UPDATE `player_boats` SET `state` = '"..state.."' WHERE `plate` = '"..plate.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
    
            if state == 1 then
                FvMain.Functions.ExecuteSql(false, "UPDATE `player_boats` SET `boathouse` = '"..boathouse.."' WHERE `plate` = '"..plate.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
            end
        end
    end)
end)

RegisterServerEvent('fvm-diving:server:CallCops')
AddEventHandler('fvm-diving:server:CallCops', function(Coords)
    local src = source
    for k, v in pairs(FvMain.Functions.GetPlayers()) do
        local Player = FvMain.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                local msg = "someone is stealing coral!"
                TriggerClientEvent('fvm-diving:client:CallCops', Player.PlayerData.source, Coords, msg)
                local alertData = {
                    title = "Illegal diving",
                    coords = {x = Coords.x, y = Coords.y, z = Coords.z},
                    description = msg,
                }
                TriggerClientEvent("fvm-phone:client:addPoliceAlert", -1, alertData)
            end
        end
	end
end)

local AvailableCoral = {}

FvMain.Commands.Add("wetsuit", "Pull your wetsuit off", {}, false, function(source, args)
    local Player = FvMain.Functions.GetPlayer(source)
    TriggerClientEvent("fvm-diving:client:UseGear", source, false)
end)

RegisterServerEvent('fvm-diving:server:SellCoral')
AddEventHandler('fvm-diving:server:SellCoral', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    if HasCoral(src) then
        for k, v in pairs(AvailableCoral) do
            local Item = Player.Functions.GetItemByName(v.item)
            local price = (Item.amount * v.price)
            local Reward = math.ceil(GetItemPrice(Item, price))

            if Item.amount > 1 then
                for i = 1, Item.amount, 1 do
                    Player.Functions.RemoveItem(Item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items[Item.name], "remove")
                    Player.Functions.AddMoney('cash', math.ceil((Reward / Item.amount)), "sold-coral")
                    Citizen.Wait(250)
                end
            else
                Player.Functions.RemoveItem(Item.name, 1)
                Player.Functions.AddMoney('cash', Reward, "sold-coral")
                TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items[Item.name], "remove")
            end
        end
    else
        TriggerClientEvent('FvMain:Notify', src, 'You don\'t have any coral to sell..', 'error')
    end
end)

function GetItemPrice(Item, price)
    if Item.amount > 5 then
        price = price / 100 * 80
    elseif Item.amount > 10 then
        price = price / 100 * 70
    elseif Item.amount > 15 then
        price = price / 100 * 50
    end
    return price
end

function HasCoral(src)
    local Player = FvMain.Functions.GetPlayer(src)
    local retval = false
    AvailableCoral = {}

    for k, v in pairs(FVMDiving.CoralTypes) do
        local Item = Player.Functions.GetItemByName(v.item)
        if Item ~= nil then
            table.insert(AvailableCoral, v)
            retval = true
        end
    end
    return retval
end