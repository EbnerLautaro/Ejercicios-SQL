-- PARTE 1

USE world;

-- 1) Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
SELECT 
	city.Name AS "City name", 
	country.Name AS "Country name",
	country.GovernmentForm AS "Government Form",
	country.Region
FROM 
	city
INNER JOIN country ON
	city.CountryCode = country.Code
ORDER BY
	city.Population DESC
LIMIT 10;

-- 2) Listar los 10 países con menor población del mundo, junto a sus ciudades capitales (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").
SELECT 
	country.Name, 
	city.Name
FROM 
	country
INNER JOIN city ON 
	city.ID = country.Capital
ORDER BY country.Population DESC
LIMIT 10;
	
-- 3 Listar el nombre, continente y todos los lenguajes oficiales de cada país. (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
SELECT 
	country.Name,
	country.Continent,
	countrylanguage.`Language`
FROM 
	country
INNER JOIN countrylanguage ON 
	countrylanguage.CountryCode = country.Code
WHERE
	countrylanguage.IsOfficial = "T"
ORDER BY
	country.Name,
	country.Continent,
	countrylanguage.`Language`;

-- 4 Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.
SELECT 
	country.Name,
	city.Name,
	country.SurfaceArea
FROM
	country
INNER JOIN city ON
	city.ID = country.Capital
ORDER BY
	country.SurfaceArea DESC 
LIMIT 20;


-- 5 Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.
SELECT 
	city.Name,
	countrylanguage.`Language`,
	city.Population,
	countrylanguage.Percentage
FROM
	city
INNER JOIN countrylanguage ON 
	city.CountryCode = countrylanguage.CountryCode
WHERE
	countrylanguage.IsOfficial = "T"
ORDER BY
	city.Population DESC ,
	countrylanguage.Percentage DESC;


-- 6 Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
(SELECT 
	country.Name,
	country.Population
FROM
	country
ORDER BY
	country.Population DESC
LIMIT 10
) UNION (
SELECT 
	country.Name,
	country.Population 
FROM country
ORDER BY country.Population ASC
LIMIT 10); 



-- 7 Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
SELECT DISTINCT 
	DISTINCT country.Name
FROM
	country
INNER JOIN countrylanguage ON 
	country.Code = countrylanguage.CountryCode
WHERE
	(countrylanguage.`Language` LIKE "French" XOR
	countrylanguage.`Language` LIKE "English") AND countrylanguage.IsOfficial = "T"


-- 8 Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
(SELECT co.Name
FROM country co
JOIN countrylanguage cl ON 
	co.Code = cl.CountryCode
WHERE  cl.`Language` = "English")
EXCEPT 
(SELECT co.Name
FROM country co
JOIN countrylanguage cl ON 
	co.Code = cl.CountryCode
WHERE  cl.`Language` = "Spanish")
	
	
-- PARTE 2	

/* 
 * 1. ¿Devuelven los mismos valores las siguientes consultas? ¿Por qué? 
 * 		
 * La primera query es mas estricta a la hora de fetchear las filas, mientras que 
 * la segunda "trae" mas filas, pero luego las filtra
 * 
 * 2. ¿Y si en vez de INNER JOIN fuera un LEFT JOIN?
 * 
 * Si fuese un INNER JOIN, la primera query devuelve una tabla con valores nullos, mientras que 
 * la segunda los filtra y no muestra nulls
 * 
 * 
 * conclusion, una es mas segura que la otra, capaz (no se) si la primera es mas rapida en el caso correcto.
**/
	
