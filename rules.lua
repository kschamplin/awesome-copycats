local awful = require("awful")
local beautiful = require("beautiful")
local keys = require('keys')
local vars = require("vars")
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.clientkeys,
                     buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = true } },

    -- Set Firefox to always map on the first tag on screen 1.
    { rule = { class = "firefox" },
      properties = { floating = false, tag = vars.tagnames[2] } },
    { 
        rule = {
            class = "kitty",
            instance = "popup"
        },
        properties = {
            placement = awful.placement.top+awful.placement.center_horizontal,
            above = true,
			sticky = true,
			skip_taskbar = true,
            floating = true,
            titlebars_enabled = false,
            callback = function (c)
                c:connect_signal("unfocus", function (c)
                    c:kill()
                end)
            end
        }
    },
    {
        rule = {
            class = "kitty"
        },
        properties = {
            titlebars_enabled = false,
            border_width = 0
        }
    },
    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized = true } },
}