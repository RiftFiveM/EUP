local doorInfo = {}

RegisterServerEvent('fvm-doorlock:server:setupDoors')
AddEventHandler('fvm-doorlock:server:setupDoors', function()
	local src = source
	TriggerClientEvent("fvm-doorlock:client:setDoors", FVM.Doors)
end)

RegisterServerEvent('fvm-doorlock:server:updateState')
AddEventHandler('fvm-doorlock:server:updateState', function(doorID, state)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	FVM.Doors[doorID].locked = state
	TriggerClientEvent('fvm-doorlock:client:setState', -1, doorID, state)
end)