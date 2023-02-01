-- Final Exam Part b
-- pwylezek
-- Dec 8, 2022

USE `pwylezek`;
-- DDL-1
-- Define the following relations: book(isbn, title, author, pub_date), patron(id, first_name, last_name, sign_up), borrow(patron, book, check_out_date, due_date). Define constraints sufficient to pass all test cases.
CREATE TRIGGER checkOutLessThanDueDate 
BEFORE INSERT 
ON borrow FOR EACH ROW
    BEGIN
        IF NEW.check_out_date > NEW.due_date THEN
            SIGNAL SQLSTATE '45000';
        END IF;
    END;


USE `pwylezek`;
-- DDL-2
-- Add a new relation: late_notice(patron, book, check_out_date, notice_date)  Define constraints sufficient to pass all test cases. You do not need to define any additional constraints beyond those exercised by the test cases.
CREATE TRIGGER checkForValidBorrow
BEFORE INSERT 
ON late_notice FOR EACH ROW
    BEGIN
        IF (SELECT COUNT(*) 
                FROM borrow 
                WHERE patron = NEW.patron
                    AND book = NEW.book
                    AND check_out_date = NEW.check_out_date) = 0 THEN
            SIGNAL SQLSTATE '45000';
        END IF;
    END;


USE `pwylezek`;
-- DML-1
-- Add sample data to your library tables. Ensure that there are at least 6 "borrow" rows, 3 of which should represent patrons borrowing a book on their date of sign up (these need not be the same patron)  Also add 2 late notices.
INSERT INTO book (isbn, title, author, pub_date) VALUES
    ('69722', 'Book 1', 'Philippe Wylezek-Serrano', '2001-03-01'),
    ('83645', 'Book 2', 'Makayla Ware', '2001-10-10'),
    ('18571', 'Book 3', 'Samuel Ricci', null);
	
INSERT INTO patron (id, first_name, last_name, sign_up) VALUES 
    (1, 'Josh', 'Rowe', CURRENT_DATE),
    (2, 'Edward', 'Tompson', DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY)),
    (3, 'Mikkie', 'Hayes', DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY));

INSERT INTO borrow (patron, book, check_out_date, due_date) VALUES 
    (1, '69722', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 5 DAY)),
    (1, '18571', '2021-09-05', '2021-09-24'),
    (2, '69722', DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY)),
    (2, '83645', '2021-05-02', '2021-05-18'),
    (3, '83645', DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY)),
    (3, '18571', '2021-04-01', '2021-04-15');
  
  
INSERT INTO late_notice (patron, book, check_out_date, notice_date) VALUES
    (1, '69722', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)),
    (2, '69722', DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)),
    (3, '83645', DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY));


USE `pwylezek`;
-- DML-2
-- Write a single UPDATE statement to change the due date for all books borrowed on same day as the borrowing patron's sign-up. These due dates should be changed to exactly 30 days after patron sign-up. 
UPDATE borrow
    JOIN patron ON patron.id = borrow.patron
SET due_date = DATE_ADD(sign_up, INTERVAL 30 DAY)
WHERE borrow.check_out_date = patron.sign_up;


USE `BAKERY`;
-- BAKERY-1
-- Based on purchase count, which items(s) are more popular on Fridays than Mondays? Report food, flavor, and purchase counts for Monday and Friday as two separate columns. Report a count of 0 if a given item has not been purchased on that day. Sort by food then flavor, both in A-Z order.
WITH MFG AS (
    SELECT Flavor, Food, DAYNAME(SaleDate) AS Day, COUNT(*) AS DayCount FROM receipts
        JOIN items ON items.receipt = receipts.RNumber
        JOIN goods ON goods.gID = items.item
    WHERE DAYNAME(SaleDate) = 'Monday'
        OR DAYNAME(SaleDate) = 'Friday'
    GROUP BY Flavor, Food, Day
    )
SELECT g.Food, g.Flavor, 
        IF(mfg1.DayCount IS NULL, 0, mfg1.DayCount) AS MondayCount, 
        IF(mfg2.DayCount IS NULL, 0, mfg2.DayCount) AS FridayCount
    FROM goods g
        LEFT JOIN MFG mfg1 ON mfg1.Flavor = g.Flavor AND mfg1.Food = g.Food AND mfg1.Day = 'Monday'
        LEFT JOIN MFG mfg2 ON mfg2.Flavor = g.Flavor AND mfg2.Food = g.Food AND mfg2.Day = 'Friday'
HAVING MondayCount < FridayCount
ORDER BY Food, Flavor;


USE `BAKERY`;
-- BAKERY-2
-- Find all pairs of customers who have purchased the exact same combination of cookie flavors. For example, customers with ID 1 and 10 have each purchased at least one Marzipan cookie and neither customer has purchased any other flavor of cookie. Report each pair of customers just once, sort by the numerically lower customer ID. The MySQL-specific GROUP_CONCAT and JSON_ARRAYAGG functions are not permitted.
-- Cookies Per Customer
-- Flavor Per Customer
-- Flavor Customer Matches
WITH CPC AS (
        SELECT DISTINCT cID, Flavor, FirstName, LastName FROM receipts
            JOIN items ON items.receipt = receipts.RNumber
            JOIN goods ON goods.gID = items.item
            JOIN customers ON customers.cID = receipts.customer
        WHERE goods.Food = 'Cookie'
        ),
FPC AS (
    SELECT cID, COUNT(DISTINCT Flavor) AS DistFlav FROM CPC
    GROUP BY cID
    ),
FCM AS (
    SELECT cpc1.cID AS c1, cpc1.FirstName AS fn1, cpc1.LastName AS ln1, 
           cpc2.cID AS c2, cpc2.FirstName AS fn2, cpc2.LastName AS ln2,
           COUNT(*) AS Matches 
        FROM CPC cpc1
            JOIN CPC cpc2 ON cpc2.Flavor = cpc1.Flavor 
                            AND cpc2.cID != cpc1.cID
    GROUP BY cpc1.cID, cpc2.cID
    )
SELECT c1, ln1, fn1, c2, ln2, fn2 FROM FCM 
    JOIN FPC fpc1 ON fpc1.cID = FCM.c1
    JOIN FPC fpc2 ON fpc2.cID = FCM.c2
WHERE Matches = fpc1.DistFlav 
    AND Matches = fpc2.DistFlav
    AND c1 < c2
ORDER BY c1;


USE `AIRLINES`;
-- AIRLINES-1
-- Find the number of different destinations that can be reached starting from airport ABQ, flying a one-transfer route with both flights on the same airline. Report a single integer: the number of destinations.
SELECT COUNT(DISTINCT f2.Destination) FROM flights f1
    JOIN flights f2 ON f1.Airline = f2.Airline AND f1.Destination = f2.Source
WHERE f1.Source = 'ABQ' 
    AND f2.Destination != 'ABQ';


USE `AIRLINES`;
-- AIRLINES-2
-- List all airlines. For every airline, compute the number of regional airports (full name of airport contains the string 'Regional') from which that airline does NOT fly, considering source airport only. Sort by airport count in descending order.
WITH RA AS (
    SELECT * FROM airports
    WHERE airports.Name LIKE '%Regional%'
    ),
FCA AS(
    SELECT Airline, COUNT(*) AS Flies FROM (
        SELECT DISTINCT Airline, Code 
        FROM flights
            JOIN RA
        ORDER BY Airline
        ) fa
    GROUP BY Airline
    ),
FRA AS(
    SELECT Airline, COUNT(*) AS Flies FROM (
        SELECT Distinct Airline, Code 
        FROM flights
            JOIN RA ON RA.Code = flights.Source
            ) fma
    GROUP BY Airline
    )
SELECT airlines.Name, IF(FRA.Airline IS NULL, FCA.Flies, FCA.Flies - FRA.Flies) AS Total FROM FCA
    LEFT JOIN FRA ON FRA.Airline = FCA.Airline
    JOIN airlines ON airlines.Id = FCA.Airline
ORDER BY Total DESC, airlines.Name;


USE `AIRLINES`;
-- AIRLINES-3
-- List all airports from which airline Southwest operates more flights than Northwest. Include only airports that have at least one outgoing flight on Southwest and at least one on Northwest. List airport code along with counts for each airline as two separate columns. Order by source airport code.
WITH NSW AS (
    SELECT Airline, Abbr, Source, COUNT(*) AS Flies FROM flights
        JOIN airlines ON airlines.Id = flights.Airline
    WHERE airlines.Abbr = 'Northwest' 
        OR airlines.Abbr = 'Southwest'
    GROUP BY Airline, Source
    )
SELECT nsw1.Source, nsw2.Flies AS FlightsSW, nsw1.Flies AS FlightsNW FROM NSW nsw1
    JOIN NSW nsw2 ON nsw1.Source = nsw2.Source
WHERE nsw1.Abbr = 'NorthWest'
    AND nsw2.Abbr = 'Southwest'
    AND nsw2.Flies > nsw1.Flies
ORDER BY nsw1.Source;


USE `INN`;
-- INN-1
-- Find all reservations in room HBB that overlap by at least one day with any stay by customer with last name KNERIEN. Last last and first name along with checkin and checkout dates. Sort by check in date in chronological order.
WITH KR AS (
    SELECT CheckIn, Checkout FROM reservations
    WHERE LastName = 'KNERIEN' 
),
HR AS (
    SELECT * FROM reservations
    WHERE reservations.Room = 'HBB'
)
SELECT LastName, FirstName, HR.CheckIn, HR.Checkout FROM HR
    JOIN KR
WHERE (HR.CheckIn > KR.CheckIn AND HR.Checkout < KR.Checkout)
    OR (HR.CheckIn < KR.CheckIn AND HR.Checkout > KR.Checkout)
    OR (HR.CheckIn < KR.CheckIn AND HR.Checkout > KR.CheckIn AND HR.Checkout < KR.Checkout)
    OR (HR.Checkout > KR.Checkout AND HR.CheckIn > KR.CheckIn AND HR.CheckIn < KR.Checkout)
ORDER BY HR.CheckIn;


USE `INN`;
-- INN-2
-- Find all rooms that are unoccupied on both the night of March 20, 2010 and every night during the date range March 12, 2010 through March 14, 2010 (inclusive). List room code and room name, sort by room code A-Z.
SELECT RoomCode, RoomName FROM rooms
WHERE NOT EXISTS(
    SELECT *
    FROM reservations
    WHERE ((CheckIn <= '2010-03-14' AND CheckOut > '2010-03-12')
        OR (CheckIn < '2010-03-20' AND CheckOut > '2010-03-20'))
        AND RoomCode = Room
    )
ORDER BY RoomCode;


