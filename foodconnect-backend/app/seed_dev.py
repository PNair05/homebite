from sqlalchemy.orm import Session
from .database import SessionLocal, Base, engine
from .models.campus import Campus
from .models.user import User, UserRole
from .models.dish import Dish
from .models.dish_image import DishImage
from .models.rating import Rating


def ensure_seed():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()
    try:
        if db.query(Campus).count() == 0:
            campus = Campus(name="Sample Campus", address="123 College Ave")
            db.add(campus)
            db.flush()
        else:
            campus = db.query(Campus).first()
        if db.query(User).count() == 0:
            cook = User(email="cook@example.com", full_name="Campus Cook", role=UserRole.cook)
            buyer = User(email="buyer@example.com", full_name="Hungry Student", role=UserRole.consumer)
            db.add_all([cook, buyer])
            db.flush()
            d1 = Dish(cook_id=cook.id, title="Spaghetti Bolognese", description="Hearty Italian pasta", price=9.99, campus_id=campus.id)
            d2 = Dish(cook_id=cook.id, title="Veggie Curry", description="Spicy and flavorful", price=8.50, campus_id=campus.id)
            db.add_all([d1, d2])
            db.flush()
            db.add(DishImage(dish_id=d1.id, url="https://picsum.photos/seed/spaghetti/600/400", sort_order=0))
            db.add(DishImage(dish_id=d2.id, url="https://picsum.photos/seed/curry/600/400", sort_order=0))
            db.add(Rating(user_id=buyer.id, dish_id=d1.id, score=5, comment="Delicious!"))
        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    ensure_seed()
