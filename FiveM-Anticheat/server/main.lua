RegisterNetEvent(Events.Sample, function(data)
    ACValidation.ValidateSample(source, data)
end)

RegisterNetEvent(Events.Flag, function(reason, evidence)
    local src = source
    if type(reason) ~= 'string' then return end
    ACValidation.Flag(src, reason, evidence)
end)

RegisterNetEvent(Events.Heartbeat, function(data)
    ACValidation.ValidateHeartbeat(source, data)
end)

RegisterNetEvent(Events.Combat, function(data)
    ACValidation.ValidateCombat(source, data)
end)

RegisterNetEvent(Events.Vehicle, function(data)
    ACValidation.ValidateVehicle(source, data)
end)

AddEventHandler('playerJoining', function()
    ACValidation.InitPlayer(source)
end)

AddEventHandler('playerDropped', function()
    ACValidation.ClearPlayer(source)
end)

CreateThread(function()
    if not Config.ResourceRecon.enabled then return end
    Wait(Config.ResourceRecon.delayMs)

    local num = GetNumResources()
    for i = 0, num - 1 do
        local res = GetResourceByFindIndex(i)
        if res and GetResourceState(res) == 'started' then
            for _, sig in ipairs(Config.ResourceRecon.signatures) do
                local content = LoadResourceFile(res, sig.file)
                if content and sig.file ~= 'fxmanifest.lua' then
                    print(('[AC-RECON] %s detected in resource: %s'):format(sig.label, res))
                end
            end
        end
    end
end)

RegisterCommand('acstrikes', function(src, args)
    if src ~= 0 and not ACAdmin.IsBypassed(src) then return end
    local target = tonumber(args[1])
    if not target then return end
    print(('[AC] Player %s strikes: %s'):format(target, ACValidation.GetStrikes(target)))
end, false)

RegisterCommand('acflag', function(src, args)
    if src ~= 0 and not ACAdmin.IsBypassed(src) then return end
    local target = tonumber(args[1])
    local reason = args[2] or 'manual_flag'
    if target then
        ACValidation.Flag(target, reason, { by = src })
    end
end, false)

print('[^2AC^7] wayze-ac v2 loaded — server authoritative mode')
