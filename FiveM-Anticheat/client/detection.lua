local lastSample = 0

CreateThread(function()
    while true do
        Wait(Config.Speed.sampleMs)

        local ped = PlayerPedId()
        if not ped or ped == 0 then goto continue end
        if not NetworkIsPlayerActive(PlayerId()) then goto continue end

        local coords = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)
        local speed = GetEntitySpeed(ped)
        local now = GetGameTimer()

        TriggerServerEvent('ac:knowledge:sample', {
            coords = { x = coords.x, y = coords.y, z = coords.z },
            speed = speed,
            inVehicle = veh ~= 0,
            weapon = GetSelectedPedWeapon(ped),
            health = GetEntityHealth(ped),
            sampleMs = now - lastSample,
        })

        lastSample = now

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(5000)

        local ped = PlayerPedId()
        if not ped or ped == 0 then goto continue end

        if IsEntityVisible(ped) and GetPlayerInvincible(PlayerId()) then
            TriggerServerEvent('ac:knowledge:flag', 'local_godmode_hint', {})
        end

        ::continue::
    end
end)
