from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class KeystrokeData(BaseModel):
    """Input data - derived features only, never raw keystrokes"""
    session_id: str
    avg_dwell_time: float = Field(..., ge=0, description="Average key press duration in ms")
    avg_flight_time: float = Field(..., ge=0, description="Average time between keys in ms")
    pause_count: int = Field(..., ge=0, description="Number of pauses >2s")
    avg_pause_duration: float = Field(0, ge=0, description="Average pause duration in ms")
    error_rate: float = Field(..., ge=0, le=1, description="Backspace/delete frequency 0-1")
    correction_rate: float = Field(0, ge=0, le=1, description="Correction attempts 0-1")
    text_length: int = Field(..., ge=0, description="Total characters typed")
    sentiment_score: float = Field(0, ge=-1, le=1, description="Text sentiment -1 to 1")
    word_count: int = Field(0, ge=0, description="Number of words")

class CognitiveScores(BaseModel):
    """Output cognitive state scores"""
    cognitive_load: float = Field(..., ge=0, le=1)
    mood_drift: float = Field(..., ge=0, le=1)
    decision_stability: float = Field(..., ge=0, le=1)
    risk_volatility: float = Field(..., ge=0, le=1)
    heat: float = Field(..., ge=0, le=1)
    rage: float = Field(..., ge=0, le=1)

class CognitiveMetricResponse(BaseModel):
    id: int
    session_id: str
    timestamp: datetime
    avg_dwell_time: float
    avg_flight_time: float
    pause_count: int
    avg_pause_duration: float
    error_rate: float
    correction_rate: float
    text_length: int
    sentiment_score: float
    word_count: int
    cognitive_load: float
    mood_drift: float
    decision_stability: float
    risk_volatility: float
    heat: float
    rage: float
    
    class Config:
        from_attributes = True

class AnalysisResponse(BaseModel):
    """Response containing cognitive analysis"""
    session_id: str
    scores: CognitiveScores
    timestamp: datetime

class DiaryEntryCreate(BaseModel):
    """Create a new diary entry"""
    session_id: str
    mood_rating: int = Field(..., ge=1, le=5, description="Mood rating 1-5")
    mood_notes: str = Field("", description="Optional notes about mood")
    is_crisis: bool = Field(False, description="Mark as crisis entry")

class DiaryEntryResponse(BaseModel):
    """Diary entry with cognitive snapshot"""
    id: int
    session_id: str
    timestamp: datetime
    mood_rating: int
    mood_notes: str
    cognitive_load: float
    mood_drift: float
    decision_stability: float
    risk_volatility: float
    heat: float
    rage: float
    is_crisis: bool
    
    class Config:
        from_attributes = True
