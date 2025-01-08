## Use

 * ESX Function
```lua
    ESX.Progressbar("test", 25000,{
        FreezePlayer = false, 
        animation ={
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh", 
            lib ="low_car_sex_to_prop_p2_player" 
        }, 
        onFinish = function()
        --Code here
    end})

```

* Export
  
```lua
    exports["esx_progressbar"]:Progressbar("Unlocking Storage", 3000,{
        FreezePlayer = true, 
        animation ={
            type = "anim",
            dict = "anim@mp_player_intmenu@key_fob@", 
            lib ="fob_click"
        },
        onFinish = function()
        --Code here
    end})
```

* Cancel
  
```lua
    ESX.Progressbar("Unlocking Storage", 3000,{
        FreezePlayer = true, 
        animation ={
            type = "anim",
            dict = "anim@mp_player_intmenu@key_fob@", 
            lib ="fob_click"
        },
        onFinish = function()
        --Code here
    end, onCancel = function()
        --Code here
    end
    })
```

* Scenario
  
```lua
    ESX.Progressbar("Unlocking Storage", 3000,{
        FreezePlayer = true, 
        animation ={
            type = "Scenario",
            Scenario = "PROP_HUMAN_BUM_BIN", 
        },
        onFinish = function()
        --Code here
    end, onCancel = function()
        --Code here
    end
    })
```

## Legal

esx_progressbar

Copyright (C) 2022-2024 ESX-Framework

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see <http://www.gnu.org/licenses/>.