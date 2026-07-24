/*
====================================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
====================================================================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions;
	- Truncates the bronze tables before loading data.
	- Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.
	
Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.
	
Usage Example:
	EXECUTE bronze.load_bronze;
====================================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	--DATETIME2 is used because it contains milliseconds time as well and number in bracket is used for how many precision
	--SYSDATETIME is used to get datetime in milliseconds, because GETDATE truncates the time to seconds
	DECLARE @bronze_start_time DATETIME2(3), @bronze_end_time DATETIME2(3), @crm_start_time DATETIME2(3), @crm_end_time DATETIME2(3), @erp_start_time DATETIME2(3), @erp_end_time DATETIME2(3), @start_time DATETIME2(3), @end_time DATETIME2(3);

	BEGIN TRY
		SET @bronze_start_time = SYSDATETIME();
		PRINT'Bronze Layer Starting Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';

		PRINT'===========================================================';
		PRINT'Loading Bronze Layer';
		PRINT'===========================================================';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @crm_start_time = SYSDATETIME();
		PRINT'CRM Tables Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';

		PRINT'-----------------------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.crm_cust_info Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT'>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.crm_cust_info Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.crm_cust_info: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.crm_prd_info Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT'>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.crm_prd_info Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.crm_prd_info: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.crm_sales_details Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT'>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.crm_sales_details Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.crm_sales_details: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
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

		PRINT'-----------------------------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.erp_cust_az12 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT'>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.erp_cust_az12 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.erp_cust_az12: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.erp_loc_a101 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT'>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.erp_loc_a101 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.erp_loc_a101: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

		SET @start_time = SYSDATETIME();
		PRINT'bronze.erp_px_cat_g1v2 Table Loading Start Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT'>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\SQL_DataWareHouse_Project_By_Bara\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = SYSDATETIME();
		PRINT'bronze.erp_px_cat_g1v2 Table Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
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
		PRINT'>> Loading of Bronze Layer is Completed';
		SET @bronze_end_time = SYSDATETIME();
		PRINT'Bronze Layer Loading End Time: ' + CAST(SYSDATETIME() AS NVARCHAR);
		PRINT'                ---------------------------                ';
		PRINT'>> Load Duration for Bronze Layer: ' + CAST(DATEDIFF(millisecond,@bronze_start_time,@bronze_end_time) AS NVARCHAR(10)) + ' milliseconds (' + CAST(DATEDIFF(millisecond,@start_time,@end_time)/1000.0 AS NVARCHAR(10)) + ' sec)';
		PRINT'-----------------------------------------------------------';

		PRINT'----------------------------------------------------------------------------------------------------------------------';

	END TRY

	BEGIN CATCH
		PRINT'===========================================================';
		PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT'Error Message' + ERROR_MESSAGE();
		PRINT'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT'===========================================================';
	END CATCH
END
