----------------------------------------------------------------------
-- counting the number of null values in each row
SELECT 
  COUNT(*) as total_rows, #5783100 
  COUNT(*) - COUNT(ride_id) as null_ride_id,
  COUNT(*) - COUNT(rideable_type) as null_rideable_type,
  COUNT(*) - COUNT(started_at) as null_started_at, 
  COUNT(*) - COUNT(ended_at) as null_ended_at,
  COUNT(*) - COUNT(start_station_name) as null_start_station_name, #1080148
  COUNT(*) - COUNT(start_station_id) as null_start_station_id, #1080148
  COUNT(*) - COUNT(end_station_name) as null_end_station_name,  #1110075
  COUNT(*) - COUNT(end_station_id) as null_end_station_id,    #1110075
  COUNT(*) - COUNT(start_lat) as null_start_lat,
  COUNT(*) - COUNT(start_lng) as null_start_lng,
  COUNT(*) - COUNT(end_lat) as null_end_lat, #6744
  COUNT(*) - COUNT(end_lng) as null_end_lng,  #6744
  COUNT(*) - COUNT(member_casual) as null_member_casual
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`;


----------------------------------------------------------------------
-- checking for blank (non-null) strings in the data
-- outputs 0
SELECT
  *
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
WHERE start_station_name = " " OR end_station_name = " " 
OR start_station_id = " " OR end_station_name = " " 
OR ride_id = " " OR rideable_type = " "
OR member_casual = " ";


----------------------------------------------------------------------
-- check if ride_id is unique for each row
-- ouputs 215 rows that have duplicated ride_id
SELECT                     
  ride_id,
  COUNT(ride_id) AS distinct_ride_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY ride_id
HAVING distinct_ride_id > 1
ORDER BY distinct_ride_id DESC;


----------------------------------------------------------------------
-- check distinct values of rideable_type
-- outputs 3 distinct values: 
--  - electric_bike
--  - electric_scooter
--  - classic_bike
SELECT
  DISTINCT rideable_type
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`;


----------------------------------------------------------------------
-- checks distinct values of start_station_name
-- outputs 2041 rows
-- some start_station_name map to multiple start_station_id
-- no more than 2 start_station_id if inconsistency exist
-- some start_station_id map to multiple start_station_name
-- no more than 2 start_station_name if inconsistency exist
SELECT
  DISTINCT start_station_name,
  start_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`;


----------------------------------------------------------------------
-- checks start_station_name on how many values that ends with char '*'
-- 18 outputs
SELECT
  DISTINCT start_station_name,
  start_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
WHERE start_station_name LIKE '%*%';


----------------------------------------------------------------------
-- checks start_station_id on how many values that ends with char '.0'
-- 180 outputs
SELECT
  DISTINCT start_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
WHERE start_station_id LIKE '%.0%';


----------------------------------------------------------------------
-- for each start_station_name that map to multiple start_station_id, shows all start_station_name and start_station_ids
-- outputs 49
SELECT
    start_station_name,
    STRING_AGG(DISTINCT CAST(REGEXP_REPLACE(start_station_id, r'\.0+$', '') AS STRING), ', ') AS start_station_ids
 FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY
    start_station_name
HAVING
    COUNT(DISTINCT REGEXP_REPLACE(start_station_id, r'\.0+$', '')) > 1;


----------------------------------------------------------------------
-- for each start_station_id with multiple name variations, show all associated start_station_names and their counts.
-- outputs 96 rows
WITH start_station_cols AS (
  SELECT 
    REGEXP_REPLACE(start_station_name, r'\*+$', '') AS cleaned_start_station_name,
    CASE
      WHEN start_station_id != '331.0' THEN REGEXP_REPLACE(start_station_id, r'\.0+$', '')
      ELSE start_station_id
    END AS cleaned_start_station_id
  FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
),

station_variants AS (
  SELECT
    cleaned_start_station_id,
    MIN(cleaned_start_station_name) AS first_name,
    MAX(cleaned_start_station_name) AS second_name
  FROM start_station_cols
  GROUP BY cleaned_start_station_id
  HAVING MIN(cleaned_start_station_name) != MAX(cleaned_start_station_name)
)

SELECT
  sv.cleaned_start_station_id AS end_station_id,
  sv.first_name AS first_start_station_name,
  sv.second_name AS second_start_station_name,
  COUNTIF(cd.cleaned_start_station_name = sv.first_name) AS first_name_count,
  COUNTIF(cd.cleaned_start_station_name = sv.second_name) AS second_name_count
FROM station_variants sv
JOIN start_station_cols cd
  ON sv.cleaned_start_station_id = cd.cleaned_start_station_id
GROUP BY 1, 2, 3
ORDER BY 1;


----------------------------------------------------------------------
-- checks distinct values of end_station_name
-- outputs 2052 rows
-- some end_station_name map to multiple end_station_id
-- no more than 2 end_station_id if inconsistency exist
-- some end_station_id map to multiple end_station_name
-- no more than 2 end_station_name if inconsistency exist
SELECT
  DISTINCT end_station_name,
  end_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`;


----------------------------------------------------------------------
-- checks end_station_name on how many values that ends with char '*'
-- 18 outputs
SELECT
  DISTINCT end_station_name,
  end_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
WHERE end_station_name LIKE '%*%';


----------------------------------------------------------------------
-- checks end_station_id on how many values that ends with char '.0'
-- 181 outputs
SELECT
  DISTINCT end_station_id
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
WHERE end_station_id LIKE '%.0%';


----------------------------------------------------------------------
-- for each end_station_name that map to multiple end_station_id, shows all end_station_name and end_station_ids
-- outputs 49
SELECT
    end_station_name,
    STRING_AGG(DISTINCT CAST(REGEXP_REPLACE(end_station_id, r'\.0+$', '') AS STRING), ', ') AS end_station_ids
 FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY
    end_station_name
HAVING
    COUNT(DISTINCT REGEXP_REPLACE(end_station_id, r'\.0+$', '')) > 1;


----------------------------------------------------------------------
-- for each end_station_id with multiple name variations, show all associated start_station_names and their counts.
-- outputs 96 rows
WITH end_station_cols AS (
  SELECT 
    REGEXP_REPLACE(end_station_name, r'\*+$', '') AS cleaned_end_station_name,
    CASE
      WHEN end_station_id != '331.0' THEN REGEXP_REPLACE(end_station_id, r'\.0+$', '')
      ELSE end_station_id
    END AS cleaned_end_station_id
  FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
),

station_variants AS (
  SELECT
    cleaned_end_station_id,
    MIN(cleaned_end_station_name) AS first_name,
    MAX(cleaned_end_station_name) AS second_name
  FROM end_station_cols
  GROUP BY cleaned_end_station_id
  HAVING MIN(cleaned_end_station_name) != MAX(cleaned_end_station_name)
)

SELECT
  sv.cleaned_end_station_id AS end_station_id,
  sv.first_name AS first_end_station_name,
  sv.second_name AS second_end_station_name,
  COUNTIF(cd.cleaned_end_station_name = sv.first_name) AS first_name_count,
  COUNTIF(cd.cleaned_end_station_name = sv.second_name) AS second_name_count
FROM station_variants sv
JOIN end_station_cols cd
  ON sv.cleaned_end_station_id = cd.cleaned_end_station_id
GROUP BY 1, 2, 3
ORDER BY 1;


----------------------------------------------------------------------
-- explores starting coordinates
-- 1	41.892278, -87.612043
SELECT
  CONCAT(start_lat,', ',start_lng) AS coordinates,
  COUNT(*) AS frequency
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY coordinates
ORDER BY frequency desc
LIMIT 10;


----------------------------------------------------------------------
-- explores ending coordinates
-- 1	41.892278, -87.612043
SELECT
  CONCAT(end_lat,', ',end_lng) AS coordinates,
  COUNT(*) AS frequency
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY coordinates
ORDER BY frequency desc
LIMIT 10;


----------------------------------------------------------------------
-- counting rides where start and end coordinates match, with at least 1 minute duration
-- outputs 6
-- indicates round trips
SELECT
  CONCAT(end_lat,', ',end_lng) AS end_coordinates,
  CONCAT(start_lat,', ',start_lng) AS start_coordinates,
  TIMESTAMP_DIFF(started_at, ended_at, MINUTE) AS time_length
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
GROUP BY 1,2,3
HAVING end_coordinates = start_coordinates 
AND time_length != 0 AND time_length > 0;


----------------------------------------------------------------------
-- checks distinct values in member_casual
SELECT
  DISTINCT member_casual
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`;


----------------------------------------------------------------------
-- identifies format values in timestamp format
--  - YYYY-MM-DD HH:MM:SS UTC
SELECT
  started_at,ended_at
FROM `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
LIMIT 20;


-- data cleaning to do:
-- remove null start_station_name, start_station_id, end_station_name, end_station_id
-- remove duplicated ride_id
-- have consistent values in start_station_name, end_station_name, start_station_id, end_station_id:
-- start_station_name and end_station_name map to only one id
-- start_station_id and end_station_id map to one station_name
