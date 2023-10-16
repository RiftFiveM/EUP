local data = {}

RegisterNetEvent('fvm-billing:sendbill')
AddEventHandler('fvm-billing:sendbill',function(name,price,reason,citizenid,job)
    table.insert(data,price)
    table.insert(data,citizenid)
    table.insert(data,reason)
    table.insert(data,name)
    table.insert(data,job)

    pressmsg = "Press the button below to accept the bill."
    if data[5] ~= nil then
        data[4] = data[5].label
        pressmsg = "Check your banking application."
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = data[4],
            subject = "Bill",
            message = "You have received a bill from ".. data[4] ..",<br><br>Bill information<br>Amount $"..price.."<br>Reason: "..reason.."<br><br> ".. pressmsg .."",
        })
    else 
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = data[4],
            subject = "Bill",
            message = "You have received a bill from ".. data[4] ..",<br><br>Bill information<br>Amount $"..price.."<br>Reason: "..reason.."<br><br> ".. pressmsg .."",
            button = {
                enabled = true,
                buttonEvent = "billing:client:AcceptBill",
                buttonData = data
            }
        })
    end
    data = {}
end)

RegisterNetEvent('billing:client:AcceptBill')
AddEventHandler('billing:client:AcceptBill',function(data)
    local Player = FvMain.Functions.GetPlayerData()
    local bank = Player.money['bank'] 
    local cash = Player.money['cash'] 

    if bank >= data[1] or cash >= data[1] then
        FvMain.Functions.Notify("You paid the bill for $"..data[1])
        TriggerServerEvent('fvm-billing:paybill',data)
    else
        TriggerServerEvent('fvm-phone:server:sendNewMail', {
            sender = data[4],
            subject = "Bill",
            message = "You have received a bill from ".. data[4] ..",<br><br>Bill information<br>Amount $"..price.."<br>Reason: "..reason.."<br><br> Press the button below to accept the bill.",
            button = {
                enabled = true,
                buttonEvent = "billing:client:AcceptBill",
                buttonData = data
            }
        })
        data = {}
    end
end)