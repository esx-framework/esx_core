USE `es_extended`;

CREATE TABLE `billing` (
	`id` int NOT NULL AUTO_INCREMENT,
	`identifier` varchar(60) NOT NULL,
	`sender` varchar(60) NOT NULL,
	`target_type` varchar(50) NOT NULL,
	`target` varchar(60) NOT NULL,
	`label` varchar(255) NOT NULL,
	`amount` int NOT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

