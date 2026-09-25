
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









--Quality Data for Silver Layer
--crm_cust_info
INSERT INTO silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_material_status,
cst_gndr,
cst_create_date
)
Select
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname, --removing unwanted spaces
trim(cst_lastname) as cst_lastname, --removing unwanted spaces
CASE WHEN UPPER(trim(cst_material_status)) = 'M' THEN 'Married'
	WHEN UPPER(trim(cst_material_status)) = 'S' THEN 'Single'
	ELSE 'n/a'
END as cst_material_status, --Normalize marital status
CASE WHEN UPPER(trim(cst_gndr)) = 'M' THEN 'Male'
	WHEN UPPER(trim(cst_gndr)) = 'F' THEN 'Female'
	ELSE 'n/a'
END cst_gndr, --Normalize gender
cst_create_date
from(
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as flag_last 
from bronze.crm_cust_info)a
where flag_last = 1 and cst_id is not NULL;--avoiding duplicate records by flag_last and no NULL in primary key



--crm_prd_info
--need to do some modifications in datatype for below table and then to do the insert
IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

INSERT INTO silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id, --Extracting category id
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key, --Extracting product key
prd_nm,
ISNULL(prd_cost,0) as prd_cost, --Instead of Null we will transform it to 0 value
CASE UPPER(prd_line)
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other Sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'n/a'       --Handeled missing data as well
	END as prd_line, --Map product line codes to descriptive values.#####This is known as data normalization
CAST(prd_start_dt AS DATE), --Casting data type from DATETIME to DATE
CAST(
	LEAD(prd_start_dt) over(PARTITION BY prd_key order by prd_start_dt)-1 
	AS DATE) as prd_end_test --Calculate end date as one day before next start date.#####This is known as data enrichment, making the data enhaced for analysis
FROM bronze.crm_prd_info;
