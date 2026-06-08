Config = {}

Config.Debug = false

Config.Admin = {
    acePermission = 'ac.bypass',
}

Config.Webhook = {
    enabled = false,
    url = '',
    username = 'AC Knowledge',
    avatar = '',
    color = 16711680,
}

Config.Strikes = {
    windowSec = 600,
    kickAt = 6,
    banAt = 10,
    decaySec = 120,
}

Config.RateLimit = {
    defaultMs = 400,
    sampleMs = 700,
    flagMs = 1500,
    heartbeatMs = 2000,
}

Config.Speed = {
    enabled = true,
    maxOnFoot = 11.5,
    maxSwimming = 8.0,
    maxInVehicle = 90.0,
    sampleMs = 1200,
    sprintGrace = 1.25,
}

Config.Teleport = {
    enabled = true,
    maxDeltaOnFoot = 100.0,
    maxDeltaInVehicle = 250.0,
    maxDeltaFalling = 180.0,
    graceAfterJoinMs = 12000,
}

Config.Noclip = {
    enabled = true,
    minAirTimeMs = 4000,
    minHeight = 8.0,
    requireNotFalling = true,
}

Config.SuperJump = {
    enabled = true,
    maxVerticalDelta = 6.5,
    windowMs = 800,
}

Config.Godmode = {
    enabled = true,
    checkMs = 4000,
    testDamage = 5,
}

Config.Invisible = {
    enabled = true,
    checkMs = 5000,
}

Config.Weapons = {
    enabled = true,
    checkMs = 3000,
    blacklist = {
        `WEAPON_RAILGUN`,
        `WEAPON_MINIGUN`,
        `WEAPON_RPG`,
        `WEAPON_HOMINGLAUNCHER`,
        `WEAPON_GRENADELAUNCHER`,
        `WEAPON_FIREWORK`,
        `WEAPON_RAYMINIGUN`,
        `WEAPON_EMPLAUNCHER`,
    },
}

Config.Combat = {
    enabled = true,
    maxKillDistance = 320.0,
    maxMeleeDistance = 4.5,
    reportMs = 2500,
}

Config.Vehicle = {
    enabled = true,
    checkMs = 3500,
    maxEnginePowerMultiplier = 1.15,
    blockBlacklistedModels = true,
    blacklist = {
        `RHINO`,
        `HYDRA`,
        `LAZER`,
        `JET`,
        `BOMBUSHKA`,
        `VOLATOL`,
    },
}

Config.Vision = {
    enabled = true,
    checkMs = 6000,
    blockNightVision = true,
    blockThermal = true,
}

Config.Heartbeat = {
    enabled = true,
    intervalMs = 10000,
    maxMissed = 3,
    tokenRotateSec = 45,
}

Config.Entity = {
    enabled = true,
    maxPerMinute = 25,
    maxVehiclesPerMinute = 8,
    maxPedsPerMinute = 10,
    maxObjectsPerMinute = 20,
}

Config.Economy = {
    enabled = true,
    maxSinglePayout = 50000,
    maxSellAmount = 100,
    transactionCooldownMs = 800,
}

Config.Bans = {
    enabled = true,
    checkOnConnect = true,
    message = 'You are banned from this server.',
}

Config.Explosion = {
    enabled = true,
    blockAll = false,
    maxPerMinute = 5,
    blacklistTypes = { 2, 3, 4, 5, 25, 32, 33 },
}

Config.ResourceRecon = {
    enabled = true,
    delayMs = 6000,
    signatures = {
        { file = 'shared_fg-obfuscated.lua', label = 'FiveGuard-style' },
        { file = 'waveshield.lua', label = 'WaveShield-style' },
        { file = 'fxmanifest.lua', label = 'Generic AC scan' },
    },
}

Config.Ped = {
    enabled = true,
    checkMs = 5000,
    maxArmor = 100,
    maxHealth = 200,
}
