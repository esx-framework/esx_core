USE `essentialmode`;

CREATE TABLE `billing` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`identifier` varchar(255) NOT NULL,
	`sender` varchar(255) NOT NULL,
	`target_type` varchar(50) NOT NULL,
	`target` varchar(255) NOT NULL,
	`label` varchar(255) NOT NULL,
	`amount` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);
