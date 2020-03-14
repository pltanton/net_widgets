local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local module_path = (...):match ("(.+/)[^/]+$") or ""

local indicator = {}
local function worker(args)
  local args = args or {}
  local widget = wibox.container.background()
  local wired = wibox.widget.imagebox()
  local wired_na = wibox.widget.imagebox()
  -- Settings
  local interfaces = args.interfaces
  local ignore_interfaces = args.ignore_interfaces or {}
  local ICON_DIR = awful.util.getdir("config").."/"..module_path.."/net_widgets/icons/"
  local timeout = args.timeout or 5
  local font = args.font or beautiful.font
  local onclick = args.onclick
  local hidedisconnected = args.hidedisconnected
  local popup_position = args.popup_position or naughty.config.defaults.position

  local function get_interfaces()
    local ifaces = {}
    f = io.popen("ip link")
    for line in f:lines() do
      -- 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 [...]
      --     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      -- 2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 [...]
      --     link/ether 1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
      local iface = string.match(line, "^%d+:%s+([%l%d]+):%s+<")
      if iface then
        for _, i in pairs(ignore_interfaces) do
          if (i == iface) then
            iface = nil
            break
          end
        end
        if iface then
          table.insert(ifaces, iface)
        end
      end
    end
    f:close()
    return ifaces
  end

  local connected = false
  local function text_grabber()
    local msg = ""
    for _, i in pairs(interfaces or get_interfaces()) do
      msg = msg .. "\n<span font_desc=\""..font.."\">┌["..i.."]\n"
      f = io.popen("ip addr show "..i)
      for line in f:lines() do
        inet = string.match(line, "inet ([%d.]+)")
        if inet then
          -- inet 192.168.1.190/24 brd 192.168.1.255 scope global enp3s0
          msg = msg .. "├IP:\t"..inet.."\n"
        else
          mac = string.match(line, "link/ether ([%x:]+)")
          if mac then
            -- link/ether 1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
            msg = msg .. "├MAC:\t"..mac.."\n"
          end
        end
      end
      f:close()

      local localrt = {}
      f = io.popen("ip route")
      for line in f:lines() do
        local rt = string.match(line, "^([^%s]+) dev "..i)
        if rt then
          -- 10.11.0.0/24 dev tun2 proto kernel scope link src 10.11.0.3
          if string.match(line, " proto ") then
            proto = string.match(line, " proto ([^%s]+) ")
            if not (proto == "kernel") then
              rt = rt .. " [" .. proto .. "]"
            end
          end
          table.insert(localrt, rt)
        else
          rt = string.match(line, "^([^%s]+ via [%d.]+) dev "..i)
          if rt then
            -- link/ether 1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
            if string.match(line, " proto ") then
              proto = string.match(line, " proto ([^%s]+) ")
              if not (proto == "kernel") then
                rt = rt .. " [" .. proto .. "]"
              end
            end
            msg = msg .. "├RT:\t"..rt.."\n"
          end
        end
      end
      f:close()

      if (#localrt == 0) then
        table.insert(localrt, "NO LOCAL ROUTE")
      end
      for rt = 1, #localrt - 1 do
        msg = msg .. "├LOC:\t"..localrt[rt].."\n"
      end
      msg = msg .. "└LOC:\t"..localrt[#localrt].."</span>\n"

    end
    return msg
  end

  wired:set_image(ICON_DIR.."wired.png")
  wired_na:set_image(ICON_DIR.."wired_na.png")
  widget:set_widget(wired_na)
  local function net_update()
    connected = false
    for _, i in pairs(interfaces or get_interfaces()) do
      awful.spawn.easy_async("bash -c \"ip link show "..i.." | awk 'NR==1 {printf \\\"%s\\\", $9}'\"", function(stdout, stderr, reason, exit_code)
          state = stdout:sub(1, stdout:len() - 1)
          if (state == "UP") then
            connected = true
          end
          if connected then
            widget:set_widget(wired)
          else
            if not hidedisconnected then
              widget:set_widget(wired_na)
            else
              widget:set_widget(nil)
            end
          end
        end)
    end

    return true
  end

  net_update()

  gears.timer.start_new(timeout, net_update)

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
        screen = mouse.screen,
        position = popup_position
      })
  end

  -- Bind onclick event function
  if onclick then
    widget:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.util.spawn(onclick) end)
    ))
  end

  widget:connect_signal('mouse::enter', function () widget:show(0) end)
  widget:connect_signal('mouse::leave', function () widget:hide() end)
  return widget
end
return setmetatable(indicator, {__call = function(_,...) return worker(...) end})
