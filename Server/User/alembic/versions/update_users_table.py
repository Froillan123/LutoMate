"""Update users table structure

Revision ID: update_users_table
Revises: 5b9d097ce335
Create Date: 2024-01-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'update_users_table'
down_revision = '5b9d097ce335'
branch_labels = None
depends_on = None


def upgrade():
    # Add new columns
    op.add_column('users', sa.Column('first_name', sa.String(50), nullable=True))
    op.add_column('users', sa.Column('last_name', sa.String(50), nullable=True))
    op.add_column('users', sa.Column('role', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('status', sa.String(20), nullable=True))
    
    # Update existing records with placeholder values
    op.execute("UPDATE users SET first_name = 'User', last_name = 'Name', role = 'user', status = 'active' WHERE first_name IS NULL")
    
    # Make columns not nullable
    op.alter_column('users', 'first_name', nullable=False)
    op.alter_column('users', 'last_name', nullable=False)
    op.alter_column('users', 'role', nullable=False)
    op.alter_column('users', 'status', nullable=False)
    
    # Set default values for new columns
    op.execute("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user'")
    op.execute("ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active'")
    
    # Drop only username column, keep password
    op.drop_column('users', 'username')


def downgrade():
    # Add back username column
    op.add_column('users', sa.Column('username', sa.String(50), nullable=True))
    
    # Update existing records with placeholder values
    op.execute("UPDATE users SET username = email WHERE username IS NULL")
    
    # Make username not nullable
    op.alter_column('users', 'username', nullable=False)
    
    # Add unique constraint back
    op.create_unique_constraint('users_username_key', 'users', ['username'])
    
    # Drop new columns
    op.drop_column('users', 'first_name')
    op.drop_column('users', 'last_name')
    op.drop_column('users', 'role')
    op.drop_column('users', 'status') 