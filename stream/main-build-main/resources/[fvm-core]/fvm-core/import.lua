if GetCurrentResourceName() == 'fvm-core' then 
    function GetSharedObject()
        return FvMain
    end

    exports('GetSharedObject', GetSharedObject)
end

FvMain = exports['fvm-core']:GetSharedObject()