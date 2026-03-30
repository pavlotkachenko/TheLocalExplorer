# The Local Explorer API

FastAPI backend serving restaurant data for The Local Explorer iOS app.

## Setup

```bash
pip install poetry
poetry install
```

## Run Locally

```bash
poetry run uvicorn app.main:app --port 8001 --reload
```

API docs available at: http://localhost:8001/docs

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /healthz | Health check |
| GET | /api/v1/drops/today | Today's editorial drops |
| GET | /api/v1/spots/nearby | Nearby spots by location |
| GET | /api/v1/spots/search | Search spots |
| GET | /api/v1/spots/{id} | Spot details |
| POST | /api/v1/polls | Create a poll |
| GET | /api/v1/polls | List active polls |
| GET | /api/v1/polls/{id} | Get poll details |
| POST | /api/v1/polls/{id}/vote | Vote on a poll |
| GET | /api/v1/collections | List saved collections |
| POST | /api/v1/collections/{name}/spots | Save spot to collection |
| DELETE | /api/v1/collections/{name}/spots/{id} | Remove spot |
| GET | /polls/{id} | Poll web view (for Telegram sharing) |

## Deployment

Deploy to any platform that supports Python/FastAPI. Update the `baseURL` in `TheLocalExplorer/Core/Services/APIService.swift` with your deployed URL.
