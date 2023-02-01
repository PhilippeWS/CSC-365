DROP TABLE IF EXISTS CountryPopulationByYear;
DROP TABLE IF EXISTS CountryAverageWeightHeight;
DROP TABLE IF EXISTS CountryDetails;

CREATE TABLE CountryDetails(
  CountryRank INTEGER PRIMARY KEY,
  CCA3 VARCHAR(3) NOT NULL,
  Country         VARCHAR(32) UNIQUE NOT NULL,
  Capital         VARCHAR(19) NOT NULL,
  Continent       VARCHAR(13) NOT NULL
);


CREATE TABLE CountryAverageWeightHeight(
  Country       VARCHAR(32) PRIMARY KEY,
  male_height   INTEGER  NOT NULL,
  female_height INTEGER  NOT NULL,
  male_weight   BIGINT NOT NULL,
  female_weight BIGINT NOT NULL,
  
  FOREIGN KEY fk_CAWH_CountryDetails (Country) REFERENCES CountryDetails(Country)
);

CREATE TABLE CountryPopulationByYear(
    Country VARCHAR(32) PRIMARY KEY,
    2022_Population INTEGER  NOT NULL,
    2020_Population  INTEGER  NOT NULL,
    2015_Population  INTEGER  NOT NULL,
    2010_Population  INTEGER  NOT NULL,
    2000_Population  INTEGER  NOT NULL,
    1990_Population  INTEGER  NOT NULL,
    1980_Population  INTEGER  NOT NULL,
    1970_Population  INTEGER  NOT NULL,
    Growth_Rate DOUBLE NOT NULL,

    FOREIGN KEY fk_CPBY_CountryDetails (Country) REFERENCES CountryDetails(Country)
);