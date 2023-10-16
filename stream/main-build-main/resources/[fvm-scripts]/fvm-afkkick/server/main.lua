RegisterServerEvent("KickForAFK")
AddEventHandler("KickForAFK", function()
	DropPlayer(source, "You have been kicked for AFK.")
end)

FvMain.Functions.CreateCallback('fvm-afkkick:server:GetPermissions', function(source, cb)
    local group = FvMain.Functions.GetPermission(source)
    cb(group)
end)