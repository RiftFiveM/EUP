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

local inCityhallPage = false
local FVMCityhall = {}

FVMCityhall.Open = function()
    SendNUIMessage({
        action = "open"
    })
    SetNuiFocus(true, true)
    inCityhallPage = true
end

FVMCityhall.Close = function()
    SendNUIMessage({
        action = "close"
    })
    SetNuiFocus(false, false)
    inCityhallPage = false
end

FVMCityhall.DrawText3Ds = function(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    inCityhallPage = false
end)

local inRange = false

Citizen.CreateThread(function()
    CityhallBlip = AddBlipForCoord(Config.Cityhall.coords.x, Config.Cityhall.coords.y, Config.Cityhall.coords.z)

    SetBlipSprite (CityhallBlip, 487)
    SetBlipDisplay(CityhallBlip, 4)
    SetBlipScale  (CityhallBlip, 0.65)
    SetBlipAsShortRange(CityhallBlip, true)
    SetBlipColour(CityhallBlip, 0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("City Hall")
    EndTextCommandSetBlipName(CityhallBlip)

    DrivingSchoolBlip = AddBlipForCoord(Config.DrivingSchool.coords.x, Config.DrivingSchool.coords.y, Config.DrivingSchool.coords.z)

    SetBlipSprite (DrivingSchoolBlip, 225)
    SetBlipDisplay(DrivingSchoolBlip, 4)
    SetBlipScale  (DrivingSchoolBlip, 0.65)
    SetBlipAsShortRange(DrivingSchoolBlip, true)
    SetBlipColour(DrivingSchoolBlip, 47)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Driving School")
    EndTextCommandSetBlipName(DrivingSchoolBlip)
end)

local currentName = nil

Citizen.CreateThread(function()
    while true do

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        inRange = false

        local dist = #(pos - Config.Cityhall.coords)
        local dist2 = #(pos - Config.DrivingSchool.coords)

        if dist < 20 then
            inRange = true
            DrawMarker(2, Config.Cityhall.coords.x, Config.Cityhall.coords.y, Config.Cityhall.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 155, 152, 234, 155, false, false, false, true, false, false, false)
            if #(pos - vector3(Config.Cityhall.coords.x, Config.Cityhall.coords.y, Config.Cityhall.coords.z)) < 1.5 then
                FVMCityhall.DrawText3Ds(Config.Cityhall.coords, '~g~E~w~ - Open cityhall')
                if IsControlJustPressed(0, Keys["E"]) then
                    FVMCityhall.Open()
                end
            end
            DrawMarker(2, Config.DriverTest.coords.x, Config.DriverTest.coords.y, Config.DriverTest.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 155, 152, 234, 155, false, false, false, true, false, false, false)
            if #(pos - vector3(Config.DriverTest.coords.x, Config.DriverTest.coords.y, Config.DriverTest.coords.z)) < 1.5 then
                FVMCityhall.DrawText3Ds(Config.DriverTest.coords, '~g~E~w~ - Request driving lessons')
                if IsControlJustPressed(0, Keys["E"]) then
                    if FvMain.Functions.GetPlayerData().metadata["licences"]["driver"] then
                         FvMain.Functions.Notify("You already have your driving license, request it to your left")
                    else
                        TriggerServerEvent("fvm-cityhall:server:sendDriverTest")
                    end
                end
            end
        end

        if dist2 < 20 then
            inRange = true
            DrawMarker(2, Config.DrivingSchool.coords.x, Config.DrivingSchool.coords.y, Config.DrivingSchool.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 155, 152, 234, 155, false, false, false, true, false, false, false)
            if #(pos - vector3(Config.DrivingSchool.coords.x, Config.DrivingSchool.coords.y, Config.DrivingSchool.coords.z)) < 1.5 then
                FVMCityhall.DrawText3Ds(Config.DrivingSchool.coords, '~g~E~w~ - Request driving lessons')
                if IsControlJustPressed(0, Keys["E"]) then
                    if FvMain.Functions.GetPlayerData().metadata["licences"]["driver"] then
                        FvMain.Functions.Notify("You have already obtained your driving license, request it at the city hall!")
                    else
                        TriggerServerEvent("fvm-cityhall:server:sendDriverTest")
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(2)
    end
end)

RegisterNetEvent('fvm-cityhall:client:sendDriverEmail')
AddEventHandler('fvm-cityhall:client:sendDriverEmail', function(charinfo)
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Mr."
        if FvMain.Functions.GetPlayerData().charinfo.gender == "woman" then
            gender = "Mrs."
        end
        local charinfo = FvMain.Functions.GetPlayerData().charinfo
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = "City hall",
            subject = "Request driving lessons",
            message = "Dear " .. gender .. " " .. charinfo.lastname .. ",<br /><br />We have just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact him.<br />Name: <strong>".. charinfo.firstname .. " " .. charinfo.lastname .. "</strong><br />Phone number: <strong>"..charinfo.phone.."</strong><br/><br/>Kind regards,<br />Cityhall Los Santos",
        })
    end)
end)

local idTypes = {
    ["id-card"] = {
        label = "ID Card",
        item = "id_card"
    },
    ["driverlicense"] = {
        label = "Driver License",
        item = "driver_license"
    },
}

RegisterNUICallback('requestId', function(data)
    if inRange then
        local idType = data.idType

        TriggerServerEvent('fvm-cityhall:server:requestId', idTypes[idType])
        FvMain.Functions.Notify('You have received your '..idTypes[idType].label..' for $50', 'success', 3500)
    else
        FvMain.Functions.Notify('This will not work', 'error')
    end
end)

RegisterNUICallback('requestLicenses', function(data, cb)
    local PlayerData = FvMain.Functions.GetPlayerData()
    local licensesMeta = PlayerData.metadata["licences"]
    local availableLicenses = {}

    if FvMain.Functions.GetPlayerData().metadata["licences"]["driver"] then
        table.insert(availableLicenses, {
            idType = 'driverlicense',
            label = "Driver license"
        })
    end

    cb(availableLicenses)
end)

RegisterNUICallback('applyJob', function(data)
    if inRange then
        TriggerServerEvent('fvm-cityhall:server:ApplyJob', data.job)
    else
        FvMain.Functions.Notify('Unfortunately it isnt working...', 'error')
    end
end)