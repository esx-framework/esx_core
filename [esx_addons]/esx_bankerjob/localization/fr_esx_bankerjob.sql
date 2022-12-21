

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Banque',1),
	('bank_savings','Livret Bleu',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Banquier')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Conseiller',10,'{}','{}'),
	('banker',1,'banker','Banquier',20,'{}','{}'),
	('banker',2,'business_banker',"Banquier d\'affaire",30,'{}','{}'),
	('banker',3,'trader','Trader',40,'{}','{}'),
	('banker',4,'boss','Patron',0,'{}','{}')
;
