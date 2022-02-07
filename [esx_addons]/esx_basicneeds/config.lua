Config = {}
Config.Locale = 'en'
Config.Visible = true

Config.food = {
     ["bread"] = {type = "hunger", value= 87714, action = "onEat", notif = _U("used_bread")},    -- Food
     ["water"] = {type = "thirst", value = 69478, action = "onDrink", notif = _U("used_water")}, -- Drink
}
