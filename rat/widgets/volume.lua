-- Volume widget based on brightness widget

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")


local volume = {}
local volume_notification = nil


-- this is the actual progress bar.
local volume_bar = wibox.widget {
	color            = beautiful.fg_normal,
	background_color = beautiful.bg_normal,
	forced_width     = 200,
	forced_height    = 25,
	margins          = 1,
	paddings         = 1,
	ticks            = false,
	widget           = wibox.widget.progressbar
}
-- creates a notification and sets up the text and the progress bar
local create_notification = function (text)
    volume_notification = naughty.notify({
        text = text,
        font = beautiful.font,
        width = 200,
        height = 40,
        destroy = function ()
            volume_notification = nil
        end
    })
    volume_notification.box:setup({
        layout = wibox.layout.fixed.vertical,
        {
            layout = wibox.layout.fixed.horizontal,
            volume_notification.textbox
        },
        {
            layout = wibox.layout.fixed.horizontal,
            volume_bar
        }
    })
end

-- Spawns the notification. Called after changes/update.
volume.notify = function ()
    awful.spawn.easy_async("pamixer --get-volume-human", function (stdout)
        local vol_now = tonumber(string.match(stdout, "%d+"))
        if vol_now == nil then
            -- we are muted
            -- dont set volume
            local text = "Volume - Muted"
            if not volume_notification then
                create_notification(text)
            else
                naughty.replace_text(volume_notification, nil, text)
            end 
        else
            -- not muted!
            volume_bar:set_value(vol_now / 100)
            local text = "Volume - " .. vol_now .. "%"
            if not volume_notification then
                create_notification(text)
            else
                naughty.replace_text(volume_notification, nil, text)
            end
        end
    end)
end

volume.inc = function(percent)
    awful.spawn.easy_async("pamixer -i " .. percent, volume.notify)
end
volume.dec = function (percent)
    awful.spawn.easy_async("pamixer -d " .. percent, volume.notify)
end
volume.mute = function ()
    awful.spawn.easy_async("pamixer -t", volume.notify)
end

return volume
