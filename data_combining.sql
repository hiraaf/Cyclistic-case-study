-- combine past 12 months of data 
CREATE TABLE `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data` AS
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_03_drivy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_04_drivy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_05_drivvy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_05_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_06_drivvy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_06_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_07_drivvy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_07_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_08_drivvy_data_1` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_08_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_09_drivvy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_09_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_10_drivvy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_10_drivvy_data_2` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_11__drivy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2024_12_drivy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2025_01_drivy_data` 
UNION ALL 
SELECT 
  * 
FROM `corded-aquifer-450216-k9.divvy_tripdata.2025_02_drivy_data` 
