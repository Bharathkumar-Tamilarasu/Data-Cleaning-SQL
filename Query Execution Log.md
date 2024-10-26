# Nashville Housing Cleanup
## Query Execution Log
**Author**: Bharathkumar Tamilarasu <br />
**Email**: bharathkumar.t.17@gmail.com <br />
**Website**: https://www.datascienceportfol.io/bharathkumar_t <br />
**LinkedIn**: https://www.linkedin.com/in/bharathkumartamilarasu/  <br />
##

**1.**  Transforming data type of Saledate

**(i).**  Changing saledate values from the given format to a date format

````sql
UPDATE PROPERTY
SET SALEDATE = TO_DATE(SALEDATE,'Month DD, YYYY')
````

**Results: Before Execution**

| uniqueid | saledate           |
|----------|--------------------|
| 2045     | April 9, 2013      |
| 16918    | June 10, 2014      |
| 54582    | September 26, 2016 |
| 43070    | January 29, 2016   |
| 22714    | October 10, 2014   |


**Results: After Execution**

| uniqueid | saledate (varchar type) |
|----------|--------------------------|
| 2045     | 09-04-2013               |
| 16918    | 10-06-2014               |
| 54582    | 26-09-2016               |
| 43070    | 29-01-2016               |
| 22714    | 10-10-2014               |

**(ii).**  Update wont change the data type. Hence changing the data type of that to date

````sql
ALTER TABLE PROPERTY
ALTER COLUMN SALEDATE TYPE date USING SALEDATE::date
````

**Results: Before Execution**

| uniqueid | saledate (varchar type) |
|----------|--------------------------|
| 2045     | 09-04-2013               |
| 16918    | 10-06-2014               |
| 54582    | 26-09-2016               |
| 43070    | 29-01-2016               |
| 22714    | 10-10-2014               |
| 2045     | 09-04-2013               |


**Results: After Execution**

| uniqueid | saledate (date type) |
|----------|----------------------|
| 2045     | 09-04-2013           |
| 16918    | 10-06-2014           |
| 54582    | 26-09-2016           |
| 43070    | 29-01-2016           |
| 22714    | 10-10-2014           |

**2.**  Property address - Filling null values

````sql
UPDATE PROPERTY A
SET PROPERTYADDRESS = B.PROPERTYADDRESS
FROM (SELECT PARCELID, PROPERTYADDRESS
      FROM PROPERTY
      WHERE PROPERTYADDRESS IS NOT NULL ) B
WHERE A.PARCELID = B.PARCELID
	AND A.PROPERTYADDRESS IS NULL;
````

**Results: Before Execution**

| uniqueid | parcelid         | propertyaddress | saledate   |
|----------|------------------|-----------------|------------|
| 11478    | 092 13 0 322.00  | [null]          | 17-01-2014 |
| 14753    | 108 07 0A 026.00 | [null]          | 15-04-2014 |
| 15886    | 109 04 0A 080.00 | [null]          | 13-05-2014 |
| 22775    | 043 09 0 074.00  | [null]          | 27-10-2014 |
| 24197    | 110 03 0A 061.00 | [null]          | 19-11-2014 |


**Results: After Execution**

| uniqueid | parcelid         | propertyaddress                       | saledate   |
|----------|------------------|---------------------------------------|------------|
| 11478    | 092 13 0 322.00  | 237  37TH AVE N, NASHVILLE            | 17-01-2014 |
| 14753    | 108 07 0A 026.00 | 908  PATIO DR, NASHVILLE              | 15-04-2014 |
| 15886    | 109 04 0A 080.00 | 2537  JANALYN TRCE, HERMITAGE         | 13-05-2014 |
| 22775    | 043 09 0 074.00  | 213 B  LOVELL ST, MADISON             | 27-10-2014 |
| 24197    | 110 03 0A 061.00 | 2704  ALVIN SPERRY PASS, MOUNT JULIET | 19-11-2014 |

**3.**  Spliting Propertyaddress (using substring)

````sql
-- Adding two columns (City and Address)

ALTER TABLE PROPERTY 
	ADD COLUMN ADDRESS VARCHAR(300),
	ADD COLUMN CITY VARCHAR(300)
	
-- Updating the column values

UPDATE PROPERTY
SET CITY = SUBSTRING(PROPERTYADDRESS FROM POSITION(',' IN PROPERTYADDRESS) + 2),
	  ADDRESS = SUBSTRING(PROPERTYADDRESS,1,POSITION(',' IN PROPERTYADDRESS)-1)
````

**Results: Before Execution**

| uniqueid | parcelid         | propertyaddress                    | address | city   |
|----------|------------------|------------------------------------|---------|--------|
| 53147    | 026 06 0A 038.00 | 109  CANTON CT, GOODLETTSVILLE     | [null]  | [null] |
| 43076    | 025 07 0 031.00  | 410  ROSEHILL CT, GOODLETTSVILLE   | [null]  | [null] |
| 39432    | 026 01 0 069.00  | 141  TWO MILE PIKE, GOODLETTSVILLE | [null]  | [null] |
| 45290    | 026 05 0 017.00  | 208  EAST AVE, GOODLETTSVILLE      | [null]  | [null] |
| 43080    | 033 06 0 041.00  | 1129  CAMPBELL RD, GOODLETTSVILLE  | [null]  | [null] |


**Results: After Execution**

| uniqueid | parcelid         | propertyaddress                    | address            | city           |
|----------|------------------|------------------------------------|--------------------|----------------|
| 53147    | 026 06 0A 038.00 | 109  CANTON CT, GOODLETTSVILLE     | 109  CANTON CT     | GOODLETTSVILLE |
| 43076    | 025 07 0 031.00  | 410  ROSEHILL CT, GOODLETTSVILLE   | 410  ROSEHILL CT   | GOODLETTSVILLE |
| 39432    | 026 01 0 069.00  | 141  TWO MILE PIKE, GOODLETTSVILLE | 141  TWO MILE PIKE | GOODLETTSVILLE |
| 45290    | 026 05 0 017.00  | 208  EAST AVE, GOODLETTSVILLE      | 208  EAST AVE      | GOODLETTSVILLE |
| 43080    | 033 06 0 041.00  | 1129  CAMPBELL RD, GOODLETTSVILLE  | 1129  CAMPBELL RD  | GOODLETTSVILLE |

**4.**  Spliting Owner Address (using splitpart)

````sql
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
````

**Results: Before Execution**

| uniqueid | parcelid         | owneraddress                           | splitedowneraddress | splitedownercity | splittedownerstate |
|----------|------------------|----------------------------------------|---------------------|------------------|--------------------|
| 53147    | 026 06 0A 038.00 |                                        |                     |                  |                    |
| 43076    | 025 07 0 031.00  | 410  ROSEHILL CT, GOODLETTSVILLE, TN   |                     |                  |                    |
| 39432    | 026 01 0 069.00  | 141  TWO MILE PIKE, GOODLETTSVILLE, TN |                     |                  |                    |
| 45290    | 026 05 0 017.00  | 208  EAST AVE, GOODLETTSVILLE, TN      |                     |                  |                    |
| 43080    | 033 06 0 041.00  | 1129  CAMPBELL RD, GOODLETTSVILLE, TN  |


**Results: After Execution**

| uniqueid | parcelid         | owneraddress                           | splitedowneraddress | splitedownercity | splittedownerstate |
|----------|------------------|----------------------------------------|---------------------|------------------|--------------------|
| 53147    | 026 06 0A 038.00 |                                        |                     |                  |                    |
| 43076    | 025 07 0 031.00  | 410  ROSEHILL CT, GOODLETTSVILLE, TN   | 410  ROSEHILL CT    | GOODLETTSVILLE   | TN                 |
| 39432    | 026 01 0 069.00  | 141  TWO MILE PIKE, GOODLETTSVILLE, TN | 141  TWO MILE PIKE  | GOODLETTSVILLE   | TN                 |
| 45290    | 026 05 0 017.00  | 208  EAST AVE, GOODLETTSVILLE, TN      | 208  EAST AVE       | GOODLETTSVILLE   | TN                 |
| 43080    | 033 06 0 041.00  | 1129  CAMPBELL RD, GOODLETTSVILLE, TN  | 1129  CAMPBELL RD   | GOODLETTSVILLE   | TN                 |

**5.**  Changing 'soldasvacant' column values from Y/N to Yes/No

````sql
UPDATE PROPERTY
SET SOLDASVACANT =
  CASE
    WHEN SOLDASVACANT = 'N' THEN 'No'
    WHEN SOLDASVACANT = 'Y' THEN 'Yes'
    ELSE SOLDASVACANT
  END
````

**Results: Before Execution**

| soldasvacant | occurrences |
|--------------|-------------|
| No           | 51403       |
| Yes          | 4623        |
| N            | 399         |
| Y            | 52          |

**Results: After Execution**

| soldasvacant | occurrences |
|--------------|-------------|
| No           | 51802       |
| Yes          | 4675        |

**6.**  Removing duplicate rows

````sql
WITH MYCTE AS
  (
  SELECT *, ROW_NUMBER() OVER(PARTITION BY PARCELID,PROPERTYADDRESS,SALEDATE,SALEPRICE, LEGALREFERENCE,OWNERADDRESS
  ORDER BY PARCELID) AS rownum
  FROM PROPERTY
  )
DELETE
FROM PROPERTY
WHERE UNIQUEID IN
		(
    SELECT UNIQUEID
    FROM MYCTE
    WHERE rownum > 1
    )
````

**Results: Before Execution**

| parcelid        | propertyaddress                      | saledate   | saleprice | legalreference   | owneraddress                             |
|-----------------|--------------------------------------|------------|-----------|------------------|------------------------------------------|
| 081 02 0 144.00 | 1728  PECAN ST, NASHVILLE            | 02-02-2015 | 57000     | 20150205-0010843 | 1728  PECAN ST, NASHVILLE, TN            |
| 081 02 0 144.00 | 1728  PECAN ST, NASHVILLE            | 02-02-2015 | 57000     | 20150205-0010843 | 1728  PECAN ST, NASHVILLE, TN            |
| 081 07 0 265.00 | 1806  15TH AVE N, NASHVILLE          | 17-02-2015 | 65000     | 20150223-0015122 | 1806  15TH AVE N, NASHVILLE, TN          |
| 081 07 0 265.00 | 1806  15TH AVE N, NASHVILLE          | 17-02-2015 | 65000     | 20150223-0015122 | 1806  15TH AVE N, NASHVILLE, TN          |
| 081 10 0 313.00 | 1626  25TH AVE N, NASHVILLE          | 20-02-2015 | 35000     | 20150224-0015904 | 1626  25TH AVE N, NASHVILLE, TN          |
| 081 10 0 313.00 | 1626  25TH AVE N, NASHVILLE          | 20-02-2015 | 35000     | 20150224-0015904 | 1626  25TH AVE N, NASHVILLE, TN          |
| 081 11 0 168.00 | 1710  DR D B TODD JR BLVD, NASHVILLE | 13-02-2015 | 44500     | 20150218-0013602 | 1710  DR D B TODD JR BLVD, NASHVILLE, TN |
| 081 11 0 168.00 | 1710  DR D B TODD JR BLVD, NASHVILLE | 13-02-2015 | 44500     | 20150218-0013602 | 1710  DR D B TODD JR BLVD, NASHVILLE, TN |
| 081 11 0 495.00 | 1718  ARTHUR AVE, NASHVILLE          | 09-02-2015 | 36500     | 20150210-0012450 | 1718  ARTHUR AVE, NASHVILLE, TN          |
| 081 11 0 495.00 | 1718  ARTHUR AVE, NASHVILLE          | 09-02-2015 | 36500     | 20150210-0012450 | 1718  ARTHUR AVE, NASHVILLE, TN          |

**Results: After Execution**

| parcelid        | propertyaddress                      | saledate   | saleprice | legalreference   | owneraddress                             |
|-----------------|--------------------------------------|------------|-----------|------------------|------------------------------------------|
| 081 02 0 144.00 | 1728  PECAN ST, NASHVILLE            | 02-02-2015 | 57000     | 20150205-0010843 | 1728  PECAN ST, NASHVILLE, TN            |
| 081 07 0 265.00 | 1806  15TH AVE N, NASHVILLE          | 17-02-2015 | 65000     | 20150223-0015122 | 1806  15TH AVE N, NASHVILLE, TN          |
| 081 10 0 313.00 | 1626  25TH AVE N, NASHVILLE          | 20-02-2015 | 35000     | 20150224-0015904 | 1626  25TH AVE N, NASHVILLE, TN          |
| 081 11 0 168.00 | 1710  DR D B TODD JR BLVD, NASHVILLE | 13-02-2015 | 44500     | 20150218-0013602 | 1710  DR D B TODD JR BLVD, NASHVILLE, TN |
| 081 11 0 495.00 | 1718  ARTHUR AVE, NASHVILLE          | 09-02-2015 | 36500     | 20150210-0012450 | 1718  ARTHUR AVE, NASHVILLE, TN          |

**7.**  Dropping unused columns

````sql
ALTER TABLE PROPERTY
DROP COLUMN PROPERTYADDRESS,
DROP COLUMN OWNERADDRESS,
DROP COLUMN TAXDISTRICT
````

### **Your time and interest in viewing my project are greatly appreciated. Thank you. 😃!**






