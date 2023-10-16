FvMain.Commands.Add("am", "Toggle animation menu", {}, false, function(source, args)
	TriggerClientEvent('animations:client:ToggleMenu', source)
end)

FvMain.Commands.Add("animations", "Toggle animation menu", {}, false, function(source, args)
	TriggerClientEvent('animations:client:ToggleMenu', source)
end)

FvMain.Commands.Add("emotes", "Toggle animation menu", {}, false, function(source, args)
	TriggerClientEvent('animations:client:ToggleMenu', source)
end)

FvMain.Commands.Add("a", "Do an animation, for the animation list do /am", {{name = "name", help = "Emote name"}}, true, function(source, args)
	TriggerClientEvent('animations:client:EmoteCommandStart', source, args)
end)

FvMain.Functions.CreateUseableItem("walkstick", function(source, item)
    local Player = FvMain.Functions.GetPlayer(source)
    TriggerClientEvent("animations:UseWandelStok", source)
end)
