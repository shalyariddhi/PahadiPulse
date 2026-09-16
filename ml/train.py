import os
import joblib
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from dataset import REPORTS_DATASET

MODELS_EXPORT_DIR = os.path.join(os.path.dirname(__file__), "..", "backend", "app", "ml", "saved_models")
LOCAL_MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")

for d in [MODELS_EXPORT_DIR, LOCAL_MODELS_DIR]:
    os.makedirs(d, exist_ok=True)

def train_report_classifier():
    print("Training Citizen Report Category and Severity Models...")
    texts = [item[0] for item in REPORTS_DATASET]
    categories = [item[1] for item in REPORTS_DATASET]
    severities = [item[2] for item in REPORTS_DATASET]

    # Category Pipeline
    cat_pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1, sublinear_tf=True)),
        ('clf', LogisticRegression(C=1.0, max_iter=200, class_weight='balanced'))
    ])
    cat_pipeline.fit(texts, categories)

    # Severity Pipeline
    sev_pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1, sublinear_tf=True)),
        ('clf', LogisticRegression(C=1.0, max_iter=200))
    ])
    sev_pipeline.fit(texts, severities)

    for target_dir in [MODELS_EXPORT_DIR, LOCAL_MODELS_DIR]:
        joblib.dump(cat_pipeline, os.path.join(target_dir, "report_category_model.joblib"))
        joblib.dump(sev_pipeline, os.path.join(target_dir, "report_severity_model.joblib"))
    
    print("Exported report_category_model.joblib & report_severity_model.joblib")

def train_pressure_forecaster():
    print("Training 7-Day Regional Pressure Time-Series Regressor...")
    np.random.seed(42)
    n_samples = 1500

    base_p = np.random.uniform(20, 85, n_samples)
    dow = np.random.randint(0, 7, n_samples)
    is_weekend = (dow >= 5).astype(float)
    holiday = np.random.choice([0.0, 1.0], p=[0.85, 0.15], size=n_samples)
    rain = np.random.exponential(scale=15.0, size=n_samples)
    reports = np.random.poisson(lam=3, size=n_samples)
    occupancy = np.clip(base_p * 1.1 + is_weekend * 20 + np.random.normal(0, 5, n_samples), 10, 100)

    X = np.column_stack([base_p, dow, is_weekend, holiday, rain, reports, occupancy])
    y = np.clip(
        0.5 * base_p + 
        0.25 * occupancy + 
        (is_weekend * 12.0) + 
        (holiday * 15.0) + 
        (rain * 0.15) + 
        (reports * 1.2) + 
        np.random.normal(0, 2.5, n_samples),
        5.0, 99.0
    )

    model = RandomForestRegressor(n_estimators=100, max_depth=8, random_state=42)
    model.fit(X, y)

    for target_dir in [MODELS_EXPORT_DIR, LOCAL_MODELS_DIR]:
        joblib.dump(model, os.path.join(target_dir, "pressure_forecast_model.joblib"))

    print("Exported pressure_forecast_model.joblib")

if __name__ == "__main__":
    train_report_classifier()
    train_pressure_forecaster()
    print("ML Pipeline training completed successfully.")
