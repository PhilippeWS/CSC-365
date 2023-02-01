-- Lab 6
-- pwylezek
-- Nov 26, 2022

USE `BAKERY`;
-- BAKERY-1
-- Find all customers who did not make a purchase between October 5 and October 11 (inclusive) of 2007. Output first and last name in alphabetical order by last name.
SELECT FirstName, LastName 
FROM customers
WHERE NOT EXISTS (
                SELECT DISTINCT Customer 
                FROM receipts 
                WHERE SaleDate BETWEEN '2007-10-5' AND '2007-10-11' AND customers.CId = receipts.Customer
                ORDER BY Customer
                )
ORDER BY FirstName, LastName;


USE `BAKERY`;
-- BAKERY-2
-- Find the customer(s) who spent the most money at the bakery during October of 2007. Report first, last name and total amount spent (rounded to two decimal places). Sort by last name.
WITH ReceiptSums AS (
                    SELECT FirstName, LastName, SUM(PRICE) AS Total 
                        FROM receipts
                            JOIN items ON items.Receipt = receipts.RNumber
                            JOIN goods ON goods.GId = items.Item
                            JOIN customers ON customers.CId = receipts.Customer
                    WHERE SaleDate BETWEEN '2007-10-01' AND '2007-10-31'
                    GROUP BY Customer)
SELECT FirstName, LastName, ROUND(ReceiptSums.Total, 2) 
FROM ReceiptSums
WHERE Total = (SELECT MAX(Total) FROM ReceiptSums);


USE `BAKERY`;
-- BAKERY-3
-- Find all customers who never purchased a twist ('Twist') during October 2007. Report first and last name in alphabetical order by last name.

SELECT FirstName, LastName 
FROM customers
WHERE NOT EXISTS (                
                SELECT DISTINCT Customer 
                FROM receipts
                    JOIN items ON items.Receipt = receipts.RNumber
                    JOIN goods ON goods.GId = items.item
                WHERE goods.Food = 'Twist' 
                    AND customers.CId = receipts.Customer
                )
ORDER BY LastName;


USE `BAKERY`;
-- BAKERY-4
-- Find the baked good(s) (flavor and food type) responsible for the most total revenue.
WITH ItemRev AS (
                SELECT Flavor, Food, SUM(PRICE) AS Total
                FROM items 
                    JOIN goods ON goods.GId = items.item
                GROUP BY Flavor, Food)
SELECT Flavor, Food 
FROM ItemRev
WHERE ItemRev.Total = (SELECT MAX(Total) FROM ItemRev);


USE `BAKERY`;
-- BAKERY-5
-- Find the most popular item, based on number of pastries sold. Report the item (flavor and food) and total quantity sold.
WITH ItemCount AS (
                SELECT Flavor, Food, COUNT(*) AS Count
                FROM items 
                    JOIN goods ON goods.GId = items.item
                GROUP BY Flavor, Food)
SELECT Flavor, Food, Count
FROM ItemCount
WHERE ItemCount.Count = (SELECT MAX(Count) FROM ItemCount);


USE `BAKERY`;
-- BAKERY-6
-- Find the date(s) of highest revenue during the month of October, 2007. In case of tie, sort chronologically.
WITH DateRev AS (
                SELECT SaleDate, SUM(PRICE) AS Total
                FROM receipts
                    JOIN items ON items.Receipt = receipts.RNumber
                    JOIN goods ON goods.GId = items.item
                GROUP BY SaleDate)
SELECT SaleDate
FROM DateRev
WHERE DateRev.Total = (SELECT MAX(Total) FROM DateRev)
ORDER BY SaleDate;


USE `BAKERY`;
-- BAKERY-7
-- Find the best-selling item(s) (by number of purchases) on the day(s) of highest revenue in October of 2007.  Report flavor, food, and quantity sold. Sort by flavor and food.
WITH ItemDateCount AS (
                SELECT Flavor, Food, SaleDate, COUNT(*) AS Count
                FROM receipts
                    JOIN items ON items.Receipt = receipts.RNumber
                    JOIN goods ON goods.GId = items.item
                WHERE SaleDate BETWEEN '2007-10-1' AND '2007-10-31'
                GROUP BY Flavor, Food, SaleDate
                )
,DateRev AS (
            SELECT SaleDate, SUM(PRICE) AS Total
            FROM receipts
                JOIN items ON items.Receipt = receipts.RNumber
                JOIN goods ON goods.GId = items.item
            WHERE SaleDate BETWEEN '2007-10-1' AND '2007-10-31'
            GROUP BY SaleDate
            
            )
,MaxDateRev AS (
                SELECT SaleDate
                FROM DateRev
                WHERE DateRev.Total = (SELECT MAX(Total) FROM DateRev)
                ORDER BY SaleDate
                ) 
SELECT Flavor, Food, Count
FROM ItemDateCount 
WHERE ItemDateCount.Count = (
                SELECT MAX(Count) 
                FROM ItemDateCount 
                WHERE SaleDate = (SELECT SaleDate FROM MaxDateRev) 
                )
    AND SaleDate = (SELECT SaleDate FROM MaxDateRev);


USE `BAKERY`;
-- BAKERY-8
-- For every type of Cake report the customer(s) who purchased it the largest number of times during the month of October 2007. Report the name of the pastry (flavor, food type), the name of the customer (first, last), and the quantity purchased. Sort output in descending order on the number of purchases, then in alphabetical order by last name of the customer, then by flavor.
WITH CakesBought AS (
                    SELECT FirstName, LastName, Flavor, Food, COUNT(*) AS Bought FROM receipts
                        JOIN items ON items.Receipt = receipts.RNumber                                            
                        JOIN goods ON goods.GId = items.item 
                        JOIN customers ON customers.CId = receipts.Customer
                    WHERE Food='Cake'
                    GROUP BY Flavor, Food, Customer
                    ),
MaxBought AS (
            SELECT Flavor, Food, MAX(Bought) AS Most
            FROM CakesBought
            GROUP BY Flavor, Food
            )
SELECT MaxBought.Flavor, MaxBought.Food, FirstName, LastName, Bought 
    FROM CakesBought
        JOIN MaxBought ON MaxBought.Most = CakesBought.Bought 
            AND MaxBought.Flavor = CakesBought.Flavor
ORDER BY Bought DESC, LastName, Flavor;


USE `BAKERY`;
-- BAKERY-9
-- Output the names of all customers who made multiple purchases (more than one receipt) on the latest day in October on which they made a purchase. Report names (last, first) of the customers and the *earliest* day in October on which they made a purchase, sorted in chronological order, then by last name.

WITH MMS AS (
            SELECT Customer, MAX(SaleDate) AS LastD, MIN(SaleDate) AS FirstD 
                FROM receipts
                JOIN customers ON customers.CId = receipts.Customer
            GROUP BY Customer
            )
SELECT LastName, FirstName, FirstD 
FROM MMS
    JOIN receipts ON MMS.Customer = receipts.Customer
    JOIN customers ON customers.CId = MMS.Customer 
WHERE receipts.SaleDate = MMS.LastD
GROUP BY MMS.Customer
HAVING COUNT(*) > 1
ORDER BY FirstD, LastName;


USE `BAKERY`;
-- BAKERY-10
-- Find out if sales (in terms of revenue) of Chocolate-flavored items or sales of Croissants (of all flavors) were higher in October of 2007. Output the word 'Chocolate' if sales of Chocolate-flavored items had higher revenue, or the word 'Croissant' if sales of Croissants brought in more revenue.

WITH Choc AS (
            SELECT SUM(Price) AS Total 
                FROM items 
                JOIN goods ON goods.GId = items.Item
            WHERE goods.Flavor = 'Chocolate'
            ),
Croiss AS (
        SELECT SUM(Price) AS Total
            FROM items 
            JOIN goods ON goods.GId = items.Item
        WHERE goods.Food = 'Croissant' 
        )
SELECT IF(Croiss.Total > Choc.Total, "Croissant", "Chocolate") AS Winner 
FROM Croiss, Choc;


USE `INN`;
-- INN-1
-- Find the most popular room(s) (based on the number of reservations) in the hotel  (Note: if there is a tie for the most popular room, report all such rooms). Report the full name of the room, the room code and the number of reservations.

-- Number of Reservations
WITH NoR AS (
            SELECT Room, COUNT(*) AS Stays
            FROM reservations
            GROUP BY reservations.Room
            )
SELECT RoomName, Room, NoR.Stays 
FROM NoR
    JOIN rooms ON rooms.RoomCode = NoR.Room
WHERE NoR.Stays = (SELECT MAX(Stays) FROM NoR);


USE `INN`;
-- INN-2
-- Find the room(s) that have been occupied the largest number of days based on all reservations in the database. Report the room name(s), room code(s) and the number of days occupied. Sort by room name.
-- Days Occupied
WITH DO AS (
        SELECT Room, SUM(DATEDIFF(Checkout, CheckIn)) AS Days 
        FROM reservations
        GROUP BY Room
        )
SELECT RoomName, DO.Room, DO.Days 
FROM DO
    JOIN rooms ON rooms.RoomCode = DO.Room
WHERE DO.Days = (SELECT MAX(Days) FROM DO);


USE `INN`;
-- INN-3
-- For each room, report the most expensive reservation. Report the full room name, dates of stay, last name of the person who made the reservation, daily rate and the total amount paid (rounded to the nearest penny.) Sort the output in descending order by total amount paid.
WITH Pays AS(
            SELECT Room, Code, DATEDIFF(Checkout, CheckIn)*Rate AS Paid 
            FROM reservations
            ),
MaxPays AS (
        SELECT Room, MAX(Paid) AS Most
        FROM Pays
        GROUP BY Room
        )
SELECT RoomName, CheckIn, CheckOut, LastName, Rate, Paid FROM MaxPays
    JOIN Pays ON Pays.Room = MaxPays.Room
    JOIN reservations ON reservations.Code = Pays.Code
    JOIN rooms ON RoomCode = reservations.Room
WHERE Paid = Most
ORDER BY Paid DESC;


USE `INN`;
-- INN-4
-- For each room, report whether it is occupied or unoccupied on July 4, 2010. Report the full name of the room, the room code, and either 'Occupied' or 'Empty' depending on whether the room is occupied on that day. (the room is occupied if there is someone staying the night of July 4, 2010. It is NOT occupied if there is a checkout on this day, but no checkin). Output in alphabetical order by room code. 
SELECT RoomName, RoomCode, IF(r.Room IS NULL, 'Empty', 'Occupied') AS Jul4Status FROM rooms
    LEFT JOIN (
                SELECT Room
                FROM reservations 
                WHERE Checkin <= '2010-07-04' AND CheckOut > '2010-07-04'
                ) r ON rooms.RoomCode = r.Room
ORDER BY RoomCode;


USE `INN`;
-- INN-5
-- Find the highest-grossing month (or months, in case of a tie). Report the month name, the total number of reservations and the revenue. For the purposes of the query, count the entire revenue of a stay that commenced in one month and ended in another towards the earlier month. (e.g., a September 29 - October 3 stay is counted as September stay for the purpose of revenue computation). In case of a tie, months should be sorted in chronological order.
WITH MGI AS (
            SELECT MONTHNAME(CheckIn) AS Month, COUNT(*) AS NReservations, ROUND(SUM(DATEDIFF(Checkout, CheckIn)*Rate),2) AS MonthlyRevenue 
            FROM reservations 
            GROUP BY MONTHNAME(CheckIn)
            )
SELECT * 
FROM MGI
WHERE MonthlyRevenue = (SELECT MAX(MonthlyRevenue) FROM MGI)
ORDER BY Month;


USE `STUDENTS`;
-- STUDENTS-1
-- Find the teacher(s) with the largest number of students. Report the name of the teacher(s) (last, first) and the number of students in their class.

WITH SPT AS (
            SELECT Last, First, COUNT(*) AS nstudents FROM teachers
            NATURAL JOIN list
            GROUP BY Last, First
            )
SELECT *
FROM SPT
WHERE nstudents = (SELECT MAX(nstudents) FROM SPT);


USE `STUDENTS`;
-- STUDENTS-2
-- Find the grade(s) with the largest number of students whose last names start with letters 'A', 'B' or 'C' Report the grade and the number of students. In case of tie, sort by grade number.
WITH SPG AS (
            SELECT Grade, COUNT(*) AS ABCCount FROM list
            WHERE LastName LIKE 'A%' 
                OR LastName LIKE 'B%' 
                OR LastName LIKE 'C%' 
            GROUP BY grade
            )
SELECT * 
FROM SPG
WHERE ABCCount = (SELECT MAX(ABCCount) FROM SPG)
ORDER BY Grade;


USE `STUDENTS`;
-- STUDENTS-3
-- Find all classrooms which have fewer students in them than the average number of students in a classroom in the school. Report the classroom numbers and the number of student in each classroom. Sort in ascending order by classroom.
WITH CPC AS (
            SELECT ClassRoom, Count(*) AS ns
            FROM list
            GROUP BY ClassRoom
            ),
APC AS (
        SELECT SUM(ns)/COUNT(*) FROM CPC
        )
SELECT * 
FROM CPC
WHERE ns < (SELECT * FROM APC)
ORDER BY ClassRoom ASC;


USE `STUDENTS`;
-- STUDENTS-4
-- Find all pairs of classrooms with the same number of students in them. Report each pair only once. Report both classrooms and the number of students. Sort output in ascending order by the number of students in the classroom.
-- Count Per Classroom
WITH CPC AS (
            SELECT ClassRoom, Count(*) AS StudentCount
            FROM list
            GROUP BY ClassRoom
            )
SELECT cpc1.ClassRoom, cpc2.ClassRoom, cpc2.StudentCount FROM CPC cpc1
    JOIN CPC cpc2
WHERE cpc1.ClassRoom < cpc2.ClassRoom
    AND cpc1.StudentCount = cpc2.StudentCount
ORDER BY cpc2.StudentCount ASC;


USE `STUDENTS`;
-- STUDENTS-5
-- For each grade with more than one classroom, report the grade and the last name of the teacher who teaches the classroom with the largest number of students in the grade. Output results in ascending order by grade.
-- Multiple Classroom Grades
-- Students Per Classroom
-- Max Per Grade
WITH MCG AS (
            SELECT grade AS MCGgrade, COUNT(DISTINCT Classroom) AS NoC 
            FROM list
            GROUP BY list.grade
            HAVING NoC > 1
            ),
SPC AS (
        SELECT  Grade, Last, Classroom, COUNT(*) AS NoS 
        FROM list
            NATURAL JOIN teachers
            JOIN MCG ON list.grade = MCG.MCGgrade
        GROUP BY ClassRoom, Grade
        ),
MPG AS (
        SELECT Grade, MAX(NoS) AS GMS 
        FROM SPC
        GROUP BY Grade
        )
SELECT DISTINCT list.grade, teachers.Last
FROM teachers
    NATURAL JOIN list
    JOIN SPC ON SPC.Classroom = teachers.classroom
    JOIN MPG ON MPG.GMS = SPC.Nos
ORDER BY list.grade;


USE `CSU`;
-- CSU-1
-- Find the campus(es) with the largest enrollment in 2000. Output the name of the campus and the enrollment. Sort by campus name.

-- 2 Thousand(k) Enrollment
WITH 2kE AS (
            SELECT CampusId, Enrolled FROM enrollments
            WHERE year = 2000
            )
SELECT campuses.Campus, 2kE.Enrolled FROM 2kE
    JOIN campuses ON campuses.Id = 2kE.CampusId
WHERE 2kE.Enrolled = (SELECT MAX(Enrolled) FROM 2kE)
ORDER BY campuses.Campus;


USE `CSU`;
-- CSU-2
-- Find the university (or universities) that granted the highest average number of degrees per year over its entire recorded history. Report the name of the university, sorted alphabetically.

WITH ACD AS (
            SELECT CampusId, ROUND(SUM(degrees)/COUNT(*), 0) AS AvDeg 
            FROM degrees
            GROUP BY CampusId
            )
SELECT campuses.Campus FROM ACD
    JOIN campuses ON campuses.Id = ACD.CampusId
WHERE ACD.AvDeg = (SELECT MAX(AvDeg) FROM ACD)
ORDER BY campuses.Campus;


USE `CSU`;
-- CSU-3
-- Find the university with the lowest student-to-faculty ratio in 2003. Report the name of the campus and the student-to-faculty ratio, rounded to one decimal place. Use FTE numbers for enrollment. In case of tie, sort by campus name.
WITH SPF AS (
            SELECT faculty.CampusId, ROUND(enrollments.FTE/faculty.FTE,1) AS StPerFa 
            FROM enrollments
                JOIN faculty ON faculty.CampusId = enrollments.CampusId 
            WHERE enrollments.year = 2003 
                AND faculty.year = enrollments.year
            )
SELECT Campus, StPerFa 
FROM SPF 
    JOIN campuses ON campuses.Id = SPF.CampusId
WHERE StPerFa = (SELECT MIN(StPerFa) FROM SPF)
ORDER BY Campus;


USE `CSU`;
-- CSU-4
-- Among undergraduates studying 'Computer and Info. Sciences' in the year 2004, find the university with the highest percentage of these students (base percentages on the total from the enrollments table). Output the name of the campus and the percent of these undergraduate students on campus. In case of tie, sort by campus name.
WITH CSS AS (
            SELECT discEnr.CampusId, ROUND((Ug/Enrolled)*100,1) AS Percent FROM discEnr
                JOIN disciplines ON  disciplines.Id = discEnr.Discipline
                JOIN enrollments ON enrollments.CampusId = discEnr.CampusId
            WHERE Name = 'Computer and Info. Sciences'
                AND discEnr.Year = 2004 AND discEnr.Year = enrollments.year
            )
SELECT campuses.Campus, Percent 
FROM CSS
    JOIN campuses ON campuses.Id = CSS.CampusId
WHERE Percent = (SELECT MAX(Percent) FROM CSS)
ORDER BY campuses.Campus;


USE `CSU`;
-- CSU-5
-- For each year between 1997 and 2003 (inclusive) find the university with the highest ratio of total degrees granted to total enrollment (use enrollment numbers). Report the year, the name of the campuses, and the ratio. List in chronological order.
-- Degree Enrollment Ratio
-- Degree Enrollment Max
WITH DER AS (
            SELECT degrees.CampusId, degrees.Year, ROUND(degrees/Enrolled,4) AS Ratio
            FROM degrees
                JOIN enrollments ON enrollments.Year = degrees.year 
                    AND enrollments.CampusId = degrees.CampusId
            WHERE degrees.Year BETWEEN 1997 AND 2003
            ),
DEM AS (
        SELECT Year, MAX(Ratio) MRatio
        FROM DER
        GROUP BY Year
        )
SELECT DEM.Year, Campus, DEM.MRatio 
FROM DER
    JOIN DEM ON DEM.Year = DER.Year
    JOIN campuses ON campuses.Id =  DER.CampusId
WHERE DEM.MRatio = DER.Ratio
ORDER BY DEM.Year;


USE `CSU`;
-- CSU-6
-- For each campus report the year of the highest student-to-faculty ratio, together with the ratio itself. Sort output in alphabetical order by campus name. Use FTE numbers to compute ratios and round to two decimal places.
WITH SPF AS (
            SELECT faculty.CampusId, faculty.Year, ROUND(enrollments.FTE/faculty.FTE,2) AS StPerFa 
            FROM enrollments
                JOIN faculty ON faculty.CampusId = enrollments.CampusId 
            WHERE faculty.year = enrollments.year
            ),
MSF AS (
        SELECT CampusID, MAX(StPerFa) AS MaxSPF
        FROM SPF 
        GROUP BY CampusId
        )
SELECT Campus, SPF.Year, SPF.StPerFa
FROM SPF
    JOIN MSF ON MSF.CampusId = SPF.CampusId
    JOIN campuses ON campuses.Id = SPF.CampusId
WHERE StPerFa = MSF.MaxSPF
ORDER BY Campus;


USE `CSU`;
-- CSU-7
-- For each year for which the data is available, report the total number of campuses in which student-to-faculty ratio became worse (i.e. more students per faculty) as compared to the previous year. Report in chronological order.

WITH SPF AS (
            SELECT faculty.CampusId, faculty.Year, ROUND(enrollments.FTE/faculty.FTE,2) AS StPerFa 
            FROM enrollments
                JOIN faculty ON faculty.CampusId = enrollments.CampusId 
            WHERE faculty.year = enrollments.year
            )
SELECT spf2.Year, COUNT(*) FROM SPF spf1
    JOIN SPF spf2 ON spf2.CampusId = spf1.CampusId
WHERE spf2.Year = spf1.Year+1
    AND spf2.StPerFa > spf1.StPerFa
GROUP BY spf2.Year
ORDER BY spf2.Year;


USE `MARATHON`;
-- MARATHON-1
-- Find the state(s) with the largest number of participants. List state code(s) sorted alphabetically.

-- Runners Per State
WITH RPS AS (
            SELECT State, COUNT(*) AS Runners
            FROM marathon
            GROUP BY State
            )
SELECT State 
    FROM RPS
WHERE Runners = (SELECT MAX(Runners) FROM RPS);


USE `MARATHON`;
-- MARATHON-2
-- Find all towns in Rhode Island (RI) which fielded more female runners than male runners for the race. Include only those towns that fielded at least 1 male runner and at least 1 female runner. Report the names of towns, sorted alphabetically.

-- Female Male Runners
WITH FMR AS (
            SELECT Sex, Town, COUNT(*) AS Count
            FROM marathon
            WHERE STATE = 'RI'
            GROUP BY Sex, Town
            )
SELECT fmr1.Town FROM FMR fmr1
    JOIN FMR fmr2 ON fmr2.Town = fmr1.Town
WHERE fmr1.Sex != fmr2.Sex
    AND fmr1.Sex = 'M'
    AND fmr2.Sex = 'F'
    AND fmr1.Count < fmr2.Count 
    AND fmr2.Count > 0
ORDER BY fmr1.Town;


USE `MARATHON`;
-- MARATHON-3
-- For each state, report the gender-age group with the largest number of participants. Output state, age group, gender, and the number of runners in the group. Report only information for the states where the largest number of participants in a gender-age group is greater than one. Sort in ascending order by state code, age group, then gender.
-- Runners Per Group
-- Max Per State
WITH RPG AS (
            SELECT State, AgeGroup, Sex, COUNT(*) NoR 
            FROM marathon
            GROUP BY State, AgeGroup, Sex
            ),
MPS AS (
        SELECT State, MAX(NoR) MNoR
        FROM RPG
        GROUP BY State
        )
SELECT RPG.State, AgeGroup, Sex, NoR FROM RPG
    JOIN MPS ON MPS.State = RPG.State
WHERE MPS.MNoR = RPG.Nor
    AND MPS.MNoR > 1
ORDER BY MPS.State, AgeGroup, Sex;


USE `MARATHON`;
-- MARATHON-4
-- Find the 30th fastest female runner. Report her overall place in the race, first name, and last name. This must be done using a single SQL query (which may be nested) that DOES NOT use the LIMIT clause. Think carefully about what it means for a row to represent the 30th fastest (female) runner.
WITH ER AS (
            SELECT ROW_NUMBER() OVER (ORDER BY Place) AS RN, Place, FirstName, LastName 
            FROM marathon
            WHERE Sex = 'F' 
            ORDER BY Place
            )
SELECT Place, FirstName, LastName
FROM ER 
WHERE RN = 30;


USE `MARATHON`;
-- MARATHON-5
-- For each town in Connecticut report the total number of male and the total number of female runners. Both numbers shall be reported on the same line. If no runners of a given gender from the town participated in the marathon, report 0. Sort by number of total runners from each town (in descending order) then by town.

WITH GCR AS (
            SELECT Town, Sex, COUNT(*) NoR 
            FROM marathon
            WHERE State = 'CT'
            GROUP BY Town, Sex
            ORDER BY Sex, Town 
            ),
RPT AS (
        SELECT DISTINCT marathon.Town, s.Sex, NoR 
        FROM marathon
            JOIN (SELECT DISTINCT Sex FROM marathon) s
            LEFT JOIN GCR ON GCR.Sex = s.Sex 
                AND GCR.Town = marathon.Town 
        WHERE marathon.State = 'CT'
        )
SELECT rpt1.Town, IF(rpt1.NoR IS NULL, 0, rpt1.NoR) AS Men, IF(rpt2.NoR IS NULL, 0, rpt2.NoR) AS Women
FROM RPT rpt1
    JOIN RPT rpt2 ON rpt2.Town = rpt1.Town
WHERE rpt1.Sex = 'M'
    AND rpt2.Sex = 'F'
ORDER BY (Men+Women) DESC, Town;


USE `KATZENJAMMER`;
-- KATZENJAMMER-1
-- Report the first name of the performer who never played accordion.

WITH PUA AS (
            SELECT DISTINCT Bandmate 
            FROM Instruments
            JOIN Band ON Band.Id = Instruments.Bandmate
            WHERE Instrument = 'accordion'
            )
SELECT Firstname 
FROM Band
WHERE NOT EXISTS (
                SELECT * 
                FROM PUA
                WHERE PUA.Bandmate = Band.Id
                );


USE `KATZENJAMMER`;
-- KATZENJAMMER-2
-- Report, in alphabetical order, the titles of all instrumental compositions performed by Katzenjammer ("instrumental composition" means no vocals).

-- Distinct Vocal Songs
WITH DVS AS (
            SELECT DISTINCT Song 
            FROM Vocals 
            )
SELECT Title
FROM Songs s
WHERE NOT EXISTS (
                SELECT * 
                FROM DVS
                WHERE DVS.Song = s.SongId
                );


USE `KATZENJAMMER`;
-- KATZENJAMMER-3
-- Report the title(s) of the song(s) that involved the largest number of different instruments played (if multiple songs, report the titles in alphabetical order).
WITH NIP AS (
            SELECT Song, COUNT(*) NoI
            FROM Instruments
            GROUP BY Song
            )
SELECT Title 
FROM NIP
    JOIN Songs ON NIP.Song = Songs.SongId
WHERE NoI = (SELECT MAX(NoI) FROM NIP)
ORDER BY Title;


USE `KATZENJAMMER`;
-- KATZENJAMMER-4
-- Find the favorite instrument of each performer. Report the first name of the performer, the name of the instrument, and the number of songs on which the performer played that instrument. Sort in alphabetical order by the first name, then instrument.

WITH ITP AS (
            SELECT Bandmate, Instrument, COUNT(*) AS Tp
            FROM Instruments
            GROUP BY Bandmate, Instrument
            )
SELECT Firstname, Instrument, Tp 
FROM ITP
    JOIN Band ON Id = Bandmate
    JOIN (
        SELECT Bandmate, MAX(Tp) Mtp
        FROM ITP
        GROUP BY Bandmate
        ) m ON m.Bandmate = ITP.Bandmate 
WHERE m.Mtp = ITP.Tp
ORDER BY Firstname, Instrument;


USE `KATZENJAMMER`;
-- KATZENJAMMER-5
-- Find all instruments played ONLY by Anne-Marit. Report instrument names in alphabetical order.
WITH OIP AS (
        SELECT DISTINCT Instrument 
        FROM Instruments
        JOIN Band ON Band.Id = Instruments.Bandmate
        WHERE Band.Firstname != 'Anne-Marit'
        )
SELECT Instrument 
FROM Instruments
    JOIN Band ON Band.Id = Instruments.Bandmate
WHERE Firstname = 'Anne-Marit'
    AND NOT EXISTS (
                    SELECT *
                    FROM OIP
                    WHERE OIP.Instrument = Instruments.Instrument
                    );


USE `KATZENJAMMER`;
-- KATZENJAMMER-6
-- Report, in alphabetical order, the first name(s) of the performer(s) who played the largest number of different instruments.

WITH DIP AS (
            SELECT Bandmate, COUNT(*) NoI
            FROM (
                SELECT DISTINCT Bandmate, Instrument 
                FROM Instruments
                ) i
            GROUP BY Bandmate
            )
SELECT Firstname 
FROM DIP
    JOIN Band ON Band.Id = DIP.Bandmate
WHERE DIP.NoI = (SELECT MAX(NoI) FROM DIP)
ORDER BY Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-7
-- Which instrument(s) was/were played on the largest number of songs? Report just the names of the instruments, sorted alphabetically (note, you are counting number of songs on which an instrument was played, make sure to not count two different performers playing same instrument on the same song twice).
-- Songs Instruments Played
WITH SIP AS (
            SELECT Instrument, COUNT(*) Tp 
            FROM (
                SELECT DISTINCT Song, Instrument 
                FROM Instruments
                ) si
            GROUP BY Instrument
            )
SELECT Instrument
FROM SIP
WHERE Tp = (SELECT MAX(Tp) FROM SIP)
ORDER BY Instrument;


USE `KATZENJAMMER`;
-- KATZENJAMMER-8
-- Who spent the most time performing in the center of the stage (in terms of number of songs on which she was positioned there)? Return just the first name of the performer(s), sorted in alphabetical order.

-- Times Center Stage
WITH TCS AS (
            SELECT Bandmate, COUNT(*) AS Cs 
            FROM Performance
            WHERE StagePosition = 'Center'
            GROUP BY Bandmate
            )
SELECT Firstname FROM TCS
    JOIN Band ON Band.Id = TCS.Bandmate
WHERE TCS.Cs = (SELECT MAX(Cs) FROM TCS)
ORDER BY Firstname;


