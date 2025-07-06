from sqlalchemy.orm import Session
from . import models, schemas
from passlib.context import CryptContext
from uuid import UUID
import os
import requests

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        first_name=user.first_name,
        last_name=user.last_name,
        email=user.email,
        password=hashed_password,
        role=user.role or 'user',
        status=user.status or 'active',
        preferences=user.preferences or []
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, email: str, password: str):
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        return None
    if not verify_password(password, user.password):
        return None
    return user

def get_user_by_id(db: Session, user_id: UUID):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def fetch_openverse_image(query: str) -> str:
    """Fetch image from Openverse API (free alternative to Unsplash)"""
    # First try with commercial license filter
    url = f"https://api.openverse.engineering/v1/images/?q={query}&page_size=1&filter=license_type:commercial"
    try:
        resp = requests.get(url, timeout=10)
        data = resp.json()
        if data.get("results") and len(data["results"]) > 0:
            return data["results"][0]["url"]
    except Exception as e:
        print(f"[Openverse] Error fetching commercial image for '{query}': {e}")
    
    # Fallback: try without commercial filter
    try:
        fallback_url = f"https://api.openverse.engineering/v1/images/?q={query}&page_size=1"
        resp = requests.get(fallback_url, timeout=10)
        data = resp.json()
        if data.get("results") and len(data["results"]) > 0:
            return data["results"][0]["url"]
    except Exception as e:
        print(f"[Openverse] Error fetching fallback image for '{query}': {e}")
    
    return None

def create_recipe(db: Session, recipe: schemas.RecipeCreate, user_id: UUID):
    image_url = recipe.image_url
    if not image_url:
        image_url = fetch_openverse_image(recipe.title)
    db_recipe = models.Recipe(
        title=recipe.title,
        image_url=image_url,
        ingredients=recipe.ingredients,
        steps=recipe.steps,
        tags=recipe.tags or [],
        difficulty=recipe.difficulty,
        estimated_time=recipe.estimated_time,
        created_by=user_id
    )
    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)
    return db_recipe

def get_recipe(db: Session, recipe_id: UUID):
    return db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

def get_recipes(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.Recipe).offset(skip).limit(limit).all()

def get_recommendations(db: Session, user_id: UUID, limit: int = 10):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    preferences = user.preferences or []
    return (
        db.query(models.Recipe)
        .filter(models.Recipe.tags.overlap(preferences))
        .limit(limit)
        .all()
    )

def call_gemini_api(prompt: str) -> str:
    api_key = os.getenv("GEMINI_API_KEY")
    api_url = os.getenv("GEMINI_API_URL")
    print(f"[Gemini] api_key: {api_key}")
    print(f"[Gemini] api_url: {api_url}")
    print(f"[Gemini] prompt: {prompt!r}")
    if not api_key or not api_url:
        print("[Gemini] Missing API key or URL!")
        return None
    headers = {
        "Content-Type": "application/json"
    }
    url = f"{api_url}?key={api_key}"
    data = {
        "contents": [{"parts": [{"text": prompt}]}]
    }
    try:
        resp = requests.post(url, headers=headers, json=data)
        print(f"[Gemini] Response status: {resp.status_code}")
        print(f"[Gemini] Response body: {resp.text}")
        resp.raise_for_status()
        result = resp.json()
        return result.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
    except Exception as e:
        print(f"[Gemini] Exception: {e}")
        return None

def update_user(db: Session, user_id: UUID, update: schemas.UserCreate):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None
    # Only update fields that are not None and not empty (for strings)
    if update.first_name is not None and update.first_name != '':
        user.first_name = update.first_name
    if update.last_name is not None and update.last_name != '':
        user.last_name = update.last_name
    if update.email is not None and update.email != '':
        user.email = update.email
    if update.role is not None and update.role != '':
        user.role = update.role
    if update.status is not None and update.status != '':
        user.status = update.status
    if update.preferences is not None:
        user.preferences = update.preferences
    if update.password is not None and update.password != '':
        user.password = get_password_hash(update.password)
    db.commit()
    db.refresh(user)
    return user 