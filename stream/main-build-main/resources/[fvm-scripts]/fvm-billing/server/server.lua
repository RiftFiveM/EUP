FvMain.Commands.Add("createbill", "Bill Player", {{name="true/false", help="Type true if its company bill"}, {name="id", help="Player ID"}, {name="amount", help="Fine Amount"}, {name="reason", help="Reason of the bill"}}, false, function(source, args)
    local src = source
    local Player = FvMain.Functions.GetPlayer(src)
    local OtherPlayer = FvMain.Functions.GetPlayer(tonumber(args[2]))
    
    if OtherPlayer ~= nil then
        name = OtherPlayer.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
        citizenid = OtherPlayer.PlayerData.citizenid
        job = Player.PlayerData.job
        companybill = tostring(args[1])
        playerId = tonumber(args[2])
        price = tonumber(args[3])

        table.remove(args, 1)
        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        if price and price > 0 then
            if companybill == "true" then
                TriggerClientEvent("fvm-billing:sendbill", playerId, name, price, reason, citizenid, job)
                TriggerClientEvent('chatMessage', src, "SYSTEM", "inform", "You sent companybill to ".. name .." with ".. price .."$ for ".. reason ..".")

                FvMain.Functions.ExecuteSql(false, "INSERT INTO `phone_invoices` (`citizenid`, `amount`, `society`, `title`) VALUES ('" .. citizenid .. "', " .. price .. ", '" .. Player.PlayerData.job.name .. "', '" .. reason .. "')", function()
                    TriggerClientEvent("fvm-phone:RefreshPhone", OtherPlayer.PlayerData.source)
                end)
            else
                TriggerClientEvent("fvm-billing:sendbill", playerId, name, price, reason, citizenid)
                TriggerClientEvent('chatMessage', src, "SYSTEM", "inform", "You sent bill to ".. name .." with ".. price .."$ for ".. reason ..".")
            end
        else
            TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Invalid amount.")
        end
    else
        TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Invalid Player ID!")
    end
end)

RegisterNetEvent('fvm-billing:paybill')
AddEventHandler('fvm-billing:paybill',function(data)
    local Player = FvMain.Functions.GetPlayer(source)
    local OtherPlayer = FvMain.Functions.GetPlayerByCitizenId(data[2])
    local bank = Player.PlayerData.money.bank
    local cash = Player.PlayerData.money.cash
    local name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    local rsender = ""
    local checkmsg = ""
    
    if Player ~= nil then
        if cash >= data[1] or bank >= data[1] then
            if bank >= data[1] then
                Player.Functions.RemoveMoney("bank", data[1], "paid-bill")
            else 
                Player.Functions.RemoveMoney("cash", data[1], "paid-bill")
            end

            if OtherPlayer ~= nil then
                if data[5] ~= nil then
                    rsender = data[5].label
                    checkmsg = "Payment was sent to ".. data[5].label .." society account."
                    TriggerEvent("fvm-society:bossmenu:server:addAccountMoney", data[5].name , data[1])
                else
                    rsender = name
                    checkmsg = "Payment was sent to your bank account."
                    OtherPlayer.Functions.AddMoney("bank", data[1], "recieved-bill")
                end

                TriggerEvent('fvm-phone:server:sendNewMailToOffline', OtherPlayer.PlayerData.citizenid, {
                    sender = "".. name .."",
                    subject = "Bill payment",
                    message = "Payment for the invoice was sent,<br>Sender name: "..Player.PlayerData.charinfo.firstname.. " ".. Player.PlayerData.charinfo.lastname .." <br>Amount: ".. data[1] .."$<br>Reason: ".. data[3] ..".<br><br>".. checkmsg .."",
                })
            end
        else
            -- if he got no money
        end
    end
end)
