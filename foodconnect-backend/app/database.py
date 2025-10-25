import atexit
from typing import Optional
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

from .config import get_settings


settings = get_settings()
Base = declarative_base()

engine = None
SessionLocal = None

def _build_engine():
    """Build a SQLAlchemy engine either from DATABASE_URL or Cloud SQL connector settings."""
    global engine, SessionLocal
    # Prefer Cloud SQL connector if configured
    if settings.cloudsql_instance and settings.db_user and settings.db_name:
        # Lazy import to avoid dependency if unused
        from google.cloud.sql.connector import Connector

        connector = Connector()

        def getconn():
            return connector.connect(
                settings.cloudsql_instance,
                driver="pg8000",
                user=settings.db_user,
                password=settings.db_password or "",
                db=settings.db_name,
            )

        # Ensure connector is closed on exit
        atexit.register(lambda: connector.close())

        engine = create_engine(
            "postgresql+pg8000://",
            creator=getconn,
            pool_pre_ping=True,
            future=True,
        )
    else:
        # Fallback to standard SQLAlchemy URL (e.g., SQLite, TCP Postgres, Cloud SQL Proxy)
        connect_args = {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}
        engine = create_engine(settings.database_url, echo=False, future=True, connect_args=connect_args, pool_pre_ping=True)

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


_build_engine()


def get_db():
    """FastAPI dependency that yields a DB session and ensures it's closed."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
