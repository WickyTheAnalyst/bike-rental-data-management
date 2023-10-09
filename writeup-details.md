# Bike Rental Data Mangement
## Project Overview
The last decade has seen enormous growth in the personal transportation startup industry, including bike and e-bike rental programs in many major cities. The goal of this project is to create a flexible and efficient relational database to store bike rental data, using datasets from Citi Bike and NOAA.

## Objective
To explore, clean, inspect datasets, create a flexible & efficient relational database with analytics-ready views connecting Citi Bike and weather datasets.

## Stages
- Stage 1: Data Cleaning, Exploring and Inspection
- Stage 2: Developing a relational database structure (RDBMS)
- Stage 3: Implementing the database in PostgreSQL
- Stage 4: Data Insertion in Database (using SQLAlchemy and Pandas)
- Stage 5: developing flexible analytics-ready views on top of the relational database
- Stage 6: Executing SQL Queries on the implelemted database

## **Stage 1 - Inspecting and Cleaning the Datasets**
[**Jupyter Notebook on Nbviewer**](https://nbviewer.org/github/WickyTheAnalyst/bike-rental-data-management/blob/e648d07974aa518260b406003c534b2c589df81e/bike-rental-v1.3-final.ipynb)
#### Data Integrity and Preparation:
- The Citi Bike dataset for the year 2016 exhibited data integrity issues, including missing 04 days altogether, missing or unknown values in various fields, and outliers in trip duration.
- To handle missing data, summary columns were created in the final database, and missing values were preserved as **"unknown"** to facilitate analysis and database usability.
- **Outliers** in trip duration were identified, potentially indicating system malfunctions or users exceeding the maximum rental limit. A **flag** was created to easily access or remove these outlier values from queries.
- The weather dataset was cleaned by *removing irrelevant columns, handling missing values, and simplifying the dataset for ease of analysis.*

#### Demographic and User Type Analysis:
- Significant data quality issues were observed in the "Birth Year" and "Gender" columns, particularly for "Customer" user types.
- The "Birth Year" variable showed anomalies, including a **minimum value** of **1900**, implying unrealistic ages. An **outlier (116 years)** was identified and removed from the dataset.
- Missing data in the "Birth Year" column was predominantly associated with **Customer** user types, with 99% of them missing this information.
- **Demographic info** (birth year and gender) appeared more meaningful for **Subscriber** user types than for **Customer** user types.
- A strategy to handle missing demographic data was proposed, *retaining missing values and categorizing them as "Unknown"* to preserve data integrity and aid future investigations.

#### Trip Duration Analysis:
- Trip duration exhibited a wide range of values, spanning several orders of magnitude, lasting thousand of hours. The distribution included unrealistically long trip durations, **likely indicating outliers.**
- Trip durations longer than **24 hours** (the maximum rental limit) were identified and flagged for further analysis or potential removal in specific queries.

#### Weather Data Preparation:
- The weather dataset was prepared by removing irrelevant columns, addressing missing data, and simplifying the dataset to focus on key weather indicators (e.g., average wind speed, precipitation, temperature, snow depth, and snow amount).
- A station table was created to store essential station information for use in analysis and joins.

#### Recommendations for Future Analysis:
- Future analysis should consider different data preparation and cleaning techniques to further enhance data quality and accuracy.
- Additional exploration of the impact of weather conditions on bike ridership and trip durations is warranted, leveraging the cleaned and prepared weather dataset.

By addressing data integrity issues, preparing the datasets, and making meaningful observations, we have laid a strong foundation for subsequent analytical investigations to derive valuable insights from the Citi Bike and weather datasets for the year 2016.

## Stage - 2 Developing a relational database structure (RDBMS)
- [**Entity Realationship Diagram**](https://github.com/WickyTheAnalyst/bike-rental-data-management/blob/main/ERD.png)
- [**SQL Script for Database Schema and Table Creation**](https://github.com/WickyTheAnalyst/bike-rental-data-management/blob/main/tables.sql)

#### Citi Bike Database Normalization

The **Citi Bike** dataset underwent a series of adjustments to achieve proper *normalization*. This process involved:

- Separating *station* and *demographic* data into their respective tables.
- Creating a new primary key column for the *demographic data*.
- Establishing appropriate relationships between these tables and the main **Citi Bike** table.

#### Station Data
The station data was relatively straightforward to normalize. It already included IDs that served as suitable primary keys. Therefore, it was simply organized into a dedicated table.

#### Demographic Data
Normalizing the *demographic data* required:

- The creation of a new primary key column to facilitate linking demographic information to the main **Citi Bike** table.
  
#### Weather Data
The *weather data* required less structural adjustment. However, it is important to note that joining on date-time fields can be risky due to potential discrepancies. To facilitate reliable joins, a *date_key* field was introduced for both the *weather* and **Citi Bike** data. This field stores each date as an integer in the format *yyyymmdd*, ensuring consistency and accuracy in the join operations.

#### Date Dimension Table
To streamline date-related queries and enhance efficiency, a central date dimension table was created. This table stores each day as both a date and an integer *date_key*. It includes the following attributes:

- Month represented as both a number (e.g., 1) and its corresponding name (e.g., *January*).
- Day of the month as both a number (e.g., 21) and its name (*Wednesday*).
- Identification of whether the day is a weekend day or a weekday.
- Financial quarter information.

## Stage - 3 Implementing the database in PostgreSQL & Data Insertion in Database 
Database was implemented inside PostgreSQL, Following tables were created using a SQL Script
- rides
- stations
- trip_demo
- demo
- weather
### **Key Activities**
**Tables Splitting**
- Separated station and demographic data into their own tables.
- Utilized existing station IDs and added new primary keys for demographics.

**Weather Data Structuring**
- Introduced a `date_key` field for both weather and Citi Bike data.
- Simplified date-time field joins.

**Central Date Dimension Table**
- Created a central table for date-related information.
- Includes date, integer date_key, month (number and name), day (number and name), weekend/weekday classification, and financial quarter.

These steps ensure data integrity and enable efficient analysis of the Citi Bike dataset.

### Data Insertion
Data insertion was performed using **SQLAlchemy and pandas** to ensure efficiency. Data was insrted within PostgreSQL by localy connecting it to JupyterNotebook
The resulting database, organized through *normalization* and designed with data integrity in mind, provides a solid foundation for Citi Bike data analysis and reporting.

## Stage 4 - Development of Views
[**SQL Script for Creating Analytical Views over the database**](https://github.com/WickyTheAnalyst/bike-rental-data-management/blob/main/views.sql)

<br>
To support the analytics team, I have crafted the following views:

### *daily_data*

This view encompasses data for each day of the year, utilizing outer joins to ensure thorough investigation of days absent from the Citi Bike dataset. It not only provides the count of rides on a given day but also includes:

- Breakdowns by date (e.g., month and day of the week)
- Ride breakdowns (e.g., using `filter` statements to analyze rides by subscriber, customer, and duration)
- Running monthly totals (leveraging `window` functions)
- Integration of weather data

Notably, this view contains information about records with an unknown `user_type` and unusually large `trip_duration`, aiding the analytics team in further exploration.

### *monthly_data*

This view summarizes the data from *daily_data* on a monthly basis. It includes:

- Total rides per month
- Breakdown of total rides by user type
- Daily ride averages segmented by user type
- Average temperature and maximum precipitation amounts (as averages were consistently close to `0`)
- Counts of rainy and snowy days

### *late_return*

While the previous views already incorporate counts of late returns (rentals exceeding 24 hours), this table offers the necessary data for in-depth investigation. It includes:

- Complete date information
- Bike ID
- Start and end station details
- User type

### *hourly_summary*, *trip_demographics*, *week_summary*

These additional views provide further insights and summaries to support the analytics endeavors.

## Stage 5 - Executing SQL Queries over Database
[**Practical Demo SQL Querying**](https://nbviewer.org/github/WickyTheAnalyst/bike-rental-data-management/blob/e648d07974aa518260b406003c534b2c589df81e/bike-rental-v1.3-final.ipynb#query)
- Jupyter Notebook was locally connected to PostgreSQL 
- Connection was established with PostgreSQL bike-data-managemnet-v1 database
- Valuable information was retrieved from Database using SQL complex queries inside Jupyter Notebook
  <br>
  
*Following SQL Querries were executed*
- Total No of Rides
- Average Trip Duration in Minutes
- Top 5 Stations with the most rides
- Total number of rides by user type
- Top 5 stations with the highest average trip duration in hours
- Total number of rides for each day of the week
- Average age of riders by gender
- Total number of rides on weekends and weekdays
- Date with the highest precipitation (rain or snow)
- Top 5 Stations by Ride Count
- Find the top 5 stations with the highest average trip duration in hours, but only consider stations with more than 100 rides
- Find the date with the highest number of rides and the average trip duration on that date
- Calculate the total number of rides for each financial quarter
- Calculate the average trip duration for each user type and gender combination
- Find the top 5 stations with the highest average trip duration in hours, but exclude stations where the average age of riders is below 30
- Calculate the total number of rides for each user type and gender, but only for users who have taken trips longer than the overall average trip duration
- Find the top 5 dates with the highest total precipitation (rain + snow) and the number of rides on those dates
- Calculate the average trip duration in hours for each month of the year, but only for trips taken by users who are 25 years old or younger
- Find the top 5 stations with the highest average trip duration in hours, considering only weekdays, and exclude stations where the average age of riders is below 30
- Find the top 5 stations with the highest average trip duration in hours, considering only weekdays, and exclude stations where the average age of riders is below 30
- Calculate the average trip duration in hours for Top 5 stations, but only for stations where the temperature (tavg) is above the 90th percentile of all stations' temperatures
