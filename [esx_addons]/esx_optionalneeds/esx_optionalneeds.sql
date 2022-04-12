USE `es_extended`;

CREATE TABLE `shops` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`store` varchar(100) NOT NULL,
	`item` varchar(100) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('beer', 'Beer', 1)
;

INSERT INTO `shops` (store, item, price) VALUES
	('TwentyFourSeven', 'beer', 45),
	('RobsLiquor', 'beer', 45),
	('LTDgasoline', 'beer', 45)
;
