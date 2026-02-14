import React from 'react';
import './MetricCard.css';

const MetricCard = ({ title, value, description, color = '#4CAF50' }) => {
  // Convert to percentage for display
  const percentage = Math.round(value * 100);
  
  return (
    <div className="metric-card">
      <div className="metric-header">
        <h3>{title}</h3>
      </div>
      <div className="metric-body">
        <div className="metric-gauge">
          <svg viewBox="0 0 100 100" className="gauge-svg">
            <circle
              cx="50"
              cy="50"
              r="45"
              fill="none"
              stroke="#e0e0e0"
              strokeWidth="8"
            />
            <circle
              cx="50"
              cy="50"
              r="45"
              fill="none"
              stroke={color}
              strokeWidth="8"
              strokeDasharray={`${percentage * 2.83} 283`}
              strokeLinecap="round"
              transform="rotate(-90 50 50)"
            />
          </svg>
          <div className="gauge-value">{percentage}%</div>
        </div>
        <p className="metric-description">{description}</p>
      </div>
    </div>
  );
};

export default MetricCard;
