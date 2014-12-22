require("awful")
require("awful.autofocus")
require("beautiful")
require("naughty")
require("vain")

tb = require('toolbox')
dir = {}
dir.config = awful.util.getdir('config')
dir.cache = awful.util.getdir('cache')
dir.theme = tb.path.join(dir.config, "/themes/zenburn")

beautiful.init(dir.theme .. "/theme.lua")
beautiful.iconpath = dir.theme

-- custom modules
require("revelation")
require("shifty")
require("panel")
require("volume")
mylayout = require("mylayout")




browser  = tb.client.create_launcher("firefox", true)
editor   = tb.client.create_launcher("gvim", true)
filemgr  = tb.client.create_launcher("thunar", true)
mail     = ""
music    = tb.client.create_launcher("sonata", false)
terminal = tb.client.create_launcher("urxvt")

modkey   = "Mod4"

mwfact80 = ((screen.count() - 1) > 0 and 0.4) or 0.52

shifty.config.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
    vain.layout.cascadebrowse,
    vain.layout.centerwork,
    vain.layout.termfair,
    -- mylayout,
}

-- Shifty configuration
shifty.config.tags = {
    -- web = {
    --     -- exclusive   = true,
    --     -- max_clients = 1,
    --     position    = 1,
    --     layout = awful.layout.suit.tile,
    --     screen = 2,
    -- },
    -- gapps = {
    --     position = 2,
    --     screen = 2,
    --     -- exclusive   = true,
    -- },
    -- ide = {
    --     layout = awful.layout.suit.max,
    --     position = 7
    -- },
    -- ds = {
    --     layout   = awful.layout.suit.max,
    --     position = 8,
    --     slave    = false,
    -- },
    -- rdp = {
    --     layout   = awful.layout.suit.max,
    --     position = 9,
    --     slave    = false,
    --     exclusive= true
    -- },
}
shifty.config.tags['1:web'] = {
        position    = 1,
        layout = awful.layout.suit.tile,
        screen = 2,
}

shifty.config.tags['9:hangouts'] = {
        position    = 9,
        layout = awful.layout.suit.vair,
        screen = 1,
}

dofile(tb.path.join(dir.config, 'apps.lua'))

shifty.config.defaults = {
    layout  = awful.layout.suit.tile,
    ncol    = 1,
    nmaster = 1,
}

-- sloppy focus ?
shifty.config.sloppy = false
-- Add titlebars to all clients when the float?
-- shifty.config.float_bars = true
shifty.modkey = modkey

-- Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))

shifty.config.clientkeys = awful.util.table.join(
    awful.key({modkey, "Shift"}, "c", function(c) c:kill() end),
    -- awful.key({modkey, "Shift"}, "c", function(c)
    --             local cmd = "zenity --question --title='Quit?' --text='Quit?' && echo kill"
    --             local f_reader = io.popen(cmd)
    --             local str = assert(f_reader:read('*a'))
    --             f_reader:close()
    --             if "kill" == str then
    --                 c:kill()
    --             end
    -- end),
    keydoc.group("Window props"),
            awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, "Toggle floating"),
    awful.key({modkey, "Control"}, "Return",
              function(c) c:swap(awful.client.getmaster()) end, "Make master"),
    awful.key({modkey, "Shift"}, "s", awful.client.movetoscreen),
    awful.key({modkey, "Shift"}, "r", function(c) c:redraw() end, "Redraw"),
    awful.key({modkey,}, "t", function(c) c.ontop = not c.ontop end, "Toggle on-top"),
    awful.key({modkey,}, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimize"),
    awful.key({modkey,}, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end, "Maximize")
)

for s = 1, screen.count() do
    local p = panel({
            s = s,
            position='top',
            modkey=modkey,
            layouts=shifty.config.layouts
        })
end

dofile(tb.path.join(dir.config, 'keys.lua'))

shifty.taglist = panel.taglist
shifty.init()


client.add_signal("manage", function (c, startup)
  if (awful.layout.get(c.screen) ==  awful.layout.suit.floating)  
   then
    awful.titlebar.add(c, { modkey = modkey }) 
   end

--{{{ Item added to cause floating:
c:add_signal("property::floating", function(c)
  if awful.layout.get(c.screen) ==  awful.layout.suit.floating or awful.client.floating.get(c)
   then
    awful.titlebar.add(c, { modkey = modkey })
   else
     if not awful.client.property.get(c, "sticky_titlebar") then
       awful.titlebar.remove(c, { modkey = modkey })
     end
   end
end)
end)


client.add_signal("focus",
                  function(c)
                      c.border_color = beautiful.border_focus
                      c.opacity = 1.0
                  end)

client.add_signal("unfocus",
                  function(c)
                      c.border_color = beautiful.border_normal
                      if c.class:find("chrome") or c.class:find("jetbrains") or c.class:find("sun-awt") then
                          c.opacity = 1.0
                      else
                          c.opacity = 0.9
                      end
                  end)
