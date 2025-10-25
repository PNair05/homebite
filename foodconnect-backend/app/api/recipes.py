from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import json

from ..database import get_db
from ..deps import get_current_user
from ..models.user import User
from ..models.recipe import Recipe
from ..schemas import RecipeCreate, RecipeRead

router = APIRouter()


@router.post("/", response_model=RecipeRead)
def create_recipe(payload: RecipeCreate, db: Session = Depends(get_db), current: User = Depends(get_current_user)):
    r = Recipe(
        user_id=current.id,
        title=payload.title,
        description=payload.description,
        ingredients_json=json.dumps(payload.ingredients),
        steps_json=json.dumps(payload.steps),
    )
    db.add(r)
    db.commit()
    db.refresh(r)
    return RecipeRead(
        id=r.id,
        user_id=r.user_id,
        title=r.title,
        description=r.description,
        ingredients=json.loads(r.ingredients_json or "[]"),
        steps=json.loads(r.steps_json or "[]"),
        created_at=r.created_at,
    )


@router.get("/me", response_model=list[RecipeRead])
def list_my_recipes(db: Session = Depends(get_db), current: User = Depends(get_current_user)):
    rows = db.query(Recipe).filter(Recipe.user_id == current.id).order_by(Recipe.created_at.desc()).all()
    out = []
    for r in rows:
        out.append(
            RecipeRead(
                id=r.id,
                user_id=r.user_id,
                title=r.title,
                description=r.description,
                ingredients=json.loads(r.ingredients_json or "[]"),
                steps=json.loads(r.steps_json or "[]"),
                created_at=r.created_at,
            )
        )
    return out
