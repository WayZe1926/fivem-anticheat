CREATE TABLE IF NOT EXISTS `ac_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(64) DEFAULT NULL,
  `steam` VARCHAR(64) DEFAULT NULL,
  `discord` VARCHAR(64) DEFAULT NULL,
  `player_name` VARCHAR(64) DEFAULT NULL,
  `reason` VARCHAR(64) NOT NULL,
  `evidence` LONGTEXT,
  `severity` VARCHAR(16) DEFAULT 'warn',
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `license_idx` (`license`),
  KEY `reason_idx` (`reason`),
  KEY `created_idx` (`created_at`)
);

CREATE TABLE IF NOT EXISTS `ac_bans` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(64) DEFAULT NULL,
  `steam` VARCHAR(64) DEFAULT NULL,
  `discord` VARCHAR(64) DEFAULT NULL,
  `reason` VARCHAR(128) NOT NULL,
  `banned_by` VARCHAR(64) DEFAULT 'system',
  `expires_at` DATETIME DEFAULT NULL,
  `banned_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_unique` (`license`)
);

CREATE TABLE IF NOT EXISTS `ac_actions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(64) DEFAULT NULL,
  `player_name` VARCHAR(64) DEFAULT NULL,
  `action` VARCHAR(32) NOT NULL,
  `reason` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`)
);

-- demo table for SafeTransaction examples (optional)
CREATE TABLE IF NOT EXISTS `ac_demo_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(64) NOT NULL,
  `money` INT DEFAULT 0,
  `inventory` JSON DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_unique` (`license`)
);
