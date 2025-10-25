from fastapi import APIRouter

from . import users, dishes, ai_agent

api_router = APIRouter()
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(dishes.router, prefix="/dishes", tags=["dishes"])
api_router.include_router(ai_agent.router, prefix="/ai", tags=["ai"])
