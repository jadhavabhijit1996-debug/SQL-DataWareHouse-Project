/*
=======================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=======================================================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
  -Truncates Silver tables.
  -Inserts transformed and cleansed data from Bronze into Silver Tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC Silver.load_silver:
=======================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_bronze AS
BEGIN
	--DATETIME2 is used because it contains milliseconds time as well and number in bracket is used for how many precision
	--SYSDATETIME is used to get datetime in milliseconds, because GETDATE truncates the time to seconds
	DECLARE @silver_start_time DATETIME2(3), @silver_end_time DATETIME2(3), @crm_start_time DATETIME2(3), @crm_end_time DATETIME2(3), @erp_start_time DATETIME2(3), @erp_end_time DATETIME2(3), @start_time DATETIME2(3), @end_time DATETIME2(3);

	BEGIN TRY
		SET @silver_start_time = SYSDATETIME();
		PRINT'Silver Layer Starting Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';

		PRINT'===========================================================';
		PRINT'Loading Silver Layer';
		PRINT'===========================================================';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @crm_start_time = SYSDATETIME();
		PRINT'CRM Tables Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';

		PRINT'===========================================================';
		PRINT'Loading CRM Tables';
		PRINT'===========================================================';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.crm_cust_info Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT'>> Inserting Data Into: silver.crm_cust_info';

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
		
		SET @end_time = SYSDATETIME();
		PRINT'silver.crm_cust_info Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for silver.crm_cust_info: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.crm_prd_info Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT'>> Inserting Data Into: silver.crm_prd_info';

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
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id, --Extracting category id. #####This is known as Derived new columns
			SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key, --Extracting product key. #####This is known as Derived new columns
			prd_nm,
			ISNULL(prd_cost,0) as prd_cost, --Instead of Null we will transform it to 0 value. #####This is known as Handling NULL values
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
				AS DATE) as prd_end_dt --Calculate end date as one day before next start date.#####This is known as data enrichment, making the data enhanced for analysis
			FROM bronze.crm_prd_info;
		
		SET @end_time = SYSDATETIME();
		PRINT'bronze.crm_prd_info Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.crm_prd_info: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.crm_sales_details Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT'>> Inserting Data Into: silver.crm_sales_details';

			INSERT INTO silver.crm_sales_details(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)
			Select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,  --handling invalid data and casting data type from INT to DATE
			CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,  --handling invalid data and casting data type from INT to DATE
			CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,  --handling invalid data and casting data type from INT to DATE
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				 THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,  --handling invalid data and deriving data from existing data with applying mathematical calculations
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				 THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
			END AS sls_price  --handling invalid data and deriving data from existing data with applying mathematical calculations
			from bronze.crm_sales_details;
		
		SET @end_time = SYSDATETIME();
		PRINT'silver.crm_sales_details Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for silver.crm_sales_details: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		PRINT'>> CRM Tables Loading Completd';
		SET @crm_end_time = SYSDATETIME();
		PRINT'CRM Tables Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for CRM Tables: ' + CAST(DATEDIFF(millisecond,@crm_start_time,@crm_end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';
		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @erp_start_time = SYSDATETIME();
		PRINT'ERP Tables Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		
		PRINT'----------------------------------------------------------------------------------------------------------------------';

		PRINT'===========================================================';
		PRINT'Loading ERP Tables';
		PRINT'===========================================================';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.erp_cust_az12 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT'>> Inserting Data Into: silver.erp_cust_az12';

			INSERT INTO silver.erp_cust_az12 (
				cid,
				bdate,
				gen
			)
			Select
			CASE WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid),4,LEN(cid))
				 ELSE TRIM(cid)
			END AS cid, --handled invalid values by removing prefixes NAS
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate, --Handled invalid values, Setting future birthdates as NULL
			CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				 ELSE 'n/a'
			END AS gen --Normalized gender values handled unknown cases
			from bronze.erp_cust_az12;
			
		SET @end_time = SYSDATETIME();
		PRINT'silver.erp_cust_az12 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for silver.erp_cust_az12: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.erp_loc_a101 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT'>> Inserting Data Into: silver.erp_loc_a101';
			
			INSERT INTO silver.erp_loc_a101 (
				cid,
				cntry
			)
			Select 
			REPLACE(cid, '-','') AS cid, --handled invalid values and transformed it to required format
			CASE WHEN UPPER(TRIM(cntry)) IN ('USA','US','UNITED STATES') THEN 'United States of America'
				 WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry --Normalizing the data and handling missing or blank country codes
			from bronze.erp_loc_a101;

		SET @end_time = SYSDATETIME();
		PRINT'silver.erp_loc_a101 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for silver.erp_loc_a101: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'silver.erp_px_cat_g1v2 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT'>> Inserting Data Into: silver.erp_px_cat_g1v2';

			INSERT INTO silver.erp_px_cat_g1v2 (
				id,
				cat,
				subcat,
				maintenance
			)
			Select 
			id,
			cat,
			subcat,
			maintenance
			from bronze.erp_px_cat_g1v2;

		SET @end_time = SYSDATETIME();
		PRINT'silver.erp_px_cat_g1v2 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for silver.erp_px_cat_g1v2: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		PRINT'>> ERP Tables Loading Completed';
		SET @erp_end_time = SYSDATETIME();
		PRINT'ERP Tables Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for ERP Tables: ' + CAST(DATEDIFF(millisecond,@erp_start_time,@erp_end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';
		PRINT'>> Loading of Silver Layer is Completed';
		SET @silver_end_time = SYSDATETIME();
		PRINT'Silver Layer Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for Silver Layer: ' + CAST(DATEDIFF(millisecond,@silver_start_time,@silver_end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@silver_start_time,@silver_end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

	END TRY
	
	BEGIN CATCH
		PRINT'===========================================================';
		PRINT'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT'Error Message' + ERROR_MESSAGE();
		PRINT'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT'===========================================================';
	END CATCH
END
