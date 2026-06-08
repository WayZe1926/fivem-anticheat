AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end

    ACClient.Debug('client anticheat loaded')
end)

CreateThread(function()
    while true do
        Wait(15000)

        if not ACClient.IsReady() then
            goto continue
        end

        local ped = ACClient.GetPed()
        if IsPedInAnyPlane(ped) or IsPedInAnyHeli(ped) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and GetEntitySpeed(veh) > 120.0 and GetEntityHeightAboveGround(veh) < 5.0 then
                ACClient.SendFlag('vehicle_hover_suspicion', {
                    speed = GetEntitySpeed(veh),
                    height = GetEntityHeightAboveGround(veh),
                })
            end
        end

        ::continue::
    end
end)
