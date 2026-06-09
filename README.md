# EV Fleet Telematics & Battery Analytics

A data analytics project I built to analyze EV fleet performance — tracking battery health, trip efficiency, charging patterns, and maintenance alerts.

**Tools used:** Python, PostgreSQL, Power BI

---

## What this project does

I worked with data from 50 electric vehicles across 5 regions. The goal was to understand how batteries degrade over time, which vehicles are most efficient, and where maintenance issues are happening most.

The data was generated using Python (Faker library) and loaded into PostgreSQL. Analysis was done in Jupyter notebooks, and the final dashboards were built in Power BI.

---

## Database tables

- `vehicles` — vehicle details, manufacturer, region, battery capacity
- `drivers` — driver info and region
- `trips` — 5,000 trip records with distance, speed, energy used
- `battery_health` — 8,000 readings tracking state of health over time
- `charging_sessions` — 2,000 charging events with cost and charger type
- `alerts` — 600 maintenance and fault alerts

---

## Folder structure

```
data/           raw CSV files and data generation scripts
sql/            schema and analysis queries
notebooks/      EDA notebook
docs/           Power BI setup and DAX measures
assets/         dashboard screenshots
```

---

## How to run it

1. Install dependencies
```
pip install -r requirements.txt
```

2. Create the database
```
psql -U postgres -c "CREATE DATABASE ev_fleet_db;"
psql -U postgres -d ev_fleet_db -f sql/schema.sql
```

3. Generate and load data
```
python data/generate_data.py
python data/load_to_postgres.py
```

4. Open the notebook
```
jupyter notebook notebooks/ev_fleet_eda.ipynb
```

---

## Dashboard previews

### Fleet Overview
![Fleet Overview](assets/dashboard_fleet_overview.png)

### Battery Health
![Battery Health](assets/dashboard_battery_health.png)

### Charging & Alerts
![Charging and Alerts](assets/dashboard_charging_alerts.png)

---

## Key findings

- Battery health drops noticeably after 150+ charge cycles
- DCFC (fast charging) sessions show slightly lower average SoH compared to Level 2
- North and East regions have higher alert frequency — mostly maintenance-related
- Trip efficiency varies significantly by manufacturer, Tesla and BYD leading in km/kWh
