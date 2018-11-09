USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Bank',1),
	('bank_savings','Bank Savings',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Banker')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Advisor',10,'{}','{}'),
	('banker',1,'banker','Banker',20,'{}','{}'),
	('banker',2,'business_banker','Business Banker',30,'{}','{}'),
	('banker',3,'trader','Trader',40,'{}','{}'),
	('banker',4,'boss','Lead Banker',0,'{}','{}')
;
