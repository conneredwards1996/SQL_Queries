--UNION Practice

--QUestion 1: Union 2018 and 2019 data - add query layer for creating and reporting the count of rows

SELECT *
FROM divvybikes_2018

UNION

SELECT *
FROM divvybikes_2019

LIMIT 50000 -- remove this to get full list, runs for minutes on end
;


SELECT COUNT(*) QTY_TRIPS_2018_2019 --- answer given by Connor we couldn't do
FROM
	(SELECT TRIP_ID
		FROM PUBLIC.DIVVYBIKES_2018
		UNION ALL SELECT TRIP_ID
		FROM PUBLIC.DIVVYBIKES_2019) AS T1


-- Question 2 
---Union 2018 & 2019, for only "Customer user_type" - count number of rows stacked

SELECT *
FROM divvybikes_2018
WHERE user_type ilike 'Customer'

UNION

SELECT *
FROM divvybikes_2019
WHERE user_type ilike 'Customer'
; --answer is 1557793 rows

--Question 3
--- What is the newest and oldest data in your 2018/2019 unioned dataset? use an outer layer

SELECT min(start_time), max(start_time)
	FROM divvybikes_2018
	WHERE user_type ilike 'Customer'
	UNION
SELECT min(start_time), max(start_time)
	FROM divvybikes_2019
	WHERE user_type ilike 'Customer'
; 

 
--Join review question


--starting location -- start_station_id
--tables - b


SELECT baywheels_stations.id, baywheels_stations.name, count(baywheels_stations.id) as Rides_By_Station
FROM baywheels_2017
JOIN baywheels_stations
ON baywheels_2017.start_station_id = baywheels_stations.id
GROUP BY baywheels_stations.id
ORDER BY Rides_By_Station desc
LIMIT 10;
