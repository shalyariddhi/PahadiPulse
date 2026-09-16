from fastapi import APIRouter
from pydantic import BaseModel
from app.models.schemas import AIReportClassification
from app.services.ml_service import ml_service

router = APIRouter(prefix="/ai", tags=["AI & Machine Learning Engine"])

class TextClassificationRequest(BaseModel):
    text: str

@router.post("/classify-report", response_model=AIReportClassification)
def classify_report_text(req: TextClassificationRequest):
    return ml_service.classify_report(req.text)
