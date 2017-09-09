INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_police','Police',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_police','Police',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_police', 'Police', 1)
;

INSERT INTO `jobs` (name, label) VALUES 
	('police','LSPD')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Recrue',20,'{\"tshirt_1\":57,\"torso_1\":55,\"arms\":0,\"pants_1\":35,\"glasses\":0,\"decals_2\":0,\"hair_color_2\":0,\"helmet_2\":0,\"hair_color_1\":5,\"face\":19,\"glasses_2\":1,\"torso_2\":0,\"shoes\":24,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"pants_2\":0,\"hair_2\":0,\"decals_1\":0,\"tshirt_2\":0,\"helmet_1\":8}','{\"tshirt_1\":34,\"torso_1\":48,\"shoes\":24,\"pants_1\":34,\"torso_2\":0,\"decals_2\":0,\"hair_color_2\":0,\"glasses\":0,\"helmet_2\":0,\"hair_2\":3,\"face\":21,\"decals_1\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"arms\":14,\"hair_color_1\":10,\"tshirt_2\":0,\"helmet_1\":57}'),
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

INSERT INTO `fine_types` (label, amount, category) VALUES 
	('Usage abusif du klaxon',30,0),
	('Franchir une ligne continue',40,0),
	('Circulation à contresens',250,0),
	('Demi-tour non autorisé',250,0),
	('Circulation hors-route',170,0),
	('Non-respect des distances de sécurité',30,0),
	('Arrêt dangereux / interdit',150,0),
	('Stationnement gênant / interdit',70,0),
	('Non respect  de la priorité à droite',70,0),
	('Non-respect à un véhicule prioritaire',90,0),
	('Non-respect d\'un stop',105,0),
	('Non-respect d\'un feu rouge',130,0),
	('Dépassement dangereux',100,0),
	('Véhicule non en état',100,0),
	('Conduite sans permis',1500,0),
	('Délit de fuite',800,0),
	('Excès de vitesse < 5 kmh',90,0),
	('Excès de vitesse 5-15 kmh',120,0),
	('Excès de vitesse 15-30 kmh',180,0),
	('Excès de vitesse > 30 kmh',300,0),
	('Entrave de la circulation',110,1),
	('Dégradation de la voie publique',90,1),
	('Trouble à l\'ordre publique',90,1),
	('Entrave opération de police',130,1),
	('Insulte envers / entre civils',75,1),
	('Outrage à agent de police',110,1),
	('Menace verbale ou intimidation envers civil',90,1),
	('Menace verbale ou intimidation envers policier',150,1),
	('Manifestation illégale',250,1),
	('Tentative de corruption',1500,1),
	('Arme blanche sortie en ville',120,2),
	('Arme léthale sortie en ville',300,2),
	('Port d\'arme non autorisé (défaut de license)',600,2),
	('Port d\'arme illégal',700,2),
	('Pris en flag lockpick',300,2),
	('Vol de voiture',1800,2),
	('Vente de drogue',1500,2),
	('Fabriquation de drogue',1500,2),
	('Possession de drogue',650,2),
	('Prise d\'ôtage civil',1500,2),
	('Prise d\'ôtage agent de l\'état',2000,2),
	('Braquage particulier',650,2),
	('Braquage magasin',650,2),
	('Braquage de banque',1500,2),
	('Tir sur civil',2000,3),
	('Tir sur agent de l\'état',2500,3),
	('Tentative de meurtre sur civil',3000,3),
	('Tentative de meurtre sur agent de l\'état',5000,3),
	('Meurtre sur civil',10000,3),
	('Meurte sur agent de l\'état',30000,3),
	('Meurtre involontaire',1800,3),
	('Escroquerie à l\'entreprise',2000,2)
;
