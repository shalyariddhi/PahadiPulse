from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
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
    auth,
    notifications
)
import os
from fastapi.staticfiles import StaticFiles

# Production security docs settings
docs_url = "/docs" if settings.ENVIRONMENT != "production" else None
redoc_url = "/redoc" if settings.ENVIRONMENT != "production" else None

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="PahadiPulse: AI-Powered Regional Tourism & Community Intelligence Platform for Uttarakhand (IBM Hackathon PS-04)",
    docs_url=docs_url,
    redoc_url=redoc_url
)

# Security Headers Middleware
class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
        return response

app.add_middleware(SecurityHeadersMiddleware)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_cors_origins(),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Static files for local uploads fallback
uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "uploads")
os.makedirs(uploads_dir, exist_ok=True)
app.mount("/static/uploads", StaticFiles(directory=uploads_dir), name="uploads")


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
app.include_router(notifications.router, prefix=settings.API_V1_STR)

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
