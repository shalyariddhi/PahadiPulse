import os
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

"""
PahadiPulse Regional Pressure Synthetic Dataset Generator
IBM Hackathon PS-04 — Solve for My Region

NOTICE:
This dataset is synthetically generated based on Uttarakhand Himalayan tourism patterns,
carrying capacities, and seasonal pressure indices for hackathon evaluation and demonstration.
"""

DESTINATIONS = [
    {"id": "mussoorie", "capacity": 15000, "base_t": 88.0, "base_w": 82.0, "base_ws": 76.0, "base_tr": 92.0, "base_env": 45.0},
    {"id": "dhanaulti", "capacity": 5000, "base_t": 28.0, "base_w": 30.0, "base_ws": 22.0, "base_tr": 20.0, "base_env": 25.0},
    {"id": "kanatal", "capacity": 4000, "base_t": 18.0, "base_w": 25.0, "base_ws": 15.0, "base_tr": 12.0, "base_env": 20.0},
    {"id": "rishikesh", "capacity": 25000, "base_t": 84.0, "base_w": 62.0, "base_ws": 68.0, "base_tr": 85.0, "base_env": 40.0},
    {"id": "nainital", "capacity": 12000, "base_t": 86.0, "base_w": 80.0, "base_ws": 78.0, "base_tr": 82.0, "base_env": 55.0},
    {"id": "mukteshwar", "capacity": 4500, "base_t": 32.0, "base_w": 35.0, "base_ws": 25.0, "base_tr": 28.0, "base_env": 22.0},
    {"id": "auli", "capacity": 3500, "base_t": 48.0, "base_w": 30.0, "base_ws": 25.0, "base_tr": 35.0, "base_env": 60.0},
    {"id": "chopta", "capacity": 2500, "base_t": 42.0, "base_w": 28.0, "base_ws": 30.0, "base_tr": 32.0, "base_env": 50.0},
    {"id": "lansdowne", "capacity": 4500, "base_t": 35.0, "base_w": 32.0, "base_ws": 28.0, "base_tr": 30.0, "base_env": 20.0},
    {"id": "ranikhet", "capacity": 6000, "base_t": 30.0, "base_w": 35.0, "base_ws": 24.0, "base_tr": 22.0, "base_env": 18.0},
    {"id": "almora", "capacity": 8000, "base_t": 40.0, "base_w": 45.0, "base_ws": 38.0, "base_tr": 35.0, "base_env": 25.0},
    {"id": "binsar", "capacity": 3000, "base_t": 22.0, "base_w": 20.0, "base_ws": 18.0, "base_tr": 15.0, "base_env": 20.0},
    {"id": "tehri", "capacity": 10000, "base_t": 52.0, "base_w": 40.0, "base_ws": 35.0, "base_tr": 45.0, "base_env": 35.0},
    {"id": "chakrata", "capacity": 4000, "base_t": 26.0, "base_w": 25.0, "base_ws": 20.0, "base_tr": 22.0, "base_env": 30.0},
    {"id": "harsil", "capacity": 2000, "base_t": 18.0, "base_w": 18.0, "base_ws": 12.0, "base_tr": 15.0, "base_env": 35.0},
    {"id": "munsiyari", "capacity": 2500, "base_t": 15.0, "base_w": 15.0, "base_ws": 10.0, "base_tr": 14.0, "base_env": 40.0},
    {"id": "kausani", "capacity": 3500, "base_t": 24.0, "base_w": 22.0, "base_ws": 18.0, "base_tr": 16.0, "base_env": 20.0},
    {"id": "devprayag", "capacity": 6000, "base_t": 38.0, "base_w": 30.0, "base_ws": 32.0, "base_tr": 36.0, "base_env": 30.0},
    {"id": "uttarkashi", "capacity": 8000, "base_t": 45.0, "base_w": 42.0, "base_ws": 35.0, "base_tr": 40.0, "base_env": 45.0},
    {"id": "pauri", "capacity": 7000, "base_t": 28.0, "base_w": 30.0, "base_ws": 25.0, "base_tr": 24.0, "base_env": 25.0}
]

def generate_synthetic_dataset(num_days=730, output_path="ml/data/synthetic_pressure_dataset.csv"):
    """
    Generates a 2-year daily time-series dataset (730 days x 20 destinations = 14,600 rows).
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    np.random.seed(42)

    start_date = datetime(2024, 1, 1)
    rows = []

    for dest in DESTINATIONS:
        dest_id = dest["id"]
        capacity = dest["capacity"]
        base_t = dest["base_t"]
        base_w = dest["base_w"]
        base_ws = dest["base_ws"]
        base_tr = dest["base_tr"]
        base_env = dest["base_env"]

        prev_pressure = 0.30*base_t + 0.25*base_w + 0.20*base_ws + 0.15*base_tr + 0.10*base_env
        recent_pressures = [prev_pressure] * 7

        for day_idx in range(num_days):
            curr_date = start_date + timedelta(days=day_idx)
            month = curr_date.month
            day_of_week = curr_date.weekday()
            is_weekend = 1 if day_of_week in (5, 6) else 0

            # Season multiplier
            # Peak summer: May(5), June(6)
            # Monsoon dip: July(7), August(8)
            # Autumn rush: September(9), October(10)
            # Winter ski/snow (Auli/Chopta): Dec(12), Jan(1)
            if month in (5, 6):
                season_mult = 1.35
                season_code = 1 # summer_peak
            elif month in (7, 8):
                season_mult = 0.70
                season_code = 2 # monsoon
            elif month in (9, 10):
                season_mult = 1.20
                season_code = 3 # autumn
            elif month in (12, 1) and dest_id in ("auli", "chopta", "dhanaulti"):
                season_mult = 1.30
                season_code = 0 # winter_snow
            else:
                season_mult = 1.0
                season_code = 0 # regular

            # Weekend surge
            weekend_boost = 14.0 if is_weekend else -3.0
            
            # Weather / environmental seasonal hazard
            if month in (7, 8):
                env_boost = 35.0 # Landslide/monsoon risk
            elif month in (12, 1):
                env_boost = 15.0 # Freezing/fog
            else:
                env_boost = -5.0

            # Random natural fluctuations
            jitter = np.random.normal(0, 3.5)

            # Feature calculations (clamped [0, 100])
            tourism_score = np.clip((base_t * season_mult) + weekend_boost + jitter, 5.0, 100.0)
            tourist_volume = int((tourism_score / 100.0) * capacity * np.random.uniform(0.9, 1.4))
            water_score = np.clip((base_w * season_mult * 0.9) + (weekend_boost * 0.5) + jitter * 0.7, 5.0, 100.0)
            waste_score = np.clip((base_ws * season_mult * 0.95) + (weekend_boost * 0.6) + jitter * 0.8, 5.0, 100.0)
            traffic_score = np.clip((base_tr * season_mult) + (weekend_boost * 1.1) + jitter, 5.0, 100.0)
            environment_score = np.clip(base_env + env_boost + jitter * 0.5, 5.0, 100.0)

            # Current composite pressure
            current_pressure = (
                0.30 * tourism_score +
                0.25 * water_score +
                0.20 * waste_score +
                0.15 * traffic_score +
                0.10 * environment_score
            )
            current_pressure = np.clip(current_pressure, 0.0, 100.0)

            # Lag features
            lag_1d = recent_pressures[-1]
            lag_7d_avg = np.mean(recent_pressures[-7:])
            rolling_3d_avg = np.mean(recent_pressures[-3:])

            # Future pressure target (3 days ahead for prediction horizon)
            # Simulated forward looking drift
            next_day_weekend_factor = 8.0 if (curr_date + timedelta(days=3)).weekday() in (5, 6) else -2.0
            future_pressure = current_pressure * 0.85 + (lag_7d_avg * 0.10) + next_day_weekend_factor + np.random.normal(0, 2.0)
            future_pressure = round(float(np.clip(future_pressure, 0.0, 100.0)), 2)

            rows.append({
                "destination_id": dest_id,
                "date": curr_date.strftime("%Y-%m-%d"),
                "tourist_volume": tourist_volume,
                "capacity": capacity,
                "tourism_score": round(float(tourism_score), 1),
                "water_score": round(float(water_score), 1),
                "waste_score": round(float(waste_score), 1),
                "traffic_score": round(float(traffic_score), 1),
                "environment_score": round(float(environment_score), 1),
                "day_of_week": day_of_week,
                "is_weekend": is_weekend,
                "month": month,
                "season_code": season_code,
                "current_pressure": round(float(current_pressure), 2),
                "lag_pressure_1d": round(float(lag_1d), 2),
                "lag_pressure_7d_avg": round(float(lag_7d_avg), 2),
                "rolling_mean_3d": round(float(rolling_3d_avg), 2),
                "future_pressure_score": future_pressure,
                "is_synthetic": 1
            })

            # Update rolling window
            recent_pressures.append(current_pressure)

    df = pd.DataFrame(rows)
    df.to_csv(output_path, index=False)
    print(f"Generated synthetic training dataset with {len(df)} samples across {len(DESTINATIONS)} destinations -> {output_path}")
    return df

if __name__ == "__main__":
    generate_synthetic_dataset()
