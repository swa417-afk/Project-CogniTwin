"""
Cognitive Analysis Service - Deterministic formulas (no ML)
Privacy-first: processes derived features only, never raw keystrokes
"""
import math
from app.schemas.cognitive import KeystrokeData, CognitiveScores

class CognitiveAnalyzer:
    """Analyzes typing behavior to compute cognitive state metrics"""
    
    @staticmethod
    def normalize(value: float, min_val: float, max_val: float) -> float:
        """Normalize value to 0-1 range with clipping"""
        if max_val == min_val:
            return 0.5
        normalized = (value - min_val) / (max_val - min_val)
        return max(0.0, min(1.0, normalized))
    
    @staticmethod
    def sigmoid(x: float) -> float:
        """Sigmoid function for smooth 0-1 mapping"""
        return 1 / (1 + math.exp(-x))
    
    def calculate_cognitive_load(self, data: KeystrokeData) -> float:
        """
        Cognitive load: higher with faster typing, more errors, shorter pauses
        Indicates mental effort and task complexity
        """
        # Faster typing under pressure (inverse relationship with flight time)
        typing_speed_factor = self.normalize(data.avg_flight_time, 50, 300)
        typing_speed_score = 1 - typing_speed_factor  # Invert: faster = higher load
        
        # Error rate indicates struggle
        error_score = data.error_rate
        
        # Fewer/shorter pauses = sustained high load
        if data.pause_count > 0:
            pause_score = 1 - self.normalize(data.avg_pause_duration, 2000, 10000)
        else:
            pause_score = 0.8  # No pauses = high sustained load
        
        # Weighted combination
        cognitive_load = (
            0.4 * typing_speed_score +
            0.4 * error_score +
            0.2 * pause_score
        )
        
        return max(0.0, min(1.0, cognitive_load))
    
    def calculate_mood_drift(self, data: KeystrokeData) -> float:
        """
        Mood drift: tracks emotional state from sentiment and typing rhythm
        Negative sentiment and irregular timing = higher drift (stress/frustration)
        """
        # Sentiment: map -1 to 1 range into 0 to 1 (negative sentiment = high drift)
        sentiment_factor = (1 - data.sentiment_score) / 2  # -1->1, 0->0.5, 1->0
        
        # Dwell time variability proxy: longer dwell = hesitation/fatigue
        dwell_factor = self.normalize(data.avg_dwell_time, 50, 200)
        
        # High error rate indicates frustration
        frustration_factor = data.error_rate
        
        # Weighted combination
        mood_drift = (
            0.5 * sentiment_factor +
            0.3 * frustration_factor +
            0.2 * dwell_factor
        )
        
        return max(0.0, min(1.0, mood_drift))
    
    def calculate_decision_stability(self, data: KeystrokeData) -> float:
        """
        Decision stability: measures consistency in typing behavior
        High corrections and pauses = low stability (indecision)
        """
        # High correction rate = low stability
        correction_instability = data.correction_rate
        
        # Many pauses = indecision
        pause_factor = self.normalize(data.pause_count, 0, 10)
        
        # Very low or very high dwell time = instability
        dwell_mid = 100  # Target stable dwell time
        dwell_deviation = abs(data.avg_dwell_time - dwell_mid) / dwell_mid
        dwell_instability = min(1.0, dwell_deviation)
        
        # Calculate stability (inverse of instability)
        instability = (
            0.5 * correction_instability +
            0.3 * pause_factor +
            0.2 * dwell_instability
        )
        
        stability = 1 - instability
        return max(0.0, min(1.0, stability))
    
    def calculate_risk_volatility(self, data: KeystrokeData) -> float:
        """
        Risk volatility: rapid changes in behavior indicating uncertainty
        High speed with high errors = risky/impulsive behavior
        """
        # Fast typing (low flight time) = impulsive
        speed_risk = 1 - self.normalize(data.avg_flight_time, 50, 300)
        
        # High error rate without corrections = reckless
        if data.correction_rate > 0:
            recklessness = data.error_rate / (1 + data.correction_rate)
        else:
            recklessness = data.error_rate
        
        # Short pauses with high text volume = rushed
        if data.text_length > 0:
            rush_factor = data.text_length / (1 + data.avg_pause_duration / 1000)
            rush_score = self.normalize(rush_factor, 0, 100)
        else:
            rush_score = 0
        
        # Weighted combination
        risk_volatility = (
            0.4 * speed_risk +
            0.4 * recklessness +
            0.2 * rush_score
        )
        
        return max(0.0, min(1.0, risk_volatility))
    
    def analyze(self, data: KeystrokeData) -> CognitiveScores:
        """
        Main analysis function: computes all cognitive metrics
        Returns scores between 0 and 1
        """
        return CognitiveScores(
            cognitive_load=self.calculate_cognitive_load(data),
            mood_drift=self.calculate_mood_drift(data),
            decision_stability=self.calculate_decision_stability(data),
            risk_volatility=self.calculate_risk_volatility(data)
        )
