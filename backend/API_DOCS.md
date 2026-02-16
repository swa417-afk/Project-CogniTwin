# CogniTwin API Docs

## Run (Docker)
From repo root:
```bash
docker compose up --build
```

Backend:
- API: `http://localhost:8000`
- Docs: `http://localhost:8000/docs`
- OpenAPI: `http://localhost:8000/openapi.json`

## Run (Local)
From `backend/`:
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Health
```bash
curl http://localhost:8000/health
```

## Seed demo data
```bash
python -m app.seed
```

## Migrations (Alembic)
Ensure DATABASE_URL is set (or uses backend/.env):
```bash
alembic revision --autogenerate -m "init"
alembic upgrade head
```
