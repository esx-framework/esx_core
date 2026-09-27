-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

CREATE TABLE IF NOT EXISTS `esx_whitelist` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `player_name` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    `whitelisted` TINYINT(1) NOT NULL DEFAULT 0,
    `added_by` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_esx_whitelist_whitelisted_id` (`whitelisted`, `id`),
    KEY `idx_esx_whitelist_name_id` (`player_name`(180), `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `esx_whitelist_identifier` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `whitelist_id` INT UNSIGNED NOT NULL,
    `type` VARCHAR(32) NOT NULL,
    `identifier` VARCHAR(255) NOT NULL COLLATE utf8mb4_bin,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_esx_whitelist_identifier` (`identifier`),
    KEY `idx_esx_whitelist_identifier_whitelist_id` (`whitelist_id`),
    CONSTRAINT `fk_esx_whitelist_identifier_esx_whitelist`
        FOREIGN KEY (`whitelist_id`) REFERENCES `esx_whitelist` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
