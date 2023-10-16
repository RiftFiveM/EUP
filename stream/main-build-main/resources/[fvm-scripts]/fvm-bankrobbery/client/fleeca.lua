local closestBank = nil
local inRange
local requiredItemsShowed = false
local copsCalled = false
local PlayerJob = {}

currentThermiteGate = 0

CurrentCops = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 60 * 5)
        if copsCalled then
            copsCalled = false
        end
    end
end)

RegisterNetEvent('FvMain:Client:OnJobUpdate')
AddEventHandler('FvMain:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = true
end)

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent("FvMain:Client:OnPlayerLoaded")
AddEventHandler("FvMain:Client:OnPlayerLoaded", function()
    PlayerJob = FvMain.Functions.GetPlayerData().job
    FvMain.Functions.TriggerCallback('fvm-bankrobbery:server:GetConfig', function(config)
        Config = config
    end)
    onDuty = true
    ResetBankDoors()
end)

Citizen.CreateThread(function()
    Wait(500)
    if FvMain.Functions.GetPlayerData() ~= nil then
        PlayerJob = FvMain.Functions.GetPlayerData().job
        onDuty = true
    end
end)

RegisterNetEvent('FvMain:Client:SetDuty')
AddEventHandler('FvMain:Client:SetDuty', function(duty)
    onDuty = duty
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist

        if FvMain ~= nil then
            inRange = false

            for k, v in pairs(Config.SmallBanks) do
                dist = #(pos - vector3(Config.SmallBanks[k]["coords"]["x"], Config.SmallBanks[k]["coords"]["y"], Config.SmallBanks[k]["coords"]["z"]))
                if dist < 15 then
                    closestBank = k
                    inRange = true
                end
            end

            if not inRange then
                Citizen.Wait(2000)
                closestBank = nil
            end
        end

        Citizen.Wait(3)
    end
end)


Citizen.CreateThread(function()
    Citizen.Wait(2000)
    local requiredItems = {
        [1] = {name = FvMain.Shared.Items["electronickit"]["name"], image = FvMain.Shared.Items["electronickit"]["image"]},
        [2] = {name = FvMain.Shared.Items["trojan_usb"]["name"], image = FvMain.Shared.Items["trojan_usb"]["image"]},
    }
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if FvMain ~= nil then
            if closestBank ~= nil then
                if not Config.SmallBanks[closestBank]["isOpened"] then
                    local dist = #(pos - vector3(Config.SmallBanks[closestBank]["coords"]["x"], Config.SmallBanks[closestBank]["coords"]["y"], Config.SmallBanks[closestBank]["coords"]["z"]))
                    if dist < 1 then
                        if not requiredItemsShowed then
                            requiredItemsShowed = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                        end
                    else
                        if requiredItemsShowed then
                            requiredItemsShowed = false
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end
                    end
                end
                if Config.SmallBanks[closestBank]["isOpened"] then
                    for k, v in pairs(Config.SmallBanks[closestBank]["lockers"]) do
                        local lockerDist = #(pos - vector3(Config.SmallBanks[closestBank]["lockers"][k].x, Config.SmallBanks[closestBank]["lockers"][k].y, Config.SmallBanks[closestBank]["lockers"][k].z))
                        if not Config.SmallBanks[closestBank]["lockers"][k]["isBusy"] then
                            if not Config.SmallBanks[closestBank]["lockers"][k]["isOpened"] then
                                if lockerDist < 5 then
                                    DrawMarker(2, Config.SmallBanks[closestBank]["lockers"][k].x, Config.SmallBanks[closestBank]["lockers"][k].y, Config.SmallBanks[closestBank]["lockers"][k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 255, 255, 255, 255, false, false, false, 1, false, false, false)
                                    if lockerDist < 0.5 then
                                        DrawText3Ds(Config.SmallBanks[closestBank]["lockers"][k].x, Config.SmallBanks[closestBank]["lockers"][k].y, Config.SmallBanks[closestBank]["lockers"][k].z + 0.3, '[E] Crack the vault')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            if CurrentCops >= Config.MinimumFleecaPolice then
                                                openLocker(closestBank, k)
                                            else
                                                FvMain.Functions.Notify("Not enough police.. ("..Config.MinimumFleecaPolice.." needed)", "error")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Citizen.Wait(2500)
            end
        end

        Citizen.Wait(1)
    end
end)

function DrawText3Ds(x, y, z, text)
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

RegisterNetEvent('electronickit:UseElectronickit')
AddEventHandler('electronickit:UseElectronickit', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    if math.random(1, 100) <= 85 and not IsWearingHandshoes() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end
    if closestBank ~= nil then
        FvMain.Functions.TriggerCallback('fvm-bankrobbery:server:isRobberyActive', function(isBusy)
            if not isBusy then
                if closestBank ~= nil then
                    local dist = #(pos - vector3(Config.SmallBanks[closestBank]["coords"]["x"], Config.SmallBanks[closestBank]["coords"]["y"], Config.SmallBanks[closestBank]["coords"]["z"]))
                    if dist < 1.5 then
                        if CurrentCops >= Config.MinimumFleecaPolice then
                            if not Config.SmallBanks[closestBank]["isOpened"] then 
                                FvMain.Functions.TriggerCallback('FvMain:HasItem', function(result)
                                    if result then 
                                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                                        FvMain.Functions.Progressbar("hack_gate", "Connecting electronic kit..", math.random(5000, 10000), false, true, {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        }, {
                                            animDict = "anim@gangops@facility@servers@",
                                            anim = "hotwire",
                                            flags = 16,
                                        }, {}, {}, function() -- Done
                                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                                            TriggerEvent("mhacking:show")
                                            TriggerEvent("mhacking:start", math.random(5, 9), math.random(15, 25), OnHackDone)
                                            if not copsCalled then
                                                local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
                                                local street1 = GetStreetNameFromHashKey(s1)
                                                local street2 = GetStreetNameFromHashKey(s2)
                                                local streetLabel = street1
                                                if street2 ~= nil then 
                                                    streetLabel = streetLabel .. " " .. street2
                                                end
                                                if Config.SmallBanks[closestBank]["alarm"] then
                                                    TriggerServerEvent("fvm-bankrobbery:server:callCops", "small", closestBank, streetLabel, pos)
                                                    TriggerEvent('dispatch:fleecaRobbery', closestBank)
                                                    copsCalled = true
                                                end
                                            end
                                        end, function() -- Cancel
                                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                                            FvMain.Functions.Notify("Canceled..", "error")
                                        end)
                                    else
                                        FvMain.Functions.Notify("You are missing something..", "error")
                                    end
                                end, "trojan_usb")
                            else
                                FvMain.Functions.Notify("It looks like the bank is already opened..", "error")
                            end
                        else
                            FvMain.Functions.Notify("Not enough police.. (4 needed)", "error")
                        end
                    end
                end
            else
                FvMain.Functions.Notify("The security lock is active, the door cannot be opened at the moment..", "error", 5500)
            end
        end)
    end
end)

RegisterNetEvent('fvm-bankrobbery:client:setBankState')
AddEventHandler('fvm-bankrobbery:client:setBankState', function(bankId, state)
    if bankId == "paleto" then
        Config.BigBanks["paleto"]["isOpened"] = state
        if state then
            OpenPaletoDoor()
        end
    elseif bankId == "pacific" then
        Config.BigBanks["pacific"]["isOpened"] = state
        if state then
            OpenPacificDoor()
        end
    else
        Config.SmallBanks[bankId]["isOpened"] = state
        if state then
            OpenBankDoor(bankId)
        end
    end
end)

RegisterNetEvent('fvm-bankrobbery:client:enableAllBankSecurity')
AddEventHandler('fvm-bankrobbery:client:enableAllBankSecurity', function()
    for k, v in pairs(Config.SmallBanks) do
        Config.SmallBanks[k]["alarm"] = true
    end
end)

RegisterNetEvent('fvm-bankrobbery:client:disableAllBankSecurity')
AddEventHandler('fvm-bankrobbery:client:disableAllBankSecurity', function()
    for k, v in pairs(Config.SmallBanks) do
        Config.SmallBanks[k]["alarm"] = false
    end
end)

RegisterNetEvent('fvm-bankrobbery:client:BankSecurity')
AddEventHandler('fvm-bankrobbery:client:BankSecurity', function(key, status)
    Config.SmallBanks[key]["alarm"] = status
end)

function OpenBankDoor(bankId)
    local object = GetClosestObjectOfType(Config.SmallBanks[bankId]["coords"]["x"], Config.SmallBanks[bankId]["coords"]["y"], Config.SmallBanks[bankId]["coords"]["z"], 5.0, Config.SmallBanks[bankId]["object"], false, false, false)
    local timeOut = 10
    local entHeading = Config.SmallBanks[bankId]["heading"].closed

    if object ~= 0 then
        Citizen.CreateThread(function()
            while true do

                if entHeading ~= Config.SmallBanks[bankId]["heading"].open then
                    SetEntityHeading(object, entHeading - 10)
                    entHeading = entHeading - 0.5
                else
                    break
                end

                Citizen.Wait(10)
            end
        end)
    end
end

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

function ResetBankDoors()
    for k, v in pairs(Config.SmallBanks) do
        local object = GetClosestObjectOfType(Config.SmallBanks[k]["coords"]["x"], Config.SmallBanks[k]["coords"]["y"], Config.SmallBanks[k]["coords"]["z"], 5.0, Config.SmallBanks[k]["object"], false, false, false)
        if not Config.SmallBanks[k]["isOpened"] then
            SetEntityHeading(object, Config.SmallBanks[k]["heading"].closed)
        else
            SetEntityHeading(object, Config.SmallBanks[k]["heading"].open)
        end
    end
    if not Config.BigBanks["paleto"]["isOpened"] then
        local paletoObject = GetClosestObjectOfType(Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"], Config.BigBanks["paleto"]["coords"]["z"], 5.0, Config.BigBanks["paleto"]["object"], false, false, false)
        SetEntityHeading(paletoObject, Config.BigBanks["paleto"]["heading"].closed)
    else
        local paletoObject = GetClosestObjectOfType(Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"], Config.BigBanks["paleto"]["coords"]["z"], 5.0, Config.BigBanks["paleto"]["object"], false, false, false)
        SetEntityHeading(paletoObject, Config.BigBanks["paleto"]["heading"].open)
    end

    if not Config.BigBanks["pacific"]["isOpened"] then
        local pacificObject = GetClosestObjectOfType(Config.BigBanks["pacific"]["coords"][2]["x"], Config.BigBanks["pacific"]["coords"][2]["y"], Config.BigBanks["pacific"]["coords"][2]["z"], 20.0, Config.BigBanks["pacific"]["object"], false, false, false)
        SetEntityHeading(pacificObject, Config.BigBanks["pacific"]["heading"].closed)
    else
        local pacificObject = GetClosestObjectOfType(Config.BigBanks["pacific"]["coords"][2]["x"], Config.BigBanks["pacific"]["coords"][2]["y"], Config.BigBanks["pacific"]["coords"][2]["z"], 20.0, Config.BigBanks["pacific"]["object"], false, false, false)
        SetEntityHeading(pacificObject, Config.BigBanks["pacific"]["heading"].open)
    end
end

function openLocker(bankId, lockerId)
    local pos = GetEntityCoords(PlayerPedId())
    if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end
    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', true)
    if bankId == "paleto" then
        FvMain.Functions.TriggerCallback('fvm-ifruitstore:server:GetItem', function(hasItem)
            if hasItem then
                loadAnimDict("anim@heists@fleeca_bank@drilling")
                TaskPlayAnim(PlayerPedId(), 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
                local pos = GetEntityCoords(PlayerPedId(), true)
                local DrillObject = CreateObject(GetHashKey("hei_prop_heist_drill"), pos.x, pos.y, pos.z, true, true, true)
                AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
                IsDrilling = true
                FvMain.Functions.Progressbar("open_locker_drill", "Cracking the save..", math.random(40000, 60000), false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                    DetachEntity(DrillObject, true, true)
                    DeleteObject(DrillObject)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isOpened', true)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
                    TriggerServerEvent('fvm-bankrobbery:server:recieveItem', 'paleto')
                    FvMain.Functions.Notify("Succes!", "success")
                    IsDrilling = false
                end, function() -- Cancel
                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
                    DetachEntity(DrillObject, true, true)
                    DeleteObject(DrillObject)
                    FvMain.Functions.Notify("Canceled..", "error")
                    IsDrilling = false
                end)
                Citizen.CreateThread(function()
                    while IsDrilling do
                        TriggerServerEvent('fvm-hud:Server:GainStress', math.random(4, 8))
                        Citizen.Wait(10000)
                    end
                end)
            else
                FvMain.Functions.Notify("It looks like the safe lock is too strong..", "error")
                TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
            end
        end, "drill")
    elseif bankId == "pacific" then
        FvMain.Functions.TriggerCallback('fvm-ifruitstore:server:GetItem', function(hasItem)
            if hasItem then
                loadAnimDict("anim@heists@fleeca_bank@drilling")
                TaskPlayAnim(PlayerPedId(), 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
                local pos = GetEntityCoords(PlayerPedId(), true)
                local DrillObject = CreateObject(GetHashKey("hei_prop_heist_drill"), pos.x, pos.y, pos.z, true, true, true)
                AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
                IsDrilling = true
                FvMain.Functions.Progressbar("open_locker_drill", "Cracking the save..", math.random(40000, 60000), false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                    DetachEntity(DrillObject, true, true)
                    DeleteObject(DrillObject)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isOpened', true)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
                    TriggerServerEvent('fvm-bankrobbery:server:recieveItem', 'pacific')
                    FvMain.Functions.Notify("Succes!", "success")
                    IsDrilling = false
                end, function() -- Cancel
                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                    TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
                    DetachEntity(DrillObject, true, true)
                    DeleteObject(DrillObject)
                    FvMain.Functions.Notify("Canceled..", "error")
                    IsDrilling = false
                end)
                Citizen.CreateThread(function()
                    while IsDrilling do
                        TriggerServerEvent('fvm-hud:Server:GainStress', math.random(4, 8))
                        Citizen.Wait(10000)
                    end
                end)
            else
                FvMain.Functions.Notify("It looks like the safe lock is too strong..", "error")
                TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
            end
        end, "drill")
    else
        IsDrilling = true
        FvMain.Functions.Progressbar("open_locker", "Cracking the save..", math.random(24000, 48000), false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@gangops@facility@servers@",
            anim = "hotwire",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
            TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isOpened', true)
            TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
            TriggerServerEvent('fvm-bankrobbery:server:recieveItem', 'small')
            FvMain.Functions.Notify("Success!", "success")
            IsDrilling = false
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
            TriggerServerEvent('fvm-bankrobbery:server:setLockerState', bankId, lockerId, 'isBusy', false)
            FvMain.Functions.Notify("Canceled..", "error")
            IsDrilling = false
        end)
        Citizen.CreateThread(function()
            while IsDrilling do
                TriggerServerEvent('fvm-hud:Server:GainStress', math.random(4, 8))
                Citizen.Wait(10000)
            end
        end)
    end
end

RegisterNetEvent('fvm-bankrobbery:client:setLockerState')
AddEventHandler('fvm-bankrobbery:client:setLockerState', function(bankId, lockerId, state, bool)
    if bankId == "paleto" then
        Config.BigBanks["paleto"]["lockers"][lockerId][state] = bool
    elseif bankId == "pacific" then
        Config.BigBanks["pacific"]["lockers"][lockerId][state] = bool
    else
        Config.SmallBanks[bankId]["lockers"][lockerId][state] = bool
    end
end)

RegisterNetEvent('fvm-bankrobbery:client:ResetFleecaLockers')
AddEventHandler('fvm-bankrobbery:client:ResetFleecaLockers', function(BankId)
    Config.SmallBanks[BankId]["isOpened"] = false
    for k,_ in pairs(Config.SmallBanks[BankId]["lockers"]) do
        Config.SmallBanks[BankId]["lockers"][k]["isOpened"] = false
        Config.SmallBanks[BankId]["lockers"][k]["isBusy"] = false
    end
end)

function OnHackDone(success, timeremaining)
    if success then
        TriggerEvent('mhacking:hide')
        TriggerServerEvent('fvm-bankrobbery:server:setBankState', closestBank, true)
    else
		TriggerEvent('mhacking:hide')
	end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        ResetBankDoors()
    end
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

function searchPockets()
    if ( DoesEntityExist( PlayerPedId() ) and not IsEntityDead( PlayerPedId() ) ) then 
        loadAnimDict( "random@mugging4" )
        TaskPlayAnim( PlayerPedId(), "random@mugging4", "agitated_loop_a", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
    end
end

function giveAnim()
    if ( DoesEntityExist( PlayerPedId() ) and not IsEntityDead( PlayerPedId() ) ) then 
        loadAnimDict( "mp_safehouselost@" )
        if ( IsEntityPlayingAnim( PlayerPedId(), "mp_safehouselost@", "package_dropoff", 3 ) ) then 
            TaskPlayAnim( PlayerPedId(), "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
        else
            TaskPlayAnim( PlayerPedId(), "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
        end     
    end
end