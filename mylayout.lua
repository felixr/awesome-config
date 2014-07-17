local tag       = require("awful.tag")
local beautiful = require("beautiful")
local tonumber  = tonumber

local mylayout =
{
    name          = "mylayout",
    nmaster       = 0,
    ncol          = 0,
    mwfact        = 0,
    offset_x      = 5,
    offset_y      = 32,
    extra_padding = 0
}

function mylayout.arrange(p)
    -- Screen.
    local wa = p.workarea
    local cls = p.clients

    local c = cls[#cls]
    local g = {}
        
    local h = wa.height / #cls

    -- Remaining clients stacked in slave column, new ones on top.
    if #cls > 0 then
            for i = #cls,1,-1
                do
                    c = cls[i]
                    g = {}
                    g.width = wa.width 
                    g.height = h
                    g.x = wa.x 
                    g.y = wa.y + (i - 1) * (wa.height / #cls) 
                    c:geometry(g)
                end
            end
    end

return mylayout

