# Contributing to CogniTwin

## Local dev

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Tests
Backend smoke:
```bash
cd backend
python test_api.py
```

Frontend:
```bash
cd frontend
npm test
```

## Migrations
```bash
cd backend
alembic revision --autogenerate -m "change"
alembic upgrade head
```
