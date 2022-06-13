Config = {}
Config.Locale           = 'en'

Config.Blips = {
    Parking = {
        Sprite              = 357,
        Scale               = 1.0,
        Colour              = 3,
    },
    Pound = {
        Sprite              = 794,
        Scale               = 1.0,
        Colour              = 1,
    },
}

Config.DrawDistance     = 10.0

Config.Markers = {
    EntryPoint = {
        Type            = 1,
        Size = {
            x           = 2.0,
            y           = 2.0,
            z           = 1.0
        },
        Color = {
            r           = 0,
            g           = 153,
            b           = 51,
        }
    },
    StorePoint = {
        Type            = 1,
        Size = {
            x           = 2.0,
            y           = 2.0,
            z           = 1.0
        },
        Color = {
            r           = 153,
            g           = 51,
            b           = 51,
        }
    },
    GetOutPoint = {
        Type            = 1,
        Size = {
            x           = 2.0,
            y           = 2.0,
            z           = 1.0
        },
        Color = {
            r           = 54,
            g           = 51,
            b           = 255,
        }
    },
}

Config.Garages = {
    VespucciBoulevard = {
        EntryPoint = {
            x           = -285.2, 
            y           = -886.5, 
            z           = 30.0
        },
        StorePoint = {
            x           = -298.8,
            y           = -901.0, 
            z           = 30.0
        },
        SpawnPoint = {
            x           = -309.3, 
            y           = -897.0, 
            z           = 31.0, 
            heading     = 351.8
        },
        ImpoundedName = 'LosSantos',
    },
    SanAndreasAvenue = {
        EntryPoint = {
            x           = 216.4, 
            y           = -786.6,
            z           = 29.8,
        },
        StorePoint = {
            x           = 231.9,
            y           = -792.9, 
            z           = 29.5
        },
        SpawnPoint = {
            x           = 218.9,
            y           = -779.7,
            z           = 30.8,
            heading     = 338.8
        },
        ImpoundedName = 'LosSantos',
    },
}

Config.Pounds = {
    LosSantos = {
        GetOutPoint = {
            x           = 400.7,
            y           = -1630.5, 
            z           = 28.3
        },
        SpawnPoint = {
            x           = 401.9,
            y           = -1647.4, 
            z           = 29.2, 
            heading     = 323.3
        },
        Cost = 3000
    },
    PaletoBay = {
        GetOutPoint = {
            x           = -211.4,
            y           = 6206.5, 
            z           = 30.4
        },
        SpawnPoint = {
            x           = -204.6,
            y           = 6221.6, 
            z           = 30.5, 
            heading     = 227.2
        },
        Cost = 3000
    },
    SandyShores = {
        GetOutPoint = {
            x           = 1728.2,
            y           = 3709.3,
            z           = 33.2,
        },
        SpawnPoint = {
            x           = 1722.7,
            y           = 3713.6,
            z           = 33.2,
            heading     = 19.9
        },
        Cost = 3000
    },
}