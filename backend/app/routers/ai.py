from fastapi import APIRouter
from typing import Optional
from pydantic import BaseModel, Field
from app.models.schemas import AIReportClassification
from app.services.ml_service import ml_service

router = APIRouter(prefix="/ai", tags=["AI & Machine Learning Engine"])

class TextClassificationRequest(BaseModel):
    text: str = Field(..., min_length=3, description="Citizen issue observation text")
    imageUrl: Optional[str] = Field(None, description="Optional photo URL attached with the report")

@router.post("/classify-report", response_model=AIReportClassification)
def classify_report_text(req: TextClassificationRequest):
    """
    Classifies regional citizen/tourist issue description into 9 categories:
    WATER, WASTE, ROAD, TRAFFIC, HEALTH, CONNECTIVITY, TOURISM, ENVIRONMENT, OTHER,
    and estimates severity (LOW, MEDIUM, HIGH, CRITICAL) with confidence and explanation.
    """
    return ml_service.classify_report(req.text, image_url=req.imageUrl)

