--- Chat logging setup
-- @script server/log.lua

--- @section Tables

--- Table to store logs
local logs = {}

--- Creates entry in logs for each chat type.
for chat_type in pairs(config.logs) do logs[chat_type] = {} end

--- @section Local functions

--- Loads existing log entries from JSON files into memory.
-- @function load_logs
local function load_logs()
    for chat_type, file in pairs(config.logs) do
        local content, status, result = LoadResourceFile(GetCurrentResourceName(), file.path), nil, nil
        if content and content ~= '' then
            status, result = pcall(json.decode, content)
            logs[chat_type] = status and result or {}
        end
    end
end
load_logs()

--- Saves log entries to their respective JSON files.
-- @function save_logs
-- @param chat_type string The chat type identifier.
local function save_logs(chat_type)
    if not config.save_on_restart then return end
    local status, result = pcall(json.encode, logs[chat_type], { indent = true })
    if status then
        SaveResourceFile(GetCurrentResourceName(), config.logs[chat_type].path, result, -1)
    else
        print('Failed to encode ' .. chat_type .. ' logs: ' .. result)
    end
end

--- Sends a webhook to a discord channel when a message is received.
-- @param chat_type: The chat type identifier.
-- @param log_entry: The log entry data.
local function send_webhook(chat_type, log_entry)
    local should_mention = config.discord[chat_type].should_mention or false
    local webhook = config.discord[chat_type].webhook or config.discord['global_chat'].webhook
    local description = '**Sender:** ' .. log_entry.player_name .. '\n**Message:** ' .. log_entry.message
    if log_entry.target_name then
        description = description .. '\n**Target**: ' .. log_entry.target_name
    end
    if log_entry.group_name then
        description = description .. '\n**Group**: ' .. log_entry.group_name
    end
    if log_entry.group_members and #log_entry.group_members > 0 then
        description = description .. '\n**Members**: ' .. table.concat(log_entry.group_members, ", ")
    end
    local embed = {
        {
            ['title'] = '💬 ' .. (config.discord[chat_type].title or 'Chat Log'),
            ['color'] = config.discord[chat_type].colour or 3447003,
            ['footer'] = {
                ['text'] = '© - BOII | Development ' .. os.date('%c'),
                ['icon_url'] = 'https://i.ibb.co/dBWBZCx/boii-mascot-ava.png',
            },
            ['description'] = description,
        }
    }
    local payload = {
        username = '💠 CHAT LOGS 💠',
        embeds = embed,
        avatar_url = 'https://i.ibb.co/dBWBZCx/boii-mascot-ava.png'
    }
    if should_mention then
        payload.content = '@everyone'
    end
    PerformHttpRequest(webhook, function() end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

--- @section Global functions

--- Logs messages for different chat types.
-- @param options table Contains details for the log entry such as chat type, player name, message, target name (optional), and group name (optional).
-- @example
-- @usage log_message({ chat_type = 'global_chat', player_name = 'John Doe', message = 'Hello, world!' })
-- @usage log_message({ chat_type = 'player_warning', player_name = 'John Doe', target_name = 'Jane Doe', message = 'This is a warning.' })
-- @usage log_message({ chat_type = 'group', group_name = 'Racers', player_name = 'John Doe', message = 'Race at 9 PM.', group_members = { 'John Doe', 'Jane Doe' } })
function log_message(options)
    if not config.logs[options.chat_type].should_log then return end
    local time_data = utils.dates.get_timestamp()
    local log_entry = {
        timestamp = time_data.formatted,
        player_name = options.player_name,
        message = options.message
    }
    if (options.chat_type == 'player_warning' and options.target_name) or (options.chat_type == 'pm' and options.target_name) then
        log_entry.target_name = options.target_name
    end
    if options.chat_type == 'group' and options.group_name then
        local group_data = utils.groups.get_group(options.group_name)
        if group_data and group_data.members then
            log_entry.group_name = options.group_name
            log_entry.group_members = {}
            for _, member in ipairs(group_data.members) do
                log_entry.group_members[#log_entry.group_members + 1] = member.first_name .. ' ' .. member.last_name
            end
        end
    end
    logs[options.chat_type][#logs[options.chat_type] + 1] = log_entry
    if config.discord[options.chat_type].enabled then
        send_webhook(options.chat_type, log_entry) 
    end
    if #logs[options.chat_type] % config.save_count == 0 then
        save_logs(options.chat_type)
    end
end

--- @section Event handlers

--- Handles the event when the resource stops, ensuring all logs are saved.
-- @event onResourceStop
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for chat_type in pairs(logs) do if #logs[chat_type] > 0 then save_logs(chat_type) end end
    end
end)