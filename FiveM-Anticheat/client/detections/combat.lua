CreateThread(function()
    while true do
        Wait(Config.Weapons.checkMs)

        if not ACClient.IsReady() or not Config.Weapons.enabled then
            goto continue
        end

        local ped = ACClient.GetPed()
        local weapon = GetSelectedPedWeapon(ped)

        for i = 1, #Config.Weapons.blacklist do
            if weapon == Config.Weapons.blacklist[i] then
                ACClient.SendFlag('blacklisted_weapon', { weapon = weapon })
                break
            end
        end

        ACClient.SendCombat({
            weapon = weapon,
            shooting = IsPedShooting(ped),
            aiming = IsPlayerFreeAiming(PlayerId()),
            inCover = IsPedInCover(ped, false),
        })

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(Config.Godmode.checkMs)

        if not ACClient.IsReady() or not Config.Godmode.enabled then
            goto continue
        end

        local ped = ACClient.GetPed()
        if IsEntityVisible(ped) and GetPlayerInvincible(PlayerId()) then
            ACClient.SendFlag('godmode_invincible', {})
        end

        local hpBefore = GetEntityHealth(ped)
        ApplyDamageToPed(ped, Config.Godmode.testDamage, false)
        Wait(50)
        local hpAfter = GetEntityHealth(ped)

        if hpBefore > 100 and hpAfter >= hpBefore then
            ACClient.SendFlag('godmode_no_damage', { before = hpBefore, after = hpAfter })
        else
            SetEntityHealth(ped, hpBefore)
        end

        ::continue::
    end
end)
