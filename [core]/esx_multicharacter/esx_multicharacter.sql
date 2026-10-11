-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

CREATE TABLE `multicharacter_slots` (
	`identifier` VARCHAR(60) NOT NULL,
	`slots` INT(11) NOT NULL,
	PRIMARY KEY (`identifier`) USING BTREE,
	INDEX `slots` (`slots`) USING BTREE
) ENGINE=InnoDB;

ALTER TABLE `users` ADD COLUMN
	`disabled` TINYINT(1) NULL DEFAULT '0';
