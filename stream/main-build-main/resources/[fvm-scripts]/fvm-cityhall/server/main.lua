RegisterServerEvent('fvm-cityhall:server:requestId')
AddEventHandler('fvm-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    local licenses = {
        ["driver"] = true,
        ["business"] = false
    }

    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "A1-A2-A | AM-B | C1-C-CE"
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)

    TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items[identityData.item], 'add')
end)

RegisterServerEvent('fvm-cityhall:server:sendDriverTest')
AddEventHandler('fvm-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    
    for k, v in pairs(Config.DrivingInstructors) do 
        local SchoolPlayer = FvMain.Functions.GetPlayerByCitizenId(v)
        if SchoolPlayer ~= nil then 

            TriggerEvent('fvm-phone:server:sendNewMailToOffline', v, {
                sender = "City Hall",
                subject = "Request driving lessons",
                message = "We just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact him:<br />Name: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "</strong><br />Phone number: <strong>"..Player.PlayerData.charinfo.phone.."</strong> <br/><br/>Kind regards,<br/>City Hall Los Santos",
            })
        else
            TriggerEvent('fvm-phone:server:sendNewMailToOffline', v, {
                sender = "City Hall",
                subject = "Request driving lessons",
                message = "We just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact him:<br />Name: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "</strong><br />Phone number: <strong>"..Player.PlayerData.charinfo.phone.."</strong> <br/><br/>Kind regards,<br/>City Hall Los Santos",
            })
        end
    end
    TriggerClientEvent('FvMain:Notify', src, 'An email has been sent to driving schools, you will be contacted when they can', "success", 5000)
end)

local AvailableJobs = {
    "trucker",
    "taxi",
    "tow",
    "reporter",
    "garbage",
    "butcher",
    "gopostal",
    "security",
}

function IsAvailableJob(job)
    local retval = false
    for k, v in pairs(AvailableJobs) do
        if v == job then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('fvm-cityhall:server:ApplyJob')
AddEventHandler('fvm-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local ped = GetPlayerPed(src)
    local PedCoords = GetEntityCoords(ped)
    local JobInfo = FvMain.Shared.Jobs[job]

    if #(PedCoords - Config.Cityhall.coords) >= 20.0 or not IsAvailableJob(job) then
        return DropPlayer(source, "Attempted exploit abuse")
    end

    Player.Functions.SetJob(job, 0)
    TriggerClientEvent('FvMain:Notify', src, 'Congratulations with your new job! ('..JobInfo.label..')')
end)


FvMain.Commands.Add("givedrivinglicense", "Give a drivers license to a person", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = FvMain.Functions.GetPlayer(source)
    if IsWhitelistedSchool(Player.PlayerData.citizenid) or (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "sheriff") then
        local SearchedPlayer = FvMain.Functions.GetPlayer(tonumber(args[1]))
        if SearchedPlayer ~= nil then
            local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
            if not driverLicense then
                local licenses = {
                    ["driver"] = true,
                    ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
                }
                SearchedPlayer.Functions.SetMetaData("licences", licenses)
                TriggerClientEvent('FvMain:Notify', SearchedPlayer.PlayerData.source, "You are allowed to request driving license at cityhall.", "success", 5000)
            else
                TriggerClientEvent('FvMain:Notify', src, "Cannot give driver license..", "error")
            end
        end
    else
        TriggerClientEvent('FvMain:Notify', src, "You don't have access to this command.", "error")
    end
end)

function IsWhitelistedSchool(citizenid)
    local retval = false
    for k, v in pairs(Config.DrivingInstructors) do 
        if v == citizenid then
            retval = true
        end
    end
    return retval
end
