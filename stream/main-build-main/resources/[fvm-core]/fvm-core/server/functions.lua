FvMain.Functions = {}

FvMain.Functions.ExecuteSql = function(wait, query, cb)
	local rtndata = {}
	local waiting = true
	exports['ghmattimysql']:execute(query, {}, function(data)
		if cb ~= nil and wait == false then
			cb(data)
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata)
		end
	end
	return rtndata
end

FvMain.Functions.GetIdentifier = function(source, idtype)
	local src = source
	local idtype = idtype or FVMConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(src)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

FvMain.Functions.GetSource = function(identifier)
	for src, player in pairs(FvMain.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

FvMain.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return FvMain.Players[source]
	else
		return FvMain.Players[FvMain.Functions.GetSource(source)]
	end
end

FvMain.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(FvMain.Players) do
		local cid = citizenid
		if FvMain.Players[src].PlayerData.citizenid == cid then
			return FvMain.Players[src]
		end
	end
	return nil
end

FvMain.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(FvMain.Players) do
		local cid = citizenid
		if FvMain.Players[src].PlayerData.charinfo.phone == number then
			return FvMain.Players[src]
		end
	end
	return nil
end

FvMain.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(FvMain.Players) do
		table.insert(sources, k)
	end
	return sources
end

-- Will return an array of FVM Player class instances
-- unlike the GetPlayers() wrapper which only returns IDs
FvMain.Functions.GetFVMPlayers = function()
	return FvMain.Players
end

FvMain.Functions.CreateCallback = function(name, cb)
	FvMain.ServerCallbacks[name] = cb
end

FvMain.Functions.TriggerCallback = function(name, source, cb, ...)
	if FvMain.ServerCallbacks[name] ~= nil then
		FvMain.ServerCallbacks[name](source, cb, ...)
	end
end

FvMain.Functions.CreateUseableItem = function(item, cb)
	FvMain.UseableItems[item] = cb
end

FvMain.Functions.CanUseItem = function(item)
	return FvMain.UseableItems[item] ~= nil
end

FvMain.Functions.UseItem = function(source, item)
	FvMain.UseableItems[item.name](source, item)
end

FvMain.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check our Discord for further information: "..FvMain.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

FvMain.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (FvMain.Config.Server.whitelist) then
		local result = exports['ghmattimysql']:executeSync('SELECT * FROM whitelist WHERE license=@license', {['@license'] = FvMain.Functions.GetIdentifier(source, 'license')})
		local data = result[1]
		if data ~= nil then
			for _, id in pairs(identifiers) do
				if data.license == id then
					rtn = true
				end
			end
		end
	else
		rtn = true
	end
	return rtn
end

FvMain.Functions.AddPermission = function(source, permission)
	local Player = FvMain.Functions.GetPlayer(source)
	if Player then
		FvMain.Config.Server.PermissionList[FvMain.Functions.GetIdentifier(source, 'license')] = {
			license = FvMain.Functions.GetIdentifier(source, 'license'),
			permission = permission:lower(),
		}
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = FvMain.Functions.GetIdentifier(source, 'license')})

		exports['ghmattimysql']:execute('INSERT INTO permissions (name, license, permission) VALUES (@name, @license, @permission)', {
			['@name'] = GetPlayerName(source),
			['@license'] = FvMain.Functions.GetIdentifier(source, 'license'),
			['@permission'] = permission:lower()
		})

		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('FvMain:Client:OnPermissionUpdate', source, permission)
	end
end

FvMain.Functions.RemovePermission = function(source)
	local Player = FvMain.Functions.GetPlayer(source)
	if Player then
		FvMain.Config.Server.PermissionList[FvMain.Functions.GetIdentifier(source, 'license')] = nil	
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = FvMain.Functions.GetIdentifier(source, 'license')})
		Player.Functions.UpdatePlayerData()
	end
end

FvMain.Functions.HasPermission = function(source, permission)
	local retval = false
	local license = FvMain.Functions.GetIdentifier(source, 'license')
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if FvMain.Config.Server.PermissionList[license] ~= nil then 
			if FvMain.Config.Server.PermissionList[license].license == license then
				if FvMain.Config.Server.PermissionList[license].permission == permission or FvMain.Config.Server.PermissionList[license].permission == "god" then
					retval = true
				end
			end
		end
	end
	return retval
end

FvMain.Functions.GetPermission = function(source)
	local retval = "user"
	Player = FvMain.Functions.GetPlayer(source)
	local license = FvMain.Functions.GetIdentifier(source, 'license')
	if Player ~= nil then
		if FvMain.Config.Server.PermissionList[Player.PlayerData.license] ~= nil then 
			if FvMain.Config.Server.PermissionList[Player.PlayerData.license].license == license then
				retval = FvMain.Config.Server.PermissionList[Player.PlayerData.license].permission
			end
		end
	end
	return retval
end

FvMain.Functions.IsOptin = function(source)
	local retval = false
	local license = FvMain.Functions.GetIdentifier(source, 'license')
	if FvMain.Functions.HasPermission(source, "admin") then
		retval = FvMain.Config.Server.PermissionList[license].optin
	end
	return retval
end

FvMain.Functions.ToggleOptin = function(source)
	local license = FvMain.Functions.GetIdentifier(source, 'license')
	if FvMain.Functions.HasPermission(source, "admin") then
		FvMain.Config.Server.PermissionList[license].optin = not FvMain.Config.Server.PermissionList[license].optin
	end
end

FvMain.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
    local result = exports.ghmattimysql:executeSync('SELECT * FROM bans WHERE license=@license', {['@license'] = FvMain.Functions.GetIdentifier(source, 'license')})
    if result[1] ~= nil then
        if os.time() < result[1].expire then
            retval = true
            local timeTable = os.date("*t", tonumber(result.expire))
            message = "You have been banned from the server:\n"..result[1].reason.."\nYour ban expires "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
        else
            exports['ghmattimysql']:execute('DELETE FROM bans WHERE id=@id', {['@id'] = result[1].id})
        end
    end
	return retval, message
end

FvMain.Functions.IsLicenseInUse = function(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                local playerLicense = id
                if playerLicense == license then
                    return true
                end
            end
        end
    end
    return false
end
