-- ============================================================
-- EV Fleet Telematics & Battery Analytics — PostgreSQL Schema
-- ============================================================

CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id           SERIAL PRIMARY KEY,
    vin                  VARCHAR(17) UNIQUE NOT NULL,
    model                VARCHAR(50),
    manufacturer         VARCHAR(50),
    year                 INT,
    battery_capacity_kwh NUMERIC(6,2),
    max_range_km         INT,
    fleet_region         VARCHAR(50),
    status               VARCHAR(20) DEFAULT 'active',
    registered_at        DATE
);

CREATE TABLE IF NOT EXISTS drivers (
    driver_id      SERIAL PRIMARY KEY,
    full_name      VARCHAR(100),
    license_number VARCHAR(30) UNIQUE,
    region         VARCHAR(50),
    joined_at      DATE
);

CREATE TABLE IF NOT EXISTS trips (
    trip_id         SERIAL PRIMARY KEY,
    vehicle_id      INT REFERENCES vehicles(vehicle_id),
    driver_id       INT REFERENCES drivers(driver_id),
    start_time      TIMESTAMP,
    end_time        TIMESTAMP,
    distance_km     NUMERIC(8,2),
    energy_used_kwh NUMERIC(7,3),
    avg_speed_kmh   NUMERIC(6,2),
    start_soc       NUMERIC(5,2),
    end_soc         NUMERIC(5,2),
    start_lat       NUMERIC(10,6),
    start_lon       NUMERIC(10,6),
    end_lat         NUMERIC(10,6),
    end_lon         NUMERIC(10,6),
    region          VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS battery_health (
    record_id       SERIAL PRIMARY KEY,
    vehicle_id      INT REFERENCES vehicles(vehicle_id),
    recorded_at     TIMESTAMP,
    state_of_health NUMERIC(5,2),
    state_of_charge NUMERIC(5,2),
    temperature_c   NUMERIC(5,2),
    voltage_v       NUMERIC(6,3),
    cycle_count     INT,
    charging_mode   VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS charging_sessions (
    session_id       SERIAL PRIMARY KEY,
    vehicle_id       INT REFERENCES vehicles(vehicle_id),
    driver_id        INT REFERENCES drivers(driver_id),
    start_time       TIMESTAMP,
    end_time         TIMESTAMP,
    energy_added_kwh NUMERIC(7,3),
    start_soc        NUMERIC(5,2),
    end_soc          NUMERIC(5,2),
    charger_type     VARCHAR(20),
    location         VARCHAR(100),
    cost_usd         NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS alerts (
    alert_id    SERIAL PRIMARY KEY,
    vehicle_id  INT REFERENCES vehicles(vehicle_id),
    alert_time  TIMESTAMP,
    alert_type  VARCHAR(50),
    severity    VARCHAR(20),
    message     TEXT,
    resolved    BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_trips_vehicle    ON trips(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_trips_start      ON trips(start_time);
CREATE INDEX IF NOT EXISTS idx_battery_vehicle  ON battery_health(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_battery_recorded ON battery_health(recorded_at);
CREATE INDEX IF NOT EXISTS idx_alerts_vehicle   ON alerts(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_alerts_time      ON alerts(alert_time);
