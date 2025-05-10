#checking if any errors before update
select 
employee_name,
CONCAT(
LOWER(REPLACE(employee_name, " ", ".")),"@ndogowater.gov") AS new_email
from employee;

#udate on email and phone numbers
Update employee
set email = CONCAT(LOWER(REPLACE(employee_name, " ", ".")),"@ndogowater.gov");
update employee
set phone_number = TRIM(phone_number);

#how many employee in each town 
select
town_name,
COUNT(employee_name) AS num_employees
from employee
group by town_name;

# top 3 employees with most visits
SELECT assigned_employee_id,
       COUNT(record_id) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY assigned_employee_id
LIMIT 3;

# top 3 employees info 
SELECT *
FROM employee
WHERE assigned_employee_id IN (0 , 1 , 2);

# count number of records per town:
select
town_name,
count(location_type) as records_per_town
from location
group by town_name
order by count(location_type) DESC;

# count number of records per province:
select
province_name,
count(location_type) as records_per_town
from location
group by province_name
order by count(location_type) DESC;
/*from the two tables we can see that most of water sources in the survey are suited in small rural communities
scattered accross Maji Ndogo*/

# count number of records per province and town :
/*this query shows us that the data is reliable because each town and province has many documented sources*/
select
province_name,
town_name,
count(location_type) as records_per_town
from location
group by province_name, town_name
order by province_name, count(location_type) DESC;

# count number of sources per each location type:
select
count(town_name) AS num_sources,
location_type
from location
group by location_type;
# calculating percentage to give relevant insight than raw numbers 
select 23740 / (15910 + 23740) * 100
# we can see that almost 60% of water sources are in rural communitites

# total number of people surveyed and served by different water sources
select 
sum(number_of_people_served) as total_peopel_surveyed
from water_source;

# how many rivers, wells, taps are there?
select
type_of_water_source,
count(source_id) as number_of_source
from water_source
group by type_of_water_source;

# average of people served by each water source
select
type_of_water_source,
round(avg(number_of_people_served)) as avg_people_per_source
from water_source
group by type_of_water_source;

# population served by each water source
select
type_of_water_source,
sum(number_of_people_served) as population_served
from water_source
group by type_of_water_source
ORDER BY sum(number_of_people_served) DESC;

# people served by each water source (percentages)
select
type_of_water_source,
round(sum(number_of_people_served)/ 27628140 * 100) as percentages_people_per_source
from water_source
group by type_of_water_source
ORDER BY sum(number_of_people_served) DESC;

# ranking by population served based on types of water source excluding home taps 
#as these are the best water sources avaialble in our data and we can't do anything more to improve that
select
type_of_water_source,
sum(number_of_people_served) as population_served,
rank() over ( order by sum(number_of_people_served) DESC) AS rank_by_population
from water_source
where type_of_water_source not in ('tap_in_home', 'tap_in_home_broken')
group by type_of_water_source
order by sum(number_of_people_served) DESC;

# ranking the really most used sources to fix first (which shared taps or wells should be fixed first?) 
SELECT
source_id,
type_of_water_source,
number_of_people_served,
RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source NOT IN ('tap_in_home', 'tap_in_home_broken')
GROUP BY  source_id,
type_of_water_source
ORDER By number_of_people_served DESC;

# How long did the survey take?
SELECT
MIN(time_of_record) AS first_time_of_record,
MAX(time_of_record) AS last_time_of_record,
datediff(MAX(time_of_record),MIN(time_of_record)) as time_difference
FROM visits;

# the average time people take to queue for water
SELECT
round(avg(nullif(time_in_queue, 0))) as avg_time_queue
FROM visits;

# the average time people take to queue for water on different days
SELECT
dayname(time_of_record) as days_of_week,
round(avg(nullif(time_in_queue, 0))) as avg_queue_time
FROM visits
group by dayname(time_of_record);

# the average time people take to queue for water at hours of day
SELECT
time_format(time(time_of_record),'%H:00') as hour_of_day,
round(avg(nullif(time_in_queue, 0))) as avg_queue_time
FROM visits
group by time_format(time(time_of_record),'%H:00')
ORDER BY time_format(time(time_of_record),'%H:00') DESC;

# making a pivot table on mysql that illustrate queue times for different days and different hours
SELECT
time_format(time(time_of_record),'%H:00') as hour_of_day,
ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Sunday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Sunday,   
 
 ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Monday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Monday,
 
 ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Tuesday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Tuesday,
 
 ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Wednesday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Wednesday, 

ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Thursday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Thursday,
 
 ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Friday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Friday,
 
 ROUND(AVG(CASE WHEN  dayname(time_of_record) = "Saturday"
     THEN time_in_queue
     ELSE NULL
 END ))AS Saturday    
 
FROM visits
WHERE time_in_queue <> 0 
GROUP BY time_format(time(time_of_record),'%H:00');

# Q1 answer: 
SELECT CONCAT(day(time_of_record), " ", monthname(time_of_record), " ", year(time_of_record)) FROM visits;

#  Q2 answer: not sure
SELECT name,
wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY (name) ORDER BY (year)) 
FROM global_water_access
ORDER BY name;

# Q3 answer: Lesedi Kofi, Kunto Asha (15)
SELECT *
FROM employee
WHERE assigned_employee_id IN (20 , 22);

#Q4 answer 
#It computes an average queue time for each shared tap,
# that is updated for each visit, and the results set is ordered by visit_count.
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
#Q5 answer
#‘33 Angelique Kidjo Avenue’

#Q6 answer (6 employees)
select
town_name,
COUNT(employee_name) AS num_employees
from employee
group by town_name
HAVING town_name = 'Dahabu';

#Q7 answer (2 employees)
select
town_name,
province_name,
COUNT(employee_name) AS num_employees
from employee
where town_name = 'Harare' and province_name = 'Kilimani'
group by town_name,
province_name;	

#Q8 answer (279)
select
type_of_water_source,
round(avg(number_of_people_served)) as avg_people_per_source
from water_source
where type_of_water_source = 'well'
group by type_of_water_source;

#Q9 answer (WHERE type_of_water_source LIKE "%tap%")
SELECT
type_of_water_source,
SUM(number_of_people_served) AS population_served
FROM
water_source
WHERE type_of_water_source LIKE "%tap%"
GROUP BY
type_of_water_source
ORDER BY
population_served DESC
;

#Q10 answer (Saturday: 239, Tuesday: 122, Sunday: 84)
