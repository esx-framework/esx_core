INSERT INTO `addon_account` VALUES (name, label, shared)
  ('society_cardealer','Concessionnaire',1)
;

INSERT INTO `jobs` (name, label) VALUES
  ('cardealer','Concessionnaire')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('cardealer',0,'recruit','Recrue',10,'{}','{}'),
  ('cardealer',1,'novice','Novice',25,'{}','{}'),
  ('cardealer',2,'experienced','Experimente',40,'{}','{}'),
  ('cardealer',3,'boss','Patron',0,'{}','{}')
;
