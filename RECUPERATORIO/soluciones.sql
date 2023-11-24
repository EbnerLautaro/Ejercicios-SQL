-- Active: 1700680255165@@127.0.0.1@3306@olympics

USE olympics;

-- 1 Listar todas las ciudades sede de los juegos olímpicos de verano junto con su año, de más reciente a menos reciente (1p)

SELECT
    c.city_name,
    g.games_year
FROM games g
    INNER JOIN games_city gc ON g.id = gc.`games_id`
    INNER JOIN city c ON c.id = gc.`city_id`
WHERE g.season = 'Summer'
ORDER BY g.games_year DESC;

-- 2 Obtener el ranking de los 10 países con más medallas de oro en fútbol (1.5p)

SELECT
    nr.`region_name`,
    COUNT(p.id) AS qty_gold
FROM `sport` s
    INNER JOIN `event` e ON e.`sport_id` = s.`id`
    INNER JOIN `competitor_event` ce ON e.`id` = ce.`event_id`
    INNER JOIN `medal` m ON ce.`medal_id` = m.id
    INNER JOIN `games_competitor` gc ON ce.`competitor_id` = gc.`id`
    INNER JOIN `person` p ON gc.`person_id` = p.`id`
    INNER JOIN `person_region` pr ON pr.`person_id` = p.`id`
    INNER JOIN `noc_region` nr ON pr.`region_id` = nr.`id`
WHERE
    m.`medal_name` = "Gold"
    AND s.sport_name = "Football"
GROUP BY nr.`id`
ORDER BY qty_gold DESC
LIMIT 10;

-- 3 Listar con la misma query el país con más participaciones y el país con menos participaciones en los juegos olímpicos (2p)

WITH appearances_by_region AS (
    SELECT
        nr.region_name,
        COUNT(ce.event_id) AS qty_appearances
    FROM noc_region nr
        INNER JOIN person_region pr ON nr.id = pr.region_id
        INNER JOIN person pe ON pr.person_id = pe.id
        INNER JOIN games_competitor gc ON pe.id = gc.person_id
        INNER JOIN competitor_event ce ON gc.games_id = ce.competitor_id
    GROUP BY nr.id
) 
(
    SELECT *
    FROM
        appearances_by_region
    ORDER BY
        qty_appearances DESC
    LIMIT 1
) UNION (
    SELECT *
    FROM
        appearances_by_region
    ORDER BY
        qty_appearances ASC
    LIMIT 1
);

-- 4 Crear una vista en la que se muestren entradas del tipo (país, deporte, medallas de oro, medallas de plata, medallas de bronce, participaciones sin medallas) para cada país y deporte (2.5p)

CREATE VIEW
    medals_by_country AS
SELECT
    nr.region_name AS "país",
    sp.sport_name AS "deporte",
    sum(
        CASE
            WHEN me.medal_name = "Gold" THEN 1
            ELSE 0
        END
    ) AS "medallas de oro",
    sum(
        CASE
            WHEN me.medal_name = "Silver" THEN 1
            ELSE 0
        END
    ) AS "medallas de plata",
    sum(
        CASE
            WHEN me.medal_name = "Bronze" THEN 1
            ELSE 0
        END
    ) AS "medallas de bronce",
    sum(
        CASE
            WHEN me.medal_name = "NA" THEN 1
            ELSE 0
        END
    ) AS "participaciones sin medallas"
FROM noc_region nr
    INNER JOIN person_region pr ON nr.id = pr.region_id
    INNER JOIN person pe ON pr.person_id = pe.id
    INNER JOIN games_competitor gc ON pe.id = gc.person_id
    INNER JOIN competitor_event ce ON gc.games_id = ce.competitor_id
    INNER JOIN `event` ev ON ce.event_id = ev.id
    INNER JOIN sport sp ON ev.sport_id = sp.id
    INNER JOIN medal me ON ce.medal_id = me.id
GROUP BY nr.id, sp.id;

-- DROP VIEW medals_by_country;

-- SELECT * FROM medals_by_country

-- 5 Crear un procedimiento que reciba como parámetro el nombre de un país y devuelva la cantidad total (sumando todos los deportes) de medallas de oro, plata y bronce ganadas por ese país. Puede usar la vista creada en el punto anterior, va a ser mucho más fácil. (1.5p)

DELIMITER //
CREATE PROCEDURE total_medals_by_country(
    IN country_name_param VARCHAR(50), 
    OUT total_medals INT) 
BEGIN  
	SELECT
	    SUM(mbc.`medallas de bronce`) + SUM(mbc.`medallas de plata`) + SUM(mbc.`medallas de oro`) INTO total_medals
	FROM medals_by_country mbc
	WHERE
	    mbc.país = country_name_param;
END // 
DELIMITER;

-- DROP PROCEDURE total_medals_by_country;

-- CALL total_medals_by_country('Argentina', @M);

-- SELECT @M;

-- 6 OJO, este ejercicio, dejenlo para el final, porque cambia el schema y les puede invalidar los ejercicios anteriores. La tabla sport solo se usa para contener el nombre del deporte. Vamos a simplificar el modelo y eliminarla. Para ello, debemos:

-- a Actualizar la tabla `event` para que tenga una columna `sport_name` con el nombre del deporte. Además introducir el nombre de deporte correspondiente (1p)

ALTER TABLE `event`
ADD
    COLUMN `sport_name` VARCHAR(200) DEFAULT NULL;

-- DESCRIBE `event`;

UPDATE `event`
    INNER JOIN sport s ON s.id = `event`.sport_id
SET
    `event`.sport_name = s.sport_name;

-- SELECT * FROM `event`;

-- b Eliminar la columna `sport_id` de la tabla `event` (0.25p)

ALTER TABLE `event` DROP FOREIGN KEY `fk_ev_sp`;

-- SHOW CREATE TABLE `event` lo use para conseguir el nombre de la fk

ALTER TABLE `event` DROP COLUMN `sport_id`;

-- DESCRIBE event

-- c Eliminar la tabla `sport` (0.25p)

DROP TABLE `sport`;