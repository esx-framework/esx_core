USE `essentialmode`;

CREATE TABLE `datastore` (
	`name` VARCHAR(60) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`shared` INT(11) NOT NULL,

	PRIMARY KEY (`name`)
);

CREATE TABLE `datastore_data` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(60) NOT NULL,
	`owner` VARCHAR(60),
	`data` LONGTEXT,

	PRIMARY KEY (`id`),
	UNIQUE INDEX `index_datastore_data_name_owner` (`name`, `owner`),
	INDEX `index_datastore_data_name` (`name`)
);
