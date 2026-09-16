from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import (
    destinations,
    pressure,
    region,
    reports,
    itineraries,
    providers,
    admin,
    ai,
    auth
)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="PahadiPulse: AI-Powered Regional Tourism & Community Intelligence Platform for Uttarakhand (IBM Hackathon PS-04)",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers under /api
app.include_router(destinations.router, prefix=settings.API_V1_STR)
app.include_router(pressure.router, prefix=settings.API_V1_STR)
app.include_router(region.router, prefix=settings.API_V1_STR)
app.include_router(reports.router, prefix=settings.API_V1_STR)
app.include_router(itineraries.router, prefix=settings.API_V1_STR)
app.include_router(providers.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(ai.router, prefix=settings.API_V1_STR)
app.include_router(auth.router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "project": "PahadiPulse",
        "description": "AI Regional Intelligence Platform for Uttarakhand",
        "hackathon": "IBM Hackathon PS-04 — Solve for My Region",
        "version": settings.VERSION,
        "docs": "/docs",
        "status": "online"
    }

@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "modelsLoaded": True
    }
