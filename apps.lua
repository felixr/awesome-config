reload_rules = function()
    dofile('/home/rdl/.config/awesome/apps.lua')
    local serpent = require('serpent')
    local shifty = require('shifty')

    for k,v in ipairs(client.get()) do
        local status, err = pcall(shifty.match, v,true)
        if not status then
            return err
        end

    end

    return serpent.block(shifty.config.apps)
end

shifty.config.apps = {
    {
        match          = {""},
        float          = true,
        honorsizehints = true,
        buttons        = awful.util.table.join(
            awful.button({}, 1, function(c) client.focus = c; c:raise() end),
            awful.button({modkey}, 1, awful.mouse.client.move),
            awful.button({modkey}, 3, awful.mouse.client.resize)),
        slave          = true,
        callback = function(c)
            -- if c.skip_taskbar and c.icon == nil then
            if c.skip_taskbar then
                c.border_width = 0
            end
        end
    },
    {
        match = {".*IntelliJ IDEA.*"},
        tag = "ide",
        float = false
    },
    {
        match = {"libreoffice.*",
                    name={"%Microsoft Word", "XChange Viewer"}
                },
        float = false,
        tag   = "office",
    },
    {
        match = {"remmina", "rdesktop"},
        float = false,
        tag   = "rdp",
    },
    {
        match = {"vim", "gvim", "Oracle SQL Developer", "emacs"},
        float = false,
    },
    {
        match = {"Navigator", "Firefox"},
        tag   = "web",
        float = false,
    },
    {
        match = {"Thunderbird"},
        tag   = "mail",
        float = false,
    },
    {
        match = {"Evince"},
        tag   = "ds",
        float = false,
    },
    -- {
    --     match          = {"R"},
    --     honorsizehints = true,
    --     float          = true,
    --     ontop          = true
    -- },
    {
        match          = { "%-terminal", "urxvt", "R_x11"},
        honorsizehints = false,
        float          = false,
        ontop          = false
    },
    {
        match = {"dialog", "%-applet", "MPlayer", "Sonata", "Thunar", "Skype"},
        intrusive = true,
        float = true
    },
    {
        match = { name = {"Commit Monitor"}},
        float = true,
        ontop = true,
        intrusive = true
    },
}
