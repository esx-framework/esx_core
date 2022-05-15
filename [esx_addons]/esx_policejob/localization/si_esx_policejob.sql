USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Policija')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Rekrut',20,'{}','{}'),
	('police',1,'officer','Uradnik',40,'{}','{}'),
	('police',2,'sergeant','Serzant',60,'{}','{}'),
	('police',3,'lieutenant','PodDirektor',85,'{}','{}'),
	('police',4,'boss','Direktor',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	("Zloraba roga", 30, 0),
	("nezakonito prečkanje neprekinjene črte", 40, 0),
	("vožnja po napačni strani ceste", 250, 0),
	("Nezakonit obrat v nasprotno smer", 250, 0),
	("Nezakonita vožnja zunaj ceste", 170, 0),
	("zavrnitev zakonitega ukaza", 30, 0),
	("Nezakonito ustavljanje vozila", 150, 0),
	("nezakonito parkiranje", 70, 0),
	("Neupoštevanje prednosti na desni strani", 70, 0),
	("neupoštevanje informacij o vozilu", 90, 0),
	("Neustavitev pri znaku za ustavitev", 105, 0),
	("ne ustavi pri rdeči luči", 130, 0),
	("nezakonita vožnja mimo", 100, 0),
	("vožnja nezakonitega vozila", 100, 0),
	("vožnja brez vozniškega dovoljenja", 1500, 0),
	("pobeg s kraja", 800, 0),
	("prekoračitev hitrosti nad < 5 mph", 90, 0),
	("prekoračitev hitrosti nad 5-15 mph", 120, 0),
	("prekoračitev hitrosti nad 15-30 mph", 180, 0),
	("prekoračitev hitrosti nad > 30 mph", 300, 0),
	("Oviranje pretočnosti prometa", 110, 1),
	("zastrupitev v javnosti", 90, 1),
	("Neurejeno vedenje", 90, 1),
	("oviranje pravosodja", 130, 1),
	("žalitve državljanov", 75, 1),
	("nespoštovanje uslužbenca policije", 110, 1),
	("verbalna grožnja državljanu", 90, 1),
	("Verbalna grožnja pripadniku LEO", 150, 1),
	("Zagotavljanje lažnih informacij", 250, 1),
	("poskus korupcije", 1500, 1),
	("razkazovanje orožja na območju mesta", 120, 2),
	("razkazovanje smrtonosnega orožja na območju mesta", 300, 2),
	("nima dovoljenja za strelno orožje", 600, 2),
	("posedovanje nezakonitega orožja", 700, 2),
	("posedovanje vlomilskega orodja", 300, 2),
	("Grand Theft Auto", 1800, 2),
	("namera prodaje/distribucije prepovedane snovi", 1500, 2),
	('distribucija nedovoljene snovi', 1500, 2),
	("posedovanje nedovoljene snovi", 650, 2),
	("ugrabitev civilista", 1500, 2),
	("ugrabitev policista", 2000, 2),
	("rop", 650, 2),
	("oborožen rop trgovine", 650, 2),
	("oborožen rop banke", 1500, 2),
	("napad na civilista", 2000, 3),
	("napad na policista", 2500, 3),
	("poskus umora civilne osebe", 3000, 3),
	("Poskus umora policista", 5000, 3),
	("Umor civilne osebe", 10000, 3),
	("Umor policista", 30000, 3),
	("nenamerni uboj", 1800, 3),
	("goljufija", 2000, 2);
;
