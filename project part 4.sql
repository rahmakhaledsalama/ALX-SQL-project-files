# This table assembles data from different tables into one to simplify analysis
CREATE VIEW combined_analysis_table AS(
SELECT 
l.province_name,
l.town_name,
w.type_of_water_source,
l.location_type,
w.number_of_people_served,
v.time_in_queue,
we.results
from
visits AS v
LEFT JOIN
well_pollution AS we
ON
we.source_id = v.source_id
INNER JOIN
location AS l
ON
v.location_id = l.location_id
INNER JOIN
water_source AS w
ON
v.source_id = w.source_id
WHERE 
v.visit_count = 1);

WITH province_totals AS ( 	-- This CTE calculates the population of each province
SELECT 
province_name,
SUM(number_of_people_served) AS Total_served_per_province
FROM
combined_analysis_table AS ct
GROUP BY province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND(SUM(CASE WHEN type_of_water_source = 'river' 
           THEN number_of_people_served ELSE 0 END ) * 100 / pt.total_served_per_province ) AS river,
ROUND(SUM(CASE WHEN type_of_water_source = 'shared_tap'
          THEN number_of_people_served ELSE 0 END) * 100 / pt.total_served_per_province) AS shared_taps,  
ROUND(SUM(CASE WHEN type_of_water_source = 'tap_in_home'
          THEN number_of_people_served ELSE 0 END) * 100 / pt.total_served_per_province ) AS tap_in_home,
ROUND(SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
          THEN number_of_people_served ELSE 0 END) * 100 / pt.total_served_per_province ) AS tap_in_home_broken,
ROUND(SUM(CASE WHEN type_of_water_source = 'well'
          THEN number_of_people_served ELSE 0 END) * 100 / pt.total_served_per_province  ) AS well       
FROM combined_analysis_table AS ct
JOIN
province_totals AS pt
ON
pt.province_name = ct.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;
          
  CREATE TEMPORARY TABLE town_aggregated_water_access -- create a temporary table 
WITH town_totals AS ( 	-- This CTE calculates the population of each town
SELECT 
province_name,
town_name,
SUM(number_of_people_served) AS Total_served_per_province
FROM
combined_analysis_table AS ct
GROUP BY province_name, town_name
)
SELECT
ct.province_name,
ct.town_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND(SUM(CASE WHEN type_of_water_source = 'river' 
           THEN number_of_people_served ELSE 0 END ) * 100 / tt.total_served_per_province ) AS river,
ROUND(SUM(CASE WHEN type_of_water_source = 'shared_tap'
          THEN number_of_people_served ELSE 0 END) * 100 / tt.total_served_per_province) AS shared_taps,  
ROUND(SUM(CASE WHEN type_of_water_source = 'tap_in_home'
          THEN number_of_people_served ELSE 0 END) * 100 / tt.total_served_per_province ) AS tap_in_home,
ROUND(SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
          THEN number_of_people_served ELSE 0 END) * 100 / tt.total_served_per_province ) AS tap_in_home_broken,
ROUND(SUM(CASE WHEN type_of_water_source = 'well'
          THEN number_of_people_served ELSE 0 END) * 100 / tt.total_served_per_province  ) AS well       
FROM combined_analysis_table AS ct
JOIN  -- Since the town names are not unique, we have to join on a composite key
town_totals AS tt
ON
tt.province_name = ct.province_name AND tt.town_name = ct.town_name
GROUP BY -- We group by province first, then by town.
 ct.province_name, ct.town_name
ORDER BY ct.town_name;
                  
          
          