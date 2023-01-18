

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Pankki',1),
	('bank_savings','Pankki',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Pankkiiri')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Konsultti',10,'{}','{}'),
	('banker',1,'banker','Pankkiiri',20,'{}','{}'),
	('banker',2,'business_banker','Yritys Pankkiiri',30,'{}','{}'),
	('banker',3,'trader','Välittäjä',40,'{}','{}'),
	('banker',4,'boss','Pomo',0,'{}','{}')
;
