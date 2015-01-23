local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")

local wireless = {}
local function worker(args)
    local args = args or {}

    local widget = wibox.layout.fixed.horizontal()
    local connected = false

    -- Settings
    local ICON_DIR  = awful.util.getdir("config").."/net_widgets/icons/"
    local interface = args.interface or "wlan0"
    local timeout   = args.timeout or 5
        
    local net_icon = wibox.widget.imagebox()
    net_icon:set_image(ICON_DIR.."wireless_na.png")
    local net_text = wibox.widget.textbox()
    net_text:set_text(" N/A ")
    local net_timer = timer({ timeout = timeout })
    local function net_update() 
        local signal_level = tonumber(awful.util.pread("awk 'NR==3 {printf \"%3.0f\" ,($3/70)*100}' /proc/net/wireless"))
        if signal_level == nil then
            connected = false
            net_text:set_text(" N/A ")
            net_icon:set_image(ICON_DIR.."wireless_na.png")
        else
            connected = true
            net_text:set_text(string.format("%3d%%", signal_level))
            if signal_level < 25 then
                net_icon:set_image(ICON_DIR.."wireless_0.png")
            elseif signal_level < 50 then
                net_icon:set_image(ICON_DIR.."wireless_1.png")
            elseif signal_level < 75 then
                net_icon:set_image(ICON_DIR.."wireless_2.png")
            else 
                net_icon:set_image(ICON_DIR.."wireless_3.png")
            end
        end
    end
    
    net_update()
    net_timer:connect_signal("timeout", net_update)
    net_timer:start()
    
    widget:add(net_icon)
    widget:add(net_text)
    
    local function text_grabber()
        local msg = ""
        if connected then
            f = io.popen("iwconfig "..interface)
           
            line    = f:read() or ""    -- wlp1s0    IEEE 802.11abgn  ESSID:"ESSID" 
            essid   = string.match(line, "ESSID:\"(.+)\"") or " N/A "
            line    = f:read() or ""    -- Mode:Managed  Frequency:2.437 GHz  Access Point: aa:bb:cc:dd:ee:ff
            mac     = string.match(line, "Access Point: (.+)") or " N/A "
            line    = f:read() or ""    -- Bit Rate=36 Mb/s   Tx-Power=15 dBm 
            bitrate = string.match(line, "Bit Rate=(.+/s)") or " N/A "
    
            f:close()
            f = io.popen("ifconfig "..interface)
            
            line    = f:read() or ""    -- wlp1s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            line    = f:read() or ""    -- inet 192.168.1.15  netmask 255.255.255.0  broadcast 192.168.1.255
            inet    = string.match(line, "inet (%d+%.%d+%.%d+%.%d+)") or " N/A "
    
            f:close()
            
    
            msg = 
                "┌["..interface.."]\n"..
                "├ESSID:\t\t"..essid.."\n"..
                "├IP:\t\t"..inet.."\n"..
                "├BSSID\t\t"..mac.."\n"..
                "└Bit rate:\t"..bitrate
    
        else
            msg = "Wireless network is disconnected"
        end
    
        return msg
    end
   
    local notification = nil
    function widget:hide() 
        if notification ~= nil then
            naughty.destroy(notification)
            notification = nil
        end
    end

    function widget:show(t_out)
        widget:hide()
    
        notification = naughty.notify({
            preset = fs_notification_preset,
            text = text_grabber(),
            timeout = t_out,
        })
    end

    widget:connect_signal('mouse::enter', function () widget:show(0) end)
    widget:connect_signal('mouse::leave', function () widget:hide() end)
    return widget
end

return setmetatable(wireless, {__call = function(_,...) return worker(...) end})
