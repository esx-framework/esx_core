USE `essentialmode`;

INSERT INTO `licenses` (`type`, `label`) VALUES
	('boat', 'Boat License')
;

ALTER TABLE `owned_vehicles`
	ADD COLUMN `vehicleType` VARCHAR(20) NULL DEFAULT 'car',
	ADD COLUMN `stored` TINYINT(1) NOT NULL DEFAULT '1'
;