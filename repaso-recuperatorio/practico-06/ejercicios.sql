-- Active: 1700680255165@@127.0.0.1@3306@classicmodels

-- 1. Devuelva la oficina con mayor número de empleados.

SELECT o.*
FROM offices o
    INNER JOIN employees e on o.`officeCode` = e.`officeCode`
GROUP BY o.`officeCode`
ORDER BY
    COUNT(e.`employeeNumber`) DESC
LIMIT 1

-- 2. ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?

CREATE VIEW ordersByOffice AS
SELECT
    e.`officeCode`,
    COUNT(o.`orderNumber`) as numberOfOrders
FROM employees e
    INNER JOIN customers c ON e.`employeeNumber` = c.`salesRepEmployeeNumber`
    INNER JOIN orders o ON o.`customerNumber` = c.`customerNumber`
GROUP BY e.`officeCode`;

-- PROMEDIO DE ORDENES

SELECT AVG(numberOfOrders) FROM `ordersByOffice` 

SELECT o.*
FROM `ordersByOffice` obf
    INNER JOIN offices o ON obf.`officeCode` = o.`officeCode`
ORDER BY
    obf.`numberOfOrders` DESC
LIMIT 1

-- 3. Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.

SELECT
    MONTHNAME(p.`paymentDate`),
    MIN(p.amount) as minimo,
    MAX(p.amount) as maximo,
    AVG(p.amount) as promedio
FROM payments p
GROUP BY
    MONTHNAME(p.`paymentDate`)

-- 4. Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.

DELIMITER //

CREATE PROCEDURE UPDATECREDIT(IN CUSTOMER INT, IN NEW_CREDIT_LIMIT 
INT) BEGIN 
	UPDATE customers
	SET
	    creditLimit = new_credit_limit
	WHERE
	    `customerNumber` = customer;
	END // 


delimiter ;

-- 5. Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.

CREATE VIEW PremiumCustomers AS
SELECT
    c.`customerName`,
    c.city,
    sum(p.amount) as moneySpent
FROM customers c
    INNER JOIN payments p on c.`customerNumber` = p.`customerNumber`
GROUP BY c.`customerNumber`
ORDER BY moneySpent DESC
LIMIT 10;

-- 6. Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.

DELIMITER // 

CREATE FUNCTION EMPLOYEE_OF_THE_MONTH(MONTH_PARAM INT
, YEAR_PARAM INT) RETURNS VARCHAR(100) DETERMINISTIC 
BEGIN 
	DECLARE response VARCHAR(100);
	SELECT
	    CONCAT(
	        e.`firstName`,
	        " ",
	        e.`lastName`
	    ) INTO response
	FROM employees e
	    INNER JOIN customers c ON e.`employeeNumber` = c.`salesRepEmployeeNumber`
	    INNER JOIN orders o ON c.`customerNumber` = o.`customerNumber`
	WHERE
	    MONTH(o.`orderDate`) = month_param
	    AND YEAR(o.`orderDate`) = year_param
	GROUP BY e.`employeeNumber`
	ORDER BY
	    COUNT(o.`orderNumber`)
	LIMIT 1;
	RETURN response;
	END // 


delimiter ;

SELECT employee_of_the_month(1,2015);

-- 7. Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.

CREATE TABLE
    productRefillment (
        `refillmentID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `productCode` VARCHAR(15) NOT NULL,
        `orderDate` DATE NOT NULL,
        `quantity` INT DEFAULT 0,
        FOREIGN KEY (productCode) REFERENCES products(productCode),
        PRIMARY KEY (`refillmentID`)
    );

DESCRIBE productRefillment;

-- 8. Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.

DELIMITER //

CREATE TRIGGER RESTOCKPRODUCT AFTER INSERT ON ORDERDETAILS 
FOR EACH ROW BEGIN 
	-- OBTENGO LA CANTIDAD EN STOCK
	DECLARE stock int;
	SELECT
	    p.quantityInStEW - NEW.quantityOrdered INTO stock
	FROM products p
	WHERE
	    p.`productCode` = NEW.`productCode`;
	IF(stock < 10) THEN
	INSERT INTO
	    productRefillment (
	        `productCode`,
	        `orderDate`,
	        quantity
	    )
	VALUES (NEW.`productCode`, NOW(), 10);
	END IF;
	END // 


delimiter ; 

-- 9. Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas

CREATE ROLE empleado;

GRANT SELECT,CREATE VIEW ON classicmodels.* to empleado;

show GRANTS for empleado 