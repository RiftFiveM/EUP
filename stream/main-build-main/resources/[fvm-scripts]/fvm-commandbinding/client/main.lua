local keyPressed = false
local isLoggedIn = false

local inKeyBinding = false
local availableKeys = {
    {289, "F2"},
    {170, "F3"},
    {166, "F5"},
    {167, "F6"},
    {168, "F7"},
    {56, "F9"},
    {57, "F10"},
}

RegisterNetEvent("FvMain:Client:OnPlayerUnload")
AddEventHandler("FvMain:Client:OnPlayerUnload", function()
    isLoggedIn = false
end)

RegisterNetEvent("FvMain:Client:OnPlayerLoaded")
AddEventHandler("FvMain:Client:OnPlayerLoaded", function()
    isLoggedIn = true
end)

function openBindingMenu()
    local PlayerData = FvMain.Functions.GetPlayerData()
    local keyMeta = PlayerData.metadata["commandbinds"]
    SendNUIMessage({
        action = "openBinding",
        keyData = keyMeta
    })
    inKeyBinding = true
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
end

function closeBindingMenu()
    inKeyBinding = false
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', closeBindingMenu)

RegisterNetEvent('fvm-commandbinding:client:openUI')
AddEventHandler('fvm-commandbinding:client:openUI', function()
    openBindingMenu()
end)

for k, v in pairs(availableKeys) do
    RegisterCommand(v[1], function()
        if isLoggedIn and not keyPressed and GetLastInputMethod(0) then
            if not exports['fvm-houses']:InDeco() and not exports['fvm-phone']:InPhone() then 
                local keyMeta = FvMain.Functions.GetPlayerData().metadata["commandbinds"]
                local args = {}
                if next(keyMeta) ~= nil then
                    if keyMeta[v[2]]["command"] ~= "" then
                        if keyMeta[v[2]]["argument"] ~= "" then args = {[1] = keyMeta[v[2]]["argument"]} else args = {[1] = nil} end
                        TriggerServerEvent('FvMain:CallCommand', keyMeta[v[2]]["command"], args)
                        keyPressed = true
                        Citizen.Wait(1000)
                        keyPressed = false
                    else
                        FvMain.Functions.Notify('There is still nothing ['..v[2]..'] bound, /binds to bind a command', 'primary', 4000)
                    end
                else
                    FvMain.Functions.Notify('You have not bound any commands, /binds to bind a command', 'primary', 4000)
                end
            end
        end
    end, false)
    RegisterKeyMapping(v[1], 'BIND '..k, 'keyboard', v[2])
end

RegisterNUICallback('save', function(data)
    local keyData = {
        ["F2"]  = {["command"] = data.keyData["F2"][1],  ["argument"] = data.keyData["F2"][2]},
        ["F3"]  = {["command"] = data.keyData["F3"][1],  ["argument"] = data.keyData["F3"][2]},
        ["F5"]  = {["command"] = data.keyData["F5"][1],  ["argument"] = data.keyData["F5"][2]},
        ["F6"]  = {["command"] = data.keyData["F6"][1],  ["argument"] = data.keyData["F6"][2]},
        ["F7"]  = {["command"] = data.keyData["F7"][1],  ["argument"] = data.keyData["F7"][2]},
        ["F9"]  = {["command"] = data.keyData["F9"][1],  ["argument"] = data.keyData["F9"][2]},
        ["F10"] = {["command"] = data.keyData["F10"][1], ["argument"] = data.keyData["F10"][2]},
    }

    FvMain.Functions.Notify('Command bindings have been saved!', 'success')

    TriggerServerEvent('fvm-commandbinding:server:setKeyMeta', keyData)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(200)
        isLoggedIn = true
    end
end)