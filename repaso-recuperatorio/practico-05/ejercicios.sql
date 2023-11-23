-- Active: 1700680255165@@127.0.0.1@3306@sakila

-- 1. Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.

CREATE TABLE
    `directors`(
        `name` VARCHAR(50),
        `last_name` VARCHAR(50),
        `movies_number` VARCHAR(50)
    );

-- 2. El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. Basados en esta información, inserten, utilizando una subquery los valores correspondientes en la tabla `directors`.

INSERT INTO
    `directors` (
        `name`,
        `last_name`,
        `movies_number`
    )
SELECT
    a.first_name,
    a.last_name,
    COUNT(a.actor_id) as movies_number
FROM actor a
    INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY movies_number DESC
LIMIT 5

-- SELECT * FROM directors

-- 3. Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será premium.

ALTER TABLE customer
ADD
    COLUMN premium_customer ENUM('T', 'F') DEFAULT 'F'

-- 4. Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes con mayor dinero gastado en la plataforma.

UPDATE customer
SET premium_customer = 'T'
WHERE customer_id IN (
        SELECT *
        FROM (
                SELECT
                    c.customer_id
                FROM
                    customer c
                    INNER JOIN payment p on c.customer_id = p.customer_id
                GROUP BY
                    p.customer_id
                ORDER BY
                    SUM(p.amount) DESC
                LIMIT
                    10
            ) as top_customers
    )

-- 5. Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).

SELECT
    f.rating,
    count(f.film_id) as qsy_movies
FROM film f
GROUP BY f.rating
ORDER BY qsy_movies DESC

-- 6. ¿Cuáles fueron la primera y última fecha donde hubo pagos?

(
    SELECT
        MIN(p.payment_date)
    FROM payment p
)
UNION (
    SELECT
        MAX(p.payment_date)
    FROM payment p
)

-- 7. Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).

SELECT
    MONTHNAME(p.payment_date) as Mes,
    AVG(p.amount) as Promedio
FROM payment p
GROUP BY
    MONTHNAME(p.payment_date)

-- 8. Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).

SELECT
    a.district AS 'Top 10 Districts'
FROM rental r
    INNER JOIN customer c on r.customer_id = c.customer_id
    INNER JOIN address a on c.address_id = a.address_id
GROUP BY c.customer_id
ORDER BY
    COUNT(c.customer_id) DESC
LIMIT 10

-- 9. Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y representa la cantidad de copias de una misma película que tiene determinada tienda. El número por defecto debería ser 5 copias.

ALTER TABLE inventory ADD COLUMN stock INT DEFAULT 5 

-- SELECT * FROM inventory

-- 10. Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, haga un update en la tabla `inventory` restando una copia al stock de lapelícula rentada (Hint: revisar que el rental no tiene información directa sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).

DELIMITER //

CREATE TRIGGER UPDATE_STOCK AFTER INSERT ON RENTAL 
FOR EACH ROW BEGIN 
    UPDATE inventory i
	SET stock = stock - 1
	WHERE
	    i.inventory_id = NEW.inventory_id;
	END // 


-- SELECT * FROM inventory WHERE inventory_id = 1

-- INSERT INTO

--     rental (

--         rental_date,

--         inventory_id,

--         customer_id,

--         staff_id

--     )

-- VALUES (NOW(), 1, 1, 1);

-- 11. Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.

CREATE TABLE
    `fines` (
        rental_id INT,
        amount DECIMAL(10, 2),
        FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    );

-- 12. Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date). El valor de la multa será el número de días de retraso multiplicado por 1.5.

SELECT * FROM fines 

DELIMITER //

CREATE PROCEDURE `CHECK_DATE_AND_FINE`() BEGIN
	INSERT INTO
	    fines (rental_id, amount) (
	        SELECT
	            r.rental_id,
	            DATEDIFF(NOW(), r.return_date) * 1.5
	        FROM rental r
	        WHERE
	            DATEDIFF(NOW(), r.return_date) > 3
	    );
	END DELIMITER;


-- CALL `CHECK_DATE_AND_FINE`();

-- 13. Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.

CREATE ROLE `employee`;
GRANT INSERT, DELETE, UPDATE ON sakila.rental TO employee;

-- 14. Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.
REVOKE DELETE ON rental FROM employee;
CREATE ROLE `administrator`;
GRANT ALL PRIVILEGES on sakila.* to `administrator`;


-- 15. Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro de `administrator`.

create role `user1`;
grant `employee` to `user1`;

create role `user2`;
grant `administrator` to `user2`;