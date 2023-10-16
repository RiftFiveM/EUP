RegisterNetEvent('FvMain:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
    TriggerServerEvent('FvMain:Server:updatePlayers')
end)

RegisterNetEvent('FvMain:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

-- FvMain Command Events
RegisterNetEvent('FvMain:Command:TeleportToPlayer', function(coords)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('FvMain:Command:TeleportToCoords', function(x, y, z)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, x, y, z)
end)

RegisterNetEvent('FvMain:Command:GoToMarker', function()
    local ped = PlayerPedId()
    local blip = GetFirstBlipInfoId(8)
    if DoesBlipExist(blip) then
        local blipCoords = GetBlipCoords(blip)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(ped, blipCoords.x, blipCoords.y, height + 0.0)
            local foundGround, zPos = GetGroundZFor_3dCoord(blipCoords.x, blipCoords.y, height + 0.0)
            if foundGround then
                SetPedCoordsKeepVehicle(ped, blipCoords.x, blipCoords.y, height + 0.0)
                break
            end
            Wait(0)
        end
    end
end)

RegisterNetEvent('FvMain:Command:SpawnVehicle', function(vehName)
    local ped = PlayerPedId()
    local hash = GetHashKey(vehName)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    local vehicle = CreateVehicle(hash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetModelAsNoLongerNeeded(vehicle)
	TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
end)

RegisterNetEvent('FvMain:Command:DeleteVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    if veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)

        FvMain.Functions.TriggerCallback('fvm-vehiclekeys:HasKeys', function(result)
            if result then
                TriggerServerEvent('fvm-removekeys', plate)
            end
        end, plate)
    else
        local pcoords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        for k, v in pairs(vehicles) do
            if #(pcoords - GetEntityCoords(v)) <= 5.0 then
                SetEntityAsMissionEntity(v, true, true)
                DeleteVehicle(v)
            end
        end
    end
end)

RegisterNetEvent('FvMain:Command:Revive', function()
	local coords = FvMain.Functions.GetCoords(GLOBAL_PED)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(GLOBAL_PED, false)
	ClearPedBloodDamage(GLOBAL_PED)
end)

-- Other stuff
RegisterNetEvent('FvMain:Player:SetPlayerData', function(val)
    FvMain.PlayerData = val
end)

RegisterNetEvent('FvMain:Player:UpdatePlayerData', function()
    local data = {}
	data.position = FvMain.Functions.GetCoords(GLOBAL_PED)
	TriggerServerEvent('FvMain:UpdatePlayer', data)
end)

RegisterNetEvent('FvMain:Player:UpdatePlayerPosition', function()
	local position = FvMain.Functions.GetCoords(GLOBAL_PED)
	TriggerServerEvent('FvMain:UpdatePlayerPosition', position)
end)

RegisterNetEvent('FvMain:Client:LocalOutOfCharacter', function(playerId, playerName, message)
	local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId)), false)
    local pos = GetEntityCoords(PlayerPedId(), false)
    if (#(pos - sourcePos) < 20.0) then
		TriggerEvent("chatMessage", "Local OOC | " .. playerName, "normal", message)
    end
end)

RegisterNetEvent('FvMain:Notify', function(text, type, length)
    FvMain.Functions.Notify(text, type, length)
end)

RegisterNetEvent('FvMain:Client:TriggerCallback', function(name, ...)
    if FvMain.ServerCallbacks[name] then
        FvMain.ServerCallbacks[name](...)
        FvMain.ServerCallbacks[name] = nil
    end
end)

RegisterNetEvent('FvMain:Client:UseItem', function(item)
    TriggerServerEvent('FvMain:Server:UseItem', item)
end)

RegisterNetEvent('FvMain:client:updatePlayers', function(players)
	FvMain.Players = players
end)

RegisterNetEvent('FvMain:client:updatePlayersCoords', function(playerCoords)
	FvMain.PlayersCoords = playerCoords
end)