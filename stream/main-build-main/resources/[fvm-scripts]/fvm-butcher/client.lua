local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local PlayerData                = {}

isLoggedIn = false
local PlayerJob = {}
local notInteressted = false

RegisterNetEvent('FvMain:Client:OnPlayerLoaded')
AddEventHandler('FvMain:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = FvMain.Functions.GetPlayerData().job
end)

RegisterNetEvent('FvMain:Client:OnPlayerUnload')
AddEventHandler('FvMain:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('FvMain:Client:OnJobUpdate')
AddEventHandler('FvMain:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end

Citizen.CreateThread(function()
    if Config.NPCEnable == true then
        for i, v in pairs(Config.NPC) do
            RequestModel(v.npc)
            while not HasModelLoaded(v.npc) do
                Wait(1)
            end
            chickenped = CreatePed(1, v.npc, v.x, v.y, v.z, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(chickenped, true)
            SetPedDiesWhenInjured(chickenped, false)
            SetPedCanPlayAmbientAnims(chickenped, true)
            SetPedCanRagdollFromPlayerImpact(chickenped, false)
            SetEntityInvincible(chickenped, true)
            FreezeEntityPosition(chickenped, true)
        end
    end
end)

function Animation() 
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common")do 
        Citizen.Wait(0)
    end;b=CreateObject(GetHashKey('prop_weed_bottle'),0,0,0,true)
    AttachEntityToEntity(b,PlayerPedId(),
    GetPedBoneIndex(PlayerPedId(),57005),0.13,0.02,0.0,-90.0,0,0,1,1,0,1,0,1)
    AttachEntityToEntity(p,l,GetPedBoneIndex(l,57005),0.13,0.02,0.0,-90.0,0,0,1,1,0,1,0,1)
    TaskPlayAnim(PlayerPedId(),"mp_common","givetake1_a",8.0,-8.0,-1,0,0,false,false,false)
    TaskPlayAnim(l,"mp_common","givetake1_a",8.0,-8.0,-1,0,0,false,false,false)
    Wait(1550)
    DeleteEntity(b)
    ClearPedTasks(pid)
    ClearPedTasks(l)
end

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(2)
		local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.Chickens) do
            if #(coords - vector3(v.x, v.y, v.z)) < 5 then
                if not notInteressted then
                    if PlayerJob.name == "butcher" then
                        DrawText3D( v.x, v.y, v.z, "[E] Catch Chickens", 0.7)
                        if IsControlJustPressed(1, 38) then
                            CatchChickens()
                            notInteressted = true
                            SetTimeout(4000, ClearTimeOut)
                            FvMain.Functions.Notify("Catching Chickens!", "success")	
                            Citizen.Wait(1500)		
                        end
                    else
                        Citizen.Wait(2500)
                    end 
                end
            end
        end
	end
end)

function CatchChickens()
	local playerPed = PlayerPedId()
    LoadAnim("random@domestic")
    FreezeEntityPosition(PlayerPedId(),true)
    TaskPlayAnim(playerPed, 'random@domestic', 'pickup_low', 8.0, -8, -1, 48, 0, 0, 0, 0)
    Citizen.Wait(1000)
    FvMain.Functions.Progressbar("chickencatch", "Catching chicken...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done 
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
        TriggerServerEvent("fvm-butcher:chicken", "alive_chicken")
    end, function() -- Cancel
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
	end)	
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(2)
        if not notInteressted then
            local pos = GetEntityCoords(PlayerPedId())
            if PlayerJob.name == "butcher" then
                if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["butcher"].coords.x, Config.Locations["butcher"].coords.y, Config.Locations["butcher"].coords.z, true) < 10.0) then
                    DrawMarker(2, Config.Locations["butcher"].coords.x, Config.Locations["butcher"].coords.y, Config.Locations["butcher"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["butcher"].coords.x, Config.Locations["butcher"].coords.y, Config.Locations["butcher"].coords.z, true) < 1.5) then
                        DrawText3D(Config.Locations["butcher"].coords.x, Config.Locations["butcher"].coords.y, Config.Locations["butcher"].coords.z, "~g~E~w~ - Cut the chickens ")
                        if IsControlJustReleased(0, Keys["E"]) then
                            SlaughterChickens()
                            notInteressted = true
                            SetTimeout(15000, ClearTimeOut)
                        end
                    end
                end
            else
                Citizen.Wait(2500)
            end
        end
    end
end)


function SlaughterChickens()
    local ped = PlayerPedId()
    local playerPed = PlayerPedId()
    local PedCoords = GetEntityCoords(PlayerPedId())
    LoadAnim("anim@amb@business@coc@coc_unpack_cut_left@")
    FreezeEntityPosition(PlayerPedId(),true)
    TaskPlayAnim(PlayerPedId(), "anim@amb@business@coc@coc_unpack_cut_left@", "coke_cut_v1_coccutter", 3.0, -8, -1, 63, 0, 0, 0, 0 )
    bicak = CreateObject(GetHashKey('prop_knife'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
    AttachEntityToEntity(bicak, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0xDEAD), 0.13, 0.14, 0.09, 40.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetEntityHeading(PlayerPedId(), 311.0)
    tavuk = CreateObject(GetHashKey('prop_int_cf_chick_01'),-94.87, 6207.008, 30.08, true, true, true)
    SetEntityRotation(tavuk,90.0, 0.0, 45.0, 1,true)

	FvMain.Functions.Progressbar("slaughtering", "Slaughtering chickens...", 15000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done    
        DeleteEntity(tavuk)
        DeleteEntity(bicak)
        DeleteEntity(tavuk)
        DeleteEntity(bicak)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
        TriggerServerEvent('fvm-butcher:slaughter')
    end, function() -- Cancel
        DeleteEntity(tavuk)
        DeleteEntity(bicak)
        DeleteEntity(tavuk)
        DeleteEntity(bicak)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
    end)
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(2)
        if not notInteressted then
            local pos = GetEntityCoords(PlayerPedId())
            if PlayerJob.name == "butcher" then
                if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["packing"].coords.x, Config.Locations["packing"].coords.y, Config.Locations["packing"].coords.z, true) < 10.0) then
                    DrawMarker(2, Config.Locations["packing"].coords.x, Config.Locations["packing"].coords.y, Config.Locations["packing"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["packing"].coords.x, Config.Locations["packing"].coords.y, Config.Locations["packing"].coords.z, true) < 1.5) then
                        DrawText3D(Config.Locations["packing"].coords.x, Config.Locations["packing"].coords.y, Config.Locations["packing"].coords.z, "~g~E~w~ - Pack chickens")
                        if IsControlJustReleased(0, Keys["E"]) then
                            PackChickens()
                            notInteressted = true
                            SetTimeout(16000, ClearTimeOut)
                        end
                    end
                end
            else
                Citizen.Wait(2500)
            end
        end
    end
end)

function PackChickens()
    local ped = PlayerPedId()
    local playerPed = PlayerPedId()
	SetEntityHeading(PlayerPedId(), 40.0)
    local PedCoords = GetEntityCoords(PlayerPedId())
    
    tavuket = CreateObject(GetHashKey('prop_cs_steak'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
	AttachEntityToEntity(tavuket, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x49D9), 0.15, 0.0, 0.01, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	karton = CreateObject(GetHashKey('prop_cs_clothes_box'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
	AttachEntityToEntity(karton, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.13, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	LoadAnimDict("anim@heists@ornate_bank@grab_cash_heels")
	TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(playerPed, true)
	FvMain.Functions.Progressbar("packing", "Packing chickens...", 15000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done    
        DeleteEntity(karton)
        DeleteEntity(tavuket)
        DeleteEntity(karton)
	    DeleteEntity(tavuket)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
        TriggerServerEvent('fvm-butcher:packing')
    end, function() -- Cancel
        DeleteEntity(karton)
        DeleteEntity(tavuket)
        DeleteEntity(karton)
	    DeleteEntity(tavuket)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
    end)
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(2)
        if not notInteressted then
            if isLoggedIn and FvMain ~= nil then
                local pos = GetEntityCoords(PlayerPedId())
                if PlayerJob.name == "butcher" then
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["sell"].coords.x, Config.Locations["sell"].coords.y, Config.Locations["sell"].coords.z, true) < 10.0) then
                        DrawMarker(2, Config.Locations["sell"].coords.x, Config.Locations["sell"].coords.y, Config.Locations["sell"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                        if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["sell"].coords.x, Config.Locations["sell"].coords.y, Config.Locations["sell"].coords.z, true) < 7.5) then
                            DrawText3D(Config.Locations["sell"].coords.x, Config.Locations["sell"].coords.y, Config.Locations["sell"].coords.z, "~g~E~w~ - Sell packaged chickens")
                            if IsControlJustReleased(0, Keys["E"]) then
                                SellPackages()
                                notInteressted = true
                                SetTimeout(5000, ClearTimeOut)       
                            end
                        end
                    end
                else
                    Citizen.Wait(2500)
                end
            else
                Citizen.Wait(2500)
            end
        end
    end
end)

function SellPackages()
    local ped = PlayerPedId()
    local playerPed = PlayerPedId()
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.9, -0.98))

    prop = CreateObject(GetHashKey('hei_prop_heist_box'), x, y, z,  true,  true, true)
    SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
    LoadAnimDict('amb@medic@standing@tendtodead@idle_a')
    TaskPlayAnim(PlayerPedId(), 'amb@medic@standing@tendtodead@idle_a', 'idle_a', 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
    LoadAnimDict('amb@medic@standing@tendtodead@exit')
    TaskPlayAnim(PlayerPedId(), 'amb@medic@standing@tendtodead@exit', 'exit', 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
    ClearPedTasks(PlayerPedId())
    DeleteEntity(prop)
    FreezeEntityPosition(playerPed, true)
	FvMain.Functions.Progressbar("selling", "Selling packages...", 6200, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done     
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(playerPed, false)
        TriggerServerEvent('fvm-butcher:sell')
    end)
end

Citizen.CreateThread(function()
	for k,v in pairs(Config.Chickens) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)

		SetBlipSprite (blip, 256)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.5)
		SetBlipColour (blip, 5)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Chicken Factory')
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-592.68, -881.78, 25.92)

    SetBlipSprite (blip, 256)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.7)
    SetBlipColour (blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Chicken - Selling point')
    EndTextCommandSetBlipName(blip)
end)

function ClearTimeOut()
    notInteressted = not notInteressted
end
