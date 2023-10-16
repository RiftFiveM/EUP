FvMain.Commands = {}
FvMain.Commands.List = {}

FvMain.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	if type(permission) == 'string' then
        permission = permission:lower()
    else
        permission = 'user'
    end
    FvMain.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

FvMain.Commands.Refresh = function(source)
	local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(FvMain.Commands.List) do
            local isGod = FvMain.Functions.HasPermission(src, 'god')
            local hasPerm = FvMain.Functions.HasPermission(src, FvMain.Commands.List[command].permission)
            local isPrincipal = IsPlayerAceAllowed(src, 'command')
            if isGod or hasPerm or isPrincipal then
                suggestions[#suggestions+1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            end
        end
        TriggerClientEvent('chat:addSuggestions', tonumber(source), suggestions)
    end
end

FvMain.Commands.Add("tp", "Teleport to a player or location", {{name="id/x", help="ID of player or X position"}, {name="y", help="Y position"}, {name="z", help="Z position"}}, false, function(source, args)
	if (args[1] ~= nil and (args[2] == nil and args[3] == nil)) then
		local player = GetPlayerPed(source)
		local target = GetPlayerPed(tonumber(args[1]))
		if target ~= 0 then
			local coords = GetEntityCoords(target)
			TriggerClientEvent('FvMain:Command:TeleportToPlayer', source, coords)
		else
			TriggerClientEvent('FvMain:Notify', source, "Player is not online!", "error")
		end
	else
		if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
			local player = GetPlayerPed(source)
			local x = tonumber(args[1])
			local y = tonumber(args[2])
			local z = tonumber(args[3])
			if (x ~= 0) and (y ~= 0) and (z ~= 0) then
				TriggerClientEvent('FvMain:Command:TeleportToCoords', source, x, y, z)
			else
				TriggerClientEvent('FvMain:Notify', source, "Incorrect Format.", "error")
			end
		else
			TriggerClientEvent('FvMain:Notify', source, "Not every argument has been entered (x, y, z)", "error")
		end
	end
end, "admin")

FvMain.Commands.Add("tpm", "Teleport to your waypoint", {}, false, function(source, args)
	TriggerClientEvent('FvMain:Command:GoToMarker', source)
end, "admin")

FvMain.Commands.Add("addpermission", "Grant permissions to someone (god/admin)", {{name="id", help="ID of player"}, {name="permission", help="Permission level"}}, true, function(source, args)
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player then
		FvMain.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

FvMain.Commands.Add("removepermission", "Remove permissions from someone", {{name="id", help="ID of player"}}, true, function(source, args)
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	if Player then
		FvMain.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

FvMain.Commands.Add("sv", "Spawn a vehicle", {{name="model", help="Model name of the vehicle"}}, true, function(source, args)
	local src = source
	TriggerClientEvent('FvMain:Command:SpawnVehicle', src, args[1])
end, "admin")

FvMain.Commands.Add("debug", "Turn debug mode on / off", {}, false, function(source, args)
	local src = source
	TriggerClientEvent('koil-debug:toggle', src)
end, "admin")

FvMain.Commands.Add("dv", "Despawn a vehicle", {}, false, function(source, args)
	local src = source
	TriggerClientEvent('FvMain:Command:DeleteVehicle', src)
end, "admin")

FvMain.Commands.Add("givemoney", "Give money to a player", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	if Player then
		Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

FvMain.Commands.Add("setmoney", "Set a players money amount", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	if Player then
		if Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3])) then
			TriggerClientEvent('FvMain:Notify', args[1], "Admin set your ".. args[2] .." to $" .. args[3] ..".")
			TriggerClientEvent('FvMain:Notify', src, "You set money for player correctly.", "success")
		end
	else
		TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

FvMain.Commands.Add("setjob", "Set a job for a player.", {{name="id", help="Player ID"}, {name="job", help="Job name"}, {name="grade", help= "Grade"}}, true, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	if Player then
		if Player.Functions.SetJob(tostring(args[2]), tonumber(args[3])) then
			TriggerClientEvent('FvMain:Notify', args[1], "Admin set your job - Name: "..Player.PlayerData.job.label.. " - Grade: " ..Player.PlayerData.job.grade.name.." - Level: " ..Player.PlayerData.job.grade.level.."")
			TriggerClientEvent('FvMain:Notify', src, "You set job for player correctly.", "success")
		end
	else
		TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

FvMain.Commands.Add("setgang", "Set Player's gang.", {{name="id", help="Player ID"}, {name="gang", help="Gang Name"}, {name="level", help= "Grade in Gang"}}, true, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
	local name = tostring(args[2])
	local level = tonumber(args[3])

	if Player then
		if level then
			if level <= FvMain.Shared.Gangs[name].maxLevel and level >= 0 then
				if Player.Functions.SetGang(name, level) then
					TriggerClientEvent('FvMain:Notify', src, "Admin set your gang - "..Player.PlayerData.gang.label.. " - Grade: " ..Player.PlayerData.gang.grade.name.." - Level: " ..Player.PlayerData.gang.grade.level.."", "success")
					TriggerClientEvent('FvMain:Notify', src, "You set gang for player correctly.", "success")
				end
			else
				TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Invalid Level. Gang's max level (grade) is " ..FvMain.Shared.Gangs[name].maxLevel.."")
			end
		else
			TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Invalid Level. Gang's max level (grade) is " ..FvMain.Shared.Gangs[name].maxLevel.."")
		end
	else
		TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player is not online!")
	end
end, "god")

FvMain.Commands.Add("job", "Check your current job...", {}, false, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if Player.PlayerData.job.label ~= nil or Player.PlayerData.job.level ~= nil or Player.PlayerData.job.grade.level ~= nil then
		TriggerClientEvent('chatMessage', src, "SYSTEM", "warning", "Your Job: ^4"..Player.PlayerData.job.label.. " ^7- Grade: ^4" ..Player.PlayerData.job.grade.name.." ^7- Level: ^4" ..Player.PlayerData.job.grade.level.."")
	else 
		Player.Functions.SetJob("unemployed", 1)
		TriggerClientEvent('chatMessage', src, "SYSTEM", "warning", "Your Job: ^4"..Player.PlayerData.job.label.. " ^7- Grade: ^4" ..Player.PlayerData.job.grade.name.." ^7- Level: ^4" ..Player.PlayerData.job.grade.level.."")
	end
end)

FvMain.Commands.Add("gang", "Check your current gang...", {}, false, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if Player.PlayerData.gang.label ~= nil or Player.PlayerData.gang.grade.name ~= nil or Player.PlayerData.gang.grade.level ~= nil then
		TriggerClientEvent('chatMessage', src, "SYSTEM", "warning", "Your Gang: ^4"..Player.PlayerData.gang.label.. " ^7- Grade: ^4" ..Player.PlayerData.gang.grade.name.." ^7- Level: ^4" ..Player.PlayerData.gang.grade.level.."")
	else 
		Player.Functions.SetGang("none", 0)
		TriggerClientEvent('chatMessage', src, "SYSTEM", "warning", "Your Gang: ^4"..Player.PlayerData.gang.label.. " ^7- Grade: ^4" ..Player.PlayerData.gang.grade.name.." ^7- Level: ^4" ..Player.PlayerData.gang.grade.level.."")
	end
end)

FvMain.Commands.Add("clearinv", "Clear the inventory of a player", {{name="id", help="Player ID"}}, false, function(source, args)
	local playerId = args[1] ~= nil and args[1] or source 
	local Player = FvMain.Functions.GetPlayer(tonumber(playerId))
	if Player ~= nil then
		Player.Functions.ClearInventory()
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

FvMain.Commands.Add("looc", "Local Out of Character message", {}, false, function(source, args)
	local message = table.concat(args, " ")
	TriggerClientEvent("FvMain:Client:LocalOutOfCharacter", -1, source, GetPlayerName(source), message)
	local Players = FvMain.Functions.GetPlayers()
	local Player = FvMain.Functions.GetPlayer(source)

	for k, v in pairs(FvMain.Functions.GetPlayers()) do
		if FvMain.Functions.HasPermission(v, "admin") then
			if FvMain.Functions.IsOptin(v) then
				--TriggerClientEvent('chatMessage', v, "OOC " .. GetPlayerName(source), "normal", message)
				TriggerEvent("fvm-log:server:CreateLog", "ooc", "Local OOC", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
			end
		end
	end
end)

FvMain.Commands.Add("addrep", "Add Reputation to a Player", {{name="id", help="ID of player"}, {name="type", help="dealer/crafting/atcrafting/weapondealer"}, {name="amount", help="Amount of Reputation"}}, false, function(source, args)
    local Player = FvMain.Functions.GetPlayer(tonumber(args[1]))
    
    if Player then 
        if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
            local x = tonumber(args[1])
            local y = args[2]
            local z = tonumber(args[3])

            if y == "dealer" then
                local newrep = Player.PlayerData.metadata["dealerrep"] + z
                Player.Functions.SetMetaData("dealerrep", newrep)
				TriggerClientEvent('chatMessage', -1, "BANHAMMER", "error", " has been banned for:")
                TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "You received reputation from admin - type of reputation: DEALER - your new reputation: ".. newrep .."")
            end
            if y == "crafting" then
                local newrep = Player.PlayerData.metadata["craftingrep"] + z
                Player.Functions.SetMetaData("craftingrep", newrep)
                TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "You received reputation from admin - type of reputation: CRAFTING - your new reputation: ".. newrep .."")
            end
            if y == "atcrafting" then
                local newrep  = Player.PlayerData.metadata["attachmentcraftingrep"]  + z
                Player.Functions.SetMetaData("attachmentcraftingrep", newrep)
                TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "You received reputation from admin - type of reputation: ATTACHMENT CRAFTING - your new reputation: ".. newrep .."")
            end
            if y == "weapondealer" then
                local newrep  = Player.PlayerData.metadata["wepdealerrep"]  + z
                Player.Functions.SetMetaData("wepdealerrep", newrep)
                TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "You received reputation from admin - type of reputation: WEAPON DEALER - your new reputation: ".. newrep .."")
            end
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Not every argument has been entered.")
        end
    else 
       TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not Online")
    end
end, "admin")

FvMain.Commands.Add("reputation", "Check your reputation", {}, false, function(source, args)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	local weapdealer = Player.PlayerData.metadata["wepdealerrep"]
	local attachment = Player.PlayerData.metadata["attachmentcraftingrep"]
	local crafting = Player.PlayerData.metadata["craftingrep"]
	local dealer = Player.PlayerData.metadata["dealerrep"]

	TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "Dealer reputation ".. dealer .."")
	TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "Crafting reputation ".. crafting .."")
	TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "Weapon Attachments reputation ".. attachment .."")
	TriggerClientEvent('chatMessage', Player.PlayerData.source, "SYSTEM", "error", "Weapon Dealer reputation ".. weapdealer .."")
end)