fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'wayze-ac'
author 'WayZe'
description 'Advanced server-authoritative FiveM anticheat'
version '2.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/events.lua',
}

client_scripts {
    'client/utils.lua',
    'client/heartbeat.lua',
    'client/detections/movement.lua',
    'client/detections/combat.lua',
    'client/detections/vehicle.lua',
    'client/detections/player.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/admin.lua',
    'server/logging.lua',
    'server/punishments.lua',
    'server/validation.lua',
    'server/movement.lua',
    'server/combat.lua',
    'server/economy.lua',
    'server/entity.lua',
    'server/bans.lua',
    'server/exports.lua',
    'server/main.lua',
}

server_exports {
    'FlagPlayer',
    'AddStrike',
    'IsBypassed',
    'SecureRegister',
    'GetPlayerStrikes',
    'BanPlayer',
    'KickPlayer',
}
