

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Police')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Posterunkowy',20,'{}','{}'),
	('police',1,'officer','Sierżant',40,'{}','{}'),
	('police',2,'sergeant','Aspirant',60,'{}','{}'),
	('police',3,'lieutenant','Komisarz',85,'{}','{}'),
	('police',4,'boss','Generalny Inspektor',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Nadużywanie klaksonu', 30, 0),
	('Przekroczenie lini ciągłej', 40, 0),
	('Jechanie po złej stronie drogi', 250, 0),
	('Nieprawidłowe zawracanie', 250, 0),
	('Nielegalna jazda Off-road', 170, 0),
	('Niedostosowanie się do poleceń Policji', 30, 0),
	('Nieprawidłowe zatrzymanie pojazdu', 150, 0),
	('Nieprawidłowe parkownie', 70, 0),
	('Niezastosowanie się do ruchu prawostronnego (jazda lewym pasem)', 70, 0),
	('Brak informacji o pojeździe', 90, 0),
	('Niezastosowanie się do znaku SOTP', 105, 0),
	('Niezatrzymanie się na czerwonym świetle', 130, 0),
	('Przechodzenie w niedozwolonym miejscu', 100, 0),
	('Jazda nielegalnym pojazdem', 100, 0),
	('Brak prawa jazdy', 1500, 0),
	('Ucieczka z miejsca zdarzenia', 800, 0),
	('Przekroczenie prędkości < 5 mph', 90, 0),
	('Przekroczenie prędkości 5-15 mph', 120, 0),
	('Przekroczenie prędkości 15-30 mph', 180, 0),
	('Przekroczenie prędkości > 30 mph', 300, 0),
	('Utrudnianie przemieszczania się', 110, 1),
	('Publiczne zgorszenie', 90, 1),
	('Niepoprawne zachowanie', 90, 1),
	('Utrudnianie postępowania', 130, 1),
	('Obraza cywilów', 75, 1),
	('Obraza graczy', 110, 1),
	('Groźby werbalne', 90, 1),
	('Przeklinanie na graczy', 150, 1),
	('Dostarczanie fałszywych informacji', 250, 1),
	('Próba korupcji', 1500, 1),
	('Wymachiwanie bronią w mieście', 120, 2),
	('Wymachiwanie niebezpieczną bronią w mieście', 300, 2),
	('Brak pozwolenia na broń', 600, 2),
	('Posiadanie nielegalnej broni', 700, 2),
	('Posiadanie narzędzi do włamań', 300, 2),
	('Złodziej - recydywista', 1800, 2),
	('Rozprowadzanie nielegalnych substancji', 1500, 2),
	('Wytwarzanie nielegalnych substancji', 1500, 2),
	('Posiadanie zakazanych substancji', 650, 2),
	('Porwanie cywila', 1500, 2),
	('Porwanie gracza', 2000, 2),
	('Rabunek', 650, 2),
	('Kradzież z bronią w ręku', 650, 2),
	('Napad na Bank', 1500, 2),
	('Atak na cywila', 2000, 3),
	('Atak na gracza', 2500, 3),
	('Próba morderstwa cywila', 3000, 3),
	('Próba morderstwa gracza', 5000, 3),
	('Zabójstwo cywila z premedytacją', 10000, 3),
	('Zabójstwo gracza z premedytacją', 30000, 3),
	('Nieumyślne spowodowanie śmierci', 1800, 3),
	('Oszustwo', 2000, 2);
;
