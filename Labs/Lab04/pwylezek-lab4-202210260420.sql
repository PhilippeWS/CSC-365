-- Lab 4
-- pwylezek
-- Oct 26, 2022

USE `STUDENTS`;
-- STUDENTS-1
-- Find all students who study in classroom 111. For each student list first and last name. Sort the output by the last name of the student.
SELECT Firstname, LastName 
    FROM list 
WHERE classroom = 111 
ORDER BY Lastname;


USE `STUDENTS`;
-- STUDENTS-2
-- For each classroom report the grade that is taught in it. Report just the classroom number and the grade number. Sort output by classroom in descending order.
SELECT DISTINCT classroom, grade 
    FROM list 
ORDER BY classroom DESC;


USE `STUDENTS`;
-- STUDENTS-3
-- Find all teachers who teach fifth grade. Report first and last name of the teachers and the room number. Sort the output by room number.
SELECT DISTINCT First, Last, teachers.classroom 
    FROM list 
        NATURAL JOIN teachers 
WHERE list.grade = 5;


USE `STUDENTS`;
-- STUDENTS-4
-- Find all students taught by OTHA MOYER. Output first and last names of students sorted in alphabetical order by their last name.
SELECT FirstName, LastName 
    FROM list 
        NATURAL JOIN teachers 
WHERE First='OTHA' 
    AND Last='MOYER' 
ORDER BY LastName;


USE `STUDENTS`;
-- STUDENTS-5
-- For each teacher teaching grades K through 3, report the grade (s)he teaches. Output teacher last name, first name, and grade. Each name has to be reported exactly once. Sort the output by grade and alphabetically by teacher’s last name for each grade.
SELECT DISTINCT Last, First, grade 
    FROM teachers 
        NATURAL JOIN list
WHERE grade < 4 
ORDER BY grade, Last;


USE `BAKERY`;
-- BAKERY-1
-- Find all chocolate-flavored items on the menu whose price is under $5.00. For each item output the flavor, the name (food type) of the item, and the price. Sort your output in descending order by price.
SELECT Flavor, Food, PRICE 
    FROM goods 
WHERE price <= 5.00 
    AND Flavor = 'Chocolate' 
ORDER BY PRICE DESC;


USE `BAKERY`;
-- BAKERY-2
-- Report the prices of the following items (a) any cookie priced above $1.10, (b) any lemon-flavored items, or (c) any apple-flavored item except for the pie. Output the flavor, the name (food type) and the price of each pastry. Sort the output in alphabetical order by the flavor and then pastry name.
SELECT Flavor, Food, PRICE 
    FROM goods 
WHERE (Food='Cookie' AND PRICE > 1.10) 
    OR (Flavor = 'Lemon') 
    OR (Flavor = 'Apple' AND Food != 'Pie') 
ORDER BY Flavor, Food;


USE `BAKERY`;
-- BAKERY-3
-- Find all customers who made a purchase on October 3, 2007. Report the name of the customer (last, first). Sort the output in alphabetical order by the customer’s last name. Each customer name must appear at most once.
SELECT  DISTINCT LastName, FirstName 
    FROM receipts 
        JOIN customers ON  customers.CId = receipts.Customer 
WHERE SaleDate = '2007-10-03' 
ORDER BY LastName;


USE `BAKERY`;
-- BAKERY-4
-- Find all different cakes purchased on October 4, 2007. Each cake (flavor, food) is to be listed once. Sort output in alphabetical order by the cake flavor.
SELECT DISTINCT Flavor, Food 
    FROM items 
        JOIN goods ON GId = Item  
        JOIN receipts ON Receipt = RNumber
WHERE SaleDate = '2007-10-04' 
    AND Food = 'Cake'
ORDER BY Flavor;


USE `BAKERY`;
-- BAKERY-5
-- List all pastries purchased by ARIANE CRUZEN on October 25, 2007. For each pastry, specify its flavor and type, as well as the price. Output the pastries in the order in which they appear on the receipt (each pastry needs to appear the number of times it was purchased).
SELECT Flavor, Food, PRICE 
    FROM items 
        JOIN receipts ON RNumber = Receipt 
        JOIN goods ON GId = Item
        JOIN customers ON CId = Customer 
WHERE SaleDate='2007-10-25' 
    AND FirstName = 'ARIANE' 
    AND LastName='CRUZEN' 
ORDER BY Ordinal;


USE `BAKERY`;
-- BAKERY-6
-- Find all types of cookies purchased by KIP ARNN during the month of October of 2007. Report each cookie type (flavor, food type) exactly once in alphabetical order by flavor.

SELECT DISTINCT Flavor, Food 
    FROM items 
        JOIN receipts ON RNumber = Receipt 
        JOIN goods ON GId = Item
        JOIN customers ON CId = Customer 
WHERE SaleDate LIKE '%2007%' 
    AND FirstName = 'KIP' 
    AND LastName='ARNN' 
    AND Food='Cookie' 
ORDER BY Flavor;


USE `CSU`;
-- CSU-1
-- Report all campuses from Los Angeles county. Output the full name of campus in alphabetical order.
SELECT Campus 
    FROM campuses 
WHERE County = 'Los Angeles' 
ORDER BY Campus;


USE `CSU`;
-- CSU-2
-- For each year between 1994 and 2000 (inclusive) report the number of students who graduated from California Maritime Academy Output the year and the number of degrees granted. Sort output by year.
SELECT degrees.year, degrees 
    FROM degrees 
        JOIN campuses ON  Id=CampusId  
WHERE Campus='California Maritime Academy' 
    AND degrees.year>=1994 
    AND degrees.year<=2000 
ORDER BY degrees.year;


USE `CSU`;
-- CSU-3
-- Report undergraduate and graduate enrollments (as two numbers) in ’Mathematics’, ’Engineering’ and ’Computer and Info. Sciences’ disciplines for both Polytechnic universities of the CSU system in 2004. Output the name of the campus, the discipline and the number of graduate and the number of undergraduate students enrolled. Sort output by campus name, and by discipline for each campus.
SELECT Campus, Name, Gr, Ug 
    FROM discEnr 
        JOIN disciplines ON disciplines.Id = discEnr.Discipline 
        JOIN campuses ON campuses.Id = CampusId
WHERE (Name='Mathematics' OR Name='Engineering' OR Name='Computer and Info. Sciences') 
    AND Campus LIKE '%Polytechnic%' 
    AND discEnr.year=2004 
ORDER BY Campus, Discipline;


USE `CSU`;
-- CSU-4
-- Report graduate enrollments in 2004 in ’Agriculture’ and ’Biological Sciences’ for any university that offers graduate studies in both disciplines. Report one line per university (with the two grad. enrollment numbers in separate columns), sort universities in descending order by the number of ’Agriculture’ graduate students.
SELECT DISTINCT Campus, dE1.Gr AS 'Agriculture', dE2.Gr AS 'Biological Sciences' 
    FROM discEnr AS dE1
        JOIN discEnr AS dE2 ON dE2.CampusId = dE1.CampusId 
        JOIN campuses ON campuses.Id = dE1.CampusId 
        JOIN disciplines AS D1 ON D1.Id = dE1.Discipline  
        JOIN disciplines AS D2 ON D2.Id = dE2.Discipline  
WHERE D1.Name ='Agriculture' 
    AND D2.Name='Biological Sciences' 
    AND dE1.Gr > 0 
    AND dE2.Gr > 0 
ORDER BY dE1.Gr DESC;


USE `CSU`;
-- CSU-5
-- Find all disciplines and campuses where graduate enrollment in 2004 was at least three times higher than undergraduate enrollment. Report campus names, discipline names, and both enrollment counts. Sort output by campus name, then by discipline name in alphabetical order.
SELECT Campus, Name, Ug, Gr 
    FROM campuses
        JOIN discEnr ON discEnr.CampusId = campuses.Id 
        JOIN disciplines ON disciplines.Id = discEnr.Discipline 
WHERE discEnr.Year=2004 
    AND Gr>=Ug*3 
ORDER BY Campus, Name;


USE `CSU`;
-- CSU-6
-- Report the amount of money collected from student fees (use the full-time equivalent enrollment for computations) at ’Fresno State University’ for each year between 2002 and 2004 inclusively, and the amount of money (rounded to the nearest penny) collected from student fees per each full-time equivalent faculty. Output the year, the two computed numbers sorted chronologically by year.
SELECT enrollments.Year, (enrollments.FTE * fee) AS 'Collected', ROUND((enrollments.FTE * fee)/faculty.FTE , 2) AS 'PER FACULTY' 
    FROM enrollments
        JOIN faculty ON faculty.CampusId = enrollments.CampusId 
        JOIN campuses ON campuses.Id = enrollments.CampusId AND campuses.Id = faculty.CampusId 
        JOIN fees ON fees.CampusId = enrollments.CampusId AND fees.CampusId = campuses.Id 
WHERE Campus='Fresno State University' 
    AND enrollments.Year>=2002 
    AND enrollments.Year<= 2004 
    AND fees.Year = enrollments.Year 
    AND faculty.Year = enrollments.Year 
ORDER BY enrollments.Year;


USE `CSU`;
-- CSU-7
-- Find all campuses where enrollment in 2003 (use the FTE numbers), was higher than the 2003 enrollment in ’San Jose State University’. Report the name of campus, the 2003 enrollment number, the number of faculty teaching that year, and the student-to-faculty ratio, rounded to one decimal place. Sort output in ascending order by student-to-faculty ratio.
SELECT campuses.Campus, enrollments.FTE, faculty.FTE, ROUND(enrollments.FTE/faculty.FTE, 1) AS 'RATIO' 
    FROM campuses
        JOIN enrollments ON enrollments.CampusId = campuses.Id 
        JOIN faculty ON  faculty.CampusId = enrollments.CampusId
        JOIN enrollments AS eSJ
        JOIN campuses AS cSJ ON eSJ.CampusId = cSJ.Id 
WHERE eSJ.year = 2003 
    AND cSJ.Campus = 'San Jose State University' 
    AND enrollments.Year = 2003 
    AND enrollments.FTE > eSJ.FTE 
    AND faculty.Year = enrollments.Year 
ORDER BY RATIO ASC;


USE `INN`;
-- INN-1
-- Find all modern rooms with a base price below $160 and two beds. Report room code and full room name, in alphabetical order by the code.
SELECT RoomCode, RoomName 
    FROM rooms 
WHERE basePrice < 160 
    AND Beds = 2 
    AND decor='modern' 
ORDER BY RoomCode;


USE `INN`;
-- INN-2
-- Find all July 2010 reservations (a.k.a., all reservations that both start AND end during July 2010) for the ’Convoke and sanguine’ room. For each reservation report the last name of the person who reserved it, checkin and checkout dates, the total number of people staying and the daily rate. Output reservations in chronological order.
SELECT LastName, CheckIn, Checkout, (Adults + Kids) AS 'Guests', Rate 
    FROM rooms
        JOIN reservations ON rooms.RoomCode = reservations.Room 
WHERE CheckIn LIKE '%2010-07%' 
    AND Checkout LIKE '%2010-07%' 
    AND RoomName = 'Convoke and sanguine' 
ORDER BY CheckIn;


USE `INN`;
-- INN-3
-- Find all rooms occupied on February 6, 2010. Report full name of the room, the check-in and checkout dates of the reservation. Sort output in alphabetical order by room name.
SELECT RoomName, CheckIn, Checkout 
    FROM rooms
        JOIN reservations ON reservations.Room = rooms.RoomCode  
WHERE CheckIn <= '2010-02-06' 
    AND Checkout > '2010-02-06'
ORDER BY RoomName;


USE `INN`;
-- INN-4
-- For each stay by GRANT KNERIEN in the hotel, calculate the total amount of money, he paid. Report reservation code, room name (full), checkin and checkout dates, and the total stay cost. Sort output in chronological order by the day of arrival.

SELECT CODE, RoomName, CheckIn, Checkout, (DATEDIFF(Checkout, CheckIn) * Rate) AS 'PAID' 
    FROM rooms
        JOIN reservations ON rooms.RoomCode = reservations.Room  
WHERE FirstName='GRANT' 
    AND LastName='KNERIEN' 
ORDER BY CheckIn;


USE `INN`;
-- INN-5
-- For each reservation that starts on December 31, 2010 report the room name, nightly rate, number of nights spent and the total amount of money paid. Sort output in descending order by the number of nights stayed.
SELECT RoomName, Rate, DATEDIFF(Checkout, CheckIn) AS 'Nights', DATEDIFF(Checkout, CheckIn)*Rate AS 'Money' 
    FROM rooms
        JOIN reservations ON rooms.RoomCode = reservations.Room 
WHERE CheckIn LIKE '%2010-12-31%' 
ORDER BY Nights DESC;


USE `INN`;
-- INN-6
-- Report all reservations in rooms with double beds that contained four adults. For each reservation report its code, the room abbreviation, full name of the room, check-in and check out dates. Report reservations in chronological order, then sorted by the three-letter room code (in alphabetical order) for any reservations that began on the same day.
SELECT Code, Room, RoomName, CheckIn, Checkout FROM reservations
    JOIN rooms ON reservations.Room = rooms.RoomCode 
WHERE rooms.bedType = 'Double' 
    AND reservations.Adults = 4 
ORDER BY CheckIn, Room;


USE `MARATHON`;
-- MARATHON-1
-- Report the overall place, running time, and pace of TEDDY BRASEL.
SELECT Place, RunTime, Pace 
    FROM marathon 
WHERE FirstName='Teddy' 
    AND LastName='Brasel';


USE `MARATHON`;
-- MARATHON-2
-- Report names (first, last), overall place, running time, as well as place within gender-age group for all female runners from QUNICY, MA. Sort output by overall place in the race.
SELECT FirstName, LastName, Place, RunTime, GroupPlace 
    FROM marathon 
WHERE Town = 'Qunicy' 
    AND State = 'MA' 
    AND Sex = 'F' 
ORDER BY Place;


USE `MARATHON`;
-- MARATHON-3
-- Find the results for all 34-year old female runners from Connecticut (CT). For each runner, output name (first, last), town and the running time. Sort by time.
SELECT FirstName, LastName, Town, RunTime 
    FROM marathon 
WHERE Sex='F' 
    AND State='CT' 
    AND Age=34 
ORDER BY RunTime;


USE `MARATHON`;
-- MARATHON-4
-- Find all duplicate bibs in the race. Report just the bib numbers. Sort in ascending order of the bib number. Each duplicate bib number must be reported exactly once.
SELECT DISTINCT M1.BibNumber 
    FROM marathon AS M1
        JOIN marathon AS M2 ON M1.BibNumber = M2.BibNumber  
WHERE M1.Place != M2.Place 
ORDER BY M1.BibNumber ASC;


USE `MARATHON`;
-- MARATHON-5
-- List all runners who took first place and second place in their respective age/gender groups. List gender, age group, name (first, last) and age for both the winner and the runner up (in a single row). Include only age/gender groups with both a first and second place runner. Order the output by gender, then by age group.
SELECT M1.Sex, M1.AgeGroup, M1.FirstName, M1.LastName, M1.Age, M2.FirstName, M2.LastName, M2.Age 
    FROM marathon AS M1
        JOIN marathon AS M2 ON M1.AgeGroup = M2.AgeGroup AND M1.Sex = M2.Sex 
WHERE M1.GroupPlace = 1 
    AND M2.GroupPlace = 2 
ORDER BY M1.Sex, M1.AgeGroup;


USE `AIRLINES`;
-- AIRLINES-1
-- Find all airlines that have at least one flight out of AXX airport. Report the full name and the abbreviation of each airline. Report each name only once. Sort the airlines in alphabetical order.
SELECT DISTINCT Name, Abbr 
    FROM airlines
        JOIN flights ON flights.Airline = airlines.Id 
WHERE flights.Source = 'AXX' 
ORDER BY Name;


USE `AIRLINES`;
-- AIRLINES-2
-- Find all destinations served from the AXX airport by Northwest. Re- port flight number, airport code and the full name of the airport. Sort in ascending order by flight number.

SELECT FlightNo, Code, airports.Name 
    FROM flights
        JOIN airports
        JOIN airlines ON flights.Airline = airlines.Id 
WHERE flights.source='AXX' 
    AND airlines.Abbr = 'Northwest' 
    AND airports.code=flights.Destination 
ORDER BY FlightNo;


USE `AIRLINES`;
-- AIRLINES-3
-- Find all *other* destinations that are accessible from AXX on only Northwest flights with exactly one change-over. Report pairs of flight numbers, airport codes for the final destinations, and full names of the airports sorted in alphabetical order by the airport code.
SELECT f1.flightNo, f2.flightNo, f2.Destination, airports.Name 
    FROM airports 
        JOIN airlines 
        JOIN flights AS f1 ON f1.airline=airlines.Id 
        JOIN flights as f2 ON f2.airline=f1.airline  
WHERE f1.Source = 'AXX' 
    AND f2.Destination != f1.Source 
    AND airports.Code = f2.Destination
    AND airlines.Name = 'Northwest Airlines'
    AND f1.Destination = f2.Source;


USE `AIRLINES`;
-- AIRLINES-4
-- Report all pairs of airports served by both Frontier and JetBlue. Each airport pair must be reported exactly once (if a pair X,Y is reported, then a pair Y,X is redundant and should not be reported).
SELECT DISTINCT f1.Source, f2.Destination 
    FROM flights AS f1
        JOIN flights as f2 ON f2.Source = f1.Source AND f2.Destination = f1.Destination 
        JOIN airports ON airports.code = f1.Source AND airports.code = f2.Source
        JOIN airlines AS a1 ON a1.Id = f1.airline 
        JOIN airlines AS a2 ON a2.Id = f2.airline
WHERE a1.Abbr = 'Frontier' 
    AND a2.Abbr = 'JetBlue' 
    AND f1.Source < f1.Destination;


USE `AIRLINES`;
-- AIRLINES-5
-- Find all airports served by ALL five of the airlines listed below: Delta, Frontier, USAir, UAL and Southwest. Report just the airport codes, sorted in alphabetical order.
SELECT DISTINCT f1.Source 
    FROM flights AS f1 
        JOIN flights AS f2 ON f1.Source = f2.Source
        JOIN flights AS f3 ON f1.Source = f3.Source
        JOIN flights AS f4 ON f1.Source = f4.Source
        JOIN flights AS f5 ON f1.Source = f5.Source
        JOIN airlines AS a1 ON f1.Airline = a1.Id
        JOIN airlines AS a2 ON f2.Airline = a2.Id
        JOIN airlines AS a3 ON f3.Airline = a3.Id
        JOIN airlines AS a4 ON f4.Airline = a4.Id
        JOIN airlines AS a5 ON f5.Airline = a5.Id
WHERE a1.Abbr = 'Delta' 
    AND a2.Abbr = 'Frontier' 
    AND a3.Abbr='USAir' 
    AND a4.Abbr='UAL' 
    AND a5.Abbr='Southwest' 
ORDER BY f1.Source;


USE `AIRLINES`;
-- AIRLINES-6
-- Find all airports that are served by at least three Southwest flights. Report just the three-letter codes of the airports — each code exactly once, in alphabetical order.
SELECT DISTINCT f1.Source 
    FROM flights AS f1
        JOIN flights AS f2 ON f1.Source = f2.Source
        JOIN flights AS f3 ON f1.Source = f3.Source
        JOIN airlines ON f1.Airline = airlines.Id AND f2.Airline = airlines.Id AND f3.Airline = airlines.Id
WHERE 
    airlines.Abbr='Southwest' 
    AND f1.FlightNo != f2.FlightNo 
    AND f1.FlightNo != f3.FlightNo 
    AND f2.FlightNo != f3.FlightNo
ORDER BY f1.Source;


USE `KATZENJAMMER`;
-- KATZENJAMMER-1
-- Report, in order, the tracklist for ’Le Pop’. Output just the names of the songs in the order in which they occur on the album.
SELECT Songs.Title 
    FROM Songs
        JOIN Tracklists ON Tracklists.Song = Songs.SongId
        JOIN Albums ON Tracklists.Album = Albums.AId
WHERE Albums.Title='Le Pop'
ORDER BY Tracklists.Position;


USE `KATZENJAMMER`;
-- KATZENJAMMER-2
-- List the instruments each performer plays on ’Mother Superior’. Output the first name of each performer and the instrument, sort alphabetically by the first name.
SELECT Firstname, Instrument 
    FROM Songs
        JOIN Instruments ON Songs.SongId = Instruments.Song
        JOIN Band ON Band.Id = Instruments.Bandmate
WHERE Songs.Title='Mother Superior'
ORDER BY Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-3
-- List all instruments played by Anne-Marit at least once during the performances. Report the instruments in alphabetical order (each instrument needs to be reported exactly once).
SELECT DISTINCT Instrument 
    FROM Instruments
        JOIN Band ON Band.id = Instruments.Bandmate
WHERE Band.Firstname = 'Anne-Marit'
ORDER BY Instrument;


USE `KATZENJAMMER`;
-- KATZENJAMMER-4
-- Find all songs that featured ukalele playing (by any of the performers). Report song titles in alphabetical order.
SELECT Songs.Title 
    FROM Songs
        JOIN Instruments ON Songs.SongId = Instruments.Song 
WHERE Instruments.Instrument='ukalele'
ORDER BY Songs.Title;


USE `KATZENJAMMER`;
-- KATZENJAMMER-5
-- Find all instruments Turid ever played on the songs where she sang lead vocals. Report the names of instruments in alphabetical order (each instrument needs to be reported exactly once).
SELECT DISTINCT Instruments.Instrument 
    FROM Instruments
        JOIN Band ON Band.Id = Instruments.Bandmate
        JOIN Vocals ON Vocals.Song = Instruments.Song AND Vocals.Bandmate = Band.Id
WHERE Band.Firstname = 'Turid' 
    AND Vocals.VocalType = 'lead'
ORDER BY Instruments.Instrument;


USE `KATZENJAMMER`;
-- KATZENJAMMER-6
-- Find all songs where the lead vocalist is not positioned center stage. For each song, report the name, the name of the lead vocalist (first name) and her position on the stage. Output results in alphabetical order by the song, then name of band member. (Note: if a song had more than one lead vocalist, you may see multiple rows returned for that song. This is the expected behavior).
SELECT Songs.Title, Band.Firstname, Performance.StagePosition 
    FROM Performance
        JOIN Songs ON Performance.Song = Songs.SongId
        JOIN Vocals ON Performance.Song = Vocals.Song AND Vocals.Bandmate = Performance.Bandmate 
        JOIN Band ON Band.Id = Vocals.Bandmate
WHERE Vocals.VocalType = 'lead'
    AND Performance.StagePosition != 'center'
ORDER BY Songs.Title, Band.Firstname;


USE `KATZENJAMMER`;
-- KATZENJAMMER-7
-- Find a song on which Anne-Marit played three different instruments. Report the name of the song. (The name of the song shall be reported exactly once)
SELECT DISTINCT Songs.Title 
    FROM Songs
        JOIN Instruments AS i1 ON Songs.SongId = i1.Song
        JOIN Instruments AS i2 ON Songs.SongId = i2.Song
        JOIN Instruments AS i3 ON Songs.SongId = i3.Song
        JOIN Band ON i1.Bandmate = Band.Id AND i2.Bandmate = Band.Id AND i3.Bandmate = Band.Id
WHERE i1.Instrument != i2.Instrument
    AND i1.Instrument != i3.Instrument
    AND i3.Instrument != i2.Instrument
    AND Band.Firstname = 'Anne-Marit';


USE `KATZENJAMMER`;
-- KATZENJAMMER-8
-- Report the positioning of the band during ’A Bar In Amsterdam’. (just one record needs to be returned with four columns (right, center, back, left) containing the first names of the performers who were staged at the specific positions during the song).
SELECT b1.Firstname AS 'RIGHT', b2.Firstname AS 'CENTER', b3.Firstname AS 'BACK', b4.Firstname AS 'LEFT' 
    FROM Songs
        JOIN Performance as p1 ON Songs.SongId = p1.Song
        JOIN Performance as p2 ON Songs.SongId = p2.Song
        JOIN Performance as p3 ON Songs.SongId = p3.Song
        JOIN Performance as p4 ON Songs.SongId = p4.Song
        JOIN Band as b1 ON b1.Id = p1.Bandmate
        JOIN Band as b2 ON b2.Id = p2.Bandmate
        JOIN Band as b3 ON b3.Id = p3.Bandmate
        JOIN Band as b4 ON b4.Id = p4.Bandmate
WHERE Songs.Title='A Bar In Amsterdam'
    AND p1.StagePosition = 'right'
    AND p2.StagePosition = 'center'
    AND p3.StagePosition = 'back'
    AND p4.StagePosition = 'left';


