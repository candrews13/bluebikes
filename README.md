# Bostom Bluebikes Customer Conversion Analysis Project
Bluebikes data analysis project for customer conversion

This project utilized a combination of SQL and Tableau to analyze and visualize trip data from 2018 and 2019.
The PostgreSQL code is provided here in this github repository.

Background:

Bluebikes is a public bike share program in Metro Boston, MA which launched in 2011. The system’s most recent expansion was into Everett in 2019.
Subscribers can pay for monthly or annual memberships with unlimited 45-minute trips. 
Customers can either purchase single 30-minute trips, or an Adventure (Day) Pass for unlimited 2-hour trips.

Business Case Scenario:

Management for Bluebikes wants recommendations on increasing the number of subscribing riders, as they consider it a more stable operating revenue source.

Data:

This analysis uses data from a SQL database provided by General Assembly. 
The datasets included four years (2016-2019) of trip data and some data on docking stations.

Assumptions:

•	Users age 80 or older were excluded from analysis as being outside the target population

Limitations:

•	No clear separation between tourists and other local casual users

•	Some casual users (customers) may not provide accurate personal information

Data Dictionary

Stations table
| **Column Name** | **Data Type** | **Description**                                                   |
|-----------------|---------------|-------------------------------------------------------------------|
| Number          | varchar       |     Station identifying alphanumeric code                         |
| Name            | varchar       | Name of the station                                               |
| Latitude        | numeric       | Station location information                                      |
| Longitude       | numeric       | Station location information                                      |
| District        | text          |     Municipality: Boston, Cambridge, Everett, Somerville, etc.    |
| Public          | text          | yes = 339, no other entries                                       |
| Total_docks     | integer       | Number of bike docks at the station                               |
| Id              | integer       | Station id number                                                 |

Trip Tables (one per year)
| **Column Name**  | **Data Type** | **Description**                                                                        |
|------------------|---------------|----------------------------------------------------------------------------------------|
| Bike id          | integer       |     Station identifying alphanumeric code                                              |
| Start time       | timestamp     | Logged start time of a rider’s trip                                                    |
| End time         | timestamp     | Logged end time of a rider’s trip                                                      |
| Start_station_id | integer       | ID of the station the trip started at                                                  |
| End_station_id   | integer       | ID of the station the trip ended at                                                    |
| User_type        | text          | Customer = Single Trip or Adventure (day) Pass;  Subscriber = Annual or Monthly Member |
| User_birth_year  | text          | User’s given year of birth                                                             |
| User_gender      | integer       | User’s self-reported gender Zero=unknown; 1=male; 2=female                             |

