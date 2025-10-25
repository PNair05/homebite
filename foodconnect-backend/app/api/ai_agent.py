from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List

from ..deps import get_current_user
from ..models.user import User
from ..services.ai import suggest_tags_from_text, recipe_from_pantry

router = APIRouter()


class Prompt(BaseModel):
    prompt: str


class AIResponse(BaseModel):
    reply: str


@router.post("/chat", response_model=AIResponse)
def chat(payload: Prompt):
    return AIResponse(reply=f"AI agent is not configured yet. You said: {payload.prompt}")


class SuggestTagsIn(BaseModel):
    text: str
    max_tags: int | None = 8


@router.post("/suggest-tags", response_model=List[str])
def suggest_tags(payload: SuggestTagsIn, current: User = Depends(get_current_user)):
    try:
        return suggest_tags_from_text(payload.text, max_tags=payload.max_tags or 8)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class PantryRecipeIn(BaseModel):
    images_base64: List[str]
    pantry: List[str] = []


class PantryRecipeOut(BaseModel):
    title: str
    ingredients: List[str]
    steps: List[str]


@router.post("/pantry-recipe", response_model=PantryRecipeOut)
def pantry_recipe(payload: PantryRecipeIn, current: User = Depends(get_current_user)):
    try:
        res = recipe_from_pantry(payload.images_base64, payload.pantry)
        return PantryRecipeOut(**res)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
