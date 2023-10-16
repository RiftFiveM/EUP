currentDealer = nil
knockingDoor = false

local dealerIsHome = false

local waitingDelivery = nil
local activeDelivery = nil

local interacting = false
local haskey = false
local refused = false
local askedforitem = false

local deliveryTimeout = 0

local healAnimDict = "mini@cpr@char_a@cpr_str"
local healAnim = "cpr_pumpchest"

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    FvMain.Functions.TriggerCallback('fvm-weapondealer:server:RequestConfig', function(DealerConfig)
        WP.Dealers = DealerConfig
    end)
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        nearDealer = false

        for id, dealer in pairs(WP.Dealers) do
            local dealerDist = #(pos - vector3(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z))

            if dealerDist <= 6 then
                nearDealer = true

                if dealerDist <= 1.5 then
                    if not interacting then
                        if not dealerIsHome then
                            DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z, '[E] Knock')
                            if IsControlJustPressed(0, Keys["E"]) then
                                askedforitem = false
                                TriggerEvent('fvm-weathersync:client:EnableSync')
                                Citizen.Wait(1000)
                                currentDealer = id
                                knockDealerDoor()
                            end
                        elseif dealerIsHome then

                            if not askedforitem and not refused then
                                FvMain.Functions.TriggerCallback('fvm-ifruitstore:server:GetItem', function(hasItem)
                                    if dealer["name"] == "Bogdan" then
                                        if hasItem then
                                            haskey = true
                                        else
                                            haskey = false
                                        end
                                    end
                                    askedforitem = true
                                end, "labkey")
                            end

                            if dealer["name"] == "Bogdan" then
                                if haskey then
                                    DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z, '[E] To buy / [G] Do assignments')
                                else
                                    if FvMain.Functions.GetPlayerData().metadata["wepdealerrep"] > WP.RequiredReputationForMethLab and not haskey and not refused then
                                        DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z, '~w~You received ~g~offer~w~ from ~r~'.. dealer["name"] ..'.')
                                        DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z - 0.2, 'Receive access to methlab ~g~[G] ~w~/ ~r~[E] ~w~to refuse')
                                    else
                                        DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z, '[E] To buy / [G] Do assignments')
                                    end
                                end
                            else
                                DrawText3D(dealer["coords"].x, dealer["coords"].y, dealer["coords"].z, '[E] To buy / [G] Do assignments')
                            end

                            if IsControlJustPressed(0, Keys["E"]) then
                                if dealer["name"] == "Bogdan" and FvMain.Functions.GetPlayerData().metadata["wepdealerrep"] > WP.RequiredReputationForMethLab and not haskey and not refused then
                                    TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "normal", 'As you wish...')
                                    refused = true
                                    --interacting = false
                                    --dealerIsHome = false
                                elseif dealer["name"] == "Bogdan" and haskey then
                                    buyDealerStuff()
                                    interacting = false
                                    dealerIsHome = false
                                else
                                    buyDealerStuff()
                                    interacting = false
                                    dealerIsHome = false
                                end
                            end

                            if IsControlJustPressed(0, Keys["G"]) then
                                if dealer["name"] == "Bogdan" and FvMain.Functions.GetPlayerData().metadata["wepdealerrep"] > WP.RequiredReputationForMethLab and not haskey and not refused then
                                    TriggerServerEvent("fvm-methlab:givekey", source)
                                    haskey = true
                                    interacting = false
                                    dealerIsHome = false
                                    TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "normal", "There is your key, I'll be in touch.")
                                    
                                    SetTimeout(15000, function()
                                        TriggerServerEvent('fvm-phone:server:sendNewMail', {
                                            sender = WP.Dealers[currentDealer]["name"],
                                            subject = "Instructions",
                                            message = "<b>Alright man,</b> lab is located at small village called Grapeseed, only two buldings from paint shop..<br> Enter it from behind.",
                                        })
                                    end)
                                else
                                    if waitingDelivery == nil then
                                        TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "normal", 'Here you have the products, keep track of your email regarding where to deliver the goods!')
                                        requestDelivery()
                                        interacting = false
                                        dealerIsHome = false
                                    else
                                        TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "error", 'You still have an open delivery. What are you waiting for?')
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not nearDealer then
            interacting = false
            dealerIsHome = false
            Citizen.Wait(2000)
        end

        Citizen.Wait(3)
    end
end)

function GetClosestPlayer()
    local ped = PlayerPedId()
    local closestPlayers = FvMain.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(ped)

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

knockDealerDoor = function()
    local hours = GetClockHours()
    local min = WP.Dealers[currentDealer]["time"]["min"]
    local max = WP.Dealers[currentDealer]["time"]["max"]

    if min > max then 
        if hours > min or hours < max then
            knockDoorAnim(true)
            return
        else
            knockDoorAnim(false)
            return
        end
    elseif hours >= min and hours <= max then
        knockDoorAnim(true)
        return
    else
        knockDoorAnim(false)
        return
    end         
end

function buyDealerStuff()
    local repItems = {}
    repItems.label = WP.Dealers[currentDealer]["name"]
    repItems.items = {}
    repItems.slots = 30

    for k, v in pairs(WP.Dealers[currentDealer]["products"]) do
        if FvMain.Functions.GetPlayerData().metadata["wepdealerrep"] >= WP.Dealers[currentDealer]["products"][k].minrep then
            repItems.items[k] = WP.Dealers[currentDealer]["products"][k]
        end
    end

    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Dealer_"..WP.Dealers[currentDealer]["name"], repItems)
end

function knockDoorAnim(home)
    local knockAnimLib = "timetable@jimmy@doorknock@"
    local knockAnim = "knockdoor_idle"
    local PlayerPed = PlayerPedId()
    local myData = FvMain.Functions.GetPlayerData()

    if home then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "knock_door", 0.2)
        Citizen.Wait(100)
        while (not HasAnimDictLoaded(knockAnimLib)) do
            RequestAnimDict(knockAnimLib)
            Citizen.Wait(100)
        end
        knockingDoor = true
        TaskPlayAnim(PlayerPed, knockAnimLib, knockAnim, 3.0, 3.0, -1, 1, 0, false, false, false )
        Citizen.Wait(3500)
        TaskPlayAnim(PlayerPed, knockAnimLib, "exit", 3.0, 3.0, -1, 1, 0, false, false, false)
        knockingDoor = false
        Citizen.Wait(1000)
        dealerIsHome = true
        if WP.Dealers[currentDealer]["name"] == "Bogdan" and FvMain.Functions.GetPlayerData().metadata["wepdealerrep"] > WP.RequiredReputationForMethLab then
            TriggerEvent("chatMessage", "Dealer "..WP.Dealers[currentDealer]["name"], "normal", 'Hello my friend, what can i do for you? :)')
        elseif WP.Dealers[currentDealer]["name"] == "Bogdan" then
            TriggerEvent("chatMessage", "Dealer "..WP.Dealers[currentDealer]["name"], "normal", 'Hi, what can I do for you?')
        -- elseif WP.Dealers[currentDealer]["name"] == "Fred" then
        --     dealerIsHome = false
        --     TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "normal", 'Unfortunately, I no longer do business...')
        else
            TriggerEvent("chatMessage", WP.Dealers[currentDealer]["name"], "normal", 'Da '..myData.charinfo.firstname..', What you want?')
        end
        -- knockTimeout()
    else
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "knock_door", 0.2)
        Citizen.Wait(100)
        while (not HasAnimDictLoaded(knockAnimLib)) do
            RequestAnimDict(knockAnimLib)
            Citizen.Wait(100)
        end
        knockingDoor = true
        TaskPlayAnim(PlayerPed, knockAnimLib, knockAnim, 3.0, 3.0, -1, 1, 0, false, false, false )
        Citizen.Wait(3500)
        TaskPlayAnim(PlayerPed, knockAnimLib, "exit", 3.0, 3.0, -1, 1, 0, false, false, false)
        knockingDoor = false
        Citizen.Wait(1000)
        FvMain.Functions.Notify('No one seems to be home..', 'error', 3500)
    end
end

RegisterNetEvent('fvm-weapondealer:client:updateDealerItems')
AddEventHandler('fvm-weapondealer:client:updateDealerItems', function(itemData, amount)
    TriggerServerEvent('fvm-weapondealer:server:updateDealerItems', itemData, amount, currentDealer)
end)

RegisterNetEvent('fvm-weapondealer:client:setDealerItems')
AddEventHandler('fvm-weapondealer:client:setDealerItems', function(itemData, amount, dealer)
    WP.Dealers[dealer]["products"][itemData.slot].amount = WP.Dealers[dealer]["products"][itemData.slot].amount - amount
end)

function requestDelivery()
    local location = math.random(1, #DeliveryLocations)
    local amount = math.random(1, 3)
    local item = randomDeliveryItemOnRep()
    waitingDelivery = {
        ["coords"] = DeliveryLocations[location]["coords"],
        ["locationLabel"] = DeliveryLocations[location]["label"],
        ["amount"] = amount,
        ["dealer"] = currentDealer,
        ["itemData"] = DeliveryItems[item]
    }
    FvMain.Functions.TriggerCallback('fvm-weapondealer:giveDeliveryItems', function()
    end, amount)
    SetTimeout(7000, function()
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = WP.Dealers[currentDealer]["name"],
            subject = "Place of delivery",
            message = "Here is all the information about your delivery, <br>Place: "..waitingDelivery["locationLabel"].."<br>Goods: <br> "..amount.."x "..FvMain.Shared.Items[waitingDelivery["itemData"]["item"]]["label"].."<br><br> Make sure you are on time!",
            button = {
                enabled = true,
                buttonEvent = "fvm-weapondealer:client:setLocation",
                buttonData = waitingDelivery
            }
        })
    end)
end

function randomDeliveryItemOnRep()
    local ped = PlayerPedId()
    local myRep = FvMain.Functions.GetPlayerData().metadata["wepdealerrep"]

    retval = nil

    for k, v in pairs(DeliveryItems) do
        if DeliveryItems[k]["minrep"] <= myRep then
            local availableItems = {}
            table.insert(availableItems, k)

            local item = math.random(1, #availableItems)

            retval = item
        end
    end
    return retval
end

function setMapBlip(x, y)
    SetNewWaypoint(x, y)
    FvMain.Functions.Notify('The route to the delivery point is indicated on your map.', 'success');
end

RegisterNetEvent('fvm-weapondealer:client:setLocation')
AddEventHandler('fvm-weapondealer:client:setLocation', function(locationData)
    if activeDelivery == nil then
        activeDelivery = locationData
    else
        setMapBlip(activeDelivery["coords"]["x"], activeDelivery["coords"]["y"])
        FvMain.Functions.Notify('You still have an active delivery...')
        return
    end

    deliveryTimeout = 300
    deliveryTimer()
    setMapBlip(activeDelivery["coords"]["x"], activeDelivery["coords"]["y"])

    Citizen.CreateThread(function()
        while true do

            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inDeliveryRange = false

            if activeDelivery ~= nil then
                local dist = GetDistanceBetweenCoords(pos, activeDelivery["coords"]["x"], activeDelivery["coords"]["y"], activeDelivery["coords"]["z"])

                if dist < 15 then
                    inDeliveryRange = true
                    if dist < 1.5 then
                        DrawText3D(activeDelivery["coords"]["x"], activeDelivery["coords"]["y"], activeDelivery["coords"]["z"], '[E] '..activeDelivery["amount"]..'x '..FvMain.Shared.Items[activeDelivery["itemData"]["item"]]["label"]..' to deliver.')

                        if IsControlJustPressed(0, Keys["E"]) then
                            deliverStuff(activeDelivery)
                            activeDelivery = nil
                            waitingDelivery = nil
                            break
                        end
                    end
                end

                if not inDeliveryRange then
                    Citizen.Wait(1500)
                end
            else
                break
            end

            Citizen.Wait(3)
        end
    end)
end)

function deliveryTimer()
    Citizen.CreateThread(function()
        while true do

            if deliveryTimeout - 1 > 0 then
                deliveryTimeout = deliveryTimeout - 1
            else
                deliveryTimeout = 0
                break
            end

            Citizen.Wait(1000)
        end
    end)
end

function deliverStuff(activeDelivery)
    if deliveryTimeout > 0 then
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        Citizen.Wait(500)
        TriggerEvent('animations:client:EmoteCommandStart', {"bumbin"})
        checkPedDistance()
        FvMain.Functions.Progressbar("work_dropbox", "Delivers products..", 3500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('fvm-weapondealer:server:succesDelivery', activeDelivery, true)
        end, function() -- Cancel
            ClearPedTasks(PlayerPedId())
            FvMain.Functions.Notify("Canceled..", "error")
        end)
    else
        TriggerServerEvent('fvm-weapondealer:server:succesDelivery', activeDelivery, false)
    end
    deliveryTimeout = 0
end

function checkPedDistance()
    local PlayerPeds = {}
    if next(PlayerPeds) == nil then
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            table.insert(PlayerPeds, ped)
        end
    end
    
    local closestPed, closestDistance = FvMain.Functions.GetClosestPed(coords, PlayerPeds)

    if closestDistance < 40 and closestPed ~= 0 then
        local callChance = math.random(1, 100)

        if callChance < WP.ChanceToCallCops then
            doPoliceAlert()
        end
    end
end

function doPoliceAlert()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then 
        streetLabel = streetLabel .. " " .. street2
    end
    TriggerEvent('dispatch:weapontrafficking')
end

RegisterNetEvent('fvm-weapondealer:client:executeEvents')
AddEventHandler('fvm-weapondealer:client:executeEvents', function()
    TriggerServerEvent('fvm-weapondealer:server:giveDeliveryItems', amount)
end)

RegisterNetEvent('fvm-weapondealer:client:sendDeliveryMail')
AddEventHandler('fvm-weapondealer:client:sendDeliveryMail', function(type, deliveryData)
    if type == 'perfect' then
        smessage = "You did a great job! I hope to do business with you again soon ;)<br><br><b>Greetings, "..WP.Dealers[deliveryData["dealer"]]["name"]
        if WP.Dealers[deliveryData["dealer"]]["name"] == "Olov" then
            local chance = math.random(1, 100)
            if chance <= WP.ChanceToReceiveSecretLocation then
                smessage = "<b>You did a great job!</b><br> By the way if you want to make more money.<br>You should visit my friend at <b>Amarillo Vista El Burro Heights</b><br> I hope to do business with you again soon ;)<br><br><b>Greetings, "..WP.Dealers[deliveryData["dealer"]]["name"]
            end
        end
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = WP.Dealers[deliveryData["dealer"]]["name"],
            subject = "Delivery",
            message = smessage,
        })
    elseif type == 'bad' then
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = WP.Dealers[deliveryData["dealer"]]["name"],
            subject = "Delivery",
            message = "I'm getting a complaint about your delivery, do not let this happen again..."
        })
    elseif type == 'late' then
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = WP.Dealers[deliveryData["dealer"]]["name"],
            subject = "Delivery",
            message = "You were not on time. You had more important things to do than business?"
        })
    end
end)

Citizen.CreateThread(function()
    if WP.EnableBlips then
        for k, v in pairs(WP.Dealers) do
            local MissionDealers = AddBlipForCoord(v["coords"].x, v["coords"].y, v["coords"].z)
            SetBlipSprite(MissionDealers, 66)
            SetBlipDisplay(MissionDealers, 4)
            SetBlipScale(MissionDealers, 0.6)
            SetBlipAsShortRange(MissionDealers, true)
            SetBlipColour(MissionDealers, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(v["name"])
            EndTextCommandSetBlipName(MissionDealers)
        end
    end
end)
