from fastapi import APIRouter

from . import users, dishes, ai_agent, auth, orders, ratings, meta, recipes

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(dishes.router, prefix="/dishes", tags=["dishes"])
api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
api_router.include_router(ratings.router, prefix="/ratings", tags=["ratings"])
api_router.include_router(meta.router, prefix="", tags=["meta"])
api_router.include_router(ai_agent.router, prefix="/ai", tags=["ai"])
api_router.include_router(recipes.router, prefix="/recipes", tags=["recipes"])
