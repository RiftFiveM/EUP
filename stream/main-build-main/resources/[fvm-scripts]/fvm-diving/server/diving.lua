local CurrentDivingArea = math.random(1, #FVMDiving.Locations)

FvMain.Functions.CreateCallback('fvm-diving:server:GetDivingConfig', function(source, cb)
    cb(FVMDiving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('fvm-diving:server:TakeCoral')
AddEventHandler('fvm-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local CoralType = math.random(1, #FVMDiving.CoralTypes)
    local Amount = math.random(1, FVMDiving.CoralTypes[CoralType].maxAmount)
    local ItemData = FvMain.Shared.Items[FVMDiving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (FVMDiving.Locations[Area].TotalCoral - 1) == 0 then
        for k, v in pairs(FVMDiving.Locations[CurrentDivingArea].coords.Coral) do
            v.PickedUp = false
        end
        FVMDiving.Locations[CurrentDivingArea].TotalCoral = FVMDiving.Locations[CurrentDivingArea].DefaultCoral

        local newLocation = math.random(1, #FVMDiving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(3)
            newLocation = math.random(1, #FVMDiving.Locations)
        end
        CurrentDivingArea = newLocation
        
        TriggerClientEvent('fvm-diving:client:NewLocations', -1)
    else
        FVMDiving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
        FVMDiving.Locations[Area].TotalCoral = FVMDiving.Locations[Area].TotalCoral - 1
    end

    TriggerClientEvent('fvm-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('fvm-diving:server:RemoveGear')
AddEventHandler('fvm-diving:server:RemoveGear', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["diving_gear"], "remove")
end)

RegisterServerEvent('fvm-diving:server:GiveBackGear')
AddEventHandler('fvm-diving:server:GiveBackGear', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    
    Player.Functions.AddItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["diving_gear"], "add")
end)