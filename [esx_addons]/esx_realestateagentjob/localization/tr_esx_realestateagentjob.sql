

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Emlak Bürosu',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Emlak Bürosu')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Eleman',10,'{}','{}'),
	('realestateagent',1,'vendeur','Sekreter',25,'{}','{}'),
	('realestateagent',2,'gestion','Asistan',40,'{}','{}'),
	('realestateagent',3,'boss','Patron',0,'{}','{}')
;
