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
  ('miner', 0, 'interim', 'Intérimaire', 0, '{"tshirt_2":1,"ears_1":8,"glasses_1":15,"torso_2":0,"ears_2":2,"glasses_2":3,"shoes_2":1,"pants_1":75,"shoes_1":51,"bags_1":0,"helmet_2":0,"pants_2":7,"torso_1":71,"tshirt_1":59,"arms":2,"bags_2":0,"helmet_1":0}', '{}'),
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
