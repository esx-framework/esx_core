

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Prodajalna Hiš',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Prodajalec Hiš')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Prodajalni Agent',10,'{}','{}'),
	('realestateagent',1,'vendeur','Agent',25,'{}','{}'),
	('realestateagent',2,'gestion','Manager',40,'{}','{}'),
	('realestateagent',3,'boss','Direktor',0,'{}','{}')
;
