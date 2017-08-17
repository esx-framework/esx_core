USE `essentialmode`;

CREATE TABLE `weashops` (
  
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `item` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  
  PRIMARY KEY (`id`)
);

INSERT INTO `weashops` (name, item, price, label) VALUES
	('GunShop','WEAPON_Pistol',300, 'pistol'),
	('blackweashop','WEAPON_Pistol',500, 'pistol')
;