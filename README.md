# Network Widgets
If you use `netctl` or another network manager which doesn't provide any good tray icon or if you want something more native than `nm-applet`, this is for you.

![network widgets total](https://dl.dropbox.com/s/i3aljidy8l6v6mh/net_widgets_total.png?dl=0)
## How to use
First of all you should clone repository in your awesome config directory
```
git clone git@github.com:plotnikovanton/net_widgets.git ~/.config/awesome/net_widgets
```
Then, paste this in your 'rc.lua'
```Lua
local net_widgets = require("net_widgets")
```
### Wireless widget.
![wireless widget](https://dl.dropbox.com/s/737pn4mdwv7x79g/wireless_widget.png)
Widget is simple as hell. Icon changes depend on signal level, if you put mouse pointer on it you can see some information about current connection.

Create widget by
```Lua
net_wireless = net_widgets.wireless({interface="wlp1s0"})
```
After that just place `net_wireless` wherever you want. You can also change widget update timeout. By default it is `timeout=5`, `interface=wlan0`

### Wired network indicator.
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
## Tips
#### Table looks bad
You can change font to monospace by `font` option.

#### Display the signal strength in the popup instead of next to icon
![strenght in popup](https://cloud.githubusercontent.com/assets/23966/6146605/a8eba74c-b1bc-11e4-826a-9468edf18009.png)

Set `popup_signal=true`.

#### Set action on click
Just set `onclick` argument, for example

```Lua
net_wireless = net_widgets.wireless({interface   = "wlp3s0", 
                                     onclick     = terminal .. " -e sudo wifi-menu" }) 
```


#### Get table of wireless widgets or set container widget
Just set `widget` argument as `false`  to get table or some widget layout to change default layout, for example

```Lua
net_wireless = net_widgets.wireless({interface   = "wlp3s0", 
                                     widget = false, }) 
```

or

```Lua
net_wireless = net_widgets.wireless({interface   = "wlp3s0", 
                                     widget = wibox.layout.fixed.vertical(), }) 
```


By default `widget = wibox.layout.fixed.horizontal()`

#### Set indent in wireless textbox
Just set `indent` 
```Lua
net_wireless = net_widgets.wireless({interface   = "wlp3s0", 
                                     indent = 0, }) 
```

or

```Lua
net_wireless = net_widgets.wireless({interface   = "wlp3s0", 
                                     indent = 5, }) 
```


By default `indent = 3`
