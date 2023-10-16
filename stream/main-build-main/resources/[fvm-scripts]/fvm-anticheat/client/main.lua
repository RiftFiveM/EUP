local isDead = false
local group = Config.Group

-- Check if is decorating --

local IsDecorating = false

RegisterNetEvent('fvm-anticheat:client:ToggleDecorate')
AddEventHandler('fvm-anticheat:client:ToggleDecorate', function(bool)
  IsDecorating = bool
end)

-- Few frequently used locals --

local flags = 0 
local player = PlayerId()
local ped = PlayerPedId()

local isLoggedIn = false

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    FvMain.Functions.TriggerCallback('fvm-anticheat:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
    isLoggedIn = true
end)

RegisterNetEvent("fvm-anticheat:SetDeathStatus")
AddEventHandler("fvm-anticheat:SetDeathStatus", function(playerDead)
    isDead = playerDead
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        FvMain.Functions.TriggerCallback('fvm-anticheat:server:GetPermissions', function(UserGroup)
            group = UserGroup
        end)
    end
end)

-- Godmode --
local isInvincible = false
local GodWait = 500

Citizen.CreateThread(function()
    while true do
        local player = PlayerId()
        local ped = PlayerPedId()
        isInvincible = GetPlayerInvincible(player)
        if not isDead then
            if isInvincible and group == Config.Group and isLoggedIn then
                GodWait = 0
                TriggerEvent('FvMain:Notify', "ANTICHEAT: Stop using godmode or you get banned !")
                SetPlayerInvincible(player, false)
                TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Godmode detect", "green", "** @everyone " ..GetPlayerName(player).. "** tried to use godmode.")  
            elseif not IsInvincible and GodWait == 0 then
                GodWait = 500
            end
        end
        Citizen.Wait(GodWait)
    end
end)

-- Superjump --

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)
 
        local ped = PlayerPedId()
        local pedId = PlayerPedId()

        if group == Config.Group and isLoggedIn then 
            if IsPedJumping(pedId) then
                local firstCoord = GetEntityCoords(ped)
  
                while IsPedJumping(pedId) do
                    Citizen.Wait(0)
                end
        
                local secondCoord = GetEntityCoords(ped)
                local lengthBetweenCoords = #(firstCoord - secondCoord)

                if (lengthBetweenCoords > Config.SuperJumpLength) then
                    flags = flags + 1      
                    TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Superjump)**")         
                end
            end
        end
    end
end)

-- Speedhack --

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)

        local ped = PlayerPedId()
        local speed = GetEntitySpeed(ped) 
        local inveh = IsPedInAnyVehicle(ped, false)
        local ragdoll = IsPedRagdoll(ped)
        local jumping = IsPedJumping(ped)
        local falling = IsPedFalling(ped)
 
        if group == Config.Group and isLoggedIn then 
            if not inveh then
                if not ragdoll then 
                    if not falling then 
                        if not jumping then 
                            if speed > Config.MaxSpeed then 
                                flags = flags + 1 
                                TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Speedhack)**")   
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Invisibility --

Citizen.CreateThread(function()
    while true do      
        Citizen.Wait(10000)

        local ped = PlayerPedId()

        if group == Config.Group and isLoggedIn then 
            if not IsDecorating then 
                if not IsEntityVisible(ped) then
                    SetEntityVisible(ped, 1, 0)
                    TriggerEvent('FvMain:Notify', "ANTICHEAT: You were invisble but now visible again!")
                    TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Made player visible", "green", "** @everyone " ..GetPlayerName(player).. "** was invisible and is visible again by the Anticheat")            
                end 
            end
        end
    end
end)

-- Nightvision --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        local ped = PlayerPedId()

        if group == Config.Group and isLoggedIn then 
            if GetUsingnightvision(true) then 
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1 
                    TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Nightvision)**")
                end
            end
        end
    end
end)

-- Thermalvision --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        local ped = PlayerPedId()

        if group == Config.Group and isLoggedIn then 
            if GetUsingseethrough(true) then 
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1
                    TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Thermalvision)**") 
                end
            end
        end
    end
end)

-- Spawned car --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped)
        local DriverSeat = GetPedInVehicleSeat(veh, -1)
        local plate = GetVehicleNumberPlateText(veh)

        if isLoggedIn then
            if group == Config.Group then
                if IsPedInAnyVehicle(ped, true) then
                    for _, BlockedPlate in pairs(Config.BlacklistedPlates) do
                        if plate == BlockedPlate then
                            if DriverSeat == ped then 
                                DeleteVehicle(veh)     
                                TriggerServerEvent("fvm-anticheat:server:IsPlayerBanAble")          
                                TriggerServerEvent("fvm-anticheat:server:banPlayer", "Cheating")
                                TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Cheat detected!", "red", "** @everyone " ..GetPlayerName(player).. "** has been banned for cheating (Was in a spawned vehicle with the lincense plate **"..BlockedPlate.."**")         
                            end   
                        end
                    end
                end
            end
        end
    end
end)

-- Check if ped has weapon in inventory --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        if isLoggedIn then

            local PlayerPed = PlayerPedId()
            local player = PlayerId()
            local CurrentWeapon = GetSelectedPedWeapon(PlayerPed)
            local WeaponInformation = FvMain.Shared.Weapons[CurrentWeapon]

            if WeaponInformation["name"] ~= "weapon_unarmed" then
                FvMain.Functions.TriggerCallback('fvm-anticheat:server:HasWeaponInInventory', function(HasWeapon)
                    if not HasWeapon then
                        RemoveAllPedWeapons(PlayerPed, false)
                        TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Weapon removed!", "orange", "** @everyone " ..GetPlayerName(player).. "** had a weapon on them that they did not have in his inventory. Anticheat has removed the weapon.")
                    end
                end, WeaponInformation)
            end
        end
    end
end)

-- Max flags reached = ban, log, explosion & break --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local player = PlayerId()
        local coords = GetEntityCoords(ped, true)
        
        if flags >= Config.FlagsForBan then
            -- TriggerServerEvent("fvm-anticheat:server:banPlayer", "Cheating")
            -- AddExplosion(coords, EXPLOSION_GRENADE, 1000.0, true, false, false, true)
            TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Player banned! (Test)", "red", "** @everyone " ..GetPlayerName(player).. "** has been flagged to much and has been banned!")  
            flags = 0 
        end
    end
end)

RegisterNetEvent('fvm-anticheat:client:NonRegisteredEventCalled')
AddEventHandler('fvm-anticheat:client:NonRegisteredEventCalled', function(reason, CalledEvent)
    local player = PlayerId()
    
    TriggerServerEvent("fvm-anticheat:server:IsPlayerBanAble")
    TriggerServerEvent('fvm-anticheat:server:banPlayer', reason)
    TriggerServerEvent("fvm-log:server:CreateLog", "anticheat", "Player banned! (Test)", "red", "** @everyone " ..GetPlayerName(player).. "** has tried to trigger event **"..CalledEvent.." (LUA injector!)")  
end)