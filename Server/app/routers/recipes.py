from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from .. import models, schemas, crud
from ..database import SessionLocal
from app.routers.users import get_current_user, get_db

router = APIRouter(prefix="/api/lutome/recipes", tags=["recipes"])

@router.post("/", response_model=schemas.RecipeOut)
def create_recipe(recipe: schemas.RecipeCreate = Body(...), db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    return crud.create_recipe(db, recipe, user_id=current_user.id)

@router.get("/", response_model=List[schemas.RecipeOut])
def list_recipes(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return crud.get_recipes(db, skip=skip, limit=limit)

@router.get("/{recipe_id}", response_model=schemas.RecipeOut)
def get_recipe(recipe_id: UUID, db: Session = Depends(get_db)):
    db_recipe = crud.get_recipe(db, recipe_id)
    if not db_recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return db_recipe

@router.get("/recommendations", response_model=List[schemas.RecipeOut])
def get_recommendations(user_id: UUID, db: Session = Depends(get_db)):
    return crud.get_recommendations(db, user_id=user_id)

@router.post("/ai_suggest")
def ai_suggest(prompt: str = Body(..., embed=True)):
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")
    return {"suggestion": response} 