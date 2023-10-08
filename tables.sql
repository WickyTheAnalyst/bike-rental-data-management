-- Create a table to store date-related information
CREATE TABLE date_dim (
    date_key integer PRIMARY KEY,     -- Primary key for date dimension
    full_date date,                   -- Full date in 'YYYY-MM-DD' format
    month integer,                    -- Month as a number (1-12)
    day integer,                      -- Day of the month (1-31)
    month_name varchar(20),           -- Month name (e.g., 'January')
    day_name varchar(20),             -- Day name (e.g., 'Monday')
    financial_qtr integer,            -- Financial quarter
    weekend boolean                   -- Flag to indicate if it's a weekend day (TRUE/FALSE)
);

-- Create a table to store station information
CREATE TABLE stations (
    id integer PRIMARY KEY,           -- Primary key for stations
    station_name varchar(50),         -- Name of the station
    latitude real,                    -- Latitude coordinate
    longitude real                    -- Longitude coordinate
);

-- Create a table to store trip demographic information
CREATE TABLE trip_demo (
    id integer PRIMARY KEY,           -- Primary key for trip demographics
    user_type varchar(50),            -- User type (e.g., 'Subscriber', 'Customer')
    gender integer,                   -- Gender (e.g., 1 for male, 2 for female)
    birth_year integer,               -- Birth year of the user
    age integer                       -- Age of the user
);

-- Create a table to store weather information
CREATE TABLE weather (
    id serial PRIMARY KEY,            -- Primary key for weather records (auto-increment)
    rec_date date,                    -- Recorded date
    avg_wind real,                    -- Average wind speed
    prcp real,                        -- Precipitation
    snow_amt real,                    -- Snowfall amount
    snow_depth real,                  -- Snow depth
    tavg integer,                     -- Average temperature
    tmax integer,                     -- Maximum temperature
    tmin integer,                     -- Minimum temperature
    date_key integer,                 -- Foreign key to date dimension
    rain boolean,                     -- Flag to indicate rain (TRUE/FALSE)
    snow boolean,                     -- Flag to indicate snow (TRUE/FALSE)
    FOREIGN KEY(date_key) REFERENCES date_dim(date_key)  -- Relationship to date dimension
);

-- Create a table to store ride information
CREATE TABLE rides (
    id integer PRIMARY KEY,           -- Primary key for ride records
    date_key integer,                 -- Foreign key to date dimension
    trip_duration integer,            -- Trip duration in seconds
    trip_minutes real,                -- Trip duration in minutes (decimal)
    trip_hours real,                  -- Trip duration in hours (decimal)
    start_time timestamp,             -- Start time of the trip
    stop_time timestamp,              -- Stop time of the trip
    start_station_id integer,         -- Start station ID (foreign key)
    end_station_id integer,           -- End station ID (foreign key)
    bike_id integer,                  -- Bike ID
    valid_duration boolean,           -- Flag to indicate valid duration (TRUE/FALSE)
    trip_demo integer,                -- Foreign key to trip demographics
    FOREIGN KEY(date_key) REFERENCES date_dim(date_key),         -- Relationship to date dimension
    FOREIGN KEY(start_station_id) REFERENCES stations(id),       -- Relationship to start station
    FOREIGN KEY(end_station_id) REFERENCES stations(id),         -- Relationship to end station
    FOREIGN KEY(trip_demo) REFERENCES trip_demo(id)              -- Relationship to trip demographics
);
