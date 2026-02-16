"""Seed script for local demo data.

Run from backend/:
  python -m app.seed
"""

from datetime import datetime
from app.database import SessionLocal, Base, engine
from app.models.cognitive import CognitiveMetric, DiaryEntry, Session as SessionModel


def main() -> None:
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        session_id = "demo-session"

        session = db.query(SessionModel).filter(SessionModel.session_id == session_id).first()
        if not session:
            session = SessionModel(session_id=session_id)
            db.add(session)
            db.commit()

        metric = CognitiveMetric(
            session_id=session_id,
            avg_dwell_time=110.0,
            avg_flight_time=85.0,
            pause_count=4,
            avg_pause_duration=0.45,
            error_rate=0.06,
            backspace_rate=0.04,
            typing_speed=52.0,
            rhythm_variability=0.22,
            cognitive_load=0.42,
            mood_drift=-0.10,
            decision_stability=0.78,
            risk_volatility=0.25,
            heat=0.15,
            rage=0.05,
            timestamp=datetime.utcnow(),
        )
        db.add(metric)
        db.commit()
        db.refresh(metric)

        entry = DiaryEntry(
            session_id=session_id,
            mood_rating=7,
            mood_notes="Seeded demo entry for hackathon / local testing.",
            is_crisis=False,
            cognitive_load=metric.cognitive_load,
            mood_drift=metric.mood_drift,
            decision_stability=metric.decision_stability,
            risk_volatility=metric.risk_volatility,
            heat=metric.heat,
            rage=metric.rage,
            timestamp=datetime.utcnow(),
        )
        db.add(entry)
        db.commit()

        print("Seed complete.")
        print(f"  session_id: {session_id}")
        print("  created: 1 CognitiveMetric, 1 DiaryEntry")
    finally:
        db.close()


if __name__ == "__main__":
    main()
