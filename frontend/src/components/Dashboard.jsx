import React from 'react';
import MetricCard from './MetricCard';
import './Dashboard.css';

const Dashboard = ({ scores, isAnalyzing }) => {
  if (!scores) {
    return (
      <div className="dashboard">
        <div className="no-data">
          <p>Start typing to see your cognitive metrics...</p>
        </div>
      </div>
    );
  }
  
  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h2>Cognitive Metrics</h2>
        {isAnalyzing && <span className="analyzing-badge">Analyzing...</span>}
      </div>
      
      <div className="metrics-grid">
        <MetricCard
          title="Cognitive Load"
          value={scores.cognitive_load}
          description="Mental effort and task complexity"
          color="#FF6B6B"
        />
        <MetricCard
          title="Mood Drift"
          value={scores.mood_drift}
          description="Emotional state tracking"
          color="#4ECDC4"
        />
        <MetricCard
          title="Decision Stability"
          value={scores.decision_stability}
          description="Consistency in behavior"
          color="#45B7D1"
        />
        <MetricCard
          title="Risk Volatility"
          value={scores.risk_volatility}
          description="Impulsivity and uncertainty"
          color="#FFA07A"
        />
      </div>
    </div>
  );
};

export default Dashboard;
