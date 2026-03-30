# Testing The Local Explorer Backend API

## Overview
The backend is a FastAPI app at `backend/app/main.py` with 12 API endpoints + healthz, using in-memory data stores (dicts/lists). Data resets on server restart.

## Prerequisites
- Python 3.12+
- Poetry installed

## Starting the Backend
```bash
cd backend
poetry install
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8001
```

**Common Issue:** If `poetry install` fails with "pyproject.toml changed significantly since poetry.lock was last generated", run `poetry lock --no-update` first, then `poetry install`. This can happen after dependency changes.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/healthz` | Health check |
| GET | `/api/v1/drops/today` | Today's editorial drops |
| GET | `/api/v1/spots/nearby` | Nearby spots (params: lat, lng, radius) |
| GET | `/api/v1/spots/search` | Search spots (params: q, cuisine, price, vibe) |
| GET | `/api/v1/spots/{id}` | Spot details |
| POST | `/api/v1/polls` | Create poll (body: title, spot_ids, duration_minutes) |
| GET | `/api/v1/polls` | List active polls |
| GET | `/api/v1/polls/{id}` | Get poll details |
| POST | `/api/v1/polls/{id}/vote` | Vote on poll (body: option_id, voter_name) |
| GET | `/api/v1/collections` | List saved collections |
| POST | `/api/v1/collections/{name}/spots` | Save spot (body: spot_id) |
| DELETE | `/api/v1/collections/{name}/spots/{id}` | Remove spot |
| GET | `/polls/{id}` | Poll web view (HTML for Telegram sharing) |

## Seed Data
- **15 restaurants** (spot-1 through spot-15) with Manhattan locations
- **3 editorial drops** (1 hero + 2 additional)
- **3 seed collections**: favorites, want_to_go, client_lunch (each with 3 spots)
- **Default coordinates**: lat=40.7484, lng=-73.9857 (Midtown Manhattan)

## Testing Tips

### Collections have seed data
The `favorites`, `want_to_go`, and `client_lunch` collections are pre-populated. When testing save/remove operations, account for existing spots in assertions.

### Poll lifecycle testing
Best tested as a sequence: create poll → vote multiple times → verify percentages → check web view → verify in active list. Use the poll ID and option IDs from the create response in subsequent calls.

### Walking time formula
The formula is `max(1, round(miles / 0.05))` which assumes ~3 mph walking speed. This might produce values that seem high for short distances.

### Search filtering
- `q` parameter matches against spot name OR cuisine (case-insensitive)
- `cuisine` matches against cuisine field only
- `vibe` matches against any vibe in the vibes array
- `price` filters spots with price_level <= value

### Error responses
All 404 errors return JSON `{"detail": "..."}` except the poll web view which returns styled HTML.

## Devin Secrets Needed
None - the backend runs locally without any API keys or secrets.

## What Cannot Be Tested on Linux
- iOS app UI (requires Xcode on macOS)
- Google Maps SDK integration (requires iOS build + API key)
- Telegram sharing (requires iOS share sheet)
- SwiftUI compilation (no Swift toolchain configured for iOS targets)
