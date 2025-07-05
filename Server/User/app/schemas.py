from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    role: Optional[str] = 'user'
    status: Optional[str] = 'active'
    preferences: Optional[List[str]] = []

class UserCreate(UserBase):
    password: str

class UserOut(UserBase):
    id: UUID

    class Config:
        orm_mode = True

class RecipeBase(BaseModel):
    title: str
    image_url: Optional[str] = None
    ingredients: str
    steps: str
    tags: Optional[List[str]] = []
    difficulty: Optional[str] = None
    estimated_time: Optional[int] = None

class RecipeCreate(RecipeBase):
    pass

class RecipeOut(RecipeBase):
    id: UUID
    created_by: Optional[UUID] = None

    class Config:
        orm_mode = True

class UserRecipeInteractionBase(BaseModel):
    liked: Optional[bool] = False

class UserRecipeInteractionCreate(UserRecipeInteractionBase):
    user_id: UUID
    recipe_id: UUID

class UserRecipeInteractionOut(UserRecipeInteractionBase):
    id: int
    user_id: UUID
    recipe_id: UUID
    viewed_at: Optional[str]

    class Config:
        orm_mode = True

class FavoriteBase(BaseModel):
    pass

class FavoriteCreate(FavoriteBase):
    user_id: UUID
    recipe_id: UUID

class FavoriteOut(FavoriteBase):
    id: int
    user_id: UUID
    recipe_id: UUID
    added_at: Optional[str]

    class Config:
        orm_mode = True

class GroceryChecklistBase(BaseModel):
    item_name: str
    quantity: Optional[str] = None
    is_checked: Optional[bool] = False

class GroceryChecklistCreate(GroceryChecklistBase):
    user_id: UUID

class GroceryChecklistOut(GroceryChecklistBase):
    id: int
    user_id: UUID

    class Config:
        orm_mode = True

class VoiceQueryBase(BaseModel):
    query_text: str

class VoiceQueryCreate(VoiceQueryBase):
    user_id: Optional[UUID] = None

class VoiceQueryOut(VoiceQueryBase):
    id: int
    user_id: Optional[UUID] = None
    created_at: Optional[str]

    class Config:
        orm_mode = True 