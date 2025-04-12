-- how many members vs casuals in total
SELECT
  member_casual,
  COUNT(member_casual)
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual;

-- members vs casuals avg ride length in minutes and average distance in miles
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member_casual,
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual;

-- members vs casuals on what weekday they rode most and the avg ride length and distance
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member_casual,
  weekDay
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual, weekDay
ORDER BY member_casual;

-- member vs casual on what month they rode most and the avg ride length and distance
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member_casual,
  month
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual, month
ORDER BY member_casual, month;

-- member vs casual on what quarter they rode most and the avg ride length and distance
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member_casual,
  quarter
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual, quarter
ORDER BY member_casual, quarter;


-- top 20 start stations frequented by riders with the ride length and distance overall
SELECT
  start_station_name,
  COUNT(start_station_name) AS count_station_name,
  ROUND(AVG(ride_length_min),4) AS average_ride_length,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;


-- top 20 start stations frequented by casual riders with the ride length and distance 
SELECT
  start_station_name,
  COUNT(start_station_name) AS count_station_name,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_casual
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE member_casual = 'casual'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;

-- top 20 end stations frequented by casual riders with the ride length and distance 
SELECT
  end_station_name,
  COUNT(end_station_name) AS count_station_name,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_casual,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_casual
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE member_casual = 'casual'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;


-- top 20 start stations frequented by members with the ride length and distance 
SELECT
  start_station_name,
  COUNT(start_station_name) AS count_station_name,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE member_casual = 'member'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;

-- top 20 end stations frequented by members with the ride length and distance 
SELECT
  end_station_name,
  COUNT(end_station_name) AS count_station_name,
  ROUND(AVG(ride_length_min),4) AS average_ride_length_member,
  ROUND(AVG(distance_in_miles),4) AS average_distance_in_miles_member
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE member_casual = 'member'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;


-- who had more round trip between casual and members
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE round_trip = 1
GROUP BY 1;


--what part of the day member vs casual started rides
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  hour_started_at,
  case 
    WHEN hour_started_at >= 5 AND hour_started_at <= 11
    THEN 'morning'
    WHEN hour_started_at >= 12 AND hour_started_at <= 16
    THEN 'afternoon'
    WHEN hour_started_at >= 17 AND hour_started_at <= 21
    THEN 'evening'
    ELSE 'night'
    END AS part_of_day
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY 1,3
ORDER BY 1, 2 DESC;

-- what part of the day on the week of the day members started ride 
SELECT
  member_casual,
  COUNT(member_casual) AS count_member_casual,
  hour_started_at,
  case 
    WHEN hour_started_at >= 5 AND hour_started_at <= 11
    THEN 'morning'
    WHEN hour_started_at >= 12 AND hour_started_at <= 16
    THEN 'afternoon'
    WHEN hour_started_at >= 17 AND hour_started_at <= 21
    THEN 'evening'
    ELSE 'night'
    END AS part_of_day,
    weekDay
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
WHERE member_casual = 'member'
GROUP BY 1,3,5
ORDER BY 1, 2 DESC;

--what bike is used more between casual and member riders
SELECT
  member_casual,
  COUNT(member_casual),
  rideable_type
FROM `corded-aquifer-450216-k9.divvy_tripdata.cleaned_divvy_data` 
GROUP BY member_casual, rideable_type;
