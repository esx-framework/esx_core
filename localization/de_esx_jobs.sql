USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
  ('caution', 'Caution', 0)
;

INSERT INTO `jobs` (name, label) VALUES
  ('slaughterer', 'Schlachterei'),
  ('fisherman', 'Fischerei'),
  ('miner', 'Bergbau'),
  ('lumberjack', 'Holzbetrieb'),
  ('fuel', 'Raffinerie'),
  ('reporter', 'Kanal 7'),
  ('textil', 'Schneiderei')
;

ALTER TABLE jobs ADD whitelisted BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('lumberjack', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}'),
  ('fisherman', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}'),
  ('fuel', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}'),
  ('reporter', 0, 'employee', 'Mitarbeiter', 0, '{}', '{}'),
  ('textil', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}'),
  ('miner', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}'),
  ('slaughterer', 0, 'interim', 'Mitarbeiter', 0, '{}', '{}')
;

INSERT INTO `items` (`name`, `label`) VALUES
  ('alive_chicken', 'lebendes Huhn'),
  ('slaughtered_chicken', 'geschlachtetes Huhn'),
  ('packaged_chicken', 'Hähnchenfilet'),
  ('fish', 'Fisch'),
  ('stone', 'Felsbrocken'),
  ('washed_stone', 'gewaschener Felsbrocken'),
  ('copper', 'Kupfer'),
  ('iron', 'Eisen'),
  ('gold', 'Gold'),
  ('diamond', 'Diamant'),
  ('wood', 'Holz'),
  ('cutted_wood', 'Holzstämme'),
  ('packaged_plank', 'Bretterpaket'),
  ('petrol', 'Öl'),
  ('petrol_raffin', 'bearbeitetes Öl'),
  ('essence', 'Benzin'),
  ('whool', 'Wolle'),
  ('fabric', 'Tuch'),
  ('clothe', 'Kleidung')
;
