<h1 align="center">ESX Notify</h1>

<h3>Change style and time</h3>

```lua
---usage: message/type/length
ESX.ShowNotification("message here", "error", 3000)
ESX.ShowNotification("message here", "success", 3000)
ESX.ShowNotification("message here", "info", 3000)

ESX.ShowNotification("text here") -- Default will time and type will be info/3000
```

<h3>Export Usage</h3>

```lua
exports["esx_notify"]:Notify("info", 3000, "message here")
```

<h3>Event Usage</h3>

```lua
TriggerEvent("ESX:Notify", "info", 3000, "message here")
```

<h3>Color Code Usage</h3>

```lua
~r~ = Red
~b~ = Blue
~g~ = Green
~y~ = Yellow
~p~ = Purple
~c~ = Grey
~m~ = Dark Grey
~u~ = Black
~o~ = Orange

ESX.ShowNotification("I i ~r~love~s~ donuts", "success", 3000)
```

<img src="https://imgur.com/gsNwFO3.png" alt="image">
