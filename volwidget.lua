-- a simple volume widget using pulseaudio.

local string = string

local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local volwidget = wibox.widget.base.make_widget()
