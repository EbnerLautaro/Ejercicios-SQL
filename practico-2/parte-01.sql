-- 1) crear y conectarse a la base de datos:

CREATE DATABASE IF NOT EXISTS world;
USE world;

-- 2) generar tablas.

CREATE TABLE IF NOT EXISTS country(
	Code CHAR(100) UNIQUE,
	Name CHAR(100),
	Continent CHAR(100),
	Region CHAR(100),
	SurfaceArea INT,
	IndepYear INT,
	Population INT,
	LifeExpectancy INT,
	GNP INT,
	GNPOld INT,
	LocalName CHAR(100),
	GovernmentForm CHAR(100),
	HeadOfState CHAR(100),
	Capital INT,
	Code2 CHAR(100)
);

CREATE TABLE IF NOT EXISTS city (
	ID INT,
	Name CHAR(100),
	CountryCode CHAR(100),
	District CHAR(100),
	Population INT,
	PRIMARY KEY (ID),
	FOREIGN KEY (CountryCode) REFERENCES country(Code)
);

CREATE TABLE IF NOT EXISTS countrylanguage(
	CountryCode CHAR(100),
	`Language` CHAR(100),
	IsOfficial CHAR(100),
	Percentage INT,
	PRIMARY KEY (CountryCode,`Language`),
	FOREIGN KEY (CountryCode) REFERENCES country(Code)
);

-- 3) Insertar datos (otro archivo)

-- 4) Crear una tabla "Continent"

CREATE TABLE IF NOT EXISTS Continent(
	Name CHAR(100),
	Area INT, 
	PercentTotalMass FLOAT,
	MostPopulousCity char(100),
	PRIMARY KEY (Name)
);



-- 5) Inserte los siguientes valores en la tabla "Continent":
INSERT INTO `Continent` VALUES ("Africa", 30370000, 20.4, "Cairo, Egypt");
INSERT INTO `Continent` VALUES ("Asia", 44579000, 29.5, "Mumbai, India");
INSERT INTO `Continent` VALUES ("Europe", 10180000, 6.8, "Instanbul, Turquia");
INSERT INTO `Continent` VALUES ("North America", 24709000, 16.5, "Ciudad de México, Mexico");
INSERT INTO `Continent` VALUES ("Oceania", 8600000, 5.9, "Sydney, Australia");
INSERT INTO `Continent` VALUES ("South America", 17840000, 12.0, "São Paulo, Brazil");

-- 6) Modificar la tabla "country" de manera que el campo "Continent" 
-- pase a ser una clave externa (o foreign key) a la tabla Continent.*

ALTER TABLE country 
ADD CONSTRAINT continent_of_country FOREIGN KEY (Continent) REFERENCES Continent (Name);