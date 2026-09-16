import os
import joblib
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression, Ridge
from sklearn.ensemble import RandomForestRegressor, GradientBoostingClassifier
from sklearn.pipeline import Pipeline
from sklearn.calibration import CalibratedClassifierCV

MODELS_DIR = os.path.join(os.path.dirname(__file__), "saved_models")
os.makedirs(MODELS_DIR, exist_ok=True)

# Training dataset for Uttarakhand Citizen Infrastructure Reports
SAMPLE_REPORTS_TRAIN = [
    # WATER
    ("Drinking water pipeline burst near Mall road junction, zero supply for 3 days", "WATER", 4),
    ("Water tanker didn't arrive in upper Barlowganj, taps running dry in village", "WATER", 4),
    ("Natural spring source polluted with construction debris and silt", "WATER", 3),
    ("Severe water shortage in hotels, groundwater borewell failed", "WATER", 5),
    ("Low water pressure in municipal pipeline near Gandhi Chowk", "WATER", 2),
    ("Sewage water mixing with mountain freshwater stream behind bus stand", "WATER", 5),
    ("Water filtration plant offline due to pump failure", "WATER", 4),
    ("Leakage in main storage tank near Mussoorie reservoir", "WATER", 3),

    # WASTE
    ("Huge plastic bottle and garbage heap overflowing at Kempty falls bypass", "WASTE", 4),
    ("Tourist picnic trash dumped along deodar forest trail in Dhanaulti", "WASTE", 3),
    ("Municipal waste bin open and burning plastic fumes spreading in market", "WASTE", 4),
    ("Commercial food packaging litter scattered all over Chopta meadows", "WASTE", 3),
    ("Unauthorized dump site created near riverbank in Rishikesh", "WASTE", 5),
    ("Garbage truck has not collected waste for over 5 days in ward 4", "WASTE", 3),
    ("Massive polythene bags choking mountain water drain", "WASTE", 4),
    ("Littering and broken glass bottles at sunset viewpoint", "WASTE", 2),

    # ROAD
    ("Landslide debris blocking highway near Devprayag, single lane only", "ROAD", 5),
    ("Deep potholes and road cave-in on Rishikesh-Badrinath highway", "ROAD", 4),
    ("Retaining wall collapsed along ghat bend after heavy rain", "ROAD", 5),
    ("Loose gravel on sharp hairpin bend causing bike skids", "ROAD", 3),
    ("Bridge approach road cracked near Tehri dam bridge", "ROAD", 5),
    ("Unpaved muddy stretch making village access impassable for ambulances", "ROAD", 4),
    ("Road widening work left open trenches without warning signs", "ROAD", 3),
    ("Rockfall on highway between Joshimath and Auli", "ROAD", 4),

    # TRAFFIC
    ("Massive 5km vehicle gridlock from Kolhukhet toll to Library Point", "TRAFFIC", 5),
    ("Illegal tourist bus parking blocking main bazaar junction", "TRAFFIC", 3),
    ("Traffic halted for 2 hours due to broken down truck on single ghat lane", "TRAFFIC", 4),
    ("Overcrowded parking lot at Nainital lake causing city-wide jam", "TRAFFIC", 4),
    ("Severe bottleneck at entry checkpoint on weekend morning", "TRAFFIC", 3),
    ("Unauthorized taxi stand creating chaos outside railway station", "TRAFFIC", 2),
    ("Traffic signal malfunctioning at main crossroads", "TRAFFIC", 2),

    # HEALTH
    ("Primary Health Centre dispensary running out of antivenom and emergency kits", "HEALTH", 4),
    ("No doctor available at community health post for altitude sickness cases", "HEALTH", 4),
    ("Ambulance delayed due to ghat blockages, emergency patient critical", "HEALTH", 5),
    ("Contaminated water outbreak causing acute gastroenteritis in village", "HEALTH", 5),
    ("First aid booth closed at high altitude trekking base", "HEALTH", 3),

    # CONNECTIVITY
    ("Mobile network tower down in Chopta and Tungnath trail for 48 hours", "CONNECTIVITY", 3),
    ("Optic fiber snapped due to road widening, broadband internet severed", "CONNECTIVITY", 3),
    ("Zero cell reception during emergency near Harsil valley", "CONNECTIVITY", 4),
    ("Power outage in entire block for 12 hours affecting communication", "CONNECTIVITY", 3),

    # TOURISM
    ("Illegal camping on sensitive high-altitude bugyal without permits", "TOURISM", 4),
    ("Tourists playing loud music in eco-sensitive wildlife corridor past midnight", "TOURISM", 3),
    ("Unregistered fake trekking guides overcharging and abandoning tourists", "TOURISM", 3),
    ("Extreme overcrowding beyond carrying capacity at Kempty waterfall", "TOURISM", 4),

    # ENVIRONMENT
    ("Forest fire smoke spotted spreading towards pine ridge in Almora", "ENVIRONMENT", 5),
    ("Illegal tree felling in reserved oak forest near Binsar sanctuary", "ENVIRONMENT", 4),
    ("Flash flood warning in local ravine after cloudburst upstream", "ENVIRONMENT", 5),
    ("Slope instability and active soil erosion threatening mountain houses", "ENVIRONMENT", 4)
]

def train_report_classifier():
    print("Training AI Citizen Report Classifier & Severity Estimator...")
    texts = [item[0] for item in SAMPLE_REPORTS_TRAIN]
    categories = [item[1] for item in SAMPLE_REPORTS_TRAIN]
    severities = [item[2] for item in SAMPLE_REPORTS_TRAIN]

    # Category pipeline
    category_pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1, sublinear_tf=True)),
        ('clf', LogisticRegression(C=1.0, max_iter=200, class_weight='balanced'))
    ])
    category_pipeline.fit(texts, categories)

    # Severity regressor / classifier
    severity_pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1, sublinear_tf=True)),
        ('clf', LogisticRegression(C=1.0, max_iter=200))
    ])
    severity_pipeline.fit(texts, severities)

    joblib.dump(category_pipeline, os.path.join(MODELS_DIR, "report_category_model.joblib"))
    joblib.dump(severity_pipeline, os.path.join(MODELS_DIR, "report_severity_model.joblib"))
    print("Saved Category and Severity models successfully.")

def train_pressure_predictor():
    print("Training 7-Day Regional Pressure Forecast Model...")
    # Synthetic feature generator simulating historical pressure in mountain districts
    np.random.seed(42)
    n_samples = 1200

    # Features: [base_pressure, day_of_week (0-6), is_weekend, holiday_flag, rainfall_mm, open_reports_count, active_hotel_occupancy]
    base_p = np.random.uniform(20, 85, n_samples)
    dow = np.random.randint(0, 7, n_samples)
    is_weekend = (dow >= 5).astype(float)
    holiday = np.random.choice([0.0, 1.0], p=[0.85, 0.15], size=n_samples)
    rain = np.random.exponential(scale=15.0, size=n_samples)
    reports = np.random.poisson(lam=3, size=n_samples)
    occupancy = np.clip(base_p * 1.1 + is_weekend * 20 + np.random.normal(0, 5, n_samples), 10, 100)

    X = np.column_stack([base_p, dow, is_weekend, holiday, rain, reports, occupancy])
    
    # Target: Next 24-48h pressure change / forward pressure
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

    regressor = RandomForestRegressor(n_estimators=80, max_depth=8, random_state=42)
    regressor.fit(X, y)

    joblib.dump(regressor, os.path.join(MODELS_DIR, "pressure_forecast_model.joblib"))
    print("Saved Pressure Forecaster model successfully.")

if __name__ == "__main__":
    train_report_classifier()
    train_pressure_predictor()
    print("All ML models trained and saved to backend/app/ml/saved_models/")
