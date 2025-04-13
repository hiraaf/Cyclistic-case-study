# Cyclistic-case-study

## Project Overview

Cyclistic is a bike-share company based in Chicago with:
- 5,800 bicycles
- 600 docking stations

The company has two types of users:

- Annual members (subscribers)
- Casual riders (single-ride or day-pass users)

Business Objective: The aim is to encourage casual riders to become annual members. To achieve this, we need to address the key question: **how do annual members and casual riders use Cyclistic bikes differently?**

## Data Sources

Data provided by Divvy [licensed for use](https://divvybikes.com/data-license-agreement)

12 months of data (March 2024 - February 2025)  
There are 12 monthly datasets, each with 13 columns of trip information. 

## Tools & Technologies Used

- Bigquery for SQL-based data cleaning, transformation and analysis
- Tableau for data visualization

## Data Combining

The 12 monthly datasets were combined into a single table with 5,783,100 rows.  


![Screen Shot 2025-04-12 at 6 06 52 PM](https://github.com/user-attachments/assets/85bb08c1-d2ff-4036-a3bd-90cbad82893e)

## Data Exploration

Identified several data quality issues:
- Null values in station names, IDs, and location coordinates
- Verified uniqueness of ride IDs
- Examined distinct values for bike types and user types
- Verified timestamp consistency across records
- Discovered inconsistent station naming:
  - Some station names mapped to multiple IDs
  
  ![Screen Shot 2025-04-12 at 12 38 12 PM](https://github.com/user-attachments/assets/826ae6e7-9e1f-4021-a302-ba09b4c98cae)

  - Some station IDs mapped to multiple name variations
  
  ![Screen Shot 2025-04-12 at 6 17 24 PM](https://github.com/user-attachments/assets/14c366ac-8eb8-4aa8-a971-c54d18a91fc1)

## Data Cleaning

- Removed duplicate ride IDs
- Standardized station naming:
  - Ensured each station name maps to only one ID
  - Ensured each station IDs maps to only one name
- Created new calculated fields:
  - Ride duration (minutes)
  - Ride distance (miles)
  - Temporal features (month, quarter, weekday, hour)
  - Round trip indicator
- Removed all null values
- Final cleaned dataset: 4,012,468 rows with 19 fields

## Data Analysis & Visualization

#### Casual Riders vs Member Riders:
  - Member riders account for 2.5 million (63.34%) of the total ridership.
  - Casual riders account for 1.4 million (36.66%) of the total ridership. 

#### Average ride length and distance:
Average ride distances are similar between members and casual riders, but casual riders spend nearly twice as much time per trip (23.9 min vs. 12.2 min).

Members
- Implies they ride faster and more directly to their destination.
- Likely use bikes for utilitarian purposes like commuting to work or school

Casuals
- Suggests prioritization of duration over speed
- Indicates leisure/recreation use such as sightseeing or exploration

![avg ride length (2)-2](https://github.com/user-attachments/assets/60b7e894-1a4c-4206-8ff9-8b17b76f0fd8)


![Sheet 6 (4)-2](https://github.com/user-attachments/assets/d09283f6-c14e-4344-911f-e7288e35761d)

#### Weekday, Part of the day and Hour

Weekday:
- Members exhibit work-related commuting patterns:
  - Highest usage on weekdays (Tue-Thu), suggesting regular employment schedules.
- Casual riders show leisure/recreational patterns:
  - Highest usage on weekends (Sat-Sun) and Fridays, suggesting free-time usage.

![weekday (2)](https://github.com/user-attachments/assets/e6f19b21-1a75-430d-aaa7-9cfb999efad7)

Part of the Day:

Morning: 5-11 AM
Afternoon: 12-4 PM
Evening: 5-9 PM

- Member
  - Rides peak in the afternoon
  - Evening usage remaining nearly as strong (within 30,000 rides) and morning activity following closely (within 50,000 rides).
  -  Reinforcing routine, utilitarian use such as commuting or errands.
- Casual ridership
  - Peaks in the afternoon
  - Also shows significant usage in the evening hours, indicating sightseeing and dining/nightlife-related trips

![part of day-2](https://github.com/user-attachments/assets/d54fada3-4f9d-45bf-af20-eb5e761e9d20)

Hour:
- Members:
  - Primary peak: 5 PM, with strong ridership sustained between 4-6 PM (end of work-day)
  - Secondary peak: 7-9 AM (start of work-day)
- Casuals:
  - Primary peak: 5 PM (with elevated ridership 3-6 PM)
  - Secondary peak: 12-2 PM
  - Peaks align with sightseeing, lunch breaks, or social outings.

![weekday (4)-2](https://github.com/user-attachments/assets/14c76a0a-2674-4716-9a6f-1f41309c9d20)

#### Stations frequency

Top 3 stations for members and nearby areas:
- Kingsbury St & Kinze St: Apartments, neighbhoods, the loop: a central business district, universities
- Clinton St & Washington Blvd: The loop, a central business district and Fulton River District, a neighborhood
- Clark St & Elm St: Apartments, Library, Church

Top 3 stations for casuals and nearby areas:
- Streeter Dr & Grand Ave: Pier, parks, museums, section called the Magnificient Mile that is devoted to retail, dining, and tourist attraction.
- Dusable Lakeshore Dr & Monroe St Station: Nearby area are parks, Chicago loop, and museums
- Michigan Ave & Oak St: Shopping Centers, Museums, Magnificient Mile, Neighborhood

Members primarily use stations near:
- Residential areas (apartments, neighborhoods)
-  Business districts (The Loop, universities)
-  Practical stops (library, church)
Reinfroces routine and utilitarian use such as home-to-work commuting.

Casual riders favor stations near:
- Tourist attractions & scenic areas (parks, museums, piers, shopping districts)
- Retail/dining hubs (Magnificent Mile)
Reflects leisure, sightseeing, social outings and recreational use.

## Recommendations

To convert casual riders to members:
1. Promote memberships at Tourists hotspots/Social hubs
2. Partner with Museums, Parks, Retail/Dining Hubs for ride incentives and emphasizing cost savings of memberships for frequent leisure
3. Weekend Membership trials and bundled offers with leisure activities.

