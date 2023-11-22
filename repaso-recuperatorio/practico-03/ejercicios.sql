-- Active: 1700680255165@@127.0.0.1@3306@world

USE world 

-- 1. Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.

select
    ci.`Name`,
    co.`Name`,
    co.`Region`,
    co.`GovernmentForm`
from city ci
    inner join country co on ci.`CountryCode` = co.`Code`
order by ci.`Population` desc
limit 10

-- 2. Listar los 10 países con menor población del mundo, junto a sus ciudades capitales (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").

SELECT co.`Name`, ci.`Name`
FROM country co
    LEFT JOIN city ci on co.`Capital` = ci.`ID`
order by co.`Population` asc
limit 10

-- 3. Listar el nombre, continente y todos los lenguajes oficiales de cada país. (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).

SELECT
    co.`Name`,
    cl.`Language`
FROM country co
    INNER JOIN countrylanguage cl on co.`Code` = cl.`CountryCode`
WHERE cl.`IsOfficial` = 'T'

-- 4. Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.

SELECT co.`Name`, ci.`Name`
FROM country co
    INNER JOIN city ci on co.`Capital` = ci.`ID`
ORDER BY co.`SurfaceArea` DESC
limit 20

-- 5. Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.

SELECT
    ci.`Name`,
    cl.`Language`,
    cl.`Percentage`
FROM city ci
    INNER JOIN country co on co.`Capital` = ci.`ID`
    INNER JOIN countrylanguage cl on co.`Code` = cl.`CountryCode`
WHERE cl.`IsOfficial` = 'T'
ORDER BY
    ci.`Name` ASC,
    cl.`Percentage` DESC

-- 6. Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.

(
    SELECT *
    FROM country co
    WHERE
        co.`Population` >= 100
    ORDER BY
        co.`Population` ASC
    LIMIT 10
)
UNION (
    SELECT *
    FROM country co
    WHERE
        co.`Population` >= 100
    ORDER BY
        co.`Population` DESC
    LIMIT 10
)

-- 7. Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: NO debería haber filas duplicadas).

(
    SELECT co.`Name`
    FROM country co
        INNER JOIN countrylanguage cl ON cl.`CountryCode` = co.`Code`
    WHERE
        cl.`Language` = 'English'
        AND cl.`IsOfficial` = 'T'
)
INTERSECT (
    SELECT co.`Name`
    FROM country co
        INNER JOIN countrylanguage cl ON cl.`CountryCode` = co.`Code`
    WHERE
        cl.`Language` = 'French'
        AND cl.`IsOfficial` = 'T'
)

-- 8. Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.

(
    SELECT co.`Name`
    FROM country co
        INNER JOIN countrylanguage cl ON cl.`CountryCode` = co.`Code`
    WHERE cl.`Language` = 'English'
) EXCEPT (
    SELECT co.`Name`
    FROM country co
        INNER JOIN countrylanguage cl ON cl.`CountryCode` = co.`Code`
    WHERE cl.`Language` = 'Spanish' AND cl.`Percentage` <> 0
) 