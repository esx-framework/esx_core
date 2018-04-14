INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police','Polis',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police','Polis',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Polis', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police','Polis')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Aspirant',20,'{\"tshirt_1\":57,\"torso_1\":55,\"arms\":0,\"pants_1\":35,\"glasses\":0,\"decals_2\":0,\"hair_color_2\":0,\"helmet_2\":0,\"hair_color_1\":5,\"face\":19,\"glasses_2\":1,\"torso_2\":0,\"shoes\":24,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"pants_2\":0,\"hair_2\":0,\"decals_1\":0,\"tshirt_2\":0,\"helmet_1\":8}','{\"tshirt_1\":34,\"torso_1\":48,\"shoes\":24,\"pants_1\":34,\"torso_2\":0,\"decals_2\":0,\"hair_color_2\":0,\"glasses\":0,\"helmet_2\":0,\"hair_2\":3,\"face\":21,\"decals_1\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"arms\":14,\"hair_color_1\":10,\"tshirt_2\":0,\"helmet_1\":57}'),
	('police',4,'officer','Biträdande Rikspolischef',40,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":0,\"decals_1\":8,\"torso_2\":0,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"hair_color_1\":5,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":14,\"pants_1\":34,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"shoes\":24,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"face\":21,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"hair_color_1\":10,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
	('police',1,'sergeant','Assistent',60,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":0,\"decals_1\":8,\"torso_2\":0,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"hair_color_1\":5,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":14,\"pants_1\":34,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"shoes\":24,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"face\":21,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"hair_color_1\":10,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
	('police',2,'lieutenant','Inspektör',85,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":2,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"glasses\":0,\"decals_1\":8,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"torso_2\":0,\"arms\":41,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"hair_2\":3,\"decals_2\":2,\"hair_color_2\":0,\"hair_color_1\":10,\"helmet_2\":0,\"face\":21,\"shoes\":24,\"torso_2\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"decals_1\":7,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
	('police',3,'boss','Rikspolischef',100,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":41,\"torso_2\":0,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"decals_1\":8,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":21,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"hair_color_1\":10,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"shoes\":24,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}')
;

CREATE TABLE `fine_types` (

	`id` int(11) NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int(11) DEFAULT NULL,
	`category` int(11) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `fine_types` (label, amount, category) VALUES
	('Missbruk av tuta',30,0),
	('Köra över heldragen linje',40,0),
	('Kört i motsatt riktning i rondell',250,0),
	('Olaglig U-Sväng',250,0),
	('Olovlig körning i skogen',170,0),
	('Kört för nära bil framför',30,0),
	('Trafikfarligt stopp',150,0),
	('olaglig parkering',70,0),
	('Använder inte högerregeln',70,0),
	('Aktar sig inte för tjänstefordon i utryckning',90,0),
	('Kört förbi stoppskylt',105,0),
	('Kört mot rött',130,0),
	('Farlig omkörning',100,0),
	('Fordon i dåligt skick',100,0),
	('Kört utan körkort',1500,0),
	('smitning från olycka',800,0),
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
	('butiksrån',650,2),
	('bankrån',1500,2),
	('Skjutit en person',2000,3),
	('Skjutit en tjänsteman',2500,3),
	('mordförsök',3000,3),
	('Mordförsök på tjänsteman',5000,3),
	('mord',10000,3),
	('mord på tjänsteman',30000,3),
	('dråp',1800,3),
	('Olagliga aktiviteter inom ett företag',2000,2)
;
