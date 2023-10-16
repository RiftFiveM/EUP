local CurrentDock = nil
local ClosestDock = nil
local PoliceBlip = nil

RegisterNetEvent('FvMain:Client:OnJobUpdate')
AddEventHandler('FvMain:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    if PlayerJob.name == "police" or PlayerJob.name == "sheriff" then
        if PoliceBlip ~= nil then
            RemoveBlip(PoliceBlip)
        end
        PoliceBlip = AddBlipForCoord(FVMBoatshop.PoliceBoat.x, FVMBoatshop.PoliceBoat.y, FVMBoatshop.PoliceBoat.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police Boats")
        EndTextCommandSetBlipName(PoliceBlip)
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(3)
        if isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            if PlayerJob.name == "police" or PlayerJob.name == "sheriff" then
                local dist = #(pos - vector3(FVMBoatshop.PoliceBoat.x, FVMBoatshop.PoliceBoat.y, FVMBoatshop.PoliceBoat.z))
                if dist < 10 then
                    DrawMarker(2, FVMBoatshop.PoliceBoat.x, FVMBoatshop.PoliceBoat.y, FVMBoatshop.PoliceBoat.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                    if dist < 1.5 then
                        FvMain.Functions.DrawText3D(FVMBoatshop.PoliceBoat.x, FVMBoatshop.PoliceBoat.y, FVMBoatshop.PoliceBoat.z, "~g~E~w~ - Take a boat")
                        if IsControlJustReleased(0, Keys["E"]) then
                            local coords = FVMBoatshop.PoliceBoatSpawn
                            FvMain.Functions.SpawnVehicle("predator", function(veh)
                                SetVehicleNumberPlateText(veh, "PBOA"..tostring(math.random(1000, 9999)))
                                SetEntityHeading(veh, coords.w)
                                exports['LegacyFuel']:SetFuel(veh, 100.0)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                SetVehicleEngineOn(veh, true, true)
                            end, coords, true)
                        end
                    end
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(3000)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(3)
        if isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            if PlayerJob.name == "police" or PlayerJob.name == "sheriff" then
                local dist = #(pos - vector3(FVMBoatshop.PoliceBoat2.x, FVMBoatshop.PoliceBoat2.y, FVMBoatshop.PoliceBoat2.z))
                if dist < 10 then
                    DrawMarker(2, FVMBoatshop.PoliceBoat2.x, FVMBoatshop.PoliceBoat2.y, FVMBoatshop.PoliceBoat2.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                    if dist < 1.5 then
                        FvMain.Functions.DrawText3D(FVMBoatshop.PoliceBoat2.x, FVMBoatshop.PoliceBoat2.y, FVMBoatshop.PoliceBoat2.z, "~g~E~w~ - Take a boat")
                        if IsControlJustReleased(0, Keys["E"]) then
                            local coords = FVMBoatshop.PoliceBoatSpawn2
                            FvMain.Functions.SpawnVehicle("predator", function(veh)
                                SetVehicleNumberPlateText(veh, "PBOA"..tostring(math.random(1000, 9999)))
                                SetEntityHeading(veh, coords.w)
                                exports['LegacyFuel']:SetFuel(veh, 100.0)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                SetVehicleEngineOn(veh, true, true)
                            end, coords, true)
                        end
                    end
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(3000)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do

        local inRange = false
        local Ped = PlayerPedId()
        local Pos = GetEntityCoords(Ped)

        for k, v in pairs(FVMBoatshop.Docks) do
            local TakeDistance = #(Pos - vector3(v.coords.take.x, v.coords.take.y, v.coords.take.z))

            if TakeDistance < 50 then
                ClosestDock = k
                inRange = true
                PutDistance = #(Pos - vector3(v.coords.put.x, v.coords.put.y, v.coords.put.z))

                local inBoat = IsPedInAnyBoat(Ped)

                if inBoat then
                    DrawMarker(35, v.coords.put.x, v.coords.put.y, v.coords.put.z + 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.7, 1.7, 1.7, 255, 55, 15, 255, false, false, false, true, false, false, false)
                    if PutDistance < 2 then
                        if inBoat then
                            DrawText3D(v.coords.put.x, v.coords.put.y, v.coords.put.z, '~g~E~w~ - Push the boat away')
                            if IsControlJustPressed(0, Keys["E"]) then
                                RemoveVehicle()
                            end
                        end
                    end
                end

                if not inBoat then
                    DrawMarker(2, v.coords.take.x, v.coords.take.y, v.coords.take.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.5, -0.30, 15, 255, 55, 255, false, false, false, true, false, false, false)
                    if TakeDistance < 2 then
                        DrawText3D(v.coords.take.x, v.coords.take.y, v.coords.take.z, '~g~E~w~ - Take a boat')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            CloseMenu()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            CurrentDock = nil
                        elseif IsControlJustPressed(0, Keys["E"]) and Menu.hidden then
                            MenuGarage()
                            Menu.hidden = not Menu.hidden
                            CurrentDock = k
                        end
                        Menu.renderGUI()
                    end
                end
            elseif TakeDistance > 51 then
                if ClosestDock ~= nil then
                    ClosestDock = nil
                end
            end
        end

        for k, v in pairs(FVMBoatshop.Depots) do
            local TakeDistance = #(Pos - vector3(v.coords.take.x, v.coords.take.y, v.coords.take.z))

            if TakeDistance < 50 then
                ClosestDock = k
                inRange = true
                PutDistance = #(Pos - vector3(v.coords.put.x, v.coords.put.y, v.coords.put.z))

                local inBoat = IsPedInAnyBoat(Ped)

                if not inBoat then
                    DrawMarker(2, v.coords.take.x, v.coords.take.y, v.coords.take.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.5, -0.30, 15, 255, 55, 255, false, false, false, true, false, false, false)
                    if TakeDistance < 2 then
                        DrawText3D(v.coords.take.x, v.coords.take.y, v.coords.take.z, '~g~E~w~ - Boat storage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            CloseMenu()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            CurrentDock = nil
                        elseif IsControlJustPressed(0, Keys["E"]) and Menu.hidden then
                            MenuBoatDepot()
                            Menu.hidden = not Menu.hidden
                            CurrentDock = k
                        end
                        Menu.renderGUI()
                    end
                end
            elseif TakeDistance > 51 then
                if ClosestDock ~= nil then
                    ClosestDock = nil
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(4)
    end
end)

function RemoveVehicle()
    local ped = PlayerPedId()
    local Boat = IsPedInAnyBoat(ped)

    if Boat then
        local CurVeh = GetVehiclePedIsIn(ped)

        TriggerServerEvent('fvm-diving:server:SetBoatState', GetVehicleNumberPlateText(CurVeh), 1, ClosestDock)

        FvMain.Functions.DeleteVehicle(CurVeh)
        SetEntityCoords(ped, FVMBoatshop.Docks[ClosestDock].coords.take.x, FVMBoatshop.Docks[ClosestDock].coords.take.y, FVMBoatshop.Docks[ClosestDock].coords.take.z)
    end
end

Citizen.CreateThread(function()
    for k, v in pairs(FVMBoatshop.Docks) do
        DockGarage = AddBlipForCoord(v.coords.put.x, v.coords.put.y, v.coords.put.z)

        SetBlipSprite (DockGarage, 410)
        SetBlipDisplay(DockGarage, 4)
        SetBlipScale  (DockGarage, 0.8)
        SetBlipAsShortRange(DockGarage, true)
        SetBlipColour(DockGarage, 3)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.label)
        EndTextCommandSetBlipName(DockGarage)
    end

    for k, v in pairs(FVMBoatshop.Depots) do
        BoatDepot = AddBlipForCoord(v.coords.take.x, v.coords.take.y, v.coords.take.z)

        SetBlipSprite (BoatDepot, 410)
        SetBlipDisplay(BoatDepot, 4)
        SetBlipScale  (BoatDepot, 0.8)
        SetBlipAsShortRange(BoatDepot, true)
        SetBlipColour(BoatDepot, 3)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.label)
        EndTextCommandSetBlipName(BoatDepot)
    end
end)

-- MENU JAAAAAAAAAAAAAA

function MenuBoatDepot()
    ClearMenu()
    FvMain.Functions.TriggerCallback("fvm-diving:server:GetDepotBoats", function(result)
        ped = PlayerPedId();
        MenuTitle = "My Boats :"

        if result == nil then
            FvMain.Functions.Notify("You dont have a boat in this depot", "error", 5000)
            CloseMenu()
        else
            Menu.addButton(FVMBoatshop.Depots[CurrentDock].label, "yeet", FVMBoatshop.Depots[CurrentDock].label)

            for k, v in pairs(result) do
                currentFuel = v.fuel
                state = "Boat house"
                if v.state == 0 then
                    state = "Storage"
                end

                Menu.addButton(FVMBoatshop.ShopBoats[v.model]["label"], "TakeOutDepotBoat", v, state, "Fuel: "..currentFuel.. "%")
            end
        end
            
        Menu.addButton("Back", "MenuGarage", nil)
    end)
end

function BoatList()
    ClearMenu()
    FvMain.Functions.TriggerCallback("fvm-diving:server:GetMyBoats", function(result)
        ped = PlayerPedId();
        MenuTitle = "My Boats :"

        if result == nil then
            FvMain.Functions.Notify("You dont have any boats here.", "error", 5000)
            CloseMenu()
        else
            Menu.addButton(FVMBoatshop.Docks[CurrentDock].label, "yeet", FVMBoatshop.Docks[CurrentDock].label)

            for k, v in pairs(result) do
                currentFuel = v.fuel
                state = "Boat house"
                if v.state == 0 then
                    state = "Out"
                end

                Menu.addButton(FVMBoatshop.ShopBoats[v.model]["label"], "TakeOutVehicle", v, state, "Fuel: "..currentFuel.. "%")
            end
        end
            
        Menu.addButton("Back", "MenuGarage", nil)
    end, CurrentDock)
end

function TakeOutVehicle(vehicle)
    if vehicle.state == 1 then
        FvMain.Functions.SpawnVehicle(vehicle.model, function(veh)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, FVMBoatshop.Docks[CurrentDock].coords.put.w)
            exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
            FvMain.Functions.Notify("Boat is out with fuel: "..currentFuel.. "%", "primary", 4500)
            CloseMenu()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
            SetVehicleEngineOn(veh, true, true)
            TriggerServerEvent('fvm-diving:server:SetBoatState', GetVehicleNumberPlateText(veh), 0, CurrentDock)
        end, FVMBoatshop.Docks[CurrentDock].coords.put, true)
    else
        FvMain.Functions.Notify("The boat is not in the boat house...", "error", 4500)
    end
end

function TakeOutDepotBoat(vehicle)
    FvMain.Functions.SpawnVehicle(vehicle.model, function(veh)
        SetVehicleNumberPlateText(veh, vehicle.plate)
        SetEntityHeading(veh, FVMBoatshop.Depots[CurrentDock].coords.put.w)
        exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
        FvMain.Functions.Notify("Boat is out of garage with fuel: "..currentFuel.. "%", "primary", 4500)
        CloseMenu()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, FVMBoatshop.Depots[CurrentDock].coords.put, true)
end

function MenuGarage()
    ClearMenu()
    ped = PlayerPedId();
    MenuTitle = "Garage"
    Menu.addButton("My Boats", "BoatList", nil)
    Menu.addButton("Close Menu", "CloseMenu", nil) 
end

function CloseMenu()
    Menu.hidden = true
    ClearMenu()
end

function ClearMenu()
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end