ACLogging = {}

function ACLogging.GetIdentifiers(src)
    local out = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        local prefix = id:match('([^:]+):')
        if prefix then
            out[prefix] = id
        end
    end
    return out
end

function ACLogging.GetPrimaryId(src)
    local ids = ACLogging.GetIdentifiers(src)
    return ids.license or ids.steam or ids.discord or ('src:' .. src)
end

function ACLogging.Detection(src, reason, evidence, severity)
    severity = severity or 'warn'
    local ids = ACLogging.GetIdentifiers(src)
    local name = GetPlayerName(src) or 'unknown'
    local primary = ACLogging.GetPrimaryId(src)

    print(('[^1AC^7][%s] %s (%s) | %s | %s'):format(
        severity:upper(),
        name,
        src,
        reason,
        json.encode(evidence or {})
    ))

    MySQL.insert([[
        INSERT INTO ac_logs (license, steam, discord, player_name, reason, evidence, severity, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ]], {
        ids.license,
        ids.steam,
        ids.discord,
        name,
        reason,
        json.encode(evidence or {}),
        severity,
    })

    if Config.Webhook.enabled and Config.Webhook.url ~= '' then
        local color = severity == 'ban' and 10038562 or (severity == 'kick' and 16744448 or Config.Webhook.color)
        PerformHttpRequest(Config.Webhook.url, function() end, 'POST', json.encode({
            username = Config.Webhook.username,
            avatar_url = Config.Webhook.avatar ~= '' and Config.Webhook.avatar or nil,
            embeds = {{
                title = 'Detection: ' .. reason,
                color = color,
                fields = {
                    { name = 'Player', value = name .. ' (`' .. src .. '`)', inline = true },
                    { name = 'License', value = ids.license or 'n/a', inline = true },
                    { name = 'Severity', value = severity, inline = true },
                    { name = 'Evidence', value = '```json\n' .. json.encode(evidence or {}) .. '\n```' },
                },
                footer = { text = 'wayze-ac v2' },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            }},
        }), { ['Content-Type'] = 'application/json' })
    end
end

function ACLogging.Action(src, action, reason)
    local ids = ACLogging.GetIdentifiers(src)
    local name = GetPlayerName(src) or 'unknown'

    MySQL.insert([[
        INSERT INTO ac_actions (license, player_name, action, reason, created_at)
        VALUES (?, ?, ?, ?, NOW())
    ]], {
        ids.license or 'unknown',
        name,
        action,
        reason or '',
    })
end
