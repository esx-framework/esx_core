

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_realestateagent','Ingatlan közvetítő',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('realestateagent','Ingatlanügynök')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('realestateagent',0,'location','Bérbeadó ügynök',10,'{}','{}'),
	('realestateagent',1,'vendeur','Ügynök',25,'{}','{}'),
	('realestateagent',2,'gestion','Menedzsment',40,'{}','{}'),
	('realestateagent',3,'boss','Bróker',0,'{}','{}')
;
