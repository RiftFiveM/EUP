RegisterNetEvent("fvm-bag:open")
AddEventHandler("fvm-bag:open", function(bagId)
	local ped = PlayerPedId()
    local dict = "mini@triathlon"
    loadAnimDict(dict)
    TaskPlayAnim(ped, dict, "rummage_bag", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "invbag", 0.5)
    FvMain.Functions.Progressbar("use_bag", "Opening bag", 5000, false, true, 
    {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {}, {}, {}, function() -- Done
        local BagData = {
            outfitData = {
                ["bag"]   = { item = 44, texture = 0}, 
            }
        }
        TriggerEvent('fvm-clothing:client:loadOutfit', BagData)

        TriggerServerEvent("inventory:server:OpenInventory", "stash", "bag_"..bagId, {
            maxweight = 250000, -- max weight of bag
            slots = 30, -- max slots in bag
        })
        TriggerEvent("inventory:client:SetCurrentStash", "bag_"..bagId)


        --TriggerServerEvent("inventory:server:OpenInventory", "stash", "bag_"..FvMain.Functions.GetPlayerData().citizenid)
        --TriggerEvent("inventory:client:SetCurrentStash", "bag_"..FvMain.Functions.GetPlayerData().citizenid)
    end)
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 