CREATE TABLE IF NOT EXISTS `rnotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `noteid` varchar(50) NOT NULL DEFAULT '0',
  `citizenid` varchar(50) NOT NULL DEFAULT '0',
  `notes` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;