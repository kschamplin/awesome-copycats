local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local awful = require("awful")
local gears = require("gears")
local beautiful     = require("beautiful")
local naughty = require("naughty")
local wibox         = require("wibox")
local vars = require("variables")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local rat = require("rat")

local keys = {}

local music_keys = gears.table.join(
    -- MPD control
    awful.key({ vars.altkey, "Control" }, "Up",
        function ()
            os.execute("mpc toggle")
            beautiful.mpd.update()
        end,
        {description = "mpc toggle", group = "widgets"}),
    awful.key({ vars.altkey, "Control" }, "Down",
        function ()
            os.execute("mpc stop")
            beautiful.mpd.update()
        end,
        {description = "mpc stop", group = "widgets"}),
    awful.key({ vars.altkey, "Control" }, "Left",
        function ()
            os.execute("mpc prev")
            beautiful.mpd.update()
        end,
        {description = "mpc prev", group = "widgets"}),
    awful.key({ vars.altkey, "Control" }, "Right",
        function ()
            os.execute("mpc next")
            beautiful.mpd.update()
        end,
        {description = "mpc next", group = "widgets"}),
    awful.key({ vars.altkey }, "0",
        function ()
            local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
            if beautiful.mpd.timer.started then
                beautiful.mpd.timer:stop()
                common.text = common.text .. lain.util.markup.bold("OFF")
            else
                beautiful.mpd.timer:start()
                common.text = common.text .. lain.util.markup.bold("ON")
            end
            naughty.notify(common)
        end,
        {description = "mpc on/off", group = "widgets"}
    )
)
local launcher_keys = gears.table.join(
    awful.key({ vars.modkey }, "space",
        function ()
            -- get a list of all windows.
            local client_table = {}
            local wins = ""
            local winrules = function (c)
                return true --awful.rules.match(c, {})
            end
            for c in awful.client.iterate(winrules) do
                client_table[#client_table + 1] = c
                -- add client id + name
                wins = wins .. #client_table .. " "  .. c.name .. "\n"
            end
            wins = wins:sub(1,-2)
            -- create fzf process that takes the windows and outputs to tmp file
            awful.spawn.easy_async(rat.helpers.popup_program("echo '" .. wins .. "' | fzf --with-nth=2.. > /run/user/1000/chosen-window.txt"), function ()
                awful.spawn.easy_async("cat /run/user/1000/chosen-window.txt", function (stdout, stderr, reason, return_code)
                    if return_code == 0 then
                        local idx = stdout:match("^([^ ]+)") -- get the first field (whitespace delimiting)
                        client_table[tonumber(idx)]:jump_to(true)
                    end
                end)
            end)
        end,
        { description = "switch window", group = "launcher"}
    ),
    awful.key({ vars.modkey }, "Return",
        function () 
            awful.spawn(vars.terminal)
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    awful.key({ vars.modkey }, "q", function () awful.spawn(vars.browser) end,
    {description = "run browser", group = "launcher"}),
    awful.key({ vars.modkey }, "a",
        function ()
            awful.spawn(vars.gui_editor)
        end,
        {description = "run gui editor", group = "launcher"}
    ),

    -- Prompt
    awful.key({ vars.modkey }, "r",
        function ()
            awful.prompt.run({
                prompt = "> ",
                textbox = awful.screen.focused().mypromptbox.widget,
                completion_callback = awful.completion.shell,
                exe_callback = function (cmd)
                    awful.spawn.with_shell("source $HOME/.zshrc && " .. cmd)
                end

            })
        end,
        {description = "run prompt", group = "launcher"}
    )
)
local awesome_keys = gears.table.join(
    awful.key({ vars.modkey,}, "w",
        function ()
            awful.util.mymainmenu:show()
        end,
        {description = "show main menu", group = "awesome"}
    ),
    awful.key({ vars.modkey }, "b", 
        function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibar", group = "awesome"}
    ),

    awful.key({ vars.modkey, "Control" }, "r", rat.helpers.restart,
        {description = "reload awesome", group = "awesome"}
    ),
    awful.key({ vars.modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}
    ),

    awful.key({ vars.modkey }, "x",
        function ()
            awful.prompt.run {
              prompt       = "Run Lua code: ",
              textbox      = awful.screen.focused().mypromptbox.widget,
              exe_callback = awful.util.eval,
              history_path = gears.filesystem.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}
    )
)
keys.global = gears.table.join(
    launcher_keys,
    awesome_keys,
    -- Take a screenshot
    -- https://github.com/lcpz/dots/blob/master/bin/screenshot
    awful.key({ vars.modkey }, "p",
        function() 
            os.execute("screenshot")
        end,
        {description = "take a screenshot", group = "hotkeys"}
    ),
    awful.key({ }, "Print", function () end, {description = "take a screenshot", group = "hotkeys"}),
    -- X screen locker
    awful.key({ vars.altkey, "Control" }, "l", function () os.execute(vars.scrlocker) end,
              {description = "lock screen", group = "hotkeys"}),

    -- Hotkeys
    awful.key({ vars.modkey,}, "s", hotkeys_popup.show_help, {description = "show help", group="awesome"}),
    -- Tag browsing
    awful.key({ vars.modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ vars.modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ vars.modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Default client focus
    awful.key({ vars.altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ vars.altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ vars.modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ vars.modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ vars.modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ vars.modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),


    -- Layout manipulation
    awful.key({ vars.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ vars.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ vars.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ vars.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ vars.modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ vars.modkey,           }, "Tab",
        function ()
            if vars.cycle_prev then
                awful.client.focus.history.previous()
            else
                awful.client.focus.byidx(-1)
            end
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "cycle with previous/go back", group = "client"}),
    awful.key({ vars.modkey, "Shift"   }, "Tab",
        function ()
            if vars.cycle_prev then
                awful.client.focus.byidx(1)
                if client.focus then
                    client.focus:raise()
                end
            end
        end,
        {description = "go forth", group = "client"}),

    -- Show/Hide wibar


    -- On the fly useless gaps change
    -- awful.key({ vars.altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end,
    --           {description = "increment useless gaps", group = "tag"}),
    -- awful.key({ vars.altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
    --           {description = "decrement useless gaps", group = "tag"}),
    -- Standard program


    awful.key({ vars.altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ vars.altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ vars.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ vars.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ vars.modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ vars.modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    -- awful.key({ vars.modkey,           }, "space", function () awful.layout.inc( 1)                end,
    --           {description = "select next", group = "layout"}),
    -- awful.key({ vars.modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),

    awful.key({ vars.modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Widgets popups
    awful.key({ vars.altkey, }, "c", function () if beautiful.cal then beautiful.cal.show(7) end end,
              {description = "show calendar", group = "widgets"}),
    awful.key({ vars.altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
              {description = "show filesystem", group = "widgets"}),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn("xbacklight -inc 5") end,
              {description = "+5%", group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn("xbacklight -dec 5") end,
              {description = "-5%", group = "hotkeys"}),


    -- Pulse volume ctrl
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +1%") end,
        {description = "volume up", group = "hotkeys"}
    ),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -1%") end,
        {description = "volume down", group="hotkeys"}),
    awful.key({ }, "XF86AudioMute", function () awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
        {description = "toggle mute", group = "hotkeys"}
    ),
    awful.key({ }, "XF86AudioMicMute", function () awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle") end,
        {description = "toggle mic mute", group = "hotkeys"}
    ),

    -- TODO: pactl selector


    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ vars.modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
              {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ vars.modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
              {description = "copy gtk to terminal", group = "hotkeys"})

    -- User programs
    --]]
)
return keys