from fastapi import APIRouter, Depends, HTTPException, Body, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List
import re

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
    prompt = f"Give me a list of 10 popular dishes or recipes for the category '{category}'. Only return the dish names as a numbered list."
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
def ai_ingredients(dish: str = Query(None, description="Dish name"), db: Session = Depends(get_db)):
    print(f"[ai_ingredients] Received dish: {dish!r}")
    if not dish or not dish.strip():
        raise HTTPException(status_code=400, detail="Dish is required")
    # 1. Check if recipe is already cached in DB
    db_recipe = db.query(models.Recipe).filter(models.Recipe.title.ilike(dish)).first()
    if db_recipe and db_recipe.ingredients and db_recipe.steps:
        return {
            "ingredients": db_recipe.ingredients.split('\n'),
            "steps": db_recipe.steps.split('\n'),
            "reference": getattr(db_recipe, 'reference', '')
        }
    # 2. If not, call Gemini
    prompt = (
        f"For the dish '{dish}', provide:\n"
        f"1. A bullet list of main ingredients.\n"
        f"2. Step-by-step instructions on how to cook it.\n"
        f"3. A YouTube video link or recipe website link for this dish.\n"
        f"Format:\n"
        f"Ingredients:\n- ...\nSteps:\n1. ...\nReference: https://youtube.com/watch?v=... or https://allrecipes.com/recipe/..."
    )
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")

    # Parse Gemini's response
    ingredients, steps, reference = [], [], ""
    section = None
    for line in response.split('\n'):
        line = line.strip()
        # Robust section detection (handles Markdown, colons, etc.)
        if re.match(r"^\*?\*?ingredients\*?\*?:?", line.lower()):
            section = "ingredients"
            continue
        if re.match(r"^\*?\*?steps\*?\*?:?", line.lower()):
            section = "steps"
            continue
        if re.match(r"^\*?\*?reference\*?\*?:?", line.lower()):
            section = "reference"
            # Try to extract a known recipe/video site URL
            allowed_domains = ["youtube.com", "allrecipes.com", "foodnetwork.com", "tasty.co", "epicurious.com", "panlasangpinoy.com", "yummly.com", "simplyrecipes.com", "bbcgoodfood.com", "tasteofhome.com"]
            urls = re.findall(r"https?://\S+", line)
            found = False
            for url in urls:
                for domain in allowed_domains:
                    if domain in url:
                        reference = url
                        found = True
                        break
                if found:
                    break
            if not found:
                # fallback: any url
                if urls:
                    reference = urls[0]
                else:
                    reference = line.split(":", 1)[-1].strip()
            continue
        elif section == "reference" and line.strip():
            urls = re.findall(r"https?://\S+", line)
            found = False
            for url in urls:
                for domain in allowed_domains:
                    if domain in url:
                        reference = url
                        found = True
                        break
                if found:
                    break
            if not found and not reference:
                if urls:
                    reference = urls[0]
                else:
                    reference = line.strip()
        if section == "ingredients" and (line.startswith("-") or line.startswith("*") or line[:1].isdigit()):
            # Remove bullet, number, or asterisk
            name = re.sub(r"^[\-*\d.\s]+", "", line)
            if name:
                ingredients.append(name)
        elif section == "steps" and (line[:1].isdigit() or line.startswith("-") or line.startswith("*")):
            step = re.sub(r"^[\-*\d.\s]+", "", line)
            if step:
                steps.append(step)

    # Save to DB for future use
    db_recipe = models.Recipe(
        title=dish,
        ingredients='\n'.join(ingredients),
        steps='\n'.join(steps),
        reference=reference,
        image_url=None,
        tags=[],
        difficulty=None,
        estimated_time=None,
        created_by=None
    )
    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    return {
        "ingredients": ingredients,
        "steps": steps,
        "reference": reference
    }

@router.post("/ai_suggest")
def ai_suggest(prompt: str = Body(..., embed=True)):
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")
    return {"suggestion": response}


@router.post("/ai_conversation")
def ai_conversation(user_input: str = Body(..., embed=True), db: Session = Depends(get_db)):
    print(f"[ai_conversation] User input: {user_input!r}")

    # Try to detect if the user is asking for a specific dish
    dish_patterns = [
        r"i want to cook (.+)",
        r"how to cook (.+)",
        r"show me how to make (.+)",
        r"how do i make (.+)",
        r"give me the recipe for (.+)",
        r"recipe for (.+)",
        r"how to make (.+)",
        r"make (.+)",
    ]
    dish_name = None
    for pat in dish_patterns:
        m = re.match(pat, user_input.strip().lower())
        if m:
            dish_name = m.group(1).strip().rstrip("?.!")
            break

    if dish_name:
        # Only return the specific dish as the suggestion
        # Call the AI for details about this dish (reuse ai_ingredients logic)
        # Try DB first
        db_recipe = db.query(models.Recipe).filter(models.Recipe.title.ilike(dish_name)).first()
        if db_recipe and db_recipe.ingredients and db_recipe.steps:
            suggestion = {
                "name": db_recipe.title,
                "description": db_recipe.description if hasattr(db_recipe, 'description') else '',
                "ingredients": db_recipe.ingredients.replace('\n', ', '),
                "time": db_recipe.estimated_time or '',
                "difficulty": db_recipe.difficulty or '',
                "instructions": db_recipe.steps.replace('\n', '\n'),
                "reference": getattr(db_recipe, 'reference', ''),
            }
        else:
            # Call Gemini for this dish
            prompt = (
                f"For the dish '{dish_name}', provide:\n"
                f"1. A bullet list of main ingredients.\n"
                f"2. Step-by-step instructions on how to cook it.\n"
                f"3. A YouTube video link or recipe website link for this dish.\n"
                f"Format:\n"
                f"Ingredients:\n- ...\nSteps:\n1. ...\nReference: https://youtube.com/watch?v=... or https://allrecipes.com/recipe/..."
            )
            response = crud.call_gemini_api(prompt)
            if not response:
                raise HTTPException(status_code=500, detail="AI service unavailable or error.")
            # Parse Gemini's response
            ingredients, steps, reference = [], [], ""
            section = None
            for line in response.split('\n'):
                line = line.strip()
                if re.match(r"^\*?\*?ingredients\*?\*?:?", line.lower()):
                    section = "ingredients"
                    continue
                if re.match(r"^\*?\*?steps\*?\*?:?", line.lower()):
                    section = "steps"
                    continue
                if re.match(r"^\*?\*?reference\*?\*?:?", line.lower()):
                    section = "reference"
                    # Try to extract a known recipe/video site URL
                    allowed_domains = ["youtube.com", "allrecipes.com", "foodnetwork.com", "tasty.co", "epicurious.com", "panlasangpinoy.com", "yummly.com", "simplyrecipes.com", "bbcgoodfood.com", "tasteofhome.com"]
                    urls = re.findall(r"https?://\S+", line)
                    found = False
                    for url in urls:
                        for domain in allowed_domains:
                            if domain in url:
                                reference = url
                                found = True
                                break
                        if found:
                            break
                    if not found:
                        # fallback: any url
                        if urls:
                            reference = urls[0]
                        else:
                            reference = line.split(":", 1)[-1].strip()
                    continue
                elif section == "reference" and line.strip():
                    urls = re.findall(r"https?://\S+", line)
                    found = False
                    for url in urls:
                        for domain in allowed_domains:
                            if domain in url:
                                reference = url
                                found = True
                                break
                        if found:
                            break
                    if not found and not reference:
                        if urls:
                            reference = urls[0]
                        else:
                            reference = line.strip()
                if section == "ingredients" and (line.startswith("-") or line.startswith("*") or line[:1].isdigit()):
                    name = re.sub(r"^[\-*\d.\s]+", "", line)
                    if name:
                        ingredients.append(name)
                elif section == "steps" and (line[:1].isdigit() or line.startswith("-") or line.startswith("*")):
                    step = re.sub(r"^[\-*\d.\s]+", "", line)
                    if step:
                        steps.append(step)
            suggestion = {
                "name": dish_name,
                "description": f"Recipe for {dish_name}",
                "ingredients": ', '.join(ingredients),
                "time": '',
                "difficulty": '',
                "instructions": '\n'.join(steps),
                "reference": reference,
            }
        return {
            "user_input": user_input,
            "suggestions": [suggestion],
            "ai_response": f"Direct dish request for: {dish_name}"
        }

    # Otherwise, use the normal AI multi-suggestion logic
    prompt = f"""
    User said: \"{user_input}\"
    
    Based on this request, suggest 3-5 specific dishes that would be perfect for the user.
    For each dish, provide:
    1. Dish name
    2. Brief description (1 sentence)
    3. Main ingredients (3-5 key ingredients)
    4. Cooking time estimate
    5. Difficulty level (Easy/Medium/Hard)
    6. Step-by-step cooking instructions (3-5 steps)
    
    Format your response as:
    DISH 1:
    Name: [Dish Name]
    Description: [Brief description]
    Ingredients: [Main ingredients separated by commas]
    Time: [Estimated cooking time]
    Difficulty: [Easy/Medium/Hard]
    Instructions: [Step-by-step cooking instructions, numbered]
    
    DISH 2:
    Name: [Dish Name]
    Description: [Brief description]
    Ingredients: [Main ingredients separated by commas]
    Time: [Estimated cooking time]
    Difficulty: [Easy/Medium/Hard]
    Instructions: [Step-by-step cooking instructions, numbered]
    
    And so on...
    """
    response = crud.call_gemini_api(prompt)
    if not response:
        raise HTTPException(status_code=500, detail="AI service unavailable or error.")
    # Parse the response into structured data
    dishes = []
    current_dish = {}
    for line in response.split('\n'):
        line = line.strip()
        if line.startswith('DISH') and line[4].isdigit():
            if current_dish:
                dishes.append(current_dish)
            current_dish = {}
        elif line.startswith('Name:'):
            current_dish['name'] = line.split(':', 1)[1].strip()
        elif line.startswith('Description:'):
            current_dish['description'] = line.split(':', 1)[1].strip()
        elif line.startswith('Ingredients:'):
            current_dish['ingredients'] = line.split(':', 1)[1].strip()
        elif line.startswith('Time:'):
            current_dish['time'] = line.split(':', 1)[1].strip()
        elif line.startswith('Difficulty:'):
            current_dish['difficulty'] = line.split(':', 1)[1].strip()
        elif line.startswith('Instructions:'):
            current_dish['instructions'] = line.split(':', 1)[1].strip()
    if current_dish:
        dishes.append(current_dish)
    return {
        "user_input": user_input,
        "suggestions": dishes,
        "ai_response": response
    }

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