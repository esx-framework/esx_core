-- ================================================================
-- TrickEm City - 1970s Theme SQL Data
-- Run this AFTER legacy.sql to add 70s themed content
-- ================================================================

-- --------------------------------------------------------
-- 70s Themed Jobs
-- --------------------------------------------------------

INSERT INTO `jobs` (`name`, `label`, `type`, `whitelisted`) VALUES
('disco_dj', 'Disco DJ', 'civ', 0),
('bouncer', 'Club Bouncer', 'civ', 0),
('hustler', 'Street Hustler', 'civ', 0),
('bartender', 'Bartender', 'civ', 0)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- Update existing job labels to 70s style
UPDATE `jobs` SET `label` = 'The Fuzz' WHERE `name` = 'police';
UPDATE `jobs` SET `label` = 'County General' WHERE `name` = 'ambulance';
UPDATE `jobs` SET `label` = 'Slick''s Auto Body' WHERE `name` = 'mechanic';
UPDATE `jobs` SET `label` = 'Downtown Cab Co.' WHERE `name` = 'taxi';
UPDATE `jobs` SET `label` = 'Groovy Rides' WHERE `name` = 'cardealer';
UPDATE `jobs` SET `label` = 'Del Perro Fishing' WHERE `name` = 'fisherman';
UPDATE `jobs` SET `label` = 'Paleto Lumber Co.' WHERE `name` = 'lumberjack';
UPDATE `jobs` SET `label` = 'Raton Canyon Mine' WHERE `name` = 'miner';
UPDATE `jobs` SET `label` = 'Far Out Threads' WHERE `name` = 'tailor';
UPDATE `jobs` SET `label` = 'The Butcher Shop' WHERE `name` = 'slaughterer';
UPDATE `jobs` SET `label` = 'Channel 7 News' WHERE `name` = 'reporter';
UPDATE `jobs` SET `label` = 'Gas & Go' WHERE `name` = 'fueler';

-- --------------------------------------------------------
-- 70s Themed Job Grades
-- --------------------------------------------------------

-- Disco DJ grades
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('disco_dj', 0, 'rookie', 'Vinyl Spinner', 15, '{}', '{}'),
('disco_dj', 1, 'regular', 'Groove Master', 30, '{}', '{}'),
('disco_dj', 2, 'senior', 'Funk Commander', 50, '{}', '{}'),
('disco_dj', 3, 'boss', 'King of Disco', 0, '{}', '{}');

-- Bouncer grades
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('bouncer', 0, 'doorman', 'Doorman', 18, '{}', '{}'),
('bouncer', 1, 'bouncer', 'Bouncer', 28, '{}', '{}'),
('bouncer', 2, 'head_security', 'Head of Security', 40, '{}', '{}'),
('bouncer', 3, 'boss', 'Boss', 0, '{}', '{}');

-- Hustler grades
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('hustler', 0, 'small_time', 'Small Timer', 10, '{}', '{}'),
('hustler', 1, 'player', 'Player', 25, '{}', '{}'),
('hustler', 2, 'big_shot', 'Big Shot', 45, '{}', '{}'),
('hustler', 3, 'boss', 'The Man', 0, '{}', '{}');

-- Bartender grades
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('bartender', 0, 'barback', 'Barback', 12, '{}', '{}'),
('bartender', 1, 'bartender', 'Bartender', 22, '{}', '{}'),
('bartender', 2, 'head_bartender', 'Head Bartender', 35, '{}', '{}'),
('bartender', 3, 'boss', 'Bar Manager', 0, '{}', '{}');

-- Update existing police grades to 70s style
UPDATE `job_grades` SET `label` = 'Beat Cop' WHERE `job_name` = 'police' AND `grade` = 0;
UPDATE `job_grades` SET `label` = 'Patrolman' WHERE `job_name` = 'police' AND `grade` = 1;
UPDATE `job_grades` SET `label` = 'Detective' WHERE `job_name` = 'police' AND `grade` = 2;
UPDATE `job_grades` SET `label` = 'Lieutenant' WHERE `job_name` = 'police' AND `grade` = 3;
UPDATE `job_grades` SET `label` = 'Chief' WHERE `job_name` = 'police' AND `grade` = 4;

-- Update taxi grades to 70s style
UPDATE `job_grades` SET `label` = 'Rookie Cabby' WHERE `job_name` = 'taxi' AND `grade` = 0;
UPDATE `job_grades` SET `label` = 'Street Cabby' WHERE `job_name` = 'taxi' AND `grade` = 1;
UPDATE `job_grades` SET `label` = 'Veteran Cabby' WHERE `job_name` = 'taxi' AND `grade` = 2;
UPDATE `job_grades` SET `label` = 'Ace Driver' WHERE `job_name` = 'taxi' AND `grade` = 3;
UPDATE `job_grades` SET `label` = 'Dispatch Boss' WHERE `job_name` = 'taxi' AND `grade` = 4;

-- Update ambulance grades
UPDATE `job_grades` SET `label` = 'Orderly' WHERE `job_name` = 'ambulance' AND `grade` = 0;
UPDATE `job_grades` SET `label` = 'Paramedic' WHERE `job_name` = 'ambulance' AND `grade` = 1;
UPDATE `job_grades` SET `label` = 'Doctor' WHERE `job_name` = 'ambulance' AND `grade` = 2;
UPDATE `job_grades` SET `label` = 'Chief of Medicine' WHERE `job_name` = 'ambulance' AND `grade` = 3;

-- --------------------------------------------------------
-- 70s Society Accounts
-- --------------------------------------------------------

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_disco_dj', 'Disco DJ', 1),
('society_bouncer', 'Club Security', 1),
('society_bartender', 'Bartender', 1)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

INSERT INTO `addon_account_data` (`account_name`, `money`, `owner`) VALUES
('society_disco_dj', 0, NULL),
('society_bouncer', 0, NULL),
('society_bartender', 0, NULL)
ON DUPLICATE KEY UPDATE `money` = VALUES(`money`);

-- --------------------------------------------------------
-- 70s Themed Items
-- --------------------------------------------------------

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('disco_record', 'Vinyl Record', 1, 0, 1),
('afro_pick', 'Afro Pick', 1, 0, 1),
('bell_bottoms', 'Bell-Bottom Pants', 2, 0, 1),
('platform_shoes', 'Platform Shoes', 2, 0, 1),
('mood_ring', 'Mood Ring', 1, 0, 1),
('lava_lamp', 'Lava Lamp', 3, 1, 1),
('cassette_tape', 'Cassette Tape', 1, 0, 1),
('polaroid_camera', 'Polaroid Camera', 2, 0, 1),
('eight_track', '8-Track Tape', 1, 0, 1),
('fondue_set', 'Fondue Set', 3, 0, 1),
('joint', 'Joint', 1, 0, 1),
('whiskey', 'Whiskey Bottle', 2, 0, 1),
('cigar', 'Cuban Cigar', 1, 0, 1),
('switchblade', 'Switchblade', 1, 0, 1),
('dice', 'Lucky Dice', 1, 0, 1),
('lockpick', 'Lockpick', 1, 0, 1),
('repair_kit', 'Repair Kit', 3, 0, 1)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- --------------------------------------------------------
-- 70s Vehicle List (replace modern vehicles)
-- --------------------------------------------------------

-- Clear existing vehicles and add 70s era vehicles
DELETE FROM `vehicles`;

INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES
-- Muscle Cars
('Sabre Turbo', 'sabregt', 4500, 'muscle'),
('Sabre GT Custom', 'sabregt2', 5200, 'muscle'),
('Dukes', 'dukes', 3800, 'muscle'),
('Gauntlet', 'gauntlet', 4200, 'muscle'),
('Dominator', 'dominator', 4800, 'muscle'),
('Phoenix', 'phoenix', 3200, 'muscle'),
('Vigero', 'vigero', 2800, 'muscle'),
('Blade', 'blade', 2500, 'muscle'),
('Buccaneer', 'buccaneer', 2200, 'muscle'),
('Buccaneer Custom', 'buccaneer2', 3500, 'muscle'),
('Chino', 'chino', 2000, 'muscle'),
('Chino Custom', 'chino2', 3000, 'muscle'),
('Tampa', 'tampa', 2800, 'muscle'),
('Faction', 'faction', 2600, 'muscle'),
('Faction Custom', 'faction2', 3800, 'muscle'),
('Nightshade', 'nightshade', 5500, 'muscle'),
('Voodoo', 'voodoo', 1800, 'muscle'),
('Picador', 'picador', 2400, 'muscle'),
('Slam Van', 'slamvan3', 2000, 'muscle'),
('Hustler', 'hustler', 6500, 'muscle'),
('Hermes', 'hermes', 5800, 'muscle'),
('Hotknife', 'hotknife', 7500, 'muscle'),
('Coquette BlackFin', 'coquette3', 6000, 'muscle'),

-- Sports Classics
('Stinger', 'stinger', 8500, 'sportsclassics'),
('Stinger GT', 'stingergt', 8000, 'sportsclassics'),
('Monroe', 'monroe', 6000, 'sportsclassics'),
('Coquette Classic', 'coquette2', 5500, 'sportsclassics'),
('Manana', 'manana', 1600, 'sportsclassics'),
('Pigalle', 'pigalle', 2800, 'sportsclassics'),
('Casco', 'casco', 4000, 'sportsclassics'),
('GT 500', 'gt500', 9000, 'sportsclassics'),
('Retinue', 'retinue', 6500, 'sportsclassics'),
('Savestra', 'savestra', 8000, 'sportsclassics'),
('Rapid GT Classic', 'rapidgt3', 7200, 'sportsclassics'),
('Z-Type', 'ztype', 15000, 'sportsclassics'),
('Roosevelt', 'btype', 6500, 'sportsclassics'),
('Viseris', 'viseris', 8500, 'sportsclassics'),
('Ardent', 'ardent', 10000, 'sportsclassics'),
('Stirling GT', 'feltzer3', 7000, 'sportsclassics'),
('Tornado', 'tornado', 1800, 'sportsclassics'),

-- Sedans / Economy
('Washington', 'washington', 2500, 'sedans'),
('Emperor', 'emperor', 2200, 'sedans'),
('Glendale', 'glendale', 1800, 'sedans'),
('Regina', 'regina', 800, 'sedans'),
('Warrener', 'warrener', 650, 'sedans'),
('Asea', 'asea', 900, 'sedans'),
('Intruder', 'intruder', 1100, 'sedans'),
('Premier', 'premier', 1200, 'sedans'),
('Fugitive', 'fugitive', 1500, 'sedans'),
('Cognoscenti', 'cognoscenti', 6000, 'sedans'),
('Super Diamond', 'superd', 8000, 'sedans'),
('Stretch Limo', 'stretch', 9500, 'sedans'),

-- Vans
('Surfer Van', 'surfer', 1600, 'vans'),
('Youga Van', 'youga', 1800, 'vans'),
('Moonbeam', 'moonbeam', 2200, 'vans'),
('Moonbeam Custom', 'moonbeam2', 3500, 'vans'),
('Minivan', 'minivan', 1500, 'vans'),
('Burrito', 'burrito3', 2000, 'vans'),
('Bobcat XL', 'bobcatxl', 2800, 'vans'),
('Journey', 'journey', 1200, 'vans'),
('Paradise Van', 'paradise', 2400, 'vans'),
('Camper', 'camper', 3000, 'vans'),
('Rumpo Van', 'rumpo', 1800, 'vans'),

-- Motorcycles
('Western Daemon', 'daemon', 1500, 'motorcycles'),
('Hexer', 'hexer', 1600, 'motorcycles'),
('Innovation', 'innovation', 2200, 'motorcycles'),
('Wolfsbane', 'wolfsbane', 1200, 'motorcycles'),
('Nightblade', 'nightblade', 2800, 'motorcycles'),
('Sovereign', 'sovereign', 2000, 'motorcycles'),
('Zombie Chopper', 'zombiea', 1400, 'motorcycles'),
('Avarus', 'avarus', 1600, 'motorcycles'),
('Bagger', 'bagger', 1800, 'motorcycles'),
('PCJ-600', 'pcj', 900, 'motorcycles'),
('Sanchez', 'sanchez', 700, 'motorcycles'),
('Faggio', 'faggio', 300, 'motorcycles'),

-- Compacts
('Blista', 'blista', 1000, 'compacts'),
('Issi', 'issi2', 1200, 'compacts'),
('Panto', 'panto', 900, 'compacts'),
('Brioso', 'brioso', 1400, 'compacts');

-- --------------------------------------------------------
-- Update Vehicle Categories for 70s feel
-- --------------------------------------------------------

UPDATE `vehicle_categories` SET `label` = 'Muscle Machines' WHERE `name` = 'muscle';
UPDATE `vehicle_categories` SET `label` = 'Classic Cruisers' WHERE `name` = 'sportsclassics';
UPDATE `vehicle_categories` SET `label` = 'Sedans & Luxury' WHERE `name` = 'sedans';
UPDATE `vehicle_categories` SET `label` = 'Vans & Wagons' WHERE `name` = 'vans';
UPDATE `vehicle_categories` SET `label` = 'Choppers & Bikes' WHERE `name` = 'motorcycles';
UPDATE `vehicle_categories` SET `label` = 'Compact Cars' WHERE `name` = 'compacts';

-- Remove modern categories that don't fit 70s
DELETE FROM `vehicle_categories` WHERE `name` IN ('super', 'sports');

-- --------------------------------------------------------
-- Update Licenses for 70s style
-- --------------------------------------------------------

UPDATE `licenses` SET `label` = 'Learner''s Permit' WHERE `type` = 'dmv';
UPDATE `licenses` SET `label` = 'Driver''s License' WHERE `type` = 'drive';
UPDATE `licenses` SET `label` = 'Motorcycle Endorsement' WHERE `type` = 'drive_bike';
UPDATE `licenses` SET `label` = 'Commercial License (CDL)' WHERE `type` = 'drive_truck';
UPDATE `licenses` SET `label` = 'Boating Certificate' WHERE `type` = 'boat';

-- --------------------------------------------------------
-- Update Fine Types for 70s Pricing
-- --------------------------------------------------------

UPDATE `fine_types` SET `amount` = ROUND(`amount` * 0.15) WHERE `amount` > 0;

-- --------------------------------------------------------
-- Update Paycheck Salaries for 70s Economy
-- (Average salary in 1975 was ~$14,000/year or ~$270/week)
-- --------------------------------------------------------

UPDATE `job_grades` SET `salary` = ROUND(`salary` * 0.75) WHERE `salary` > 0;
