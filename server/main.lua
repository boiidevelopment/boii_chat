--- This script covers server-side functionality for the pawnshop, including dynamic pricing, item stock management,
-- and employee permissions.
-- @script server/main.lua

--- @section Dependencies
--- Import utility library from a shared resource.
utils = exports['boii_utils']:get_utils()

--- @section Local functions

--- Internal help function to get player name
-- @lfunction get_player_name
local function get_player_name(source)
    local identity = utils.fw.get_identity(source)
    local player_name = identity.first_name .. ' ' .. identity.last_name
    return player_name
end

--- @section Exports

--- Intercepts default chat messages using chat exports.
exports.chat:registerMessageHook(function(source, outMessage, hookRef)
    local message = outMessage.args[2]
    if string.sub(message, 1, 1) ~= "/" then
        hookRef.cancel()
        local player_name = get_player_name(source)
        log_message({
            chat_type = 'global_chat',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message default">
                    <span><i class="fa-solid fa-globe"></i>[GLOBAL] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end
end)

--- @section Commands

--- Allows a player to clear their own chat.
if not config.disable_commands.clear then
    utils.commands.register('clear', nil, 'Clears your chat window.', {}, function(source, args, raw)
        TriggerClientEvent('chat:clear', source)
    end)
end

--- Allows a staff member to clear everyones chat.
if not config.disable_commands.clear then
    utils.commands.register('clear_all', { 'dev' }, 'Clears chat for all players.', {}, function(source, args, raw)
        TriggerClientEvent('chat:clear', -1)
    end)
end

--- Sends a message in local chat *(to players within the messaging players scope)*
if not config.disable_chats.local_chat then
    utils.commands.register('local', nil, 'Send a local chat message only visible to those in range.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        local players_in_range = utils.scope.get_players_in_range(source, 20.0, true)
        for _, player_id in ipairs(players_in_range) do
            log_message({
                chat_type = 'local_chat',
                player_name = player_name,
                message = message
            })
            TriggerClientEvent('chat:addMessage', player_id, {
                template = [[
                    <div class="msg chat-message local">
                        <span><i class="fa-solid fa-street-view"></i>[LOCAL] <player_name>{0}:</player_name> {1}</span>
                    </div>
                ]],
                args = { player_name, message }
            })
        end
    end)
end

--- Sends a staff message to all players.
-- Uses utils user ranks for permissions.
if not config.disable_chats.staff then
    utils.commands.register('staff', { 'dev' }, 'Send a staff message.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        log_message({
            chat_type = 'staff',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message staff">
                    <span><i class="fa-solid fa-user-secret"></i>[STAFF] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end

--- Sends a message in staff only chat.
-- Uses utils user ranks for permissions.
if not config.disable_chats.staff_only then
    utils.commands.register('staff_only', { 'dev' }, 'Send a staff only message.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        log_message({
            chat_type = 'staff_only',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message staff_only">
                    <span><i class="fa-solid fa-circle-exclamation"></i>[STAFF ONLY] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end

--- Sends an advertisement message to all players
if not config.disable_chats.advert then
    utils.commands.register('ad', nil, 'Send a local chat message only visible to those in range.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        log_message({
            chat_type = 'adverts',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message advert">
                    <span><i class="fa-solid fa-rectangle-ad"></i>[AD] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end

--- Sends a police message to all players, optionally filtering by on-duty status.
if not config.disable_chats.police then
    utils.commands.register('police', nil, 'Send a police message to all players.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        local job_names = config.police.jobs
        local on_duty_required = config.police.on_duty_only
        if not utils.fw.player_has_job(source, job_names, on_duty_required) then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: You dont have permission to talk in this chat or you are not on duty.</span>
                    </div>
                ]],
                args = { }
            })
            return
        end
        log_message({
            chat_type = 'police',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message police">
                    <span><i class="fa-solid fa-shield-halved"></i>[POLICE] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end

--- Sends a ems message to all players, optionally filtering by on-duty status.
if not config.disable_chats.ems then
    utils.commands.register('ems', nil, 'Send a ems message to all players.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        local job_names = config.ems.jobs
        local on_duty_required = config.ems.on_duty_only
        if not utils.fw.player_has_job(source, job_names, on_duty_required) then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: You dont have permission to talk in this chat or you are not on duty.</span>
                    </div>
                ]],
                args = { }
            })
            return
        end
        log_message({
            chat_type = 'ems',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message ems">
                    <span><i class="fa-solid fa-shield-halved"></i>[EMS] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end

--- Staff can send a warning message to a specific player or all players
if not config.disable_chats.warning then
    utils.commands.register('warn', { 'dev' }, 'Send a warning to all players or specify a player.', {{ name = 'id', help = 'Player ID (optional)' }, { name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local target_id = tonumber(args[1])
        local message = table.concat(args, " ", target_id and 2 or 1)
        local player_name = get_player_name(source)
        if target_id then
            local target_name = get_player_name(target_id)
            log_message({
                chat_type = 'player_warning',
                player_name = player_name,
                target_name = target_name,
                message = message
            })
            TriggerClientEvent('chat:addMessage', target_id, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[PM] from <player_name>{0}:</player_name> <player_name>{1}</player_name> {2}</span>
                    </div>
                ]],
                args = { player_name, target_name, message }
            })
        else
            log_message({
                chat_type = 'warning',
                player_name = player_name,
                message = message
            })
            TriggerClientEvent('chat:addMessage', -1, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] <player_name>{0}:</player_name> {1}</span>
                    </div>
                ]],
                args = { player_name, message }
            })
        end
    end)
end

--- Sends a private message to a specific player
if not config.disable_chats.pm then
    utils.commands.register('pm', nil, 'Send a private message to a specific player.', {{ name = 'id', help = 'Player ID' }, { name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local target_id = tonumber(args[1])
        local player_name = get_player_name(source)
        if not target_id then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: You must specify a player ID.</span>
                    </div>
                ]],
                args = { }
            })
            return
        end
        local message = table.concat(args, " ", 2)
        local target_player_exists = GetPlayerName(target_id) ~= nil
        if target_player_exists then
            local target_name = get_player_name(target_id)
            log_message({
                chat_type = 'pm',
                player_name = player_name,
                target_name = target_name,
                message = message
            })
            TriggerClientEvent('chat:addMessage', target_id, {
                template = [[
                    <div class="msg chat-message pm">
                        <span><i class="fa-solid fa-envelope"></i>[PM] from <player_name>{0}:</player_name> {1}</span>
                    </div>
                ]],
                args = { player_name, message }
            })
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message success">
                        <span><i class="fa-solid fa-check"></i>[SUCCESS] Your message was sent to {0}.</span>
                    </div>
                ]],
                args = { target_name }
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: No player was found for that ID.</span>
                    </div>
                ]],
                args = { }
            })
        end
    end)
end

--- Sends a group chat message to all members of the player's group(s).
if not config.disable_chats.group then
    utils.commands.register('group', nil, 'Send a message to your group.', {{ name = 'group_name', help = 'Name of the group' }, { name = 'message', help = 'The message to say' }}, function(source, args, raw)
        if #args < 2 then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: You must specify a group name and a message.</span>
                    </div>
                ]],
                args = {}
            })
            return
        end
        local group_name = args[1]
        local message = table.concat(args, " ", 2)
        local player_name = get_player_name(source)
        if not utils.groups.group_exists(group_name) then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: Specified group does not exist.</span>
                    </div>
                ]],
                args = {}
            })
            return
        end
        if not utils.groups.in_group({name = group_name, player_id = source}) then
            TriggerClientEvent('chat:addMessage', source, {
                template = [[
                    <div class="msg chat-message warning">
                        <span><i class="fa-solid fa-triangle-exclamation"></i>[WARNING] Error: You are not a member of the specified group.</span>
                    </div>
                ]],
                args = {}
            })
            return
        end
        local group_data = utils.groups.get_group(group_name)
        log_message({
            chat_type = 'group',
            player_name = player_name,
            group_name = group_name,
            group_members = group_data.members,
            message = message
        })
        for _, player in ipairs(group_data.members) do
            TriggerClientEvent('chat:addMessage', player.id, {
                template = [[
                    <div class="msg chat-message group">
                        <span><i class="fa-solid fa-users"></i>[GROUP] - <group_name>{0}</group_name>: <player_name>{1}:</player_name> {2}</span>
                    </div>
                ]],
                args = { group_name, player_name, message }
            })
        end
    end)
end

--- Sends an trade message to all players
if not config.disable_chats.trade then
    utils.commands.register('trade', nil, 'Send a trade chat message to all players.', {{ name = 'message', help = 'The message to say' }}, function(source, args, raw)
        local message = table.concat(args, " ")
        local player_name = get_player_name(source)
        log_message({
            chat_type = 'trade',
            player_name = player_name,
            message = message
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = [[
                <div class="msg chat-message trade">
                    <span><i class="fa-solid fa-hand-holding-hand"></i>[TRADE] <player_name>{0}:</player_name> {1}</span>
                </div>
            ]],
            args = { player_name, message }
        })
    end)
end
