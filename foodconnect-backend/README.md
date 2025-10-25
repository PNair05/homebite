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

Set the database to PostgreSQL to match production and the UUID schema:

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

## Using Cloud SQL (two options)

- Install (macOS):

```bash
brew install cloud-sql-proxy
```

- Start the proxy (TCP, localhost:5432):

```bash
cloud-sql-proxy PROJECT:REGION:INSTANCE --port 5432
```

Then set `FC_DATABASE_URL` as shown above for TCP.

### Direct connector (no proxy)

Alternatively, you can connect without a proxy using the Cloud SQL Python Connector (already included in requirements):

```bash
export FC_CLOUDSQL_INSTANCE="PROJECT:REGION:INSTANCE"
export FC_DB_USER="db_user"
export FC_DB_PASSWORD="db_password"   # optional if using IAM auth
export FC_DB_NAME="db_name"
```

Ensure your environment has Google credentials with Cloud SQL Client role (e.g., set `GOOGLE_APPLICATION_CREDENTIALS=/path/key.json` or run on GCP with a suitable service account). When `FC_CLOUDSQL_INSTANCE` is set, the app will use the connector automatically.

## Migrations

Tables are auto-created on startup for development. For production, use Alembic migrations.

If you previously ran with SQLite, the new UUID-based schema won't match prior tables. Point `FC_DATABASE_URL` to a fresh PostgreSQL database (recommended) or remove `app.db` to recreate.

## Environment variables

- `FC_APP_NAME` — app title
- `FC_DEBUG` — enable FastAPI debug
- `FC_DATABASE_URL` — SQLAlchemy database URL
- `FC_OPENAI_API_KEY` — optional, for AI integrations
- `FC_GOOGLE_API_KEY` — Google Gemini API key for AI features
- `FC_CLOUDSQL_INSTANCE` — optional Cloud SQL instance string `PROJECT:REGION:INSTANCE` (enables direct connector)
- `FC_DB_USER`, `FC_DB_PASSWORD`, `FC_DB_NAME` — DB credentials for the connector

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
