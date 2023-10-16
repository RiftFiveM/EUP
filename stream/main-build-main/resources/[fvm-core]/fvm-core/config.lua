FVMConfig = {}

FVMConfig.ServerName = "FiveM.Network"

FVMConfig.MaxPlayers = GetConvarInt('sv_maxclients', 64) -- Gets max players from config file, default 32
FVMConfig.DefaultSpawn = {x=-1035.71,y=-2731.87,z=12.86,a=0.0}

FVMConfig.Money = {}
FVMConfig.Money.MoneyTypes = {['cash'] = 500, ['bank'] = 5000, ['crypto'] = 0 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
FVMConfig.Money.DontAllowMinus = {'cash', 'crypto'} -- Money that is not allowed going in minus
FVMConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck

FVMConfig.Player = {}
FVMConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
FVMConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
FVMConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
FVMConfig.Player.MaxInvSlots = 41 -- Max inventory slots for a player
FVMConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

FVMConfig.Server = {} -- General server config
FVMConfig.Server.closed = false -- Set server closed (no one can join except people with ace permission 'fvm-admin.join')
FVMConfig.Server.closedReason = "We\'re still testing." -- Reason message to display when people can't join the server
FVMConfig.Server.uptime = 0 -- Time the server has been up.
FVMConfig.Server.whitelist = false -- Enable or disable whitelist on the server
FVMConfig.Server.discord = "url with http" -- Discord invite link
FVMConfig.Server.PermissionList = {} -- permission list


FVMConfig.Notify = {}

FVMConfig.Notify.NotificationStyling = {
    group = false, -- Allow notifications to stack with a badge instead of repeating
    position = "right", -- top-left | top-right | bottom-left | bottom-right | top | bottom | left | right | center
    progress = true -- Display Progress Bar
}

-- These are how you define different notification variants
-- The "color" key is background of the notification
-- The "icon" key is the css-icon code, this project uses `Material Icons` & `Font Awesome`
FVMConfig.Notify.VariantDefinitions = {
    success = {
        classes = 'success',
        icon = 'done'
    },
    primary = {
        classes = 'primary',
        icon = 'info'
    },
    error = {
        classes = 'error',
        icon = 'dangerous'
    },
    police = {
        classes = 'police',
        icon = 'local_police'
    },
    ambulance = {
        classes = 'ambulance',
        icon = 'fas fa-ambulance'
    }
}
