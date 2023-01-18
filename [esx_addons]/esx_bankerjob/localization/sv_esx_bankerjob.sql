

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Bank',1),
	('bank_savings','Bank',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Banktjänsteman')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Rådgivare',10,'{}','{}'),
	('banker',1,'banker','Banktjänsteman',20,'{}','{}'),
	('banker',2,'business_banker','Företagstjänsteman',30,'{}','{}'),
	('banker',3,'trader','Köpman',40,'{}','{}'),
	('banker',4,'boss','VD',0,'{}','{}')
;
