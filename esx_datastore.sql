USE `essentialmode`;

CREATE TABLE `datastore` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`label` varchar(255) NOT NULL,
	`shared` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `datastore_data` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(60) NOT NULL,
	`owner` varchar(60),
	`data` longtext,

	INDEX index_datastore_name (`name`),
	CONSTRAINT unique_datastore_owner_name UNIQUE (`owner`, `name`),

	PRIMARY KEY (`id`)
);
