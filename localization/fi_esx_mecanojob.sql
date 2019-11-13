USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'Mekaanikko', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'Mekaanikko', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Mekaanikko')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Harjottelija',12,'{}','{}'),
	('mechanic',1,'novice','Aloittelija',24,'{}','{}'),
	('mechanic',2,'experimente','Kokenut',36,'{}','{}'),
	('mechanic',3,'chief','Johtaja',48,'{}','{}'),
	('mechanic',4,'boss','Pomo',0,'{}','{}')
;

INSERT INTO `items` (name, label, weight) VALUES
	('gazbottle', 'Kaasupullo', 2),
	('fixtool', 'Korjaustyökalut', 2),
	('carotool', 'Työkalut', 2),
	('blowpipe', 'Polttoleikkuri', 2),
	('fixkit', 'Korjauskitti', 3),
	('carokit', 'Korikitti', 3)
;
