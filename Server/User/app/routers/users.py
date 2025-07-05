from fastapi import APIRouter, Depends, HTTPException, status, Body, Header
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from datetime import datetime, timedelta
from uuid import UUID
import os
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.exc import IntegrityError

from .. import models, schemas, crud
from ..database import SessionLocal

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

router = APIRouter(prefix="/api/lutome", tags=["users"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(authorization: str = Header(...), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        if not authorization.startswith("Bearer "):
            raise credentials_exception
        token = authorization.replace("Bearer ", "")
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = crud.get_user_by_id(db, user_id)
    if user is None:
        raise credentials_exception
    return user

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_email = crud.get_user_by_email(db, user.email)
    if db_email:
        raise HTTPException(status_code=400, detail="Email already registered")
    try:
        return crud.create_user(db, user)
    except IntegrityError as e:
        db.rollback()
        # Check if it's a unique constraint violation for email
        if 'users_email_key' in str(e.orig):
            raise HTTPException(status_code=400, detail="Email already registered")
        raise HTTPException(status_code=400, detail="Registration failed: Integrity error")

class TokenResponse(BaseModel):
    access_token: str
    token_type: str

class LogoutResponse(BaseModel):
    message: str

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login", response_model=TokenResponse, summary="Login with email and password")
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, login_data.email, login_data.password)
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/logout", response_model=LogoutResponse, summary="Logout (client should delete token)")
def logout():
    return {"message": "Successfully logged out. Please delete your token on the client."}

@router.get("/me", response_model=schemas.UserOut)
def read_users_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.patch("/update", response_model=schemas.UserOut)
def update_user(update: schemas.UserCreate = Body(...), db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    user = crud.update_user(db, current_user.id, update)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/voice-query")
def save_voice_query(query: schemas.VoiceQueryCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    voice_query = models.VoiceQuery(
        user_id=current_user.id,
        query_text=query.query_text,
        created_at=datetime.utcnow()
    )
    db.add(voice_query)
    db.commit()
    db.refresh(voice_query)
    return {"success": True, "message": "Voice query saved"}

@router.get("/voice-history")
def get_voice_history(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    queries = db.query(models.VoiceQuery).filter(
        models.VoiceQuery.user_id == current_user.id
    ).order_by(models.VoiceQuery.created_at.desc()).limit(20).all()
    
    return {
        "queries": [
            {
                "id": query.id,
                "query_text": query.query_text,
                "created_at": query.created_at.isoformat() if query.created_at else None
            }
            for query in queries
        ]
    }

@router.post("/search-history")
def save_search_history(search: str = Body(..., embed=True), db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Save search to voice queries for now (can create separate table later)
    voice_query = models.VoiceQuery(
        user_id=current_user.id,
        query_text=search,
        created_at=datetime.utcnow()
    )
    db.add(voice_query)
    db.commit()
    return {"success": True, "message": "Search history saved"}

@router.get("/search-history")
def get_search_history(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    queries = db.query(models.VoiceQuery).filter(
        models.VoiceQuery.user_id == current_user.id
    ).order_by(models.VoiceQuery.created_at.desc()).limit(50).all()
    
    return {
        "history": [
            {
                "id": query.id,
                "query_text": query.query_text,
                "created_at": query.created_at.isoformat() if query.created_at else None
            }
            for query in queries
        ]
    } 