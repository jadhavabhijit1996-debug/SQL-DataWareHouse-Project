SELECT
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost,0) as prd_cost,
CASE UPPER(prd_line)
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other Sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'n/a'
	END as prd_line,
CAST(prd_start_dt AS DATE),
CAST(LEAD(prd_start_dt) over(PARTITION BY prd_key order by prd_start_dt)-1 AS DATE) as prd_end_dt_test
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN (Select sls_prd_key from bronze.crm_sales_details);

Select distinct id from bronze.erp_px_cat_g1v2;

Select * from bronze.crm_sales_details;
Select * from bronze.crm_prd_info WHERE prd_start_dt>prd_end_dt;

--Quality checks
--Check for NULLS or Duplicates in Primary key
--Expectation: No result
Select prd_id, count(*) from silver.crm_prd_info group by prd_id having count(*)>1;
--Check for unwanted spaces
--Expectation: No result
Select prd_nm from silver.crm_prd_info where prd_nm != TRIM(prd_nm);
--Check for Nulls and Negative cost
--Expectation: No result
Select * from silver.crm_prd_info where prd_cost<0 or prd_cost is null;
--Data Standardization & Consistency
Select distinct prd_line from silver.crm_prd_info;
--Check for Invalid date orders
Select * from silver.crm_prd_info where prd_start_dt > prd_end_dt;



--Cleaning bronze.crm_sales_details
Select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details;

Select * from silver.crm_prd_info;

Select * from bronze.crm_cust_info;

--Check for Invalid dates
Select 
NULLIF(sls_order_dt,0) as sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details where 
sls_due_dt<=0 or 
LEN(sls_due_dt)!=8 or 
sls_due_dt>20500101 or 
sls_due_dt<19000101;
