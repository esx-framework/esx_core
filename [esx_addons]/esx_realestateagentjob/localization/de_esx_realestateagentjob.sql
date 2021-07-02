USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Immobilienverkauf',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Immobilienverkauf')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Vermieter',10,'{}','{}'),
	('realestateagent',1,'vendeur','Verkäufer',25,'{}','{}'),
	('realestateagent',2,'gestion','Manager',40,'{}','{}'),
	('realestateagent',3,'boss','Boss',0,'{}','{}')
;
