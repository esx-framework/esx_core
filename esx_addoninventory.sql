USE `essentialmode`;

CREATE TABLE `addon_inventory` (
	`name` VARCHAR(60) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`shared` INT(11) NOT NULL,

	PRIMARY KEY (`name`)
);

CREATE TABLE `addon_inventory_items` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`inventory_name` VARCHAR(100) NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`count` INT(11) NOT NULL,
	`owner` VARCHAR(60) DEFAULT NULL,

	PRIMARY KEY (`id`),
	INDEX `index_addon_inventory_items_inventory_name_name` (`inventory_name`, `name`),
	INDEX `index_addon_inventory_items_inventory_name_name_owner` (`inventory_name`, `name`, `owner`),
	INDEX `index_addon_inventory_inventory_name` (`inventory_name`)
);