FvMain = {}
FvMain.Config = FVMConfig
FvMain.Shared = FVMShared
FvMain.ServerCallbacks = {}
FvMain.UseableItems = {}

exports('GetCoreObject', function()
    return FvMain
end)

function GetCoreObject()
	return FvMain
end

RegisterServerEvent('FvMain:GetObject')
AddEventHandler('FvMain:GetObject', function(cb)
	cb(GetCoreObject())
end)

Citizen.CreateThread(function()
    while true do
    	TriggerEvent('FvMain:Server:updatePlayersCoords')
    	Citizen.Wait(3000)
    end
end)