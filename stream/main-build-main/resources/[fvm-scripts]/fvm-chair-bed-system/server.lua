
local oArray = {}
local oPlayerUse = {}

AddEventHandler('playerDropped', function()
    local oSource = source
    if oPlayerUse[oSource] ~= nil then
        oArray[oPlayerUse[oSource]] = nil
        oPlayerUse[oSource] = nil
    end
end)


RegisterServerEvent('fvm-chair-bed-system:Server:Enter')
AddEventHandler('fvm-chair-bed-system:Server:Enter', function(object, objectcoords)
    local oSource = source
    if oArray[objectcoords] == nil then
        oPlayerUse[oSource] = objectcoords
        oArray[objectcoords] = true
        TriggerClientEvent('fvm-chair-bed-system:Client:Animation', oSource, object, objectcoords)
    end
end)

RegisterServerEvent('fvm-chair-bed-system:Server:Leave')
AddEventHandler('fvm-chair-bed-system:Server:Leave', function(objectcoords)
    local oSource = source

    oPlayerUse[oSource] = nil
    oArray[objectcoords] = nil
end)

