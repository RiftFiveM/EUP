FvMain = {}
FvMain.PlayerData = {}
FvMain.Config = FVMConfig
FvMain.Shared = FVMShared
FvMain.ServerCallbacks = {}
FvMain.Players = {}
FvMain.PlayersCoords = {}

isLoggedIn = false

exports('GetCoreObject', function()
	return FvMain
end)
-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local FvMain = exports['fvm-core']:GetCoreObject()

RegisterNetEvent('FvMain:GetObject')
AddEventHandler('FvMain:GetObject', function(cb)
	cb(GetCoreObject())
end)

function GetCoreObject()
	return FvMain
end

