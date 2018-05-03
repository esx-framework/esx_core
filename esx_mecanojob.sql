USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mecano', 'Mécano', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mecano', 'Mécano', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mecano', 'Mécano')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mecano',0,'recrue','Recrue',12,'{}','{}'),
	('mecano',1,'novice','Novice',24,'{}','{}'),
	('mecano',2,'experimente','Experimente',36,'{}','{}'),
	('mecano',3,'chief','Chef d\'équipe',48,'{}','{}'),
	('mecano',4,'boss','Patron',0,'{}','{}')
;

INSERT INTO `items` (name, label, `limit`) VALUES
	('gazbottle', 'bouteille de gaz', 11),
	('fixtool', 'outils réparation', 6),
	('carotool', 'outils carosserie', 4),
	('blowpipe', 'Chalumeaux', 10),
	('fixkit', 'Kit réparation', 5),
	('carokit', 'Kit carosserie', 3)
;
