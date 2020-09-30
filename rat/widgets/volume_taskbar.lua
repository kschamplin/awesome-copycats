

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")
local rat = require("rat")
local spr = wibox.widget.textbox(" ")

local speaker_icon = wibox.widget({
    text = beautiful.speaker_icon,
    widget = wibox.widget.textbox
})
local mic_icon = wibox.widget({
    text = beautiful.mic_icon,
    widget = wibox.widget.textbox
})

local volume_taskbar = {}
volume_taskbar.widget = wibox.widget({
    spr,
    speaker_icon,
    spr,
    mic_icon,
    spr,
    layout = wibox.layout.fixed.horizontal
})
volume_taskbar.update = function ()
    awful.spawn.easy_async("pamixer --get-mute", function (stdout)
        local muted = (stdout == "true\n")
        if muted then
            speaker_icon:set_text(beautiful.speaker_icon_muted)
        else
            speaker_icon:set_text(beautiful.speaker_icon)
        end
    end)
    awful.spawn.easy_async("pamixer --get-mute --default-source", function (stdout)
        local mic_muted = (stdout == "true\n")
        if mic_muted then
            mic_icon:set_text(beautiful.mic_icon_muted)
        else
            mic_icon:set_text(beautiful.mic_icon)
        end
    end)
end
volume_taskbar.spawn_popup = function ()
    awful.spawn(rat.helpers.popup_program("pulsemixer"))
end

volume_taskbar.widget:buttons(gears.table.join(
    awful.button({ } , 1, function (t)
        volume_taskbar.spawn_popup()
    end, nil)
))
gears.timer({
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = volume_taskbar.update
})
return volume_taskbar