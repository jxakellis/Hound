# CALL Hound.queryAll;

SELECT * FROM families;
SELECT * FROM familyMembers;
SELECT * FROM users;
SELECT * FROM userConfiguration;
SELECT * FROM dogs;
SELECT * FROM dogLogs;
SELECT * FROM dogReminders;
SELECT * FROM subscriptions;

SELECT * FROM userRequestLogs;
SELECT * FROM previousFamilies;
SELECT * FROM previousFamilyMembers;

INSERT INTO dogLogs(dogId, userId, logDate, logNote, logAction, logCustomActionName, logLastModified, logIsDeleted) VALUES
('5','38c0e67317cdff1f49a8a7a9901e0d503e5dafca1a9bb1d800c2d6a3f7adf037','2022-07-12 01:01:01.001','','Feed','','3000-01-01 01:01:01.001','0'),
('5','38c0e67317cdff1f49a8a7a9901e0d503e5dafca1a9bb1d800c2d6a3f7adf037','2022-07-13 01:01:01.001','','Walk','','3000-01-01 01:01:01.001','0'),
('5','38c0e67317cdff1f49a8a7a9901e0d503e5dafca1a9bb1d800c2d6a3f7adf037','2022-07-14 01:01:01.001','','Potty: Pee','','3000-01-01 01:01:01.001','0'),
('5','38c0e67317cdff1f49a8a7a9901e0d503e5dafca1a9bb1d800c2d6a3f7adf037','2022-07-15 01:01:01.001','','Potty: Poo','','3000-01-01 01:01:01.001','0'),
('5','38c0e67317cdff1f49a8a7a9901e0d503e5dafca1a9bb1d800c2d6a3f7adf037','2022-07-16 01:01:01.001','','Potty: Both','','3000-01-01 01:01:01.001','0');