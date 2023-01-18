

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Banka',1),
	('bank_savings','Banka Birikimi',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Bankacı')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Danışman',10,'{}','{}'),
	('banker',1,'banker','Bankacı',20,'{}','{}'),
	('banker',2,'business_banker','İşletme Bankacısı',30,'{}','{}'),
	('banker',3,'trader','Borsacı',40,'{}','{}'),
	('banker',4,'boss','Yönetici',0,'{}','{}')
;
