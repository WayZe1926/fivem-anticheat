CreateThread(function()
    while true do
        Wait(Config.Vehicle.checkMs)

        if not ACClient.IsReady() or not Config.Vehicle.enabled then
            goto continue
        end

        local ped = ACClient.GetPed()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 then
            goto continue
        end

        local model = GetEntityModel(veh)
        local engine = GetVehicleEngineHealth(veh)
        local speed = GetEntitySpeed(veh)

        ACClient.SendVehicle({
            model = model,
            speed = speed,
            engine = engine,
            modded = GetVehicleMod(veh, 11),
            plate = GetVehicleNumberPlateText(veh),
            driver = GetPedInVehicleSeat(veh, -1) == ped,
        })

        if Config.Vehicle.blockBlacklistedModels then
            for i = 1, #Config.Vehicle.blacklist do
                if model == Config.Vehicle.blacklist[i] then
                    ACClient.SendFlag('blacklisted_vehicle', { model = model })
                    break
                end
            end
        end

        ::continue::
    end
end)
