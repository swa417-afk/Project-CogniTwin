# Deployment

## Docker (recommended)
```bash
docker compose up --build
```

## Environment
- Backend reads `DATABASE_URL` from environment (see `backend/.env.example`)
- Frontend reads API base URL from Vite env vars if used

## Health check
- Backend: `/health`
