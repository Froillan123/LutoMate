# LutoMate – Smart Recipe App

**Generated on:** 2025-07-04 05:13:19

---

## 🚀 Application Overview
LutoMate is a smart, mobile-first recipe and cooking guide app designed to make home cooking easy, personalized, and fun. It leverages AI for recipe suggestions, supports food preferences, and offers a seamless experience from registration to cooking.

---

## 🔧 Backend (MVP)
- **Framework:** FastAPI (Python 3.11, Dockerized for Render compatibility)
- **Database:** PostgreSQL (Hosted on Render)
- **ORM:** SQLAlchemy
- **Deployment:** Docker

**Backend Structure:**
```
backend/
├── app/
│   ├── main.py
│   ├── models.py
│   ├── schemas.py
│   ├── database.py
│   ├── crud.py
│   └── routers/
│       ├── users.py
│       └── recipes.py
├── Dockerfile
├── requirements.txt
└── alembic/ (optional for migrations)
```

---

## 🧩 ERD Design (Simplified)
**Users**
- id (UUID)
- username
- email
- password (hashed)
- preferences (JSON[])

**Recipes**
- id (UUID)
- title
- image_url
- ingredients (TEXT)
- steps (TEXT)
- tags (JSON[])
- difficulty
- estimated_time

**UserRecipeInteraction**
- id
- user_id → Users
- recipe_id → Recipes
- liked (bool)
- viewed_at (timestamp)

---

## 📱 Frontend (Flutter)
**Screens:**
- LoginPage
- RegisterPage (with food preferences via chips/checkboxes)
- HomePage (visual recipe browse + AI suggestions)
- RecipeDetailPage
- VoiceSearchPage (speech-to-text input)

**User Flow:**
1. User registers and selects food preferences (e.g., "chicken", "spicy").
2. Preferences stored in backend (users.preferences).
3. Homepage calls:
   `GET /recipes/recommendations?user_id=<uid>`
4. Backend recommends recipes where Recipe.tags overlap with user preferences.

**Backend Recommendation Logic (MVP):**
```python
def get_recommendations(user_id: UUID, db: Session):
    user = db.query(User).filter(User.id == user_id).first()
    preferences = user.preferences or []
    return (
        db.query(Recipe)
        .filter(Recipe.tags.overlap(preferences))  # PostgreSQL array overlap
        .limit(10)
        .all()
    )
```

---

## 🧠 Future Features
- AI: "I want to cook something with noodles" → smart response
- Speech-to-text input + OpenAI or Gemini API
- Save to favorites
- User-uploaded recipes
- Grocery checklist
- Filter by cooking time, difficulty, dietary need

---

Ready to generate backend files, sample UI, or voice integration!