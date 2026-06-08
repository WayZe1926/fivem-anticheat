ACClient = ACClient or {}

function ACClient.GetPed()
    local ped = PlayerPedId()
    if not ped or ped == 0 then
        return nil
    end
    return ped
end

function ACClient.IsReady()
    if not NetworkIsPlayerActive(PlayerId()) then
        return false
    end
    return ACClient.GetPed() ~= nil
end

function ACClient.SendFlag(reason, evidence)
    TriggerServerEvent(Events.Flag, reason, evidence or {})
end

function ACClient.SendSample(payload)
    TriggerServerEvent(Events.Sample, payload)
end

function ACClient.SendCombat(payload)
    TriggerServerEvent(Events.Combat, payload)
end

function ACClient.SendVehicle(payload)
    TriggerServerEvent(Events.Vehicle, payload)
end

function ACClient.Debug(msg)
    if Config.Debug then
        print('[AC-CLIENT] ' .. msg)
    end
end
