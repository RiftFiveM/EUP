FvMain.Commands.Add("skin", "Open Clothing Menu", {}, false, function(source, args)
	TriggerClientEvent("fvm-clothing:client:openMenu", source)
end, "admin")

RegisterServerEvent("fvm-clothing:saveSkin")
AddEventHandler('fvm-clothing:saveSkin', function(model, skin)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    if model ~= nil and skin ~= nil then
        print('Save skin called.')
        FvMain.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(results)
            if results[1] ~= nil then
                FvMain.Functions.ExecuteSql(false, "UPDATE `playerskins` SET `model` = '"..model.."', `skin` = '"..skin.."', `active` = 1 WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
            else
                FvMain.Functions.ExecuteSql(false, "INSERT INTO `playerskins` (`citizenid`, `model`, `skin`, `active`) VALUES ('"..Player.PlayerData.citizenid.."', '"..model.."', '"..skin.."', 1)")
            end
        end)
    end
end)

RegisterServerEvent("fvm-clothes:loadPlayerSkin")
AddEventHandler('fvm-clothes:loadPlayerSkin', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            TriggerClientEvent("fvm-clothes:loadSkin", src, false, result[1].model, result[1].skin)
        else
            TriggerClientEvent("fvm-clothes:loadSkin", src, true)
        end
    end)
end)

RegisterServerEvent("fvm-clothes:saveOutfit")
AddEventHandler("fvm-clothes:saveOutfit", function(outfitName, model, skinData)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = "outfit-"..math.random(1, 10).."-"..math.random(1111, 9999)
        FvMain.Functions.ExecuteSql(false, "INSERT INTO `player_outfits` (`citizenid`, `outfitname`, `model`, `skin`, `outfitId`) VALUES ('"..Player.PlayerData.citizenid.."', '"..outfitName.."', '"..model.."', '"..json.encode(skinData).."', '"..outfitId.."')", function()
            FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
                if result[1] ~= nil then
                    TriggerClientEvent('fvm-clothing:client:reloadOutfits', src, result)
                else
                    TriggerClientEvent('fvm-clothing:client:reloadOutfits', src, nil)
                end
            end)
        end)
    end
end)

RegisterServerEvent("fvm-clothing:server:removeOutfit")
AddEventHandler("fvm-clothing:server:removeOutfit", function(outfitName, outfitId)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)

    FvMain.Functions.ExecuteSql(false, "DELETE FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `outfitname` = '"..outfitName.."' AND `outfitId` = '"..outfitId.."'", function()
        FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
            if result[1] ~= nil then
                TriggerClientEvent('fvm-clothing:client:reloadOutfits', src, result)
            else
                TriggerClientEvent('fvm-clothing:client:reloadOutfits', src, nil)
            end
        end)
    end)
end)

FvMain.Functions.CreateCallback('fvm-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local anusVal = {}

    FvMain.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                result[k].skin = json.decode(result[k].skin)
                anusVal[k] = v
            end
            cb(anusVal)
        end
        cb(anusVal)
    end)
end)

FvMain.Functions.CreateUseableItem("backpack", function(source, item)
    local src = source
	local Player = FvMain.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
        TriggerClientEvent('fvm-clothing:client:openOutfitMenu', src)
	end
end)

FvMain.Commands.Add("hat", "Take your helmet / cap / hat on or off", {}, false, function(source, args)
    TriggerClientEvent("fvm-clothing:client:adjustfacewear", source, 1)
end)

FvMain.Commands.Add("glasses", "Take your glasses on or off", {}, false, function(source, args)
	TriggerClientEvent("fvm-clothing:client:adjustfacewear", source, 2)
end)

FvMain.Commands.Add("mask", "Take your mask on or off", {}, false, function(source, args)
	TriggerClientEvent("fvm-clothing:client:adjustfacewear", source, 4)
end)