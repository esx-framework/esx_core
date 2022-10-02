INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Monteur', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Monteur', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_mechanic', 'Monteur', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Monteur')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Stagair',12,'{}','{}'),
	('mechanic',1,'novice','Personeel',24,'{}','{}'),
	('mechanic',2,'experimente','Ervaard',36,'{}','{}'),
	('mechanic',3,'chief','Supervisor',48,'{}','{}'),
	('mechanic',4,'boss','Baas',0,'{}','{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Gas Fles', 2),
	('fixtool', 'Repareer set', 2),
	('carotool', 'Tools', 2),
	('blowpipe', 'Las Apparaat', 2),
	('fixkit', 'Repareer set', 3),
	('carokit', 'Body set', 3)
;
