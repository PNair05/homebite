from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List, Literal
import uuid

from ..database import get_db
from ..models.order import Order, OrderStatus
from ..models.order_item import OrderItem
from ..models.dish import Dish
from ..models.user import User
from ..schemas import OrderCreate, OrderRead, OrderItemRead
from ..deps import get_current_user

router = APIRouter()


@router.get("/", response_model=List[OrderRead])
def list_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    as_: Literal["buyer", "cook"] = Query("buyer", alias="as"),
    status: Optional[OrderStatus] = None,
    limit: int = 50,
    offset: int = 0,
):
    query = db.query(Order)
    if as_ == "buyer":
        query = query.filter(Order.buyer_id == current_user.id)
    else:
        query = query.filter(Order.cook_id == current_user.id)
    if status:
        query = query.filter(Order.status == status)
    rows = query.order_by(Order.created_at.desc()).limit(limit).offset(offset).all()
    return [get_order(o.id, db, current_user) for o in rows]


@router.get("/{order_id}", response_model=OrderRead)
def get_order(order_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    o = db.query(Order).filter(Order.id == order_id).first()
    if not o:
        raise HTTPException(status_code=404, detail="Order not found")
    items = db.query(OrderItem).filter(OrderItem.order_id == o.id).all()
    return OrderRead(
        id=o.id,
        buyer_id=o.buyer_id,
        cook_id=o.cook_id,
        status=o.status,
        total=float(o.total),
        currency=o.currency,
        scheduled_pickup=o.scheduled_pickup,
        pickup_notes=o.pickup_notes,
        pickup_location=o.pickup_location,
        items=[OrderItemRead.model_validate(i) for i in items],
        created_at=o.created_at,
    )


@router.post("/", response_model=OrderRead)
def create_order(payload: OrderCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not payload.items:
        raise HTTPException(status_code=400, detail="Empty order")
    first_dish = db.query(Dish).filter(Dish.id == payload.items[0].dish_id).first()
    if not first_dish:
        raise HTTPException(status_code=404, detail="Dish not found")
    order = Order(
        buyer_id=current_user.id,
        cook_id=first_dish.cook_id,
        status=OrderStatus.pending,
        currency=payload.currency,
        scheduled_pickup=payload.scheduled_pickup,
        pickup_notes=payload.pickup_notes,
        pickup_location=payload.pickup_location or first_dish.pickup_location,
    )
    db.add(order)
    db.flush()
    total = 0.0
    for item in payload.items:
        dish = db.query(Dish).filter(Dish.id == item.dish_id).first()
        if not dish:
            raise HTTPException(status_code=404, detail=f"Dish {item.dish_id} not found")
        qty = max(1, item.quantity or 1)
        unit_price = float(dish.price)
        line_total = qty * unit_price
        total += line_total
        db.add(
            OrderItem(
                order_id=order.id,
                dish_id=dish.id,
                quantity=qty,
                unit_price=unit_price,
                total_price=line_total,
                special_instructions=item.special_instructions,
            )
        )
    order.total = total
    db.commit()
    return get_order(order.id, db, current_user)
