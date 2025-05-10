# Project Part3
# Creating a new table to import csv 
DROP TABLE IF EXISTS Auditor_report;
CREATE TABLE Auditor_report (
location_id VARCHAR(32),
type_of_water_source VARCHAR(64),
true_water_source_score INT DEFAULT NULL,
statements VARCHAR(255)
);

# comparing auditor_report to water_quality by joining both tables through visits table
SELECT
au.location_id,
w.record_id ,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id;

#comparing auditor_score to employee_old_score to see the accuracy of new data is 94% and there is 102 rows still wrong
SELECT
au.location_id,
w.record_id ,
v.visit_count,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id
WHERE 
true_water_source_score != subjective_quality_score
AND v.visit_count = 1;

# linking 102 rows with employees table to see where the mistake came from
SELECT
au.location_id,
w.record_id ,
e.employee_name,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id
JOIN 
employee as e
ON e.assigned_employee_id = v.assigned_employee_id
WHERE 
true_water_source_score != subjective_quality_score
AND v.visit_count = 1
;

# saving this result table as CTE to use it later
WITH Incorrect_records AS (
SELECT
au.location_id,
w.record_id ,
e.employee_name,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id
JOIN 
employee as e
ON e.assigned_employee_id = v.assigned_employee_id
WHERE 
true_water_source_score != subjective_quality_score
AND v.visit_count = 1
)
SELECT * FROM Incorrect_records ;

# how many mistakes each employee made?
WITH Incorrect_records AS (
SELECT
au.location_id,
w.record_id ,
e.employee_name,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id
JOIN 
employee as e
ON e.assigned_employee_id = v.assigned_employee_id
WHERE 
true_water_source_score != subjective_quality_score
AND v.visit_count = 1
)
SELECT DISTINCT 
employee_name,
COUNT(employee_name)  AS Number_of_mistakes
FROM Incorrect_records 
group by employee_name;

# creating a view table incorrect_records to use it as table to make our query readible
WITH Incorrect_records AS (
SELECT
au.location_id,
w.record_id ,
e.employee_name,
true_water_source_score AS auditor_score,
subjective_quality_score AS employee_score,
au.statements
FROM
auditor_report AS au
JOIN
visits AS v
ON
au.location_id = v.location_id
JOIN
water_quality As w
ON 
v.record_id = w.record_id
JOIN 
employee as e
ON e.assigned_employee_id = v.assigned_employee_id
WHERE 
true_water_source_score != subjective_quality_score
AND v.visit_count = 1
),
error_count AS (
SELECT DISTINCT 
employee_name,
COUNT(employee_name)  AS Number_of_mistakes
FROM Incorrect_records
group by employee_name 
)
# the average error count to use it as a subquery
/* SELECT
AVG(Number_of_mistakes) AS avg_error_count_per_empl
FROM error_count; */

# create suspect_list to compare each eamployee with the avg_errors
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT
                            AVG(Number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count);

-- this CTE counts the number of mistakes each employee made
WITH error_count AS (
SELECT DISTINCT 
employee_name,
COUNT(employee_name)  AS Number_of_mistakes
FROM Incorrect_records
group by employee_name 
),
# the average error count to use it as a subquery
/* SELECT
AVG(Number_of_mistakes) AS avg_error_count_per_empl
FROM error_count; */

# create suspect_list to compare each eamployee with the avg_errors
suspect_list AS ( -- making suspect_list CTE of the four employees above average errors
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT
                            AVG(Number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count)
)
-- this query filters all records where the corrupt employees gathered data
SELECT employee_name,
 location_id,
 statements 
 FROM incorrect_records
WHERE employee_name IN  (SELECT employee_name FROM suspect_list)
AND statements LIKE "%cash%";