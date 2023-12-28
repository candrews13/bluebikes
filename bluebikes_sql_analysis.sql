-- Stations Table EDA

-- counting the number of stations,
-- checking number and id columns against each other
select count(number) number_count, count(id) id_count
from bluebikes_stations;
-- number column counts 339, id column counts 336
select id
from bluebikes_stations
where id is null;
/* 3 nulls returned for id, accounting for the disparity between
	 the number count and the id count */

-- looking for other nulls
select *
from bluebikes_stations
where number is null
	  or name is null
	  or district is null
	  or total_docks is null
	  or latitude is null
	  or longtitude is null;
-- no rows returned which indicates no null values found

-- analyzing the 3 null station ids
select *
from bluebikes_stations
where id IS NULL;
/* 1 is in Cambridge, 2 are in Watertown
 2 of the 3 Watertown stations don't have an ID number
*/


-- checking for duplicate station numbers and names
select number, count(number)
from bluebikes_stations
group by number
having count(number) > 1;

select id, count(id)
from bluebikes_stations
group by id
having count(id) > 1;

select name, count(name)
from bluebikes_stations
group by name
having count(name) > 1;
-- no rows returned, indicating no duplicates


-- pulling station names and location data for mapping
SELECT id, name, latitude, longitude, district
FROM bluebikes_stations
ORDER BY id;


-- counting the number of bike docks
select sum(total_docks)
from bluebikes_stations;
--- 6004 docks

-- do any stations have 0 docks?
select number, name, total_docks
from bluebikes_stations
where total_docks = 0;
-- no stations are recorded as having 0 docks

-- finding min, max, average docks per station
select min(total_docks), max(total_docks), round(avg(total_docks))
from bluebikes_stations;
-- Min: 10, Max: 47, Avg: 18

select 
	case
		when total_docks <= 22 then '10-22'
		when total_docks between 23 and 35 then '23-35'
		else '35-47'
	end as num_docks,
	count(id) num_stations
from bluebikes_stations
group by 1
order by 1;
--  295/336 stations have 10-22 bike docks, 3 have 35-47 bike docks

-- counting number of stations by District
select district, count(id)
from bluebikes_stations
group by 1;




-- Trip Tables EDA
-- checking for nulls
select *
from bluebikes_2019
where bike_id is null
	or start_time is null
	or end_time is null
	or start_station_id is null
	or end_station_id is null
	or user_type is null
	or user_birth_year is null
	or user_gender is null
limit 100;
-- no rows returned

select *
from bluebikes_2018
where bike_id is null
	or start_time is null
	or end_time is null
	or start_station_id is null
	or end_station_id is null
	or user_type is null
	or user_birth_year is null
	or user_gender is null
limit 100;
-- 100 rows returned, user_birth_year nulls
select count(bike_id)
from bluebikes_2018
where user_birth_year is null;
-- 9592 rows with null user_birth_year

select *
from bluebikes_2017
where bike_id is null
	or start_time is null
	or end_time is null
	or start_station_id is null
	or end_station_id is null
	or user_type is null
	or user_birth_year is null
	or user_gender is null
limit 100;
-- 100 rows returned
select count(bike_id)
from bluebikes_2017
where user_birth_year is null;
-- 21,0947 rows have null user_birth_year

select *
from bluebikes_2016
where bike_id is null
	or start_time is null
	or end_time is null
	or start_station_id is null
	or end_station_id is null
	or user_type is null
--	or user_birth_year is null
	or user_gender is null
limit 100;
-- no rows returned
/* there are a multitude of nulls for user's birth year in the trip data
 for all years except 2019. will focus user demographics on 2019 trip data.
*/


-- looking for duplicate trip entries
select bike_id, start_time, count(*)
from bluebikes_2019
group by 1, 2
having count(*) > 1;

select bike_id, start_time, count(*)
from bluebikes_2018
group by 1, 2
having count(*) > 1;

select bike_id, start_time, count(*)
from bluebikes_2017
group by 1, 2
having count(*) > 1;

select bike_id, start_time, count(*)
from bluebikes_2016
group by 1, 2
having count(*) > 1;
-- no rows returned; indicates no duplicate entries of trips


--- checking for nulls and outliers for user birth year
select user_birth_year
from bluebikes_2019
order by 1 desc
limit 10;
-- 2003 most recent year indicates youngest user would be 16 in 2019
select user_birth_year, 2019 - user_birth_year::numeric age
from bluebikes_2019
where (2019 - user_birth_year::numeric) > 100
order by 1;
-- 773 rows where user's age is over 100
select user_birth_year, count(user_birth_year) number_of_rides
from bluebikes_2019
where user_birth_year::numeric < 1919
group by user_birth_year;
/*  335 entries have 1900 as user_birth_year - these could be default/fillers.
	1886, 1888, 1889 have 3, 47, 85 entries - these could be typos
	replacing the 2nd digit that should be '9' with an '8' (i.e. 1888 vs 1988),
	or other data entry errors (fake birth years).
*/
select user_birth_year, 2019 - user_birth_year::numeric age
from bluebikes_2019
where (2019 - user_birth_year::numeric) >= 80 and (2019 - user_birth_year::numeric) <= 90
order by 1;
-- 185 rows where user's age is 80-90



-- how many rides were taken by each gender in 2019?
-- select user_gender, count(user_gender)
-- from bluebikes_2019
-- group by user_gender;
select 
	case when user_gender = 0 then 'unknown'
		 when user_gender = 1 then 'male'
		 when user_gender = 2 then 'female'
	end as gender,
	count(user_gender) num_of_rides
from bluebikes_2019
where (2019 - user_birth_year::numeric) < 80   -- filtering out outlier & innacurate ages
group by gender;


-- are there any Members/Subscribers who's self-reported gender is 'unknown'?
-- counting the # of users with 'unknown' gender by user type
select user_type, count(user_gender) num_of_rides
from bluebikes_2019
where user_gender = 0
group by 1;


-- looking to see if non-subscribers report gender
select user_gender, count(user_gender) num_of_users
from bluebikes_2019
where user_type ilike 'customer'
group by user_gender;
-- 276k report f/m gender, 257k report as 'unknown' 
-- so about a 50/50 split between unknown and f/m selected



-- checking station ids in the trips table against ids in the stations table
select start_station_id
from bluebikes_2019
except
select id
from bluebikes_stations
order by start_station_id
-- 11 station ids with trip starts that are not in the stations table
select start_station_id
from bluebikes_2018
except
select id
from bluebikes_stations
order by start_station_id
-- 51 station ids that are not in the stations table

select end_station_id
from bluebikes_2019
except
select id
from bluebikes_stations
order by end_station_id
-- 12 station ids for end id that are not in the stations table

select distinct(start_station_id), bs.name
from bluebikes_2019 b19
left join bluebikes_stations bs
	on b19.start_station_id = bs.id
order by 2 desc
limit 15;

select date_part('month', start_time) month_num,
		start_station_id,
		count(bike_id) num_of_rides
from bluebikes_2019
where start_station_id in (select start_station_id
						from bluebikes_2019
						except
						select id
						from bluebikes_stations)
group by 1, 2
limit 100;
-- trips happening throughout the year from these null name stations

select count(distinct start_station_id)
from bluebikes_2019
-- 338 station ids


-- Further Analysis

-- How have user demographics changed over the years?
-- looking at gender demographics for 2017-2019
select date_part('year',start_time) as year,
	case when user_gender = 0 then 'unknown'
		 when user_gender = 1 then 'male'
		 when user_gender = 2 then 'female'
	end as gender,
	count(user_gender) num_of_users
from bluebikes_2019
where (2019 - user_birth_year::integer) < 80   -- filtering out outliers & innacurate ages
group by year, gender

union 

select date_part('year',start_time) as year,
	case when user_gender = 0 then 'unknown'
		 when user_gender = 1 then 'male'
		 when user_gender = 2 then 'female'
	end as gender,
	count(user_gender) num_of_users
from bluebikes_2018
where (2018 - user_birth_year::numeric) < 80   
group by year, gender

union 

select date_part('year',start_time) as year,
	case when user_gender = 0 then 'unknown'
		 when user_gender = 1 then 'male'
		 when user_gender = 2 then 'female'
	end as gender,
	count(user_gender) num_of_users
from bluebikes_2017
where (2017 - user_birth_year::numeric) < 80   
group by year, gender;


-- How are user_types segmented by gender?
select user_type,
		case when user_gender = 0 then 'U'
		 	when user_gender = 1 then 'M'
		 	when user_gender = 2 then 'F'
		end as gender,
		count (*)
from bluebikes_2019
where (2019 - user_birth_year::numeric) < 80 
group by 1, 2;


-- what are the number of rides each year by user type and gender?
with multi_year as(
		select * 
		from bluebikes_2019
		where (2019 - user_birth_year::numeric) < 80
		union
		select * 
		from bluebikes_2018
		where (2018 - user_birth_year::numeric) < 80
		union
		select * 
		from bluebikes_2017
		where (2017 - user_birth_year::numeric) < 80
)
select date_part('year',start_time) as year,
		user_type,
		case when user_gender = 0 then 'unknown'
			 when user_gender = 1 then 'male'
			 when user_gender = 2 then 'female'
		end as gender,
		count(user_gender) num_of_rides
from multi_year
group by 1,2,3;



-- How are riders segmented by age?
create temp table user_ages as (
select 	2019 - user_birth_year::numeric as age,
		bike_id,
		start_time,
		end_time,
		start_station_id,
		end_station_id,
		user_type,
		user_gender
from bluebikes_2019
where (2019 - user_birth_year::numeric) < 80);
--drop table user_ages;

select case when age < 20 then '16-19'
			when age >= 20 and age < 30 then '20-29'
			when age >= 30 and age < 40 then '30-39'
			when age >= 40 and age < 50 then '40-49'
			when age >= 50 and age < 60 then '50-49'
			when age >= 60 and age < 70 then '60-49'
			when age >= 70 and age < 80 then '70-79'
			end as age_group,
		count (*) num_of_rides
from user_ages
group by 1
order by 1;

-- How are riders segmented by age?
-- including segmenting by user_type
select case when age < 20 then '16-19'
			when age >= 20 and age < 30 then '20-29'
			when age >= 30 and age < 40 then '30-39'
			when age >= 40 and age < 50 then '40-49'
			when age >= 50 and age < 60 then '50-59'
			when age >= 60 and age < 70 then '60-49'
			when age >= 70 and age < 80 then '70-79'
			end as age_group,
		user_type,
		count (*) num_of_rides
from user_ages
group by 1, 2
order by 1;

-- -- Are riders of a younger age group more likely to be casual users?
select user_type,
		case when age < 25 then '< 25'
		when age < 40 then '25-35'
		else '> 35' 
		end as age_group,
		count(bike_id) as number_of_rides
from user_ages
group by 2,1
limit 100;

-- look at subscribers & customers by District 
-- count of trips per district and user type based on starting location
-- 2019
select bs.district, b19.user_type, count(b19.start_station_id) num_of_rides
from bluebikes_2019 b19
	join bluebikes_stations bs
	on b19.start_station_id = bs.id
where (2019 - user_birth_year::numeric) < 80  
group by district, user_type;

-- 2018
select bs.district, b18.user_type, count(b18.start_station_id) num_of_rides
from bluebikes_2018 b18
	join bluebikes_stations bs
	on b18.start_station_id = bs.id
where (2018 - user_birth_year::numeric) < 80  
group by district, user_type;
	
with multi_year_district as(
		select * 
		from bluebikes_2019 b19
		join bluebikes_stations bs
		on b19.start_station_id = bs.id
		where (2019 - user_birth_year::numeric) < 80
		union
		select * 
		from bluebikes_2018 b18
		join bluebikes_stations bs
		on b18.start_station_id = bs.id
		where (2018 - user_birth_year::numeric) < 80
)
select date_part('year', start_time) as year,
		district, user_type, 
		count(start_station_id) num_of_rides
from multi_year_district
group by 1, 2, 3;

-- What are the differences between user types and ages across each District?
select district, user_type,
		case when age < 20 then '16-19'
			when age >= 20 and age < 30 then '20-29'
			when age >= 30 and age < 40 then '30-39'
			when age >= 40 and age < 50 then '40-49'
			when age >= 50 and age < 60 then '50-49'
			when age >= 60 and age < 70 then '60-49'
			when age >= 70 and age < 80 then '70-79'
			end as age_group,
		count (*) num_of_rides
from user_ages ua
join bluebikes_stations bs on ua.start_station_id = bs.id
group by district, age_group, user_type
order by 1;




-- what are the most popular start stations for customer and subscribers?
-- customers
select start_station_id, name, district,
	count(start_station_id) number_of_rides
from bluebikes_2019 b19
	join bluebikes_stations bs
	on b19.start_station_id = bs.id
where (2019 - user_birth_year::numeric) < 80
	and user_type like 'Customer'
group by start_station_id, district, name
order by 4 desc
limit 25;

-- subscribers
select start_station_id, name, district,
	count(start_station_id) number_of_rides
from bluebikes_2019 b19
	join bluebikes_stations bs
	on b19.start_station_id = bs.id
where (2019 - user_birth_year::numeric) < 80
	and user_type like 'Subscriber'
group by start_station_id, district, name
order by 4 desc
limit 25;

-- re-writing the above 2 queries using RANK()
	-- select start_station_id, user_type
	-- 	, count(start_station_id) number_of_rides
	-- 	, rank() over(partition by user_type order by count(start_station_id) desc) top_stations
	-- from user_ages
	-- group by start_station_id, user_type;

with start_station_ranks as (
		select start_station_id, user_type
			, count(start_station_id) number_of_rides
			, rank() over(partition by user_type 
						  order by count(start_station_id) desc) station_rank
		from user_ages
		group by start_station_id, user_type
)
select user_type, station_rank, start_station_id, number_of_rides
from start_station_ranks
where station_rank <= 20;


-- grabbing station location data from the above most popular stations
with start_station_ranks as (
		select start_station_id, user_type
			, count(start_station_id) number_of_rides
			, rank() over(partition by user_type 
						  order by count(start_station_id) desc) station_rank
		from user_ages
		group by start_station_id, user_type
)
select user_type, station_rank, number_of_rides, start_station_id
		, name, latitude, longitude, district
from start_station_ranks ssr
join bluebikes_stations bs
	on ssr.start_station_id = bs.id
where station_rank <= 20;



-------------- Time-scale Analysis
create temp table rides_2018_19 as(
		select * 
		from bluebikes_2018
		where (2018 - user_birth_year::numeric) < 80
		union
		select * 
		from bluebikes_2019
		where (2019 - user_birth_year::numeric) < 80
)
-- drop table rides_2018_19;

-- Looking at subscribers vs customers monthly
select date_part('year', start_time) as trip_year,
		date_part('month', start_time) month_num, 
		to_char(start_time, 'Mon') month_text,
		user_type,
		count(start_station_id) total_rides
from rides_2018_19
group by trip_year, month_num, user_type, month_text
;
-- keeping timestamp dates
select date_trunc('year', start_time) as trip_year,
		date_trunc('month', start_time) month_num, 
		user_type,
		count(start_station_id) total_rides
from rides_2018_19
group by trip_year, month_num, user_type
limit 20;


-- counting rides by day of the week (1 = Sunday), separate by user type
select 	to_char(start_time, 'YYYY') as trip_year,
		to_char(start_time, 'd') day_of_week, 
		user_type, 
		count(bike_id) total_rides
from rides_2018_19
group by 1,2,3;

select to_char(start_time, 'YYYY') as trip_year,
		to_char(start_time, 'd') day_of_week, 
		count(case when user_type like 'Customer' then 1 else null end) as customer_count,
		count(case when user_type like 'Subscriber' then 1 else null end) as subscriber_count,
		count(start_time) as total_rides
from rides_2018_19
group by trip_year, day_of_week
order by day_of_week, trip_year;



-- Looking at subscribers vs customers quarterly
select 	to_char(start_time, 'YYYY') as trip_year,
		to_char(start_time, 'Q') as quarter, 
	--	to_char(start_time, 'Mon') month_text,
		user_type,
		count(start_station_id) total_rides
from rides_2018_19
group by trip_year, quarter, user_type;

-- by season
select case when start_time between '2018-12-21' and '2019-03-19' then 'Winter'
			when start_time between '2019-03-19' and '2019-06-22' then 'Spring'
			when start_time between '2019-06-22' and '2019-09-23' then 'Summer'
			when start_time between '2019-09-23' and '2019-12-21' then 'Fall'
		end as season,
		user_type,
		count(start_station_id) total_rides
from rides_2018_19
where start_time between '2018-12-21' and '2019-12-21'
group by season, user_type
limit 100;


-- adding in district location
with trip_district as (
		select * 
		from bluebikes_2019 b19
		join bluebikes_stations bs
		on b19.start_station_id = bs.id
		where (2019 - user_birth_year::numeric) < 80
	)
select date_part('month', start_time) month_num, 
		to_char(start_time, 'Mon') month_text,
		district,
		user_type,
		count(start_station_id) num_of_rides
from trip_district
group by month_num, month_text, district, user_type
order by 1, 3;
-- addinng in window function column to sum rides per month by district
with trip_district as(
		select * 
		from bluebikes_2019 b19
		join bluebikes_stations bs
		on b19.start_station_id = bs.id
		where (2019 - user_birth_year::numeric) < 80
)
select 
  date_part('month', start_time) month_num, 
	to_char(start_time, 'Mon') month_text,
	district,
	user_type,
	count(start_station_id) num_of_rides,
  sum(count(start_station_id)) over (partition by date_part('month', start_time),district) total_rides_in_district
from trip_district
group by month_num, month_text, district, user_type
order by 1, 3;



-- average ride times
select user_type, avg(end_time-start_time) avg_trip_time
from rides_2018_19
group by user_type;
-- subscriber average ride is 15 min, customer average ride is 1h 6min

select min(end_time-start_time) min_trip_length
		, max(end_time-start_time) max_trip_length
from rides_2018_19
where date_trunc('day', start_time) = date_trunc('day', end_time)
group by user_type
;


--- hour by hour useage for each day o the week
select date_part('isodow', start_time) day_of_week,
		date_part('hour', start_time) hour_of_day, 
		user_type, 
		count(bike_id) total_rides
from rides_2018_19
group by 1,2,3;