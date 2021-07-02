USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Bank',1),
	('bank_savings','Ahorro bancario',0)
;

INSERT INTO `jobs` (name, label) VALUES
	('banker','Banquero')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'advisor','Asesores',10,'{}','{}'),
	('banker',1,'banker','Banquero',20,'{}','{}'),
	('banker',2,'business_banker','Banquero de negocios',30,'{}','{}'),
	('banker',3,'trader','Comerciante',40,'{}','{}'),
	('banker',4,'boss','Banquero principal',0,'{}','{}')
;
