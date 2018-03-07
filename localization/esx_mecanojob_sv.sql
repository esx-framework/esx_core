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
  ('mecano',0,'Rekryt','Recruit',12,'{}','{}'),
  ('mecano',1,'Nyanställd','Novice',24,'{}','{}'),
  ('mecano',2,'Erfaren','Experienced',36,'{}','{}'),
  ('mecano',3,'Chef','Leader',48,'{}','{}'),
  ('mecano',4,'Bossen','Boss',0,'{}','{}')
;

INSERT INTO `items` (name, label) VALUES
  ('gazbottle', 'Gas Flaska'),
  ('fixtool', 'Reparationsverktyg'),
  ('carotool', 'Verktyg'),
  ('blowpipe', 'Blåslampa'),
  ('fixkit', 'Reparationssats'),
  ('carokit', 'Plåt Verktyg')
;
