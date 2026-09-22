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
) ENGINE=InnoDB AUTO_INCREMENT=4145 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apartments`
--

LOCK TABLES `apartments` WRITE;
/*!40000 ALTER TABLE `apartments` DISABLE KEYS */;
INSERT INTO `apartments` VALUES
(4144,'apartment3219775','apartment3','Integrity Way 219775','FEZ03578');
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
(20,NULL,'lawyer',0,'job','[]');
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
('qbit',1000,'[{\"NewWorth\":1000,\"PreviousWorth\":1000}]');
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
('license:b43e4e1ff76ba7f9c6d7a3c303fab5c0a1e73c23','num4','','num5','','num6','','num7','','num8','','num9','');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_outfits`
--

LOCK TABLES `player_outfits` WRITE;
/*!40000 ALTER TABLE `player_outfits` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES
(1,'FEZ03578',1,'license:b43e4e1ff76ba7f9c6d7a3c303fab5c0a1e73c23','vwrz8269','{\"crypto\":0,\"cash\":500,\"bank\":3010}','{\"cid\":1,\"birthdate\":\"2026-09-22\",\"phone\":\"1378416509\",\"nationality\":\"Argentina\",\"account\":\"US01QBCore4447723097\",\"gender\":0,\"firstname\":\"Raul\",\"lastname\":\"Galvez\"}','{\"onduty\":true,\"isboss\":false,\"label\":\"Civilian\",\"type\":\"none\",\"grade\":{\"isboss\":false,\"level\":0,\"name\":\"Freelancer\",\"payment\":10},\"name\":\"unemployed\",\"payment\":10}','{\"label\":\"No Gang\",\"name\":\"none\",\"isboss\":false,\"grade\":{\"level\":0,\"name\":\"Unaffiliated\",\"isboss\":false}}','{\"x\":1390.2462158203126,\"y\":3607.397705078125,\"z\":38.934814453125}','{\"currentapartment\":\"apartment3219775\",\"inlaststand\":false,\"jailitems\":[],\"stress\":0,\"criminalrecord\":{\"hasRecord\":false},\"fingerprint\":\"VX984i66FOt1121\",\"hunger\":91.6,\"inside\":{\"apartment\":{\"apartmentId\":\"apartment3219775\",\"apartmentType\":\"apartment3\"}},\"phonedata\":{\"InstalledApps\":[],\"SerialNumber\":80842504},\"thirst\":92.4,\"isdead\":false,\"status\":[],\"callsign\":\"NO CALLSIGN\",\"armor\":0,\"vehicleKeys\":{\"87YIM239\":true},\"licences\":{\"business\":false,\"weapon\":false,\"driver\":true},\"phone\":[],\"injail\":0,\"rep\":[],\"ishandcuffed\":false,\"tracker\":false,\"walletid\":\"QB-87505508\",\"bloodtype\":\"AB+\"}','[]','2026-09-22 17:54:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playerskins`
--

LOCK TABLES `playerskins` WRITE;
/*!40000 ALTER TABLE `playerskins` DISABLE KEYS */;
INSERT INTO `playerskins` VALUES
(2,'FEZ03578','1885233650','{\"jaw_bone_width\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"nose_5\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"neck_thikness\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"bag\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"moles\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"makeup\":{\"item\":-1,\"defaultItem\":-1,\"texture\":1,\"defaultTexture\":1},\"ageing\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"cheek_1\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"glass\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"eye_opening\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"cheek_3\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"blush\":{\"item\":-1,\"defaultItem\":-1,\"texture\":1,\"defaultTexture\":1},\"arms\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"vest\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"eyebrown_high\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"chimp_bone_width\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"t-shirt\":{\"item\":1,\"defaultItem\":1,\"texture\":0,\"defaultTexture\":0},\"face2\":{\"item\":7,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"facemix\":{\"defaultShapeMix\":0.0,\"defaultSkinMix\":0.0,\"shapeMix\":0,\"skinMix\":0},\"bracelet\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"nose_0\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"chimp_bone_lowering\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"watch\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"eyebrown_forward\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"eyebrows\":{\"item\":-1,\"defaultItem\":-1,\"texture\":1,\"defaultTexture\":1},\"mask\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"cheek_2\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"hair\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"jaw_bone_back_lenght\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"chimp_hole\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"torso2\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"nose_1\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"lipstick\":{\"item\":-1,\"defaultItem\":-1,\"texture\":1,\"defaultTexture\":1},\"chimp_bone_lenght\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"hat\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"pants\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"nose_2\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"ear\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"eye_color\":{\"item\":-1,\"defaultItem\":-1,\"texture\":0,\"defaultTexture\":0},\"lips_thickness\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"nose_4\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"decals\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"accessory\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"nose_3\":{\"item\":0,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"face\":{\"item\":7,\"defaultItem\":0,\"texture\":0,\"defaultTexture\":0},\"shoes\":{\"item\":1,\"defaultItem\":1,\"texture\":0,\"defaultTexture\":0},\"beard\":{\"item\":-1,\"defaultItem\":-1,\"texture\":1,\"defaultTexture\":1}}',1);
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

-- Dump completed on 2026-09-22 19:56:53
