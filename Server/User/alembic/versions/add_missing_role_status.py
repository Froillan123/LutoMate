"""Add missing role and status columns

Revision ID: add_missing_role_status
Revises: update_users_table
Create Date: 2024-01-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_missing_role_status'
down_revision = 'update_users_table'
branch_labels = None
depends_on = None


def upgrade():
    # Add missing role and status columns
    op.add_column('users', sa.Column('role', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('status', sa.String(20), nullable=True))
    
    # Update existing records with default values
    op.execute("UPDATE users SET role = 'user', status = 'active' WHERE role IS NULL")
    
    # Make columns not nullable
    op.alter_column('users', 'role', nullable=False)
    op.alter_column('users', 'status', nullable=False)
    
    # Set default values for new columns
    op.execute("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user'")
    op.execute("ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active'")


def downgrade():
    # Drop the columns
    op.drop_column('users', 'role')
    op.drop_column('users', 'status') 