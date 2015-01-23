# Network Widgets
If you use `netctl` or another network manager wich not provide any good tray icon or want something more native than `nm-applet`, that widgets for you.

![network widgets total](https://dl.dropbox.com/s/i3aljidy8l6v6mh/net_widgets_total.png?dl=0)
## How to use
First of all you should to clone repository in your awesome config directory
```
git clone git@github.com:plotnikovanton/net_widgets.git ~/.config/awesome/net_widgets
```
Then, past these in your 'rc.lua'
```Lua
local net_widgets = require("net_widgets")
```
### Wireless widget.
![wireless widget](https://dl.dropbox.com/s/737pn4mdwv7x79g/wireless_widget.png)
Widget is siple as hell. Icon changes depends on signal level, if you put mouse on it you can see some information about current connection.

Create widget by
```Lua
net_wireless = net_widgets.wireless({interface="wlp1s0"})
```
After that just place `net_wireless` whatever you want
In arguments you can change also `timeout` of widget update. Bu tefault it is `timeout=5`, `interface=wlan0`

### Wided network indicator.
![wired widget](https://dl.dropbox.com/s/5hg1bo41luelzob/wired_icon.png)
If network is disconnected icon changes color to red. You can set multiple interfaces to indicate it. It also have got popup.

To create widget put in `rc.lua`
```Lua
net_wired = net_widgets.indicator({
    interfaces  = {"enp2s0", "another_interface", "and_another_one"},
    timeout     = 5
})
```

By default `interfaces={"enp2s0"}`, `timeout=5`
