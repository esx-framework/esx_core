

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Mehanik', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Mehanik', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_mechanic', 'Mehanik', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Mehanik')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Rekrut',12,'{}','{}'),
	('mechanic',1,'novice','Novinec',24,'{}','{}'),
	('mechanic',2,'experimente','Izkušen',36,'{}','{}'),
	('mechanic',3,'chief','PodDirektor',48,'{}','{}'),
	('mechanic',4,'boss','Direktor',0,'{}','{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Gas Bottle', 2),
	('fixtool', 'Orodja za popravilo', 2),
	('carotool', 'Tools', 2),
	('blowpipe', 'Blowtorch', 2),
	('fixkit', 'Popravilo', 3),
	('carokit', 'Body Kit', 3)
;
