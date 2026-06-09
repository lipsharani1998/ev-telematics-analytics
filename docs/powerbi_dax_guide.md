# Power BI DAX Measures — EV Fleet Telematics

## How to Connect Power BI to PostgreSQL
1. Open Power BI Desktop → **Get Data** → **PostgreSQL database**
2. Server: `localhost`, Database: `ev_fleet_db`
3. Import tables: `vehicles`, `drivers`, `trips`, `battery_health`, `charging_sessions`, `alerts`
4. In **Model View**, set relationships:
   - `trips[vehicle_id]` → `vehicles[vehicle_id]`
   - `trips[driver_id]` → `drivers[driver_id]`
   - `battery_health[vehicle_id]` → `vehicles[vehicle_id]`
   - `charging_sessions[vehicle_id]` → `vehicles[vehicle_id]`
   - `alerts[vehicle_id]` → `vehicles[vehicle_id]`

---

## Core Measures

```dax
Total Trips =
COUNTROWS(trips)

Total Distance (km) =
SUM(trips[distance_km])

Total Energy Used (kWh) =
SUM(trips[energy_used_kwh])

Avg Efficiency (km/kWh) =
DIVIDE([Total Distance (km)], [Total Energy Used (kWh)], 0)

Avg Battery SoH % =
AVERAGE(battery_health[state_of_health])

Active Vehicles =
CALCULATE(
    COUNTROWS(vehicles),
    vehicles[status] = "active"
)
```

---

## Battery Health Measures

```dax
Vehicles Critical (<70% SoH) =
CALCULATE(
    DISTINCTCOUNT(battery_health[vehicle_id]),
    AVERAGE(battery_health[state_of_health]) < 70
)

Vehicles Warning (<80% SoH) =
CALCULATE(
    DISTINCTCOUNT(battery_health[vehicle_id]),
    AVERAGE(battery_health[state_of_health]) >= 70,
    AVERAGE(battery_health[state_of_health]) < 80
)

Avg Charge Cycles =
AVERAGE(battery_health[cycle_count])
```

---

## Charging Measures

```dax
Total Charging Cost (USD) =
SUM(charging_sessions[cost_usd])

Total Energy Charged (kWh) =
SUM(charging_sessions[energy_added_kwh])

Avg Cost per kWh =
DIVIDE([Total Charging Cost (USD)], [Total Energy Charged (kWh)], 0)

DCFC Sessions % =
DIVIDE(
    CALCULATE(COUNTROWS(charging_sessions), charging_sessions[charger_type] = "DCFC"),
    COUNTROWS(charging_sessions),
    0
) * 100
```

---

## Alert Measures

```dax
Total Alerts =
COUNTROWS(alerts)

Critical Alerts =
CALCULATE(COUNTROWS(alerts), alerts[severity] = "critical")

Alert Resolution Rate % =
DIVIDE(
    CALCULATE(COUNTROWS(alerts), alerts[resolved] = TRUE),
    [Total Alerts],
    0
) * 100
```

---

## Recommended Dashboard Pages

| Page | Visuals |
|------|---------|
| **Fleet Overview** | KPI cards (Active vehicles, Total trips, Avg SoH, Alerts), Map (vehicle locations), Bar (by manufacturer) |
| **Battery Health** | SoH trend line, Scatter (cycles vs SoH), Health status donut, Heat map by region |
| **Trip Analytics** | Distance histogram, Efficiency leaderboard, Hourly heatmap, Region comparison |
| **Charging** | Cost trend line, Charger type donut, Monthly energy bar, Duration scatter |
| **Alerts & Maintenance** | Alert heatmap (type × severity), Monthly trend, Resolution rate KPI, Unresolved table |
