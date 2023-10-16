FvMain.Functions.StartPayCheck = function()
    GivePayCheck = function()
        local Players = FvMain.Functions.GetPlayers()

        for i=1, #Players, 1 do
            local Player = FvMain.Functions.GetPlayer(Players[i])

            if Player.PlayerData.job ~= nil and Player.PlayerData.job.payment > 0 then
                Player.Functions.AddMoney('bank', Player.PlayerData.job.payment)
                TriggerClientEvent('FvMain:Notify', Players[i], "You received your paycheck of $"..Player.PlayerData.job.payment)
            end
        end
        SetTimeout(FvMain.Config.Money.PayCheckTimeOut * (60 * 1000), GivePayCheck)
    end
    SetTimeout(FvMain.Config.Money.PayCheckTimeOut * (60 * 1000), GivePayCheck)
end