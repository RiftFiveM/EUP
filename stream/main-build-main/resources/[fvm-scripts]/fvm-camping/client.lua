local a = {
	{title="Camping area", colour = 5, id = 417, x = 2948.568, y = 5326.274, z = 101.27 },
}

RegisterNetEvent('fvm-camping')
AddEventHandler('fvm-camping',function()
    local b=PlayerPedId()
    local c=GetEntityCoords(PlayerPedId())
    local d=#(vector3(2952.8,5325.69,101.02) - vector3(c.x,c.y,c.z))
    if IsPedInAnyVehicle(b)then 
	  	FvMain.Functions.Notify("This operation cannot be performed in the vehicle", "success", 2500)
        TriggerServerEvent('fvm-camping:itemback', source)
    else 
        if d<100 then 
            crouch()
			FvMain.Functions.Notify("You are putting the tent", "success", 9000)
            TriggerServerEvent('fvm-camping:control')
        else 
		    FvMain.Functions.Notify("You can camp only in designated areas!", "success", 2500)
            TriggerServerEvent('fvm-camping:itemback', source)
        end 
    end 
end)
    
    RegisterNetEvent("fvm-camping:createobject")
    AddEventHandler("fvm-camping:createobject",function(f,g,h)
        local i=PlayerPedId()
        local j=GetEntityCoords(i)
        local k=ObjToNet(CreateObject(GetHashKey(f),j.x-1,j.y-1.5,j.z-1.6,true,false))
        local l=ObjToNet(CreateObjectNoOffset(GetHashKey(g),j.x-1.5,j.y-3.5,j.z-0.5,true,false))
        local m=ObjToNet(CreateObjectNoOffset(GetHashKey(h),j.x-2.5,j.y+0.3,j.z-0.6,true,false))
        local n=ObjToNet(CreateObjectNoOffset(GetHashKey(h),j.x+1.0,j.y+0.3,j.z-0.6,true,false))
    end) 

function crouch()
	TaskStartScenarioInPlace(PlayerPedId(),'world_human_gardener_plant',0,false)
	Wait(9000)
	ClearPedTasks(PlayerPedId())
end

local isindim = false
local isinmadim = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)
        local entity = GetClosestObjectOfType(pcoords, 1.0, `prop_beach_fire`, false, false, false)
        local entityCoords = GetEntityCoords(entity)

        if DoesEntityExist(entity) and #(pcoords-entityCoords) < 1.5 then
            if isindim == false then
                startAnim()
				FvMain.Functions.Notify("You are warming up", "success", 2500)
                Citizen.Wait(1000)
                isindim = true
                isinmadim = false
				--Citizen.Wait(10000)
				--SetEntityHealth(ped, 200)
            end
        else
            if isindim == true and isinmadim == false then
				FvMain.Functions.Notify("You went away from the fire!", "success", 2500)
                ClearPedTasks(ped)
                isindim = false
                isinmadim = true
            end
        end
    end
end)

function startAnim()
	Citizen.CreateThread(function()
	RequestAnimDict("bs_2a_mcs_10-6")
	while not HasAnimDictLoaded("bs_2a_mcs_10-6")
		do Citizen.Wait(0)end
		TaskPlayAnim(PlayerPedId(),"bs_2a_mcs_10-6","hc_hacker_dual-6",8.0,-8.0,-1,50,0,false,false,false)
	end)
end

Citizen.CreateThread(function()
	for a,b in pairs(a)do b.blip=AddBlipForCoord(b.x,b.y,b.z)
		SetBlipSprite(b.blip,b.id)
		SetBlipDisplay(b.blip,4)
		SetBlipScale(b.blip,0.7)
		SetBlipColour(b.blip,b.colour)
		SetBlipAsShortRange(b.blip,true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(b.title)
		EndTextCommandSetBlipName(b.blip)
	end 
end)
