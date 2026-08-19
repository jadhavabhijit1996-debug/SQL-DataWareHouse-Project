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
