# FiveM Anti-Cheat 

> **not a paste from a wiki. not a 47-line bypass from 2023. a full server-authoritative anticheat suite with real modules, real sql, real exports — built for devs who are tired of getting their economy deleted by one unprotected net event.**

---

## why this repo exists

i've seen 300 player servers die because of this:

```lua
RegisterNetEvent('job:pay', function(amount)
    xPlayer.addMoney(amount)
end)
```

one menu. one event. one kid with free time. gone.

adhesive, fiveguard, waveshield — all useful. **none of them replace your brain.** they can't fix your `giveItem` event. they can't stop dupes when you update money and inventory separately. they can't validate that a "delivery complete" actually happened.

this repo is the full stack mindset:

```
CLIENT  = sensors (measure, report, never punish)
SERVER  = judge (validate, strike, kick, ban, log)
MYSQL   = truth (transactions, bans, evidence)
```

**disclaimer:** educational + defensive. no adhesive patches. no injectors. no spoofer code. post this to help server owners — not to ruin communities.

---

## feature list (everything included)

### movement & world
| feature | client | server | config key |
|---------|--------|--------|------------|
| speed hack detection | ✅ | ✅ | `Config.Speed` |
| teleport detection | ✅ | ✅ | `Config.Teleport` |
| noclip hints | ✅ | ✅ | `Config.Noclip` |
| super jump hints | ✅ | ✅ | `Config.SuperJump` |
| vehicle hover suspicion | ✅ | ✅ | client main |

### combat & weapons
| feature | client | server | config key |
|---------|--------|--------|------------|
| godmode (invincible + damage test) | ✅ | ✅ | `Config.Godmode` |
| blacklisted weapons | ✅ | ✅ | `Config.Weapons` |
| impossible shot distance | — | ✅ | `weaponDamageEvent` |
| explosion blacklist + spam | — | ✅ | `Config.Explosion` |
| damage / melee modifier detection | ✅ | ✅ | client player |

### player state
| feature | client | server | config key |
|---------|--------|--------|------------|
| invisible ped | ✅ | ✅ | `Config.Invisible` |
| night vision / thermal | ✅ | ✅ | `Config.Vision` |
| health / armor overflow | ✅ | ✅ | `Config.Ped` |
| beast jump | ✅ | ✅ | client player |

### vehicles
| feature | client | server | config key |
|---------|--------|--------|------------|
| blacklisted models (rhino, hydra, etc) | ✅ | ✅ | `Config.Vehicle` |
| vehicle speed validation | ✅ | ✅ | `Config.Vehicle` |

### anti-tamper
| feature | client | server | config key |
|---------|--------|--------|------------|
| heartbeat + rotating token | ✅ | ✅ | `Config.Heartbeat` |
| resource stop detection | ✅ | ✅ | heartbeat |
| missed heartbeat strikes | — | ✅ | `Config.Heartbeat` |

### entity & spam
| feature | client | server | config key |
|---------|--------|--------|------------|
| entity creation limits | — | ✅ | `entityCreating` |
| vehicle/ped/object per-minute caps | — | ✅ | `Config.Entity` |
| explosion rate limit | — | ✅ | `Config.Explosion` |

### economy & events
| feature | client | server | config key |
|---------|--------|--------|------------|
| `SecureRegister` wrapper | — | ✅ | `ACEconomy.SecureRegister` |
| schema validation (type/min/max/enum) | — | ✅ | per-event opts |
| rate limit all secure events | — | ✅ | `Config.Economy` |
| atomic mysql transactions | — | ✅ | `ACEconomy.SafeTransaction` |

### admin & enforcement
| feature | client | server | config key |
|---------|--------|--------|------------|
| ace bypass (`ac.knowledge.bypass`) | — | ✅ | `Config.Admin` |
| weighted strike system | — | ✅ | `strikeWeight` table |
| strike decay | — | ✅ | `Config.Strikes.decaySec` |
| kick / temp ban / perm ban | — | ✅ | `Config.Strikes` |
| connect-time ban check | — | ✅ | `Config.Bans` |

### logging & integrations
| feature | client | server | config key |
|---------|--------|--------|------------|
| mysql detection logs | — | ✅ | `ac_logs` |
| ban + action tables | — | ✅ | `ac_bans`, `ac_actions` |
| discord webhook embeds | — | ✅ | `Config.Webhook` |
| exports for other resources | — | ✅ | `server/exports.lua` |
| ac resource recon on boot | — | ✅ | `Config.ResourceRecon` |

---

## project structure

```
fivem-anticheat-knowledge/
├── fxmanifest.lua
├── README.md
├── shared/
│   ├── config.lua          ← every module toggle + threshold
│   └── events.lua          ← centralized event names
├── client/
│   ├── utils.lua
│   ├── heartbeat.lua
│   ├── main.lua
│   └── detections/
│       ├── movement.lua
│       ├── combat.lua
│       ├── vehicle.lua
│       └── player.lua
├── server/
│   ├── admin.lua
│   ├── logging.lua
│   ├── punishments.lua
│   ├── validation.lua      ← strikes, heartbeat, core
│   ├── movement.lua
│   ├── combat.lua          ← weaponDamageEvent, explosionEvent
│   ├── economy.lua         ← SecureRegister + transactions
│   ├── entity.lua          ← entityCreating limits
│   ├── bans.lua            ← connect ban gate
│   ├── exports.lua
│   └── main.lua
└── sql/
    └── schema.sql
```

---

## install (2 minutes)

1. drop in `resources/[local]/fivem-anticheat-knowledge`
2. import `sql/schema.sql`
3. `server.cfg`:
   ```
   ensure oxmysql
   add_ace group.admin ac.knowledge.bypass allow
   ensure fivem-anticheat-knowledge
   ```
4. optional discord webhook in `shared/config.lua`:
   ```lua
   Config.Webhook = {
       enabled = true,
       url = 'https://discord.com/api/webhooks/...',
   }
   ```
5. tune thresholds for your server (rp servers need looser values than pvp)

---

## how adhesive fits (real talk)

adhesive is cfx client integrity. it fingerprints, scans, reports. cheaters target it because it's client-side — hooks, patches, telemetry blocks, identifier rotation. cfx patches, cheaters adapt, repeat.

**you cannot fix that from lua.**

what you CAN do:
- assume every client is compromised
- never trust payouts, items, jobs, admin actions from client params
- log evidence with license + json payload
- ban on patterns across a strike window
- use db transactions so dupes die

---

## the architecture that doesn't break

```
┌─────────────────────────────────────────────────────────────┐
│                         SERVER                               │
│  SecureRegister │ entityCreating │ weaponDamageEvent         │
│  explosionEvent │ strike engine │ bans │ mysql logs          │
└───────────────────────────▲─────────────────────────────────┘
                            │ net events (rate limited)
┌───────────────────────────┴─────────────────────────────────┐
│                         CLIENT                               │
│  movement/combat/vehicle/player sensors + heartbeat          │
│  NEVER DropPlayer │ NEVER Ban │ NEVER AddMoney                 │
└───────────────────────────▲─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│              Adhesive / platform (not under your control)    │
└─────────────────────────────────────────────────────────────┘
```

---

## secure event pattern (use this everywhere)

**bad — menu food:**
```lua
RegisterNetEvent('shop:sell', function(item, amount, price)
    addMoney(source, price * amount)
end)
```

**good — server owns truth:**
```lua
exports['fivem-anticheat-knowledge']:SecureRegister('shop:sell', function(src, itemName, amount)
    local prices = { gold = 5000, fish = 80 }
    local unit = prices[itemName]
    if not unit then return end
    -- your inventory remove + money add here, server-side only
end, {
    cooldown = 800,
    schema = {
        { type = 'string' },
        { type = 'number', min = 1, max = 50 },
    },
})
```

client sends **intent**. server sends **truth**. menu sends whatever it wants — server says no.

---

## exports api

```lua
-- flag from another resource
exports['fivem-anticheat-knowledge']:FlagPlayer(source, 'custom_reason', { foo = 'bar' })

-- manual strike
exports['fivem-anticheat-knowledge']:AddStrike(source, 'manual', {})

-- check strikes
local n = exports['fivem-anticheat-knowledge']:GetPlayerStrikes(source)

-- admin bypass check
if exports['fivem-anticheat-knowledge']:IsBypassed(source) then return end

-- ban / kick
exports['fivem-anticheat-knowledge']:BanPlayer(source, 'economy_abuse', 72) -- 72h
exports['fivem-anticheat-knowledge']:KickPlayer(source, 'Kicked')

-- wrap your own events
exports['fivem-anticheat-knowledge']:SecureRegister('myjob:finish', function(src, jobId)
    -- server logic
end, { cooldown = 1000, schema = { { type = 'string', enum = { 'delivery', 'mining' } } } })
```

---

## admin commands

| command | who | does |
|---------|-----|------|
| `acstrikes [id]` | console / bypass ace | print strike count |
| `acflag [id] [reason]` | console / bypass ace | manual flag |

give staff bypass:
```
add_ace identifier.license:xxxx ac.knowledge.bypass allow
```

---

## strike weights (why some flags hit harder)

```lua
-- in server/validation.lua
godmode_no_damage = 4 strikes
resource_stopped  = 5 strikes
blacklisted_weapon = 3 strikes
night_vision      = 1 strike
```

tune `Config.Strikes.kickAt` and `banAt` for your tolerance.

---

## db dupe prevention (read this twice)

```lua
-- BAD: disconnect between these = dupe ticket at 3am
RemoveItem(src, 'gold', 1)
AddMoney(src, 5000)

-- GOOD: atomic
ACEconomy.SafeTransaction({
    { query = 'UPDATE users SET money = money + ? WHERE license = ?', values = { 5000, license } },
    { query = 'UPDATE users SET inventory = JSON_REMOVE(inventory, ?) WHERE license = ?', values = { '$."gold"', license } },
}, function(ok)
    if not ok then print('transaction failed') end
end)
```

---

## config tuning tips

| server type | speed max | teleport max | kickAt |
|-------------|-----------|--------------|--------|
| strict pvp | 11.5 | 100 | 4 |
| rp medium | 13.0 | 140 | 6 |
| rp relaxed | 15.0 | 180 | 8 |

always set `graceAfterJoinMs` high enough for spawn loaders.

---

## what will shock people when you post this

1. **it's not readme-only** — full resource with 15+ detection modules
2. **SecureRegister** — copy-paste event hardening with schema validation
3. **heartbeat anti-stop** — catches people killing your ac resource
4. **weighted strikes** — not dumb "1 flag = ban"
5. **entityCreating limits** — stops object/vehicle rain
6. **weaponDamageEvent distance check** — server-side impossible shot detection
7. **discord embeds** — looks professional out of the box
8. **exports** — other devs can plug into it

---

## github post template

**name:** `FiveM-AntiCheat-Knowledge`  
**desc:** `Advanced server-authoritative FiveM anticheat — movement, combat, economy, entity spam, heartbeat, bans, exports. Real code. No bypass garbage.`  
**tags:** `fivem`, `anticheat`, `adhesive`, `lua`, `security`, `gta5`, `oxmysql`

---

## legal

for server owners and developers. bypass tools violate [FiveM ToS](https://fivem.net/terms). use this to protect your community.

---

*if this saves your economy from one menu kid, it did its job.*
