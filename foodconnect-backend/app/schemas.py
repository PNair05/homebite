from datetime import datetime
from decimal import Decimal
from typing import Optional, List

from pydantic import BaseModel, EmailStr, ConfigDict


# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserRead(UserBase):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# Dish Schemas
class DishBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: Decimal


class DishCreate(DishBase):
    created_by: int


class DishRead(DishBase):
    id: int
    created_at: datetime
    created_by: int

    model_config = ConfigDict(from_attributes=True)


# Order Schemas
class OrderBase(BaseModel):
    status: Optional[str] = "pending"


class OrderCreate(OrderBase):
    user_id: Optional[int] = None


class OrderRead(OrderBase):
    id: int
    user_id: Optional[int] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
