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
