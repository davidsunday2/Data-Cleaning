#Knowing the data 

-- Created a temporary staging table so I can keep the orignal table as backup

CREATE TABLE Temp_nashville_housing AS 
SELECT * FROM nashville_housing;

-- Verifying all the rows are loaded in to the database table.
select count(*) from Temp_nashville_housing;
-- A cursery view of the dataset by quering 2000 rows to see the structure and on a high level data quality issues 
select * from Temp_nashville_housing
limit 2000;

-- *****************************************************************
#Summary of data quality issues obaserved 
-- Wrangling the Date column
-- Handling Missing values in the  property addresses 
-- Splitting & Dicing Addresses,Triming leading and trailing spaces 
-- Change  inncosistent values in 'soldasvacant' field like  Y and N to Yes and No /Making ‘SoldAsVacant’ Speak Clearly
-- Duplicates records ,using a row_number() window function 
-- Streamlining for Clarity
-- *******************************************************


-- step 1: Dates in the dataset were inconsistent, so loaded them as VARCHAR and later used STR_TO_DATE() to standardize the format for analysis.
        --  With the DATE data type, dates are treated in a true chronological order, ensuring accurate sorting,comparison, and analysis

-- Standardizing Date Format

SELECT sale_date, STR_TO_DATE(sale_date, '%m/%d/%Y') AS property_sale_date
FROM Temp_nashville_housing;

-- Adding a new column for standardized dates
ALTER TABLE Temp_nashville_housing
ADD property_sale_date DATE;

UPDATE Temp_nashville_housing
SET property_sale_date = STR_TO_DATE(sale_date, '%m/%d/%Y');


#Handling Missing values in the  property addresses 
-- checking for distinct values in the propery addresses , to validate the existance of  null values
SELECT DISTINCT COALESCE(property_address, 'NULL') AS Distinct_property_addresses 
FROM temp_nashville_housing
where COALESCE(property_address, 'NULL') like 'NULL';

-- getting the count of null values in the property address 
select count(*) from temp_nashville_housing where property_address is null;

/* Handling the missing addresses usimg the parcel_id with addresses not missing. 
 The purpose is to find records where the property_address a is NULL and attempt to fill it with the address from another row in b that has the same parcel_id but a different unique_id
 I only want one matching row for each missing property_address, which is why the window function and ROW_NUMBER() are used to select the "best match"
 */

-- Create a temporary table to hold the CTE results, as you can't reference a CTE in an UPDATE statement 
CREATE TEMPORARY TABLE temp_table AS
with cte as (
select 
row_number() over(partition by a.unique_id order by a.unique_id) as rn, 
a.unique_id as unique_id_a,a.parcel_id as parcel_id_a ,a.property_address  as property_address_a , b.unique_id as unique_id_b ,b.parcel_id as parcel_id_b,b.property_address as property_address_b,
coalesce(a.property_address, b.property_address) as new_property_address
from 
temp_nashville_housing a
left join temp_nashville_housing b
on a.parcel_id=b.parcel_id and a.unique_id <>b.unique_id
where a.property_address is null
)
select 
    unique_id_a, 
    parcel_id_a, 
    property_address_a, 
    unique_id_b, 
    parcel_id_b, 
    property_address_b, 
    new_property_address
from cte
where rn = 1;

UPDATE temp_nashville_housing
SET property_address = (
  SELECT t.new_property_address
  FROM temp_table t
  WHERE t.unique_id_a = temp_nashville_housing.unique_id
)
WHERE property_address IS NULL;

-- Validating if the null values in property address are replaced successfully.
SELECT property_address
FROM temp_nashville_housing
where property_address is null;


-- Splitting & Dicing Addresses

-- ******* Splitting Property addresss

select property_address ,substr(property_address,1,locate(',',property_address)-1) as new_property_address,
						 substr(property_address,locate(',',property_address)+1,length(property_address)) as city

from temp_nashville_housing;

alter table temp_nashville_housing
add column new_property_address varchar(255);

update temp_nashville_housing
set new_property_address =trim(substr(property_address,1,locate(',',property_address)-1));

alter table temp_nashville_housing
add column city varchar(255);

update temp_nashville_housing
set city =trim(substr(property_address,locate(',',property_address)+1,length(property_address)));

-- ******* Splitting Cleaning owners addresss

select owner_address ,trim(substr(owner_address,1,locate(',',owner_address)-1)) as new_owner_address,
                      trim(substr(owner_address,locate(',',owner_address)+1, length(owner_address)-locate(',',owner_address)-4)) as owner_city,
                      trim(right(owner_address,2)) as owner_state
from temp_nashville_housing;

alter table temp_nashville_housing 
add column new_owner_address varchar(255),
add column new_owner_city varchar(255),
add column new_owner_state varchar(255);



-- Updating the table with split addresses and cities
update temp_nashville_housing
set new_owner_address=trim(substr(owner_address,1,locate(',',owner_address)-1)),
	new_owner_city=trim(substr(owner_address,locate(',',owner_address)+1, length(owner_address)-locate(',',owner_address)-4)),
    new_owner_state=trim(right(owner_address,2));



-- Change  inncosistent values in 'soldasvacant' field like  Y and N to Yes and No 
select distinct sold_as_vacant, count(*) as count
from temp_nashville_housing
group by sold_as_vacant
order by count;

-- Standardizing SoldAsVacant Data into Yes and No
select sold_as_vacant, 
	case 
		when sold_as_vacant = 'Y' then 'Yes'
		when sold_as_vacant = 'N' then 'No'
		else sold_as_vacant
	end as yes_no
from temp_nashville_housing;

-- Updating the table with standardized SoldAsVacant values
update temp_nashville_housing
set sold_as_vacant= case
                        when sold_as_vacant = 'Y' then 'Yes'
		                when sold_as_vacant = 'N' then 'No'
		                else sold_as_vacant
	                    end ;

select sold_as_vacant, count(*) as count  
from temp_nashville_housing
group by sold_as_vacant;

-- This script leverages Common Table Expressions (CTE) and window functions to identify and handle duplicate records

with temp_cte as (
select *, 
     row_number() over(partition by 
     parcel_id, 
     property_address, 
     sale_date, 
     sale_price, 
     legal_reference 
    order by unique_id) as rn 
from temp_nashville_housing
)
select count(*)
from 
temp_cte
where rn >1;

-- Handling the duplicates

WITH temp_cte AS (
  SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY 
      parcel_id, 
      property_address, 
      sale_date, 
      sale_price, 
      legal_reference 
    ORDER BY unique_id) AS rn 
  FROM temp_nashville_housing
)
DELETE FROM temp_nashville_housing
WHERE unique_id IN (
  SELECT unique_id 
  FROM temp_cte
  WHERE rn > 1
);

-- I optimized the dataset by removing unnecessary columns that I transformed with SQL, making it more efficient and focused for analysis.

ALTER TABLE temp_nashville_housing
DROP COLUMN owner_address,
DROP COLUMN tax_district,
DROP COLUMN property_address,
DROP COLUMN sale_date;

select * from temp_nashville_housing;



