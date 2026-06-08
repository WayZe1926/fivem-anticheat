ACAdmin = {}

function ACAdmin.IsBypassed(src)
    if not src or src <= 0 then
        return false
    end
    return IsPlayerAceAllowed(src, Config.Admin.acePermission)
end
