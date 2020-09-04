local t = {}
setmetatable(t, {
    __index = function (table, key)
        return rawget(table,key) or require("rat." ..key)
    end
})
return t