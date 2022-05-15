
-- Dumping structure for table legacy.banking
CREATE TABLE IF NOT EXISTS `banking` (
  `identifier` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `amount` int(64) DEFAULT NULL,
  `time` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
