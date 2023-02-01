-- Lab 5
-- pwylezek
-- Nov 11, 2022

USE `AIRLINES`;
-- AIRLINES-1
-- Find all airports with exactly 17 outgoing flights. Report airport code and the full name of the airport sorted in alphabetical order by the code.
SELECT flights.Source AS Code, airports.Name FROM flights
    JOIN airports ON flights.source = airports.code
GROUP BY flights.Source
HAVING COUNT(flights.FlightNo) = 17
ORDER BY Code;


USE `AIRLINES`;
-- AIRLINES-2
-- Find the number of airports from which airport ANP can be reached with exactly one transfer. Make sure to exclude ANP itself from the count. Report just the number.
SELECT  Count(DISTINCT f1.Source) AS AirportCount FROM flights AS f1
    JOIN flights AS f2 
WHERE f2.Destination = 'ANP' 
    AND f1.Destination = f2.Source 
    AND f1.Source != 'ANP';


USE `AIRLINES`;
-- AIRLINES-3
-- Find the number of airports from which airport ATE can be reached with at most one transfer. Make sure to exclude ATE itself from the count. Report just the number.
SELECT  Count(DISTINCT f1.Source) AS AirportCount FROM flights AS f1
    JOIN flights AS f2 
WHERE f2.Destination = 'ATE' 
    AND f1.Destination = f2.Source 
    AND f1.Source != 'ATE'
    OR f1.Destination = 'ATE';


USE `AIRLINES`;
-- AIRLINES-4
-- For each airline, report the total number of airports from which it has at least one outgoing flight. Report the full name of the airline and the number of airports computed. Report the results sorted by the number of airports in descending order. In case of tie, sort by airline name A-Z.
SELECT airlines.Name, COUNT(DISTINCT flights.Source) AS Airports FROM flights
    JOIN airlines ON airlines.Id = flights.Airline
GROUP BY flights.Airline
ORDER BY Airports DESC, airlines.Name ASC;


USE `BAKERY`;
-- BAKERY-1
-- For each flavor which is found in more than three types of items offered at the bakery, report the flavor, the average price (rounded to the nearest penny) of an item of this flavor, and the total number of different items of this flavor on the menu. Sort the output in ascending order by the average price.
SELECT goods.Flavor, ROUND(SUM(goods.Price)/COUNT(DISTINCT goods.Food) ,2) AS AveragePrice, COUNT(DISTINCT goods.Food) as DifferentPastries 
    FROM goods
GROUP BY goods.Flavor
HAVING DifferentPastries > 3
ORDER BY AveragePrice;


USE `BAKERY`;
-- BAKERY-2
-- Find the total amount of money the bakery earned in October 2007 from selling eclairs. Report just the amount.
SELECT SUM(Price) AS EclairRevenue FROM items 
    JOIN goods ON goods.GId = Item
WHERE goods.Food = 'Eclair'
GROUP BY Food;


USE `BAKERY`;
-- BAKERY-3
-- For each visit by NATACHA STENZ output the receipt number, sale date, total number of items purchased, and amount paid, rounded to the nearest penny. Sort by the amount paid, greatest to least.
SELECT receipts.RNumber, receipts.SaleDate, COUNT(Item) AS NumberOfItems, ROUND(SUM(Price),2) AS CheckAmount  FROM items
    JOIN receipts ON receipts.RNumber = items.Receipt
    JOIN customers ON receipts.Customer = customers.CId
    JOIN goods ON goods.GId = items.Item 
WHERE customers.FirstName='NATACHA' AND customers.LastName='STENZ'
GROUP BY items.Receipt
ORDER BY CheckAmount DESC;


USE `BAKERY`;
-- BAKERY-4
-- For the week starting October 8, report the day of the week (Monday through Sunday), the date, total number of purchases (receipts), the total number of pastries purchased, and the overall daily revenue rounded to the nearest penny. Report results in chronological order.
SELECT DAYNAME(receipts.SaleDate) AS Day, 
        receipts.SaleDate, 
        COUNT(DISTINCT receipts.RNumber) AS Receipts, 
        COUNT(items.Ordinal) AS Items, 
        ROUND(SUM(Price), 2) AS Revenue FROM items
    JOIN receipts ON receipts.RNumber = items.Receipt
    JOIN goods ON goods.GId = items.Item 
WHERE receipts.SaleDate BETWEEN '2007-10-8' AND '2007-10-14'
GROUP BY receipts.SaleDate
ORDER BY receipts.SaleDate;


USE `BAKERY`;
-- BAKERY-5
-- Report all dates on which more than ten tarts were purchased, sorted in chronological order.
SELECT receipts.SaleDate FROM items
    JOIN goods ON goods.GId = items.Item
    JOIN receipts ON receipts.RNumber = items.Receipt
WHERE goods.Food = 'Tart'
GROUP BY receipts.SaleDate
HAVING COUNT(items.Item) > 10;


USE `CSU`;
-- CSU-1
-- For each campus that averaged more than $2,500 in fees between the years 2000 and 2005 (inclusive), report the campus name and total of fees for this six year period. Sort in ascending order by fee.
SELECT campuses.Campus, SUM(fees.Fee) AS Total FROM campuses
    JOIN fees ON fees.CampusId = campuses.Id
WHERE fees.Year BETWEEN 2000 AND 2005
GROUP BY campuses.Id
HAVING SUM(fees.Fee)/COUNT(fees.fee) > 2500
ORDER BY Total ASC;


USE `CSU`;
-- CSU-2
-- For each campus for which data exists for more than 60 years, report the campus name along with the average, minimum and maximum enrollment (over all years). Sort your output by average enrollment.
SELECT campuses.Campus, SUM(enrollments.Enrolled)/COUNT(enrollments.Year) AS Average, MIN(enrollments.Enrolled) AS MIN, MAX(enrollments.Enrolled) AS MAX FROM campuses
    JOIN enrollments ON enrollments.CampusId = campuses.Id
GROUP BY enrollments.CampusId
HAVING COUNT(enrollments.Year) > 60
ORDER BY Average;


USE `CSU`;
-- CSU-3
-- For each campus in LA and Orange counties report the campus name and total number of degrees granted between 1998 and 2002 (inclusive). Sort the output in descending order by the number of degrees.

SELECT campuses.Campus, SUM(degrees.degrees) AS Total FROM campuses
    JOIN degrees ON degrees.CampusId = campuses.Id
WHERE (County = 'Los Angeles' OR County = 'Orange') AND degrees.year BETWEEN 1998 AND 2002
GROUP BY degrees.CampusId
ORDER BY Total DESC;


USE `CSU`;
-- CSU-4
-- For each campus that had more than 20,000 enrolled students in 2004, report the campus name and the number of disciplines for which the campus had non-zero graduate enrollment. Sort the output in alphabetical order by the name of the campus. (Exclude campuses that had no graduate enrollment at all.)
SELECT campuses.Campus, COUNT(*) FROM campuses 
    JOIN enrollments ON enrollments.CampusId = campuses.Id
    JOIN discEnr ON discEnr.CampusId = campuses.Id
WHERE enrollments.Year = 2004 AND enrollments.Enrolled > 20000 AND discEnr.Gr > 0
GROUP BY campuses.Id
ORDER BY campuses.Campus;


USE `INN`;
-- INN-1
-- For each room, report the full room name, total revenue (number of nights times per-night rate), and the average revenue per stay. In this summary, include only those stays that began in the months of September, October and November of calendar year 2010. Sort output in descending order by total revenue. Output full room names.
SELECT RoomName ,SUM(DATEDIFF(CheckOut,CheckIn)*Rate) AS TotalRevenue, ROUND(SUM(DATEDIFF(CheckOut,CheckIn)*Rate)/COUNT(*),2) AS AveragePerStay  FROM reservations
    JOIN rooms ON  rooms.RoomCode = reservations.Room
    WHERE (MONTHNAME(CheckIn) = 'September' OR MONTHNAME(CheckIn) = 'October' OR MONTHNAME(CheckIn) = 'November')
GROUP BY RoomName
ORDER BY TotalRevenue DESC;


USE `INN`;
-- INN-2
-- Report the total number of reservations that began on Fridays, and the total revenue they brought in.
SELECT COUNT(*) AS Stays, SUM(DATEDIFF(Checkout,CheckIn)*Rate) AS REVENUE FROM reservations
WHERE DAYNAME(CheckIn) = 'Friday';


USE `INN`;
-- INN-3
-- List each day of the week. For each day, compute the total number of reservations that began on that day, and the total revenue for these reservations. Report days of week as Monday, Tuesday, etc. Order days from Sunday to Saturday.
SELECT DAYNAME(CheckIn) AS Day, COUNT(*) AS STAYS, SUM(DATEDIFF(Checkout, CheckIn) * Rate) AS REVENUE FROM reservations
GROUP BY DAYNAME(CheckIn)
ORDER BY FIELD(Day, 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY');


USE `INN`;
-- INN-4
-- For each room list full room name and report the highest markup against the base price and the largest markdown (discount). Report markups and markdowns as the signed difference between the base price and the rate. Sort output in descending order beginning with the largest markup. In case of identical markup/down sort by room name A-Z. Report full room names.
SELECT RoomName, MAX(Rate-baseprice) AS Markup, MIN(Rate-basePrice) AS Discount FROM rooms
    JOIN reservations ON reservations.Room = rooms.RoomCode
GROUP BY RoomCode
ORDER BY Markup DESC, RoomName;


USE `INN`;
-- INN-5
-- For each room report how many nights in calendar year 2010 the room was occupied. Report the room code, the full name of the room, and the number of occupied nights. Sort in descending order by occupied nights. (Note: this should be number of nights during 2010. Some reservations extend beyond December 31, 2010. The ”extra” nights in 2011 must be deducted).
SELECT RoomCode, RoomName, SUM(CASE 
                                    WHEN CheckIn >= '2010-01-01' AND Checkout <= '2010-12-31' THEN DATEDIFF(Checkout, CheckIn)
                                    WHEN Checkout > '2010-12-31' AND CheckIn < '2010-01-01' THEN 365
                                    WHEN Checkout > '2010-12-31' AND CheckIn >= '2010-01-01' THEN DATEDIFF('2010-12-31', CheckIn)+1
                                END) 
                AS DaysOccupied FROM reservations
    JOIN rooms ON rooms.RoomCode = reservations.Room
WHERE CheckIn <= '2010-12-31' 
GROUP BY Room
ORDER BY DaysOccupied DESC;


USE `KATZENJAMMER`;
-- KATZENJAMMER-1
-- For each performer, report first name and how many times she sang lead vocals on a song. Sort output in descending order by the number of leads. In case of tie, sort by performer first name (A-Z.)
SELECT Firstname, COUNT(*) AS `Lead` FROM Band 
    JOIN Vocals ON Vocals.Bandmate = Band.Id
WHERE Vocals.VocalType = 'Lead'
GROUP BY Firstname
ORDER BY `Lead` DESC, Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-2
-- Report how many different instruments each performer plays on songs from the album 'Le Pop'. Include performer's first name and the count of different instruments. Sort the output by the first name of the performers.
SELECT Firstname, COUNT(DISTINCT Instrument) AS InstrumentCount FROM Band
    JOIN Albums
    JOIN Tracklists ON Tracklists.Album = Albums.AId
    JOIN Instruments ON Instruments.Bandmate = Band.Id AND Tracklists.Song = Instruments.Song
WHERE Albums.Title = 'Le Pop'
GROUP BY Firstname
ORDER BY Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-3
-- List each stage position along with the number of times Turid stood at each stage position when performing live. Sort output in ascending order of the number of times she performed in each position.

SELECT StagePosition, COUNT(*) AS Count FROM Performance
    JOIN Band ON Band.Id = Performance.Bandmate
WHERE Band.Firstname = 'Turid'
GROUP BY StagePosition
ORDER BY Count ASC;


USE `KATZENJAMMER`;
-- KATZENJAMMER-4
-- Report how many times each performer (other than Anne-Marit) played bass balalaika on the songs where Anne-Marit was positioned on the left side of the stage. List performer first name and a number for each performer. Sort output alphabetically by the name of the performer.

SELECT b1.Firstname, COUNT(*) AS Bass FROM Band AS b1
    JOIN Instruments ON Instruments.Bandmate = b1.Id
    JOIN Performance AS p1 ON p1.Bandmate = b1.Id AND p1.Song = Instruments.Song
    JOIN Band AS b2 
    JOIN Performance AS p2 ON p2.Bandmate = b2.Id AND p2.Song = Instruments.Song
WHERE b1.FirstName!='Anne-Marit' AND Instruments.Instrument='bass balalaika' AND b2.FirstName='Anne-Marit' AND p2.StagePosition='left' 
GROUP BY b1.Firstname
ORDER BY b1.Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-5
-- Report all instruments (in alphabetical order) that were played by three or more people.
SELECT Instrument FROM Instruments
GROUP BY Instrument
HAVING Count(DISTINCT Bandmate) >= 3
ORDER BY Instrument;


USE `KATZENJAMMER`;
-- KATZENJAMMER-6
-- For each performer, list first name and report the number of songs on which they played more than one instrument. Sort output in alphabetical order by first name of the performer
SELECT Firstname, COUNT(DISTINCT i1.Song) AS MultiInstrumentCount FROM Band
    JOIN Instruments AS i1 ON i1.Bandmate = Band.Id
    JOIN Instruments AS i2 ON i2.Bandmate = Band.Id AND i1.Bandmate = i2.Bandmate
WHERE i1.Instrument < i2.Instrument 
    AND i1.Song = i2.Song
GROUP BY Firstname;


USE `MARATHON`;
-- MARATHON-1
-- List each age group and gender. For each combination, report total number of runners, the overall place of the best runner and the overall place of the slowest runner. Output result sorted by age group and sorted by gender (F followed by M) within each age group.
SELECT AgeGroup, Sex, COUNT(*) AS Runners, MIN(Place) AS BestPlacing, MAX(Place) AS SlowestPacing
    FROM marathon
GROUP BY AgeGroup, Sex
ORDER BY AgeGroup, Sex;


USE `MARATHON`;
-- MARATHON-2
-- Report the total number of gender/age groups for which both the first and the second place runners (within the group) are from the same state.
SELECT COUNT(DISTINCT m1.AgeGroup) 
FROM marathon AS m1
    JOIN marathon AS m2 ON m1.AgeGroup = m2.AgeGroup 
        AND m1.Sex = m2.Sex
WHERE m1.GroupPlace = 1 
    AND m2.GroupPlace = 2 
    AND m1.State = m2.State;


USE `MARATHON`;
-- MARATHON-3
-- For each full minute, report the total number of runners whose pace was between that number of minutes and the next. In other words: how many runners ran the marathon at a pace between 5 and 6 mins, how many at a pace between 6 and 7 mins, and so on.
SELECT FLOOR(pace/100) AS PaceMinutes, COUNT(*) AS Count
    FROM marathon
GROUP BY PaceMinutes;


USE `MARATHON`;
-- MARATHON-4
-- For each state with runners in the marathon, report the number of runners from the state who finished in top 10 in their gender-age group. If a state did not have runners in top 10, do not output information for that state. Report state code and the number of top 10 runners. Sort in descending order by the number of top 10 runners, then by state A-Z.
SELECT State, Count(*) AS NumberOfTop10
    FROM marathon
WHERE GroupPlace <= 10
GROUP BY State
ORDER BY NumberOfTop10 DESC, State;


USE `MARATHON`;
-- MARATHON-5
-- For each Connecticut town with 3 or more participants in the race, report the town name and average time of its runners in the race computed in seconds. Output the results sorted by the average time (lowest average time first).
SELECT Town, ROUND(AVG(TIME_TO_SEC(RunTime)),1) AS AverageTimeInSeconds FROM marathon
WHERE State='CT'
GROUP BY State, Town
HAVING COUNT(*) >= 3
ORDER BY AverageTimeInSeconds;


USE `STUDENTS`;
-- STUDENTS-1
-- Report the last and first names of teachers who have between seven and eight (inclusive) students in their classrooms. Sort output in alphabetical order by the teacher's last name.
SELECT Last, First FROM teachers
    NATURAL JOIN list
GROUP BY classroom
HAVING COUNT(*) BETWEEN 7 AND 8
ORDER BY Last;


USE `STUDENTS`;
-- STUDENTS-2
-- For each grade, report the grade, the number of classrooms in which it is taught, and the total number of students in the grade. Sort the output by the number of classrooms in descending order, then by grade in ascending order.

SELECT Grade, COUNT(DISTINCT classroom) AS Classrooms, COUNT(*) AS Students FROM list
GROUP BY Grade
ORDER BY Classrooms DESC, Grade ASC;


USE `STUDENTS`;
-- STUDENTS-3
-- For each Kindergarten (grade 0) classroom, report classroom number along with the total number of students in the classroom. Sort output in the descending order by the number of students.
SELECT classroom, COUNT(*) AS Students FROM list
WHERE grade = 0
GROUP BY classroom
ORDER BY Students DESC;


USE `STUDENTS`;
-- STUDENTS-4
-- For each fourth grade classroom, report the classroom number and the last name of the student who appears last (alphabetically) on the class roster. Sort output by classroom.
SELECT classroom, MAX(LastName) AS LastOnRoster FROM list 
WHERE grade = 4
GROUP BY classroom
ORDER BY classroom;


