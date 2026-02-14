# CogniTwin Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER BROWSER                             │
│                    (http://localhost:5173)                       │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               │ HTTP/WebSocket
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                      REACT FRONTEND                              │
│                      (Vite Dev Server)                           │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Components:                                            │     │
│  │  • TextInput (keystroke capture)                       │     │
│  │  • Dashboard (metrics display)                         │     │
│  │  • MetricCard (individual scores)                      │     │
│  │                                                         │     │
│  │  Services:                                             │     │
│  │  • api.js (backend communication)                      │     │
│  │  • sentimentAnalyzer.js (text analysis)               │     │
│  │                                                         │     │
│  │  Hooks:                                                │     │
│  │  • useKeystrokeCapture (timing & metrics)             │     │
│  └────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               │ REST API (JSON)
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                      FASTAPI BACKEND                             │
│                   (http://localhost:8000)                        │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Routes:                                                │     │
│  │  • POST /api/cognitive/analyze                         │     │
│  │  • GET  /api/cognitive/metrics/{session_id}            │     │
│  │  • GET  /api/cognitive/latest/{session_id}             │     │
│  │                                                         │     │
│  │  Services:                                             │     │
│  │  • CognitiveAnalyzer (deterministic formulas)         │     │
│  │                                                         │     │
│  │  Models:                                               │     │
│  │  • Session (user sessions)                            │     │
│  │  • CognitiveMetric (derived features only)            │     │
│  └────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               │ SQL Queries
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                      POSTGRESQL DATABASE                         │
│                    (postgresql://localhost:5432)                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Tables:                                                │     │
│  │  • sessions (session tracking)                         │     │
│  │  • cognitive_metrics (derived features only)           │     │
│  │                                                         │     │
│  │  ⚠️ NO RAW DATA STORED:                                │     │
│  │  ✗ Individual keystrokes                               │     │
│  │  ✗ Raw text content                                    │     │
│  │  ✗ Specific keystroke timings                          │     │
│  │                                                         │     │
│  │  ✓ ONLY DERIVED FEATURES:                              │     │
│  │  ✓ Aggregated timing (avg dwell/flight)                │     │
│  │  ✓ Error rates                                          │     │
│  │  ✓ Sentiment scores                                     │     │
│  │  ✓ Cognitive state scores                               │     │
│  └────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Keystroke Capture (Frontend)

```
User Types → KeyDown/KeyUp Events → useKeystrokeCapture Hook
                                              ↓
                                    Calculate Derived Metrics:
                                    • Avg dwell time (key press duration)
                                    • Avg flight time (between keys)
                                    • Pause count & duration
                                    • Error rate (backspaces)
                                    • Correction rate
```

### 2. Text Analysis (Frontend)

```
User Text → sentimentAnalyzer.js
                 ↓
        Sentiment Score (-1 to 1)
        Word Count
        Text Length
```

### 3. API Request (Frontend → Backend)

```
Aggregated Metrics → POST /api/cognitive/analyze
                            ↓
                    {
                      "session_id": "...",
                      "avg_dwell_time": 120.0,
                      "avg_flight_time": 180.0,
                      "pause_count": 3,
                      "avg_pause_duration": 2500.0,
                      "error_rate": 0.15,
                      "correction_rate": 0.12,
                      "text_length": 250,
                      "sentiment_score": 0.3,
                      "word_count": 45
                    }
```

### 4. Cognitive Analysis (Backend)

```
Input Metrics → CognitiveAnalyzer
                      ↓
            Deterministic Formulas:
            
            • Cognitive Load = 
                0.4 × typing_speed +
                0.4 × error_rate +
                0.2 × pause_score
            
            • Mood Drift = 
                0.5 × sentiment_factor +
                0.3 × frustration +
                0.2 × dwell_factor
            
            • Decision Stability = 
                1 - (0.5 × corrections +
                     0.3 × pauses +
                     0.2 × dwell_instability)
            
            • Risk Volatility = 
                0.4 × speed_risk +
                0.4 × recklessness +
                0.2 × rush_score
                      ↓
            Output: 4 scores (0-1 range)
```

### 5. Storage & Response (Backend → Database → Frontend)

```
Cognitive Scores → Store in PostgreSQL → Return to Frontend
                         ↓                        ↓
                  cognitive_metrics          Dashboard Display
                  (derived features          (4 metric cards with
                   only, no raw data)         real-time updates)
```

## Privacy Architecture

### What Gets Captured (Client-Side)
- ✓ Keystroke events (KeyDown/KeyUp)
- ✓ Timing calculations (dwell/flight)
- ✓ Text content (for sentiment)

### What Gets Aggregated (Client-Side)
- ✓ Average times (not individual)
- ✓ Error counts (not specific keys)
- ✓ Sentiment score (not text)

### What Gets Transmitted (API)
- ✓ Aggregated metrics only
- ✗ NO individual keystrokes
- ✗ NO raw text content

### What Gets Stored (Database)
- ✓ Derived features only
- ✓ Aggregated statistics
- ✓ Cognitive scores
- ✗ NO raw keystroke data
- ✗ NO text content

## Technology Stack

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite 5
- **HTTP Client**: Axios
- **Language**: JavaScript (ES6+)
- **Styling**: CSS3

### Backend
- **Framework**: FastAPI 0.109
- **ORM**: SQLAlchemy 2.0
- **Validation**: Pydantic 2.5
- **Language**: Python 3.11+
- **Server**: Uvicorn

### Database
- **DBMS**: PostgreSQL 15
- **Driver**: psycopg2-binary

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Development**: Hot reload for both frontend & backend

## Deployment Architecture (Docker Compose)

```
┌─────────────────────────────────────────────────────────────┐
│                         Host Machine                         │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Frontend   │  │   Backend   │  │  Database   │        │
│  │  Container  │  │  Container  │  │  Container  │        │
│  │             │  │             │  │             │        │
│  │  Node 18    │  │  Python 3.11│  │ PostgreSQL  │        │
│  │  Vite       │  │  FastAPI    │  │     15      │        │
│  │             │  │  Uvicorn    │  │             │        │
│  │  Port 5173  │  │  Port 8000  │  │  Port 5432  │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │
│         └────────────────┴────────────────┘                │
│                   Docker Network                            │
│                                                              │
│  Volumes:                                                   │
│  • ./frontend/src → /app/src (hot reload)                  │
│  • ./backend/app → /app/app (hot reload)                   │
│  • postgres_data → /var/lib/postgresql/data (persistence)  │
└─────────────────────────────────────────────────────────────┘
```

## Security Considerations

1. **Privacy-First Design**
   - No raw keystroke data persisted
   - Text content analyzed in-memory only
   - Only aggregated metrics stored

2. **CORS Configuration**
   - Restricted to specific origins
   - Configurable via environment variables

3. **Database Access**
   - PostgreSQL with authentication
   - No direct external access (internal network only)

4. **Input Validation**
   - Pydantic schemas validate all inputs
   - Type checking and range validation

5. **No External Services**
   - All processing local
   - No cloud APIs or third-party services
   - Complete data sovereignty

## Scalability Notes

### Current Design (Single Instance)
- Suitable for: Individual use, small teams, research
- Capacity: 100s of concurrent users
- Storage: Grows linearly with sessions

### Future Enhancements
- Add Redis for caching
- Implement WebSocket for real-time updates
- Add horizontal scaling for API
- Implement session cleanup/archival
- Add analytics aggregation
