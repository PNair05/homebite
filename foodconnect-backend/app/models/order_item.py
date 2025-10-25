import uuid
from sqlalchemy import Column, Integer, Numeric, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from ..database import Base


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id = Column(UUID(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    dish_id = Column(UUID(as_uuid=True), ForeignKey("dishes.id", ondelete="SET NULL"), nullable=True)
    quantity = Column(Integer, nullable=False, default=1)
    unit_price = Column(Numeric(10, 2), nullable=False, default=0.00)
    total_price = Column(Numeric(12, 2), nullable=False, default=0.00)
    special_instructions = Column(Text, nullable=True)
