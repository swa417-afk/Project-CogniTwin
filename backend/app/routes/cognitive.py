from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models.cognitive import CognitiveMetric, Session as SessionModel
from app.schemas.cognitive import KeystrokeData, AnalysisResponse, CognitiveMetricResponse
from app.services.cognitive_analyzer import CognitiveAnalyzer

router = APIRouter(prefix="/api/cognitive", tags=["cognitive"])
analyzer = CognitiveAnalyzer()

@router.post("/analyze", response_model=AnalysisResponse)
def analyze_typing(data: KeystrokeData, db: Session = Depends(get_db)):
    """
    Analyze typing behavior and compute cognitive metrics
    Privacy-first: accepts only derived features, never raw keystrokes
    """
    # Ensure session exists
    session = db.query(SessionModel).filter(
        SessionModel.session_id == data.session_id
    ).first()
    
    if not session:
        session = SessionModel(session_id=data.session_id)
        db.add(session)
        db.commit()
    
    # Calculate cognitive scores using deterministic formulas
    scores = analyzer.analyze(data)
    
    # Store derived metrics (privacy-preserving)
    metric = CognitiveMetric(
        session_id=data.session_id,
        avg_dwell_time=data.avg_dwell_time,
        avg_flight_time=data.avg_flight_time,
        pause_count=data.pause_count,
        avg_pause_duration=data.avg_pause_duration,
        error_rate=data.error_rate,
        correction_rate=data.correction_rate,
        text_length=data.text_length,
        sentiment_score=data.sentiment_score,
        word_count=data.word_count,
        cognitive_load=scores.cognitive_load,
        mood_drift=scores.mood_drift,
        decision_stability=scores.decision_stability,
        risk_volatility=scores.risk_volatility
    )
    
    db.add(metric)
    db.commit()
    db.refresh(metric)
    
    return AnalysisResponse(
        session_id=data.session_id,
        scores=scores,
        timestamp=metric.timestamp
    )

@router.get("/metrics/{session_id}", response_model=List[CognitiveMetricResponse])
def get_session_metrics(session_id: str, db: Session = Depends(get_db), limit: int = 50):
    """
    Retrieve historical cognitive metrics for a session
    Returns up to 'limit' most recent metrics
    """
    metrics = db.query(CognitiveMetric).filter(
        CognitiveMetric.session_id == session_id
    ).order_by(CognitiveMetric.timestamp.desc()).limit(limit).all()
    
    if not metrics:
        raise HTTPException(status_code=404, detail="No metrics found for this session")
    
    return metrics

@router.get("/latest/{session_id}", response_model=CognitiveMetricResponse)
def get_latest_metric(session_id: str, db: Session = Depends(get_db)):
    """
    Get the most recent cognitive metric for a session
    """
    metric = db.query(CognitiveMetric).filter(
        CognitiveMetric.session_id == session_id
    ).order_by(CognitiveMetric.timestamp.desc()).first()
    
    if not metric:
        raise HTTPException(status_code=404, detail="No metrics found for this session")
    
    return metric

@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "cognitive-analysis"}
