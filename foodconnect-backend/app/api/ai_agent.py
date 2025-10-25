from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class Prompt(BaseModel):
    prompt: str


class AIResponse(BaseModel):
    reply: str


@router.post("/chat", response_model=AIResponse)
def chat(payload: Prompt):
    """Placeholder AI endpoint. Integrate an AI provider or local LLM here."""
    return AIResponse(reply=f"AI agent is not configured yet. You said: {payload.prompt}")
