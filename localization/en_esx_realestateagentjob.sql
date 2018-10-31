USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Real Estate Company',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Realtor')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Renting Agent',10,'{}','{}'),
	('realestateagent',1,'vendeur','Agent',25,'{}','{}'),
	('realestateagent',2,'gestion','Management',40,'{}','{}'),
	('realestateagent',3,'boss','Broker',0,'{}','{}')
;
