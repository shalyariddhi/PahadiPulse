import os
import pandas as pd
import numpy as np
from typing import Tuple, List, Dict, Any
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import joblib

FEATURE_COLUMNS = [
    "tourist_volume",
    "capacity",
    "tourism_score",
    "water_score",
    "waste_score",
    "traffic_score",
    "environment_score",
    "day_of_week",
    "is_weekend",
    "month",
    "season_code",
    "current_pressure",
    "lag_pressure_1d",
    "lag_pressure_7d_avg",
    "rolling_mean_3d",
    "sin_day_of_week",
    "cos_day_of_week",
    "sin_month",
    "cos_month"
]

TARGET_COLUMN = "future_pressure_score"

class DataPreprocessor:
    def __init__(self):
        self.scaler = StandardScaler()
        self.is_fitted = False

    def engineer_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Calculates cyclical date encodings and normalized ratios.
        """
        data = df.copy()

        # Cyclical day of week encoding (0-6)
        data["sin_day_of_week"] = np.sin(2 * np.pi * data["day_of_week"] / 7.0)
        data["cos_day_of_week"] = np.cos(2 * np.pi * data["day_of_week"] / 7.0)

        # Cyclical month encoding (1-12)
        data["sin_month"] = np.sin(2 * np.pi * (data["month"] - 1) / 12.0)
        data["cos_month"] = np.cos(2 * np.pi * (data["month"] - 1) / 12.0)

        return data

    def fit_transform(self, df: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
        data = self.engineer_features(df)
        X = data[FEATURE_COLUMNS].values
        y = data[TARGET_COLUMN].values
        
        X_scaled = self.scaler.fit_transform(X)
        self.is_fitted = True
        return X_scaled, y

    def transform(self, df: pd.DataFrame) -> np.ndarray:
        if not self.is_fitted:
            raise ValueError("Preprocessor has not been fitted yet.")
        data = self.engineer_features(df)
        X = data[FEATURE_COLUMNS].values
        return self.scaler.transform(X)

    def save(self, filepath: str = "ml/models/preprocessor.joblib"):
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        joblib.dump(self, filepath)
        print(f"Saved preprocessor to {filepath}")

    @staticmethod
    def load(filepath: str = "ml/models/preprocessor.joblib") -> "DataPreprocessor":
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"Preprocessor file not found at {filepath}")
        return joblib.load(filepath)

def load_and_split_data(
    csv_path: str = "ml/data/synthetic_pressure_dataset.csv",
    test_size: float = 0.20,
    random_state: int = 42
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, DataPreprocessor]:
    if not os.path.exists(csv_path):
        from ml.data.generate_dataset import generate_synthetic_dataset
        generate_synthetic_dataset(output_path=csv_path)

    df = pd.read_csv(csv_path)
    preprocessor = DataPreprocessor()
    X, y = preprocessor.fit_transform(df)

    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=test_size, random_state=random_state, shuffle=True
    )

    return X_train, X_val, y_train, y_val, preprocessor
