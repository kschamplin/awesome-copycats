

local awesome = awesome
local awful = require("awful")
local naughty = require("naughty")

local vars = require("variables")
local helpers = {}

helpers.run_once = function (cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end
helpers.popup_program= function(cmd)
    return vars.terminal .. "\
        -o remember_window_size=no \
        -o initial_window_width=120c \
        -o initial_window_height=20c" .. 
        " --name popup  zsh -c \"source $HOME/.zshrc && " .. cmd .. "\""
end
helpers.restart = function ()
    awful.spawn.easy_async("awesome -k", function (stdout, stderr)
        if stderr == "✔ Configuration file syntax OK.\n" then
            awesome.restart()
        else
            -- print awesome -k errors.
            naughty.notify({
                title = "Error with awesome config!",
                text = stderr,
                ignore_suspend = true,
                preset = naughty.config.presets.critical
            })
        end
    end)
end
return helpers