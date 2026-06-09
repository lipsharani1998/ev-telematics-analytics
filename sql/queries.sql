-- ============================================================
-- EV Fleet Analytics — Key SQL Queries for Power BI
-- ============================================================

-- 1. Daily Trip Summary (Power BI time-series)
SELECT
    DATE(t.start_time)       AS trip_date,
    v.fleet_region,
    v.manufacturer,
    COUNT(t.trip_id)         AS trip_count,
    SUM(t.distance_km)       AS total_distance_km,
    SUM(t.energy_used_kwh)   AS total_energy_kwh,
    AVG(t.avg_speed_kmh)     AS avg_speed_kmh,
    AVG(t.distance_km / NULLIF(t.energy_used_kwh,0)) AS avg_km_per_kwh
FROM trips t
JOIN vehicles v ON v.vehicle_id = t.vehicle_id
GROUP BY DATE(t.start_time), v.fleet_region, v.manufacturer
ORDER BY trip_date;

-- 2. Battery Degradation per Vehicle
SELECT
    v.vin, v.manufacturer, v.model, v.fleet_region,
    DATE_TRUNC('month', bh.recorded_at)  AS month,
    AVG(bh.state_of_health)              AS avg_soh,
    MAX(bh.cycle_count)                  AS max_cycles,
    AVG(bh.temperature_c)                AS avg_temp_c,
    CASE
        WHEN AVG(bh.state_of_health) < 70 THEN 'Critical'
        WHEN AVG(bh.state_of_health) < 80 THEN 'Warning'
        WHEN AVG(bh.state_of_health) < 90 THEN 'Good'
        ELSE 'Excellent'
    END AS health_label
FROM battery_health bh
JOIN vehicles v ON v.vehicle_id = bh.vehicle_id
GROUP BY v.vin, v.manufacturer, v.model, v.fleet_region,
         DATE_TRUNC('month', bh.recorded_at)
ORDER BY v.vin, month;

-- 3. Fleet Efficiency Leaderboard
SELECT
    v.vin, v.manufacturer, v.model, v.fleet_region,
    COUNT(t.trip_id)                              AS total_trips,
    SUM(t.distance_km)                            AS total_km,
    SUM(t.energy_used_kwh)                        AS total_kwh,
    ROUND(SUM(t.distance_km)/NULLIF(SUM(t.energy_used_kwh),0),2) AS km_per_kwh,
    AVG(t.avg_speed_kmh)                          AS avg_speed
FROM trips t
JOIN vehicles v ON v.vehicle_id = t.vehicle_id
GROUP BY v.vin, v.manufacturer, v.model, v.fleet_region
ORDER BY km_per_kwh DESC;

-- 4. Charging Cost Summary (monthly)
SELECT
    DATE_TRUNC('month', cs.start_time)  AS month,
    cs.charger_type,
    COUNT(*)                             AS sessions,
    SUM(cs.energy_added_kwh)            AS total_energy_kwh,
    SUM(cs.cost_usd)                    AS total_cost_usd,
    AVG(cs.end_soc - cs.start_soc)      AS avg_soc_gain,
    AVG(EXTRACT(EPOCH FROM (cs.end_time - cs.start_time))/60) AS avg_duration_min
FROM charging_sessions cs
GROUP BY DATE_TRUNC('month', cs.start_time), cs.charger_type
ORDER BY month, cs.charger_type;

-- 5. Alert Resolution KPIs
SELECT
    alert_type,
    severity,
    COUNT(*)                        AS total_alerts,
    SUM(CASE WHEN resolved THEN 1 ELSE 0 END) AS resolved_count,
    ROUND(100.0*SUM(CASE WHEN resolved THEN 1 ELSE 0 END)/COUNT(*),1) AS resolution_rate_pct,
    ROUND(AVG(EXTRACT(EPOCH FROM (resolved_at - alert_time))/3600),2) AS avg_resolution_hrs
FROM alerts
GROUP BY alert_type, severity
ORDER BY severity, total_alerts DESC;

-- 6. Driver Performance Scorecard
SELECT
    d.full_name, d.region,
    COUNT(t.trip_id)                             AS trips,
    SUM(t.distance_km)                           AS total_km,
    ROUND(AVG(t.avg_speed_kmh),1)                AS avg_speed,
    ROUND(SUM(t.distance_km)/NULLIF(SUM(t.energy_used_kwh),0),2) AS km_per_kwh,
    ROUND(AVG(t.start_soc - t.end_soc),1)        AS avg_soc_consumed
FROM trips t
JOIN drivers d ON d.driver_id = t.driver_id
GROUP BY d.full_name, d.region
ORDER BY km_per_kwh DESC;
