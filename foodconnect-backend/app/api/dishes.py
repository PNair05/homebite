from typing import List, Optional
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import select, func

from ..database import get_db
from ..models.dish import Dish
from ..models.dish_image import DishImage
from ..models.tag import Tag
from ..models.dish_tag import DishTag
from ..models.user import User
from ..models.rating import Rating
from ..schemas import DishCreate, DishRead
from ..deps import get_current_user


router = APIRouter()


def _collect_images_and_tags(db: Session, dish_ids: list[uuid.UUID]):
    images_map: dict[uuid.UUID, list[str]] = {d: [] for d in dish_ids}
    tags_map: dict[uuid.UUID, list[str]] = {d: [] for d in dish_ids}
    if not dish_ids:
        return images_map, tags_map
    for di in db.query(DishImage).filter(DishImage.dish_id.in_(dish_ids)).order_by(DishImage.sort_order).all():
        images_map[di.dish_id].append(di.url)
    # tags join
    q = (
        db.query(DishTag.dish_id, Tag.name)
        .join(Tag, Tag.id == DishTag.tag_id)
        .filter(DishTag.dish_id.in_(dish_ids))
        .order_by(Tag.name)
        .all()
    )
    for d_id, name in q:
        tags_map[d_id].append(name)
    return images_map, tags_map


def _collect_rating_stats(db: Session, dish_ids: list[uuid.UUID]):
    avg_map: dict[uuid.UUID, float] = {d: 0.0 for d in dish_ids}
    cnt_map: dict[uuid.UUID, int] = {d: 0 for d in dish_ids}
    if not dish_ids:
        return avg_map, cnt_map
    rows = (
        db.query(Rating.dish_id, func.avg(Rating.score), func.count(Rating.id))
        .filter(Rating.dish_id.in_(dish_ids))
        .group_by(Rating.dish_id)
        .all()
    )
    for d_id, avg_, cnt in rows:
        avg_map[d_id] = float(avg_ or 0)
        cnt_map[d_id] = int(cnt or 0)
    return avg_map, cnt_map


@router.get("/", response_model=List[DishRead])
def list_dishes(
    db: Session = Depends(get_db),
    campus_id: Optional[uuid.UUID] = None,
    q: Optional[str] = None,
    tags: Optional[str] = Query(None, description="comma-separated tags"),
    limit: int = 50,
    offset: int = 0,
):
    query = db.query(Dish).filter(Dish.available.is_(True))
    if campus_id:
        query = query.filter(Dish.campus_id == campus_id)
    if q:
        like = f"%{q.lower()}%"
        query = query.filter((Dish.title.ilike(like)) | (Dish.description.ilike(like)))
    rows = query.order_by(Dish.created_at.desc()).limit(limit).offset(offset).all()
    ids = [r.id for r in rows]
    images_map, tags_map = _collect_images_and_tags(db, ids)
    avg_map, cnt_map = _collect_rating_stats(db, ids)
    requested_tags = [t.strip().lower() for t in (tags.split(",") if tags else []) if t.strip()]
    out: list[DishRead] = []
    for d in rows:
        current_tags = tags_map.get(d.id, [])
        if requested_tags and not set(requested_tags).issubset({t.lower() for t in current_tags}):
            continue
        out.append(
            DishRead(
                id=d.id,
                cook_id=d.cook_id,
                title=d.title,
                description=d.description,
                price=float(d.price),
                currency=d.currency,
                available=d.available,
                available_qty=d.available_qty,
                prep_time_minutes=d.prep_time_minutes,
                pickup_location=d.pickup_location,
                campus_id=d.campus_id,
                images=images_map.get(d.id, []),
                tags=current_tags,
                avg_rating=avg_map.get(d.id, 0.0),
                rating_count=cnt_map.get(d.id, 0),
                created_at=d.created_at,
            )
        )
    return out


@router.get("/{dish_id}", response_model=DishRead)
def get_dish(dish_id: uuid.UUID, db: Session = Depends(get_db)):
    d = db.query(Dish).filter(Dish.id == dish_id).first()
    if not d:
        raise HTTPException(status_code=404, detail="Dish not found")
    imgs, tmap = _collect_images_and_tags(db, [d.id])
    avg_map, cnt_map = _collect_rating_stats(db, [d.id])
    return DishRead(
        id=d.id,
        cook_id=d.cook_id,
        title=d.title,
        description=d.description,
        price=float(d.price),
        currency=d.currency,
        available=d.available,
        available_qty=d.available_qty,
        prep_time_minutes=d.prep_time_minutes,
        pickup_location=d.pickup_location,
        campus_id=d.campus_id,
        images=imgs.get(d.id, []),
        tags=tmap.get(d.id, []),
        avg_rating=avg_map.get(d.id, 0.0),
        rating_count=cnt_map.get(d.id, 0),
        created_at=d.created_at,
    )


@router.post("/", response_model=DishRead, status_code=status.HTTP_201_CREATED)
def create_dish(payload: DishCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    d = Dish(
        cook_id=current_user.id,
        title=payload.title,
        description=payload.description,
        price=payload.price,
        currency=payload.currency,
        available=payload.available,
        available_qty=payload.available_qty,
        prep_time_minutes=payload.prep_time_minutes,
        pickup_location=payload.pickup_location,
        campus_id=payload.campus_id or current_user.campus_id,
    )
    db.add(d)
    db.flush()

    # images
    for i, img in enumerate(payload.images):
        db.add(DishImage(dish_id=d.id, url=img.url, sort_order=img.sort_order or i))

    # tags
    tag_names = [t.strip() for t in payload.tags if t.strip()]
    if tag_names:
        existing = db.query(Tag).filter(Tag.name.in_(tag_names)).all()
        tag_map = {t.name: t for t in existing}
        for name in tag_names:
            tag = tag_map.get(name)
            if not tag:
                tag = Tag(name=name)
                db.add(tag)
                db.flush()
                tag_map[name] = tag
            db.add(DishTag(dish_id=d.id, tag_id=tag.id))

    db.commit()
    return get_dish(d.id, db)
