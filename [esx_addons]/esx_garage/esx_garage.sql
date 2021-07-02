USE `es_extended`;

CREATE TABLE `user_parkings` (
  
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) DEFAULT NULL,
  `garage` varchar(60) DEFAULT NULL,
  `zone` int(11) NOT NULL,
  `vehicle` longtext,

  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

