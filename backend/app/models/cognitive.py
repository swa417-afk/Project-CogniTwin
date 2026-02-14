from sqlalchemy import Column, Integer, Float, String, DateTime, Text
from sqlalchemy.sql import func
from app.database import Base

class Session(Base):
    """User session - stores aggregate data only, never raw keystrokes"""
    __tablename__ = "sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(100), unique=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class CognitiveMetric(Base):
    """Stores derived cognitive metrics - privacy-first design"""
    __tablename__ = "cognitive_metrics"
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(100), index=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    
    # Derived timing features (aggregated, not individual keystrokes)
    avg_dwell_time = Column(Float)  # Average time key is pressed
    avg_flight_time = Column(Float)  # Average time between keystrokes
    pause_count = Column(Integer)  # Number of pauses (>2s)
    avg_pause_duration = Column(Float)  # Average pause duration
    
    # Error metrics
    error_rate = Column(Float)  # Backspace/delete frequency
    correction_rate = Column(Float)  # Correction attempts
    
    # Text features (derived, not raw text)
    text_length = Column(Integer)
    sentiment_score = Column(Float)  # -1 to 1
    word_count = Column(Integer)
    
    # Cognitive state outputs (0-1 scores)
    cognitive_load = Column(Float)
    mood_drift = Column(Float)
    decision_stability = Column(Float)
    risk_volatility = Column(Float)
