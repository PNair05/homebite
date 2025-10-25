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

## Using Cloud SQL Auth Proxy (optional but recommended for local dev)

- Install (macOS):

```bash
brew install cloud-sql-proxy
```

- Start the proxy (TCP, localhost:5432):

```bash
cloud-sql-proxy PROJECT:REGION:INSTANCE --port 5432
```

Then set `FC_DATABASE_URL` as shown above for TCP.

## Migrations

Tables are auto-created on startup for development. For production, use Alembic migrations.

## Environment variables

- `FC_APP_NAME` — app title
- `FC_DEBUG` — enable FastAPI debug
- `FC_DATABASE_URL` — SQLAlchemy database URL
- `FC_OPENAI_API_KEY` — optional, for AI integrations
