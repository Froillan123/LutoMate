from fastapi import APIRouter, Depends, HTTPException, Body, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from .. import models, schemas, crud
from ..database import SessionLocal
from app.routers.users import get_current_user, get_db

router = APIRouter(prefix="/api/lutome/recipes", tags=["recipes"])

# AI endpoints FIRST
@router.get("/ai_dishes")
def ai_dishes(category: str = Query(None, description="Food category")):
    print(f"[ai_dishes] Received category: {category!r}")
    if not category or not category.strip():
        raise HTTPException(status_code=400, detail="Category is required")
    prompt = f"Give me a list of 20 popular dishes or recipes for the category '{category}'. Only return the dish names as a numbered list."
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")
    # Parse Gemini's response into a list
    dishes = []
    for line in response.split('\n'):
        line = line.strip()
        if line and (line[0].isdigit() or line.startswith('-')):
            # Remove number or dash
            name = line.split('.', 1)[-1].strip() if '.' in line else line.lstrip('-').strip()
            if name:
                dishes.append(name)
    if not dishes:
        # fallback: just split lines
        dishes = [l.strip() for l in response.split('\n') if l.strip()]
    return {"dishes": dishes}

@router.get("/ai_ingredients")
def ai_ingredients(dish: str = Query(None, description="Dish name")):
    print(f"[ai_ingredients] Received dish: {dish!r}")
    if not dish or not dish.strip():
        raise HTTPException(status_code=400, detail="Dish is required")
    # Ask Gemini for ingredients, steps, and a reference link
    prompt = (
        f"For the dish '{dish}', provide:\n"
        f"1. A bullet list of main ingredients.\n"
        f"2. Step-by-step instructions on how to cook it.\n"
        f"3. A reference link to a recipe or article about it.\n"
        f"Format:\n"
        f"Ingredients:\n- ...\nSteps:\n1. ...\nReference: <link>"
    )
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")

    # Parse Gemini's response
    ingredients, steps, reference = [], [], ""
    section = None
    for line in response.split('\n'):
        line = line.strip()
        if line.lower().startswith("ingredients"):
            section = "ingredients"
            continue
        if line.lower().startswith("steps"):
            section = "steps"
            continue
        if line.lower().startswith("reference"):
            section = "reference"
            reference = line.split(":", 1)[-1].strip()
            continue
        if section == "ingredients" and (line.startswith("-") or line.startswith("*")):
            name = line.lstrip("-* ").strip()
            if name:
                ingredients.append(name)
        elif section == "steps" and (line[:1].isdigit() or line.startswith("-")):
            step = line.split(".", 1)[-1].strip() if "." in line else line.lstrip("-").strip()
            if step:
                steps.append(step)

    # Fetch Unsplash images for each ingredient
    ingredient_objs = []
    from ..crud import fetch_unsplash_image
    for ing in ingredients:
        img = fetch_unsplash_image(ing)
        ingredient_objs.append({"name": ing, "image": img})

    return {
        "ingredients": ingredient_objs,
        "steps": steps,
        "reference": reference
    }

@router.post("/ai_suggest")
def ai_suggest(prompt: str = Body(..., embed=True)):
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")
    return {"suggestion": response}

# THEN the dynamic path routes
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