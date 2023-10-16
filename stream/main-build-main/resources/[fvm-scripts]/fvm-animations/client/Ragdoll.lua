local isInRagdoll = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        local ped = PlayerPedId()
        if isInRagdoll then
            SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
        end
    end
end)

RegisterCommand('toggleragdoll', function()
    local ped = PlayerPedId()
    if not exports['fvm-police']:IsHandcuffed() then
        if not IsInAnimation then
            if IsPedOnFoot(ped) then
                if isInRagdoll then
                    isInRagdoll = false
                else
                    isInRagdoll = true
                end
            end
        end
    end
end)
RegisterKeyMapping('toggleragdoll', 'Toggles Ragdoll', 'keyboard', 'u')

