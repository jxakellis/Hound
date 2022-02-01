CALL Hound.truncate_all;

INSERT INTO users (user_first_name, user_last_name, user_email) VALUES 
('Bob', 'Smith', 'bsmith@gmail.com'),
('George', 'Williams', 'gwilliams@yahoo.com'),
('Tim', 'Brown', 'tbrown@aol.com');

INSERT INTO user_configuration (user_id) VALUES 
(1),
(2),
(3);

INSERT INTO dogs (user_id, name) VALUES
(1, 'Bella'),
(1, 'Georgie'),
(2, 'Penny'),
(2, 'Ginger'),
(3, 'Scout'),
(3, 'Goose');

INSERT INTO dog_logs (log_uuid, dog_id, date, note, log_type) VALUES
('d2504f3f-8623-40f3-8238-cd374a7b0000', 1, '2021-11-16 12:00:00', 'big pee', 'Potty: Pee'),
('d2504f3f-8623-40f3-8238-cd374a7b0001', 1, '2021-11-16 14:00:00', 'big poop', 6),
('d2504f3f-8623-40f3-8238-cd374a7b0002', 2, '2021-11-16 13:00:00', '', 7),
('d2504f3f-8623-40f3-8238-cd374a7b0003', 3, '2021-11-16 16:00:00', '', 2),
('d2504f3f-8623-40f3-8238-cd374a7b0004', 4, '2021-11-16 16:30:00', '', 3),
('d2504f3f-8623-40f3-8238-cd374a7b0005', 5, '2021-11-16 14:25:00', '', 4),
('d2504f3f-8623-40f3-8238-cd374a7b0006', 6, '2021-11-16 17:00:00', '', 9);

INSERT INTO dog_reminders (reminder_uuid, dog_id, reminder_type, timing_style, execution_basis, enabled) VALUES
('d2504f3f-8623-40f3-8238-cd374a7b1000', 1, 'Feed', 'Countdown', '2021-11-16 12:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1001', 1, 'Fresh Water', 'Countdown', '2021-11-16 14:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1002', 2, 'Feed', 'Countdown', '2021-11-16 16:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1003', 2, 'Potty', 'Countdown', '2021-11-16 15:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1004', 3, 'Feed', 'Weekly', '2021-11-16 12:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1005', 4, 'Doctor Visit', 'One Time', '2021-11-10 6:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1006', 5, 'Feed', 'Countdown', '2021-11-16 12:00:00', true),
('d2504f3f-8623-40f3-8238-cd374a7b1007', 6, 'Feed', 'Countdown', '2021-11-16 12:00:00', true);

INSERT INTO reminder_countdown_components (reminder_id, execution_interval, interval_elapsed) VALUES 
(1, 18000, 0),
(2, 7200, 0),
(3, 18000, 0),
(4, 3600, 0),
(5, NULL, NULL),
(6, NULL, NULL),
(7, 18000, 0),
(8, 18000, 0);

INSERT INTO reminder_snooze_components (reminder_id) VALUES
(1)
(2)
(3)
(4)
(5)
(6)
(7)
(8);

/*
INSERT INTO reminder_time_of_day_components (reminder_id)
blah, need to insert

INSERT INTO reminder_one_time_components (blah)
blah
*/


