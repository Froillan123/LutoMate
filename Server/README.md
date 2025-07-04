# LutoMate FastAPI Backend

## Setup
1. Add a `.env` file with your database and API keys.
2. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```
3. Run migrations and start the server:
   ```sh
   python main.py
   ```
   or for hot reload:
   ```sh
   uvicorn main:app --reload
   ```

## Docker
1. Build:
   ```sh
   docker build -t lutomate-backend .
   ```
2. Run:
   ```sh
   docker run -p 8000:8000 --env-file .env lutomate-backend
   ```

## API Endpoints
- `POST   /api/lutome/register`  - Register
- `POST   /api/lutome/login`     - Login (JWT)
- `POST   /api/lutome/logout`    - Logout
- `GET    /api/lutome/me`        - Get current user
- `PATCH  /api/lutome/update`    - Update user
- `POST   /api/lutome/recipes/`  - Create recipe
- `GET    /api/lutome/recipes/`  - List recipes
- `GET    /api/lutome/recipes/{recipe_id}` - Get recipe
- `GET    /api/lutome/recipes/recommendations?user_id=...` - Recommendations
- `POST   /api/lutome/recipes/ai_suggest` - AI suggest

See `/docs` for full API documentation after running the server. 