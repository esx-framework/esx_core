CREATE TABLE `user_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `number` int(11) NOT NULL
);

ALTER TABLE `user_contacts` ADD PRIMARY KEY (`id`);

ALTER TABLE `users` 
ADD COLUMN `phone_number` INT NULL AFTER `position`;
