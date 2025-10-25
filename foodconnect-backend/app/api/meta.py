from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.campus import Campus
from ..models.tag import Tag
from ..schemas import Campus as CampusSchema

router = APIRouter()


@router.get("/campuses", response_model=list[CampusSchema])
def list_campuses(db: Session = Depends(get_db)):
    return db.query(Campus).order_by(Campus.name).all()


@router.get("/tags", response_model=list[str])
def list_tags(db: Session = Depends(get_db)):
    return [t.name for t in db.query(Tag).order_by(Tag.name).all()]
