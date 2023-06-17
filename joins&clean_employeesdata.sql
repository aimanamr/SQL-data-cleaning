select*
from salaries$

select*
from functions$

select*
from employees$

select*
from companies$

--create new join table which join all four table using salaries$ table as primary table
SELECT*
	INTO emp_dataset
	FROM salaries$
	LEFT JOIN companies$
	ON salaries$.comp_name = companies$.company_name
	LEFT JOIN functions$
	ON salaries$.func_code = functions$.function_code
	LEFT JOIN employees$
	ON salaries$.employee_id = employees$.employee_code_emp
	
SELECT* 
FROM emp_dataset

-- Select only relevant columns for further analysis
-- Create an unique identifier code between the columns 'employee_id' and 'date' and call it 'id'
-- Convert the column 'date' to DATE type because it was previously configured as TIMESTAMP
-- Transform this new table into a dataset (df_employee) for analysis

--select relevant column only
SELECT 
	employee_id, 
	date,
	employee_name, 
	[GEN(M_F)], 
	age, 
	salary, 
	function_group,
	company_name, 
	company_city, 
	company_state,
	const_site_category
FROM emp_dataset

-- Create an unique identifier code between the columns 'employee_id' and 'date' and call it 'id'
--Convert the column 'date' to DATE type because it was previously configured as TIMESTAMP

SELECT
	CONCAT (employee_id, CAST (date AS date)) AS id, CAST (date AS date) AS month_year
FROM emp_dataset

-- Transform this new table into a dataset (df_employee) for analysis

SELECT
	CONCAT (employee_id, CAST (date AS date)) AS id, 
	CAST (date AS date) AS month_year,
	CAST (employee_id AS nvarchar) AS employee_id, 
	date,
	employee_name, 
	[GEN(M_F)], 
	age, 
	salary, 
	function_group,
	company_name, 
	company_city, 
	company_state,
	const_site_category
INTO df_employee
FROM emp_dataset

SELECT employee_id 
FROM df_employee

--rename column [GEN(M_F)]' to 'gender'

sp_rename 'df_employee.[GEN(M_F)]', 'gender', 'COLUMN'

SELECT *
FROM df_employee
WHERE salary IS NULL

--Trim all column for standardization
UPDATE df_employee
SET employee_name = TRIM (employee_name),
	employee_id = TRIM (employee_id), 
	id = TRIM(id),
	function_group = TRIM(function_group),
	company_name = TRIM(company_name),
	company_city = TRIM(company_city),
	company_state = TRIM(company_state),
	const_site_category = TRIM(const_site_category)

-- check for 'null' values

SELECT*
FROM df_employee
WHERE id IS NULL
OR month_year IS NULL
OR employee_id IS NULL
OR date is NULL
OR employee_name IS NULL
OR gender IS NULL
OR age IS NULL
OR salary IS NULL
OR function_group IS NULL
OR company_name IS NULL
OR company_city IS NULL
OR company_state IS NULL
OR const_site_category IS NULL

--delete NULL values as not needed and cannot processed

DELETE FROM df_employee
WHERE salary IS NULL

DELETE FROM df_employee
WHERE const_site_category IS NULL

--change 'gender' M and F to Male and Female

UPDATE df_employee
SET gender = CASE gender
				WHEN 'M' THEN 'MALE'
				WHEN 'F' THEN 'FEMALE'
				ELSE gender
				END

--check for duplicated rows in 'id' column

SELECT DISTINCT id, COUNT (id) AS duplicated
FROM df_employee
GROUP BY id
HAVING COUNT(id) > 1

--remove duplicated rows with CTE
--the duplicates are those that contain repeated employee_id 
-- apply the DELETE statement with the condition that the row_num is greater than 1.

WITH rncte AS
	(SELECT *, ROW_NUMBER()
				OVER(
				PARTITION BY month_year, employee_id
				ORDER BY employee_id) row_num
	FROM df_employee)
DELETE
FROM rncte
WHERE row_num > 1

SELECT*
FROM df_employee