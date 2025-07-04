import subprocess
import sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, recipes

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(recipes.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to LutoMate API!"}

if __name__ == "__main__":
    # Auto-run Alembic migrations
    try:
        subprocess.run([sys.executable, "-m", "alembic", "upgrade", "head"], check=True)
    except Exception as e:
        print(f"Alembic migration failed: {e}")
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 