local BankStatus = {}

RegisterServerEvent('fvm-banking:server:SetBankClosed')
AddEventHandler('fvm-banking:server:SetBankClosed', function(BankId, bool)
  print(BankId)
  BankStatus[BankId] = bool
  TriggerClientEvent('fvm-banking:client:SetBankClosed', -1, BankId, bool)
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
    local src = source
    local ply = FvMain.Functions.GetPlayer(src)
    local bankamount = ply.PlayerData.money["bank"]
    local amount = tonumber(amount)
    if bankamount >= amount and amount > 0 then
      ply.Functions.RemoveMoney('bank', amount, "Bank withdraw")
      TriggerEvent("fvm-log:server:CreateLog", "banking", "Withdraw", "red", "**"..GetPlayerName(src) .. "** has $"..amount.." withdrawn from this bank.")
      ply.Functions.AddMoney('cash', amount, "Bank withdraw")
    else
      TriggerClientEvent('FvMain:Notify', src, 'You don\'t have enough money in your bank.', 'error')
    end
end)

RegisterServerEvent('bank:balance')
AddEventHandler('bank:balance', function()
	local src = source
  local ply = FvMain.Functions.GetPlayer(src)
	balance = ply.PlayerData.money["bank"]
	TriggerClientEvent('banking:updateBalance', src, balance, true)
	TriggerClientEvent('banking:viewBalance', src)
	
end)


RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
    local src = source
    local ply = FvMain.Functions.GetPlayer(src)
    local cashamount = ply.PlayerData.money["cash"]
    local amount = tonumber(amount)
    if cashamount >= amount and amount > 0 then
      ply.Functions.RemoveMoney('cash', amount, "Bank depost")
      TriggerEvent("fvm-log:server:CreateLog", "banking", "Deposit", "green", "**"..GetPlayerName(src) .. "** has $"..amount.." Deposit into this bank.")
      ply.Functions.AddMoney('bank', amount, "Bank depost")
    else
      TriggerClientEvent('FvMain:Notify', src, 'You don\'t have enough money in your pocket.', 'error')
    end
end)

FvMain.Commands.Add("givecash", "Give money to a person", {{name="id", help="Player ID"},{name="amount", help="Amount of money"}}, true, function(source, args)
  local Player = FvMain.Functions.GetPlayer(source)
  local TargetId = tonumber(args[1])
  local Target = FvMain.Functions.GetPlayer(TargetId)
  local amount = tonumber(args[2])
  
  if Target ~= nil then
    if amount ~= nil then
      if amount > 0 then
        if Player.PlayerData.money.cash >= amount and amount > 0 then
          if TargetId ~= source then
            TriggerClientEvent('banking:client:CheckDistance', source, TargetId, amount)
          else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You can't give money to yourself.")     
          end
        else
          TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You do not have enough money.")
        end
      else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Quantity must be greater than 0.")
      end
    else
      TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Fill an amount.")
    end
  else
    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Citizen is not in the city.")
  end    
end)

RegisterServerEvent('banking:server:giveCash')
AddEventHandler('banking:server:giveCash', function(trgtId, amount)
  local src = source
  local Player = FvMain.Functions.GetPlayer(src)
  local Target = FvMain.Functions.GetPlayer(trgtId)

  if src ~= trgtId then
    Player.Functions.RemoveMoney('cash', amount, "Cash given to "..Player.PlayerData.citizenid)
    Target.Functions.AddMoney('cash', amount, "Cash received from "..Target.PlayerData.citizenid)

    TriggerEvent("fvm-log:server:CreateLog", "banking", "Give money", "blue", "**"..GetPlayerName(src) .. "** has $"..amount.." given to **" .. GetPlayerName(trgtId) .. "**")
    
    TriggerClientEvent('FvMain:Notify', trgtId, "You received $"..amount.." from "..Player.PlayerData.charinfo.firstname.."!", 'success')
    TriggerClientEvent('FvMain:Notify', src, "You gave $"..amount.." to "..Target.PlayerData.charinfo.firstname.."!", 'success')
  else
    -- ban event?
  end
end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(trgtId, amount)
	local src = source
  local Player = FvMain.Functions.GetPlayer(src)
  local Target = FvMain.Functions.GetPlayer(trgtId)
	if Player == nil then return end
	if Target ~= nil then
  local balance = 0
  local balance = Player.PlayerData.money["bank"]

	
  if tonumber(src) == tonumber(trgtId) then
    --x
	  else
		  if balance <= 0 or balance < tonumber(amount) or tonumber(amount) <= 0 then

      TriggerClientEvent('FvMain:Notify', src, "Invalid quantity", 'error')

		  else
			Player.Functions.RemoveMoney('bank', tonumber(amount))
			Target.Functions.AddMoney('bank', tonumber(amount))

      TriggerClientEvent('FvMain:Notify', trgtId, "You received $"..amount.." from "..Player.PlayerData.charinfo.firstname.."!", 'success')
      TriggerClientEvent('FvMain:Notify', src, "You gave $"..amount.." to "..Target.PlayerData.charinfo.firstname.."!", 'success')
		  end
		
	  end
  else
    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Invalid account!")
  end
end)