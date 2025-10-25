from datetime import datetime
from typing import Optional, List
import uuid

from pydantic import BaseModel, EmailStr, ConfigDict, Field

from .models.order import OrderStatus
from .models.user import UserRole


# Meta
class Campus(BaseModel):
    id: uuid.UUID
    name: str
    address: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# Users/Auth
class UserCreate(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    password: str
    role: UserRole = UserRole.consumer
    campus_id: Optional[uuid.UUID] = None


class UserRead(BaseModel):
    id: uuid.UUID
    email: EmailStr
    full_name: Optional[str] = None
    role: UserRole
    avatar_url: Optional[str] = None
    campus_id: Optional[uuid.UUID] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead


class LoginIn(BaseModel):
    email: EmailStr
    password: str


# Dishes
class DishImageIn(BaseModel):
    url: str
    sort_order: int = 0


class DishCreate(BaseModel):
    title: str
    description: Optional[str] = None
    price: float
    currency: str = "USD"
    available: bool = True
    available_qty: Optional[int] = None
    prep_time_minutes: Optional[int] = None
    pickup_location: Optional[str] = None
    campus_id: Optional[uuid.UUID] = None
    images: List[DishImageIn] = []
    tags: List[str] = []


class DishRead(BaseModel):
    id: uuid.UUID
    cook_id: uuid.UUID
    title: str
    description: Optional[str] = None
    price: float
    currency: str
    available: bool
    available_qty: Optional[int] = None
    prep_time_minutes: Optional[int] = None
    pickup_location: Optional[str] = None
    campus_id: Optional[uuid.UUID] = None
    images: List[str] = []
    tags: List[str] = []
    avg_rating: float = 0
    rating_count: int = 0
    created_at: datetime


# Orders
class OrderItemIn(BaseModel):
    dish_id: uuid.UUID
    quantity: int = Field(1, ge=1)
    special_instructions: Optional[str] = None


class OrderCreate(BaseModel):
    items: List[OrderItemIn]
    scheduled_pickup: Optional[datetime] = None
    pickup_notes: Optional[str] = None
    pickup_location: Optional[str] = None
    currency: str = "USD"


class OrderItemRead(BaseModel):
    id: uuid.UUID
    dish_id: Optional[uuid.UUID] = None
    quantity: int
    unit_price: float
    total_price: float
    special_instructions: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class OrderRead(BaseModel):
    id: uuid.UUID
    buyer_id: uuid.UUID
    cook_id: Optional[uuid.UUID] = None
    status: OrderStatus
    total: float
    currency: str
    scheduled_pickup: Optional[datetime] = None
    pickup_notes: Optional[str] = None
    pickup_location: Optional[str] = None
    items: List[OrderItemRead] = []
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class OrderScheduleUpdate(BaseModel):
    scheduled_pickup: datetime
    pickup_notes: Optional[str] = None
    pickup_location: Optional[str] = None


# Ratings
class RatingCreate(BaseModel):
    dish_id: uuid.UUID
    score: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None


class RatingRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    dish_id: uuid.UUID
    score: int
    comment: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# Recipes
class RecipeCreate(BaseModel):
    title: str
    description: Optional[str] = None
    ingredients: List[str]
    steps: List[str]


class RecipeRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    description: Optional[str] = None
    ingredients: List[str]
    steps: List[str]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
