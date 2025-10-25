from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import uuid

from ..database import get_db
from ..models.rating import Rating
from ..models.user import User
from ..schemas import RatingCreate, RatingRead
from ..deps import get_current_user

router = APIRouter()


@router.get("/", response_model=List[RatingRead])
def list_ratings(dish_id: uuid.UUID, db: Session = Depends(get_db)):
    rows = db.query(Rating).filter(Rating.dish_id == dish_id).order_by(Rating.created_at.desc()).all()
    return [RatingRead.model_validate(r) for r in rows]


@router.post("/", response_model=RatingRead)
def create_rating(payload: RatingCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    existing = (
        db.query(Rating)
        .filter(Rating.user_id == current_user.id, Rating.dish_id == payload.dish_id)
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="Already rated")
    r = Rating(user_id=current_user.id, dish_id=payload.dish_id, score=payload.score, comment=payload.comment)
    db.add(r)
    db.commit()
    db.refresh(r)
    return RatingRead.model_validate(r)
