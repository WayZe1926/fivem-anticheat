exports('FlagPlayer', function(src, reason, evidence)
    ACValidation.Flag(src, reason, evidence or {})
end)

exports('AddStrike', function(src, reason, evidence)
    return ACValidation.AddStrike(src, reason, evidence or {})
end)

exports('GetPlayerStrikes', function(src)
    return ACValidation.GetStrikes(src)
end)

exports('IsBypassed', function(src)
    return ACAdmin.IsBypassed(src)
end)

exports('BanPlayer', function(src, reason, hours)
    ACPunish.Ban(src, reason, hours)
end)

exports('KickPlayer', function(src, reason)
    ACPunish.Kick(src, reason)
end)

exports('SecureRegister', function(eventName, handler, opts)
    ACEconomy.SecureRegister(eventName, handler, opts)
end)
