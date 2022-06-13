USE Hound;
TRUNCATE TABLE users;
TRUNCATE TABLE userConfiguration;
TRUNCATE TABLE familyMembers;
TRUNCATE TABLE families;
TRUNCATE TABLE dogs;
TRUNCATE TABLE dogLogs;
TRUNCATE TABLE dogReminders;
TRUNCATE TABLE userRequestLogs;
TRUNCATE TABLE subscriptionTiers;

INSERT INTO subscriptionTiers(subscriptionId, subscriptonName, subscriptionPrice, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs) VALUES 
(1, 'Solo', 0.0, 1, 2),
(2, 'Duo', 2.99, 2, 2),
(3, 'Quad', 4.99, 4, 4),
(4, 'Hexad', 6.99, 6, 6),
(5, 'Decad', 9.99, 10, 8);
