import uuid
from sqlalchemy import Column, Text, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from ..database import Base


class DishImage(Base):
    __tablename__ = "dish_images"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    dish_id = Column(UUID(as_uuid=True), ForeignKey("dishes.id", ondelete="CASCADE"), nullable=False)
    url = Column(Text, nullable=False)
    sort_order = Column(Integer, default=0)
