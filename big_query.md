# load public data to big query
Click on the + ADD DATA link then select Explore public datasets:

In the search bar, enter "london" and press Enter, then select the London Bicycle Hires tile, then View Dataset.

A new tab will open, and you will now have a new project called bigquery-public-data added to the Explorer panel:

If the new project bigquery-public-data doesn't appear to the Explorer panel, then click on + ADD DATA -> Pin a project -> Enter project name (bigquery-public-data) and Pin.

It's important to note that you are still working out of your lab project in this new tab. All you did was pull a publicly accessible project that contains datasets and tables into BigQuery for analysis


# connect to SQL instance
gcloud sql connect  qwiklabs-demo --user=root
```sql
CREATE DATABASE bike;
USE bike;
CREATE TABLE london1 (start_station_name VARCHAR(255), num INT);
USE bike;
CREATE TABLE london2 (end_station_name VARCHAR(255), num INT);
```

# import data from cloud storage
Return to the Cloud SQL console. You will now upload the start_station_name and end_station_name CSV files into your newly created london1 and london2 tables.

In your Cloud SQL instance page, click IMPORT.
In the Cloud Storage file field, click Browse, and then click the arrow opposite your bucket name, and then click start_station_data.csv. Click Select.
Select CSV as File format.
Select the bike database and type in "london1" as your table.
Click Import

# UNION
```sql
SELECT start_station_name AS top_stations, num FROM london1 WHERE num>100000
UNION
SELECT end_station_name, num FROM london2 WHERE num>100000
ORDER BY top_stations DESC;
```

