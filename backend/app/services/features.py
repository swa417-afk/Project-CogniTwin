"""
Enhanced Feature Detection - Heat and Rage Metrics
Privacy-first: processes derived features only
"""
from app.schemas.cognitive import KeystrokeData

# Constants for rage detection thresholds
HIGH_ERROR_THRESHOLD = 0.2
CORRECTION_PENALTY_MULTIPLIER = 0.5
OPTIMAL_DWELL_TIME = 100  # milliseconds

class FeatureDetector:
    """Detects advanced behavioral patterns from typing metrics"""
    
    @staticmethod
    def normalize(value: float, min_val: float, max_val: float) -> float:
        """Normalize value to 0-1 range with clipping"""
        if max_val == min_val:
            return 0.5
        normalized = (value - min_val) / (max_val - min_val)
        return max(0.0, min(1.0, normalized))
    
    def detect_heat(self, data: KeystrokeData) -> float:
        """
        Heat: Agitation/arousal level from typing intensity
        High heat = rapid, forceful typing with minimal pauses
        Indicators: fast keystrokes, long dwell times, few pauses
        """
        # Very fast typing indicates high arousal
        speed_heat = 1 - self.normalize(data.avg_flight_time, 50, 300)
        
        # Long dwell time (forceful keystrokes) indicates tension
        dwell_intensity = self.normalize(data.avg_dwell_time, 50, 200)
        
        # Few pauses = sustained high arousal
        if data.pause_count == 0:
            pause_heat = 0.9
        else:
            # More pauses = lower heat
            pause_heat = 1 - self.normalize(data.pause_count, 0, 10)
        
        # Continuous typing (high text volume in short time)
        if data.text_length > 0:
            typing_intensity = self.normalize(data.text_length, 0, 500)
        else:
            typing_intensity = 0
        
        # Weighted combination
        heat = (
            0.35 * speed_heat +
            0.25 * dwell_intensity +
            0.25 * pause_heat +
            0.15 * typing_intensity
        )
        
        return max(0.0, min(1.0, heat))
    
    def detect_rage(self, data: KeystrokeData) -> float:
        """
        Rage: Anger intensity from aggressive typing patterns
        High rage = erratic, aggressive behavior with negative sentiment
        Indicators: high errors, negative sentiment, erratic timing, high heat
        """
        # High error rate suggests aggressive/careless typing
        aggression_score = data.error_rate
        
        # Very negative sentiment indicates anger
        # Map sentiment -1 to 1 → rage 1 to 0
        if data.sentiment_score < 0:
            sentiment_rage = abs(data.sentiment_score)  # -1 becomes 1
        else:
            sentiment_rage = 0  # Positive sentiment = no rage
        
        # High corrections without fixing = frustrated abandonment
        if data.error_rate > HIGH_ERROR_THRESHOLD and data.correction_rate < data.error_rate * CORRECTION_PENALTY_MULTIPLIER:
            frustration_factor = 0.8
        else:
            frustration_factor = data.error_rate * CORRECTION_PENALTY_MULTIPLIER
        
        # Erratic dwell time (very short or very long) = agitation
        dwell_variance = abs(data.avg_dwell_time - OPTIMAL_DWELL_TIME) / OPTIMAL_DWELL_TIME
        erratic_score = min(1.0, dwell_variance)
        
        # High heat amplifies rage (arousal + anger)
        heat_score = self.detect_heat(data)
        heat_amplification = heat_score * 0.5
        
        # Weighted combination
        rage = (
            0.30 * aggression_score +
            0.30 * sentiment_rage +
            0.20 * frustration_factor +
            0.10 * erratic_score +
            0.10 * heat_amplification
        )
        
        return max(0.0, min(1.0, rage))
    
    def analyze_features(self, data: KeystrokeData) -> dict:
        """
        Analyze all advanced features
        Returns dictionary with heat and rage scores
        """
        return {
            'heat': self.detect_heat(data),
            'rage': self.detect_rage(data)
        }
