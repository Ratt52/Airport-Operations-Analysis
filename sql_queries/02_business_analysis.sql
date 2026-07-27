/*===============================================================
 Airport Operations Data Analysis
 Author   : Pranit Rathor
 Database : airport_db
 Table    : airports
===============================================================*/

USE airport_db;

/* Q1: Travel Insights

Objective:
Identify the busiest source-destination routes based on passenger traffic.
This helps understand travel demand and supports airline route planning.
*/

SELECT
    origin_city,
    destination_city,
    SUM(passengers) AS total_passengers,
    SUM(flights) AS total_flights
FROM airports
GROUP BY origin_city, destination_city
ORDER BY total_passengers DESC
LIMIT 10;



/* Q2: Seat Occupancy Analysis

Objective:
Identify routes with the highest and lowest overall seat occupancy.
This helps optimize aircraft capacity and improve operational efficiency.
*/

-- Highest Seat Occupancy

SELECT
    origin_city,
    destination_city,
    ROUND(
        SUM(passengers) * 100.0 / NULLIF(SUM(seats), 0),
        2
    ) AS seat_occupancy_percentage
FROM airports
GROUP BY origin_city, destination_city
ORDER BY seat_occupancy_percentage DESC
LIMIT 10;


-- Lowest Seat Occupancy

SELECT
    origin_city,
    destination_city,
    ROUND(
        SUM(passengers) * 100.0 / NULLIF(SUM(seats), 0),
        2
    ) AS seat_occupancy_percentage
FROM airports
GROUP BY origin_city, destination_city
ORDER BY seat_occupancy_percentage ASC
LIMIT 10;



/* Q3: Average Passengers per Flight

Objective:
Identify routes with the highest average number of passengers per flight.
This helps evaluate route efficiency and demand.
*/

SELECT
    origin_city,
    destination_city,
    ROUND(SUM(passengers) / NULLIF(SUM(flights),0),2) AS avg_passengers_per_flight,
    SUM(flights) AS total_flights
FROM airports
GROUP BY origin_city, destination_city
ORDER BY avg_passengers_per_flight DESC
LIMIT 10;



/* Q4: Activity Level at Origin Cities

Objective:
Analyze airport activity by measuring the number of airports,
total flights, and passenger traffic from each origin city.
This helps identify major operational hubs.
*/

SELECT
    origin_city,
    COUNT(DISTINCT origin_airport) AS total_airports,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY origin_city
ORDER BY total_passengers DESC
LIMIT 10;



/* Q5: Longest Flight Routes

Objective:
Identify routes with the highest average travel distance.
This helps understand long-haul routes and supports network planning.
*/

SELECT
    origin_airport,
    destination_airport,
    origin_city,
    destination_city,
    ROUND(AVG(distance),2) AS average_distance,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY
    origin_airport,
    destination_airport,
    origin_city,
    destination_city
ORDER BY average_distance DESC
LIMIT 10;



/* Q6: Seasonal Trends Analysis

Objective:
Analyze monthly and yearly flight operations to identify seasonal
travel demand and support operational planning.
*/

SELECT
    YEAR(fly_date) AS year,
    MONTH(fly_date) AS month_number,
    MONTHNAME(fly_date) AS month,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY
    YEAR(fly_date),
    MONTH(fly_date),
    MONTHNAME(fly_date)
ORDER BY
    YEAR(fly_date),
    MONTH(fly_date);



/* Q7: Underutilized Routes

Objective:
Identify routes with low overall seat occupancy.
These routes can be reviewed for schedule optimization or capacity reduction.
*/

SELECT
    origin_city,
    destination_city,
    ROUND(
        SUM(passengers) * 100.0 /
        NULLIF(SUM(seats),0),
        2
    ) AS seat_occupancy_percentage,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY origin_city, destination_city
HAVING seat_occupancy_percentage < 50
ORDER BY seat_occupancy_percentage ASC
LIMIT 10;



/* Q8: Most Active Airports

Objective:
Identify airports handling the highest number of flights and passengers.
This helps recognize major operational hubs.
*/

SELECT
    origin_airport,
    origin_city,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY origin_airport, origin_city
ORDER BY total_flights DESC, total_passengers DESC
LIMIT 10;



/* Q9: Airport Connectivity Analysis

Objective:
Identify airports with the highest network connectivity based on
the number of unique destination airports they serve.
This helps identify major hub airports.
*/

SELECT
    origin_airport,
    origin_city,
    COUNT(DISTINCT destination_airport) AS connected_airports,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY
    origin_airport,
    origin_city
ORDER BY connected_airports DESC,
         total_passengers DESC
LIMIT 10;



/* Q10: Manhattan Distance Between Airports

Objective:
Calculate the Manhattan distance between origin and destination airports
using latitude and longitude. This provides an approximate travel distance
for analytical comparison.
*/

SELECT
    origin_airport,
    destination_airport,
    origin_city,
    destination_city,
    ROUND(
        AVG(
            ABS(org_airport_lat - CAST(dest_airport_lat AS DECIMAL(10,6))) +
            ABS(org_airport_long - CAST(dest_airport_long AS DECIMAL(10,6)))
        ),
        2
    ) AS manhattan_distance,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports
GROUP BY
    origin_airport,
    destination_airport,
    origin_city,
    destination_city
ORDER BY manhattan_distance DESC
LIMIT 10;



/* Q11: Seasonal Demand Classification

Objective:
Classify monthly passenger demand into High, Medium, and Low categories
using a CASE statement. This helps identify peak and off-peak travel seasons
for better operational planning.
*/

SELECT
    YEAR(fly_date) AS year,
    MONTH(fly_date) AS month_number,
    MONTHNAME(fly_date) AS month,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers,

    CASE
        WHEN SUM(passengers) >= 40000000 THEN 'High Demand'
        WHEN SUM(passengers) >= 32000000 THEN 'Medium Demand'
        ELSE 'Low Demand'
    END AS demand_category

FROM airports

GROUP BY
    YEAR(fly_date),
    MONTH(fly_date),
    MONTHNAME(fly_date)

ORDER BY
    YEAR(fly_date),
    MONTH(fly_date);

    

/* Q12: Passenger Growth Analysis

Objective:
Analyze year-over-year passenger traffic and calculate the annual
growth percentage. This helps evaluate long-term travel demand trends.
*/

WITH yearly_passengers AS
(
    SELECT
        YEAR(fly_date) AS year,
        SUM(passengers) AS total_passengers
    FROM airports
    GROUP BY YEAR(fly_date)
),

passenger_growth AS
(
    SELECT
        year,
        total_passengers,
        LAG(total_passengers)
        OVER(ORDER BY year) AS previous_year_passengers
    FROM yearly_passengers
)

SELECT
    year,
    total_passengers,
    previous_year_passengers,

    ROUND(
        (total_passengers - previous_year_passengers)
        *100.0/
        NULLIF(previous_year_passengers,0),
        2
    ) AS growth_percentage

FROM passenger_growth
ORDER BY year;