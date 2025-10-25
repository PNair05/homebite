from functools import lru_cache
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "FoodConnect Backend"
    debug: bool = True
    database_url: str = "sqlite:///./app.db"
    secret_key: str = "change-me"
    openai_api_key: Optional[str] = None

    # Environment variables will be prefixed with FC_
    # e.g., FC_DATABASE_URL, FC_DEBUG, FC_OPENAI_API_KEY
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="FC_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
