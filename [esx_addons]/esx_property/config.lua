Config = {}

-------- Note: Can Cause quite abit of clutter ---------------
Config.ForSaleBlips = false -- Add Blips to For Sale Properties
Config.OwnedBlips = true -- Add blips for Owned Properties
---------------------------------------------------------------

--------------------- General Settings ---------------------------------
Config.Locale = 'en'
Config.Shells = false -- Enable/Disable Shell Interiors Default: false
Config.CanAlwaysExit = true -- Disabling this allows players to be locked in
Config.OwnerCanAlwaysEnter = true -- Disabling this means the owner can't enter the property unless door is unlocked
Config.MaxNameLength = 20 -- Max Name Length for Owned Properties Default: 20
Config.CanCustomiseInventoryAndWardrobePositions = true -- Allow users to customise inventory and wardrobe positions Default: true
Config.WipeCustomNameOnSell = true -- Wipe custom name on sell Default: true
Config.WipeFurnitureOnSell = true -- Wipe custom name on sell Default: true

--------------------- Raid Settings ---------------------------------
Config.Raiding = {
  Enabled = true, -- Enable/Disable Raiding Default: true
  CanAdminsRaid = true, -- Can Admins Raid Houses Default: true
  ItemRequired = { -- Item Required to Raid -- Remove To Disable
    RemoveItem = true, -- Remove Item from Inventory Default: true
    name = "bread", -- Item Name Default: "bread"
    label = "Bread", -- Item label Default: "Bread"
    ItemCount = 1,   -- Item Count Default: 1
  },
  Animation = {
    type = "Scenario",
    Scenario = "WORLD_HUMAN_HAMMERING",
  },
}

--------------------- Garage Settings ---------------------------------
Config.Garage = {
  Enabled = true, -- Enable/Disable Garage Default: true
  OwnedVehiclesOnly = true, -- Only allow owned vehicles to be stored Default: true
  MySQLquery = "UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?" -- MySQL Query to store vehicles `?` = True/false, Vehicle Plate
}

--------------------- Log Settings ---------------------------------
if IsDuplicityVersion() then 
  Config.Logs = {
    Webhook = "",
    LogLevel = 1

    ----------- Log Levels ------------
    -- 0 = No Logs
    -- 1 = Logs Major Actions
    -- 2 = Logs Major + Minor Actions
    -- 3 = Logs All Actions
    -------------------------------------
  }
end
--------------------- Furniture Settings ---------------------------------
Config.Furniture = {
  Enabled = true,
  RotationSpeed = 0.4, -- Object Rotation Speed
  MovementSpeed = 0.01, -- Object Movement Speed
  MovementZspeed = 0.05, -- Object Z Movement Speed
  WipeFurnitureOnSell = true, -- Wipe Furniture On Sell Default: true
  Controls = {
    PlusX = 174, -- lEFT Arrow
    MinusX = 175, -- RIGHT Arrow
    RotateRight = 19, -- Alt,
    RotateLeft = 21, -- Shift,
    Up = 96, -- UP Arrow
    Down = 97, -- DOWN Arrow
    Confirm = 201, -- ENTER
    Exit = 194, -- BACKSPACE
    PlusY = 172, -- SHIFT
    MinusY = 173, -- SHIFT
  }
}

--------------------- CCTV Settings ---------------------------------
Config.CCTV = {
  Enabled = true,
  PictureWebook = IsDuplicityVersion() and "" or "DO NOT CHANGE THIS STRING", -- Set a discord webhook here to enable taking pictures of the CCTV (link is copied to user`s clipboard)
  HeightAboveDoor = 2.5, -- Height above the door to place the cctv camera
  FOV = 80.0, -- Camera Field of View
  MaxLeftRotation = 80,
  MaxZoom = 30, 
  MinZoom = 100,
  MaxRightRotation = -50,
  MaxUpRotation = 10,
  MaxDownRotation = -45,
  RotateSpeed = 0.3, -- Camera Rotation Speed
  Controls = {
    Left = 34, -- lEFT Arrow
    Right = 35, -- RIGHT Arrow
    Screenshot = 201, -- ENTER
    NightVision = 38, -- E
    ZoomIn = 96, -- UP Arrow
    ZoomOut = 97, -- DOWN Arrow
    Up = 32, -- UP Arrow
    Down = 33, -- DOWN Arrow
    Exit = 194, -- BACKSPACE
  }
}


-------- Groups allowed to use Admin Functions -------------------
Config.AllowedGroups = {
  -- Note: Superadmin is not a group In ESX
  "admin"
}

------------------Interacting With Wardrobe Markers ------------------------------
Config.WardrobeInteraction = function(PropertyId, Interaction)
  ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
    local elements = {{unselectable = true, icon = "fas fa-tshirt", title = "Wardrobe"}}

    for i=1, #dressing, 1 do
        elements[#elements + 1] = {
            title = dressing[i],
            value = i
        }
    end
    
    ESX.OpenContext("left", elements, function(menu, element)
        TriggerEvent('skinchanger:getSkin', function(skin)
            ESX.TriggerServerCallback('esx_property:getPlayerOutfit', function(clothes)
                TriggerEvent('skinchanger:loadClothes', skin, clothes)
                TriggerEvent('esx_skin:setLastSkin', skin)

                TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerServerEvent('esx_skin:save', skin)
                end)
            end, element.value)
        end)
    end)
end)
end

--------------------- Real Estate Settings ----------
Config.PlayerManagement = {                          
  Enabled = false, -- Enable/Disable Player Management Default: true
  job = "realestateagent", -- Job Required to Manage Players Default: "realestateagent"                 
  joblabel = "Estate Agent", -- Job Label Default: "Estate Agent"          
  society = "society_realestateagent", -- Society Required to Manage Players Default: "society_realestateagent"
  SalePercentage = 0.25, -- Sale Percentage Default: 0.25 -- Note: This is a percentage of the price of the house
  jobRanks = {
    {
      grade = 0,
      name = "trainee",
      label = "Trainee",
      salary = 15,
    },
    {
      grade = 1,
      name = "agent",
      label = "Experienced Agent",
      salary = 30,
    },
    {
      grade = 2,
      name = "boss",
      label = "Chief Agent",
      salary = 45,
    },
  },
  Permissions = { -- Minimum Grade Required for Action
    CreateProperty = 0, -- Create Property
    DeleteProperty = 2, -- Delete Property
    ViewProperties = 0, -- View All Properties
    SellProperty = 0, -- Sell Property to players
    ToggleCCTV = 1, -- Change CCTV settings
    ToggleLock = 0, -- Change Lock Settings
    ToggleGarage = 1, -- Change Garage Settings
    SetPropertyName =1, -- Change Property Name
    RemovePropertyName = 1, -- Remove Property Name
    SetPropertyPrice = 0, -- Change Property Price
    ChangeInterior = 1, -- Change Interior
    ResetFurniture = 0, -- Reset Furniture
    EvictOwner = 0,   -- Evict Owners
    ChangeEntrance = 0,  -- Change Entrance
    EditInteriorPositions = 1,  -- Edit Interior Positions
    ManagePropertiesFromQuickActions = 1, -- Manage Properties From Quick Actions (F6)
  },
  Locations = {
    Entrance = vector3( -199.151, -575.000,  39.489 ), -- Entrance Location Default: vector3( -199.151, -575.000,  39.489 )
    Exit = vector3( -141.226, -614.166,  167.820 ), -- Exit Location (Interior Location) Default: vector3( -141.226, -614.166,  167.820 )
    Properties = vector3(-138.9228, -634.1255, 167.8504), -- Property Management Menu Default: vector3(-138.9228, -634.1255, 167.8504)
  }
}        

----------------------Long Lists----------------------------------------
Config.FurnitureStores = {
  {
    title = "Ikea",
    Catagories = {"Decorations", "Tables", "Sofas", "Bedroom"}
  },
  {
    title = "Electronics Store",
    Catagories = {"Electronics","Kitchen"}
  },
}

Config.Interiors = {
  IPL = {
    {
      label = "Modern Apartment",
      value = "apa_v_mp_h_01_a",
      positions = {
        Wardrobe = vec3(-797.72, 328.03, 220.42),
        Storage = vec3(-795.67, 326.67, 217.037), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-786.8663, 315.7642, 217.6385)
    },
    {
      label = "Mody Apartment",
      value = "apa_v_mp_h_02_a",
      positions = {
        Wardrobe = vec3(-797.591187, 327.995605, 220.424194),
        Storage = vec3(-795.441772, 326.307678, 217.037354), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-787.0749, 315.8198, 217.6386)
    },
    {
      label = "Vibrant Apartment",
      value = "apa_v_mp_h_03_a",
      positions = {
        Wardrobe = vec3(-798.131897, 328.417572, 220.424194),
        Storage = vec3(-796.786804, 327.164825, 217.037354),-- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-786.6245, 315.6175, 217.6385)
    },
    {
      label = "Regal Apartment",
      value = "	apa_v_mp_h_07_c",
      positions = {
        Wardrobe = vector3(-797.6594, 328.4619, 190.5122),
        Storage = vector3(-796.0188, 326.7346, 187.3131), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-787.0574, 315.6567, 187.9135)
    },
    {
      label = "Tinsel Towers",
      value = "tinsel_towers",
      positions = {
        Wardrobe = vector3(-594.5938, 55.6803, 96.9996),
        Storage = vector3(-622.8556, 54.7504, 97.5995), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-603.7109, 59.0251, 98.2002)
    },
    {
      label = "Dell Perro Heights",
      value = "dell_perro_heights",
      positions = {
        Wardrobe = vector3(-1467.2574, -536.9599, 50.7325),
        Storage = vector3(-1457.0121, -531.0082, 56.9373), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-1449.7212, -526.1263, 56.9290)
    },
    {
      label = "Mid-Tier Apartment",
      value = "mid-end",
      positions = {
        Wardrobe = vector3(350.7425, -994.2987, -99.1472),
        Storage = vector3(343.8686, -1001.1404, -99.1962), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(346.5085, -1012.7023, -99.1962)
    },
    {
      label = "Low-End Apartment",
      value = "low-end",
      positions = {
        Wardrobe = vector3(259.9943, -1003.4595, -99.0086),
        Storage = vector3(265.9162, -999.3954, -99.0086), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(266.0285, -1007.4129, -101.0086)
    },
    {
      label = "High-End House 1",
      value = "wild_oats",
      positions = {
        Wardrobe = vector3(-167.4227, 487.7173, 133.0),
        Storage = vector3(-174.4463, 492.5583, 130.0436), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(-174.3548, 497.7895, 137.6538)
    },
    {
      label = "Clubhouse",
      value = "bkr_biker_interior_placement_interior_0_biker_dlc_int_01_milo",
      positions = {
        Wardrobe = vector3(1116.9374, -3162.8467, -36.8705),
        Storage = vector3(1112.0820, -3151.4019, -37.5186), -- Only Works with Ox Inventory
      },
      type = "ipl",
      pos = vector3(1121.1871, -3152.6177, -37.0628)
    },
  },
  Shells = {
    {
      label = "Michael House",
      value = "shell_michael",
      positions = {
        Wardrobe = vector3(-12.71,8.36,-5.8), -- Wardrobe Location
        Storage = vector3(-177.77,-2.05,-1.44), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(9.290245, -5.563965, 5.053642)
    },
    {
      label = "Standard Motel",
      value = "standardmotel_shell",
      positions = {
        Wardrobe = vector3(-1.435, -4.74, -1.0),
        Storage = vector3(2.45, -4.37, -1.0), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(0.054924, 2.459473, 1.546776)
    },
    {
      label = "Mid-Tier apartment",
      value = "furnitured_midapart",
      positions = {
        Wardrobe = vector3(-4.5, -18.99, -1.2),
        Storage = vector3(-5.1, -13.68, -1.2), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(-1.434044, 9.802368, 1.511887)
    },
    {
      label = "Trever`s Trailer",
      value = "shell_trevor",
      positions = {
        Wardrobe = vector3(-0.58, -4.85, -1.0),
        Storage = vector3(3.02, -1.467, -1.0), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(-0.156189, 3.585266, 1.398056)
    },
    {
      label = "Trailer",
      value = "shell_trailer",
      positions = {
        Wardrobe = vector3(3.8, -2.92, -1.0),
        Storage = vector3(-5.69, -0.57, -1.12), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(1.282555, 1.713379, 1.469521)
    },
    {
      label = "Low-End Apartment",
      value = "shell_v16low",
      positions = {
        Wardrobe = vector3(7.31, -6.71, -3.0),
        Storage = vector3(0.61, -8.30, -3.0), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(-4.798767, 6.197479, 2.644226)
    },
    {
      label = "Store",
      value = "shell_store1",
      positions = {
        Storage = vector3(0.03, -8.4, -1.1), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(2.666809, 4.603638, 1.609573)
    },
    {
      label = "Ranch",
      value = "shell_ranch",
      positions = {
        Wardrobe = vector3(-2.78, -10.76, -1.0),
        Storage = vector3(3.1, 8.04, -1.0), -- Only Works with Ox Inventory
      },
      type = "shell",
      pos = vector3(0.873413, -5.749237, 2.416748)
    },
  }
}

Config.FurnitureCatagories = 
{Decorations = {{name = "apa_mp_h_acc_bottle_01", title = "Bottle", price = 700},
                {name = "apa_mp_h_acc_candles_01", title = "Candles", price = 700},
                {name = "p_int_jewel_mirror", title = "Mirror", price = 700},
                {name = "apa_mp_h_acc_dec_plate_01", title = "Decorative Plate", price = 700},
                {name = "apa_mp_h_acc_vase_01", title = "Vase", price = 700},
                {name = "v_res_desktidy", title = "Desk Supplies", price = 700},
                {name = "ex_prop_ashtray_luxe_02", title = "Ashtray", price = 700},
                {name = "v_res_mp_ashtrayb", title = "Ashtray 2", price = 300},
                {name = "prop_bong_01", title = "Bong", price = 700},
                {name = "prop_mr_rasberryclean", title = "Mr Rasberry Clean", price = 700},
                {name = "prop_acc_guitar_01", title = "Guitar", price = 1000},
                {name = "p_planning_board_04", title = "Planning Board", price = 500},
                {name = "prop_hotel_clock_01", title = "Hotel Clock", price = 500},
                {name = "p_cs_pamphlet_01_s", title = "Pamphlet", price = 700},
                {name = "prop_big_clock_01", title = "Big Clock", price = 500},
                {name = "prop_egg_clock_01", title = "Egg Clock", price = 500},
                {name = "prop_ld_greenscreen_01", title = "Green Screen", price = 100},
                {name = "prop_dart_bd_cab_01", title = "Dart", price = 500},
                {name = "prop_dart_bd_01", title = "Dart 2", price = 500},
                {name = "prop_exercisebike", title = "Exercise Bike", price = 500},
                {name = "p_laz_j02_s", title = "Laz", price = 500},
                {name = "v_res_cherubvase", title = "White Vase", price = 500},
                {name = "v_res_d_paddedwall", title = "Padded Wall", price = 500},
                {name = "prop_dummy_01", title = "Dummy", price = 100},
                {name = "prop_el_guitar_01", title = "E Guitar 1", price = 100},
                {name = "prop_el_guitar_02", title = "E Guitar 2", price = 100},
                {name = "prop_el_guitar_03", title = "E Guitar 2", price = 100},
                {name = "prop_ld_greenscreen_01", title = "Green Screen", price = 100},
                {name = "v_res_mbowlornate", title = "Ornate Bowl", price = 300},
                {name = "v_res_mbronzvase", title = "Bronze Vase", price = 300},
                {name = "prop_ceramic_jug_01", title = "Ceramic Jug", price = 100},
                {name = "v_res_m_candle", title = "Candle Large 1", price = 300},
                {name = "v_res_m_candlelrg", title = "Candle Large 2", price = 300},
                {name = "apa_mp_h_acc_candles_06", title = "Candles 1", price = 50},
                {name = "apa_mp_h_acc_candles_05", title = "Candles 2", price = 50},
                {name = "apa_mp_h_acc_candles_04", title = "Candles 3", price = 50},
                {name = "apa_mp_h_acc_rugwools_01", title = "Rug 1", price = 300},
                {name = "apa_mp_h_acc_rugwoolm_01", title = "Rug 2", price = 300},
                {name = "apa_mp_h_acc_rugwooll_04", title = "Rug 3", price = 300},
                {name = "apa_mp_h_acc_rugwooll_03", title = "Rug 4", price = 300},
                {name = "apa_mp_h_acc_rugwoolm_04", title = "Rug 5", price = 300},
                {name = "apa_mp_h_acc_rugwools_03", title = "Rug 6", price = 300},
                {name = "v_res_fh_pouf", title = "Pouf", price = 300},
                {name = "v_res_fh_sculptmod", title = "Sculpture", price = 300},
                {name = "prop_ceramic_jug_01", title = "Ceramic Jug", price = 100},
                {name = "prop_v_5_bclock", title = "Vintage Clock", price = 300},
                {name = "prop_v_15_cars_clock", title = "American Flag Clock", price = 300},
                {name = "prop_sm_19_clock", title = "Modern Clock", price = 300},
                {name = "prop_sports_clock_01", title = "Sports Clock", price = 300},
                {name = "prop_mem_candle_01", title = "Candle 1", price = 300},
                {name = "prop_game_clock_01", title = "Crown Clock", price = 300},
                {name = "prop_game_clock_02", title = "Kronos Clock", price = 300},
                {name = "prop_id2_20_clock", title = "Modern Clock 2", price = 300},
                {name = "ex_office_citymodel_01", title = "CIty name", price = 300},
                {name = "apa_mp_h_acc_dec_head_01", title = "Mask", price = 300},
                {name = "ex_mp_h_acc_vase_06", title = "Vase 1", price = 300},
                {name = "ex_mp_h_acc_vase_02", title = "Red Vase", price = 300},
                {name = "hei_prop_hei_bust_01", title = "Bust", price = 300},
                {name = "prop_arcade_01", title = "Arcade Machine", price = 300},
                {price = 6500, name = 'prop_beer_neon_01', title = 'Neon Sign 1'},
                {price = 6500, name = 'prop_beer_neon_02', title = 'Neon Sign 2'},
                {price = 6500, name = 'prop_beer_neon_03', title = 'Neon Sign 3'},
                {price = 6500, name = 'prop_beer_neon_04', title = 'Neon Sign 3'},
                {price = 6500, name = 'prop_patriotneon', title = 'Neon Sign Patriot'},
                {price = 6500, name = 'prop_barrachneon', title = 'Neon Sign Pussy Beer'}},
 Electronics = {{price = 0, title = 'Lamp', name = 'prop_cd_lamp'},
                {price = 1800, title = 'Shredder', name = 'v_ret_gc_shred'},
                {price = 800, title = 'Antique telephone', name = 'apa_mp_h_acc_phone_01'},
                {price = 14700, title = 'TV wall white-gray with electronics', name = 'apa_mp_h_str_avunitl_04'},
                {price = 6700, title = 'TV wooden wall with television', name = 'apa_mp_h_str_avunitl_01_b'},
                {price = 14300, title = 'Television with yellow speakers', name = 'apa_mp_h_str_avunitm_01'},
                {price = 12000, title = 'TV with white speakers', name = 'apa_mp_h_str_avunitm_03'},
                {price = 12900, title = 'Television with accessories', name = 'apa_mp_h_str_avunits_01'},
                {price = 6900, title = 'TV on a metal table', name = 'apa_mp_h_str_avunits_01'},
                {price = 5500, title = 'Notebook', name = 'bkr_prop_clubhouse_laptop_01a'},
                {price = 4400, title = 'Notebook', name = 'bkr_prop_clubhouse_laptop_01b'},
                {price = 12400, title = 'Money counter', name = 'bkr_prop_money_counter'},
                {price = 700, title = 'Large upright fan', name = 'bkr_prop_weed_fan_floor_01a'},
                {price = 2400, title = 'Tvsmash', name = 'des_tvsmash_start'},
                {price = 2700, title = 'Wall TV', name = 'ex_prop_ex_tv_flat_01'},
                {price = 3500, title = 'Desktop monitor with keyboard', name = 'ex_prop_monitor_01_ex'},
                {price = 4700, title = 'Desktop monitor with keyboard', name = 'ex_prop_trailer_monitor_01'},
                {price = 200, title = 'TV driver', name = 'ex_prop_tv_settop_remote'},
                {price = 2200, title = 'TV box', name = 'ex_prop_tv_settop_box'},
                {price = 1000, title = 'Table fan', name = 'gr_prop_bunker_deskfan_01a'},
                {price = 8400, title = 'Television with speakers and all equipment', name = 'hei_heist_str_avunitl_03'},
                {price = 1700, title = 'telephone landline', name = 'hei_prop_hei_bank_phone_01'},
                {price = 3800, title = 'Alarm', name = 'hei_prop_hei_bio_panel'},
                {price = 2100, title = 'Keyboard', name = 'hei_prop_hei_cs_keyboard'},
                {price = 8900, title = 'Project board', name = 'hei_prop_hei_muster_01'},
                {price = 1800, title = 'WIFI', name = 'hei_prop_server_piece_01'},
                {price = 3300, title = 'White notebook', name = 'p_laptop_02_s'},
                {price = 10500, title = 'Safe', name = 'p_v_43_safe_s'},
                {price = 7900, title = 'Table Hockey', name = 'prop_airhockey_01'},
                {price = 2400, title = 'Portable Radio', name = 'prop_boombox_01'},
                {price = 2500, title = 'DVD player', name = 'prop_cctv_cont_03'},
                {price = 3300, title = 'CD player', name = 'prop_cctv_cont_04'},
                {price = 900, title = 'PC Mouse', name = 'prop_cs_mouse_01'},
                {price = 900, title = 'Wall clock', name = 'prop_game_clock_01'},
                {price = 600, title = 'Wall clock black', name = 'prop_game_clock_02'},
                {price = 3400, title = 'HiFi system', name = 'prop_hifi_01'},
                {price = 1500, title = 'square clock', name = 'prop_hotel_clock_01'},
                {price = 1500, title = 'Clock', name = 'prop_id2_20_clock'},
                {price = 3400, title = 'Nikon Handheld Camera', name = 'prop_ing_camera_01'},
                {price = 1700, title = 'White keyboard', name = 'prop_keyboard_01a'},
                {price = 1600, title = 'Router', name = 'prop_ld_armour'},
                {price = 1700, title = 'Old monitor', name = 'prop_ld_monitor_01'},
                {price = 2300, title = 'Small old monitor', name = 'prop_monitor_01b'},
                {price = 400, title = 'RETRO monitor', name = 'prop_monitor_03b'},
                {price = 5900, title = 'Monitor', name = 'prop_monitor_w_large'},
                {price = 4800, title = 'Repráček', name = 'prop_mp3_dock'},
                {price = 4000, title = 'White PC', name = 'prop_pc_01a'},
                {price = 4800, title = 'Black PC', name = 'prop_pc_02a'},
                {price = 2500, title = 'Mobile', name = 'prop_phone_ing'},
                {price = 2100, title = 'Mobile', name = 'prop_phone_ing_02'},
                {price = 2000, title = 'Mobile', name = 'prop_phone_ing_02_lod'},
                {price = 2300, title = 'Mobile', name = 'prop_phone_ing_03'},
                {price = 1000, title = 'RETRO radio', name = 'prop_radio_01'},
                {price = 1100, title = 'Small speaker', name = 'prop_speaker_05'},
                {price = 1000, title = 'Speaker', name = 'prop_speaker_06'},
                {price = 1900, title = 'Speaker', name = 'prop_speaker_08'},
                {price = 2000, title = 'Old TV', name = 'prop_trev_tv_01'},
                {price = 500, title = 'Old TV', name = 'prop_tv_03'},
                {price = 300, title = 'Old TV', name = 'prop_tv_01'},
                {price = 400, title = 'RETRO TV', name = 'prop_tv_04'},
                {price = 1700, title = 'Old TV', name = 'prop_tv_06'},
                {price = 6500, title = 'Plasma big screen', name = 'prop_tv_flat_01'},
                {price = 12500, title = 'Plasma thin TV', name = 'prop_tv_flat_01_screen'},
                {price = 1600, title = 'Plasma small television', name = 'prop_tv_flat_02'},
                {price = 2100, title = 'Plasma small television', name = 'prop_tv_flat_02b'},
                {price = 900, title = 'Small TV with stand', name = 'prop_tv_flat_03'},
                {price = 300, title = 'Small TV on the wall', name = 'prop_tv_flat_03b'},
                {price = 9200, title = 'Television Michael 50cm', name = 'prop_tv_flat_michael'},
                {price = 1000, title = 'Little US Clock', name = 'prop_v_15_cars_clock'},
                {price = 4000, title = 'Professional camera', name = 'prop_v_cam_01'},
                {price = 4700, title = 'VET player RETRO', name = 'prop_vcr_01'},
                {price = 9900, title = 'Mixing desk', name = 'v_club_vu_deckcase'},
                {price = 1500, title = 'RETRO Laptop', name = 'v_ind_ss_laptop'},
                {price = 2500, title = 'CD seda', name = 'v_res_cdstorage'},
                {price = 3300, title = 'Ipod', name = 'v_res_ipoddock'},
                {price = 2800, title = 'Silver Monitor', name = 'v_res_monitorwidelarge'},
                {price = 2400, title = 'Mouse and as a gift pad', name = 'v_res_mousemat'},
                {price = 100, title = 'PC Headphones', name = 'v_res_pcheadset'},
                {price = 1200, title = 'PC speaker', name = 'v_res_pcspeaker'},
                {price = 5000, title = 'VHS white RETRO player', name = 'v_res_vhsplayer'},
                {price = 2200, title = 'Vacuum Cleaner', name = 'v_res_vacuum'},
                {price = 5400, title = 'Shredder', name = 'v_ret_gc_shred'},
                {price = 100, title = 'Stapler', name = 'v_ret_gc_staple'},
                {price = 1900, title = 'Hardisk', name = 'xm_prop_x17_harddisk_01a'},
                {price = 5300, title = 'Computer', name = 'xm_prop_x17_res_pctower'},
                {price = 12900, title = 'Plasma TV', name = 'xm_prop_x17_tv_flat_01'},
                {price = 6600, title = 'Plasma TV', name = 'xm_prop_x17_tv_flat_02'},
                {price = 14000, title = 'Jukebox', name = 'bkr_prop_clubhouse_jukebox_01b'},
                {price = 1700, title = 'USB', name = 'hei_prop_hst_usb_drive'},
                {price = 700, title = 'Flashlight', name = 'p_cs_police_torch_s'},
                {price = 1000, title = 'Mikofon', name = 'p_ing_microphonel_01'},
                {price = 1600, title = 'Radio', name = 'prop_tapeplayer_01'},
                {price = 4500, title = 'Multifunction Laser Printer', name = 'prop_printer_01'},
                {price = 11200, title = 'Multifunction Laser Printer', name = 'prop_printer_02'},
                {price = 20300, title = 'Jukebox 2', name = 'prop_50s_jukebox'},
                {price = 21200, title = 'Arcade games', name = 'prop_arcade_01'},
                {price = 19400, title = 'Safe', name = 'prop_ld_int_safe_01'},
                {price = 3800, title = 'Astronomical Clock', name = 'prop_v_5_bclock'},
                {price = 22200, title = 'Table with three monitors', name = 'xm_prop_base_staff_desk_01'},
                {price = 17900, title = 'Table with three monitors', name = 'xm_prop_base_staff_desk_02'},
                {price = 1500, title = 'Napkin machine', name = 'prop_handdry_01'},
                {price = 2700, title = 'Washing Machine', name = 'prop_washer_02'},
                {price = 600, title = 'Washing machine with its years', name = 'prop_washer_03'},
                {price = 700, title = 'RETRO washing machine', name = 'v_ret_fh_dryer'}},
  Tables = {{price = 5600, title = 'Glass table', name = 'apa_mp_h_din_table_04'},
            {price = 5000, title = 'Glass table', name = 'apa_mp_h_din_table_11'},
            {price = 5300, title = 'Glass table', name = 'apa_mp_h_tab_sidelrg_07'},
            {price = 1200, title = 'Black Round Table', name = 'apa_mp_h_tab_sidelrg_04'},
            {price = 1600, title = 'Glass table', name = 'apa_mp_h_tab_sidelrg_01'},
            {price = 5700, title = 'Decorative glass table', name = 'apa_mp_h_tab_sidelrg_02'},
            {price = 2600, title = 'Black coffee table', name = 'apa_mp_h_yacht_coffee_table_01'},
            {price = 4200, title = 'Square table', name = 'apa_mp_h_yacht_side_table_01'},
            {price = 3400, title = 'Small table', name = 'gr_dlc_gr_yacht_props_table_01'},
            {price = 4700, title = 'Long table', name = 'gr_dlc_gr_yacht_props_table_02'},
            {price = 1000, title = 'Particleboard table', name = 'prop_rub_table_01'},
            {price = 700, title = 'Particleboard dining table', name = 'prop_rub_table_02'},
            {price = 700, title = 'TV table', name = 'prop_tv_cabinet_03'},
            {price = 300, title = 'TV table', name = 'prop_tv_cabinet_04'},
            {price = 800, title = 'TV table', name = 'prop_tv_cabinet_05'},
            {price = 5300, title = 'Black modern table', name = 'v_ilev_liconftable_sml'},
            {price = 4100, title = 'Bar', name = 'xm_prop_lab_desk_01'}},
  Sofas = {{price = 11500, title = 'Couch with pillows', name = 'prop_couch_01'},
           {price = 6500, title = 'Padded bench', name = 'prop_wait_bench_01'},
           {price = 4400, title = 'White leather sofa', name = 'xm_lab_sofa_01'}},
  Kitchen = {{price = 800, title = 'Kitchen scale', name = 'bkr_prop_coke_scale_01'},
             {price = 1000, title = 'Home coffee maker', name = 'prop_coffee_mac_02'},
             {price = 5200, title = 'Automatic juice mixer', name = 'prop_juice_dispenser'},
             {price = 200, title = 'White wall phone', name = 'prop_office_phone_tnt'},
             {price = 2300, title = 'Fruit Blender', name = 'p_kitch_juicer_s'},
             {price = 1500, title = 'Kettle', name = 'prop_kettle_01'},
             {price = 2600, title = 'Crushing machine', name = 'prop_slush_dispenser'},
             {price = 700, title = 'Coffee pot', name = 'xm_prop_x17_coffee_jug'},
             {price = 3700, title = 'Mini bar fridge', name = 'prop_bar_fridge_03'},
             {price = 800, title = 'Plastic red cup', name = 'apa_prop_cs_plastic_cup_01'},
             {price = 1000, title = 'Trash', name = 'prop_bin_10a'},
             {price = 400, title = 'Universal Cleaner', name = 'prop_blox_spray'},
             {price = 200, title = 'Green bucket', name = 'prop_buck_spade_05'},
             {price = 400, title = 'Blue bucket', name = 'prop_buck_spade_06'},
             {price = 200, title = 'Red bucket', name = 'prop_buck_spade_07'},
             {price = 700, title = 'Cups', name = 'prop_food_cups2'},
             {price = 400, title = 'White Cup', name = 'prop_mug_02'},
             {price = 800, title = 'Bowl with donut lid', name = 'v_res_cakedome'},
             {price = 1000, title = 'Loose tea container', name = 'v_res_fa_pottea'},
             {price = 300, title = 'Deep Plate', name = 'v_res_mbowl'},
             {price = 500, title = 'Paper napkins', name = 'v_ret_ta_paproll'},
             {price = 400, title = 'Glasses', name = 'p_w_grass_gls_s'},
             {price = 300, title = 'Glasses', name = 'prop_cocktail'},
             {price = 600, title = 'Knife', name = 'prop_cs_bowie_knife'}},
  Bedroom = {{price = 3300, title = 'Single bed', name = 'v_res_msonbed'},
             {price = 100, title = 'Double bed', name = 'p_lestersbed_s'},
             {price = 600, title = 'Double bed', name = 'p_v_res_tt_bed_s'},
             {price = 400, title = 'Double modern bed', name = 'apa_mp_h_bed_double_08'},
             {price = 1100, title = 'Double modern bed', name = 'apa_mp_h_bed_wide_05'},
             {price = 2200, title = 'Double modern bed', name = 'apa_mp_h_yacht_bed_02'},
             {price = 700, title = 'Single sofa bed', name = 'ex_prop_exec_bed_01'},
             {price = 3100, title = 'Double modern bed', name = 'hei_heist_bed_double_08'},
             {price = 4400, title = 'Chest of drawers', name = 'apa_mp_h_bed_chestdrawer_02'},
             {price = 400, title = 'RETRO wardrobe', name = 'apa_mp_h_str_shelffloorm_02'},
             {price = 100, title = 'RETRO chest of drawers low', name = 'apa_mp_h_str_sideboardl_11'},
             {price = 2500, title = 'Gray-white low cabinet', name = 'apa_mp_h_str_sideboardl_13'},
             {price = 700, title = 'Wooden chest of drawers', name = 'apa_mp_h_str_sideboardl_14'},
             {price = 500, title = 'Wood brindle feather duster', name = 'apa_mp_h_str_sideboardm_02'},
             {price = 900, title = 'Iron open cabinet', name = 'p_cs_locker_01'},
             {price = 300, title = 'Iron used closed cabinet', name = 'p_cs_locker_01_s'}}}



-------------------DONT TOUCH -------------------------
Config.OxInventory = ESX.GetConfig().OxInventory     --
                                                     --
function GetInteriorValues(Interior)                 --
  for _,type in pairs(Config.Interiors) do           --
    for _, interior in pairs(type) do                --
      if interior.value == Interior then             --
        return interior                              --  
      end                                            --
    end                                              --
  end                                                --
end                                                  --
--------------------------------------------------------


--[[
      ESX Property - Properties Made Right!
    Copyright (C) 2022 ESX-Framework

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]] 