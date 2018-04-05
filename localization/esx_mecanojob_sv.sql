USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
  ('society_mecano','Mekaniker',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
  ('society_mecano','Mekaniker',1)
;

INSERT INTO `jobs` (name, label) VALUES
  ('mecano','Mekaniker')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('mecano',0,'recrue','Rekryt',12,'{}','{}'),
  ('mecano',1,'novice','Nyanställd',24,'{}','{}'),
  ('mecano',2,'experimente','Erfaren',36,'{}','{}'),
  ('mecano',3,'chief','Chef',48,'{}','{}'),
  ('mecano',4,'boss','Bossen',0,'{}','{}')
;

INSERT INTO `items` (name, label) VALUES
  ('gazbottle', 'Gas Flaska'),
  ('fixtool', 'Reparationsverktyg'),
  ('carotool', 'Verktyg'),
  ('blowpipe', 'Blåslampa'),
  ('fixkit', 'Reparationssats'),
  ('carokit', 'Plåt Verktyg')
;
