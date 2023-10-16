local closestDoorKey, closestDoorValue = nil, nil
local maxDistance = 1.25

local PlayerGang = {}
local PlayerJob = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        PlayerJob = FvMain.Functions.GetPlayerData().job
		PlayerGang = FvMain.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    TriggerServerEvent("fvm-doorlock:server:setupDoors")
	PlayerJob = FvMain.Functions.GetPlayerData().job
	PlayerGang = FvMain.Functions.GetPlayerData().gang
end)

RegisterNetEvent('fvm-doorlock:client:setState')
AddEventHandler('fvm-doorlock:client:setState', function(doorID, state)
	FVM.Doors[doorID].locked = state
end)

RegisterNetEvent('fvm-doorlock:client:setDoors')
AddEventHandler('fvm-doorlock:client:setDoors', function(doorList)
	FVM.Doors = doorList
end)

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    TriggerServerEvent("fvm-doorlock:server:setupDoors")
end)

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function()
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)

	FvMain.Functions.TriggerCallback('FvMain:HasItem', function(hasItem)
		for k, v in pairs(FVM.Doors) do
			local dist = #(pos - vector3(FVM.Doors[k].textCoords.x, FVM.Doors[k].textCoords.y, FVM.Doors[k].textCoords.z))
			if dist < 1.5 then
				if FVM.Doors[k].pickable then
					if FVM.Doors[k].locked then
						if hasItem then
							closestDoorKey, closestDoorValue = k, v
							TriggerEvent('fvm-lockpick:client:openLockpick', lockpickFinish)
						else
							FvMain.Functions.Notify("You are missing a toolkit..", "error")
						end
					else
						FvMain.Functions.Notify('The door is already unlocked??', 'error', 2500)
					end
				else
					FvMain.Functions.Notify('The door lock is too strong', 'error', 2500)
				end
			end
		end
    end, "screwdriverset")
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

function lockpickFinish(success)
    if success then
		FvMain.Functions.Notify('Success!', 'success', 2500)
		setDoorLocking(closestDoorValue, closestDoorKey)
    else
        FvMain.Functions.Notify('Failed..', 'error', 2500)
    end
end

function setDoorLocking(doorId, key)
	doorId.locking = true
	openDoorAnim()
    SetTimeout(400, function()
		doorId.locking = false
		doorId.locked = not doorId.locked
		TriggerServerEvent('fvm-doorlock:server:updateState', key, doorId.locked)
	end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function IsAuthorized(doorID)
	local PlayerData = FvMain.Functions.GetPlayerData()

	for _,job in pairs(doorID.authorizedJobs) do
		if job == PlayerData.job.name then
			return true
		end
	end

	for _,gang in pairs(doorID.authorizedJobs) do
		if gang == PlayerData.gang.name then
			return true
		end
	end
	
	return false
end

function openDoorAnim()
	local ped = PlayerPedId()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
	SetTimeout(400, function()
		ClearPedTasks(ped)
	end)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2500)
		for i = 1, #FVM.Doors do
			local current = FVM.Doors[i]
			if current.doors then
				for a = 1, #current.doors do
					local currentDoor = current.doors[a]
					if not currentDoor.object or not DoesEntityExist(currentDoor.object) then
						currentDoor.object = GetClosestObjectOfType(currentDoor.objCoords, 1.0, currentDoor.objName, false, false, false)
					end
				end
			else
				if not current.object or not DoesEntityExist(current.object) then
					current.object = GetClosestObjectOfType(current.objCoords, 1.0, current.objName, false, false, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local playerCoords, awayFromDoors = GetEntityCoords(PlayerPedId()), true

		for i = 1, #FVM.Doors do
			local current = FVM.Doors[i]
			local distance

			if current.doors then
				distance = #(playerCoords - current.doors[1].objCoords)
			else
				distance = #(playerCoords - current.objCoords)
			end

			if current.distance then
				maxDistance = current.distance
			end

			if distance < 10 then
				awayFromDoors = false
				if current.doors then
					for a = 1, #current.doors do
						local currentDoor = current.doors[a]
						FreezeEntityPosition(currentDoor.object, current.locked)

						if current.locked and currentDoor.objYaw and GetEntityRotation(currentDoor.object).z ~= currentDoor.objYaw then
							SetEntityRotation(currentDoor.object, 0.0, 0.0, currentDoor.objYaw, 2, true)
						end
					end
				else
					FreezeEntityPosition(current.object, current.locked)

					if current.locked and current.objYaw and GetEntityRotation(current.object).z ~= current.objYaw then
						SetEntityRotation(current.object, 0.0, 0.0, current.objYaw, 2, true)
					end
				end
			end

			if distance < maxDistance then
				awayFromDoors = false
				if current.size then
					size = current.size
				end

				local isAuthorized = IsAuthorized(current)

				if isAuthorized then
					if current.locked then
						displayText = "~g~E~w~ - Locked"
					elseif not current.locked then
						displayText = "~g~E~w~ - Unlocked"
					end
				elseif not isAuthorized then
					if current.locked then
						displayText = "~r~Locked"
					elseif not current.locked then
						displayText = "~g~Unlocked"
					end
				end

				if current.locking then
					if current.locked then
						displayText = "~g~Unlocking.."
					else
						displayText = "~r~Locking.."
					end
				end

				if current.objCoords == nil then
					current.objCoords = current.textCoords
				end

				DrawText3Ds(current.objCoords.x, current.objCoords.y, current.objCoords.z, displayText)

				if IsControlJustReleased(0, 38) then
					if isAuthorized then
						setDoorLocking(current, i)
					else
						FvMain.Functions.Notify('Not Authorized', 'error')
					end
				end
			end
		end

		if awayFromDoors then
			Citizen.Wait(1000)
		end
	end
end)