

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Szerelő', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Szerelő', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_mechanic', 'Szerelő', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Szerelő')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic', 0, 'recrue', 'Újonc', 12, '{}', '{}'),
	('mechanic', 1, 'novice', 'Kezdő', 24, '{}', '{}'),
	('mechanic', 2, 'experimente', 'Tapasztalt', 36, '{}', '{}'),
	('mechanic', 3, 'chief', 'Vezető', 48, '{}', '{}'),
	('mechanic', 4, 'boss', 'Főnök', 0, '{}' ,'{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Gázpalack', 2),
	('fixtool', 'Javítószerszámok', 2),
	('carotool', 'Szerszámok', 2),
	('blowpipe', 'Fújólámpa', 2),
	('fixkit', 'Javító készlet', 3),
	('carokit', 'Body Kit', 3)
;
