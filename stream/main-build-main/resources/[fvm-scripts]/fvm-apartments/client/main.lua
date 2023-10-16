local isLoggedIn = false
local InApartment = false
local ClosestHouse = nil
local CurrentApartment = nil
local IsOwned = false
local CurrentDoorBell = 0
local CurrentOffset = 0
local houseObj = {}
local POIOffsets = nil
local rangDoorbell = nil

AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('FvMain:Client:OnPlayerUnload')
AddEventHandler('FvMain:Client:OnPlayerUnload', function()
    isLoggedIn = false
    CurrentApartment = nil
    InApartment = false
    CurrentOffset = 0
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if houseObj ~= nil then
            exports['fvm-interior']:DespawnInterior(houseObj, function()
                CurrentApartment = nil
                TriggerEvent('fvm-weathersync:client:EnableSync')
                DoScreenFadeIn(500)
                while not IsScreenFadedOut() do
                    Citizen.Wait(10)
                end
                SetEntityCoords(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z)
                SetEntityHeading(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.w)
                Citizen.Wait(1000)
                InApartment = false
                DoScreenFadeIn(1000)
            end)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn and not InApartment then
            SetClosestApartment()
        end
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isLoggedIn and ClosestHouse ~= nil then
            if InApartment then
                PlayerPedId()
                local pos = GetEntityCoords(PlayerPedId())
                local entrancedist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z))
                local stashdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z))
                local outfitsdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z))
                local logoutdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z))


                if CurrentDoorBell ~= 0 then
                    if entrancedist < 1.2 then
                        FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z + 0.1, '~g~G~w~ - Open door')
                        if IsControlJustPressed(0, 47) then -- G
                            TriggerServerEvent("apartments:server:OpenDoor", CurrentDoorBell, CurrentApartment, ClosestHouse)
                            CurrentDoorBell = 0
                        end
                    end
                end
                --exit
                if entrancedist < 3 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z, '~g~E~w~ - Leave appartment')
                    if IsControlJustPressed(0, 38) then -- E
                        LeaveApartment(ClosestHouse)
                    end
                end
                --stash
                if stashdist < 1.2 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, '~g~E~w~ - Stash')
                    if IsControlJustPressed(0, 38) then -- E
                        if CurrentApartment ~= nil then
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", CurrentApartment)
                            TriggerEvent("inventory:client:SetCurrentStash", CurrentApartment)
                        end
                    end
                elseif stashdist < 3 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, 'Stash')
                end
                --outfits
                if outfitsdist < 1.2 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, '~g~E~w~ - Outfits')
                    if IsControlJustPressed(0, 38) then -- E
                        TriggerEvent('fvm-clothing:client:openOutfitMenu')
                    end
                elseif outfitsdist < 3 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, 'Outfits')
                end
                --logout
                if logoutdist < 1.5 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, '~g~E~w~ - Log out')
                    if IsControlJustPressed(0, 38) then -- E
                        TriggerServerEvent('fvm-houses:server:LogoutLocation')
                    end
                elseif logoutdist < 3 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, 'Log out')
                end
            else
                local pos = GetEntityCoords(PlayerPedId())
                local doorbelldist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.doorbell.x, Apartments.Locations[ClosestHouse].coords.doorbell.y,Apartments.Locations[ClosestHouse].coords.doorbell.z))
                local entrance = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z))

                if doorbelldist < 1.2 then
                    FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.doorbell.x, Apartments.Locations[ClosestHouse].coords.doorbell.y, Apartments.Locations[ClosestHouse].coords.doorbell.z, '~g~G~w~ - Ring the doorbell')
                    if IsControlJustPressed(0, 47) then -- G
                        MenuOwners()
                        Menu.hidden = not Menu.hidden
                    end
                    Menu.renderGUI()
                end

                if IsOwned then
                    local pos = GetEntityCoords(PlayerPedId())
                    if entrance < 1.2 then
                        FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~E~w~ - Enter appartment')
                        if IsControlJustPressed(0, 38) then -- E
                            FvMain.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
                                if result ~= nil then
                                    EnterApartment(ClosestHouse, result.name)
                                end
                            end)
                        end
                    end
                elseif not IsOwned then
                    if entrance < 1.2 then
                        FvMain.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~E~w~ - Change Apartment (~g~$ 2000~w~)')
                        if IsControlJustPressed(0, 38) then -- G
                            FvMain.Functions.TriggerCallback('apartments:pay', function(success)
                                if success then
                                    TriggerServerEvent("apartments:server:UpdateApartment", ClosestHouse)
                                    IsOwned = true
                                else
                                    TriggerEvent('FvMain:Notify', "Not enough money.")
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('apartments:client:setupSpawnUI', function(cData)
    FvMain.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result ~= nil then
            TriggerEvent('fvm-spawn:client:setupSpawns', cData, false, nil)
            TriggerEvent('fvm-spawn:client:openUI', true)
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
        else
            TriggerEvent('fvm-spawn:client:setupSpawns', cData, true, Apartments.Locations)
            TriggerEvent('fvm-spawn:client:openUI', true)
            TriggerEvent('fvm-clothes:client:saveSkin')
        end
    end, cData.citizenid)
end)

RegisterNetEvent('apartments:client:SpawnInApartment', function(apartmentId, apartment)
    local pos = GetEntityCoords(PlayerPedId())
    if rangDoorbell ~= nil then
        local doorbelldist = #(pos - vector3(Apartments.Locations[rangDoorbell].coords.doorbell.x, Apartments.Locations[rangDoorbell].coords.doorbell.y,Apartments.Locations[rangDoorbell].coords.doorbell.z))
        if doorbelldist > 5 then
            FvMain.Functions.Notify("You are far away from the door bell.")
            return
        end
    end
    ClosestHouse = apartment
    EnterApartment(apartment, apartmentId, true)
    IsOwned = true
end)

RegisterNetEvent('fvm-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    ClosestHouse = apartmentType
    EnterApartment(apartmentType, apartmentId, false)
end)

RegisterNetEvent('apartments:client:SetHomeBlip', function(home)
    Citizen.CreateThread(function()
        SetClosestApartment()
        for name, apartment in pairs(Apartments.Locations) do
            RemoveBlip(Apartments.Locations[name].blip)

            Apartments.Locations[name].blip = AddBlipForCoord(Apartments.Locations[name].coords.enter.x, Apartments.Locations[name].coords.enter.y, Apartments.Locations[name].coords.enter.z)
            if (name == home) then
                SetBlipSprite(Apartments.Locations[name].blip, 475)
            else
                SetBlipSprite(Apartments.Locations[name].blip, 476)
            end
            SetBlipDisplay(Apartments.Locations[name].blip, 4)
            SetBlipScale(Apartments.Locations[name].blip, 0.65)
            SetBlipAsShortRange(Apartments.Locations[name].blip, true)
            SetBlipColour(Apartments.Locations[name].blip, 3)
    
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Apartments.Locations[name].label)
            EndTextCommandSetBlipName(Apartments.Locations[name].blip)
        end
    end)
end)

RegisterNetEvent('apartments:client:RingDoor', function(player, house)
    CurrentDoorBell = player
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    FvMain.Functions.Notify("Someone is behind the door!")
end)

function EnterApartment(house, apartmentId, new)
    TriggerServerEvent("apartments:setRoutingBucket", false)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    Citizen.Wait(250)
    FvMain.Functions.TriggerCallback('apartments:GetApartmentOffset', function(offset)
        if offset == nil or offset == 0 then
            FvMain.Functions.TriggerCallback('apartments:GetApartmentOffsetNewOffset', function(newoffset)
                if newoffset > 230 then
                    newoffset = 210
                end
                CurrentOffset = newoffset
                TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
                
                local coords = { x = Apartments.Locations[house].coords.enter.x, y = Apartments.Locations[house].coords.enter.y, z = Apartments.Locations[house].coords.enter.z - CurrentOffset}
                data = exports['fvm-interior']:CreateApartmentFurnished(coords)
                Citizen.Wait(100)
                houseObj = data[1]
                POIOffsets = data[2]
                InApartment = true
                CurrentApartment = apartmentId
                ClosestHouse = house
                rangDoorbell = nil    
                Citizen.Wait(500)
                TriggerEvent('fvm-weathersync:client:DisableSync')
                Citizen.Wait(100)
                TriggerServerEvent('fvm-apartments:server:SetInsideMeta', house, apartmentId, true)
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
                TriggerServerEvent("FvMain:Server:SetMetaData", "currentapartment", CurrentApartment)
            end, house)
        else
            if offset > 230 then
                offset = 210
            end
            CurrentOffset = offset
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
            TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
            local coords = { x = Apartments.Locations[ClosestHouse].coords.enter.x, y = Apartments.Locations[ClosestHouse].coords.enter.y, z = Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset}
            data = exports['fvm-interior']:CreateApartmentFurnished(coords)
            Citizen.Wait(100)
            houseObj = data[1]
            POIOffsets = data[2]
            InApartment = true
            CurrentApartment = apartmentId
            Citizen.Wait(500)
            TriggerEvent('fvm-weathersync:client:DisableSync')
            Citizen.Wait(100)
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
            TriggerServerEvent("FvMain:Server:SetMetaData", "currentapartment", CurrentApartment)
        end
        if new ~= nil then
            if new then
                TriggerEvent('fvm-interior:client:SetNewState', true)
            else
                TriggerEvent('fvm-interior:client:SetNewState', false)
            end
        else
            TriggerEvent('fvm-interior:client:SetNewState', false)
        end
    end, apartmentId)
end

function LeaveApartment(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    TriggerServerEvent("apartments:returnBucket")
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    exports['fvm-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('fvm-weathersync:client:EnableSync')
        SetEntityCoords(PlayerPedId(), Apartments.Locations[house].coords.enter.x, Apartments.Locations[house].coords.enter.y,Apartments.Locations[house].coords.enter.z)
        SetEntityHeading(PlayerPedId(), Apartments.Locations[house].coords.enter.w)
        Citizen.Wait(1000)
        TriggerServerEvent("apartments:server:RemoveObject", CurrentApartment, house)
        TriggerServerEvent('fvm-apartments:server:SetInsideMeta', CurrentApartment, false)
        CurrentApartment = nil
        InApartment = false
        CurrentOffset = 0
        DoScreenFadeIn(1000)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("FvMain:Server:SetMetaData", "currentapartment", nil)
    end)
end

function SetClosestApartment()
    local pos = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = nil

    for id, house in pairs(Apartments.Locations) do
        local distcheck = #(pos - vector3(Apartments.Locations[id].coords.enter.x, Apartments.Locations[id].coords.enter.y, Apartments.Locations[id].coords.enter.z))
        if current ~= nil then
            if distcheck < dist then
                current = id
                dist = distcheck
            end
        else
            dist = distcheck
            current = id
        end
    end
    if current ~= ClosestHouse and isLoggedIn and not InApartment then
        ClosestHouse = current
        FvMain.Functions.TriggerCallback('apartments:IsOwner', function(result)
            IsOwned = result
        end, ClosestHouse)
    end
end

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(PlayerPedId())
end

function MenuOwners()
    ped = PlayerPedId();
    MenuTitle = "Owners"
    ClearMenu()
    Menu.addButton("Ring the doorbell", "OwnerList", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function OwnerList()
    FvMain.Functions.TriggerCallback('apartments:GetAvailableApartments', function(apartments)
        ped = PlayerPedId();
        MenuTitle = "Rang the door at: "
        ClearMenu()

        if apartments == nil then
            FvMain.Functions.Notify("There is nobody home..", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(apartments) do
                Menu.addButton(v, "RingDoor", k) 
            end
        end
        Menu.addButton("Back", "MenuOwners",nil)
    end, ClosestHouse)
end

function RingDoor(apartmentId)
    rangDoorbell = ClosestHouse
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerServerEvent("apartments:server:RingDoor", apartmentId, ClosestHouse)
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end