import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

# Get database URL from environment
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://username:password@localhost/dbname")

# Create engine
engine = create_engine(DATABASE_URL)

# Check table structure
with engine.connect() as conn:
    # Get column information
    result = conn.execute(text("""
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = 'users'
        ORDER BY ordinal_position;
    """))
    
    print("Users table columns:")
    print("-" * 50)
    for row in result:
        print(f"Column: {row[0]}")
        print(f"Type: {row[1]}")
        print(f"Nullable: {row[2]}")
        print(f"Default: {row[3]}")
        print("-" * 30) 