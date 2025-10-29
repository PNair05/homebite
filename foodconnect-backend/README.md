# FoodConnect Backend

FastAPI backend scaffold with SQLAlchemy and Pydantic. This guide explains how to switch from the default SQLite DB to PostgreSQL on Cloud SQL.

## Quick start

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./run.sh
```

- Docs: http://localhost:8000/docs
- Health check: http://localhost:8000/healthz

### Recommended (PostgreSQL)

Point the backend at PostgreSQL (AWS RDS is recommended for production):

```bash
export FC_DATABASE_URL="postgresql+psycopg://postgres:postgres@localhost:5432/homebite"
export FC_SECRET_KEY="change-me"
export FC_GOOGLE_API_KEY="<YOUR_GOOGLE_GEMINI_API_KEY>"
./run.sh
```

## Configure the Database

Settings are loaded from environment variables with the `FC_` prefix and `.env` file support. The default is SQLite at `sqlite:///./app.db`.

1. Create your `.env` from the example:

```bash
cp .env.example .env
```

2. Set `FC_DATABASE_URL` to your connection string.

### PostgreSQL (psycopg3) URL formats

- Direct TCP (public or private IP):

```
FC_DATABASE_URL=postgresql+psycopg://USER:PASSWORD@HOST:PORT/DBNAME
```

- Cloud SQL Auth Proxy (TCP on localhost):

```
FC_DATABASE_URL=postgresql+psycopg://USER:PASSWORD@127.0.0.1:5432/DBNAME
```

- Cloud SQL Auth Proxy (Unix socket):

```
FC_DATABASE_URL=postgresql+psycopg://USER:PASSWORD@/DBNAME?host=/cloudsql/PROJECT:REGION:INSTANCE
```

Note: We installed `psycopg[binary]` for convenience in development. For production, consider using the standard `psycopg` with system libpq and SSL certificates as needed.

## AWS RDS (PostgreSQL)

Use the standard Postgres URL to connect to your RDS instance (public or private endpoint).

```bash
export FC_DATABASE_URL="postgresql+psycopg://<USER>:<ENCODED_PASS>@<RDS_ENDPOINT>:5432/<DB_NAME>"
./run.sh
```

Notes:

- If your password contains special characters, URL-encode it in the URL.
- For private endpoints, run the API where it can reach the RDS network (VPC, VPN, or SSH tunnel).
- For SSL, psycopg `sslmode=require` is default on many hosts; you can append `?sslmode=require` if needed.

Optional (IAM auth):

- You can generate short-lived auth tokens using AWS IAM (requires adding `boto3` and a small hook). For now, prefer a standard DB password for simplicity.

Quickstart for this project (Connector, macOS/zsh):

```bash
# 1) Activate your virtualenv in foodconnect-backend/
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 2) Provide credentials (pick one)
# a) Service account key
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
# b) Or user ADC
gcloud auth application-default login

# 3) Set Cloud SQL connector env vars (instance: tamu-hackathon25cll-546:us-central1:homebite-tidal-f25)
export FC_CLOUDSQL_INSTANCE="tamu-hackathon25cll-546:us-central1:homebite-tidal-f25"
export FC_DB_USER="postgres"
export FC_DB_PASSWORD="<your-postgres-password>"   # plain (do NOT URL-encode here)
export FC_DB_NAME="postgres"

# 4) Run the API
./run.sh

# Health check
# open http://localhost:8000/healthz
```

## Migrations

Tables are auto-created on startup for development. For production, use Alembic migrations.

If you previously ran with SQLite, the new UUID-based schema won't match prior tables. Point `FC_DATABASE_URL` to a fresh PostgreSQL database (recommended) or remove `app.db` to recreate.

## Environment variables

- `FC_APP_NAME` — app title
- `FC_DEBUG` — enable FastAPI debug
- `FC_DATABASE_URL` — SQLAlchemy database URL
- `FC_OPENAI_API_KEY` — optional, for AI integrations
- `FC_GOOGLE_API_KEY` — Google Gemini API key for AI features

## API surface (used by iOS app)

- Auth
  - POST `/api/auth/signup` -> TokenOut
  - POST `/api/auth/login` -> TokenOut
  - GET `/api/auth/me` -> User
- Dishes
  - GET `/api/dishes` -> [Dish]
  - GET `/api/dishes/{id}` -> Dish
  - POST `/api/dishes` (Bearer) -> Dish
- Orders
  - GET `/api/orders?as=buyer|cook` (Bearer) -> [Order]
  - POST `/api/orders` (Bearer) -> Order
- Ratings
  - GET `/api/ratings?dish_id=...` -> [Rating]
  - POST `/api/ratings` (Bearer) -> Rating
- Meta
  - GET `/api/campuses` -> [Campus]
  - GET `/api/tags` -> [String]
- AI
  - POST `/api/ai/suggest-tags` (Bearer) -> [String]
    - body: `{ "text": string, "max_tags": number }`
  - POST `/api/ai/pantry-recipe` (Bearer) -> `{ title, ingredients[], steps[] }`
- Recipes
  - POST `/api/recipes` (Bearer) -> save recipe
  - GET `/api/recipes/me` (Bearer) -> list my recipes
