# CogniTwin Testing Guide

## Automated Backend Tests

### Running Backend Tests

1. Navigate to backend directory:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. Run the test script:
```bash
python test_api.py
```

### Expected Test Results

The test script validates three scenarios:

1. **Normal Typing (Balanced)**
   - Cognitive Load: ~0.38 (moderate mental effort)
   - Mood Drift: ~0.30 (neutral emotional state)
   - Decision Stability: ~0.90 (high consistency)
   - Risk Volatility: ~0.27 (low impulsivity)

2. **Fast Typing with Errors (High Stress)**
   - Cognitive Load: ~0.62 (HIGH - rushed, under pressure)
   - Mood Drift: ~0.44 (MEDIUM-HIGH - frustrated)
   - Decision Stability: ~0.86 (unstable with corrections)
   - Risk Volatility: ~0.54 (HIGH - impulsive behavior)

3. **Slow, Careful Typing (Calm)**
   - Cognitive Load: ~0.15 (LOW - relaxed pace)
   - Mood Drift: ~0.22 (LOW - positive sentiment)
   - Decision Stability: ~0.74 (MEDIUM - thoughtful pauses)
   - Risk Volatility: ~0.05 (VERY LOW - careful)

## Manual Integration Testing

### Test 1: Backend API (Without Docker)

1. Start a PostgreSQL database (or use SQLite for quick testing):
```bash
# Option 1: Use Docker for PostgreSQL only
docker run -d -p 5432:5432 -e POSTGRES_USER=cognitwin -e POSTGRES_PASSWORD=cognitwin -e POSTGRES_DB=cognitwin postgres:15-alpine

# Option 2: Modify backend to use SQLite (for testing)
# Edit backend/app/config.py and set:
# database_url: str = "sqlite:///./cognitwin.db"
```

2. Start the backend:
```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

3. Test the API:
```bash
# Health check
curl http://localhost:8000/health

# Test analysis endpoint
curl -X POST http://localhost:8000/api/cognitive/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "manual-test-1",
    "avg_dwell_time": 120.0,
    "avg_flight_time": 180.0,
    "pause_count": 3,
    "avg_pause_duration": 2500.0,
    "error_rate": 0.15,
    "correction_rate": 0.12,
    "text_length": 250,
    "sentiment_score": 0.3,
    "word_count": 45
  }'
```

Expected response:
```json
{
  "session_id": "manual-test-1",
  "scores": {
    "cognitive_load": 0.44,
    "mood_drift": 0.31,
    "decision_stability": 0.81,
    "risk_volatility": 0.39
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Test 2: Frontend (Development Mode)

1. Install dependencies:
```bash
cd frontend
npm install
```

2. Create `.env` file:
```bash
echo "VITE_API_URL=http://localhost:8000" > .env
```

3. Start the development server:
```bash
npm run dev
```

4. Open browser to `http://localhost:5173`

5. **Manual UI Test Steps**:
   - Type some text in the textarea
   - Observe keystroke capture (character count updates)
   - Click "Analyze Now" button
   - Verify cognitive metrics appear in the dashboard
   - Check that metrics update automatically every 5 seconds
   - Try different typing patterns:
     - Fast typing → High cognitive load
     - Making errors (backspace) → Higher error rate
     - Pausing for 2+ seconds → Pause tracking
     - Negative words → Lower mood score

### Test 3: Full Docker Compose

1. Start all services:
```bash
docker compose up -d --build
```

2. Wait for services to start (30-60 seconds)

3. Check service status:
```bash
docker compose ps
```

All services should show status "Up":
- cognitwin-db (PostgreSQL)
- cognitwin-backend (FastAPI)
- cognitwin-frontend (React/Vite)

4. View logs:
```bash
# All services
docker compose logs

# Specific service
docker compose logs backend
docker compose logs frontend
```

5. Test the application:
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

6. Stop services:
```bash
docker compose down
```

## Privacy Validation

Verify that privacy requirements are met:

1. **No Raw Keystrokes Stored**
   - Check database - only aggregated metrics should exist
   - Individual keystroke timings are averaged before storage

2. **No Text Content Stored**
   - Only sentiment score (number) is stored, not raw text
   - Word count is stored, but not the actual words

3. **Derived Features Only**
   - Database tables contain only computed metrics
   - See `backend/app/models/cognitive.py` for stored fields

## Performance Tests

### Backend Response Time

```bash
# Install apache-bench if needed
# sudo apt-get install apache2-utils

# Test backend performance
ab -n 100 -c 10 -p test_payload.json -T application/json \
  http://localhost:8000/api/cognitive/analyze
```

Expected: < 100ms per request for cognitive analysis

### Frontend Keystroke Capture

- Keystroke events should be captured in real-time
- No noticeable lag when typing
- Metrics update smoothly without blocking UI

## Troubleshooting

### Backend Issues

1. **Database connection failed**
   - Check PostgreSQL is running: `docker compose ps`
   - Verify DATABASE_URL in backend/.env

2. **Import errors**
   - Ensure all dependencies installed: `pip install -r requirements.txt`
   - Check Python version: `python --version` (3.11+ required)

### Frontend Issues

1. **API connection failed**
   - Check backend is running on port 8000
   - Verify VITE_API_URL in frontend/.env
   - Check CORS settings in backend/app/config.py

2. **Build errors**
   - Delete node_modules: `rm -rf node_modules`
   - Reinstall: `npm install`
   - Clear cache: `npm cache clean --force`

### Docker Issues

1. **Services not starting**
   - Check logs: `docker compose logs`
   - Verify ports not in use: `lsof -i :5173,8000,5432`
   - Rebuild: `docker compose up -d --build --force-recreate`

2. **Database not ready**
   - Wait longer for PostgreSQL to initialize
   - Check health: `docker compose ps`
   - View db logs: `docker compose logs db`

## Success Criteria

✅ Backend tests pass with correct cognitive scores  
✅ API endpoints respond with valid JSON  
✅ Frontend captures keystrokes without lag  
✅ Cognitive metrics display correctly in UI  
✅ Dashboard updates in real-time  
✅ Privacy requirements met (no raw data stored)  
✅ Docker services start and communicate  
✅ All ports accessible (5173, 8000, 5432)  
