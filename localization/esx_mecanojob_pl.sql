USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mecano', 'Mechanik', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mecano', 'Mechanik', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mecano', 'Mechanik')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mecano',0,'recrue','Praktykant',12,'{}','{}'),
	('mecano',1,'novice','Nowicjusz',24,'{}','{}'),
	('mecano',2,'experimente','Doświadczony',36,'{}','{}'),
	('mecano',3,'chief','Kierownik',48,'{}','{}'),
	('mecano',4,'boss','Szef',0,'{}','{}')
;

INSERT INTO `items` (name, label, `limit`) VALUES
	('gazbottle', 'Butelka z gazem', 11),
	('fixtool', 'Zestaw do naprawy', 6),
	('carotool', 'Częsci naprawcze', 4),
	('blowpipe', 'Palnik', 10),
	('fixkit', 'Narzedzia naprawcze', 5),
	('carokit', 'Części blacharskie', 3)
;
