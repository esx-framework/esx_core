USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Policía', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Policía', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Policía', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Policía')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Recluta',20,'{}','{}'),
	('police',1,'officer','Oficial',40,'{}','{}'),
	('police',2,'sergeant','Sargento',60,'{}','{}'),
	('police',3,'lieutenant','Teniente',85,'{}','{}'),
	('police',4,'boss','Jefe',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `fine_types` (label, amount, category) VALUES
	('Mal uso del claxon', 30, 0),
	('Cruzar indebidamente la línea continua', 40, 0),
	('Conducir por el lado incorrecto de la carretera', 250, 0),
	('Giro indebido', 250, 0),
	('Conducir indebidamente fuera de la carretera', 170, 0),
	('No hacer caso a una orden de un agente', 30, 0),
	('Detener el vehículo de forma incorrecta', 150, 0),
	('Aparcar en un lugar no habilitado', 70, 0),
	('No ceder al girar a la derecha', 70, 0),
	('No cumplir con los datos de tu vehículo', 90, 0),
	('No pararse en una señal de STOP', 105, 0),
	('No pararse en un semáforo cuando está en rojo', 130, 0),
	('Cruzar indebidamente', 100, 0),
	('Conducir un coche no permitido', 100, 0),
	('Conducir sin carnet de conducción', 1500, 0),
	('Chocar y darse a la fuga', 800, 0),
	('Exceder la velocidad permitida en 5 km/h', 90, 0),
	('Exceder la velocidad permitida entre 5 y 15 km/h', 120, 0),
	('Exceder la velocidad permitida entre 15 y 30 km/h', 180, 0),
	('Exceder la velocidad permitida más de 30 km/h', 300, 0),
	('Generar atasco en una carretera', 110, 1),
	('Intoxicación pública', 90, 1),
	('Conducta alocada', 90, 1),
	('Obstrucción a la justicia', 130, 1),
	('Insultos hacia civiles', 75, 1),
	('Insultos hacia un agente', 110, 1),
	('Amenaza verbar a un civil', 90, 1),
	('Amenaza verbal a un agente', 150, 1),
	('Dar información falsa', 250, 1),
	('Intento de corrupción', 1500, 1),
	('Tendencia de armas en los limites de la ciudad', 120, 2),
	('Tendencia de armas letales en los limites de la ciudad', 300, 2),
	('No tener licencia de armas', 600, 2),
	('Posesión de un arma ilegal', 700, 2),
	('Posesión de herramientas para robos', 300, 2),
	('Desorden público', 1800, 2),
	('Intento de venta o distribución de sustancias ilegales', 1500, 2),
	('Fabricación de sustancias ilegales', 1500, 2),
	('Posesión de sustancias ilegales', 650, 2),
	('Secuestro de un civil', 1500, 2),
	('Secuestro de un agente', 2000, 2),
	('Robo', 650, 2),
	('Robo armado a una tienda', 650, 2),
	('Robo armado a un banco', 1500, 2),
	('Asalto a un civil', 2000, 3),
	('Asalto a un agente', 2500, 3),
	('Intento de asesinato a un civil', 3000, 3),
	('Intento de asesinato a un agente', 5000, 3),
	('Asesinato de un civil', 10000, 3),
	('Asesinato de un policia', 30000, 3),
	('Homicidio involuntario', 1800, 3),
	('Fraude', 2000, 2);
;
