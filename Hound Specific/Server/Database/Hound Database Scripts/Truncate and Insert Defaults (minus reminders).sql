CALL Hound.truncateAll;

INSERT INTO users (userFirstName, userLastName, userEmail) VALUES 
('Bob', 'Smith', 'bobsmith@gmail.com'),
('George', 'Williams', 'georgewilliams@gmail.com'),
('Tim', 'Brown', 'timbrown@gmail.com');

INSERT INTO userConfiguration (
userId, isNotificationAuthorized, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView,
darkModeStyle, snoozeLength, notificationSound) VALUES 
(1, true, true, true, true, 1738, false, true, 'unspecified', 900, 'Radar'),
(2, true, true, true, true, 1738, false, true, 'unspecified', 900, 'Radar'),
(3, true, true, true, true, 1738, false, true, 'unspecified', 900, 'Radar');

INSERT INTO dogs(userId, name) VALUES
(1, 'Bella'),
(1, 'Georgie'),
(2, 'Penny'),
(2, 'Ginger'),
(3, 'Scout'),
(3, 'Goose');

INSERT INTO dogLogs (dogId, date, note, logType) VALUES
(1, '2021-11-16 12:00:00', 'big pee', 'Potty: Pee'),
(1, '2021-11-16 14:00:00', 'big poop', 6),
(2, '2021-11-16 13:00:00', '', 7),
(3, '2021-11-16 16:00:00', '', 2),
(4, '2021-11-16 16:30:00', '', 3),
(5, '2021-11-16 14:25:00', '', 4),
(6, '2021-11-16 17:00:00', '', 9);