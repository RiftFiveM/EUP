-- Player joined

RegisterNetEvent('FvMain:PlayerJoined', function()
	local src = source
	SetPlayerRoutingBucket(src, 0)
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	if FvMain.Players[src] then
		local Player = FvMain.Players[src]
		TriggerEvent("fvm-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..Player.PlayerData.license..") left..")
		Player.Functions.Save()
		FvMain.Players[src] = nil
	end

	-- INFINITY UPDATE PLAYERS
	TriggerEvent('FvMain:Server:updatePlayers')
end)

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local license
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    Wait(0)

    deferrals.update(string.format("Welcome %s. Validating Your Rockstar License", name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    Wait(2500)

    deferrals.update(string.format("Welcome %s. We are checking your ban status.", name))
	
    local isBanned, Reason = FvMain.Functions.IsPlayerBanned(player)
    local isLicenseAlreadyInUse = FvMain.Functions.IsLicenseInUse(license)
	
    Wait(2500)
	
    deferrals.update(string.format("Welcome %s to ".. FVMConfig.ServerName ..".\nJoin without special symbols in name!", name))

	Wait(3000)

    if not license then
        deferrals.done('No Valid Rockstar License Found')
    elseif isBanned then
	    deferrals.done(Reason)
    elseif isLicenseAlreadyInUse then
        deferrals.done('Duplicate Rockstar License Found')
    else
        deferrals.done()
        Wait(1000)
        TriggerEvent("connectqueue:playerConnect", name, setKickReason, deferrals)
		TriggerEvent("fvm-log:server:CreateLog", "joinleave", "Queue", "orange", "**"..name .. "** ("..json.encode(GetPlayerIdentifiers(player))..") in queue..")
		TriggerEvent("fvm-log:server:sendLog", GetPlayerIdentifiers(player)[1], "left", {})
    end
end

AddEventHandler("playerConnecting", OnPlayerConnecting)

RegisterNetEvent('FvMain:server:CloseServer', function(reason)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    if FvMain.Functions.HasPermission(source, "admin") or FvMain.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason specified..."
        FvMain.Config.Server.closed = true
        FvMain.Config.Server.closedReason = reason
        TriggerClientEvent("fvm-admin:client:SetServerStatus", -1, true)
	else
		FvMain.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterNetEvent('FvMain:server:OpenServer', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    if FvMain.Functions.HasPermission(source, "admin") or FvMain.Functions.HasPermission(source, "god") then
        FvMain.Config.Server.closed = false
        TriggerClientEvent("fvm-admin:client:SetServerStatus", -1, false)
    else
        FvMain.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterNetEvent('FvMain:UpdatePlayer', function(data)
	local src = source
	local ped = GetPlayerPed(src)
	local Player = FvMain.Functions.GetPlayer(src)
	if Player then
		Player.PlayerData.position = GetEntityCoords(ped)
		local newHunger = Player.PlayerData.metadata["hunger"] - FVMConfig.Player.HungerRate
		local newThirst = Player.PlayerData.metadata["thirst"] - FVMConfig.Player.ThirstRate
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)
		Player.Functions.Save()
	end
end)

RegisterNetEvent("FvMain:UpdatePlayerPosition", function(position)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if Player then
		Player.PlayerData.position = position
	end
end)

RegisterNetEvent('FvMain:Server:TriggerCallback', function(name, ...)
	local src = source
	FvMain.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("FvMain:Client:TriggerCallback", src, name, ...)
	end, ...)
end)

RegisterNetEvent('FvMain:Server:UseItem', function(item)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if FvMain.Functions.CanUseItem(item.name) then
			FvMain.Functions.UseItem(src, item)
		end
	end
end)

RegisterNetEvent('FvMain:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterNetEvent('FvMain:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

RegisterNetEvent('FvMain:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player then
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = FvMain.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if FvMain.Commands.List[command] ~= nil then
			local Player = FvMain.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (FvMain.Functions.HasPermission(source, "god") or FvMain.Functions.HasPermission(source, FvMain.Commands.List[command].permission)) then
					if (FvMain.Commands.List[command].argsrequired and #FvMain.Commands.List[command].arguments ~= 0 and args[#FvMain.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out!")
					    local agus = ""
					    for name, help in pairs(FvMain.Commands.List[command].arguments) do
					    	agus = agus .. " ["..help.name.."]"
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						FvMain.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
				end
			end
		end
	end
end)

RegisterNetEvent('FvMain:CallCommand', function(command, args)
	if FvMain.Commands.List[command] ~= nil then
		local Player = FvMain.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (FvMain.Functions.HasPermission(source, "god")) or (FvMain.Functions.HasPermission(source, FvMain.Commands.List[command].permission)) or (FvMain.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (FvMain.Commands.List[command].argsrequired and #FvMain.Commands.List[command].arguments ~= 0 and args[#FvMain.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out!")
					local agus = ""
					for name, help in pairs(FvMain.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					FvMain.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
			end
		end
	end
end)

RegisterNetEvent('FvMain:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	FvMain.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterNetEvent('FvMain:ToggleDuty', function()
	local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('FvMain:Notify', src, "You are now off duty!")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('FvMain:Notify', src, "You are now on duty!")
	end
	TriggerClientEvent("FvMain:Client:SetDuty", src, Player.PlayerData.job.onduty)
end)

RegisterNetEvent('FvMain:Command:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		local result = exports['ghmattimysql']:executeSync('SELECT * FROM player_vehicles WHERE plate=@plate', {['@plate'] = VehiclePlate})
		if result[1] ~= nil then
			exports.ghmattimysql:execute('UPDATE player_vehicles SET state=@state WHERE citizenid=@citizenid', {['@state'] = 1, ['@citizenid'] = result[1].citizenid})
			TriggerEvent('fvm-garages:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
		end
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	local result = exports['ghmattimysql']:executeSync('SELECT * FROM permissions')
	if result[1] ~= nil then
		for k, v in pairs(result) do
			FvMain.Config.Server.PermissionList[v.license] = {
				license = v.license,
				permission = v.permission,
				optin = true,
			}
		end
	end
end)

FvMain.Functions.CreateCallback('FvMain:HasItem', function(source, cb, items, amount)
	local retval = false
	local Player = FvMain.Functions.GetPlayer(source)
	if Player ~= nil then
		if type(items) == 'table' then
			local count = 0
            local finalcount = 0
			for k, v in pairs(items) do
				if type(k) == 'string' then
                    finalcount = 0
                    for i, _ in pairs(items) do
                        if i then finalcount = finalcount + 1 end
                    end
					local item = Player.Functions.GetItemByName(k)
					if item ~= nil then
						if item.amount >= v then
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				else
                    finalcount = #items
					local item = Player.Functions.GetItemByName(v)
					if item ~= nil then
						if amount ~= nil then
							if item.amount >= amount then
								count = count + 1
								if count == finalcount then
									retval = true
								end
							end
						else
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				end
			end
		else
			local item = Player.Functions.GetItemByName(items)
			if item ~= nil then
				if amount ~= nil then
					if item.amount >= amount then
						retval = true
					end
				else
					retval = true
				end
			end
		end
	end
	cb(retval)
end)

FvMain.Functions.CreateCallback('FvMain:GetPlayersInfinity', function(source, cb)
	local players = {}
	for k, id in pairs(GetPlayers()) do
		local playerId = tonumber(id)
		local playerName = GetPlayerName(id)
		local playerPed = GetPlayerPed(id)
		local playerCoords = GetEntityCoords(playerPed)

		table.insert(players, {
			id = playerId,
			name = playerName,
			ped = playerPed,
			coords = playerCoords
		})

	end
	
	cb(players)
end)

RegisterNetEvent('FvMain:client:updatePlayers', function(players)
	FvMain.Players = players
end)

RegisterNetEvent("FvMain:Server:updatePlayersCoords", function()
	local newTable = {}
    for k, v in pairs(FvMain.Functions.GetPlayers()) do --FvMain.Players
        local playerServerId = v
        local Player = FvMain.Functions.GetPlayer(v)
        local ped = GetPlayerPed(v)
        if(DoesEntityExist(ped)) then
            local playerCoords = GetEntityCoords(ped)
			local playerHeading = GetEntityHeading(ped)
			local playerName = GetPlayerName(v)
			if Player ~= nil then
				newTable[playerServerId] = {}
				table.insert(newTable[playerServerId], 
				{
					x = playerCoords.x,
					y = playerCoords.y,
					z = playerCoords.z,
					a = playerHeading,
					name = playerName,
					ped = ped,

				})
			end
        end
	end
	TriggerClientEvent('FvMain:client:updatePlayersCoords', -1, newTable)
end)