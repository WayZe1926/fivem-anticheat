ACBans = {}

function ACBans.IsBanned(identifiers, cb)
    local license, steam, discord

    for _, id in ipairs(identifiers) do
        if id:find('license:') then license = id end
        if id:find('steam:') then steam = id end
        if id:find('discord:') then discord = id end
    end

    MySQL.query([[
        SELECT reason, expires_at FROM ac_bans
        WHERE (license = ? OR steam = ? OR discord = ?)
        AND (expires_at IS NULL OR expires_at > NOW())
        LIMIT 1
    ]], { license, steam, discord }, function(rows)
        if rows and rows[1] then
            cb(true, rows[1].reason, rows[1].expires_at)
        else
            cb(false)
        end
    end)
end

if Config.Bans.checkOnConnect then
    AddEventHandler('playerConnecting', function(_, setKickReason, deferrals)
        local src = source
        deferrals.defer()
        Wait(0)
        deferrals.update('Checking ban status...')

        local ids = GetPlayerIdentifiers(src)
        ACBans.IsBanned(ids, function(banned, reason)
            if banned then
                deferrals.done(Config.Bans.message .. ' Reason: ' .. (reason or 'anticheat'))
            else
                deferrals.done()
            end
        end)
    end)
end
