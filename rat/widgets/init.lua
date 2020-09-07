local t = {}
setmetatable(t, {
    __index = function (table, key)
        if not rawget(table, key) then
            -- the key does not exist, so load it
            table[key] = require("rat.widgets." .. key)
        end
        return rawget(table,key)
    end
})
return t