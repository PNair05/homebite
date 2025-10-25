from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db, Base, engine
from ..models.dish import Dish
from ..models.user import User
from ..schemas import DishCreate, DishRead


router = APIRouter()

# Ensure tables exist (use Alembic for production scenarios)
Base.metadata.create_all(bind=engine)


@router.post("/", response_model=DishRead, status_code=status.HTTP_201_CREATED)
def create_dish(dish_in: DishCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == dish_in.created_by).first()
    if not user:
        raise HTTPException(status_code=404, detail="Creator user not found")

    dish = Dish(
        name=dish_in.name,
        description=dish_in.description,
        price=dish_in.price,
        created_by=dish_in.created_by,
    )
    db.add(dish)
    db.commit()
    db.refresh(dish)
    return dish


@router.get("/", response_model=List[DishRead])
def list_dishes(db: Session = Depends(get_db)):
    return db.query(Dish).order_by(Dish.id.desc()).all()
