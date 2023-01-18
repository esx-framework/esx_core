<h1 align='center'>[ESX] Notify</a></h1><p align='center'><b><a href='https://discord.esx-framework.org/'>Discord</a> - <a href='https://esx-framework.org/'>Website</a> - <a href='https://docs.esx-framework.org/legacy/installation'>Documentation</a></b></h5>

A beautiful and simple NUI notification system for ESX

# Example Code

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

# Previews

![Preview_1](https://cdn.discordapp.com/attachments/944789399852417096/997890963445927977/unknown.png)

![Preview_2_zoom](https://cdn.discordapp.com/attachments/944789399852417096/997892214053163148/unknown.png)

![Preview_2](https://cdn.discordapp.com/attachments/944789399852417096/997891726326898909/unknown.png)

## Legal

esx_notify- Notify!

Copyright (C) 2023 ESX-Framework

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see <http://www.gnu.org/licenses/>.
