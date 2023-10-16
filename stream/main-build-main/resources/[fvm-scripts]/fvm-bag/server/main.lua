local serverBags = {}

FvMain.Functions.CreateUseableItem("bag", function(source, item)
    local Player = FvMain.Functions.GetPlayer(source)
    if item.bagId ~= nil then
        TriggerClientEvent("fvm-bag:open", source, item.bagId)
        TriggerEvent("fvm-log:server:CreateLog", "inventory", "BAG", "white", "Player Open The Bag **"..GetPlayerName(source).."** Citizen ID : **"..Player.PlayerData.citizenid.. "**", false)
    else
        print('Bag id is nill.')
    end
end)
