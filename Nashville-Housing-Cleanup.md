# Nashville Housing Cleanup
## SQL Queries Details

**Author**: Bharathkumar Tamilarasu <br />
**Email**: bharathkumar.t.17@gmail.com <br />
**Website**: https://bharathkumart17.wixsite.com/portfolio <br />
**LinkedIn**: https://www.linkedin.com/in/bharathkumar-tamilarasu-218429222/  <br />
***
**1 (i)**  Changing the `saledate` column from Varchar format to Date Format

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


**Results: Before After**

| uniqueid | saledate (var char type) |
|----------|--------------------------|
| 2045     | 09-04-2013               |
| 16918    | 10-06-2014               |
| 54582    | 26-09-2016               |
| 43070    | 29-01-2016               |
| 22714    | 10-10-2014               |



To be continued....

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:






