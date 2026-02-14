from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base
from app.routes import cognitive

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="CogniTwin API",
    description="Real-time cognitive digital twin - models user mental state from typing behavior",
    version="1.0.0"
)

# CORS middleware
origins = settings.cors_origins.split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(cognitive.router)

@app.get("/")
def root():
    return {
        "message": "CogniTwin API",
        "version": "1.0.0",
        "description": "Privacy-first cognitive digital twin"
    }

@app.get("/health")
def health():
    return {"status": "healthy"}
