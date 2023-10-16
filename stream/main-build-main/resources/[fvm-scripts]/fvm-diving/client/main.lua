Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

isLoggedIn = false
PlayerJob = {}

RegisterNetEvent("FvMain:Client:OnPlayerLoaded")
AddEventHandler("FvMain:Client:OnPlayerLoaded", function()
    FvMain.Functions.TriggerCallback('fvm-diving:server:GetBusyDocks', function(Docks)
        FVMBoatshop.Locations["berths"] = Docks
    end)

    FvMain.Functions.TriggerCallback('fvm-diving:server:GetDivingConfig', function(Config, Area)
        FVMDiving.Locations = Config
        TriggerEvent('fvm-diving:client:SetDivingLocation', Area)
    end)

    PlayerJob = FvMain.Functions.GetPlayerData().job

    isLoggedIn = true

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
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
        PoliceBlip = AddBlipForCoord(FVMBoatshop.PoliceBoat2.x, FVMBoatshop.PoliceBoat2.y, FVMBoatshop.PoliceBoat2.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
    end
end)

-- Code

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('fvm-diving:client:UseJerrycan')
AddEventHandler('fvm-diving:client:UseJerrycan', function()
    local ped = PlayerPedId()
    local boat = IsPedInAnyBoat(ped)
    local vehicle = FvMain.Functions.GetClosestVehicle()
    
    if boat then
        local curVeh = GetVehiclePedIsIn(ped, false)
        FvMain.Functions.Progressbar("reful_boat", "Fueling boat..", 15000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            exports['LegacyFuel']:SetFuel(curVeh, 100)
            FvMain.Functions.Notify('The boat has been refueled', 'success')
            TriggerServerEvent('fvm-diving:server:RemoveItem', 'jerry_can', 1)
            TriggerEvent('inventory:client:ItemBox', FvMain.Shared.Items['jerry_can'], "remove")
        end, function() -- Cancel
            FvMain.Functions.Notify('Refueling has been canceled!', 'error')
        end)
    elseif vehicle ~= 0 and vehicle ~= nil then
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            LoadAnimDict("timetable@gardener@filling_can")
            TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
            FvMain.Functions.Progressbar("reful_vehicle", "Fueling vehicle..", 15000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                exports['LegacyFuel']:SetFuel(vehicle, 100)
                FvMain.Functions.Notify('The vehicle has been refueled', 'success')
                TriggerServerEvent('fvm-diving:server:RemoveItem', 'jerry_can', 1)
                TriggerEvent('inventory:client:ItemBox', FvMain.Shared.Items['jerry_can'], "remove")
            end, function() -- Cancel
                FvMain.Functions.Notify('Refueling has been canceled!', 'error')
                ClearPedTasks(ped)
            end)
        end
    else
        FvMain.Functions.Notify('You are not in a boat or near to vehicle', 'error')
    end
end)

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end