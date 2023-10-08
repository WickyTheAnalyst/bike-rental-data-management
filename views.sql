-- Create a view for daily ride counts
CREATE VIEW daily_counts AS
SELECT date_dim.date_key,
    date_dim.full_date,
    date_dim.month_name,
    date_dim.day,
    date_dim.day_name,
    date_dim.weekend,
    count(rides.id) AS ride_totals,                                 -- Total rides for the day
    count(trip_demo.user_type) FILTER (WHERE trip_demo.user_type = 'Subscriber') AS subscriber_rides,  -- Subscriber rides
    count(trip_demo.user_type) FILTER (WHERE trip_demo.user_type = 'Customer') AS customer_rides,      -- Customer rides
    count(trip_demo.user_type) FILTER (WHERE trip_demo.user_type = 'Unknown') AS unknown_rides,        -- Unknown user rides
    count(rides.valid_duration) FILTER (WHERE NOT rides.valid_duration) AS late_return               -- Late returns
FROM rides
RIGHT JOIN date_dim ON rides.date_key = date_dim.date_key
LEFT JOIN trip_demo ON rides.trip_demo = trip_demo.id
GROUP BY date_dim.date_key
ORDER BY date_dim.date_key;

-- Create a view for daily data with additional information
CREATE VIEW daily_data AS
SELECT daily_counts.date_key,
    daily_counts.full_date,
    daily_counts.month_name,
    daily_counts.day,
    daily_counts.day_name,
    daily_counts.ride_totals,
    sum(daily_counts.ride_totals) OVER (PARTITION BY daily_counts.month_name ORDER BY daily_counts.date_key) AS month_running_total,
    daily_counts.subscriber_rides,
    daily_counts.customer_rides,
    daily_counts.unknown_rides,
    daily_counts.late_return,
    daily_counts.weekend,
    weather.tmin,
    weather.tavg,
    weather.tmax,
    weather.avg_wind,
    weather.prcp,
    weather.snow_amt,
    weather.rain,
    weather.snow
FROM daily_counts
JOIN weather ON daily_counts.date_key = weather.date_key
ORDER BY daily_counts.date_key;

-- Create a view for monthly data with aggregated statistics
CREATE VIEW monthly_data AS
SELECT date_dim.month,
    date_dim.month_name,
    ROUND(AVG(daily.ride_totals)) AS avg_daily_rides,         -- Average daily rides
    SUM(daily.ride_totals) AS total_rides,                    -- Total rides for the month
    ROUND(AVG(daily.customer_rides)) AS avg_customer_rides,   -- Average customer rides
    SUM(daily.customer_rides) AS total_customer_rides,        -- Total customer rides
    ROUND(AVG(daily.subscriber_rides)) AS avg_subscriber_rides, -- Average subscriber rides
    SUM(daily.subscriber_rides) AS total_subscriber_rides,    -- Total subscriber rides
    SUM(daily.unknown_rides) AS total_unknown_rides,          -- Total unknown user rides
    SUM(daily.late_return) AS total_late_returns,             -- Total late returns
    ROUND(AVG(daily.tavg)) AS avg_tavg,                       -- Average temperature
    COUNT(daily.snow) FILTER (WHERE daily.snow) AS days_with_snow, -- Days with snow
    COUNT(daily.rain) FILTER (WHERE daily.rain) AS days_with_rain, -- Days with rain
    MAX(daily.snow_amt) AS max_snow_amt,                      -- Maximum snow amount
    MAX(daily.prcp) AS max_prcp                               -- Maximum precipitation
FROM date_dim
JOIN daily_data daily ON date_dim.date_key = daily.date_key
GROUP BY date_dim.month, date_dim.month_name
ORDER BY date_dim.month;

-- Create a view for late return analysis
CREATE VIEW late_return AS
SELECT date_dim.full_date,
   rides.id,
   rides.trip_hours,
   rides.bike_id,
   (SELECT stations.station_name
      FROM stations
     WHERE rides.start_station_id = stations.id) AS start_location,  -- Start station name
   (SELECT stations.station_name
      FROM stations
     WHERE rides.end_station_id = stations.id) AS end_location,      -- End station name
   trip_demo.user_type
FROM rides
JOIN date_dim ON rides.date_key = date_dim.date_key
JOIN trip_demo ON rides.trip_demo = trip_demo.id
WHERE rides.valid_duration = FALSE;

-- Create a view for weekly summary
CREATE VIEW week_summary AS
SELECT daily.day_name,
    ROUND(AVG(daily.ride_totals)) AS avg_rides,                     -- Average rides per day
    ROUND(AVG(daily.customer_rides)) AS avg_customer_rides,         -- Average customer rides per day
    ROUND(AVG(daily.subscriber_rides)) AS avg_subscriber_rides     -- Average subscriber rides per day
FROM daily_counts daily
GROUP BY daily.day_name
ORDER BY (ROUND(AVG(daily.ride_totals))) DESC;

-- Create a view for hourly summary
CREATE VIEW hourly_summary AS
SELECT EXTRACT(hour FROM rides.start_time) AS start_hour,            -- Start hour of the ride
    COUNT(*) AS ride_totals                                         -- Total rides for that hour
FROM rides
GROUP BY (EXTRACT(hour FROM rides.start_time))
ORDER BY (COUNT(*)) DESC;

-- Create a view for trip demographics summary
CREATE VIEW trip_demographics AS
SELECT COUNT(rides.id) AS total_rides,                               -- Total rides
   trip_demo.age,                                                    -- Age of the user
   trip_demo.gender,                                                 -- Gender of the user
   trip_demo.user_type                                               -- User type (e.g., Subscriber, Customer)
FROM rides
JOIN trip_demo ON rides.trip_demo = trip_demo.id
GROUP BY trip_demo.age, trip_demo.gender, trip_demo.user_type
ORDER BY trip_demo.user_type, trip_demo.gender, trip_demo.age;
