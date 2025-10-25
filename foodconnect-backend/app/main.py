from fastapi import FastAPI

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

    @app.get("/healthz")
    def healthcheck():
        return {"status": "ok"}

    return app


app = create_app()
