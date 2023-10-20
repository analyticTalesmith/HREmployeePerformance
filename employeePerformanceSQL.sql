--The region ID CAST from string is clunky, so including Region ID as column
--ALTER TABLE 
--	HRPerformance.dbo.EmployeeData
--ADD
--	region_ID int

--UPDATE
--	HRPerformance.dbo.EmployeeData
--SET
--	region_ID = CAST(SUBSTRING(region,CHARINDEX('_',region)+1,LEN(region)-CHARINDEX('_',region)+2) AS int)


--Also need to convert data for past performance
--ALTER TABLE 
--	HRPerformance.dbo.EmployeeData
--ADD
--	past_performance int
	
--UPDATE
--	HRPerformance.dbo.EmployeeData
--SET
--	past_performance =
--		(CASE
--			WHEN previous_year_rating <> '' THEN CAST(previous_year_rating AS int)
--			ELSE NULL
--		END)

--ALTER TABLE
--	HRPerformance.dbo.EmployeeData
--DROP COLUMN previous_year_rating


--General insights into organizational composition
SELECT
	department,
	COUNT(department) AS DptCount
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY department
	ORDER BY department

SELECT
	gender,
	COUNT(gender) AS GenderCount
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY gender

SELECT
	education,
	COUNT(education) AS EdCount
	FROM HRPerformance.dbo.EmployeeData
	WHERE education <> ''
	GROUP BY education

SELECT
	region,
	COUNT(region) AS RegionCount
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY region

--High resolution breakdown of org structure
SELECT
	region_id,
	department,
	gender,
	COUNT(gender) AS TotalEmployees
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY region_id, department, gender
	ORDER BY region_id, department, gender

--Does past performance correlate with whether employees meet KPI goals?
SELECT
	past_performance,
	COUNT(employee_id) AS total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY past_performance
	ORDER BY past_performance

-- TRAINING EFFICACY
--Does number of trainings correlate with performance and KPI goals?
SELECT
	no_of_trainings,
	COUNT(employee_id) AS total_employees,
	round(avg(CAST(past_performance AS float)), 2) AS avg_performance,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY no_of_trainings
	ORDER BY no_of_trainings

--Verifying that no 6-training employees met KPIs
SELECT
	employee_id,
	past_performance,
	no_of_trainings,
	KPIs_met
	FROM HRPerformance.dbo.EmployeeData
	WHERE no_of_trainings = 6

--Further exploring these "super-trainees"
SELECT
	no_of_trainings,
	past_performance,
	KPIs_met,
	length_of_service,
	department,
	region_ID
	FROM HRPerformance.dbo.EmployeeData
	WHERE no_of_trainings >= 5
	ORDER BY no_of_trainings DESC, department, region_ID

--Summarize "super-trainee" query
SELECT
	region_ID,
	department,
	COUNT(employee_id) AS total_trainees
	FROM HRPerformance.dbo.EmployeeData
	WHERE no_of_trainings >= 5
	GROUP BY department, region_ID
	ORDER BY region_ID, department, COUNT(employee_id) DESC


--Average training score related to Perf. or KPI goals?
WITH training_data AS (
	SELECT
		employee_id,
		(CASE	WHEN avg_training_score < 40 THEN '[0,40)'
				WHEN avg_training_score < 50 THEN '[40,50)'
				WHEN avg_training_score <60 THEN '[50,60)'
				WHEN avg_training_score <70 THEN '[60,70)'
				WHEN avg_training_score <80 THEN '[70,80)'
				WHEN avg_training_score <90 THEN '[80,90)'
				WHEN avg_training_score <=100 THEN '[90,100]'
				ELSE 'EXCEPTION: Invalid score'
		END) AS training_performance,
		KPIs_met,
		past_performance,
		no_of_trainings
		FROM HRPerformance.dbo.EmployeeData
		WHERE past_performance IS NOT NULL
	)
SELECT
	training_performance,
	COUNT(training_performance) AS n,
	round(avg(CAST(no_of_trainings AS float)), 2) AS avg_no_training,
	round(avg(CAST(past_performance AS float)), 2) AS avg_performance,
	round(CAST(sum(KPIs_met) AS float)/COUNT(employee_id), 4)*100 AS percent_KPIs_met
	FROM training_data
	GROUP BY training_performance
	ORDER BY training_performance

-- Performance Insights
-- What percentage of employees within each region as meeting KPI goals?
SELECT
	region_ID,
	ROUND(AVG(CAST(past_performance AS float)),2) AS avg_performance,
	COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS met_goal_COUNT,
	COUNT(employee_ID) AS total_employees_COUNT,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY region_ID
	ORDER BY percent_met_goal DESC

--Region	
SELECT
	department,
	COUNT(employee_id) AS total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY department
	ORDER BY percent_met_goal DESC
	-- Sales and marketing appear to be underperforming considerably

-- Demographic exploration
--Gender
SELECT
	gender,
	COUNT(employee_id) as total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY gender
	ORDER BY gender
	-- No diff in gender

--Age		
SELECT
	age,
	COUNT(employee_id) as total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY age
	ORDER BY percent_met_goal DESC
	-- Doesn't appear to be much of a story here, thankfully

--Region
SELECT
	region_ID,
	COUNT(employee_id) as total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY region_ID
	ORDER BY percent_met_goal DESC

--Education
SELECT
	education,
	COUNT(employee_id) as total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY education
	ORDER BY percent_met_goal DESC

--Recruitment
SELECT
	recruitment_channel,
	COUNT(employee_id) as total_employees,
	ROUND(CAST(COUNT(CASE WHEN KPIs_met = 1 THEN 1 END) AS float)/COUNT(employee_ID), 2) AS percent_met_goal
	FROM HRPerformance.dbo.EmployeeData
	GROUP BY recruitment_channel
	ORDER BY percent_met_goal DESC
	-- Referrals performing considerably better
