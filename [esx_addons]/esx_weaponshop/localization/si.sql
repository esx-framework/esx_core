

CREATE TABLE `weashops` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`zone` varchar(255) NOT NULL,
	`item` varchar(255) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `licenses` (`type`, `label`) VALUES
	('weapon', "Licenca za Orozje")
;

INSERT INTO `weashops` (`zone`, `item`, `price`) VALUES
	('GunShop','WEAPON_PISTOL', 300),
	('BlackWeashop','WEAPON_PISTOL', 500),
	('GunShop', 'WEAPON_FLASHLIGHT', 60),
	('BlackWeashop', 'WEAPON_FLASHLIGHT', 70),
	('GunShop', 'WEAPON_MACHETE', 90),
	('BlackWeashop', 'WEAPON_MACHETE', 110),
	('GunShop', 'WEAPON_NIGHTSTICK', 150),
	('BlackWeashop', 'WEAPON_NIGHTSTICK', 150),
	('GunShop', 'WEAPON_BAT', 100),
	('BlackWeashop', 'WEAPON_BAT', 100),
	('GunShop', 'WEAPON_STUNGUN', 50),
	('BlackWeashop', 'WEAPON_STUNGUN', 50),
	('GunShop', 'WEAPON_MICROSMG', 1400),
	('BlackWeashop', 'WEAPON_MICROSMG', 1700),
	('GunShop', 'WEAPON_PUMPSHOTGUN', 3400),
	('BlackWeashop', 'WEAPON_PUMPSHOTGUN', 3500),
	('GunShop', 'WEAPON_ASSAULTRIFLE', 10000),
	('BlackWeashop', 'WEAPON_ASSAULTRIFLE', 11000),
	('GunShop', 'WEAPON_SPECIALCARBINE', 15000),
	('BlackWeashop', 'WEAPON_SPECIALCARBINE', 16500),
	('GunShop', 'WEAPON_SNIPERRIFLE', 22000),
	('BlackWeashop', 'WEAPON_SNIPERRIFLE', 24000),
	('GunShop', 'WEAPON_FIREWORK', 18000),
	('BlackWeashop', 'WEAPON_FIREWORK', 20000),
	('GunShop', 'WEAPON_GRENADE', 500),
	('BlackWeashop', 'WEAPON_GRENADE', 650),
	('GunShop', 'WEAPON_BZGAS', 200),
	('BlackWeashop', 'WEAPON_BZGAS', 350),
	('GunShop', 'WEAPON_FIREEXTINGUISHER', 100),
	('BlackWeashop', 'WEAPON_FIREEXTINGUISHER', 100),
	('GunShop', 'WEAPON_BALL', 50),
	('BlackWeashop', 'WEAPON_BALL', 50),
	('GunShop', 'WEAPON_SMOKEGRENADE', 100),
	('BlackWeashop', 'WEAPON_SMOKEGRENADE', 100),
	('BlackWeashop', 'WEAPON_APPISTOL', 1100),
	('BlackWeashop', 'WEAPON_CARBINERIFLE', 12000),
	('BlackWeashop', 'WEAPON_HEAVYSNIPER', 30000),
	('BlackWeashop', 'WEAPON_MINIGUN', 45000),
	('BlackWeashop', 'WEAPON_RAILGUN', 50000),
	('BlackWeashop', 'WEAPON_STICKYBOMB', 500)
;
