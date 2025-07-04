from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from datetime import datetime, timedelta
from uuid import UUID
import os
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional

from .. import models, schemas, crud
from ..database import SessionLocal

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/lutome/login")

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

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
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
    db_user = crud.get_user_by_username(db, user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    return crud.create_user(db, user)

class TokenResponse(BaseModel):
    access_token: str
    token_type: str

class LogoutResponse(BaseModel):
    message: str

@router.post("/login", response_model=TokenResponse, summary="Login and get JWT token")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect username or password")
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