FvMain.Commands.Add("setcryptoworth", "Set crypto value", {{name="crypto", help="Name of the crypto currency"}, {name="Value", help="New value of the crypto currency"}}, false, function(source, args)
    local src = source
    local crypto = tostring(args[1])

    if crypto ~= nil then
        if Crypto.Worth[crypto] ~= nil then
            local NewWorth = math.ceil(tonumber(args[2]))
            
            if NewWorth ~= nil then
                local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
                local ChangeLabel = "+"
                if PercentageChange < 0 then
                    ChangeLabel = "-"
                    PercentageChange = (PercentageChange * -1)
                end
                if Crypto.Worth[crypto] == 0 then
                    PercentageChange = 0
                    ChangeLabel = ""
                end

                table.insert(Crypto.History[crypto], {
                    PreviousWorth = Crypto.Worth[crypto],
                    NewWorth = NewWorth
                })

                TriggerClientEvent('FvMain:Notify', src, "You have the value of "..Crypto.Labels[crypto].."adapted from: ($"..Crypto.Worth[crypto].." to: $"..NewWorth..") ("..ChangeLabel.." "..PercentageChange.."%)")
                Crypto.Worth[crypto] = NewWorth
                TriggerClientEvent('fvm-crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
                FvMain.Functions.ExecuteSql(false, "UPDATE `crypto` SET `worth` = '"..NewWorth.."', `history` = '"..json.encode(Crypto.History[crypto]).."' WHERE `crypto` = '"..crypto.."'")
            else
                TriggerClientEvent('FvMain:Notify', src, "You have not given a new value .. Current values: "..Crypto.Worth[crypto])
            end
        else
            TriggerClientEvent('FvMain:Notify', src, "This Crypto does not exist :(, available: Qbit")
        end
    else
        TriggerClientEvent('FvMain:Notify', src, "You have not provided Crypto, available: Qbit")
    end
end, "admin")

FvMain.Commands.Add("checkcryptoworth", "", {}, false, function(source, args)
    local src = source
    TriggerClientEvent('FvMain:Notify', src, "The Qbit has a value of: $"..Crypto.Worth["fbit"])
end, "admin")

FvMain.Commands.Add("crypto", "", {}, false, function(source, args)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local MyPocket = math.ceil(Player.PlayerData.money.crypto * Crypto.Worth["fbit"])

    TriggerClientEvent('FvMain:Notify', src, "You have: "..Player.PlayerData.money.crypto.." Fbit, with a value of: $"..MyPocket..",-")
end, "admin")

RegisterServerEvent('fvm-crypto:server:FetchWorth')
AddEventHandler('fvm-crypto:server:FetchWorth', function()
    for name,_ in pairs(Crypto.Worth) do
        FvMain.Functions.ExecuteSql(false, "SELECT * FROM `crypto` WHERE `crypto` = '"..name.."'", function(result)
            if result[1] ~= nil then
                Crypto.Worth[name] = result[1].worth
                if result[1].history ~= nil then
                    Crypto.History[name] = json.decode(result[1].history)
                    TriggerClientEvent('fvm-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, json.decode(result[1].history))
                else
                    TriggerClientEvent('fvm-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, nil)
                end
            end
        end)
    end
end)

RegisterServerEvent('fvm-crypto:server:ExchangeFail')
AddEventHandler('fvm-crypto:server:ExchangeFail', function()
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        Player.Functions.RemoveItem("cryptostick", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('FvMain:Notify', src, "Attempt failed, the stick crashed ..", 'error', 5000)
    end
end)

RegisterServerEvent('fvm-crypto:server:Rebooting')
AddEventHandler('fvm-crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('fvm-crypto:server:GetRebootState')
AddEventHandler('fvm-crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('fvm-crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('fvm-crypto:server:SyncReboot')
AddEventHandler('fvm-crypto:server:SyncReboot', function()
    TriggerClientEvent('fvm-crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('fvm-crypto:server:ExchangeSuccess')
AddEventHandler('fvm-crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 1000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        Player.Functions.RemoveItem("cryptostick", 1)
        Player.Functions.AddMoney('crypto', Amount)
        TriggerClientEvent('FvMain:Notify', src, "You have exchanged your Cryptostick for: "..Amount.." Fbit(\'s)", "success", 3500)
        TriggerClientEvent('inventory:client:ItemBox', src, FvMain.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('fvm-phone:client:AddTransaction', src, Player, {}, "There are "..Amount.." Qbit('s) credited!", "Credit")
    end
end)

FvMain.Functions.CreateCallback('fvm-crypto:server:HasSticky', function(source, cb)
    local Player = FvMain.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("cryptostick")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

FvMain.Functions.CreateCallback('fvm-crypto:server:GetCryptoData', function(source, cb, name)
    local Player = FvMain.Functions.GetPlayer(source)
    local CryptoData = {
        History = Crypto.History[name],
        Worth = Crypto.Worth[name],
        Portfolio = Player.PlayerData.money.crypto,
        WalletId = Player.PlayerData.metadata["walletid"],
    }

    cb(CryptoData)
end)

FvMain.Functions.CreateCallback('fvm-crypto:server:BuyCrypto', function(source, cb, data)
    local Player = FvMain.Functions.GetPlayer(source)

    if Player.PlayerData.money.bank >= tonumber(data.Price) then
        local CryptoData = {
            History = Crypto.History["fbit"],
            Worth = Crypto.Worth["fbit"],
            Portfolio = Player.PlayerData.money.crypto + tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('bank', tonumber(data.Price))
        TriggerClientEvent('fvm-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) purchased!", "Credit")
        Player.Functions.AddMoney('crypto', tonumber(data.Coins))
        cb(CryptoData)
    else
        cb(false)
    end
end)

FvMain.Functions.CreateCallback('fvm-crypto:server:SellCrypto', function(source, cb, data)
    local Player = FvMain.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["fbit"],
            Worth = Crypto.Worth["fbit"],
            Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('fvm-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) sold!", "Depreciation")
        Player.Functions.AddMoney('bank', tonumber(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end
end)

FvMain.Functions.CreateCallback('fvm-crypto:server:TransferCrypto', function(source, cb, data)
    local Player = FvMain.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        FvMain.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `metadata` LIKE '%"..data.WalletId.."%'", function(result)
            if result[1] ~= nil then
                local CryptoData = {
                    History = Crypto.History["fbit"],
                    Worth = Crypto.Worth["fbit"],
                    Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
                    WalletId = Player.PlayerData.metadata["walletid"],
                }
                Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('fvm-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) transferred!", "Depreciation")
                local Target = FvMain.Functions.GetPlayerByCitizenId(result[1].citizenid)

                if Target ~= nil then
                    Target.Functions.AddMoney('crypto', tonumber(data.Coins))
                    TriggerClientEvent('fvm-phone:client:AddTransaction', Target.PlayerData.source, Player, data, "There are "..tonumber(data.Coins).." Qbit('s) credited!", "Credit")
                else
                    MoneyData = json.decode(result[1].money)
                    MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                    FvMain.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(MoneyData).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                end
                cb(CryptoData)
            else
                cb("notvalid")
            end
        end)
    else
        cb("notenough")
    end
end)