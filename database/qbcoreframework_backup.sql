/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.5-MariaDB, for Win64 (AMD64)
--
-- Host: 127.0.0.1    Database: qbcoreframework
-- ------------------------------------------------------
-- Server version	11.4.5-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `apartments`
--

DROP TABLE IF EXISTS `apartments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `apartments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `citizenid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4146 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apartments`
--

LOCK TABLES `apartments` WRITE;
/*!40000 ALTER TABLE `apartments` DISABLE KEYS */;
INSERT INTO `apartments` VALUES
(4144,'apartment3219775','apartment3','Integrity Way 219775','FEZ03578'),
(4145,'apartment5934725','apartment5','Fantastic Plaza 934725','JRM45973');
/*!40000 ALTER TABLE `apartments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_accounts`
--

DROP TABLE IF EXISTS `bank_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `account_name` varchar(50) DEFAULT NULL,
  `account_balance` int(11) NOT NULL DEFAULT 0,
  `account_type` enum('shared','job','gang') NOT NULL,
  `users` longtext DEFAULT '[]',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `account_name` (`account_name`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_accounts`
--

LOCK TABLES `bank_accounts` WRITE;
/*!40000 ALTER TABLE `bank_accounts` DISABLE KEYS */;
INSERT INTO `bank_accounts` VALUES
(1,NULL,'trucker',0,'job','[]'),
(2,NULL,'tow',0,'job','[]'),
(3,NULL,'bennys',0,'job','[]'),
(4,NULL,'police',0,'job','[]'),
(5,NULL,'ambulance',2000,'job','[]'),
(6,NULL,'bus',0,'job','[]'),
(7,NULL,'mechanic3',0,'job','[]'),
(8,NULL,'judge',0,'job','[]'),
(9,NULL,'beeker',0,'job','[]'),
(10,NULL,'mechanic2',0,'job','[]'),
(11,NULL,'mechanic',0,'job','[]'),
(12,NULL,'hotdog',0,'job','[]'),
(13,NULL,'reporter',0,'job','[]'),
(14,NULL,'taxi',0,'job','[]'),
(15,NULL,'realestate',0,'job','[]'),
(16,NULL,'garbage',0,'job','[]'),
(17,NULL,'unemployed',0,'job','[]'),
(18,NULL,'vineyard',0,'job','[]'),
(19,NULL,'cardealer',0,'job','[]'),
(20,NULL,'lawyer',0,'job','[]'),
(21,NULL,'lumberjack',0,'job','[]'),
(22,NULL,'dealership_sandy',0,'job','[]'),
(23,NULL,'cards_courier',0,'job','[]'),
(24,NULL,'content_creator',0,'job','[]'),
(25,NULL,'wine_sommelier',0,'job','[]'),
(26,NULL,'food_critic',0,'job','[]'),
(27,NULL,'wildlife_ranger',0,'job','[]'),
(28,NULL,'waiter',0,'job','[]'),
(29,NULL,'dealership_sur',0,'job','[]'),
(30,NULL,'dealership_paleto',0,'job','[]'),
(31,NULL,'electrician',0,'job','[]'),
(32,NULL,'pizza',0,'job','[]'),
(33,NULL,'farmer',0,'job','[]'),
(34,NULL,'diver',0,'job','[]'),
(35,NULL,'delivery',0,'job','[]'),
(36,NULL,'security',0,'job','[]'),
(37,NULL,'windowcleaner',0,'job','[]'),
(38,NULL,'fisherman',0,'job','[]'),
(39,NULL,'miner',0,'job','[]'),
(40,NULL,'vintage_picker',0,'job','[]'),
(41,NULL,'gardener',0,'job','[]');
/*!40000 ALTER TABLE `bank_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_statements`
--

DROP TABLE IF EXISTS `bank_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_statements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `account_name` varchar(50) DEFAULT 'checking',
  `amount` int(11) DEFAULT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `statement_type` enum('deposit','withdraw') DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_statements`
--

LOCK TABLES `bank_statements` WRITE;
/*!40000 ALTER TABLE `bank_statements` DISABLE KEYS */;
INSERT INTO `bank_statements` VALUES
(1,NULL,'ambulance',2000,'Player treatment','deposit','2026-09-22 16:45:29');
/*!40000 ALTER TABLE `bank_statements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bans`
--

DROP TABLE IF EXISTS `bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bans`
--

LOCK TABLES `bans` WRITE;
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crypto`
--

DROP TABLE IF EXISTS `crypto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `crypto` (
  `crypto` varchar(50) NOT NULL DEFAULT 'qbit',
  `worth` int(11) NOT NULL DEFAULT 0,
  `history` text DEFAULT NULL,
  PRIMARY KEY (`crypto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crypto`
--

LOCK TABLES `crypto` WRITE;
/*!40000 ALTER TABLE `crypto` DISABLE KEYS */;
INSERT INTO `crypto` VALUES
('qbit',983,'[{\"NewWorth\":989,\"PreviousWorth\":994},{\"NewWorth\":989,\"PreviousWorth\":994},{\"NewWorth\":989,\"PreviousWorth\":994},{\"NewWorth\":983,\"PreviousWorth\":989}]');
/*!40000 ALTER TABLE `crypto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crypto_transactions`
--

DROP TABLE IF EXISTS `crypto_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `crypto_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `message` varchar(50) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crypto_transactions`
--

LOCK TABLES `crypto_transactions` WRITE;
/*!40000 ALTER TABLE `crypto_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `crypto_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dealers`
--

DROP TABLE IF EXISTS `dealers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dealers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `time` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `createdby` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dealers`
--

LOCK TABLES `dealers` WRITE;
/*!40000 ALTER TABLE `dealers` DISABLE KEYS */;
/*!40000 ALTER TABLE `dealers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dealership_stock`
--

DROP TABLE IF EXISTS `dealership_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dealership_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `brand` varchar(50) DEFAULT 'Ocasi+¶n',
  `category` varchar(50) DEFAULT 'sports',
  `plate` varchar(15) NOT NULL,
  `price` int(11) NOT NULL,
  `mods` longtext DEFAULT '{}',
  `seller_citizenid` varchar(50) DEFAULT NULL,
  `seller_name` varchar(100) DEFAULT 'Particular',
  `date_added` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `dealership` (`dealership`),
  KEY `plate` (`plate`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dealership_stock`
--

LOCK TABLES `dealership_stock` WRITE;
/*!40000 ALTER TABLE `dealership_stock` DISABLE KEYS */;
INSERT INTO `dealership_stock` VALUES
(1,'dealership_sur','elegy2','Annis Elegy Retro Custom','Annis','sports','SUR 0110',89000,'{}',NULL,'Particular','2026-09-25 11:35:49'),
(2,'dealership_sur','sultan','Karin Sultan RS','Karin','sports','SUR 0220',39000,'{}',NULL,'Particular','2026-09-25 11:35:49'),
(3,'dealership_sur','schafter2','Benefactor Schafter V12','Benefactor','sedans','SUR 0330',36000,'{}',NULL,'Empresa VTC','2026-09-25 11:35:49'),
(4,'dealership_sandy','sandking','Vapid Sandking XL Monster','Vapid','suvs','SND 4040',38000,'{}',NULL,'Rancho Desert','2026-09-25 11:35:49'),
(5,'dealership_sandy','kamacho','Canis Kamacho All-Terrain','Canis','suvs','SND 5050',49000,'{}',NULL,'Cazador Local','2026-09-25 11:35:49'),
(6,'dealership_sandy','sanchez','Maibatsu Sanchez Motocross','Maibatsu','bikes','SND 6060',11500,'{}',NULL,'Circuito Cross','2026-09-25 11:35:49'),
(7,'dealership_paleto','dubsta','Benefactor Dubsta Luxury 4x4','Benefactor','suvs','PLT 7070',58000,'{}',NULL,'Turista','2026-09-25 11:35:49'),
(8,'dealership_paleto','tailgater','Obey Tailgater Ejecutivo','Obey','sedans','PLT 8080',29500,'{}',NULL,'Empresario Norte','2026-09-25 11:35:49'),
(9,'dealership_paleto','kuruma','Karin Kuruma Sport','Karin','sports','PLT 9090',52000,'{}',NULL,'Particular','2026-09-25 11:35:49');
/*!40000 ALTER TABLE `dealership_stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dpkeybinds`
--

DROP TABLE IF EXISTS `dpkeybinds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dpkeybinds` (
  `id` varchar(50) DEFAULT NULL,
  `keybind1` varchar(50) DEFAULT 'num4',
  `emote1` varchar(255) DEFAULT '',
  `keybind2` varchar(50) DEFAULT 'num5',
  `emote2` varchar(255) DEFAULT '',
  `keybind3` varchar(50) DEFAULT 'num6',
  `emote3` varchar(255) DEFAULT '',
  `keybind4` varchar(50) DEFAULT 'num7',
  `emote4` varchar(255) DEFAULT '',
  `keybind5` varchar(50) DEFAULT 'num8',
  `emote5` varchar(255) DEFAULT '',
  `keybind6` varchar(50) DEFAULT 'num9',
  `emote6` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dpkeybinds`
--

LOCK TABLES `dpkeybinds` WRITE;
/*!40000 ALTER TABLE `dpkeybinds` DISABLE KEYS */;
INSERT INTO `dpkeybinds` VALUES
('license:b43e4e1ff76ba7f9c6d7a3c303fab5c0a1e73c23','num4','','num5','','num6','','num7','','num8','','num9',''),
('license:0c4a18f627ba6fe1994b23c97f950fa9b21da4f9','num4','','num5','','num6','','num7','','num8','','num9',''),
('license:bfbec128540832cf3ed84f70b6de846e123b9512','num4','','num5','','num6','','num7','','num8','','num9','');
/*!40000 ALTER TABLE `dpkeybinds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `house_plants`
--

DROP TABLE IF EXISTS `house_plants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `house_plants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `building` varchar(50) DEFAULT NULL,
  `stage` int(11) DEFAULT 1,
  `sort` varchar(50) DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `food` int(11) DEFAULT 100,
  `health` int(11) DEFAULT 100,
  `progress` int(11) DEFAULT 0,
  `coords` text DEFAULT NULL,
  `plantid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `building` (`building`),
  KEY `plantid` (`plantid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `house_plants`
--

LOCK TABLES `house_plants` WRITE;
/*!40000 ALTER TABLE `house_plants` DISABLE KEYS */;
/*!40000 ALTER TABLE `house_plants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `houselocations`
--

DROP TABLE IF EXISTS `houselocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `houselocations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `coords` text DEFAULT NULL,
  `owned` tinyint(2) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `tier` tinyint(4) DEFAULT NULL,
  `garage` text NOT NULL DEFAULT '{"y":0,"x":0,"w":0,"z":0}',
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `houselocations`
--

LOCK TABLES `houselocations` WRITE;
/*!40000 ALTER TABLE `houselocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `houselocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventories`
--

DROP TABLE IF EXISTS `inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`identifier`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventories`
--

LOCK TABLES `inventories` WRITE;
/*!40000 ALTER TABLE `inventories` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lapraces`
--

DROP TABLE IF EXISTS `lapraces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `lapraces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `checkpoints` text DEFAULT NULL,
  `records` text DEFAULT NULL,
  `creator` varchar(50) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `raceid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lapraces`
--

LOCK TABLES `lapraces` WRITE;
/*!40000 ALTER TABLE `lapraces` DISABLE KEYS */;
/*!40000 ALTER TABLE `lapraces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_fines`
--

DROP TABLE IF EXISTS `mdt_fines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mdt_fines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `target_name` varchar(100) NOT NULL,
  `amount` int(11) NOT NULL,
  `reason` text NOT NULL,
  `jail` int(11) DEFAULT 0,
  `officer` varchar(100) NOT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_fines`
--

LOCK TABLES `mdt_fines` WRITE;
/*!40000 ALTER TABLE `mdt_fines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_fines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_warrants`
--

DROP TABLE IF EXISTS `mdt_warrants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `danger` varchar(50) DEFAULT 'Media',
  `officer` varchar(100) NOT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_warrants`
--

LOCK TABLES `mdt_warrants` WRITE;
/*!40000 ALTER TABLE `mdt_warrants` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_warrants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `occasion_vehicles`
--

DROP TABLE IF EXISTS `occasion_vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `occasion_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller` varchar(50) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `mods` text DEFAULT NULL,
  `occasionid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `occasionId` (`occasionid`)
) ENGINE=InnoDB AUTO_INCREMENT=325 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `occasion_vehicles`
--

LOCK TABLES `occasion_vehicles` WRITE;
/*!40000 ALTER TABLE `occasion_vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `occasion_vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phone_gallery`
--

DROP TABLE IF EXISTS `phone_gallery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phone_gallery` (
  `citizenid` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phone_gallery`
--

LOCK TABLES `phone_gallery` WRITE;
/*!40000 ALTER TABLE `phone_gallery` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_gallery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phone_invoices`
--

DROP TABLE IF EXISTS `phone_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phone_invoices` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `society` tinytext DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `sendercitizenid` varchar(50) DEFAULT NULL,
  `candecline` int(1) NOT NULL DEFAULT 1,
  `reason` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phone_invoices`
--

LOCK TABLES `phone_invoices` WRITE;
/*!40000 ALTER TABLE `phone_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phone_messages`
--

DROP TABLE IF EXISTS `phone_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `messages` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `number` (`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phone_messages`
--

LOCK TABLES `phone_messages` WRITE;
/*!40000 ALTER TABLE `phone_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phone_tweets`
--

DROP TABLE IF EXISTS `phone_tweets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phone_tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `firstName` varchar(25) DEFAULT NULL,
  `lastName` varchar(25) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `date` datetime DEFAULT current_timestamp(),
  `url` text DEFAULT NULL,
  `picture` text DEFAULT './img/default.png',
  `tweetId` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phone_tweets`
--

LOCK TABLES `phone_tweets` WRITE;
/*!40000 ALTER TABLE `phone_tweets` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_tweets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_contacts`
--

DROP TABLE IF EXISTS `player_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_contacts`
--

LOCK TABLES `player_contacts` WRITE;
/*!40000 ALTER TABLE `player_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_houses`
--

DROP TABLE IF EXISTS `player_houses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_houses` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `house` varchar(50) NOT NULL,
  `identifier` varchar(50) DEFAULT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  `keyholders` text DEFAULT NULL,
  `decorations` text DEFAULT NULL,
  `stash` text DEFAULT NULL,
  `outfit` text DEFAULT NULL,
  `logout` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `house` (`house`),
  KEY `citizenid` (`citizenid`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_houses`
--

LOCK TABLES `player_houses` WRITE;
/*!40000 ALTER TABLE `player_houses` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_houses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_mails`
--

DROP TABLE IF EXISTS `player_mails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_mails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `read` tinyint(4) DEFAULT 0,
  `mailid` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `button` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_mails`
--

LOCK TABLES `player_mails` WRITE;
/*!40000 ALTER TABLE `player_mails` DISABLE KEYS */;
INSERT INTO `player_mails` VALUES
(1,'FEZ03578','Pillbox Hospital','Hospital Costs','Dear Mr. Galvez, <br /><br />Hereby you received an email with the costs of the last hospital visit.<br />The final costs have become: <strong>$2000</strong><br /><br />We wish you a quick recovery!',0,861968,'2026-09-22 16:45:33','[]');
/*!40000 ALTER TABLE `player_mails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_outfits`
--

DROP TABLE IF EXISTS `player_outfits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `outfitname` varchar(50) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `skin` text DEFAULT NULL,
  `outfitId` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `outfitId` (`outfitId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_outfits`
--

LOCK TABLES `player_outfits` WRITE;
/*!40000 ALTER TABLE `player_outfits` DISABLE KEYS */;
INSERT INTO `player_outfits` VALUES
(1,'ADE24479','diablo','1885233650','{\"chimp_bone_width\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"nose_5\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"pants\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":7},\"t-shirt\":{\"defaultTexture\":0,\"defaultItem\":1,\"texture\":3,\"item\":30},\"blush\":{\"defaultTexture\":1,\"defaultItem\":-1,\"texture\":1,\"item\":-1},\"facemix\":{\"defaultShapeMix\":0.0,\"defaultSkinMix\":0.0,\"shapeMix\":0.0,\"skinMix\":0.0},\"chimp_hole\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"mask\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":3},\"arms\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":2,\"item\":208},\"cheek_2\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"shoes\":{\"defaultTexture\":0,\"defaultItem\":1,\"texture\":0,\"item\":6},\"vest\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"nose_0\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"hair\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"beard\":{\"defaultTexture\":1,\"defaultItem\":-1,\"texture\":1,\"item\":-1},\"decals\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":4},\"bracelet\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"cheek_1\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"lipstick\":{\"defaultTexture\":1,\"defaultItem\":-1,\"texture\":1,\"item\":-1},\"hat\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"lips_thickness\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"bag\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"neck_thikness\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"ageing\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"eye_color\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"face\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":4,\"item\":4},\"jaw_bone_width\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"accessory\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":2},\"eyebrown_forward\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"moles\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"torso2\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":3,\"item\":6},\"chimp_bone_lowering\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"watch\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"nose_1\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"eyebrows\":{\"defaultTexture\":1,\"defaultItem\":-1,\"texture\":1,\"item\":-1},\"eyebrown_high\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"ear\":{\"defaultTexture\":0,\"defaultItem\":-1,\"texture\":0,\"item\":-1},\"face2\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":4},\"chimp_bone_lenght\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"jaw_bone_back_lenght\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"cheek_3\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"nose_4\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"makeup\":{\"defaultTexture\":1,\"defaultItem\":-1,\"texture\":1,\"item\":-1},\"eye_opening\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"glass\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"nose_3\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0},\"nose_2\":{\"defaultTexture\":0,\"defaultItem\":0,\"texture\":0,\"item\":0}}','outfit-10-5313');
/*!40000 ALTER TABLE `player_outfits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_vehicles`
--

DROP TABLE IF EXISTS `player_vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) DEFAULT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `hash` varchar(50) DEFAULT NULL,
  `mods` longtext DEFAULT NULL,
  `plate` varchar(50) NOT NULL,
  `fakeplate` varchar(50) DEFAULT NULL,
  `garage` varchar(50) DEFAULT NULL,
  `fuel` int(11) DEFAULT 100,
  `engine` float DEFAULT 1000,
  `body` float DEFAULT 1000,
  `state` int(11) DEFAULT 1,
  `depotprice` int(11) NOT NULL DEFAULT 0,
  `drivingdistance` int(50) DEFAULT NULL,
  `status` text DEFAULT NULL,
  `balance` int(11) NOT NULL DEFAULT 0,
  `paymentamount` int(11) NOT NULL DEFAULT 0,
  `paymentsleft` int(11) NOT NULL DEFAULT 0,
  `financetime` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_playervehicles_plate` (`plate`),
  KEY `plate` (`plate`),
  KEY `citizenid` (`citizenid`),
  KEY `license` (`license`),
  CONSTRAINT `FK_playervehicles_players` FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_vehicles`
--

LOCK TABLES `player_vehicles` WRITE;
/*!40000 ALTER TABLE `player_vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES
(31,'ADE24479',2,'license:b43e4e1ff76ba7f9c6d7a3c303fab5c0a1e73c23','vwrz8269','{\"crypto\":0,\"bank\":5020,\"cash\":500}','{\"account\":\"US08QBCore1278709441\",\"gender\":0,\"cid\":2,\"lastname\":\"Pedregal\",\"firstname\":\"Jaime\",\"phone\":\"3585676301\",\"birthdate\":\"2026-09-22\",\"nationality\":\"+‡land Islands\"}','{\"payment\":10,\"name\":\"unemployed\",\"type\":\"none\",\"label\":\"Civilian\",\"onduty\":true,\"isboss\":false,\"grade\":{\"level\":0,\"name\":\"Freelancer\"}}','{\"label\":\"No Gang Affiliation\",\"name\":\"none\",\"isboss\":false,\"grade\":{\"level\":0,\"name\":\"none\"}}','{\"x\":-854.1758422851563,\"y\":-2472.712158203125,\"z\":13.980224609375}','{\"isdead\":false,\"phonedata\":{\"SerialNumber\":46627952,\"InstalledApps\":[]},\"rep\":[],\"thirst\":88.60000000000001,\"inlaststand\":false,\"licences\":{\"weapon\":false,\"driver\":true,\"business\":false},\"vehicleKeys\":{\"03DTG734\":true},\"criminalrecord\":{\"hasRecord\":false},\"stress\":0,\"jailitems\":[],\"ishandcuffed\":false,\"injail\":0,\"tracker\":false,\"callsign\":\"NO CALLSIGN\",\"status\":[],\"inside\":{\"apartment\":[]},\"fingerprint\":\"Nf519V45SzI8327\",\"armor\":0,\"bloodtype\":\"O-\",\"phone\":[],\"hunger\":87.39999999999999,\"walletid\":\"QB-33342031\"}','[{\"amount\":1,\"slot\":1,\"type\":\"item\",\"name\":\"id_card\",\"info\":{\"gender\":0,\"citizenid\":\"ADE24479\",\"birthdate\":\"2026-09-22\",\"firstname\":\"Jaime\",\"lastname\":\"Pedregal\",\"nationality\":\"+‡land Islands\"}},{\"amount\":1,\"slot\":2,\"type\":\"item\",\"name\":\"phone\",\"info\":[]},{\"amount\":1,\"slot\":3,\"type\":\"item\",\"name\":\"driver_license\",\"info\":{\"birthdate\":\"2026-09-22\",\"firstname\":\"Jaime\",\"lastname\":\"Pedregal\",\"type\":\"Class C Driver License\"}}]','2026-09-22 20:26:06'),
(1,'FEZ03578',1,'license:b43e4e1ff76ba7f9c6d7a3c303fab5c0a1e73c23','vwrz8269','{\"crypto\":0,\"bank\":3060,\"cash\":500}','{\"phone\":\"1378416509\",\"birthdate\":\"2026-09-22\",\"lastname\":\"Galvez\",\"nationality\":\"Argentina\",\"account\":\"US01QBCore4447723097\",\"firstname\":\"Raul\",\"gender\":0,\"cid\":1}','{\"payment\":10,\"onduty\":true,\"grade\":{\"payment\":10,\"isboss\":false,\"name\":\"Freelancer\",\"level\":0},\"label\":\"Civilian\",\"type\":\"none\",\"name\":\"unemployed\",\"isboss\":false}','{\"label\":\"Cartel\",\"isboss\":true,\"name\":\"cartel\",\"grade\":{\"isboss\":true,\"name\":\"Boss\",\"level\":3}}','{\"x\":224.04396057128907,\"y\":-792.0791015625,\"z\":30.6951904296875}','{\"fingerprint\":\"VX984i66FOt1121\",\"inside\":{\"apartment\":[]},\"jailitems\":[],\"hunger\":95.8,\"bloodtype\":\"AB+\",\"stress\":0,\"callsign\":\"NO CALLSIGN\",\"injail\":0,\"walletid\":\"QB-87505508\",\"vehicleKeys\":{\"87YIM239\":true},\"licences\":{\"business\":false,\"weapon\":false,\"driver\":true},\"thirst\":96.2,\"isdead\":false,\"phone\":[],\"criminalrecord\":{\"hasRecord\":false},\"tracker\":false,\"inlaststand\":false,\"ishandcuffed\":false,\"rep\":[],\"status\":[],\"armor\":0,\"currentapartment\":\"apartment3219775\",\"phonedata\":{\"InstalledApps\":[],\"SerialNumber\":80842504}}','[]','2026-09-22 20:43:45'),
(16,'JRM45973',1,'license:0c4a18f627ba6fe1994b23c97f950fa9b21da4f9','SleepyLizard9074','{\"crypto\":0,\"cash\":500,\"bank\":5030}','{\"cid\":1,\"firstname\":\"MAMA+ÊEMA\",\"lastname\":\"COVIRAN\",\"account\":\"US01QBCore6802509292\",\"gender\":0,\"phone\":\"4499788861\",\"nationality\":\"Albania\",\"birthdate\":\"1975-04-23\"}','{\"payment\":10,\"onduty\":true,\"isboss\":false,\"label\":\"Civilian\",\"name\":\"unemployed\",\"type\":\"none\",\"grade\":{\"name\":\"Freelancer\",\"level\":0}}','{\"label\":\"No Gang Affiliation\",\"name\":\"none\",\"grade\":{\"name\":\"none\",\"level\":0},\"isboss\":false}','{\"x\":294.052734375,\"y\":-1063.068115234375,\"z\":29.2630615234375}','{\"thirst\":88.60000000000001,\"isdead\":false,\"rep\":[],\"injail\":0,\"bloodtype\":\"O-\",\"jailitems\":[],\"licences\":{\"driver\":true,\"business\":false,\"weapon\":false},\"status\":[],\"currentapartment\":\"apartment5934725\",\"tracker\":false,\"ishandcuffed\":false,\"criminalrecord\":{\"hasRecord\":false},\"phonedata\":{\"SerialNumber\":44436540,\"InstalledApps\":[]},\"inlaststand\":false,\"armor\":0,\"hunger\":87.39999999999999,\"inside\":{\"apartment\":{\"apartmentId\":\"apartment5934725\",\"apartmentType\":\"apartment5\"}},\"callsign\":\"NO CALLSIGN\",\"fingerprint\":\"KP916T92FeQ8494\",\"phone\":[],\"stress\":0,\"walletid\":\"QB-26903652\"}','[{\"name\":\"phone\",\"amount\":1,\"slot\":1,\"type\":\"item\",\"info\":[]},{\"name\":\"driver_license\",\"amount\":1,\"slot\":2,\"type\":\"item\",\"info\":{\"birthdate\":\"1975-04-23\",\"firstname\":\"MAMA+ÊEMA\",\"type\":\"Class C Driver License\",\"lastname\":\"COVIRAN\"}},{\"name\":\"id_card\",\"amount\":1,\"slot\":3,\"type\":\"item\",\"info\":{\"citizenid\":\"JRM45973\",\"firstname\":\"MAMA+ÊEMA\",\"lastname\":\"COVIRAN\",\"birthdate\":\"1975-04-23\",\"gender\":0,\"nationality\":\"Albania\"}}]','2026-09-22 19:53:30'),
(41,'VRK10104',1,'license:bfbec128540832cf3ed84f70b6de846e123b9512','inferno','{\"cash\":500,\"bank\":5000,\"crypto\":0}','{\"cid\":1,\"nationality\":\"El Salvador\",\"lastname\":\"pc\",\"gender\":0,\"account\":\"US04QBCore3903549218\",\"birthdate\":\"2026-09-22\",\"phone\":\"6227641921\",\"firstname\":\"pablo\"}','{\"name\":\"unemployed\",\"isboss\":false,\"onduty\":true,\"grade\":{\"name\":\"Freelancer\",\"level\":0},\"label\":\"Civilian\",\"type\":\"none\",\"payment\":10}','{\"label\":\"No Gang Affiliation\",\"grade\":{\"name\":\"none\",\"level\":0},\"isboss\":false,\"name\":\"none\"}','{\"x\":-1032.4615478515626,\"y\":-2729.9736328125,\"z\":13.744384765625}','{\"status\":[],\"fingerprint\":\"fq755h33VDQ5681\",\"walletid\":\"QB-51660327\",\"inside\":{\"apartment\":[]},\"injail\":0,\"thirst\":96.2,\"stress\":0,\"licences\":{\"driver\":true,\"business\":false,\"weapon\":false},\"armor\":0,\"ishandcuffed\":false,\"bloodtype\":\"B+\",\"phone\":[],\"inlaststand\":false,\"criminalrecord\":{\"hasRecord\":false},\"hunger\":95.8,\"tracker\":false,\"phonedata\":{\"SerialNumber\":39816326,\"InstalledApps\":[]},\"isdead\":false,\"rep\":[],\"callsign\":\"NO CALLSIGN\",\"jailitems\":[]}','[{\"name\":\"id_card\",\"info\":{\"nationality\":\"El Salvador\",\"gender\":0,\"citizenid\":\"VRK10104\",\"lastname\":\"pc\",\"firstname\":\"pablo\",\"birthdate\":\"2026-09-22\"},\"type\":\"item\",\"amount\":1,\"slot\":1},{\"name\":\"driver_license\",\"info\":{\"firstname\":\"pablo\",\"lastname\":\"pc\",\"type\":\"Class C Driver License\",\"birthdate\":\"2026-09-22\"},\"type\":\"item\",\"amount\":1,\"slot\":2},{\"name\":\"phone\",\"info\":[],\"type\":\"item\",\"amount\":1,\"slot\":3}]','2026-09-22 20:47:15');
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playerskins`
--

DROP TABLE IF EXISTS `playerskins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `playerskins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `model` varchar(255) NOT NULL,
  `skin` text NOT NULL,
  `active` tinyint(2) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playerskins`
--

LOCK TABLES `playerskins` WRITE;
/*!40000 ALTER TABLE `playerskins` DISABLE KEYS */;
INSERT INTO `playerskins` VALUES
(3,'FEZ03578','1885233650','{\"nose_5\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"cheek_3\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"nose_1\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"nose_2\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"nose_3\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"lips_thickness\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"mask\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"chimp_hole\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"bracelet\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"glass\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"eyebrown_forward\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"neck_thikness\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"accessory\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"makeup\":{\"defaultTexture\":1,\"item\":-1,\"defaultItem\":-1,\"texture\":1},\"vest\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"jaw_bone_width\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"arms\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"pants\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"eyebrows\":{\"defaultTexture\":1,\"item\":-1,\"defaultItem\":-1,\"texture\":1},\"eye_opening\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"beard\":{\"defaultTexture\":1,\"item\":-1,\"defaultItem\":-1,\"texture\":1},\"chimp_bone_lenght\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"bag\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"lipstick\":{\"defaultTexture\":1,\"item\":-1,\"defaultItem\":-1,\"texture\":1},\"moles\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"cheek_2\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"t-shirt\":{\"defaultTexture\":0,\"item\":1,\"defaultItem\":1,\"texture\":0},\"blush\":{\"defaultTexture\":1,\"item\":-1,\"defaultItem\":-1,\"texture\":1},\"shoes\":{\"defaultTexture\":0,\"item\":1,\"defaultItem\":1,\"texture\":0},\"torso2\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"eyebrown_high\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"nose_4\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"nose_0\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"face2\":{\"defaultTexture\":0,\"item\":7,\"defaultItem\":0,\"texture\":0},\"ear\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"cheek_1\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"watch\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"ageing\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"chimp_bone_width\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"hat\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"jaw_bone_back_lenght\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"chimp_bone_lowering\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"face\":{\"defaultTexture\":0,\"item\":7,\"defaultItem\":0,\"texture\":0},\"decals\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"eye_color\":{\"defaultTexture\":0,\"item\":-1,\"defaultItem\":-1,\"texture\":0},\"hair\":{\"defaultTexture\":0,\"item\":0,\"defaultItem\":0,\"texture\":0},\"facemix\":{\"skinMix\":0,\"defaultShapeMix\":0.0,\"shapeMix\":0,\"defaultSkinMix\":0.0}}',1),
(4,'JRM45973','-1613485779','{\"facemix\":{\"skinMix\":0.93,\"shapeMix\":0,\"defaultSkinMix\":0.0,\"defaultShapeMix\":0.0},\"decals\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"accessory\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"neck_thikness\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"blush\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"bag\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_3\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"moles\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"eyebrown_forward\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"pants\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"eye_opening\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"ageing\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"mask\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"chimp_hole\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"vest\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"face\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"cheek_2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"eye_color\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"lipstick\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"face2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_1\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_0\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"chimp_bone_lenght\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"hat\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"jaw_bone_back_lenght\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"jaw_bone_width\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"eyebrown_high\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_5\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"lips_thickness\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"cheek_1\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"chimp_bone_width\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"shoes\":{\"item\":1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":1},\"cheek_3\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_4\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"t-shirt\":{\"item\":1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":1},\"hair\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_2\":{\"item\":4,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"torso2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"bracelet\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"beard\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"chimp_bone_lowering\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"glass\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"arms\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"ear\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"eyebrows\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"makeup\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"watch\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1}}',1),
(5,'ADE24479','1885233650','{\"facemix\":{\"shapeMix\":0.0,\"skinMix\":0.0,\"defaultShapeMix\":0.0,\"defaultSkinMix\":0.0},\"shoes\":{\"defaultTexture\":0,\"defaultItem\":1,\"item\":6,\"texture\":0},\"makeup\":{\"defaultTexture\":1,\"defaultItem\":-1,\"item\":-1,\"texture\":1},\"face2\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":4,\"texture\":0},\"chimp_hole\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"chimp_bone_width\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"accessory\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":2,\"texture\":0},\"watch\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"lips_thickness\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"hair\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"arms\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":208,\"texture\":2},\"lipstick\":{\"defaultTexture\":1,\"defaultItem\":-1,\"item\":-1,\"texture\":1},\"eye_color\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"eyebrows\":{\"defaultTexture\":1,\"defaultItem\":-1,\"item\":-1,\"texture\":1},\"face\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":4,\"texture\":4},\"torso2\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":6,\"texture\":3},\"jaw_bone_back_lenght\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"glass\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"cheek_1\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"chimp_bone_lowering\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"nose_1\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"chimp_bone_lenght\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"eyebrown_forward\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"eyebrown_high\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"nose_2\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"eye_opening\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"cheek_3\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"cheek_2\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"nose_5\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"nose_4\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"pants\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":7,\"texture\":0},\"nose_3\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"jaw_bone_width\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"bag\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"vest\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"moles\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"beard\":{\"defaultTexture\":1,\"defaultItem\":-1,\"item\":-1,\"texture\":1},\"neck_thikness\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"mask\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":3,\"texture\":0},\"decals\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":4,\"texture\":0},\"bracelet\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"hat\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"blush\":{\"defaultTexture\":1,\"defaultItem\":-1,\"item\":-1,\"texture\":1},\"ageing\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"ear\":{\"defaultTexture\":0,\"defaultItem\":-1,\"item\":-1,\"texture\":0},\"nose_0\":{\"defaultTexture\":0,\"defaultItem\":0,\"item\":0,\"texture\":0},\"t-shirt\":{\"defaultTexture\":0,\"defaultItem\":1,\"item\":30,\"texture\":3}}',1),
(6,'VRK10104','1885233650','{\"eyebrows\":{\"defaultTexture\":1,\"texture\":1,\"item\":-1,\"defaultItem\":-1},\"cheek_2\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"nose_1\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"eyebrown_high\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"vest\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"jaw_bone_width\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"cheek_3\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"blush\":{\"defaultTexture\":1,\"texture\":1,\"item\":-1,\"defaultItem\":-1},\"hat\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"t-shirt\":{\"defaultTexture\":0,\"texture\":0,\"item\":1,\"defaultItem\":1},\"bracelet\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"face\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"arms\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"ageing\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"chimp_bone_lenght\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"nose_0\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"chimp_hole\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"lips_thickness\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"glass\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"chimp_bone_lowering\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"jaw_bone_back_lenght\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"pants\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"eyebrown_forward\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"nose_3\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"chimp_bone_width\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"eye_opening\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"makeup\":{\"defaultTexture\":1,\"texture\":1,\"item\":-1,\"defaultItem\":-1},\"nose_4\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"torso2\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"cheek_1\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"facemix\":{\"defaultSkinMix\":0.0,\"defaultShapeMix\":0.0,\"shapeMix\":0.0,\"skinMix\":0.0},\"nose_2\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"neck_thikness\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"moles\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"hair\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"beard\":{\"defaultTexture\":1,\"texture\":1,\"item\":-1,\"defaultItem\":-1},\"mask\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"eye_color\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"decals\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"accessory\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"ear\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"face2\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"watch\":{\"defaultTexture\":0,\"texture\":0,\"item\":-1,\"defaultItem\":-1},\"bag\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"shoes\":{\"defaultTexture\":0,\"texture\":0,\"item\":1,\"defaultItem\":1},\"nose_5\":{\"defaultTexture\":0,\"texture\":0,\"item\":0,\"defaultItem\":0},\"lipstick\":{\"defaultTexture\":1,\"texture\":1,\"item\":-1,\"defaultItem\":-1}}',1);
/*!40000 ALTER TABLE `playerskins` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-09-25 13:38:29
