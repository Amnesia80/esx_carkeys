CREATE TABLE `owned_keys` (
	`id` int NOT NULL AUTO_INCREMENT,
	`plate` VARCHAR(50) NOT NULL,
	`owner` VARCHAR(22) NOT NULL,

	PRIMARY KEY (`id`)
);