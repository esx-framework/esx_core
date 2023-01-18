

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Politie', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Politie', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Politie', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Politie')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'aspirant','Aspirant',0,'{}','{}'),
	('police',1,'surveillant','Surveillant',0,'{}','{}'),
	('police',2,'agent','Agent',0,'{}','{}'),
	('police',3,'hoofdagent','Hoofdagent',0,'{}','{}'),
	('police',4,'brigadier','Brigadier',0,'{}','{}'),
  ('police',5,'inspecteur','Inspecteur',0,'{}','{}'),
  ('police',6,'hoofdinspecteur','Hoofdinspecteur',0,'{}','{}'),
  ('police',7,'commissaris','Commissaris',0,'{}','{}'),
  ('police',8,'hoofdcommissaris','Hoofdcommissaris',0,'{}','{}'),
	('police',9,'boss','Eerste Hoofdcommissaris',0,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `fine_types` (label, amount, category) VALUES
	('Onnodig claxoneren', 90, 0),
	('Rijden over een doorgetrokken streep', 240, 0),
	('Tegen het verkeer in rijden', 140, 0),
	('Negeren keerverbod (u-turn)', 140, 0),
	('Niet opvolgen aanwijzing van bevoegd ambtenaar', 110, 0),
	('Fout parkeren', 95, 0),
	('Verkeerd voorsorteren', 240, 0),
	('Rijden met een WOK status ', 300, 0),
	('Door rood rijden', 240, 0),
	('Rijden zonder rijbewijs', 340, 0),
	('Snelheid overtreding < 10km', 112, 0),
	('Snelheid overtreding 10 - 20km', 202, 0),
	('Snelheid overtreding 20 - 50km', 670, 0),
	('Snelheid overtreding > 50km', 1000, 0),
	('Openbare dronkenschap', 415, 1),
	('Wanordelijk gedrag', 500, 1),
	('Hulpdiensten hinderen', 700, 1),
	('Belediging ambtenaar in functie', 200, 1),
	('Bedreiging', 980, 1),
	('Illegaal wapen bezit', 2300, 2),
	('Illegaal drugs bezit', 400, 2),
	('Drugshandel', 3000, 3)
;
