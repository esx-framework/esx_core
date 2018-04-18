USE `essentialmode`;

ALTER TABLE `users`
	ADD COLUMN `firstname` VARCHAR(50) NULL DEFAULT '',
	ADD COLUMN `lastname` VARCHAR(50) NULL DEFAULT '',
	ADD COLUMN `dateofbirth` VARCHAR(25) NULL DEFAULT '',
	ADD COLUMN `sex` VARCHAR(10) NULL DEFAULT '',
	ADD COLUMN `height` VARCHAR(5) NULL DEFAULT ''
;

CREATE TABLE `characters` (
	`identifier` varchar(255) NOT NULL,
	`firstname` varchar(255) NOT NULL,
	`lastname` varchar(255) NOT NULL,
	`dateofbirth` varchar(255) NOT NULL,
	`sex` varchar(1) NOT NULL DEFAULT 'f',
	`height` varchar(128) NOT NULL
);
