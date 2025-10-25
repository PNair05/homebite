from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from ..database import Base


class DishTag(Base):
    __tablename__ = "dish_tags"

    dish_id = Column(UUID(as_uuid=True), ForeignKey("dishes.id", ondelete="CASCADE"), primary_key=True)
    tag_id = Column(UUID(as_uuid=True), ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True)
