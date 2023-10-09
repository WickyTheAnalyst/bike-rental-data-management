# bike-rental-data-management

This repository contains ccode of `Bike Rental Data Management` project

## Project Overview

Project to create a relational database with analytics-ready views connecting Citi Bike and weather datasets. The project involved:
- Data Cleaning, Exploring and Inspection
- Developing a relational database structure (RDBMS)
- Implementing the database in PostgreSQL
- Data Insertion in Database (using SQLAlchemy and Pandas)
- developing flexible analytics-ready views on top of the relational database
- Executing SQL Queries on the implelemted database

# Folder Structure

- `bike-rental-v1.3-final.ipynb`: Covers data cleaning, data insertion in PostgresSQL, & Querring over it
- `tables.sql`: SQL queries to create the database tables
- `views.sql`: SQL queries to create the database views
- `ERD.png`: entity relationship diagram for the database made in Lucid
- `ERD-PostgreSQL.png`: ER Diagram generated via PgAdmin PostgreSQL

### `data`
- `newark_airport_2016.csv`: weather data from Newark airport
- `JC-2016xx-citibike-tripdata.csv`: twelve files each containing one month of Citi Bike data from Jersey City
    - replace `xx` with the number of each month

### `data-dictionaries`
- `citibike.pdf`: details on the Citi Bike data files from Citi Bike's website
- `weather.pdf`: details on the weather data from NOAA's website

