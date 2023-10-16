-- REQUEST ROBBERY
-- CHECK ROBBABLE HOUSES AT FVM-HOUSEROBBERIES/CONFIG.LUA
-- HOUSEROBBERIES HAS TIMER IN CONFIG WHEN YOU CAN ROB HOUSES

CFG = {}

CFG.MinimumTime = 21 -- from - When you allow to use "RequestRobbery" location, 0-24
CFG.MaximumTime = 4 -- to - Ending time  
CFG.RemoveHouseBlip = 5 -- min, Remove house blip
CFG.TimeoutForRequest = 30 -- min, Can request another location

CFG.RequestRobbery = { -- LOCATION WHERE YOU CAN REQUEST
    [1] = {
        coords = {
            x = 1272.46, 
            y = -1711.57, 
            z = 54.77,
        },
    },
    -- [2] = { -- ADD MORE LOCATIONS HERE
    --     coords = {
    --         x = 1272.46, 
    --         y = -1711.57, 
    --         z = 54.77,
    --     },
    -- },
}

