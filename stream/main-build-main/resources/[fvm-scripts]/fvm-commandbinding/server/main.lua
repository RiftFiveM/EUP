FvMain.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
    local Player = FvMain.Functions.GetPlayer(source)
	TriggerClientEvent("fvm-commandbinding:client:openUI", source)
end)

RegisterServerEvent('fvm-commandbinding:server:setKeyMeta')
AddEventHandler('fvm-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = FvMain.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)