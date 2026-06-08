ACEconomy = {}

local secureHandlers = {}

function ACEconomy.SecureRegister(eventName, handler, opts)
    opts = opts or {}
    local cooldown = opts.cooldown or Config.Economy.transactionCooldownMs
    local schema = opts.schema or {}

    secureHandlers[eventName] = true

    RegisterNetEvent(eventName, function(...)
        local src = source
        local args = { ... }

        if ACAdmin.IsBypassed(src) then
            return handler(src, table.unpack(args))
        end

        if not ACValidation.RateLimit(src, 'secure:' .. eventName, cooldown) then
            ACValidation.Flag(src, 'event_abuse', { event = eventName, reason = 'rate_limit' })
            return
        end

        for i, rule in ipairs(schema) do
            local val = args[i]
            if rule.type and type(val) ~= rule.type then
                ACValidation.Flag(src, 'event_abuse', { event = eventName, reason = 'type_' .. i })
                return
            end
            if rule.type == 'number' then
                if rule.min and val < rule.min then
                    ACValidation.Flag(src, 'event_abuse', { event = eventName, reason = 'min_' .. i })
                    return
                end
                if rule.max and val > rule.max then
                    ACValidation.Flag(src, 'event_abuse', { event = eventName, reason = 'max_' .. i })
                    return
                end
            end
            if rule.enum then
                local ok = false
                for _, allowed in ipairs(rule.enum) do
                    if val == allowed then ok = true break end
                end
                if not ok then
                    ACValidation.Flag(src, 'event_abuse', { event = eventName, reason = 'enum_' .. i })
                    return
                end
            end
        end

        handler(src, table.unpack(args))
    end)
end

-- example hardened shop event
ACEconomy.SecureRegister('ac:example:sellItem', function(src, itemName, amount)
    if type(itemName) ~= 'string' or type(amount) ~= 'number' then return end

    local catalog = {
        gold = 5000,
        iron = 250,
        fish = 80,
    }

    local price = catalog[itemName]
    if not price then
        ACValidation.Flag(src, 'event_abuse', { event = 'sellItem', item = itemName })
        return
    end

    local total = price * amount
    if total > Config.Economy.maxSinglePayout then
        ACValidation.Flag(src, 'event_abuse', { event = 'sellItem', total = total })
        return
    end

    ACLogging.Detection(src, 'sell_ok', { item = itemName, amount = amount, total = total }, 'info')
end, {
    cooldown = Config.Economy.transactionCooldownMs,
    schema = {
        { type = 'string' },
        { type = 'number', min = 1, max = Config.Economy.maxSellAmount },
    },
})

function ACEconomy.SafeTransaction(queries, onDone)
    MySQL.transaction(queries, function(success)
        if onDone then onDone(success == true) end
    end)
end

function ACEconomy.TransferItemForMoney(license, item, amount, moneyPer, onDone)
    local total = amount * moneyPer

    ACEconomy.SafeTransaction({
        {
            query = 'UPDATE ac_demo_users SET money = money + ? WHERE license = ?',
            values = { total, license },
        },
        {
            query = 'UPDATE ac_demo_users SET inventory = JSON_REMOVE(inventory, ?) WHERE license = ?',
            values = { '$."' .. item .. '"', license },
        },
    }, onDone)
end
