USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police','Polizei',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police','Polizei',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Polizei', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Polizei')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Rekrut',20,'{}','{}'),
	('police',1,'officer','Officier',40,'{}','{}'),
	('police',2,'sergeant','Sergent',60,'{}','{}'),
	('police',3,'lieutenant','Lieutenant',85,'{}','{}'),
	('police',4,'boss','Commandant',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` VALUES ('1', 'Missbrauchen der Hupe', '30', '0');
INSERT INTO `fine_types` VALUES ('2', 'Vorfahrtstraße missachtet', '40', '0');
INSERT INTO `fine_types` VALUES ('3', 'Gegenverkehr', '250', '0');
INSERT INTO `fine_types` VALUES ('4', 'Unbefugtes Wenden', '250', '0');
INSERT INTO `fine_types` VALUES ('5', 'Off-Road fahren', '170', '0');
INSERT INTO `fine_types` VALUES ('6', 'Sicherheitsrichtlinien missachtet', '30', '0');
INSERT INTO `fine_types` VALUES ('7', 'Gefährliches halten', '150', '0');
INSERT INTO `fine_types` VALUES ('8', 'Nicht erlaubtes parken', '70', '0');
INSERT INTO `fine_types` VALUES ('9', 'Nicht respektieren des Rechtsfahrgebotes', '70', '0');
INSERT INTO `fine_types` VALUES ('10', 'Nicht einhaltender Priorität eines Rettungsfahrzeuges', '90', '0');
INSERT INTO `fine_types` VALUES ('11', 'Nicht angehalten nach Aufforderung', '105', '0');
INSERT INTO `fine_types` VALUES ('12', 'Bei Rot über die Ampel', '130', '0');
INSERT INTO `fine_types` VALUES ('13', 'gefährliches Überholmanöver', '100', '0');
INSERT INTO `fine_types` VALUES ('14', 'Fahrzeug nicht Verkehrstauglich', '100', '0');
INSERT INTO `fine_types` VALUES ('15', 'Fahren ohne Lizenz', '1500', '0');
INSERT INTO `fine_types` VALUES ('16', 'Hit and Run', '800', '0');
INSERT INTO `fine_types` VALUES ('17', 'zu schnell < 5 kmh', '90', '0');
INSERT INTO `fine_types` VALUES ('18', 'zu schnell 5-15 kmh', '120', '0');
INSERT INTO `fine_types` VALUES ('19', 'zu schnell 15-30 kmh', '180', '0');
INSERT INTO `fine_types` VALUES ('20', 'zu schnell > 30 kmh', '300', '0');
INSERT INTO `fine_types` VALUES ('21', 'Verkehrsbehinderung', '110', '1');
INSERT INTO `fine_types` VALUES ('22', 'Nicht Benutzung öffentlicher Straßen', '90', '1');
INSERT INTO `fine_types` VALUES ('23', 'Störung der öffentlichen Ordnung', '90', '1');
INSERT INTO `fine_types` VALUES ('24', 'Polizeieinsatz behindern', '130', '1');
INSERT INTO `fine_types` VALUES ('25', 'Beildigung an Zivilist', '75', '1');
INSERT INTO `fine_types` VALUES ('26', 'Polizist geringschätzen', '110', '1');
INSERT INTO `fine_types` VALUES ('27', 'verbale Bedrohung an Zivilist', '90', '1');
INSERT INTO `fine_types` VALUES ('28', 'verbale Bedrohung an Polizist', '150', '1');
INSERT INTO `fine_types` VALUES ('29', 'Illegale Demonstration', '250', '1');
INSERT INTO `fine_types` VALUES ('30', 'versuchte Bestechung', '1500', '1');
INSERT INTO `fine_types` VALUES ('31', 'Mit Messer in der Stadt bewaffnet', '120', '2');
INSERT INTO `fine_types` VALUES ('32', 'Mit tötlicher Waffe bewaffnet', '300', '2');
INSERT INTO `fine_types` VALUES ('33', 'Unbefugter Besitz einer Waffe (Standard-Lizenz)', '600', '2');
INSERT INTO `fine_types` VALUES ('34', 'Illegale Waffe', '700', '2');
INSERT INTO `fine_types` VALUES ('35', 'Einbruch/Aufbruch', '300', '2');
INSERT INTO `fine_types` VALUES ('36', 'Autodiebstahl', '1800', '2');
INSERT INTO `fine_types` VALUES ('37', 'Drogenverkauf', '1500', '2');
INSERT INTO `fine_types` VALUES ('38', 'Drogen herstellen', '1500', '2');
INSERT INTO `fine_types` VALUES ('39', 'Drogenbesitz', '650', '2');
INSERT INTO `fine_types` VALUES ('40', 'Zivile Geisel genommen', '1500', '2');
INSERT INTO `fine_types` VALUES ('41', 'Geiselnahme', '2000', '2');
INSERT INTO `fine_types` VALUES ('42', 'Waghalsiges Lenken', '650', '2');
INSERT INTO `fine_types` VALUES ('43', 'Ladenraub', '650', '2');
INSERT INTO `fine_types` VALUES ('44', 'Bankraub', '1500', '2');
INSERT INTO `fine_types` VALUES ('45', 'Schießen auf Zivilisten', '2000', '3');
INSERT INTO `fine_types` VALUES ('46', 'Schießen auf Beamten', '2500', '3');
INSERT INTO `fine_types` VALUES ('47', 'versuchterMord an Zivilisten', '3000', '3');
INSERT INTO `fine_types` VALUES ('48', 'versuchter Mord an einem Beamten', '5000', '3');
INSERT INTO `fine_types` VALUES ('49', 'Mord an Zivilisten', '10000', '3');
INSERT INTO `fine_types` VALUES ('50', 'Mord an Beamten', '30000', '3');
INSERT INTO `fine_types` VALUES ('51', 'versehentlicher Mord', '1800', '3');
INSERT INTO `fine_types` VALUES ('52', 'Firmenbetrug', '2000', '2');
;
