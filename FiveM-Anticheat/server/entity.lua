ACEntity = {}

local entityCounts = {}
local explosionCounts = {}

local function bumpBucket(src, key, limit)
    local now = os.time()
    entityCounts[src] = entityCounts[src] or {}
    local bucket = entityCounts[src][key] or { count = 0, reset = now + 60 }

    if now >= bucket.reset then
        bucket.count = 0
        bucket.reset = now + 60
    end

    bucket.count = bucket.count + 1
    entityCounts[src][key] = bucket

    if bucket.count > limit then
        ACValidation.Flag(src, 'entity_spam', { type = key, count = bucket.count, limit = limit })
        return false
    end

    return true
end

AddEventHandler('entityCreating', function(entity)
    if not Config.Entity.enabled then return end

    local src = NetworkGetEntityOwner(entity)
    if not src or src <= 0 then return end
    if ACAdmin.IsBypassed(src) then return end

    local entityType = GetEntityType(entity)

    if entityType == 2 then
        if not bumpBucket(src, 'vehicle', Config.Entity.maxVehiclesPerMinute) then
            CancelEvent()
        end
    elseif entityType == 1 then
        if not bumpBucket(src, 'ped', Config.Entity.maxPedsPerMinute) then
            CancelEvent()
        end
    elseif entityType == 3 then
        if not bumpBucket(src, 'object', Config.Entity.maxObjectsPerMinute) then
            CancelEvent()
        end
    end

    if not bumpBucket(src, 'total', Config.Entity.maxPerMinute) then
        CancelEvent()
    end
end)

function ACEntity.TrackExplosion(src)
    if not Config.Explosion.enabled then return end

    local now = os.time()
    explosionCounts[src] = explosionCounts[src] or { count = 0, reset = now + 60 }

    local bucket = explosionCounts[src]
    if now >= bucket.reset then
        bucket.count = 0
        bucket.reset = now + 60
    end

    bucket.count = bucket.count + 1
    if bucket.count > Config.Explosion.maxPerMinute then
        ACValidation.Flag(src, 'explosion_spam', { count = bucket.count })
    end
end

AddEventHandler('playerDropped', function()
    local src = source
    entityCounts[src] = nil
    explosionCounts[src] = nil
end)
