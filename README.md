# 🧠 CogniTwin - Cognitive Digital Twin

A real-time cognitive digital twin that models user mental state from typing behavior. CogniTwin analyzes keystroke timing, error rates, text sentiment, and pause intervals to compute cognitive load, mood drift, decision stability, and risk volatility.

**Privacy-first. Explainable. No ML. No cloud required.**

## 🎯 Features

- **Real-time Analysis**: Continuous monitoring of typing behavior and cognitive state
- **Four Cognitive Metrics** (0-1 scores):
  - **Cognitive Load**: Mental effort and task complexity
  - **Mood Drift**: Emotional state tracking from sentiment and rhythm
  - **Decision Stability**: Consistency in typing behavior
  - **Risk Volatility**: Impulsivity and uncertainty indicators
- **Privacy-First Design**: Stores only derived features, never raw keystrokes or text
- **Deterministic Formulas**: No ML models, fully explainable calculations
- **Modern Stack**: FastAPI + PostgreSQL backend, React + Vite frontend

## 📊 Captured Metrics

### Input Features (Derived Only)
- Keystroke timing: dwell time (key press duration), flight time (time between keys)
- Error rate: backspace/delete frequency
- Text sentiment: -1 (negative) to 1 (positive)
- Pause intervals: count and duration of pauses >2 seconds
- Correction rate: editing behavior patterns

### Output Scores (0-1 Range)
All cognitive scores are calculated using deterministic formulas:

1. **Cognitive Load**: Higher with faster typing, more errors, shorter pauses
2. **Mood Drift**: Tracks emotional state from negative sentiment and irregular timing
3. **Decision Stability**: Lower with high corrections and many pauses (indecision)
4. **Risk Volatility**: High speed + high errors = risky/impulsive behavior

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- (Optional) Node.js 18+ and Python 3.11+ for local development

### Running with Docker Compose

1. Clone the repository:
```bash
git clone https://github.com/swa417-afk/Project-CogniTwin.git
cd Project-CogniTwin
```

2. Start all services:
```bash
docker-compose up -d
```

3. Access the application:
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

4. Stop all services:
```bash
docker-compose down
```

### Local Development

#### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Set up database connection
cp .env.example .env
# Edit .env with your database URL

# Run the backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend Setup
```bash
cd frontend
npm install

# Set up API URL
cp .env.example .env
# Edit .env with your backend URL

# Run the frontend
npm run dev
```

## 🏗️ Architecture

```
CogniTwin/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── main.py         # FastAPI application
│   │   ├── config.py       # Configuration
│   │   ├── database.py     # Database connection
│   │   ├── models/         # SQLAlchemy models
│   │   ├── routes/         # API endpoints
│   │   ├── schemas/        # Pydantic schemas
│   │   └── services/       # Business logic
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/               # React + Vite frontend
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom hooks
│   │   ├── services/      # API & utilities
│   │   ├── App.jsx        # Main component
│   │   └── main.jsx       # Entry point
│   ├── Dockerfile
│   └── package.json
└── docker-compose.yml     # Docker orchestration
```

## 🔒 Privacy & Security

CogniTwin is designed with privacy as a core principle:

1. **No Raw Keystroke Storage**: Individual keystrokes are never stored
2. **No Text Storage**: Input text is analyzed in-memory only for sentiment
3. **Derived Features Only**: Only aggregated metrics are persisted:
   - Average timing (not individual keystroke times)
   - Error rates (not specific errors)
   - Sentiment scores (not raw text)
4. **Local Processing**: All analysis happens locally, no cloud services
5. **Transparent Calculations**: All formulas are deterministic and auditable

## 🧪 API Endpoints

### POST `/api/cognitive/analyze`
Analyze typing behavior and compute cognitive metrics.

**Request Body:**
```json
{
  "session_id": "session-123",
  "avg_dwell_time": 120.5,
  "avg_flight_time": 180.3,
  "pause_count": 3,
  "avg_pause_duration": 2500,
  "error_rate": 0.15,
  "correction_rate": 0.12,
  "text_length": 250,
  "sentiment_score": 0.3,
  "word_count": 45
}
```

**Response:**
```json
{
  "session_id": "session-123",
  "scores": {
    "cognitive_load": 0.65,
    "mood_drift": 0.42,
    "decision_stability": 0.78,
    "risk_volatility": 0.33
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### GET `/api/cognitive/metrics/{session_id}`
Retrieve historical cognitive metrics for a session.

### GET `/api/cognitive/latest/{session_id}`
Get the most recent cognitive metric for a session.

## 📈 Cognitive Score Formulas

All scores are deterministic, rule-based calculations:

### Cognitive Load
```
cognitive_load = 
  0.4 × typing_speed_score +
  0.4 × error_rate +
  0.2 × pause_score
```
Higher values indicate greater mental effort.

### Mood Drift
```
mood_drift = 
  0.5 × sentiment_factor +
  0.3 × frustration_factor +
  0.2 × dwell_factor
```
Higher values indicate negative emotional state.

### Decision Stability
```
stability = 1 - (
  0.5 × correction_instability +
  0.3 × pause_factor +
  0.2 × dwell_instability
)
```
Lower values indicate indecision and inconsistency.

### Risk Volatility
```
risk_volatility = 
  0.4 × speed_risk +
  0.4 × recklessness +
  0.2 × rush_score
```
Higher values indicate impulsive, risky behavior.

## 🛠️ Technology Stack

- **Backend**: FastAPI, SQLAlchemy, PostgreSQL, Pydantic
- **Frontend**: React 18, Vite, Axios
- **Database**: PostgreSQL 15
- **Infrastructure**: Docker, Docker Compose
- **Language**: Python 3.11, JavaScript (ES6+)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🔮 Future Enhancements

- Historical trend visualization
- Export cognitive reports
- Multi-language support
- Customizable thresholds and alerts
- Mobile app support
- Advanced analytics dashboard

## 📞 Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Built with ❤️ for privacy-conscious cognitive analysis**
