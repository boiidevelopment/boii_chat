--- Server side configuration
-- @script server/config.lua

config = config or {}

--- @section Chat logging settings

--- Logging paths and toggle save.
-- Log files will be created when the save count is reached, or all will be created on first restart if save_on_restart is true.
-- @field path: File path to load / save json files.
-- @field should_log: Enable/disable chat logging for the chat type.
config.logs = {
    global_chat = { path = './global_chat.json', should_log = true },
    local_chat = { path = './local_chat.json', should_log = true },
    staff = { path = './staff.json', should_log = true },
    staff_only = { path = './staff_only.json', should_log = true },
    adverts = { path = './adverts.json', should_log = true },
    police = { path = './police.json', should_log = true },
    ems = { path = './ems.json', should_log = true },
    player_warning = { path = './player_warning.json', should_log = true },
    warning = { path = './warning.json', should_log = true },
    pm = { path = './pm.json', should_log = true },
    group = { path = './group.json', should_log = true },
    trade = { path = './trade.json', should_log = true }
}

--- Toggle if chat logs should be saved on script restart.
config.save_on_restart = true

--- The amount of messages before saving logs if save is enabled.
-- If save on restart is enabled chat logs will be saved on restart regardless of this value.
-- If save on restart is disabled chat logs will be saved only after this value is reached.
config.save_count = 50 

--- Discord logging controls.
config.discord = {
    global_chat = {
        enabled = true,
        title = 'GLOBAL CHAT',
        colour = 5098434,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    local_chat = {
        enabled = true,
        title = 'LOCAL CHAT',
        colour = 11842740,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    staff = {
        enabled = true,
        title = 'STAFF CHAT',
        colour = 5025616,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    staff_only = {
        enabled = true,
        title = 'STAFF ONLY CHAT',
        colour = 5025616,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    adverts = {
        enabled = true,
        title = 'ADVERTISEMENT',
        colour = 16750592,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    police = {
        enabled = true,
        title = 'POLICE CHAT',
        colour = 2201331,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    ems = {
        enabled = true,
        title = 'EMS CHAT',
        colour = 15277667,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    }, 
    player_warning = {
        enabled = true,
        title = 'PLAYER WARNING',
        colour = 16711680,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    }, 
    warning = {
        enabled = true,
        title = 'GLOBAL WARNING',
        colour = 16711680,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    pm = {
        enabled = true,
        title = 'PRIVATE MESSAGE',
        colour = 8388736,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    group = {
        enabled = true,
        title = 'GROUP CHAT',
        colour = 16777062,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    },
    trade = {
        enabled = true,
        title = 'TRADE CHAT',
        colour = 16744272,
        webhook = 'PUT YOUR WEBHOOK HERE',
        should_mention = false,
    }
}

--- @section General settings

--- Disable chats you do not wish to use here.
-- By default all chat types are enabled, change to true to disable.
config.disable_chats = {
    global_chat = false,
    local_chat = false,
    staff = false,
    staff_only = false,
    adverts = false, 
    police = false,
    ems = false, 
    player_warning = false, 
    warning = false,
    pm = false,
    group = false,
    trade = false
}

--- Disable command usage here
-- By default all commands are enabled, change to true to disable.
config.disable_commands = {
    clear = false,
    clear_all = false
}

--- @section Job specific settings

--- Police chat settings
-- @field jobs: Array of job names, any jobs here will be allowed to use the chats.
-- @field on_duty_only: If enabled only players who are on duty are allowed to use the chats.
config.police = {
    jobs = { 'unemployed' },
    on_duty_only = true
}

--- EMS chat settings
-- @field jobs: Array of job names, any jobs here will be allowed to use the chats.
-- @field on_duty_only: If enabled only players who are on duty are allowed to use the chats.
config.ems = {
    jobs = { 'unemployed' },
    on_duty_only = true
}
