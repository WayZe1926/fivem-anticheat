CreateThread(function()
    while true do
        Wait(Config.Invisible.checkMs)

        if not ACClient.IsReady() then
            goto continue
        end

        local ped = ACClient.GetPed()

        if Config.Invisible.enabled and not IsEntityVisible(ped) and not IsPedInAnyVehicle(ped, false) then
            ACClient.SendFlag('invisible_ped', {})
        end

        if Config.Vision.enabled then
            if Config.Vision.blockNightVision and GetUsingnightvision() then
                ACClient.SendFlag('night_vision', {})
            end

            if Config.Vision.blockThermal and GetUsingseethrough() then
                ACClient.SendFlag('thermal_vision', {})
            end
        end

        if Config.Ped.enabled then
            local hp = GetEntityHealth(ped)
            local armor = GetPedArmour(ped)

            if hp > Config.Ped.maxHealth then
                ACClient.SendFlag('health_overflow', { health = hp })
            end

            if armor > Config.Ped.maxArmor then
                ACClient.SendFlag('armor_overflow', { armor = armor })
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(8000)

        if not ACClient.IsReady() then
            goto continue
        end

        local ped = ACClient.GetPed()
        if IsPedDoingBeastJump(ped) then
            ACClient.SendFlag('beast_jump', {})
        end

        if GetPlayerWeaponDamageModifier(PlayerId()) > 1.1 then
            ACClient.SendFlag('damage_modifier', { mod = GetPlayerWeaponDamageModifier(PlayerId()) })
        end

        if GetPlayerMeleeWeaponDamageModifier(PlayerId()) > 1.1 then
            ACClient.SendFlag('melee_modifier', { mod = GetPlayerMeleeWeaponDamageModifier(PlayerId()) })
        end

        ::continue::
    end
end)
