Select * from gold.dim_customers
Select * from gold.dim_products
Select * from gold.fact_sales

--now check inetgrity between fact and dimensions using foreign key
Select * from gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
