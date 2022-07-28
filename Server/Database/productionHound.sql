CREATE DATABASE productionHound;
USE productionHound;
-- MariaDB dump 10.19  Distrib 10.6.4-MariaDB, for osx10.16 (x86_64)
--
-- Host: localhost    Database: Hound
-- ------------------------------------------------------
-- Server version	10.6.4-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `dogLogs`
--

DROP TABLE IF EXISTS `dogLogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dogLogs` (
  `logId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dogId` bigint(20) unsigned NOT NULL,
  `userId` char(64) NOT NULL COMMENT 'Tracks the user who created the log',
  `logDate` datetime(3) NOT NULL,
  `logNote` varchar(1000) NOT NULL,
  `logAction` enum('Custom','Feed','Fresh Water','Treat','Potty: Pee','Potty: Poo','Potty: Both','Potty: Didn''t Go','Accident','Walk','Brush','Bathe','Medicine','Wake Up','Sleep','Crate','Training Session','Doctor Visit') NOT NULL,
  `logCustomActionName` varchar(32) DEFAULT NULL COMMENT 'If the logAction is ''Custom'', tracks whether or not the user input a custom name that is used in place of ''Custom''',
  `logLastModified` datetime(3) NOT NULL COMMENT 'Tracks when the log was last modified',
  `logIsDeleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`logId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dogLogs`
--

LOCK TABLES `dogLogs` WRITE;
/*!40000 ALTER TABLE `dogLogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `dogLogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dogReminders`
--

DROP TABLE IF EXISTS `dogReminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dogReminders` (
  `reminderId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dogId` bigint(20) unsigned NOT NULL,
  `reminderAction` enum('Custom','Feed','Fresh Water','Potty','Walk','Brush','Bathe','Medicine','Sleep','Training Session','Doctor Visit') NOT NULL,
  `reminderCustomActionName` varchar(32) DEFAULT NULL,
  `reminderType` enum('countdown','weekly','monthly','oneTime') NOT NULL,
  `reminderIsEnabled` tinyint(1) NOT NULL,
  `reminderExecutionBasis` datetime(3) NOT NULL,
  `reminderExecutionDate` datetime(3) DEFAULT NULL,
  `reminderLastModified` datetime(3) NOT NULL,
  `reminderIsDeleted` tinyint(1) NOT NULL DEFAULT 0,
  `snoozeIsEnabled` tinyint(1) NOT NULL,
  `snoozeExecutionInterval` mediumint(8) unsigned NOT NULL,
  `snoozeIntervalElapsed` int(10) unsigned NOT NULL,
  `countdownExecutionInterval` mediumint(8) unsigned NOT NULL,
  `countdownIntervalElapsed` int(10) unsigned NOT NULL,
  `weeklyHour` tinyint(3) unsigned NOT NULL,
  `weeklyMinute` tinyint(3) unsigned NOT NULL,
  `weeklySunday` tinyint(1) NOT NULL,
  `weeklyMonday` tinyint(1) NOT NULL,
  `weeklyTuesday` tinyint(1) NOT NULL,
  `weeklyWednesday` tinyint(1) NOT NULL,
  `weeklyThursday` tinyint(1) NOT NULL,
  `weeklyFriday` tinyint(1) NOT NULL,
  `weeklySaturday` tinyint(1) NOT NULL,
  `weeklyIsSkipping` tinyint(1) NOT NULL,
  `weeklyIsSkippingDate` datetime(3) DEFAULT NULL,
  `monthlyDay` tinyint(3) unsigned NOT NULL,
  `monthlyHour` tinyint(3) unsigned NOT NULL,
  `monthlyMinute` tinyint(3) unsigned NOT NULL,
  `monthlyIsSkipping` tinyint(1) NOT NULL,
  `monthlyIsSkippingDate` datetime(3) DEFAULT NULL,
  `oneTimeDate` datetime(3) NOT NULL,
  PRIMARY KEY (`reminderId`),
  CONSTRAINT `dogReminders_snooze_CHECK` CHECK (`snoozeIsEnabled` = 0 or `snoozeIsEnabled` = 1 and `snoozeExecutionInterval` is not null and `snoozeIntervalElapsed` is not null),
  CONSTRAINT `dogReminders_weekly_CHECK` CHECK (`weeklyHour` >= 0 and `weeklyHour` <= 24 and `weeklyMinute` >= 0 and `weeklyMinute` <= 60 and (`weeklyIsSkipping` is false or `weeklyIsSkipping` is true and `weeklyIsSkippingDate` is not null) and (`weeklySunday` = 1 or `weeklyMonday` = 1 or `weeklyTuesday` = 1 or `weeklyWednesday` = 1 or `weeklyThursday` = 1 or `weeklyFriday` = 1 or `weeklySaturday` = 1)),
  CONSTRAINT `dogReminders_monthly_CHECK` CHECK (`monthlyHour` >= 0 and `monthlyHour` <= 24 and `monthlyMinute` >= 0 and `monthlyMinute` <= 60 and `monthlyDay` >= 0 and `monthlyDay` <= 31 and (`monthlyIsSkipping` = 0 or `monthlyIsSkipping` = 1 and `monthlyIsSkippingDate` is not null))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dogReminders`
--

LOCK TABLES `dogReminders` WRITE;
/*!40000 ALTER TABLE `dogReminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `dogReminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dogs`
--

DROP TABLE IF EXISTS `dogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dogs` (
  `dogId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `familyId` char(64) NOT NULL,
  `dogName` varchar(32) NOT NULL,
  `dogLastModified` datetime(3) NOT NULL,
  `dogIsDeleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`dogId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dogs`
--

LOCK TABLES `dogs` WRITE;
/*!40000 ALTER TABLE `dogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `dogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `families`
--

DROP TABLE IF EXISTS `families`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `families` (
  `familyId` char(64) NOT NULL,
  `userId` char(64) NOT NULL COMMENT 'familyHead userId',
  `familyCode` char(8) NOT NULL,
  `isLocked` tinyint(1) NOT NULL,
  `isPaused` tinyint(1) NOT NULL,
  `lastPause` datetime(3) DEFAULT NULL,
  `lastUnpause` datetime(3) DEFAULT NULL,
  `familyAccountCreationDate` datetime(3) NOT NULL,
  PRIMARY KEY (`familyId`),
  UNIQUE KEY `familyHeads_UN` (`familyCode`,`userId`),
  CONSTRAINT `familyHeads_CHECK` CHECK (`familyCode` regexp '^[[:upper:][:digit:]]{8}' = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `families`
--

LOCK TABLES `families` WRITE;
/*!40000 ALTER TABLE `families` DISABLE KEYS */;
/*!40000 ALTER TABLE `families` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `familyMembers`
--

DROP TABLE IF EXISTS `familyMembers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `familyMembers` (
  `familyId` char(64) NOT NULL,
  `userId` char(64) NOT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `familyMembers`
--

LOCK TABLES `familyMembers` WRITE;
/*!40000 ALTER TABLE `familyMembers` DISABLE KEYS */;
/*!40000 ALTER TABLE `familyMembers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `previousFamilies`
--

DROP TABLE IF EXISTS `previousFamilies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `previousFamilies` (
  `familyId` char(64) NOT NULL,
  `userId` char(64) NOT NULL COMMENT 'familyHead userId',
  `familyAccountCreationDate` datetime(3) NOT NULL,
  `familyAccountDeletionDate` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores records of any families that have been deleted';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `previousFamilies`
--

LOCK TABLES `previousFamilies` WRITE;
/*!40000 ALTER TABLE `previousFamilies` DISABLE KEYS */;
/*!40000 ALTER TABLE `previousFamilies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `previousFamilyMembers`
--

DROP TABLE IF EXISTS `previousFamilyMembers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `previousFamilyMembers` (
  `userId` char(64) NOT NULL,
  `familyId` char(64) NOT NULL,
  `userFirstName` varchar(32) DEFAULT NULL,
  `userLastName` varchar(32) DEFAULT NULL,
  `familyLeaveDate` datetime(3) NOT NULL,
  `familyLeaveReason` enum('userLeft','userKicked','familyDeleted') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores records of any families that users have left';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `previousFamilyMembers`
--

LOCK TABLES `previousFamilyMembers` WRITE;
/*!40000 ALTER TABLE `previousFamilyMembers` DISABLE KEYS */;
/*!40000 ALTER TABLE `previousFamilyMembers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `previousRequests`
--

DROP TABLE IF EXISTS `previousRequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `previousRequests` (
  `requestId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `appBuild` smallint(5) unsigned DEFAULT NULL,
  `requestIP` varchar(15) DEFAULT NULL,
  `requestDate` datetime(3) DEFAULT NULL,
  `requestMethod` varchar(6) DEFAULT NULL,
  `requestOriginalURL` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`requestId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `previousRequests`
--

LOCK TABLES `previousRequests` WRITE;
/*!40000 ALTER TABLE `previousRequests` DISABLE KEYS */;
/*!40000 ALTER TABLE `previousRequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `previousResponses`
--

DROP TABLE IF EXISTS `previousResponses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `previousResponses` (
  `requestId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `appBuild` smallint(5) unsigned DEFAULT NULL,
  `requestIP` varchar(15) DEFAULT NULL,
  `requestDate` datetime(3) DEFAULT NULL,
  `requestMethod` varchar(6) DEFAULT NULL,
  `requestOriginalURL` varchar(500) DEFAULT NULL,
  `responseBody` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`requestId`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `previousResponses`
--

LOCK TABLES `previousResponses` WRITE;
/*!40000 ALTER TABLE `previousResponses` DISABLE KEYS */;
INSERT INTO `previousResponses` VALUES (1,1234,NULL,'2022-07-24 08:18:36.066','GET','/app/1234','{\"message\":\"App build of 1234 is incompatible. Compatible builds: 4000,5000\",\"code\":\"ER_GENERAL_APP_BUILD_OUTDATED\",\"name\":\"ValidationError\"}'),(2,5000,NULL,'2022-07-26 13:35:52.568','PUT','/app/5000/user/1bad6b8cf97131fceab8543e81f7757195fbb1d36b376ee994ad1cf17699c464?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"message\":\"No user found or invalid permissions\",\"code\":\"ER_VALUE_INVALID\",\"name\":\"ValidationError\"}'),(3,5000,NULL,'2022-07-26 13:35:59.207','POST','/app/5000/user?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\"}'),(4,5000,NULL,'2022-07-26 13:35:59.602','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userNotificationToken\":null,\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\",\"userEmail\":\"84q8vskgdy@privaterelay.appleid.com\",\"familyId\":null,\"isNotificationEnabled\":0,\"isLoudNotification\":0,\"isFollowUpEnabled\":0,\"followUpDelay\":300,\"snoozeLength\":300,\"notificationSound\":\"Radar\",\"logsInterfaceScale\":\"Medium\",\"remindersInterfaceScale\":\"Medium\",\"interfaceStyl'),(5,5000,NULL,'2022-07-26 13:36:01.885','POST','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90\"}'),(6,5000,NULL,'2022-07-26 13:36:02.368','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userNotificationToken\":null,\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\",\"userEmail\":\"84q8vskgdy@privaterelay.appleid.com\",\"familyId\":\"119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90\",\"isNotificationEnabled\":0,\"isLoudNotification\":0,\"isFollowUpEnabled\":0,\"followUpDelay\":300,\"snoozeLength\":300,\"notificationSound\":\"Radar\",\"logsInterfaceSca'),(7,5000,NULL,'2022-07-26 13:36:02.443','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"familyCode\":\"FW28S26H\",\"isLocked\":0,\"isPaused\":0,\"familyMembers\":[{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\"}],\"activeSubscription\":{\"productId\":\"com.jonathanxakellis.hound.default\",\"subscriptionNumberOfFamilyMembers\":1,\"subscriptionNumberOfDogs\":2,\"subscriptionIsActive\":true}'),(8,5000,NULL,'2022-07-26 13:36:02.490','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/?isRetrievingReminders=true&isRetrievingLogs=true&lastDogManagerSynchronization=2009-02-13T23:31:30.000Z&userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":[]}'),(9,5000,NULL,'2022-07-26 13:36:23.059','POST','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":2}'),(10,5000,NULL,'2022-07-26 13:36:23.778','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(11,5000,NULL,'2022-07-26 13:36:33.714','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userNotificationToken\":\"c80c81fb04c7785f6c74a3566cea3dab01d0e15a0de8a592602df38b6e9df702\",\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\",\"userEmail\":\"84q8vskgdy@privaterelay.appleid.com\",\"familyId\":\"119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90\",\"isNotificationEnabled\":0,\"isLoudNotification\":0,\"isFollowUpEnabled\":0,\"followUpDelay\":300,\"s'),(12,5000,NULL,'2022-07-26 13:36:33.724','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(13,5000,NULL,'2022-07-26 13:36:33.745','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"familyCode\":\"FW28S26H\",\"isLocked\":0,\"isPaused\":0,\"familyMembers\":[{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\"}],\"activeSubscription\":{\"productId\":\"com.jonathanxakellis.hound.default\",\"subscriptionNumberOfFamilyMembers\":1,\"subscriptionNumberOfDogs\":2,\"subscriptionIsActive\":true}'),(14,5000,NULL,'2022-07-26 13:36:33.781','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/?isRetrievingReminders=true&isRetrievingLogs=true&lastDogManagerSynchronization=2022-07-26T17:36:00.866Z&userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":[{\"dogId\":2,\"dogName\":\"Bella\",\"dogIsDeleted\":0,\"reminders\":[],\"logs\":[]}]}'),(15,5000,NULL,'2022-07-26 13:36:35.567','POST','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/2/reminders/?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":[{\"monthlyDay\":1,\"snoozeIsEnabled\":false,\"weeklySaturday\":true,\"weeklyWednesday\":true,\"monthlyMinute\":0,\"reminderIsEnabled\":true,\"weeklyIsSkipping\":false,\"oneTimeDate\":\"2022-07-26T17:36:33.773Z\",\"countdownIntervalElapsed\":0,\"reminderAction\":\"Potty\",\"monthlyIsSkipping\":false,\"weeklyHour\":7,\"weeklyMinute\":0,\"weeklyTuesday\":true,\"snoozeIntervalElapsed\":0,\"reminderId\":3,\"reminderType\":\"countdown\",\"countdownExecutionInterval\":1800,\"weeklyMonday\":true,\"reminderExecutionDate\":\"2022-07-26T18:0'),(16,5000,NULL,'2022-07-26 13:36:37.205','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/2/reminders/?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(17,5000,NULL,'2022-07-26 13:36:38.868','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/2/reminders/?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(18,5000,NULL,'2022-07-26 13:36:39.953','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/2/reminders/?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(19,5000,NULL,'2022-07-26 13:36:40.678','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/2/reminders/?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(20,5000,NULL,'2022-07-26 13:36:49.590','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userNotificationToken\":\"c80c81fb04c7785f6c74a3566cea3dab01d0e15a0de8a592602df38b6e9df702\",\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\",\"userEmail\":\"84q8vskgdy@privaterelay.appleid.com\",\"familyId\":\"119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90\",\"isNotificationEnabled\":0,\"isLoudNotification\":0,\"isFollowUpEnabled\":0,\"followUpDelay\":300,\"s'),(21,5000,NULL,'2022-07-26 13:36:49.592','PUT','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":\"\"}'),(22,5000,NULL,'2022-07-26 13:36:49.614','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90?userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"familyCode\":\"FW28S26H\",\"isLocked\":0,\"isPaused\":0,\"familyMembers\":[{\"userId\":\"7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6\",\"userFirstName\":\"01234567890123456789012345678901\",\"userLastName\":\"01234567890123456789012345678901\"}],\"activeSubscription\":{\"productId\":\"com.jonathanxakellis.hound.default\",\"subscriptionNumberOfFamilyMembers\":1,\"subscriptionNumberOfDogs\":2,\"subscriptionIsActive\":true}'),(23,5000,NULL,'2022-07-26 13:36:49.658','GET','/app/5000/user/7e8bc7b92236ec55c0c0729a5fa0f5c1b25807842a028f4336d19cf25af337d6/family/119d27ae53585b873feb049b39d95abb81b82d05107f22f850c0e9882d221f90/dogs/?isRetrievingReminders=true&isRetrievingLogs=true&lastDogManagerSynchronization=2022-07-26T17:36:00.866Z&userIdentifier=1f66dbb1e7df20e51a8cd88c2334f5e4def79a2ebc1444f6766ff4160ea6927a','{\"result\":[{\"dogId\":2,\"dogName\":\"Bella\",\"dogIsDeleted\":0,\"reminders\":[{\"reminderId\":3,\"reminderAction\":\"Potty\",\"reminderCustomActionName\":null,\"reminderType\":\"countdown\",\"reminderIsEnabled\":0,\"reminderExecutionBasis\":\"2022-07-26T17:36:33.772Z\",\"reminderIsDeleted\":0,\"snoozeIsEnabled\":0,\"snoozeExecutionInterval\":300,\"snoozeIntervalElapsed\":0,\"countdownExecutionInterval\":1800,\"countdownIntervalElapsed\":0,\"weeklyHour\":7,\"weeklyMinute\":0,\"weeklySunday\":1,\"weeklyMonday\":1,\"weeklyTuesday\":1,\"weeklyWedn');
/*!40000 ALTER TABLE `previousResponses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `previousServerErrors`
--

DROP TABLE IF EXISTS `previousServerErrors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `previousServerErrors` (
  `errorId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `errorDate` datetime(3) DEFAULT NULL,
  `errorFunction` varchar(100) DEFAULT NULL,
  `errorName` varchar(500) DEFAULT NULL,
  `errorMessage` varchar(500) DEFAULT NULL,
  `errorCode` varchar(500) DEFAULT NULL,
  `errorStack` varchar(2500) DEFAULT NULL,
  PRIMARY KEY (`errorId`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `previousServerErrors`
--

LOCK TABLES `previousServerErrors` WRITE;
/*!40000 ALTER TABLE `previousServerErrors` DISABLE KEYS */;
INSERT INTO `previousServerErrors` VALUES (1,'2022-07-24 08:12:40.455','logRequest','DatabaseError','Unknown column \'requstIP\' in \'field list\'','ER_BAD_FIELD_ERROR','DatabaseError: Unknown column \'requstIP\' in \'field list\'\n    at Query.onResult (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/tools/database/databaseQuery.js:47:18)\n    at Query.execute (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/commands/command.js:36:14)\n    at Connection.handlePacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:456:32)\n    at PacketParser.onPacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:85:12)\n    at PacketParser.executeStart (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/packet_parser.js:75:16)\n    at Socket.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:92:25)\n    at Socket.emit (node:events:527:28)\n    at addChunk (node:internal/streams/readable:315:12)\n    at readableAddChunk (node:internal/streams/readable:289:9)\n    at Socket.Readable.push (node:internal/streams/readable:228:10)'),(2,'2022-07-24 08:14:20.264','logRequest','DatabaseError','Unknown column \'requstIP\' in \'field list\'','ER_BAD_FIELD_ERROR','DatabaseError: Unknown column \'requstIP\' in \'field list\'\n    at Query.onResult (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/tools/database/databaseQuery.js:47:18)\n    at Query.execute (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/commands/command.js:36:14)\n    at Connection.handlePacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:456:32)\n    at PacketParser.onPacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:85:12)\n    at PacketParser.executeStart (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/packet_parser.js:75:16)\n    at Socket.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:92:25)\n    at Socket.emit (node:events:527:28)\n    at addChunk (node:internal/streams/readable:315:12)\n    at readableAddChunk (node:internal/streams/readable:289:9)\n    at Socket.Readable.push (node:internal/streams/readable:228:10)'),(3,'2022-07-24 08:17:44.668','logResponse','DatabaseError','Column count doesn\'t match value count at row 1','ER_WRONG_VALUE_COUNT_ON_ROW','DatabaseError: Column count doesn\'t match value count at row 1\n    at Query.onResult (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/tools/database/databaseQuery.js:47:18)\n    at Query.execute (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/commands/command.js:36:14)\n    at Connection.handlePacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:456:32)\n    at PacketParser.onPacket (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:85:12)\n    at PacketParser.executeStart (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/packet_parser.js:75:16)\n    at Socket.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/node_modules/mysql2/lib/connection.js:92:25)\n    at Socket.emit (node:events:527:28)\n    at addChunk (node:internal/streams/readable:315:12)\n    at readableAddChunk (node:internal/streams/readable:289:9)\n    at Socket.Readable.push (node:internal/streams/readable:228:10)'),(4,'2022-07-25 18:49:33.099','uncaughtException','Error','listen EADDRINUSE: address already in use :::80','EADDRINUSE','Error: listen EADDRINUSE: address already in use :::80\n    at Server.setupListenHandle [as _listen2] (node:net:1372:16)\n    at listenInCluster (node:net:1420:12)\n    at Server.listen (node:net:1508:7)\n    at Object.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/server/server.js:33:19)\n    at Module._compile (node:internal/modules/cjs/loader:1105:14)\n    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1159:10)\n    at Module.load (node:internal/modules/cjs/loader:981:32)\n    at Function.Module._load (node:internal/modules/cjs/loader:822:12)\n    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:77:12)\n    at node:internal/main/run_main_module:17:47'),(5,'2022-07-25 18:49:50.886','uncaughtException','Error','listen EADDRINUSE: address already in use :::80','EADDRINUSE','Error: listen EADDRINUSE: address already in use :::80\n    at Server.setupListenHandle [as _listen2] (node:net:1372:16)\n    at listenInCluster (node:net:1420:12)\n    at Server.listen (node:net:1508:7)\n    at Object.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/server/server.js:33:19)\n    at Module._compile (node:internal/modules/cjs/loader:1105:14)\n    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1159:10)\n    at Module.load (node:internal/modules/cjs/loader:981:32)\n    at Function.Module._load (node:internal/modules/cjs/loader:822:12)\n    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:77:12)\n    at node:internal/main/run_main_module:17:47'),(6,'2022-07-25 18:51:49.498','uncaughtException','Error','listen EADDRINUSE: address already in use :::80','EADDRINUSE','Error: listen EADDRINUSE: address already in use :::80\n    at Server.setupListenHandle [as _listen2] (node:net:1372:16)\n    at listenInCluster (node:net:1420:12)\n    at Server.listen (node:net:1508:7)\n    at Object.<anonymous> (/Users/jonathanxakellis/Documents/GitHub/Jonathan-Xakellis-Comp-Sci/Server/Node/main/server/server.js:33:19)\n    at Module._compile (node:internal/modules/cjs/loader:1105:14)\n    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1159:10)\n    at Module.load (node:internal/modules/cjs/loader:981:32)\n    at Function.Module._load (node:internal/modules/cjs/loader:822:12)\n    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:77:12)\n    at node:internal/main/run_main_module:17:47');
/*!40000 ALTER TABLE `previousServerErrors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `transactionId` bigint(20) unsigned NOT NULL,
  `productId` varchar(100) NOT NULL,
  `familyId` char(64) NOT NULL,
  `userId` char(64) NOT NULL,
  `subscriptionPurchaseDate` datetime(3) NOT NULL,
  `subscriptionLastModified` datetime(3) NOT NULL,
  `subscriptionExpiration` datetime(3) NOT NULL,
  `subscriptionNumberOfFamilyMembers` tinyint(3) unsigned NOT NULL,
  `subscriptionNumberOfDogs` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`transactionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userConfiguration`
--

DROP TABLE IF EXISTS `userConfiguration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userConfiguration` (
  `userId` char(64) NOT NULL,
  `isNotificationEnabled` tinyint(1) NOT NULL,
  `isLoudNotification` tinyint(1) NOT NULL,
  `isFollowUpEnabled` tinyint(1) NOT NULL,
  `followUpDelay` mediumint(8) unsigned NOT NULL,
  `interfaceStyle` tinyint(3) unsigned NOT NULL,
  `snoozeLength` mediumint(8) unsigned NOT NULL,
  `notificationSound` enum('Radar','Apex','Beacon','Bulletin','By The Seaside','Chimes','Circuit','Constellation','Cosmic','Crystals','Hillside','Illuminate','Night Owl','Opening','Playtime','Presto','Radiate','Reflection','Ripplies','Sencha','Signal','Silk','Slow Rise','Stargaze','Summit','Twinkle','Uplift','Waves') NOT NULL,
  `logsInterfaceScale` enum('Small','Medium','Large') NOT NULL,
  `remindersInterfaceScale` enum('Small','Medium','Large') NOT NULL,
  `maximumNumberOfLogsDisplayed` smallint(5) unsigned NOT NULL,
  `lastDogManagerSynchronization` datetime(3) NOT NULL DEFAULT '1970-01-01 00:00:00.000',
  PRIMARY KEY (`userId`),
  CONSTRAINT `interfaceStyle` CHECK (`interfaceStyle` <= 2),
  CONSTRAINT `maximumNumberOfLogsDisplayed` CHECK (`maximumNumberOfLogsDisplayed` <= 5000)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userConfiguration`
--

LOCK TABLES `userConfiguration` WRITE;
/*!40000 ALTER TABLE `userConfiguration` DISABLE KEYS */;
/*!40000 ALTER TABLE `userConfiguration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `userId` char(64) NOT NULL,
  `userFirstName` varchar(32) DEFAULT NULL,
  `userLastName` varchar(32) DEFAULT NULL,
  `userEmail` varchar(320) NOT NULL,
  `userIdentifier` char(64) NOT NULL,
  `userNotificationToken` varchar(100) DEFAULT NULL,
  `userAccountCreationDate` datetime(3) NOT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `users_UN` (`userEmail`,`userIdentifier`),
  CONSTRAINT `users_CHECK` CHECK (`userEmail` <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'Hound'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-07-27 19:29:37
