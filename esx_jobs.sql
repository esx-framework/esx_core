USE `essentialmode`;

INSERT INTO `addon_account` (name, label, shared) VALUES
  ('caution', 'Caution', 0)
;

INSERT INTO `jobs` (name, label) VALUES
  ('slaughterer', 'Abatteur'),
  ('fisherman', 'Pêcheur'),
  ('miner', 'Mineur'),
  ('lumberjack', 'Bûcheron'),
  ('fuel', 'Raffineur'),
  ('reporter', 'Journaliste'),
  ('textil', 'Couturier')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('lumberjack', 0, 'interim', 'Intérimaire', 0, '{}', '{}'),
  ('fisherman', 0, 'interim', 'Intérimaire', 0, '{}', '{}'),
  ('fuel', 0, 'interim', 'Intérimaire', 0, '{}', '{}'),
  ('reporter', 0, 'employee', 'Intérimaire', 0, '{}', '{}'),
  ('textil', 0, 'interim', 'Intérimaire', 0, '{}', '{}'),
  ('miner', 0, 'interim', 'Intérimaire', 0, '{}', '{}'),
  ('slaughterer', 0, 'interim', 'Intérimaire', 0, '{}', '{}')
;

INSERT INTO `items` (`name`, `label`) VALUES
	('alive_chicken', 'Poulet vivant'),
	('slaughtered_chicken', 'Poulet abattu'),
	('packaged_chicken', 'Poulet en barquette'),
	('fish', 'Poisson'),
	('stone', 'Pierre'),
	('washed_stone', 'Pierre Lavée'),
	('copper', 'Cuivre'),
	('iron', 'Fer'),
	('gold', 'Or'),
	('diamond', 'Diamant'),
	('wood', 'Bois'),
	('cutted_wood', 'Bois coupé'),
	('packaged_plank', 'Paquet de planches'),
	('petrol', 'Pétrole'),
	('petrol_raffin', 'Pétrole Raffiné'),
	('essence', 'Essence'),
	('whool', 'Laine'),
	('fabric', 'Tissu'),
	('clothe', 'Vêtement')
;