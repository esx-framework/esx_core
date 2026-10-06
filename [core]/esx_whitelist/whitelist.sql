-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

CREATE TABLE IF NOT EXISTS `esx_whitelist_config` (
  `setting_key` VARCHAR(64) NOT NULL,
  `setting_value` LONGTEXT NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `esx_whitelist_identifiers` (
  `identifier` VARCHAR(128) NOT NULL,
  `type` VARCHAR(32) NOT NULL DEFAULT 'whitelist',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`identifier`, `type`),
  KEY `idx_type` (`type`),
  KEY `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `esx_whitelist_admin` (
  `identifier` VARCHAR(128) NOT NULL,
  `group_name` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`identifier`),
  KEY `idx_group_name` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `esx_whitelist_discord` (
  `user_id` VARCHAR(32) NOT NULL,
  `allowed` TINYINT(1) NOT NULL,
  `status` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
