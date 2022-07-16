

CREATE TABLE `user_contacts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(60) NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`number` INT(11) NOT NULL,

	PRIMARY KEY (`id`),
	INDEX `index_user_contacts_identifier_name_number` (`identifier`, `name`, `number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE `users`
	ADD COLUMN `phone_number` INT(11) NULL,
	ADD UNIQUE INDEX `index_users_phone_number` (`phone_number`);