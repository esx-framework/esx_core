USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Mekaniker', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Mekaniker', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Mekaniker')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Rekryt',12,'{}','{}'),
	('mechanic',1,'novice','Nyanställd',24,'{}','{}'),
	('mechanic',2,'experimente','Erfaren',36,'{}','{}'),
	('mechanic',3,'chief','Chef',48,'{}','{}'),
	('mechanic',4,'boss','Ägare',0,'{}','{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Gas Flaska', 2),
	('fixtool', 'Reparationsverktyg', 2),
	('carotool', 'Verktyg', 2),
	('blowpipe', 'Blåslampa', 2),
	('fixkit', 'Reparationssats', 3),
	('carokit', 'Karosskit', 3)
;
