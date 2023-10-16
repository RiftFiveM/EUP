local cornerselling = false
local hasTarget = false
local busySelling = false
local CurrentCops = 0
local PlayerJob = {}
local onDuty = false
local startLocation = nil
local currentPed = nil
local lastPed = {}
local stealingPed = nil
local stealData = {}
local availableDrugs = {}

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    PlayerJob = FvMain.Functions.GetPlayerData().job
    onDuty = true
end)

RegisterNetEvent('FvMain:Client:SetDuty')
AddEventHandler('FvMain:Client:SetDuty', function(duty)
    onDuty = duty
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

RegisterNetEvent('fvm-drugs:client:cornerselling')
AddEventHandler('fvm-drugs:client:cornerselling', function(data)
    if CurrentCops >= Config.MinimumDrugSalePolice then
        FvMain.Functions.TriggerCallback('fvm-drugs:server:cornerselling:getAvailableDrugs', function(result)
            if result ~= nil then
                availableDrugs = result

                if not cornerselling then
                    cornerselling = true
                    FvMain.Functions.Notify('Corner selling: enabled')
                    startLocation = GetEntityCoords(PlayerPedId())
                    if not exports['fvm-inventory']:IsUsingItem() then TriggerEvent("inventory:client:IsUsingItem") end
                else
                    cornerselling = false
                    FvMain.Functions.Notify('Corner selling: disabled', 'error')
                    if exports['fvm-inventory']:IsUsingItem() then TriggerEvent("inventory:client:IsUsingItem") end
                end
            else
                FvMain.Functions.Notify('You aren\'t carrying any drugs with you..', 'error')
            end
        end)
    else
        FvMain.Functions.Notify("Not enough cops on duty (".. Config.MinimumDrugSalePolice .." required)", "error")
    end
end)

function toFarAway()
    FvMain.Functions.Notify('You are moving too much, start over again!', 'error')
    if exports['fvm-inventory']:IsUsingItem() then
        TriggerEvent("inventory:client:IsUsingItem")
    end
    cornerselling = false
    hasTarget = false
    busySelling = false
    startLocation = nil
    currentPed = nil
    availableDrugs = {}
    Citizen.Wait(5000)
end

function callPolice(coords)
    TriggerEvent("dispatch:drugtrafficking")
    hasTarget = false
    Citizen.Wait(5000)
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(4)
        if stealingPed ~= nil and stealData ~= nil then
            if IsEntityDead(stealingPed) then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local pedpos = GetEntityCoords(stealingPed)
                if #(pos - pedpos) < 1.5 then
                    DrawText3D(pedpos.x, pedpos.y, pedpos.z, "[E] Pick up")
                    if IsControlJustReleased(0, Keys["E"]) then
                        RequestAnimDict("pickup_object")
                        while not HasAnimDictLoaded("pickup_object") do
                            Citizen.Wait(7)
                        end
                        TaskPlayAnim(ped, "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        Citizen.Wait(2000)
                        ClearPedTasks(ped)
                        TriggerServerEvent("FvMain:Server:AddItem", stealData.item, stealData.amount)
                        TriggerEvent('inventory:client:ItemBox', FvMain.Shared.Items[stealData.item], "add")
                        stealingPed = nil
                        stealData = {}
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do

        if cornerselling then
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            if not hasTarget then
                local PlayerPeds = {}
                if next(PlayerPeds) == nil then
                    for _, player in ipairs(GetActivePlayers()) do
                        local ped = GetPlayerPed(player)
                        table.insert(PlayerPeds, ped)
                    end
                end
                
                local closestPed, closestDistance = FvMain.Functions.GetClosestPed(coords, PlayerPeds)

                if closestDistance < 15.0 and closestPed ~= 0 and not IsPedInAnyVehicle(closestPed) then
                    SellToPed(closestPed)
                end
            end

            local startDist = #(startLocation - coords)

            if startDist > 10 then
                toFarAway()
            end
        end

        if not cornerselling then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('fvm-drugs:client:refreshAvailableDrugs')
AddEventHandler('fvm-drugs:client:refreshAvailableDrugs', function(items)
    FvMain.Functions.TriggerCallback('fvm-drugs:server:cornerselling:getAvailableDrugs', function(result)
        if result ~= nil then
            availableDrugs = result
        else
            if exports['fvm-inventory']:IsUsingItem() then
                TriggerEvent("inventory:client:IsUsingItem")
            end
            FvMain.Functions.Notify('You sold all drugs..', 'error')
            cornerselling = false
        end
    end)
end)

function SellToPed(ped)
    hasTarget = true
    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    local succesChance = math.random(1, 20)

    local scamChance = math.random(1, 5)

    local getRobbed = math.random(1, 20)

    if succesChance <= 7 then
        hasTarget = false
        return
    elseif succesChance >= 19 then
        callPolice(GetEntityCoords(ped))
        return
    end
    
    local drugType = math.random(1, #availableDrugs)
    local bagAmount = math.random(1, availableDrugs[drugType].amount)

    if bagAmount > 15 then
        bagAmount = math.random(9, 15)
    end
    currentOfferDrug = availableDrugs[drugType]

    local ddata = Config.DrugsPrice[currentOfferDrug.item]
    local randomPrice = math.random(ddata.min, ddata.max) * bagAmount
    if scamChance == 5 then
       randomPrice = math.random(3, 10) * bagAmount
    end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(PlayerPedId(), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)

    if getRobbed == 18 or getRobbed == 9 then
        TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
    else
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
    end

    while pedDist > 1.5 do
        coords = GetEntityCoords(PlayerPedId(), true)
        pedCoords = GetEntityCoords(ped)    
        if getRobbed == 18 or getRobbed == 9 then
            TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        end
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = #(coords - pedCoords)

        Citizen.Wait(100)
    end

    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
    currentPed = ped

    if hasTarget then
        while pedDist < 1.5 do
            coords = GetEntityCoords(PlayerPedId(), true)
            pedCoords = GetEntityCoords(ped)
            pedDist = #(coords - pedCoords)

            if getRobbed == 18 or getRobbed == 9 then
                TriggerServerEvent('fvm-drugs:server:robCornerDrugs', availableDrugs[drugType].item, bagAmount)
                FvMain.Functions.Notify('You have been robbed and lost '..bagAmount..' bag(\'s) '..availableDrugs[drugType].label, 'error')
                stealingPed = ped
                stealData = {
                    item = availableDrugs[drugType].item,
                    amount = bagAmount,
                }

                hasTarget = false

                local rand = (math.random(6,9) / 100) + 0.3
                local rand2 = (math.random(6,9) / 100) + 0.3
                if math.random(10) > 5 then
                    rand = 0.0 - rand
                end
            
                if math.random(10) > 5 then
                    rand2 = 0.0 - rand2
                end
            
                local moveto = GetEntityCoords(PlayerPedId())
                local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
                ClearPedTasksImmediately(ped)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)

                table.insert(lastPed, ped)
                break
            else
                if pedDist < 1.5 then
                    FvMain.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, '~g~E~w~ '..bagAmount..'x '..currentOfferDrug.label..' for $'..randomPrice..'? / ~g~G~w~ Decline offer')
                    if IsControlJustPressed(0, Keys["E"]) then
                        FvMain.Functions.Notify('Offer accepted!', 'success')
                        TriggerServerEvent('fvm-drugs:server:sellCornerDrugs', availableDrugs[drugType].item, bagAmount, randomPrice)
                        hasTarget = false

                        loadAnimDict("gestures@f@standing@casual")
                        TaskPlayAnim(PlayerPedId(), "gestures@f@standing@casual", "gesture_point", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                        Citizen.Wait(650)
                        ClearPedTasks(PlayerPedId())

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        break
                    end

                    if IsControlJustPressed(0, Keys["G"]) then
                        FvMain.Functions.Notify('Offer canceled!', 'error')
                        hasTarget = false

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        break
                    end
                else
                    hasTarget = false
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    table.insert(lastPed, ped)
                end
            end
            
            Citizen.Wait(3)
        end
        
        Citizen.Wait(math.random(4000, 7000))
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

function runAnimation(target)
    RequestAnimDict("mp_character_creation@lineup@male_a")
    while not HasAnimDictLoaded("mp_character_creation@lineup@male_a") do
    Citizen.Wait(0)
    end
    if not IsEntityPlayingAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 3) then
        TaskPlayAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
end