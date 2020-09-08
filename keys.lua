local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local awful = require("awful")
local gears = require("gears")
local beautiful     = require("beautiful")
local naughty = require("naughty")
local wibox         = require("wibox")
local vars = require("vars")
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
                prompt = " > ",
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
    awful.key({ vars.altkey, "Control" }, "l", function () awful.spawn(vars.scrlocker) end,
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
    awful.key({ }, "XF86MonBrightnessUp", function () rat.widgets.brightness.inc(5) end,
              {description = "+5%", group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown", function () rat.widgets.brightness.inc(-5) end,
              {description = "-5%", group = "hotkeys"}),


    -- Pulse volume ctrl
    awful.key({ }, "XF86AudioRaiseVolume", function () rat.widgets.volume.inc(1) end,
        {description = "volume up", group = "hotkeys"}
    ),
    awful.key({ }, "XF86AudioLowerVolume", function () rat.widgets.volume.dec(1) end,
        {description = "volume down", group="hotkeys"}),
    awful.key({ }, "XF86AudioMute", function () rat.widgets.volume.mute() end,
        {description = "toggle mute", group = "hotkeys"}
    ),
    awful.key({ }, "XF86AudioMicMute", function () awful.spawn("pamixer --default-source -t") end,
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

keys.taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ vars.modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ vars.modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)
keys.tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = dpi(250)}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)


keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ vars.modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ vars.modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)
keys.clientkeys = gears.table.join(
    -- awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
    --           {description = "magnify client", group = "client"}),
    awful.key({ vars.modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ vars.modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ vars.modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ vars.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ vars.modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ vars.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ vars.modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ vars.modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

keys.desktop_buttons = gears.table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
    keys.global = gears.table.join(keys.global,
        -- View tag only.
        awful.key({ vars.modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ vars.modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client to tag.
        awful.key({ vars.modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ vars.modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end

-- {{{ attach desktop mouse bindings
root.buttons(keys.desktop_buttons)
-- }}}

-- Attach root keys
root.keys(keys.global)
-- }}}
return keys