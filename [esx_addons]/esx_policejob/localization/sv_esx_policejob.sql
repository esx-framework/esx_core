

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Polis', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Polis', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Polis', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Polis')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Aspirant',20,'{}','{}'),
	('police',1,'officer','Assistent',40,'{}','{}'),
	('police',2,'sergeant','Inspektör',60,'{}','{}'),
	('police',3,'lieutenant','Kommissarie',85,'{}','{}'),
	('police',4,'boss','Rikspolischef',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int(11) DEFAULT NULL,
	`category` int(11) DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Missbruk av tuta',30,0),
	('Köra över heldragen linje',40,0),
	('Kört i motsatt riktning i rondell',250,0),
	('Olaglig u-sväng',250,0),
	('Olovlig körning i terräng',170,0),
	('Kört för nära bil framför',30,0),
	('Trafikfarlig stopp',150,0),
	('Olaglig parkering',70,0),
	('Använder inte högerregeln',70,0),
	('Aktar sig inte för tjänstefordon i utryckning',90,0),
	('Kört förbi stoppskylt',105,0),
	('Kört mot rött',130,0),
	('Farlig omkörning',100,0),
	('Fordon i dåligt skick',100,0),
	('Kört utan körkort',1500,0),
	('Smitning från olycka',800,0),
	('Kört för fort < 5 kmh',90,0),
	('Kört för fort 5-15 kmh',120,0),
	('Kört för fort 15-30 kmh',180,0),
	('Kört för fort > 30 kmh',300,0),
	('Blockerar trafiken',110,1),
	('Förstört allmän egendom',90,1),
	('Olaga diskriminering',90,1),
	('förhindrar polisens verksamhet',130,1),
	('Hets mot folkgrupp',75,1),
	('Dåligt beteende mot tjänsteman',110,1),
	('Verbalt hot mot annan person',90,1),
	('Verbalt hot mot en tjänsteman',150,1),
	('Olaglig protest',250,1),
	('Försök till mutning',1500,1),
	('Icke livshotande vapen på allmän plats ex. Hammare',120,2),
	('Dödligt vapen på allmän plats',300,2),
	('Vapen på allmän plats med licens (Licens Fel)',600,2),
	('Innehaft olaga vapen',700,2),
	('Försökt bryta sig in',300,2),
	('Bilstöld',1800,2),
	('Försäljning av droger',1500,2),
	('Tillverkning av droger',1500,2),
	('Innehav av droger',650,2),
	('Hålla gisslan/Hålla person mot dess vilja',1500,2),
	('Kidnappa en tjänsteman',2000,2),
	('Rån',650,2),
	('Butiksrån',650,2),
	('Bankrån',1500,2),
	('Skjutit en person',2000,3),
	('Skjutit en tjänsteman',2500,3),
	('Mordförsök',3000,3),
	('Mordförsök på tjänsteman',6000,3),
	('Mord',10000,3),
	('Mord på tjänsteman',30000,3),
	('Dråp',1800,3),
	('Olagliga aktiviteter inom ett företag',2000,2)
;
