local vars = {}
vars.theme_name = "insanity"
vars.modkey       = "Mod4"
vars.altkey       = "Mod1"
vars.terminal     = "kitty"
vars.vi_focus     = false -- vi-like client focus - https://github.com/lcpz/awesome-copycats/issues/275
vars.cycle_prev   = true -- cycle trough all previous client or just the first -- https://github.com/lcpz/awesome-copycats/issues/274
vars.editor       = os.getenv("EDITOR") or "vim"
vars.gui_editor   = os.getenv("GUI_EDITOR") or "gvim"
vars.browser      = os.getenv("BROWSER") or "firefox"
vars.scrlocker    = "i3lock --clock --bar-indicator --timecolor=ffffffff --datecolor=ffffffff --image=/home/saji/.config/awesome/themes/insanity/wall.png"
vars.tagnames = { "", "", "Code", "Chat", "5" }
return vars