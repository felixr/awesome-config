--! @file   panel.lua
--
-- @brief Quick hack to get panels on awesomewm.
--
-- @author  Perry Hargrave
-- @date    2011-09-28
--

local pairs = pairs
local setmetatable = setmetatable

local awful = require('awful')
local tag = require('awful.tag')
local capi = {
    client = client,
    mouse = mouse,
    widget = widget,
    image = image,
    -- timer = timer
}
local beautiful = require('beautiful')

local obvious = require("obvious")
local menu = require('menu')

local battery2 = require('battery2')

module('panel')

local panels = {}

local id = {}
function id:new(t)
    local n = #id + 1
    id[n] = t or {}
    id[n].id = n
    return #id
end
setmetatable(id,
             {
                 __call = function(t, ...) return id:new(...) end
             })

clock = {}
function clock:new(s, args)
    local args = args or {}
    ck = awful.widget.textclock({align = args.align or 'right'}, " 🕒 %H:%M")
    id(ck)
    return ck
end
setmetatable(clock,
             {
                 __call = function(t, ...) return clock:new(...) end
             })

layoutinfo = {}
function layoutinfo:new(s, args)
    local screen = s or 1
    local args = args or {}
    args.type = "textbox"
    local w = capi.widget(args)
    local function layout_name(scr)
        local pretty_names = {}
        pretty_names.tile       = "[tile]"
        pretty_names.tileleft   = "[l-tl]"
        pretty_names.tilebottom = "[b-tl]"
        pretty_names.tiletop    = "[t-tl]"
        pretty_names.fairv      = "[vair]"
        pretty_names.fairh      = "[hair]"
        pretty_names.spiral     = "[spir]"
        pretty_names.dwindle    = "[dwin]"
        pretty_names.max        = "[maxx]"
        pretty_names.fullscreen = "[Full]"
        pretty_names.magnifier  = "[Magn]"
        pretty_names.floating   = "[flt*]"
        pretty_names.mylayout   = "[*my*]"
        pretty_names.cascadebrowse = "[cscb]"
        pretty_names.centerwork = "[cntr]"

        local l = awful.layout.getname(awful.layout.get(scr))
        return pretty_names[l] or l
    end

    w.text = layout_name(1) 

    local function update_on_tag_selection(tag)
        w.text = layout_name(tag.screen)
    end

    tag.attached_add_signal(screen, "property::selected", update_on_tag_selection)
    tag.attached_add_signal(screen, "property::layout", update_on_tag_selection)
    id(w)
    return w
end

setmetatable(layoutinfo,
{
    __call = function(t, ...) return layoutinfo:new(...) end
})

layoutbox = {}
function layoutbox:new(s, args)
    local args = args or {}
    -- Make closures for the different directions
    local lf = function(i)
                return function() awful.layout.inc(args.layouts, i) end
            end

    local buttons = awful.util.table.join(awful.button({}, 1, lf(1)),
                                          awful.button({}, 3, lf(-1)),
                                          awful.button({}, 4, lf(1)),
                                          awful.button({}, 5, lf(-1)))
    local lbox = awful.widget.layoutbox(s)
    lbox:buttons(buttons)
    id(lbox)
    return lbox
end
setmetatable(layoutbox,
             {
                 __call = function(t, ...) return layoutbox:new(...) end
             })

taglist = {}
function taglist:new(s, args)
    local mk = args.modkey or 'Mod4'
    local buttons = awful.util.table.join(
        awful.button({}, 1, awful.tag.viewonly),
        awful.button({mk}, 1, awful.client.movetotag),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button({mk}, 3, function(t) menu.create.tags(nil, t) end),
        awful.button({"Shift"}, 1, awful.client.toggletag),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    )
    buttons = args.buttons or buttons
    local tl = awful.widget.taglist(s,
    function (t, args)
        if not args then args = {} end
        args.bg_occupied = "#000000"
        return awful.widget.taglist.label.all(t, args)
    end,
                                    buttons)
    taglist[s] = tl
    id(tl)
    return tl
end
setmetatable(taglist,
             {
                 __call = function(t, ...) return taglist:new(...) end
             })

prompt = {}
function prompt:new(s, args)
    local args = args or {}
    local layout = args.layout or awful.widget.layout.horizontal.leftright
    local p = awful.widget.prompt({layout = layout})
    id(p)
    prompt[s] = p
    return p
end

function prompt:get(s)
    return prompt[s or capi.mouse.screen]
end
setmetatable(prompt,
             {
                 __call = function(t, ...) return prompt:new(...) end
             })

tasklist = {}
function tasklist:new(s, args)
    local buttons = awful.util.table.join(
                     awful.button({},
                                  1,
                                  function (c)
                                      if c == capi.client.focus then
                                          c.minimized = true
                                      else
                                          if not c:isvisible() then
                                              awful.tag.viewonly(c:tags()[1])
                                          end
                                          -- This will also un-minimize
                                          -- the client, if needed
                                          capi.client.focus = c
                                          c:raise()
                                      end
                                  end),
                     awful.button({},
                                  3,
                                  function (c)
                                      if instance then
                                          instance:hide()
                                          instance = nil
                                      else
                                          instance = menu.create.clients(nil, c)
                                      end
                                  end),
                     awful.button({},
                                  4,
                                  function ()
                                      awful.client.focus.byidx(1)
                                      if capi.client.focus then
                                          capi.client.focus:raise()
                                      end
                                  end),
                     awful.button({},
                                  5,
                                  function ()
                                      awful.client.focus.byidx(-1)
                                      if capi.client.focus then
                                          capi.client.focus:raise()
                                      end
                                  end))

    local labeler = function(c)
        local text, bg, image, icon = awful.widget.tasklist.label.currenttags(c, s)
        if not text then return end
        -- text = "<span style='border: 1px solid white'>" .. c.name .. "</span>"
        if capi.client.focus ~= c then
            bg = beautiful.tasklist_bg
        end
        local ico
        if not c.icon then
            ico = capi.image(beautiful.widget_cpu)
        else
                ico = c.icon
        end
        return text, bg, image, ico
    end
    local tl = awful.widget.tasklist(labeler, buttons)
    id(tl)
    return tl
end
setmetatable(tasklist,
             {
                 __call = function(t, ...) return tasklist:new(...) end
             })

systray = {}
function systray:new(s, args)
    local st = capi.widget({type='systray'})
    id(st)
    return st
end
setmetatable(systray,
             {
                 __call = function(t, ...) return systray:new(...) end
             })

function new(t, args)
    local s = args.s or 1
    args.position = args.position or 'top'
    local p = {}
    if args.layouts then
        lb = layoutbox(s, args)
    end

    p.widgets = {
        taglist = taglist(s, args),
        prompt = prompt(s),
        layoutinfo = layoutinfo(s),  
        layoutbox = (args.layouts and layoutbox(s, args)) or nil,
        clock = clock(s, args),
        systray = (s == 1 and systray(s, args)) or nil,
        tasklist = tasklist(s, args)
    }

    p.wb = awful.wibox({position = args.position, screen = s, height=20})

    p.wb.widgets = {
        {
            p.widgets.taglist,
            p.widgets.prompt,
            layout = awful.widget.layout.horizontal.leftright
        },
        p.widgets.clock,
        battery2(),
        p.widgets.layoutinfo,
        p.widgets.layoutbox,
        p.widgets.systray,
        p.widgets.tasklist,
        layout = awful.widget.layout.horizontal.rightleft
    }

    id(p)
    if not panels[s] then panels[s] = {} end
    panels[s][#panels[s] + 1] = p
    return p
end


DEFAULT = {
    s = 1,
    modkey = 'Mod4',
    position = 'top'
}

get = {}
function get.by_screen(s)
    return panels[s]
end

function get.by_id(i)
    return id[i]
end

function get.by_position(p, s)
    local s = s or capi.mouse.screen
    local r = {}
    for k, v in pairs(panels[s]) do
        if p == v.position then table.insert(r, v) end
    end
    return r
end

setmetatable(_M,
             {
                 __index = panels,
                 __call = new,
             })
