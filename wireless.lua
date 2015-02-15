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
    local ICON_DIR     = awful.util.getdir("config").."/net_widgets/icons/"
    local interface    = args.interface or "wlan0"
    local timeout      = args.timeout or 5
    local font         = args.font or beautiful.font
    local popup_signal = args.popup_signal or false
    local command_mode = args.command_mode or "default" -- now implemented, "default" or "newer"

    local net_icon = wibox.widget.imagebox()
    net_icon:set_image(ICON_DIR.."wireless_na.png")
    local net_text = wibox.widget.textbox()
    net_text:set_text(" N/A ")
    local net_timer = timer({ timeout = timeout })
    local signal_level = 0
    local function net_update()
        signal_level = tonumber(awful.util.pread("awk 'NR==3 {printf \"%3.0f\" ,($3/70)*100}' /proc/net/wireless"))
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
    -- Hide the text when we want to popup the signal instead
    if not popup_signal then
        widget:add(net_text)
    end

    local function text_grabber()
        local msg = ""
        if connected then
            if command_mode == "newer" then
                -- Use iw/ip
                f = io.popen("iw dev "..interface.." link")
                line    = f:read() or "" -- Connected to 00:01:8e:11:45:ac (on wlp1s0)
                mac     = string.match(line, "Connected to ([0-f:]+)") or " N/A "
                line    = f:read() or "" -- SSID: 00018E1145AC
                essid   = string.match(line, "SSID: (.+)") or " N/A "
                line    = f:read() or "" -- freq: 2437
                line    = f:read() or "" -- RX: 363317 bytes (1223 packets)
                line    = f:read() or "" -- TX: 33835 bytes (231 packets)
                line    = f:read() or "" -- signal: -46 dBm
                line    = f:read() or "" -- tx bitrate: 36.0 MBit/s
                bitrate = string.match(line, "tx bitrate: (.+/s)") or " N/A "

                f:close()
                f = io.popen("ip addr show "..interface)

                line    = f:read() or ""    -- 3: wlp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
                line    = f:read() or ""    -- link/ether 5c:51:4f:d6:d1:c5 brd ff:ff:ff:ff:ff:ff
                line    = f:read() or ""    -- inet 192.168.1.17/24 brd 192.168.1.255 scope global wlp3s0
                inet    = string.match(line, "inet (%d+%.%d+%.%d+%.%d+)") or " N/A "

                f:close()
            else -- "default" and the others
                -- Use iwconfig/ipconfig
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
            end

            signal = ""
            if popup_signal then
                signal = "├Strength\t"..signal_level.."\n"
            end
            msg =
                "<span font_desc=\""..font.."\">"..
                "┌["..interface.."]\n"..
                "├ESSID:\t\t"..essid.."\n"..
                "├IP:\t\t"..inet.."\n"..
                "├BSSID\t\t"..mac.."\n"..
                ""..signal..
                "└Bit rate:\t"..bitrate.."</span>"


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
