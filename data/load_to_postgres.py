"""
EV Fleet Telematics — PostgreSQL Loader
Run AFTER: python generate_data.py  AND  psql -f sql/schema.sql
"""
import psycopg2, csv
from psycopg2.extras import execute_batch

DB_CONFIG = {"host":"localhost","port":5432,"dbname":"ev_fleet_db",
             "user":"postgres","password":"your_password"}

INSERT = {
    "vehicles": "INSERT INTO vehicles (vehicle_id,vin,model,manufacturer,year,battery_capacity_kwh,max_range_km,fleet_region,status,registered_at) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
    "drivers": "INSERT INTO drivers (driver_id,full_name,license_number,region,joined_at) VALUES (%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
    "trips": "INSERT INTO trips (trip_id,vehicle_id,driver_id,start_time,end_time,distance_km,energy_used_kwh,avg_speed_kmh,start_soc,end_soc,start_lat,start_lon,end_lat,end_lon,region) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
    "battery_health": "INSERT INTO battery_health (record_id,vehicle_id,recorded_at,state_of_health,state_of_charge,temperature_c,voltage_v,cycle_count,charging_mode) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
    "charging_sessions": "INSERT INTO charging_sessions (session_id,vehicle_id,driver_id,start_time,end_time,energy_added_kwh,start_soc,end_soc,charger_type,location,cost_usd) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
    "alerts": "INSERT INTO alerts (alert_id,vehicle_id,alert_time,alert_type,severity,message,resolved,resolved_at) VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING",
}
FIELDS = {
    "vehicles":["vehicle_id","vin","model","manufacturer","year","battery_capacity_kwh","max_range_km","fleet_region","status","registered_at"],
    "drivers":["driver_id","full_name","license_number","region","joined_at"],
    "trips":["trip_id","vehicle_id","driver_id","start_time","end_time","distance_km","energy_used_kwh","avg_speed_kmh","start_soc","end_soc","start_lat","start_lon","end_lat","end_lon","region"],
    "battery_health":["record_id","vehicle_id","recorded_at","state_of_health","state_of_charge","temperature_c","voltage_v","cycle_count","charging_mode"],
    "charging_sessions":["session_id","vehicle_id","driver_id","start_time","end_time","energy_added_kwh","start_soc","end_soc","charger_type","location","cost_usd"],
    "alerts":["alert_id","vehicle_id","alert_time","alert_type","severity","message","resolved","resolved_at"],
}

def load(table):
    rows=[]
    with open(f"data/{table}.csv",newline="",encoding="utf-8") as f:
        for row in csv.DictReader(f):
            vals=[None if row.get(c,"")==""
                  else (row[c].lower()=="true" if row[c].lower() in ("true","false") else row[c])
                  for c in FIELDS[table]]
            rows.append(tuple(vals))
    return rows

conn=psycopg2.connect(**DB_CONFIG); conn.autocommit=False; cur=conn.cursor()
for t in ["vehicles","drivers","trips","battery_health","charging_sessions","alerts"]:
    rows=load(t); execute_batch(cur,INSERT[t],rows,page_size=500); conn.commit()
    print(f"  {t}: {len(rows)} rows loaded")
cur.close(); conn.close(); print("All done!")
