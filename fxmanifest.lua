--[[
     ____   ____ _____ _____   _   _____  ________      ________ _      ____  _____  __  __ ______ _   _ _______ 
    |  _ \ / __ \_   _|_   _| | | |  __ \|  ____\ \    / /  ____| |    / __ \|  __ \|  \/  |  ____| \ | |__   __|
    | |_) | |  | || |   | |   | | | |  | | |__   \ \  / /| |__  | |   | |  | | |__) | \  / | |__  |  \| |  | |   
    |  _ <| |  | || |   | |   | | | |  | |  __|   \ \/ / |  __| | |   | |  | |  ___/| |\/| |  __| | . ` |  | |   
    | |_) | |__| || |_ _| |_  | | | |__| | |____   \  /  | |____| |___| |__| | |    | |  | | |____| |\  |  | |   
    |____/ \____/_____|_____| | | |_____/|______|   \/   |______|______\____/|_|    |_|  |_|______|_| \_|  |_|   
                              | |                                                                                
                              |_|           CHAT THEME V1.0.0
]]

fx_version 'cerulean'
games { 'gta5', 'rdr3' }

name 'boii_chat'
version '1.0.0'
description 'BOII | Development - Chat Theme'
author 'boiidevelopment'
repository 'https://github.com/boiidevelopment/boii_chat'
lua54 'yes'

file 'html/css/styles.css'

server_scripts {
    'server/config.lua',
    'server/log.lua',
    'server/main.lua'
}

chat_theme 'boii_chat' {
    styleSheet = 'html/css/styles.css'
}

escrow_ignore {
    'server/*'
}
