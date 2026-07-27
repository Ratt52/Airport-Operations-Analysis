/*===============================================================
 Airport Operations Data Analysis - Advanced SQL
 Author   : Pranit Rathor
 Database : airport_db
 Table    : airports
===============================================================*/

USE airport_db;



/* Q13: Rank the Busiest Routes

Objective:
Rank flight routes based on total passenger traffic.
This helps identify the busiest travel routes across the network.
*/

WITH route_summary AS
(
    SELECT
        origin_city,
        destination_city,
        SUM(passengers) AS total_passengers,
        SUM(flights) AS total_flights
    FROM airports
    GROUP BY
        origin_city,
        destination_city
)

SELECT
    origin_city,
    destination_city,
    total_passengers,
    total_flights,

    RANK() OVER(
        ORDER BY total_passengers DESC
    ) AS route_rank

FROM route_summary
ORDER BY route_rank
LIMIT 10;



/* Q14: Most Active Airport in Each City

Objective:
Identify the busiest airport within each origin city based on
total passenger traffic.
*/

WITH airport_summary AS
(
    SELECT
        origin_city,
        origin_airport,
        SUM(passengers) AS total_passengers,
        SUM(flights) AS total_flights
    FROM airports
    GROUP BY
        origin_city,
        origin_airport
),

airport_rank AS
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY origin_city
            ORDER BY total_passengers DESC
        ) AS airport_rank
    FROM airport_summary
)

SELECT
    origin_city,
    origin_airport,
    total_passengers,
    total_flights
FROM airport_rank
WHERE airport_rank = 1
ORDER BY total_passengers DESC;



/* Q15: Airport Connectivity Ranking

Objective:
Rank airports based on the number of unique destination airports served.
*/

WITH connectivity AS
(
    SELECT
        origin_airport,
        origin_city,
        COUNT(DISTINCT destination_airport) AS connected_airports
    FROM airports
    GROUP BY
        origin_airport,
        origin_city
)

SELECT
    origin_airport,
    origin_city,
    connected_airports,

    DENSE_RANK() OVER(
        ORDER BY connected_airports DESC
    ) AS connectivity_rank

FROM connectivity
ORDER BY connectivity_rank;



/* Q16: Running Total of Passengers

Objective:
Calculate the cumulative passenger traffic over the years.
This helps analyze long-term passenger growth.
*/

WITH yearly_passengers AS
(
    SELECT
        YEAR(fly_date) AS year,
        SUM(passengers) AS total_passengers
    FROM airports
    GROUP BY YEAR(fly_date)
)

SELECT
    year,
    total_passengers,

    SUM(total_passengers)
    OVER(
        ORDER BY year
    ) AS cumulative_passengers

FROM yearly_passengers
ORDER BY year;



/* Q17: Three-Year Moving Average of Passenger Traffic

Objective:
Calculate the three-year moving average of passenger traffic.
This helps identify long-term travel demand trends while smoothing
year-to-year fluctuations.
*/

WITH yearly_passengers AS
(
    SELECT
        YEAR(fly_date) AS year,
        SUM(passengers) AS total_passengers
    FROM airports
    GROUP BY YEAR(fly_date)
)

SELECT
    year,
    total_passengers,

    ROUND(
        AVG(total_passengers)
        OVER(
            ORDER BY year
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_average_passengers

FROM yearly_passengers
ORDER BY year;



/* Q18: Compare Current Year with Next Year

Objective:
Compare yearly passenger traffic with the following year to
analyze future demand trends.
*/

WITH yearly_passengers AS
(
    SELECT
        YEAR(fly_date) AS year,
        SUM(passengers) AS total_passengers
    FROM airports
    GROUP BY YEAR(fly_date)
)

SELECT
    year,
    total_passengers,

    LEAD(total_passengers)
    OVER(
        ORDER BY year
    ) AS next_year_passengers,

    LEAD(total_passengers)
    OVER(
        ORDER BY year
    ) - total_passengers AS passenger_difference

FROM yearly_passengers
ORDER BY year;



/* Q19: Compare First and Last Year Passenger Traffic

Objective:
Display the passenger traffic of the first and last available years
for comparison using window functions.
*/

WITH yearly_passengers AS
(
    SELECT
        YEAR(fly_date) AS year,
        SUM(passengers) AS total_passengers
    FROM airports
    GROUP BY YEAR(fly_date)
)

SELECT
    year,
    total_passengers,

    FIRST_VALUE(total_passengers)
    OVER(
        ORDER BY year
    ) AS first_year_passengers,

    LAST_VALUE(total_passengers)
    OVER(
        ORDER BY year
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS last_year_passengers

FROM yearly_passengers
ORDER BY year;



/* Q20: Top Three Airports in Each City

Objective:
Identify the top three airports in every origin city based on
passenger traffic.
*/

WITH airport_summary AS
(
    SELECT
        origin_city,
        origin_airport,
        SUM(passengers) AS total_passengers,
        SUM(flights) AS total_flights
    FROM airports
    GROUP BY
        origin_city,
        origin_airport
),

airport_rank AS
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY origin_city
            ORDER BY total_passengers DESC
        ) AS airport_rank
    FROM airport_summary
)

SELECT
    origin_city,
    origin_airport,
    total_passengers,
    total_flights,
    airport_rank
FROM airport_rank
WHERE airport_rank <= 3
ORDER BY
    origin_city,
    airport_rank;