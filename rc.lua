-- --stolen from http://www.markurashi.de/dotfiles/awesome/rc.lua

-- failsafe mode
-- if the current config fail, load the default rc.lua

require("awful")
require("naughty")

keydoc = require("keydoc")

stacktrace = ""
awful.util.spawn_with_shell("xrdb -merge $HOME/.Xresources")

confdir = awful.util.getdir("config")
local rc, err = loadfile(confdir .. "/awesome.lua");
if rc then
    rc, err = pcall(rc)
    -- function()
    --     stacktrace = debug.traceback()
    --     add
    -- end)
    if rc then
        return;
    end
end

dofile("/etc/xdg/awesome/rc.lua");

for s = 1,screen.count() do
    mypromptbox[s].text = awful.util.escape(err:match("[^\n]*"));
end

naughty.notify(
    {text="Awesome crashed during startup on " ..
            os.date("%d%/%m/%Y %T:\n\n")
            .. err .. "\n" .. stacktrace .. "\n", timeout = 0}
    )
