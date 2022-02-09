CALL Hound.truncateAll;

INSERT INTO users (userFirstName, userLastName, userEmail) VALUES 
('Bob', 'Smith', 'bobsmith@gmail.com'),
('George', 'Williams', 'georgewilliams@gmail.com'),
('Tim', 'Brown', 'timbrown@gmail.com');

INSERT INTO userConfiguration (userId) VALUES 
(1),
(2),
(3);

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

INSERT INTO dogReminders (dogId, reminderType, timingStyle, executionBasis, enabled) VALUES
(1, 'Feed', 'countdown', '2021-11-16 12:00:00', true),
(1, 'Fresh Water', 'countdown', '2021-11-16 14:00:00', true),
(2, 'Feed', 'countdown', '2021-11-16 16:00:00', true),
(2, 'Potty', 'countdown', '2021-11-16 15:00:00', true),
(3, 'Feed', 'weekly', '2021-11-16 12:00:00', true),
(4, 'Doctor Visit', 'oneTime', '2021-11-10 6:00:00', true),
(5, 'Feed', 'countdown', '2021-11-16 12:00:00', true),
(6, 'Feed', 'countdown', '2021-11-16 12:00:00', true);

INSERT INTO reminderCountdownComponents (reminderId, executionInterval, intervalElapsed) VALUES 
(1, 18000, 0),
(2, 7200, 0),
(3, 18000, 0),
(4, 3600, 0),
(5, NULL, NULL),
(6, NULL, NULL),
(7, 18000, 0),
(8, 18000, 0);

INSERT INTO reminderSnoozeComponents (reminderId) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8);


INSERT INTO reminderTimeOfDayComponents (reminderId) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8);

INSERT INTO reminderOneTimeComponents (reminderId) VALUES 
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8);


