USE `essentialmode`;

ALTER TABLE `users`
	ADD COLUMN `name` VARCHAR(50) NULL DEFAULT '' AFTER `money`,
	ADD COLUMN `skin` LONGTEXT NULL AFTER `name`,
	ADD COLUMN `job` VARCHAR(50) NULL DEFAULT 'unemployed' AFTER `skin`,
	ADD COLUMN `job_grade` INT NULL DEFAULT 0 AFTER `job`,
	ADD COLUMN `loadout` LONGTEXT NULL AFTER `job_grade`,
	ADD COLUMN `position` VARCHAR(36) NULL AFTER `loadout`
;

CREATE TABLE `items` (
	`name` VARCHAR(50) NOT NULL,
	`label` VARCHAR(50) NOT NULL,
	`weight` INT(11) NOT NULL DEFAULT 1,
	`rare` TINYINT(1) NOT NULL DEFAULT 0,
	`can_remove` TINYINT(1) NOT NULL DEFAULT 1,

	PRIMARY KEY (`name`)
);

CREATE TABLE `job_grades` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job_name` VARCHAR(50) DEFAULT NULL,
	`grade` INT(11) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`label` VARCHAR(50) NOT NULL,
	`salary` INT(11) NOT NULL,
	`skin_male` LONGTEXT NOT NULL,
	`skin_female` LONGTEXT NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `job_grades` VALUES (1,'unemployed',0,'unemployed','Unemployed',200,'{}','{}');

CREATE TABLE `jobs` (
	`name` VARCHAR(50) NOT NULL,
	`label` VARCHAR(50) DEFAULT NULL,

	PRIMARY KEY (`name`)
);

INSERT INTO `jobs` VALUES ('unemployed','Unemployed');

CREATE TABLE `user_accounts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(22) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`money` INT(11) NOT NULL DEFAULT '0',

	PRIMARY KEY (`id`)
);

CREATE TABLE `user_inventory` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(22) NOT NULL,
	`item` VARCHAR(50) NOT NULL,
	`count` INT(11) NOT NULL,

	PRIMARY KEY (`id`)
);
