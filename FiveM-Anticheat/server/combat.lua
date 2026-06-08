ACCombat = {}

function ACCombat.ValidateReport(src, data)
    if not Config.Combat.enabled then return end
    if type(data) ~= 'table' then return end
    if not ACValidation.RateLimit(src, 'combat', 1500) then return end

    if Config.Weapons.enabled and data.weapon then
        for i = 1, #Config.Weapons.blacklist do
            if data.weapon == Config.Weapons.blacklist[i] then
                ACValidation.Flag(src, 'blacklisted_weapon', { weapon = data.weapon })
                break
            end
        end
    end
end

AddEventHandler('weaponDamageEvent', function(sender, data)
    if not Config.Combat.enabled then return end
    if ACAdmin.IsBypassed(sender) then return end

    local senderPed = GetPlayerPed(sender)
    if not senderPed or senderPed == 0 then return end

    local senderCoords = GetEntityCoords(senderPed)
    local hitEntity = NetworkGetEntityFromNetworkId(data.hitGlobalId or 0)

    if hitEntity and hitEntity ~= 0 and IsPedAPlayer(hitEntity) then
        local victimCoords = GetEntityCoords(hitEntity)
        local dist = #(senderCoords - victimCoords)

        if dist > Config.Combat.maxKillDistance then
            ACValidation.Flag(sender, 'impossible_shot_distance', {
                distance = dist,
                max = Config.Combat.maxKillDistance,
            })
            CancelEvent()
        end
    end
end)

AddEventHandler('explosionEvent', function(sender, ev)
    if not Config.Explosion.enabled then return end
    if ACAdmin.IsBypassed(sender) then return end

    if Config.Explosion.blockAll then
        ACValidation.Flag(sender, 'explosion_blocked', { type = ev.explosionType })
        CancelEvent()
        return
    end

    for i = 1, #Config.Explosion.blacklistTypes do
        if ev.explosionType == Config.Explosion.blacklistTypes[i] then
            ACValidation.Flag(sender, 'explosion_blacklisted', { type = ev.explosionType })
            CancelEvent()
            return
        end
    end

    ACEntity.TrackExplosion(sender)
end)
