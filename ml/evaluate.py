import os
import joblib
from sklearn.metrics import classification_report
from dataset import REPORTS_DATASET

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")

def evaluate_models():
    cat_path = os.path.join(MODELS_DIR, "report_category_model.joblib")
    sev_path = os.path.join(MODELS_DIR, "report_severity_model.joblib")

    if not os.path.exists(cat_path) or not os.path.exists(sev_path):
        print("Models not found. Run train.py first.")
        return

    cat_pipeline = joblib.load(cat_path)
    texts = [item[0] for item in REPORTS_DATASET]
    true_cats = [item[1] for item in REPORTS_DATASET]

    preds = cat_pipeline.predict(texts)
    print("=== Category Classification Report ===")
    print(classification_report(true_cats, preds, zero_division=0))

if __name__ == "__main__":
    evaluate_models()
