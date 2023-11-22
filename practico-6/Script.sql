USE classicmodels;
-- 1 Devuelva la oficina con mayor número de empleados.
SELECT
	o.officeCode,
	count(e.officeCode) AS total
FROM
	offices o
INNER JOIN employees e ON 
	e.officeCode = o.officeCode
GROUP BY
	e.officeCode;
-- 2 ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?
SELECT
	avg(o.orderNumber)
FROM
	`orders` o
INNER JOIN customers c ON 
	o.customerNumber = c.customerNumber
INNER JOIN employees e ON 
	c.salesRepEmployeeNumber = e.employeeNumber;

SELECT
	e.officeCode
FROM
	`orders` o
INNER JOIN customers c ON 
	o.customerNumber = c.customerNumber
INNER JOIN employees e ON 
	c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY
	e.officeCode
ORDER BY
	COUNT(o.orderNumber) DESC
LIMIT 1;
-- 3 Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.
SELECT 
	MONTHNAME(p.paymentDate) AS `mes`, 
	AVG(p.amount) AS `prom`, 
	MAX(p.amount) AS `max`, 
	MIN(p.amount) AS `min`
FROM 
	payments p
GROUP BY 
	MONTHNAME(p.paymentDate);
-- 4 Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.
DELIMITER //
CREATE PROCEDURE Update_credit(IN client_id INT, IN new_credit_limit INT)
BEGIN
	ALTER TABLE customers
	SET
creditLimit = new_credit_limit
WHERE
customerNumber = client_id
END //
DELIMITER ;


CALL Update_credit(103,
21100);

SELECT
	*
FROM
	customers c
WHERE
	customerNumber = 103;
-- 5 Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.

CREATE VIEW Premium_Customers AS
SELECT c.customerNumber, c.customerName, sum(p.amount) AS compras
FROM customers c 
INNER JOIN payments p ON 
	c.customerNumber = p.customerNumber 
GROUP BY c.customerNumber 
ORDER BY compras DESC 
LIMIT 10;

SELECT * FROM Premium_Customers;
-- 6 Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.
DELIMITER //
CREATE FUNCTION employee_of_the_month(mes INT, anio INT)
RETURNS varchar(255) DETERMINISTIC 
BEGIN 
	DECLARE res varchar(255);
		SELECT CONCAT(e.firstName," ", e.lastName)
		INTO res
		FROM employees e
		INNER JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber 
		INNER JOIN orders o ON o.customerNumber = c.customerNumber
		WHERE MONTH(o.orderDate) = mes AND year(o.orderDate) = anio
		GROUP BY e.employeeNumber
		ORDER BY count(o.orderNumber) DESC 
		LIMIT 1;
	RETURN res;
END;//
DELIMITER ;

SELECT * FROM employees e 
WHERE CONCAT(e.firstName," ", e.lastName) = employee_of_the_month(2, 2003);

-- 7 Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.
CREATE TABLE product_refillment(
	refillmentID int NOT NULL,
	productCode varchar(15),
	orderDate date,
	quantity int DEFAULT 0,
	PRIMARY KEY (refillmentID),
	FOREIGN KEY (productCode) REFERENCES products(productCode)
);

-- 8 Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.
delimiter // 
CREATE TRIGGER restock_product
AFTER INSERT ON orderdetails
FOR EACH ROW 
BEGIN 
	DECLARE qty_in_stock integer;
	SELECT quantityInStock- NEW.quantityOrdered INTO qty_in_stock 
	FROM products p 
	WHERE p.productCode = NEW.productCode;
	
	IF qty_in_stock < 10 THEN
		INSERT INTO product_refillment (productCode, orderDate, quantity) 
		VALUES (NEW.productCode, CURDATE(), 10);
	END IF;
END;//
delimiter ;

DROP  trigger restock_product;

-- 9 Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.

CREATE ROLE Empleado; 
GRANT SELECT ON classicmodels.* TO Empleado;


-- ADICIONALES

-- Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.
WITH customersN AS (SELECT *
	FROM customers
	WHERE city LIKE "N%"
	) 
SELECT 
	c.customerNumber,
	MIN(ABS(DATEDIFF(p2.paymentDate, p1.paymentDate))) AS "min date diff", 							
	MAX(ABS(DATEDIFF(p2.paymentDate, p1.paymentDate))) AS "max date diff"
FROM payments p1
INNER JOIN payments p2 ON p2.customerNumber = p1.customerNumber
INNER JOIN customersN c ON c.customerNumber = p1.customerNumber
-- WHERE p2.paymentDate <> p1.paymentDate
WHERE p2.checkNumber <> p1.checkNumber 
GROUP BY c.customerNumber;

-- Encontrar el nombre y la cantidad vendida total de los 10 productos más vendidos que, a su vez, representen al menos el 4% del total de productos, contando unidad por unidad, de todas las órdenes donde intervienen. No utilizar LIMIT.











