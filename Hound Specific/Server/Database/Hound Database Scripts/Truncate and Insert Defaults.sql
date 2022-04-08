# CALL Hound.truncateAll;

USE Hound;
TRUNCATE TABLE users;
TRUNCATE TABLE userConfiguration;
TRUNCATE TABLE familyMembers;
TRUNCATE TABLE familyHeads;
TRUNCATE TABLE dogs;
TRUNCATE TABLE dogLogs;
TRUNCATE TABLE dogReminders;
TRUNCATE TABLE reminderCountdownComponents;
TRUNCATE TABLE reminderOneTimeComponents;
TRUNCATE TABLE reminderSnoozeComponents;
TRUNCATE TABLE reminderWeeklyComponents;
TRUNCATE TABLE reminderMonthlyComponents;

INSERT INTO users (userFirstName, userLastName, userEmail, userIdentifier) VALUES
('Joe', 'Smith', 'joesmith@gmail.com', '38523iuhfu23buyfuy42'),
('Testing', 'Account', 'testing@gmail.com', 'uhq3iufnu3ubyfeuy3');

INSERT INTO userConfiguration (
userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView,
interfaceStyle, snoozeLength, notificationSound) VALUES
(1, false, false, false, 1738, false, true, 0, 900, 'Radar'),
(2, false, false, false, 1738, false, true, 0, 900, 'Radar');

INSERT INTO familyMembers(familyId, userId) VALUES
(1,1),
(2,2);

INSERT INTO familyHeads(userId, familyCode, familyIsLocked) VALUES
(1, 'TEMPCOD1', false),
(2, 'TEMPCOD2', false);

INSERT INTO dogs(familyId, dogName) VALUES
(1, 'Bella'),
(1, 'Georgie');

INSERT INTO dogLogs (dogId, logDate, logNote, logAction) VALUES
(1, '2021-11-16 12:00:00', 'big pee', 'Potty: Pee'),
(1, '2021-11-16 14:00:00', 'big poop', 6),
(2, '2021-11-16 13:00:00', '', 7);

INSERT INTO dogReminders (dogId, reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled) VALUES
(1, 'Feed', 'countdown', '2021-11-16 12:00:00', true),
(1, 'Fresh Water', 'countdown', '2021-11-16 14:00:00', true),
(2, 'Feed', 'monthly', '2021-11-16 12:00:00', true),
(2, 'Potty', 'weekly', '2021-11-16 15:00:00', true);

INSERT INTO reminderCountdownComponents (reminderId, countdownExecutionInterval, countdownIntervalElapsed) VALUES
(1, 18000, 0),
(2, 7200, 0);

INSERT INTO reminderSnoozeComponents (reminderId, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed) VALUES
(1, false, 180, 0),
(2, false, 180, 0),
(3, false, 180, 0),
(4, false, 180, 0);

INSERT INTO reminderWeeklyComponents (reminderId, weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, weeklyIsSkipping) VALUES
(4, 10, 10, true, false, false, false, false, false, false, false);

INSERT INTO reminderMonthlyComponents (reminderId, monthlyHour, monthlyMinute, monthlyDay, monthlyIsSkipping) VALUES
(3, 15, 15, 20, false);
