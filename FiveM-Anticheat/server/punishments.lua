ACPunish = {}

function ACPunish.Kick(src, reason)
    if ACAdmin.IsBypassed(src) then return end
    ACLogging.Action(src, 'kick', reason)
    ACLogging.Detection(src, 'punish_kick', { reason = reason }, 'kick')
    DropPlayer(src, reason or 'Kicked by anticheat.')
end

function ACPunish.Ban(src, reason, durationHours)
    if ACAdmin.IsBypassed(src) then return end

    local ids = ACLogging.GetIdentifiers(src)
    local expires = nil

    if durationHours and durationHours > 0 then
        expires = os.date('%Y-%m-%d %H:%M:%S', os.time() + (durationHours * 3600))
    end

    MySQL.insert([[
        INSERT INTO ac_bans (license, steam, discord, reason, banned_by, expires_at, banned_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE reason = VALUES(reason), expires_at = VALUES(expires_at), banned_at = NOW()
    ]], {
        ids.license or 'unknown',
        ids.steam,
        ids.discord,
        reason or 'anticheat',
        'system',
        expires,
    })

    ACLogging.Action(src, 'ban', reason)
    ACLogging.Detection(src, 'punish_ban', { reason = reason, expires = expires }, 'ban')
    DropPlayer(src, 'Banned: ' .. (reason or 'anticheat'))
end

function ACPunish.CheckStrikes(src, count)
    if ACAdmin.IsBypassed(src) then return end

    if count >= Config.Strikes.banAt then
        ACPunish.Ban(src, 'strike_threshold')
    elseif count >= Config.Strikes.kickAt then
        ACPunish.Kick(src, 'Suspicious activity detected.')
    end
end
