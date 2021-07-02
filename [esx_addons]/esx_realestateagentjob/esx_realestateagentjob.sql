USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Agent immobilier',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Agent immobilier')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Location',10,'{}','{}'),
	('realestateagent',1,'vendeur','Vendeur',25,'{}','{}'),
	('realestateagent',2,'gestion','Gestion',40,'{}','{}'),
	('realestateagent',3,'boss','Patron',0,'{}','{}')
;
