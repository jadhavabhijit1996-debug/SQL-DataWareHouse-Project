/*
==================================================================================================
Quality Checks
==================================================================================================
Script Purpose:
  This script performs quality checks to validate the integrity, consistency, and accuracy of the
  Gold layer. These checks ensure:
  - Uniqueness of surrogate keys in dimension tables.
  - Referential integrity between fact and dimension tables.
  - Validation of relationships in the data model for analytical purposes.

Usage Notes:
  - Run these checks after data loading Gold layer.
  - Investigate and resolve any discrepancies found during the checks.
==================================================================================================
*/


--======================================================
--Check 'gold.customer_key'
--======================================================
--check for uniqueness of product key in gold.dim_customers
--Expectation: No result

Select
  customer_key,
  Count(*) AS duplicate_count
from gold.dim_customers
GROUP BY customer_key
HAVING Count(*) > 1;
  

--======================================================
--Check 'gold.product_key'
--======================================================
--check for uniqueness of product key in gold.dim_products
--Expectation: No result

Select
  product_key,
  Count(*) AS duplicate_count
from gold.dim_products
GROUP BY product_key
HAVING Count(*) > 1;


--======================================================
--Check 'gold.fact_sales'
--======================================================
  
--Check data model connectivity between fact and dimensions

Select * from gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL or p.product_key IS NULL
