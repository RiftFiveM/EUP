local requested = false
local houserobberyactive = false

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for id, request in pairs(CFG.RequestRobbery) do
            local dist = #(vector3(request.coords.x, request.coords.y, request.coords.z) - pos)
            if dist <= 6 then
                local hours = GetClockHours()
                if hours >= CFG.MinimumTime or hours <= CFG.MaximumTime then
                    if not requested then 
                        DrawText3D(request.coords.x, request.coords.y, request.coords.z, 'Press ~g~[E]~w~ to request house robbery')
                    else
                        DrawText3D(request.coords.x, request.coords.y, request.coords.z, '~r~Already requested - Check your email')
                    end
                        
                    if dist <= 1.5 and IsControlJustPressed(0, Keys["E"]) and not requested then
                        requestrobbery()
                           requested = true
                    end
                else
                    DrawText3D(request.coords.x, request.coords.y, request.coords.z, "Action ~r~closed~w~, come back around ~g~".. CFG.MinimumTime ..":00")
                end
            else 
                Citizen.Wait(3000)
            end
        end
        Citizen.Wait(3)
    end
end)

function requestrobbery()
    local location = math.random(1, #Houses)
    --if Houses[location]["coords"] ~= nil then
    --    return
    --end
    housedetails = {
        ["coords"] =  Houses[location]["coords"],
    }

    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, housedetails["coords"]["x"], housedetails["coords"]["y"], housedetails["coords"]["z"], Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then 
        streetLabel = streetLabel .. " " .. street2
    end

    SetTimeout(1000, function()
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = "Lester",
            subject = "House Location",
            message = "Here is all information about the house, <br><b>Location:</b> ".. streetLabel .."<br><br><b>Required tools</b><br>Toolkit, Lockpick or Advancedlockpick<br><br>Also bring some gloves..",
            button = {
                enabled = true,
                buttonEvent = "fvm-criminalactions:cl:HouseHouseBlip",
                buttonData = housedetails
            }
        })
    end)
end

RegisterNetEvent('fvm-criminalactions:cl:HouseHouseBlip')
AddEventHandler('fvm-criminalactions:cl:HouseHouseBlip', function(house)
    FvMain.Functions.Notify('You accepted contract, look on map to locate the house location.', 'success');
    housedata = house

    local HouseRadius = AddBlipForRadius(housedata["coords"]["x"], housedata["coords"]["y"], housedata["coords"]["z"] , 100.0)
    SetBlipHighDetail(HouseRadius, true)
	SetBlipColour(HouseRadius, 58)
	SetBlipAlpha (HouseRadius, 180)
    
    local HouseBlip = AddBlipForCoord(housedata["coords"]["x"] - math.random(25,55), housedata["coords"]["y"] + math.random(25,55), housedata["coords"]["z"])
    SetBlipSprite (HouseBlip, 40)
    SetBlipDisplay(HouseBlip, 4)
    SetBlipScale  (HouseBlip, 0.9)
    SetBlipAsShortRange(HouseBlip, true)
    SetBlipColour(HouseBlip, 75)
    SetBlipAlpha (HouseBlip, 180)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("House Radius")
    EndTextCommandSetBlipName(HouseBlip)

    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )

    
    SetTimeout(1000 * 60 * CFG.RemoveHouseBlip, function()
        RemoveBlip(HouseRadius)
        RemoveBlip(HouseBlip)
    end)
    
    SetTimeout(1000 * 60 * CFG.TimeoutForRequest, function()
        requested = false

        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = "Lester",
            subject = "",
            message = "Hey we got some new work, you should come back to check it out.",
        })
    end)
end)