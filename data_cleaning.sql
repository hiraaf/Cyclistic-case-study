DROP TABLE IF EXISTS `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data`;

CREATE TABLE IF NOT EXISTS `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` AS (
--outputs 4012468
WITH cleaned_columns AS (
  SELECT *,
  --searches for duplicated ride_id
  ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY ride_id) AS duplicated_rides_num,
  --cleans up outlier and standardizes station names by removing trailing asterisks
  CASE WHEN (end_station_id = '320') THEN 'Orange Ave & Addison St' ELSE 
  REGEXP_REPLACE(end_station_name, r'\*+$', '') END AS cleaned_end_station_name,
  CASE WHEN (start_station_id = '320') THEN 'Orange Ave & Addison St' ELSE 
  REGEXP_REPLACE(start_station_name, r'\*+$', '') END AS cleaned_start_station_name,
  --calculating length of each ride in minutes
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_min,
  --extracting weekday when ride started
  case when
    EXTRACT(DAYOFWEEK FROM started_at) = 1
    THEN 'Sunday'
    when
    EXTRACT(DAYOFWEEK FROM started_at) = 2
    THEN 'Monday'
    when
    EXTRACT(DAYOFWEEK FROM started_at) = 3
    THEN 'Tuesday'
    when
    EXTRACT(DAYOFWEEK FROM started_at) = 4
    THEN 'Wednesday'
    when
    EXTRACT(DAYOFWEEK FROM started_at) = 5
    THEN 'Thursday'
    when
    EXTRACT(DAYOFWEEK FROM started_at) = 6
    THEN 'Friday'
    ELSE 'Saturday'
    END AS weekDay,
  --extracting the hour of the day the ride started
  EXTRACT(HOUR FROM started_at) AS hour_started_at,
  --extracting the month the ride started
  EXTRACT(MONTH FROM started_at) AS month,
  --extracting the quarter the ride started
  EXTRACT (QUARTER FROM started_at) AS quarter,
  --calculating the distance of ride
  ROUND((ST_DISTANCE(ST_GEOGPOINT(start_lng, start_lat), ST_GEOGPOINT(end_lng, end_lat)) * 0.000621371),3) as distance_in_miles
  FROM
    `corded-aquifer-450216-k9.divvy_tripdata.combined_divvy_data`
),


-- ensures each unique `cleaned_start_station_name` maps to only one `start_station_id`
----------------------------------------------------------------------------------------------------------
-- ex: Public Rack - Delphina & Foster has multiple end_station_ids: 1180.0 and 1180
-- will pick the smallest id (1180)
---------------------------------------------------------------------------------------------------------- 
clean_start_station_id AS (
  SELECT
  cc.cleaned_start_station_name AS start_station_names,
    CASE 
    --checks if there is more than one id map to a station name
      WHEN (MIN(start_station_id), r'^\w+') != (MAX(start_station_id), r'^\w+')
    --resolves conflicts by taking the smallest id 
      THEN MIN(start_station_id)
      --default: when only one id exists
      ELSE MAX(start_station_id)
    END AS corrected_start_station_id
  FROM cleaned_columns AS cc
  --groups by station name to enforce 1:1 mapping
  GROUP BY cc.cleaned_start_station_name
),


-- same logic as clean_start_station_id
clean_end_station_id AS (
  SELECT
  cc.cleaned_end_station_name AS end_station_names,
    CASE 
      WHEN (MIN(end_station_id), r'^\w+') != (MAX(end_station_id), r'^\w+')
      THEN MIN(end_station_id)
      ELSE MAX(end_station_id)
    END AS corrected_end_station_id
  FROM cleaned_columns AS cc
  GROUP BY cc.cleaned_end_station_name
),


-- joined to preserve all original columns while adding corrected ids
corrected_columns AS (
  SELECT *
  FROM cleaned_columns cc
  LEFT JOIN clean_start_station_id AS css_id ON cc.cleaned_start_station_name = css_id.start_station_names
  LEFT JOIN clean_end_station_id AS ces_id ON cc.cleaned_end_station_name = ces_id.end_station_names
),


-- identifies cases where a single station ID maps to multiple name variations
-- stores the first name variant as first_start_station_name
-- stores the last name variant as second_start_station_name
-- two cases exists: 
--    - ids with multiple station names that have minor inconsistencies
--    - ids with multiple station names that have major inconsistencies
----------------------------------------------------------------------------------------------------------
-- ex: 1524189 id has multiple start_station_names
--      - Lowell Ave & Armitage
--      - Lowell Ave & Armitage Ave
-- will store Lowell Ave & Armitage in first_start_station_name
-- will store Lowell Ave & Armitage Ave in second_start_station_name
---------------------------------------------------------------------------------------------------------- 
assort_start_station AS (
  SELECT
    c.corrected_start_station_id AS start_station_id,
    -- Use MIN and MAX function to store each variant
    MIN(c.cleaned_start_station_name) AS first_start_station_name, 
    MAX(c.cleaned_start_station_name) AS second_start_station_name
  FROM
    corrected_columns AS c
  GROUP BY
  --groups by station id to enforce 1:1 mapping
    c.corrected_start_station_id
  ORDER BY c.corrected_start_station_id DESC
),


-- same logic as assort_start_station
assort_end_station AS (
  SELECT
    c.corrected_end_station_id AS end_station_id,
    MIN(c.cleaned_end_station_name) AS first_end_station_name,
    MAX(c.cleaned_end_station_name) AS second_end_station_name
  FROM
    corrected_columns AS c
  GROUP BY
     c.corrected_end_station_id
  ORDER BY  c.corrected_end_station_id DESC
),


 -- categorizes each row as having the first name variant or second name variant
classify_start_station_names AS (
  SELECT
    c.corrected_start_station_id AS start_station_ids,
    c.cleaned_start_station_name AS start_station_names,
    first_start_station_name AS firstnames,
    second_start_station_name AS secondnames,
    CASE
    --if end station name matches the first end station name variant 
      WHEN c.cleaned_start_station_name = ces.first_start_station_name THEN 'first_name'
    --if end station name matches the second end station name variant
      WHEN c.cleaned_start_station_name = ces.second_start_station_name THEN 'second_name'
      ELSE 'other'
    END AS name_type
  FROM
    corrected_columns c
  JOIN
    assort_start_station ces
  ON
    c.corrected_start_station_id = ces.start_station_id
),


-- same logic as classify_start_station_names
classify_end_station_names AS (
  SELECT
    c.corrected_end_station_id AS end_station_ids,
    c.cleaned_end_station_name AS end_station_names,
    first_end_station_name AS firstnames,
    second_end_station_name AS secondnames,
    CASE
      WHEN c.cleaned_end_station_name = ces.first_end_station_name THEN 'first_name'
      WHEN c.cleaned_end_station_name = ces.second_end_station_name THEN 'second_name'
      ELSE 'other'
    END AS name_type
  FROM
    corrected_columns c
  JOIN
    assort_end_station ces
  ON
    c.corrected_end_station_id = ces.end_station_id  
),


-- counts occurrences of each variant based on station id 
-- helps identify which variant is more common
get_start_station_frequency AS (
  SELECT
  cn.start_station_ids AS start_station_id,
  firstnames AS start_station_firstname,
  secondnames AS start_station_secondname,
  COUNTIF(name_type = 'first_name') AS first_name_count,
  COUNTIF(name_type = 'second_name') AS second_name_count,
FROM
  classify_start_station_names AS cn
GROUP BY
  1,2,3
ORDER BY 1
),


-- same logic as get_start_startion_frequency
get_end_station_frequency AS (
  SELECT
  cn.end_station_ids AS end_station_id,
  firstnames AS end_station_firstname,
  secondnames AS end_station_secondname,
  COUNTIF(name_type = 'first_name') AS first_name_count, 
  COUNTIF(name_type = 'second_name') AS second_name_count,
FROM
  classify_end_station_names AS cn
GROUP BY
  1,2,3
ORDER BY 1
),


-- three cases
--    - ids with only one station name
--    - ids with multiple station names that have minor inconsistencies (eg., typos)
--    - ids with multiple station names that have major inconsistencies 
----------------------------------------------------------------------------------------------------------
-- 1st case: if the row station id has only one station name, original station name unchanged
---------------------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------------------
-- 2nd case example (minor inconsistencies): 1524189 id has multiple start_station_names
--      - Lowell Ave & Armitage (172 occurrences)
--      - Lowell Ave & Armitage Ave (208 occurrences)
-- standardize to the most frequent variant
-- any station names that have Lowell Ave & Armitage will be changed to Lowell Ave & Armitage Ave
---------------------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------------------
-- 3rd case example (major inconsistencies): 514 id has multiple start_station_names
--      - Public Rack - Hamlin Ave & Grand Ave (21 occurrences)
--      - Ridge Blvd & Howard St (881 occurrences)
-- extract first word from each variant and compare if it does not match
-- compare which variant is more common 
-- if the station name matches with the variant that is most common, it is kept
--      - Ridge Blvd & Howard St is kept
-- else null
--      - station id 514 that have station name Public Rack - Hamlin Ave & Grand Ave will be turned null
---------------------------------------------------------------------------------------------------------- 
get_corrected_station_names AS (
SELECT 
cc.*,
#for start_station_id and start_station_name
CASE
-- case 1: if first name matches with second name then keep first name
when gssf.start_station_firstname = gssf.start_station_secondname THEN gssf.start_station_firstname

-- case 2: major inconsistency
-- if first name word does not match second name first word
WHEN (REGEXP_EXTRACT(gssf.start_station_firstname, r'^\w+') != 
      REGEXP_EXTRACT(gssf.start_station_secondname, r'^\w+')) 
      AND (corrected_start_station_id != 'KA1503000074') -- special exception
  -- when second name variant is greater than the first
  THEN case when gssf.first_name_count < gssf.second_name_count
              -- does the start station name matches the second name variant
              THEN case when gssf.start_station_secondname = cc.cleaned_start_station_name
                        -- kept if it does else null
                          THEN gssf.start_station_secondname ELSE NULL END
        -- when first name variant is greater than the second
        when gssf.first_name_count > gssf.second_name_count
              -- does the start station name matches the first name variant
              THEN case when gssf.start_station_firstname = cc.cleaned_start_station_name
                        -- kept if it does else null
                          THEN gssf.start_station_firstname ELSE NULL END 
        END
-- case 3: minor inconsistency
ELSE
  -- keeps the variant name that occurs most frequent
  CASE WHEN gssf.first_name_count < gssf.second_name_count
      THEN gssf.start_station_secondname
      ELSE gssf.start_station_firstname END 
END AS start_station_consistency,
-- for end_station_id and end_station_name
CASE
when gesf.end_station_firstname = gesf.end_station_secondname THEN gesf.end_station_firstname

WHEN (REGEXP_EXTRACT(gesf.end_station_firstname, r'^\w+') != 
    REGEXP_EXTRACT(gesf.end_station_secondname, r'^\w+'))
    AND (corrected_end_station_id != 'KA1503000074')
  THEN case when gesf.first_name_count < gesf.second_name_count
              THEN case when gesf.end_station_secondname = cc.cleaned_end_station_name
                          THEN gesf.end_station_secondname ELSE NULL END
        when gesf.first_name_count > gesf.second_name_count
              THEN case when gesf.end_station_firstname = cc.cleaned_end_station_name
                          THEN gesf.end_station_firstname ELSE NULL END 
        END
ELSE 
  CASE WHEN gesf.first_name_count < gesf.second_name_count
      THEN gesf.end_station_secondname
      ELSE gesf.end_station_firstname END 
END AS end_station_consistency
FROM corrected_columns AS cc
LEFT JOIN get_end_station_frequency AS gesf ON  cc.corrected_end_station_id = gesf.end_station_id
LEFT JOIN get_start_station_frequency AS gssf ON  cc.corrected_start_station_id = gssf.start_station_id
)

SELECT
ride_id, 
rideable_type,
started_at, 
ended_at,
start_station_consistency AS start_station_name, 
corrected_start_station_id AS start_station_id,
end_station_consistency AS end_station_name,
corrected_end_station_id AS end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual,
ride_length_min,
weekDay,
hour_started_at,
month,
quarter,
distance_in_miles,
-- classified as a round trip if a ride has the same start_station_name and end_station_name
 CASE when 
    start_station_consistency = end_station_consistency THEN 1
    ELSE 0
    END AS round_trip
FROM get_corrected_station_names AS gcsn
WHERE 
-- removing duplicated ride_ids and nulls
gcsn.duplicated_rides_num = 1 AND gcsn.start_station_consistency IS NOT NULL
AND gcsn.end_station_consistency IS NOT NULL AND gcsn.corrected_start_station_id IS NOT NULL
AND gcsn.corrected_end_station_id IS NOT NULL 
AND start_lat IS NOT NULL AND start_lng IS NOT NULL
AND end_lat IS NOT NULL AND end_lng IS NOT NULL 
-- ensures no negative ride_lengths
AND ride_length_min > 1 

)
