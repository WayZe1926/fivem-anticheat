ACMovement = {}

function ACMovement.ValidateSample(src, data)
    if type(data) ~= 'table' then return end
    if not ACValidation.RateLimit(src, 'sample', Config.RateLimit.sampleMs) then return end

    local st = ACValidation.GetState(src)
    if not st then return end

    if (GetGameTimer() - st.joinedAt) < Config.Teleport.graceAfterJoinMs then
        st.lastCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
        return
    end

    local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
    local speed = tonumber(data.speed) or 0.0
    local inVehicle = data.inVehicle == true
    local falling = data.falling == true
    local swimming = data.swimming == true

    if Config.Teleport.enabled and st.lastCoords then
        local delta = #(coords - st.lastCoords)
        local maxDelta = Config.Teleport.maxDeltaOnFoot

        if inVehicle then
            maxDelta = Config.Teleport.maxDeltaInVehicle
        elseif falling then
            maxDelta = Config.Teleport.maxDeltaFalling
        end

        if delta > maxDelta then
            ACValidation.Flag(src, 'teleport', { delta = delta, max = maxDelta })
        end
    end

    if Config.Speed.enabled then
        local maxSpeed = Config.Speed.maxOnFoot * Config.Speed.sprintGrace
        if swimming then
            maxSpeed = Config.Speed.maxSwimming
        elseif inVehicle then
            maxSpeed = Config.Speed.maxInVehicle
        end

        if speed > maxSpeed then
            ACValidation.Flag(src, 'speed', { speed = speed, max = maxSpeed })
        end
    end

    st.lastCoords = coords
end
