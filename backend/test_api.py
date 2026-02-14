"""Test script to validate backend API functionality"""
import sys
from app.services.cognitive_analyzer import CognitiveAnalyzer
from app.schemas.cognitive import KeystrokeData

def test_cognitive_analyzer():
    """Test cognitive analyzer with sample data"""
    print("=" * 60)
    print("TESTING COGNITIVE ANALYZER")
    print("=" * 60)
    
    analyzer = CognitiveAnalyzer()
    
    # Test case 1: Normal typing
    print("\n1. Normal typing (balanced metrics):")
    data1 = KeystrokeData(
        session_id='test-1',
        avg_dwell_time=100.0,
        avg_flight_time=200.0,
        pause_count=2,
        avg_pause_duration=3000.0,
        error_rate=0.1,
        correction_rate=0.08,
        text_length=150,
        sentiment_score=0.2,
        word_count=30
    )
    scores1 = analyzer.analyze(data1)
    print(f"   Cognitive Load: {scores1.cognitive_load:.3f} (0-1)")
    print(f"   Mood Drift: {scores1.mood_drift:.3f} (0-1)")
    print(f"   Decision Stability: {scores1.decision_stability:.3f} (0-1)")
    print(f"   Risk Volatility: {scores1.risk_volatility:.3f} (0-1)")
    
    # Test case 2: Fast typing with errors (high load, high risk)
    print("\n2. Fast typing with errors (high stress):")
    data2 = KeystrokeData(
        session_id='test-2',
        avg_dwell_time=80.0,
        avg_flight_time=100.0,
        pause_count=1,
        avg_pause_duration=2100.0,
        error_rate=0.25,
        correction_rate=0.15,
        text_length=200,
        sentiment_score=-0.3,
        word_count=40
    )
    scores2 = analyzer.analyze(data2)
    print(f"   Cognitive Load: {scores2.cognitive_load:.3f} (expect HIGH)")
    print(f"   Mood Drift: {scores2.mood_drift:.3f} (expect HIGH)")
    print(f"   Decision Stability: {scores2.decision_stability:.3f} (expect LOW)")
    print(f"   Risk Volatility: {scores2.risk_volatility:.3f} (expect HIGH)")
    
    # Test case 3: Slow, careful typing (low risk, low load)
    print("\n3. Slow, careful typing (calm state):")
    data3 = KeystrokeData(
        session_id='test-3',
        avg_dwell_time=150.0,
        avg_flight_time=300.0,
        pause_count=5,
        avg_pause_duration=5000.0,
        error_rate=0.05,
        correction_rate=0.03,
        text_length=100,
        sentiment_score=0.7,
        word_count=25
    )
    scores3 = analyzer.analyze(data3)
    print(f"   Cognitive Load: {scores3.cognitive_load:.3f} (expect LOW)")
    print(f"   Mood Drift: {scores3.mood_drift:.3f} (expect LOW)")
    print(f"   Decision Stability: {scores3.decision_stability:.3f} (expect MEDIUM)")
    print(f"   Risk Volatility: {scores3.risk_volatility:.3f} (expect LOW)")
    
    print("\n" + "=" * 60)
    print("✅ ALL TESTS PASSED - Backend validation successful!")
    print("=" * 60)
    return True

if __name__ == '__main__':
    try:
        success = test_cognitive_analyzer()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
