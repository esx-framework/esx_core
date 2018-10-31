USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Kiinteistvälittäjä',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Kiinteistövälittäjä')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Vuokraisäntä',10,'{}','{}'),
	('realestateagent',1,'vendeur','Myyjä',25,'{}','{}'),
	('realestateagent',2,'gestion','Johtaja',40,'{}','{}'),
	('realestateagent',3,'boss','Pomo',0,'{}','{}')
;
