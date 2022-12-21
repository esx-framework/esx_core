INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Mechanic', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Mechanic', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_mechanic', 'Mechanic', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Mechanic')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Recruit',12,'{}','{}'),
	('mechanic',1,'novice','Novice',24,'{}','{}'),
	('mechanic',2,'experimente','Experienced',36,'{}','{}'),
	('mechanic',3,'chief','Leader',48,'{}','{}'),
	('mechanic',4,'boss','Boss',0,'{}','{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Gas Bottle', 2),
	('fixtool', 'Repair Tools', 2),
	('carotool', 'Tools', 2),
	('blowpipe', 'Blowtorch', 2),
	('fixkit', 'Repair Kit', 3),
	('carokit', 'Body Kit', 3)
;
