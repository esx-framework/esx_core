-- ESX Whitelist System Database Tables
-- Note: These tables are created automatically by the script
-- This file is provided for manual setup or debugging purposes only

CREATE TABLE IF NOT EXISTS `whitelist` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_name` VARCHAR(255) COLLATE utf8mb4_unicode_ci,
    `whitelisted` TINYINT(1) NOT NULL DEFAULT 0,
    `added_by` VARCHAR(255) COLLATE utf8mb4_unicode_ci,
    `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `whitelist_identifiers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `whitelist_id` INT NOT NULL,
    `type` ENUM('steam', 'license', 'discord', 'xbl', 'live', 'fivem') NOT NULL,
    `identifier` VARCHAR(255) NOT NULL COLLATE utf8mb4_bin,
    FOREIGN KEY (`whitelist_id`) REFERENCES `whitelist`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_identifier` (`type`, `identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes for better performance
CREATE INDEX `idx_whitelisted` ON `whitelist`(`whitelisted`);
CREATE INDEX `idx_whitelist_id` ON `whitelist_identifiers`(`whitelist_id`);
CREATE INDEX `idx_identifier` ON `whitelist_identifiers`(`identifier`);