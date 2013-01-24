-- vim: ft=lua fdm=marker: 
local keydoc = require("keydoc")
local capi = {
    client = client
}

-- Key bindings
globalkeys = awful.util.table.join(
    keydoc.group("Navigation"), --{{{
    awful.key({modkey,}, "j",
        function()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end, "Next client"),
    awful.key({modkey,}, "k",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, "Prev client"),
        
    -- Layout manipulation
    awful.key({modkey, "Shift"}, "j",
              function() awful.client.swap.byidx(1) end, "Swap next"),
    awful.key({modkey, "Shift"}, "k",
              function() awful.client.swap.byidx(-1) end, "Swap prev"),
    awful.key({modkey}, "s",
              function()
                  awful.screen.focus_relative(1)
                  local mc = mouse.coords()
                  mouse.coords({x=mc.x + 40, y=mc.y + 40}, true)
              end),
    awful.key({modkey,}, "u", awful.client.urgent.jumpto),
    awful.key({modkey,}, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Toggle client"),
    ---}}}

    keydoc.group("Awesome"), -- {{{
    awful.key({modkey, "Control"}, "r", awesome.restart, "Restart"),
    awful.key({modkey, "Shift"}, "q", awesome.quit, "Quit"),
    -- }}}

    keydoc.group("Layout"), -- {{{
    awful.key({modkey,}, "=", function() awful.tag.setmwfact(0.5) end, "Master 50/50"),
    awful.key({modkey,}, "l", function() awful.tag.incmwfact(0.05) end, "Master  size+"),
    awful.key({modkey,}, "h", function() awful.tag.incmwfact(-0.05) end, "Master size-"),
    awful.key({modkey, "Shift"}, "h",
              function() awful.tag.incnmaster(1) end, "Master num+"),
    awful.key({modkey, "Shift"}, "l",
              function() awful.tag.incnmaster(-1) end, "Master num-"),
    awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1) end, "Column +"),
    awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1) end, "Column -"),
    awful.key({modkey}, "space",
              function() awful.layout.inc(shifty.config.layouts, 1) end, "Next layout"),
    awful.key({modkey, "Shift"}, "space",
              function() awful.layout.inc(shifty.config.layouts, -1) end, "Prev layout"),

    awful.key({modkey, "Shift"}, "n", shifty.send_prev, "Send to prev"),
    awful.key({modkey}, "n", shifty.send_next, "Send to next"),
    awful.key({modkey, "Mod1"}, "n", function() 
        local c = capi.client.focus
        local t = shifty.add()
        awful.client.movetotag(t, c)
    end, "Move to new tag"),
    -- awful.key({modkey, "Control"},
    --           "n",
    --           function()
    --               local t = awful.tag.selected()
    --               local s = awful.util.cycle(screen.count(), t.screen + 1)
    --               awful.tag.history.restore()
    --               t = shifty.tagtoscr(s, t)
    --               awful.tag.viewonly(t)
    --           end),
    
    -- }}}
    
    keydoc.group("Tag"), -- {{{
    awful.key({modkey, "Shift"}, "r", shifty.rename, "Rename"),
    awful.key({modkey}, "d", shifty.del, "Delete"),
    awful.key({modkey, "Shift"}, "a", shifty.add, "Add"),
    awful.key({modkey,}, "Left", awful.tag.viewprev, "Prev tag"),
    awful.key({modkey,}, "Right", awful.tag.viewnext, "Next tag"),
    awful.key({modkey,}, "Escape", awful.tag.history.restore, "History restore"),
    -- }}}

    -- Revelation
    keydoc.group("Misc"), ---{{{
    awful.key({modkey}, "e", revelation, "Show all windows"), -- all clients
    awful.key({modkey, "Shift"},          -- only terminals
              "e",
              function() revelation({class="URxvt"}) end, "Show all Terminals"
              ),
   -- KeyDoc
   awful.key({ modkey, }, "F1", keydoc.display),
   awful.key({ modkey,"Control" }, "x", keydoc.display),

    -- Prompt
    -- awful.key({modkey},
    --           "r",
    --           function()
    --               panel.prompt:get(mouse.screen):run()
    --           end, "Run prompt"),


     -- Run or raise applications with dmenu
     awful.key({ modkey }, "r",
            function ()
                local f_reader = io.popen( "dmenu_path | dmenu -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
                local command = assert(f_reader:read('*a'))
                f_reader:close()
                if command == "" then return end

                -- Check throught the clients if the class match the command
                local lower_command=string.lower(command)
                for k, c in pairs(client.get()) do
                    local class=string.lower(c.class)
                    if string.match(class, lower_command) then
                        for i, v in ipairs(c:tags()) do
                            awful.tag.viewonly(v)
                            c:raise()
                            c.minimized = false
                            return
                        end
                    end
                end
                awful.util.spawn(command)
            end),

    awful.key({modkey}, "x",
              function()
                  pb = panel.prompt:get(mouse.screen)
                  awful.prompt.run({
                                    prompt="Lua code: "},
                                    panel.prompt:get(mouse.screen).widget,
                                    awful.util.eval,
                                    nil,
                                    awful.util.getdir("cache").."/history_eval"
                                    )
              end, "Lua prompt"),

    -- Applications
    keydoc.group("Apps"), -- {{{
    awful.key({modkey,}, "Return", terminal, "Terminal"),
    awful.key({modkey, "Mod1"}, "e", editor, "Editor"),
    awful.key({modkey, "Mod1"}, "f", filemgr, "File mgr"),
    awful.key({modkey}, "XF86Calculator", function() awful.util.spawn("i3lock -c 000000 -d") end, "Lock screen"),
    -- }}}
    
    keydoc.group("Volume"), -- {{{
    awful.key({modkey}, "XF86Back", function() volume(-5) end, "Volume -5"),
    awful.key({}, "XF86AudioLowerVolume", volume.lower, "Volume -1"),
    awful.key({modkey}, "XF86Forward", function() volume(5) end, "Volume +5"),
    awful.key({}, "XF86AudioRaiseVolume", volume.raise, "Volume +1")
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({modkey}, i, function()
            awful.tag.viewonly(shifty.getpos(i))
        end),

        awful.key({modkey, "Control"}, i, function()
            this_screen = awful.tag.selected().screen
            t = shifty.getpos(i, this_screen)
            t.selected = not t.selected
        end),

        awful.key({modkey, "Shift"}, i, function()
            if client.focus then
                local c = client.focus
                slave = not (client.focus ==
                                awful.client.getmaster(mouse.screen))
                t = shifty.getpos(i)
                awful.client.movetotag(t,c)
                awful.tag.viewonly(t)
                if slave then awful.client.setslave(c) end
            end
        end)
    )
end
root.keys(globalkeys)
