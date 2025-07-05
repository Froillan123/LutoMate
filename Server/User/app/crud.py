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

def fetch_unsplash_image(query: str) -> str:
    api_key = os.getenv("UNSPLASH_API_KEY")
    if not api_key:
        return None
    url = f"https://api.unsplash.com/search/photos?query={query}&client_id={api_key}&per_page=1"
    try:
        resp = requests.get(url)
        data = resp.json()
        if data.get("results"):
            return data["results"][0]["urls"]["regular"]
    except Exception:
        pass
    return None

def create_recipe(db: Session, recipe: schemas.RecipeCreate, user_id: UUID):
    image_url = recipe.image_url
    if not image_url:
        image_url = fetch_unsplash_image(recipe.title)
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
    if not api_key or not api_url:
        return None
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    data = {
        "contents": [{"parts": [{"text": prompt}]}]
    }
    try:
        resp = requests.post(api_url, headers=headers, json=data)
        resp.raise_for_status()
        result = resp.json()
        # Gemini's response structure may vary; adjust as needed
        return result.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
    except Exception as e:
        return None

def update_user(db: Session, user_id: UUID, update: schemas.UserCreate):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None
    if update.first_name:
        user.first_name = update.first_name
    if update.last_name:
        user.last_name = update.last_name
    if update.email:
        user.email = update.email
    if update.role:
        user.role = update.role
    if update.status:
        user.status = update.status
    if update.preferences is not None:
        user.preferences = update.preferences
    if update.password:
        user.password = get_password_hash(update.password)
    db.commit()
    db.refresh(user)
    return user 