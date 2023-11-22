-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10000 habitantes.

SELECT ci.`Name`, co.`Name`
FROM city ci
    INNER JOIN country co ON ci.`CountryCode` = co.`Code`
WHERE (
        SELECT
            sum(ci2.`Population`)
        FROM city ci2
        WHERE
            ci2.`CountryCode` = co.`Code`
        GROUP BY co.`Code`
    ) < 10000

-- 2. Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.

SELECT
    ci.`Name`,
    ci.`Population`
FROM city ci
WHERE ci.`Population` > (
        SELECT
            AVG(ci2.`Population`)
        FROM city ci2
    )

-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.

SELECT *
FROM city ci
    INNER JOIN country co on ci.`CountryCode` = co.`Code`
WHERE
    co.`Continent` <> 'Asia'
    AND ci.`Population` >= ANY (
        SELECT
            co.`Population`
        FROM country co
        WHERE
            co.`Continent` = 'Asia'
    );

-- 4. Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.

SELECT *
FROM country co
    INNER JOIN countrylanguage cl on co.`Code` = cl.`CountryCode`
where
    cl.`IsOfficial` = 'F'
    AND cl.`Percentage` > ALL (
        SELECT
            cl2.`Percentage`
        FROM
            countrylanguage cl2
        WHERE
            cl2.`CountryCode` = co.`Code`
            AND cl2.`IsOfficial` = 'T'
    )

-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).

SELECT DISTINCT co.`Region`
FROM country co
WHERE
    co.`SurfaceArea` < 1000
    AND EXISTS (
        SELECT *
        FROM city ci
        WHERE
            ci.`CountryCode` = co.`Code`
            AND ci.`Population` > 100000
    )

-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).

SELECT co.`Name`, (
        SELECT
            MAX(ci.`Population`)
        from city ci
        WHERE
            ci.`CountryCode` = co.`Code`
    )
FROM country co

-- 7. Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.

SELECT
    co.`Name`,
    cl.`Language`
FROM country co
    INNER JOIN countrylanguage cl ON co.`Code` = cl.`CountryCode`
WHERE
    cl.`IsOfficial` = 'F'
    AND cl.`Percentage` > (
        SELECT
            AVG(cl2.`Percentage`)
        FROM
            countrylanguage cl2
        WHERE
            cl2.`CountryCode` = co.`Code`
            and cl2.`IsOfficial` = 'T'
    )

-- 8. Listar la cantidad de habitantes por continente ordenado en forma descendente.

SELECT
    co.`Region`,
    SUM(co.`Population`) as Population
FROM country co
GROUP BY co.`Region`
ORDER BY Population DESC

-- 9. Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza de vida entre 40 y 70 años.

SELECT
    DISTINCT co.`Continent`,
    AVG(co.`LifeExpectancy`) as LifeExpectancy
FROM country co
WHERE
    LifeExpectancy BETWEEN 40 and 70
GROUP BY co.`Continent`

-- 10. Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.

SELECT
    co.`Continent`,
    MAX(co.`Population`),
    MIN(co.`Population`),
    SUM(co.`Population`)
FROM country co
GROUP BY co.`Continent`