from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import api_router
from .database import Base, engine
from .config import get_settings


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, debug=settings.debug)

    # Create tables on startup (for dev). Use migrations in production.
    Base.metadata.create_all(bind=engine)

    # Mount API routers
    app.include_router(api_router, prefix="/api")

    # CORS for development (iOS simulator / web clients)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            "http://localhost",
            "http://127.0.0.1",
            "http://localhost:5173",
            "http://localhost:3000",
            "http://localhost:8000",
        ],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/healthz")
    def healthcheck():
        return {"status": "ok"}

    return app


app = create_app()
