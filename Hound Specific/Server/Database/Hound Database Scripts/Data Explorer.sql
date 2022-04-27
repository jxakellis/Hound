# CALL Hound.queryAll;

SELECT * FROM families;
SELECT * FROM familyMembers;
SELECT * FROM users;
SELECT * FROM userConfiguration;
SELECT * FROM dogs;
SELECT * FROM dogLogs;
SELECT * FROM dogReminders;
SELECT * FROM reminderCountdownComponents;
SELECT * FROM reminderOneTimeComponents;
SELECT * FROM reminderWeeklyComponents;
SELECT * FROM reminderMonthlyComponents;
SELECT * FROM reminderSnoozeComponents;

INSERT INTO familyHeads(familyId, userId, familyCode, familyIsLocked) VALUES (2,3,'ABCD1234',0);
INSERT INTO familyMembers(familyId, userId) VALUES (2,3);