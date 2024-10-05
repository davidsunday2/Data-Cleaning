-- nashville_housing Table create Statement 
CREATE TABLE nashville_housing(
    unique_id VARCHAR(50) PRIMARY KEY,
    parcel_id VARCHAR(50),
    land_use VARCHAR(100),
    property_address VARCHAR(255),
    sale_date text,
    sale_price DECIMAL(15, 2),
    legal_reference VARCHAR(255),
    sold_as_vacant VARCHAR(10),
    owner_name VARCHAR(255),
    owner_address VARCHAR(255),
    acreage DECIMAL(10, 2),
    tax_district VARCHAR(100),
    land_value DECIMAL(15, 2),
    building_value DECIMAL(15, 2),
    total_value DECIMAL(15, 2),
    year_built INT,
    bedrooms INT,
    full_bath INT,
    half_bath INT
) ;
-- Enable loading data from local files
SET GLOBAL local_infile = 1;

-- Load data from a CSV file into the table created in mysql DB
LOAD DATA LOCAL INFILE 'C:/Users/Hp/Desktop/self/SQL/Cleaning Projects/Cleaning Project Nashivile/Nashville.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(unique_id, parcel_id, land_use, property_address, sale_date, sale_price, legal_reference, sold_as_vacant, owner_name, owner_address, acreage, tax_district, land_value, building_value, total_value, year_built, bedrooms, full_bath, half_bath)
SET property_address = NULLIF(property_address, '');
   

