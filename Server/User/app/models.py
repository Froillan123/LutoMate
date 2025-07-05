import uuid
from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Text, JSON, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    role = Column(String(20), nullable=False, default='user')
    status = Column(String(20), nullable=False, default='active')
    preferences = Column(JSONB, default=list)
    recipes = relationship('Recipe', back_populates='creator')
    interactions = relationship('UserRecipeInteraction', back_populates='user')
    favorites = relationship('Favorite', back_populates='user')
    grocery_items = relationship('GroceryChecklist', back_populates='user')
    voice_queries = relationship('VoiceQuery', back_populates='user')

class Recipe(Base):
    __tablename__ = 'recipes'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(100), nullable=False)
    image_url = Column(Text)
    ingredients = Column(Text, nullable=False)
    steps = Column(Text, nullable=False)
    reference = Column(Text)
    tags = Column(JSONB, default=list)
    difficulty = Column(String(20))
    estimated_time = Column(Integer)
    created_by = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'))
    creator = relationship('User', back_populates='recipes')
    interactions = relationship('UserRecipeInteraction', back_populates='recipe')
    favorites = relationship('Favorite', back_populates='recipe')

class UserRecipeInteraction(Base):
    __tablename__ = 'user_recipe_interaction'
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'))
    recipe_id = Column(UUID(as_uuid=True), ForeignKey('recipes.id', ondelete='CASCADE'))
    liked = Column(Boolean, default=False)
    viewed_at = Column(TIMESTAMP)
    user = relationship('User', back_populates='interactions')
    recipe = relationship('Recipe', back_populates='interactions')

class Favorite(Base):
    __tablename__ = 'favorites'
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'))
    recipe_id = Column(UUID(as_uuid=True), ForeignKey('recipes.id', ondelete='CASCADE'))
    added_at = Column(TIMESTAMP)
    user = relationship('User', back_populates='favorites')
    recipe = relationship('Recipe', back_populates='favorites')

class GroceryChecklist(Base):
    __tablename__ = 'grocery_checklist'
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'))
    item_name = Column(String(100), nullable=False)
    quantity = Column(String(50))
    is_checked = Column(Boolean, default=False)
    user = relationship('User', back_populates='grocery_items')

class VoiceQuery(Base):
    __tablename__ = 'voice_queries'
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'))
    query_text = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP)
    user = relationship('User', back_populates='voice_queries') 