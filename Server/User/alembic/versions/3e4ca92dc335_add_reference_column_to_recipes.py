"""add_reference_column_to_recipes

Revision ID: 3e4ca92dc335
Revises: add_missing_role_status
Create Date: 2025-07-05 14:21:57.208471

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '3e4ca92dc335'
down_revision: Union[str, Sequence[str], None] = 'add_missing_role_status'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('recipes', sa.Column('reference', sa.Text(), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('recipes', 'reference')
