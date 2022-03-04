USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Fastighetsbyrå',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Fastighetsmäklare')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Uthyrningsagent',10,'{}','{}'),
	('realestateagent',2,'gestion','Förvaltning',40,'{}','{}'),
	('realestateagent',3,'boss','Mäklare',0,'{}','{}')
;
