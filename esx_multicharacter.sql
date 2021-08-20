CREATE TABLE `multicharacter_slots` (
	`identifier` VARCHAR(60) NOT NULL,
	`slots` INT NOT NULL
);

ALTER TABLE `users` 
	ADD `disabled` BIT NOT NULL DEFAULT 0;