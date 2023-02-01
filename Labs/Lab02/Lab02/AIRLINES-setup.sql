DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS airlines;

CREATE Table airlines(
    Id INTEGER Primary Key,
    Airline varChar(32) NOT NULL,
    Abbreviation varChar(15) UNIQUE,
    Country varChar(32) NOT NULL
);

CREATE Table airports (
    City varChar(32) NOT NULL,
    AirportCode char(3) Primary Key,
    AirportName varChar(32) NOT NULL,
    Country varChar(32) NOT NULL,
    CountryAbbrev varChar(5)
);

CREATE Table flights(
    Airline INTEGER NOT NULL,
    FlightNo INTEGER NOT NULL,
    SourceAirport char(3) NOT NULL,
    DestAirport char(3) NOT NULL,
    
    PRIMARY KEY (Airline, FlightNo),
    FOREIGN KEY Airline_AirlinesId (Airline) REFERENCES airlines(Id),
    FOREIGN KEY SourceAirport_AirportsAirportCode (SourceAirport) REFERENCES airports(AirportCode),
    FOREIGN KEY DestAirport_AirportsAirportCode (DestAirport) REFERENCES airports(AirportCode)
);