USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Poliisi', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Poliisi', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Poliisi', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Poliisi')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Tulokas',20,'{}','{}'),
	('police',1,'officer','Konstaapeli',40,'{}','{}'),
	('police',2,'sergeant','Ylikonstaapeli',60,'{}','{}'),
	('police',3,'lieutenant','Kersantti',85,'{}','{}'),
	('police',4,'boss','Komentaja',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Äänimerkin väärinkäyttö', 30, 0),
	('Laiton jatkuvan linjan ylitys', 40, 0),
	('Ajaminen tien väärällä puolella', 250, 0),
	('Laiton U-käännös', 250, 0),
	('Laiton maastossa ajaminen', 170, 0),
	('Virkavallan käskyn laiminlyönti', 30, 0),
	('Laiton pysähtyminen', 150, 0),
	('Laiton parkkeeraus', 70, 0),
	('Väistöolovelvollisuuden laiminlyönti', 70, 0),
	('Väärän ajoneuvontiedon antaminen', 90, 0),
	('Stop merkin laiminlyönti', 105, 0),
	('Punaisten valojen laiminlyönti', 130, 0),
	('Laiton ohitus', 100, 0),
	('Laittomalla ajoneuvolla ajaminen', 100, 0),
	('Ajokortitta ajo', 1500, 0),
	('Yliajo', 800, 0),
	('Ylinopeus < 5 kmh', 90, 0),
	('Ylinopeus 5-15 kmh', 120, 0),
	('Ylinopeus 15-30 kmh', 180, 0),
	('Ylinopeus > 30 kmh', 300, 0),
	('Liikenteen pysäytys tahallisesti', 110, 1),
	('Julkinen päihtyminen', 90, 1),
	('Sopimaton käytös', 90, 1),
	('Oikeusjärjestelmän estäminen', 130, 1),
	('Siviilin loukkaaminen', 75, 1),
	('Virkavallan halventaminen', 110, 1),
	('Sanallainen uhkaus siviiliä kohtaan', 90, 1),
	('Sanallinen uhkaus virkavaltaa kohtaan', 150, 1),
	('Virheellisen tiedon antaminen', 250, 1),
	('Korruptioyritys', 1500, 1),
	('Aseella heiluminen kaupungin sisällä', 120, 2),
	('Tappavalla aseella heiluminen kaupungin sisällä', 300, 2),
	('Ei aselupaa', 600, 2),
	('Laittoman aseen hallusapito', 700, 2),
	('Murtotyökalujen hallussapito', 300, 2),
	('Autovarkaus', 1800, 2),
	('Tarkoitus myydä/levittää laitonta ainetta', 1500, 2),
	('Laittoman aineen valmistus', 1500, 2),
	('Laittoman aineen hallusapito ', 650, 2),
	('Siviilin kidnappaus', 1500, 2),
	('Virkavallan kidnappaus', 2000, 2),
	('Ryöstö', 650, 2),
	('Aseellinen kaupparyöstö', 650, 2),
	('Aseellinen pankkiryöstö', 1500, 2),
	('Siviiliä kohtaan kohdistunut hyökkäys', 2000, 3),
	('Virkavaltaa kohtaan kohdistunut hyökkäys', 2500, 3),
	('Siviilin murhanyritys', 3000, 3),
	('Virkavallan murhanyirtys', 5000, 3),
	('Siviilin murha', 10000, 3),
	('Virkavallan murha', 30000, 3),
	('Väkivaltainan tappo', 1800, 3),
	('Petos', 2000, 2);
;
