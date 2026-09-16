import os
import sys
import json
import numpy as np

# Ensure root path is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from datetime import datetime, timezone
from sklearn.linear_model import Ridge
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib

from ml.data.preprocessor import load_and_split_data, FEATURE_COLUMNS

def train_and_evaluate_models(
    data_path: str = "ml/data/synthetic_pressure_dataset.csv",
    output_model_dir: str = "ml/models"
):
    os.makedirs(output_model_dir, exist_ok=True)

    print("--- Starting PahadiPulse Regional Pressure ML Training Pipeline ---")
    X_train, X_val, y_train, y_val, preprocessor = load_and_split_data(data_path)
    print(f"Data split: {X_train.shape[0]} training samples, {X_val.shape[0]} validation samples across {len(FEATURE_COLUMNS)} features.")

    # 1. Baseline Model (Ridge Regression)
    print("\nTraining Baseline Model (Ridge Regression)...")
    baseline_model = Ridge(alpha=1.0)
    baseline_model.fit(X_train, y_train)
    y_pred_base = baseline_model.predict(X_val)

    base_mae = mean_absolute_error(y_val, y_pred_base)
    base_rmse = np.sqrt(mean_squared_error(y_val, y_pred_base))
    base_r2 = r2_score(y_val, y_pred_base)

    print(f"[Baseline Ridge] R2: {base_r2:.4f}, MAE: {base_mae:.4f}, RMSE: {base_rmse:.4f}")

    # 2. Final Model (RandomForestRegressor)
    print("\nTraining Final Model (RandomForestRegressor)...")
    rf_model = RandomForestRegressor(
        n_estimators=100,
        max_depth=12,
        min_samples_split=4,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )
    rf_model.fit(X_train, y_train)
    y_pred_rf = rf_model.predict(X_val)

    rf_mae = mean_absolute_error(y_val, y_pred_rf)
    rf_rmse = np.sqrt(mean_squared_error(y_val, y_pred_rf))
    rf_r2 = r2_score(y_val, y_pred_rf)

    print(f"[Final RandomForest] R2: {rf_r2:.4f}, MAE: {rf_mae:.4f}, RMSE: {rf_rmse:.4f}")

    # 3. Alternative GradientBoostingRegressor comparison
    print("\nTraining GradientBoostingRegressor for comparison...")
    gb_model = GradientBoostingRegressor(
        n_estimators=100,
        max_depth=5,
        learning_rate=0.08,
        random_state=42
    )
    gb_model.fit(X_train, y_train)
    y_pred_gb = gb_model.predict(X_val)

    gb_mae = mean_absolute_error(y_val, y_pred_gb)
    gb_rmse = np.sqrt(mean_squared_error(y_val, y_pred_gb))
    gb_r2 = r2_score(y_val, y_pred_gb)

    print(f"[GradientBoosting] R2: {gb_r2:.4f}, MAE: {gb_mae:.4f}, RMSE: {gb_rmse:.4f}")

    # Pick best model
    if rf_r2 >= gb_r2:
        best_model = rf_model
        best_name = "RandomForestRegressor"
        best_r2 = rf_r2
        best_mae = rf_mae
        best_rmse = rf_rmse
        feature_importances = dict(zip(FEATURE_COLUMNS, [float(x) for x in rf_model.feature_importances_]))
    else:
        best_model = gb_model
        best_name = "GradientBoostingRegressor"
        best_r2 = gb_r2
        best_mae = gb_mae
        best_rmse = gb_rmse
        feature_importances = dict(zip(FEATURE_COLUMNS, [float(x) for x in gb_model.feature_importances_]))

    # 4. Serialize Model & Preprocessor
    model_path = os.path.join(output_model_dir, "pressure_regressor.joblib")
    preprocessor_path = os.path.join(output_model_dir, "preprocessor.joblib")
    metadata_path = os.path.join(output_model_dir, "model_metadata.json")

    joblib.dump(best_model, model_path)
    preprocessor.save(preprocessor_path)

    metadata = {
        "modelName": "PahadiPulse Regional Pressure Predictor",
        "algorithm": best_name,
        "trainedAt": datetime.now(timezone.utc).isoformat(),
        "isSyntheticData": True,
        "dataSource": "SYNTHETIC_DEVELOPMENT_DATASET",
        "disclaimer": "Trained on synthetic Himalayan regional tourism pressure data for IBM Hackathon demonstration. Do not use as certified real-world meteorological/civil emergency forecast without ground-truth calibration.",
        "metrics": {
            "baseline": {
                "algorithm": "Ridge",
                "r2Score": round(float(base_r2), 4),
                "mae": round(float(base_mae), 4),
                "rmse": round(float(base_rmse), 4)
            },
            "finalModel": {
                "algorithm": best_name,
                "r2Score": round(float(best_r2), 4),
                "mae": round(float(best_mae), 4),
                "rmse": round(float(best_rmse), 4)
            }
        },
        "featureImportances": sorted(
            [{"feature": k, "importance": round(v, 4)} for k, v in feature_importances.items()],
            key=lambda x: x["importance"],
            reverse=True
        ),
        "totalFeatures": len(FEATURE_COLUMNS),
        "featureNames": FEATURE_COLUMNS
    }

    with open(metadata_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"\nSaved Best Model ({best_name}) to: {model_path}")
    print(f"Saved Preprocessor to: {preprocessor_path}")
    print(f"Saved Metadata to: {metadata_path}")
    print("--- Training Pipeline Completed Successfully ---")

    return metadata

if __name__ == "__main__":
    train_and_evaluate_models()
