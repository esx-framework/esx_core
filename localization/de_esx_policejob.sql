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
  ('police','LSPD')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('police',0,'recruit','Rekrut',20,'{\"tshirt_1\":57,\"torso_1\":55,\"arms\":0,\"pants_1\":35,\"glasses\":0,\"decals_2\":0,\"hair_color_2\":0,\"helmet_2\":0,\"hair_color_1\":5,\"face\":19,\"glasses_2\":1,\"torso_2\":0,\"shoes\":24,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"pants_2\":0,\"hair_2\":0,\"decals_1\":0,\"tshirt_2\":0,\"helmet_1\":8}','{\"tshirt_1\":34,\"torso_1\":48,\"shoes\":24,\"pants_1\":34,\"torso_2\":0,\"decals_2\":0,\"hair_color_2\":0,\"glasses\":0,\"helmet_2\":0,\"hair_2\":3,\"face\":21,\"decals_1\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"arms\":14,\"hair_color_1\":10,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',1,'sergeant','Sergent',40,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":0,\"decals_1\":8,\"torso_2\":0,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"hair_color_1\":5,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":14,\"pants_1\":34,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"shoes\":24,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"face\":21,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"hair_color_1\":10,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',2,'lieutenant','Lieutenant',65,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":2,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"glasses\":0,\"decals_1\":8,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"torso_2\":0,\"arms\":41,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"hair_2\":3,\"decals_2\":2,\"hair_color_2\":0,\"hair_color_1\":10,\"helmet_2\":0,\"face\":21,\"shoes\":24,\"torso_2\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"decals_1\":7,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',3,'boss','Commandant',80,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":41,\"torso_2\":0,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"decals_1\":8,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":21,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"hair_color_1\":10,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"shoes\":24,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}')
;

CREATE TABLE `fine_types` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,

  PRIMARY KEY (`id`)
);

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
