from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models.cognitive import DiaryEntry, CognitiveMetric
from app.schemas.cognitive import DiaryEntryCreate, DiaryEntryResponse

router = APIRouter(prefix="/api/diary", tags=["diary"])

@router.post("/entry", response_model=DiaryEntryResponse)
def create_diary_entry(entry_data: DiaryEntryCreate, db: Session = Depends(get_db)):
    """
    Create a new behavior diary entry with cognitive snapshot
    """
    # Get latest cognitive metrics for this session
    latest_metric = db.query(CognitiveMetric).filter(
        CognitiveMetric.session_id == entry_data.session_id
    ).order_by(CognitiveMetric.timestamp.desc()).first()
    
    if not latest_metric:
        raise HTTPException(
            status_code=404, 
            detail="No cognitive metrics found for this session. Please analyze typing first."
        )
    
    # Create diary entry with cognitive snapshot
    diary_entry = DiaryEntry(
        session_id=entry_data.session_id,
        mood_rating=entry_data.mood_rating,
        mood_notes=entry_data.mood_notes,
        is_crisis=entry_data.is_crisis,
        cognitive_load=latest_metric.cognitive_load,
        mood_drift=latest_metric.mood_drift,
        decision_stability=latest_metric.decision_stability,
        risk_volatility=latest_metric.risk_volatility,
        heat=latest_metric.heat,
        rage=latest_metric.rage
    )
    
    db.add(diary_entry)
    db.commit()
    db.refresh(diary_entry)
    
    return diary_entry

@router.get("/entries/{session_id}", response_model=List[DiaryEntryResponse])
def get_diary_entries(session_id: str, db: Session = Depends(get_db), limit: int = 50):
    """
    Retrieve diary entries for a session
    """
    entries = db.query(DiaryEntry).filter(
        DiaryEntry.session_id == session_id
    ).order_by(DiaryEntry.timestamp.desc()).limit(limit).all()
    
    return entries

@router.get("/entry/{entry_id}", response_model=DiaryEntryResponse)
def get_diary_entry(entry_id: int, db: Session = Depends(get_db)):
    """
    Get a specific diary entry
    """
    entry = db.query(DiaryEntry).filter(DiaryEntry.id == entry_id).first()
    
    if not entry:
        raise HTTPException(status_code=404, detail="Diary entry not found")
    
    return entry

@router.delete("/entry/{entry_id}")
def delete_diary_entry(entry_id: int, db: Session = Depends(get_db)):
    """
    Delete a diary entry
    """
    entry = db.query(DiaryEntry).filter(DiaryEntry.id == entry_id).first()
    
    if not entry:
        raise HTTPException(status_code=404, detail="Diary entry not found")
    
    db.delete(entry)
    db.commit()
    
    return {"message": "Diary entry deleted successfully"}
