CREATE TABLE `multicharacter_slots` (
	`identifier` VARCHAR(60) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`slots` INT(11) NOT NULL,
	PRIMARY KEY (`identifier`) USING BTREE,
	INDEX `slots` (`slots`) USING BTREE
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
;

ALTER TABLE `users` ADD COLUMN
	`disabled` TINYINT(1) NULL DEFAULT '0'
;
