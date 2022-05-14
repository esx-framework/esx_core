USE `es_extended`;

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('beer', 'Pivo', 1)
;

INSERT INTO `shops` (store, item, price) VALUES
	('TwentyFourSeven', 'beer', 45),
	('RobsLiquor', 'beer', 45),
	('LTDgasoline', 'beer', 45)
;
