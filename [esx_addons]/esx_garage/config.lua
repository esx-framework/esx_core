Config = {}
Config.Locale = "en"

Config.DrawDistance = 10.0

Config.Markers = {
	EntryPoint = {
		Type = 21,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 50,
			g = 200,
			b = 50,
		},
	},
	GetOutPoint = {
		Type = 21,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 200,
			g = 51,
			b = 51,
		},
	},
}

Config.Garages = {
	VespucciBoulevard = {
		EntryPoint = {
			x = -285.2,
			y = -886.5,
			z = 31.0,
		},
		SpawnPoint = {
			x = -309.3,
			y = -897.0,
			z = 31.0,
			heading = 351.8,
		},
		Sprite = 357,
		Scale = 0.8,
		Colour = 3,
		ImpoundedName = "LosSantos",
	},
	SanAndreasAvenue = {
		EntryPoint = {
			x = 216.4,
			y = -786.6,
			z = 30.8,
		},
		SpawnPoint = {
			x = 218.9,
			y = -779.7,
			z = 30.8,
			heading = 338.8,
		},
		Sprite = 357,
		Scale = 0.8,
		Colour = 3,
		ImpoundedName = "LosSantos",
	},
}

Config.Impounds = {
	LosSantos = {
		GetOutPoint = {
			x = 400.7,
			y = -1630.5,
			z = 29.3,
		},
		SpawnPoint = {
			x = 401.9,
			y = -1647.4,
			z = 29.2,
			heading = 323.3,
		},
		Sprite = 524,
		Scale = 0.8,
		Colour = 1,
		Cost = 3000,
	},
	PaletoBay = {
		GetOutPoint = {
			x = -211.4,
			y = 6206.5,
			z = 31.4,
		},
		SpawnPoint = {
			x = -204.6,
			y = 6221.6,
			z = 30.5,
			heading = 227.2,
		},
		Sprite = 524,
		Scale = 0.8,
		Colour = 1,
		Cost = 3000,
	},
	SandyShores = {
		GetOutPoint = {
			x = 1728.2,
			y = 3709.3,
			z = 33.2,
		},
		SpawnPoint = {
			x = 1722.7,
			y = 3713.6,
			z = 33.2,
			heading = 19.9,
		},
		Sprite = 524,
		Scale = 0.8,
		Colour = 1,
		Cost = 3000,
	},
}

exports("getGarages", function()
	return Config.Garages
end)
exports("getImpounds", function()
	return Config.Impounds
end)
