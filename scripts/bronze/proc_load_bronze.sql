/*
----------------------------------------------------------------------------------------------------------------
Stored Procedure: Load Bronze Layer (source -> Bronze)
----------------------------------------------------------------------------------------------------------------
Script Purpose:
	This stored procedure loads data into the 'bronze' schema fom external CSV files.
	It performs the following actions:
	- Truncates the bronze tables before loading the data.
	- Uses the 'BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usuage Example:
	EXEC bronze.load_bronze;
----------------------------------------------------------------------------------------------------------------
*/

/*
---------------------------------------------------------------------------------------------------------------------------------------------
Notes:
In order to bulk load the data into the table created the we have to use the bulk insert
It is different from regular insert where we do not have to manually insert the data
Here we can specify the conditions:
for example: data starts from 2nd row as the 1st row is headers,
** Most Important: We have to specify the delimiter (how the data is separated for each row) using FIELDTERMINATOR

As we are using a bulk insert there are chances of getting duplicate if there is any prior data or might be executed twice.
So, we have to use the Truncate as the beginning so, that all the data is cleared and then do a BULK INSERT as we are doing a full load.

As we have to recurring do this truncate and full load we can create a stored procedure and just exec SP.

In order to identify the bottlnecks we can add variables to get the duration for each truncate and insert.
-------------------------------------------------------------------------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time = GETDATE();
	BEGIN TRY
		PRINT '===========================================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '===========================================================================================';
	
		PRINT '-------------------------------------------------------------------------------------------';
		PRINT 'Loading CRM Tabes';
		PRINT '-------------------------------------------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
	
		PRINT '>>Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
	
		PRINT '>>Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';

		PRINT '-------------------------------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
	
		PRINT '>>Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
	
		PRINT '>>Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
		PRINT '>>Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Abhishek\OneDrive\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'--------------------------------------------------------------------------------------------';
		SET @batch_end_time = GETDATE();
		PRINT'-----------------------------------------------------------------------------------------------';
		PRINT'>>Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'-----------------------------------------------------------------------------------------------';
	END TRY
	BEGIN CATCH
		PRINT '-------------------------------------------------------------------------------------------';
		PRINT 'Error Occured During Loading Bronze Layer';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '-------------------------------------------------------------------------------------------';
	END CATCH
END
