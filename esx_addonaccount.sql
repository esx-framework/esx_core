USE `essentialmode`;

CREATE TABLE `addon_account` (
	`name` VARCHAR(60) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`shared` INT(11) NOT NULL,

	PRIMARY KEY (`name`)
);

CREATE TABLE `addon_account_data` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`account_name` VARCHAR(100) DEFAULT NULL,
	`money` INT(11) NOT NULL,
	`owner` VARCHAR(40) DEFAULT NULL,

	PRIMARY KEY (`id`),
	UNIQUE INDEX `index_addon_account_data_account_name_owner` (`account_name`, `owner`),
	INDEX `index_addon_account_data_account_name` (`account_name`)
);
