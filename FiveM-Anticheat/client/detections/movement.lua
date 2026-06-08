local lastCoords = nil
local lastZ = nil
local lastSample = 0
local airStart = 0

CreateThread(function()
    while true do
        Wait(Config.Speed.sampleMs)

        if not ACClient.IsReady() then
            goto continue
        end

        local ped = ACClient.GetPed()
        local coords = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)
        local inVehicle = veh ~= 0
        local speed = GetEntitySpeed(ped)
        local now = GetGameTimer()
        local parachute = GetPedParachuteState(ped)
        local falling = IsPedFalling(ped) or IsPedRagdoll(ped)
        local swimming = IsPedSwimming(ped)

        ACClient.SendSample({
            coords = { x = coords.x, y = coords.y, z = coords.z },
            speed = speed,
            inVehicle = inVehicle,
            falling = falling,
            swimming = swimming,
            parachute = parachute,
            health = GetEntityHealth(ped),
            armor = GetPedArmour(ped),
            weapon = GetSelectedPedWeapon(ped),
            sampleMs = now - lastSample,
            onGround = not IsEntityInAir(ped),
        })

        if Config.SuperJump.enabled and lastZ then
            local dz = coords.z - lastZ
            if dz > Config.SuperJump.maxVerticalDelta and not inVehicle and not falling then
                ACClient.SendFlag('super_jump_hint', { deltaZ = dz })
            end
        end

        if Config.Noclip.enabled then
            local inAir = IsEntityInAir(ped) and not inVehicle and not falling and parachute == -1
            if inAir then
                if airStart == 0 then
                    airStart = now
                local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
                local heightAboveGround = found and (coords.z - groundZ) or 0.0
                if (now - airStart) > Config.Noclip.minAirTimeMs and heightAboveGround > Config.Noclip.minHeight then
                    ACClient.SendFlag('noclip_hint', {
                        airMs = now - airStart,
                        height = coords.z,
                    })
                end
            else
                airStart = 0
            end
        end

        lastCoords = coords
        lastZ = coords.z
        lastSample = now

        ::continue::
    end
end)
