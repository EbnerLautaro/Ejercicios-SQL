USE world;
-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10000 habitantes.
SELECT ci.Name, co.Name
FROM city ci
INNER JOIN country co ON
	ci.CountryCode = co.Code
WHERE(
	SELECT SUM(ci2.Population)
FROM city ci2
WHERE ci2.CountryCode = co.Code
	) < 10000;
-- 2. Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
SELECT ci1.Name, COUNT(*) OVER()
FROM city ci1
WHERE ci1.Population > (
	SELECT AVG(ALL ci2.Population)
FROM city ci2);
-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.
SELECT ci1.Name, COUNT(*) OVER() AS total
FROM(
	SELECT ci2.*
FROM city ci2
INNER JOIN country co ON
		ci2.CountryCode = co.Code
WHERE co.Continent NOT LIKE "Asia" ) AS ci1
WHERE ci1.Population >= SOME (
	SELECT co1.Population
FROM country co1
WHERE co1.Continent LIKE "Asia");
-- 4. Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.
SELECT co.Name, cl.`Language`, cl.Percentage, COUNT(*) OVER() AS total
FROM country co
INNER JOIN countrylanguage cl ON 
	co.Code = cl.CountryCode
WHERE cl.IsOfficial LIKE "F"
AND 
	cl.Percentage > ALL(
	SELECT cl2.Percentage
FROM countrylanguage cl2
WHERE cl2.CountryCode = co.Code
AND 
			cl2.IsOfficial LIKE "T");
		
-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).
-- FORMA 1
SELECT DISTINCT 
	co.Region
FROM country co
INNER JOIN city ci ON
	co.Code = ci.CountryCode
WHERE
	co.SurfaceArea < 1000
AND
	ci.Population > 100000;
	
	
-- FORMA 2
SELECT DISTINCT co.Region
FROM country co
WHERE co.SurfaceArea < 1000
AND 
	100000 < SOME (
		SELECT ci.Population
		FROM city ci
		WHERE ci.CountryCode = co.Code 
	);


-- FORMA 3
SELECT DISTINCT co.Region
FROM country co
WHERE co.SurfaceArea < 1000
AND 
	100000 < (
	SELECT MAX(ci.Population)
FROM city ci
WHERE ci.CountryCode = co.Code
GROUP BY
		ci.CountryCode 
	);
-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).
SELECT co.Name, MAX(ci.Population)
FROM country co
INNER JOIN 
	city ci ON
ci.CountryCode = co.Code
GROUP BY 
	ci.CountryCode;

-- 7. Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.
SELECT co.Name, cl.`Language`, COUNT(*) OVER() AS total
FROM country co
INNER JOIN countrylanguage cl ON 
	co.Code = cl.CountryCode
WHERE cl.IsOfficial LIKE "F"
AND 
	cl.Percentage > (SELECT AVG(cl2.Percentage)
		FROM countrylanguage cl2
		WHERE co.Code = cl2.CountryCode 
			AND cl2.IsOfficial LIKE "T"
	);

-- 8. Listar la cantidad de habitantes por continente ordenado en forma descendente.
SELECT Continent, SUM(Population) AS Poblacion
FROM country
GROUP BY 
	Continent 
ORDER BY Poblacion DESC;
	
-- 9. Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza de vida entre 40 y 70 años.
SELECT Continent, AVG(LifeExpectancy) AS esperanza
FROM country
GROUP BY 
	Continent 
HAVING 
	esperanza > 40 
	AND
	esperanza < 70;

-- 10. Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT 
	Continent, 
	MAX(Population) AS max_poblacion,
	MIN(Population) AS min_poblacion,
	AVG(Population) AS avg_poblacion,
	SUM(Population) AS sum_poblacion
FROM country
GROUP BY 
	Continent 
ORDER BY max_poblacion DESC;






