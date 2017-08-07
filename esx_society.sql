USE `essentialmode`;

CREATE TABLE `society_moneywash` (
  
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `society` varchar(60) NOT NULL,
  `amount` int(11) NOT NULL,
  
  PRIMARY KEY (`id`)
);
