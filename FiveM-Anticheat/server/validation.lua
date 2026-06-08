ACValidation = {}

local playerState = {}
local rateLimits = {}
local heartbeatTokens = {}

local strikeWeight = {
    teleport = 2,
    speed = 2,
    noclip_hint = 3,
    super_jump_hint = 2,
    godmode_invincible = 3,
    godmode_no_damage = 4,
    blacklisted_weapon = 3,
    blacklisted_vehicle = 3,
    invisible_ped = 2,
    night_vision = 1,
    thermal_vision = 1,
    health_overflow = 3,
    armor_overflow = 2,
    damage_modifier = 3,
    melee_modifier = 2,
    heartbeat_missed = 4,
    heartbeat_bad_token = 4,
    resource_stopped = 5,
    entity_spam = 3,
    explosion_spam = 3,
    event_abuse = 2,
}

function ACValidation.InitPlayer(src)
    playerState[src] = {
        strikes = {},
        lastCoords = nil,
        joinedAt = GetGameTimer(),
        heartbeatMissed = 0,
        lastDecay = os.time(),
    }
    heartbeatTokens[src] = ('%s-%s'):format(src, math.random(100000, 999999))
    TriggerClientEvent('ac:knowledge:heartbeat:sync', src, heartbeatTokens[src])
end

function ACValidation.ClearPlayer(src)
    playerState[src] = nil
    rateLimits[src] = nil
    heartbeatTokens[src] = nil
end

function ACValidation.GetStrikes(src)
    local st = playerState[src]
    if not st then return 0 end
    ACValidation.DecayStrikes(src)
    return #st.strikes
end

function ACValidation.DecayStrikes(src)
    local st = playerState[src]
    if not st then return end

    local now = os.time()
    if (now - st.lastDecay) < Config.Strikes.decaySec then
        return
    end

    st.lastDecay = now
    if #st.strikes == 0 then return end

    table.remove(st.strikes, 1)
end

function ACValidation.RateLimit(src, key, ms)
    ms = ms or Config.RateLimit.defaultMs
    rateLimits[src] = rateLimits[src] or {}

    local now = GetGameTimer()
    local last = rateLimits[src][key] or 0
    if (now - last) < ms then
        return false
    end

    rateLimits[src][key] = now
    return true
end

function ACValidation.AddStrike(src, reason, evidence)
    if ACAdmin.IsBypassed(src) then return 0 end

    local st = playerState[src]
    if not st then return 0 end

    local weight = strikeWeight[reason] or 1
    for _ = 1, weight do
        st.strikes[#st.strikes + 1] = {
            reason = reason,
            evidence = evidence,
            at = os.time(),
        }
    end

    local cutoff = os.time() - Config.Strikes.windowSec
    local fresh = {}
    for _, strike in ipairs(st.strikes) do
        if strike.at >= cutoff then
            fresh[#fresh + 1] = strike
        end
    end
    st.strikes = fresh

    ACLogging.Detection(src, reason, evidence, 'warn')
    return #fresh
end

function ACValidation.Flag(src, reason, evidence)
    if not ACValidation.RateLimit(src, 'flag:' .. reason, Config.RateLimit.flagMs) then
        return
    end

    local count = ACValidation.AddStrike(src, reason, evidence)
    ACPunish.CheckStrikes(src, count)
end

function ACValidation.ValidateHeartbeat(src, data)
    if not Config.Heartbeat.enabled then return end
    if not ACValidation.RateLimit(src, 'heartbeat', Config.RateLimit.heartbeatMs) then return end

    local st = playerState[src]
    if not st then return end

    if type(data) ~= 'table' then
        ACValidation.Flag(src, 'heartbeat_bad_token', { bad = 'payload' })
        return
    end

    if data.token ~= heartbeatTokens[src] then
        ACValidation.Flag(src, 'heartbeat_bad_token', {})
        return
    end

    if data.resourceAlive == false then
        ACValidation.Flag(src, 'resource_stopped', {})
        return
    end

    st.heartbeatMissed = 0

    if math.random(1, 100) == 1 then
        heartbeatTokens[src] = ('%s-%s'):format(src, math.random(100000, 999999))
        TriggerClientEvent('ac:knowledge:heartbeat:sync', src, heartbeatTokens[src])
    end
end

CreateThread(function()
    while true do
        Wait(Config.Heartbeat.intervalMs + 2000)

        for src, st in pairs(playerState) do
            if GetPlayerName(src) then
                st.heartbeatMissed = (st.heartbeatMissed or 0) + 1
                if st.heartbeatMissed >= Config.Heartbeat.maxMissed then
                    ACValidation.Flag(src, 'heartbeat_missed', { missed = st.heartbeatMissed })
                    st.heartbeatMissed = 0
                end
            end
        end
    end
end)

function ACValidation.GetState(src)
    return playerState[src]
end

function ACValidation.ValidateSample(src, data)
    ACMovement.ValidateSample(src, data)
end

function ACValidation.ValidateCombat(src, data)
    ACCombat.ValidateReport(src, data)
end

function ACValidation.ValidateVehicle(src, data)
    if not Config.Vehicle.enabled then return end
    if type(data) ~= 'table' then return end
    if not ACValidation.RateLimit(src, 'vehicle', 2000) then return end

    if data.speed and data.speed > Config.Speed.maxInVehicle * 1.35 then
        ACValidation.Flag(src, 'speed', { speed = data.speed, context = 'vehicle' })
    end
end
