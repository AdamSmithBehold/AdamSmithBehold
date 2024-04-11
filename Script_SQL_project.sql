-- selecting the database we want to work with
USE mintclassics;

SELECT *
FROM warehouses;

SELECT *
FROM products;

-- both query generate the same output
SELECT COUNT(*)
FROM products;

-- check if there are products that stored in multiple warehouse
SELECT 
	 productCode, 
	 COUNT(warehouseCode) AS warehouse
FROM products
GROUP BY productCode
HAVING COUNT(warehouseCode) > 1;

-- identify unique product count and their total stock on each warehouse 
SELECT 
	p.warehouseCode,
	w.warehouseName,
	COUNT(productCode) AS total_product, 
	SUM(p.quantityInStock) AS total_stock
FROM products p
JOIN warehouses AS w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseCode
order by total_product ,warehouseCode asc;

-- identify what product line each warehouse stored
SELECT 
	p.warehouseCode,
	w.warehouseName,
    p.productLine,
	COUNT(productCode) AS total_product, 
	SUM(p.quantityInStock) AS total_stock
FROM products p 
JOIN warehouses AS w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseCode, w.warehouseName, p.productLine
order by total_product ,warehouseCode asc;

-- Q.5 What is the current storage location of each product?
SELECT 
    p.productname,
    p.quantityinstock,
    w.warehousecode,
    w.warehousename
FROM
    products p
        JOIN
    warehouses w ON p.warehouseCode = w.warehouseCode;

# Q.6 Can you identify products that share the same storage location?   
 SELECT 
    productname, 
    warehouseCode
FROM
    products
    order by warehouseCode;
    
# Q.7 Are there products with low quantities that can be consolidated into fewer storage locations?
 SELECT 
    productcode,
    productname,
    warehousecode,
    SUM(quantityinstock) AS total_quantity
FROM
   products
GROUP BY productcode ,warehousecode
order by total_quantity ,warehouseCode asc;


SELECT
 DISTINCT(status)
FROM orders;

CREATE TEMPORARY TABLE inventory_summary AS(
 SELECT
  p.warehouseCode AS warehouseCode,
  p.productCode AS productCode,
        p.productName AS productName,
  p.quantityInStock AS quantityInStock,
  SUM(od.quantityOrdered) AS total_ordered,
  p.quantityInStock - SUM(od.quantityOrdered) AS remaining_stock,
  CASE 
   WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > (2 * SUM(od.quantityOrdered)) THEN 'Overstocked'
   WHEN (p.quantityInStock - SUM(od.quantityOrdered)) < 650 THEN 'Understocked'
   ELSE 'Well-Stocked'
  END AS inventory_status
 FROM products AS p
 JOIN orderdetails AS od ON p.productCode = od.productCode
 JOIN orders o ON od.orderNumber = o.orderNumber
 WHERE o.status IN ('Shipped', 'Resolved')
 GROUP BY 
  p.warehouseCode,
  p.productCode,
  p.quantityInStock
);

SELECT *
FROM inventory_summary;

SELECT COUNT(*)
FROM inventory_summary;

SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    p.warehouseCode
FROM products AS p
LEFT JOIN inventory_summary AS isum ON p.productCode = isum.productCode
WHERE isum.productCode IS NULL;

SELECT
    warehouseCode,
    inventory_status,
    COUNT(*) AS product_count
FROM inventory_summary
GROUP BY warehouseCode, inventory_status
order by warehouseCode;

SELECT
      productCode,
      productName,
      remaining_stock,
      warehouseCode
FROM inventory_summary
WHERE inventory_status = 'Overstocked'
ORDER BY warehouseCode, remaining_stock desc;

SELECT COUNT(*) as product_overstocked
FROM (SELECT
      productCode,
      productName,
      remaining_stock,
      warehouseCode
FROM inventory_summary
WHERE inventory_status = 'Overstocked'
ORDER BY warehouseCode, remaining_stock desc) AS os;

SELECT
      productCode,
      productName,
      remaining_stock,
      warehouseCode
FROM inventory_summary
WHERE inventory_status = 'Understocked'
ORDER BY warehouseCode;

SELECT COUNT(*) as product_understocked
FROM (SELECT
      productCode,
      productName,
      remaining_stock,
      warehouseCode
FROM inventory_summary
WHERE inventory_status = 'Understocked'
ORDER BY warehouseCode) AS US;


		
