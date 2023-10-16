local EventActive = false
local FrozenVeh = nil

RegisterNetEvent('fvm-event:client:EventMovie')
AddEventHandler('fvm-event:client:EventMovie', function()
    if not EventActive then
        SetNuiFocus(true, false)
        SendNUIMessage({
            action = "enable"
        })

        if IsPedInAnyVehicle(PlayerPedId()) then
            FrozenVeh = GetVehiclePedIsIn(PlayerPedId())
            FreezeEntityPosition(FrozenVeh, true)
        end
        EventActive = true
    end
end)

RegisterNUICallback('CloseEvent', function(data, cb)
    SetNuiFocus(false, false)
    EventActive = false
    FreezeEntityPosition(FrozenVeh, false)
    FrozenVeh = nil
end)