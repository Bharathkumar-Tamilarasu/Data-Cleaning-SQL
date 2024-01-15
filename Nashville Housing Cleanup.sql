-- 1. SaleDate

-- Changing the saledate column from Varchar format to Date Format

UPDATE PROPERTY
SET SALEDATE = TO_DATE(SALEDATE,'Month DD, YYYY')

-- Update wont change the data type. Hence changing the Data Type of that to date

ALTER TABLE PROPERTY
ALTER COLUMN SALEDATE TYPE date USING SALEDATE::date

-- 2. Property address - Filling null values

-- First check the null values of the column
-- Joined (Self Join) both columns using ParcelID and UniqueID
-- Assigned the b.propertyaddress to the null value of a.propertyaddress
-- Updated the actual propertyaddress from the property table

UPDATE PROPERTY A
SET PROPERTYADDRESS = B.PROPERTYADDRESS
FROM
	(SELECT PARCELID,
			PROPERTYADDRESS
		FROM PROPERTY
		WHERE PROPERTYADDRESS IS NOT NULL ) B
WHERE A.PARCELID = B.PARCELID
	AND A.PROPERTYADDRESS IS NULL;

-- 3. Spliting Property Address (Using Substring)

-- Adding two columns (City and Address)

ALTER TABLE PROPERTY 
	ADD COLUMN ADDRESS VARCHAR(300),
	ADD COLUMN CITY VARCHAR(300)
	
-- Updating the column values

UPDATE PROPERTY
SET CITY = SUBSTRING(PROPERTYADDRESS FROM POSITION(',' IN PROPERTYADDRESS) + 2),
	ADDRESS = SUBSTRING(PROPERTYADDRESS,1,POSITION(',' IN PROPERTYADDRESS)-1)
	
-- 4. Spliting Owner Address (Using Split_part)

-- Adding three columns (Address, City and State)

ALTER TABLE PROPERTY
	ADD COLUMN SPLITEDOWNERADDRESS VARCHAR(300),
	ADD COLUMN SPLITEDOWNERCITY VARCHAR(300),
	ADD COLUMN SPLITTEDOWNERSTATE VARCHAR(300)

-- Updating the column values

UPDATE PROPERTY
SET SPLITEDOWNERADDRESS = TRIM(SPLIT_PART(OWNERADDRESS,',',1)),
	SPLITEDOWNERCITY = TRIM(SPLIT_PART(OWNERADDRESS,',',2)),
	SPLITTEDOWNERSTATE = TRIM(SPLIT_PART(OWNERADDRESS,',',3))
	
-- 5. Changing SoldasVacant column

-- Changing the value from Y/N to Yes/No

UPDATE PROPERTY
SET SOLDASVACANT = CASE
WHEN SOLDASVACANT = 'N' THEN 'No'
WHEN SOLDASVACANT = 'Y' THEN 'Yes'
ELSE SOLDASVACANT
END

-- 6. Removing Duplicates

-- Deleting the rows where we have same values on parcelid, propertyaddress, saledate, saleprice, legalreference & OwnerAddress

WITH MYCTE AS
	(SELECT *,
		ROW_NUMBER() OVER(PARTITION BY PARCELID,PROPERTYADDRESS,SALEDATE,
			SALEPRICE, LEGALREFERENCE
		ORDER BY PARCELID) AS rownum
		FROM PROPERTY)
DELETE
FROM PROPERTY
WHERE UNIQUEID IN
		(SELECT UNIQUEID
			FROM MYCTE
			WHERE rownum > 1)
	
-- 7. Dropping Unused columns

ALTER TABLE PROPERTY
DROP COLUMN PROPERTYADDRESS,
DROP COLUMN OWNERADDRESS,
DROP COLUMN TAXDISTRICT
