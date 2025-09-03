-- Vehicle VIN System Migration
-- This script adds VIN (Vehicle Identification Number) support to ESX Framework
-- Author: ESX Framework Contributors
-- Date: 2025

-- Add VIN column to owned_vehicles table
ALTER TABLE `owned_vehicles` 
ADD COLUMN `vin` VARCHAR(17) DEFAULT NULL AFTER `plate`;

-- Add index for VIN column for faster lookups
ALTER TABLE `owned_vehicles` 
ADD INDEX `idx_vin` (`vin`);

-- Add unique constraint to ensure VIN uniqueness
-- Note: This is commented out initially to allow NULL values for existing vehicles
-- Uncomment after populating VINs for all vehicles
-- ALTER TABLE `owned_vehicles` 
-- ADD UNIQUE KEY `unique_vin` (`vin`);

-- Optional: Create a stored procedure to generate VINs for existing vehicles
-- This can be run manually after deployment
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS `GenerateVINsForExistingVehicles`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_plate VARCHAR(12);
    DECLARE v_owner VARCHAR(60);
    DECLARE v_vin VARCHAR(17);
    DECLARE cur CURSOR FOR 
        SELECT plate, owner 
        FROM owned_vehicles 
        WHERE vin IS NULL OR vin = '';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_plate, v_owner;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Note: This generates a simple placeholder VIN
        -- The actual VIN generation should be done by the Lua script
        -- This is just for demonstration purposes
        SET v_vin = CONCAT('1ES', UPPER(LEFT(MD5(CONCAT(v_plate, v_owner, NOW())), 14)));
        
        UPDATE owned_vehicles 
        SET vin = v_vin 
        WHERE plate = v_plate AND owner = v_owner;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- Create a table to track VIN history (optional, for audit purposes)
CREATE TABLE IF NOT EXISTS `vehicle_vin_history` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `vin` VARCHAR(17) NOT NULL,
    `plate` VARCHAR(12) NOT NULL,
    `owner` VARCHAR(60) NOT NULL,
    `action` ENUM('created', 'transferred', 'deleted') NOT NULL,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `details` JSON DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_vin_history` (`vin`),
    INDEX `idx_plate_history` (`plate`),
    INDEX `idx_owner_history` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add trigger to log VIN changes (optional)
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS `log_vin_creation`
AFTER INSERT ON `owned_vehicles`
FOR EACH ROW
BEGIN
    IF NEW.vin IS NOT NULL THEN
        INSERT INTO `vehicle_vin_history` (`vin`, `plate`, `owner`, `action`, `details`)
        VALUES (NEW.vin, NEW.plate, NEW.owner, 'created', JSON_OBJECT('type', NEW.type, 'stored', NEW.stored));
    END IF;
END$$

CREATE TRIGGER IF NOT EXISTS `log_vin_transfer`
AFTER UPDATE ON `owned_vehicles`
FOR EACH ROW
BEGIN
    IF OLD.owner != NEW.owner AND NEW.vin IS NOT NULL THEN
        INSERT INTO `vehicle_vin_history` (`vin`, `plate`, `owner`, `action`, `details`)
        VALUES (NEW.vin, NEW.plate, NEW.owner, 'transferred', JSON_OBJECT('previous_owner', OLD.owner, 'new_owner', NEW.owner));
    END IF;
END$$

DELIMITER ;

-- Migration notes:
-- 1. Run this script to add VIN support to your database
-- 2. Restart your server to load the new VIN module
-- 3. Optionally run CALL GenerateVINsForExistingVehicles(); to generate VINs for existing vehicles
-- 4. After all vehicles have VINs, you can add the unique constraint