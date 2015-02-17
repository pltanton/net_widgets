local module_path = (...):match ("(.+/)[^/]+$") or ""

package.loaded.net_widgets = nil

local net_widgets = {
    indicator   = require(module_path .. "net_widgets.indicator"),
    wireless    = require(module_path .. "net_widgets.wireless")
}

return net_widgets
