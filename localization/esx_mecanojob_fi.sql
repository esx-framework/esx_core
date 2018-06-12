USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mecano', 'Mekaanikko', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mecano', 'Mekaanikko', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mecano', 'Mekaanikko')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mecano',0,'recrue','Harjottelija',12,'{}','{}'),
	('mecano',1,'novice','Aloittelija',24,'{}','{}'),
	('mecano',2,'experimente','Kokenut',36,'{}','{}'),
	('mecano',3,'chief','Johtaja',48,'{}','{}'),
	('mecano',4,'boss','Pomo',0,'{}','{}')
;

INSERT INTO `items` (name, label, `limit`) VALUES
	('gazbottle', 'Kaasupullo', 11),
	('fixtool', 'Korjaustyökalut', 6),
	('carotool', 'Työkalut', 4),
	('blowpipe', 'Polttoleikkuri', 10),
	('fixkit', 'Korjauskitti', 5),
	('carokit', 'Korikitti', 3)
;
