USE `essentialmode`;

CREATE TABLE `characters` (

	`identifier` varchar(255) NOT NULL,
	`firstname` varchar(255) NOT NULL,
	`lastname` varchar(255) NOT NULL,
	`dateofbirth` varchar(255) NOT NULL,
	`sex` varchar(1) NOT NULL DEFAULT 'f',
	`height` varchar(128) NOT NULL
);
