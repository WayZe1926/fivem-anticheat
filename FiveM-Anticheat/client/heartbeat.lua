local missed = 0
local token = nil

RegisterNetEvent('ac:knowledge:heartbeat:sync', function(serverToken)
    token = serverToken
    missed = 0
end)

CreateThread(function()
    while true do
        Wait(Config.Heartbeat.intervalMs)

        if not Config.Heartbeat.enabled or not ACClient.IsReady() then
            goto continue
        end

        TriggerServerEvent(Events.Heartbeat, {
            token = token,
            resourceAlive = GetResourceState(GetCurrentResourceName()) == 'started',
            gameTimer = GetGameTimer(),
        })

        ::continue::
    end
end)

AddEventHandler('onClientResourceStop', function(res)
    if res == GetCurrentResourceName() then
        -- server will detect missed heartbeats
    end
end)
