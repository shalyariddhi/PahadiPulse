import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Union

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        case_sensitive=True,
        env_file=".env",
        extra="allow"
    )

    PROJECT_NAME: str = "PahadiPulse Backend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"
    ENVIRONMENT: str = "development"
    
    PORT: int = 8000
    HOST: str = "0.0.0.0"
    
    ALLOWED_ORIGINS: Union[List[str], str] = [
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:3000",
        "*"
    ]
    
    # Firebase configuration
    FIREBASE_PROJECT_ID: str = "pahadipulse-889e8"
    FIREBASE_CREDENTIALS_PATH: str = "service-account.json"
    FIREBASE_STORAGE_BUCKET: str = "pahadipulse-889e8.appspot.com"
    USE_LOCAL_DATA_STORE: bool = True
    
    # Weight configuration for Regional Pressure Score
    WEIGHT_TOURISM: float = 0.30
    WEIGHT_WATER: float = 0.25
    WEIGHT_WASTE: float = 0.20
    WEIGHT_TRAFFIC: float = 0.15
    WEIGHT_ENVIRONMENT: float = 0.10

    def get_cors_origins(self) -> List[str]:
        if isinstance(self.ALLOWED_ORIGINS, list):
            return self.ALLOWED_ORIGINS
        if isinstance(self.ALLOWED_ORIGINS, str):
            return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]
        return ["*"]

settings = Settings()
