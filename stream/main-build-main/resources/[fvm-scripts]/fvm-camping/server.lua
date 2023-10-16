                                                                                                                         
FvMain = nil
TriggerEvent('FvMain:GetObject', function(obj) FvMain = obj end)

FvMain.Functions.CreateUseableItem("campingset", function(source, item)
	 local xPlayer = FvMain.Functions.GetPlayer(source)
	 xPlayer.Functions.RemoveItem("campingset", 1)
    TriggerClientEvent('fvm-camping', source)   
end)

RegisterServerEvent('fvm-camping:itemback')
AddEventHandler('fvm-camping:itemback',function()
	local xPlayer = FvMain.Functions.GetPlayer(source)
	xPlayer.Functions.AddItem("campingset", 1)
end)

RegisterServerEvent('fvm-camping:control')
AddEventHandler('fvm-camping:control',function()
	TriggerClientEvent("fvm-camping:createobject",source,'prop_beach_fire','prop_skid_tent_01','prop_skid_chair_02')
end)
