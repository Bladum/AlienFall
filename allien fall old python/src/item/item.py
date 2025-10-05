"""
TItem: Base class for all game items.

Provides common properties and behaviors for all items in the game, including serialization, inventory compatibility, and UI display.

Classes:
    TItem: Main class for game items.

Last standardized: 2025-06-14
"""

from typing import Dict, Optional
from enums import EItemCategory, Enum
from item.item_type import TItemType


class TItem:
    """
    Base class for all game items.

    Encapsulates common properties and behaviors for item instances that can be stored in inventories, equipped by units, etc.

    Attributes:
        name (str): Human-readable item name.
        sprite (str): Path to item's visual icon.
        properties (Dict[str, str]): Additional item-specific properties.
        item_type (TItemType): Type reference for this item.
        weight (int): Item weight for inventory management.
        id (str): Unique identifier for this item instance.
    """

    name: str
    sprite: str
    properties: Dict[str, str]
    item_type: TItemType
    weight: int
    id: str
    game: 'TGame'  # type: ignore

    def __init__(self, item_type_id: str, item_id: Optional[str] = None) -> None:
        from engine.game import TGame
        self.game: 'TGame' = TGame()

        # Get item type reference
        self.item_type: TItemType = self.game.mod.items.get(item_type_id)

        # Set properties based on item type
        self.name: str = self.item_type.name
        self.sprite: str = self.item_type.sprite
        self.weight: int = self.item_type.weight
        self.properties: Dict[str, str] = {}

        # Generate UUID if no ID provided
        import uuid
        self.id: str = item_id or str(uuid.uuid4())

    def get_pixmap(self, size: Optional[int] = None) -> 'QPixmap':
        from PySide6.QtGui import QPixmap
        from PySide6.QtCore import Qt
        pixmap: 'QPixmap' = QPixmap(self.sprite)
        if size is not None and not pixmap.isNull():
            pixmap = pixmap.scaled(size, size, Qt.KeepAspectRatio, Qt.SmoothTransformation)
        return pixmap

    def get_compatible_slots(self) -> list[str]:
        """
        Get list of slot types this item is compatible with.

        Returns:
            list[str]: List of slot identifiers this item can be equipped to.
        """
        return self.properties.get('compatible_slots', [])

    def get_category(self) -> int:
        """
        Get the item's category.

        Returns:
            int: Integer representing the item category from TItemType constants.
        """
        return self.item_type.category

    def get_display_name(self) -> str:
        """
        Get a formatted display name for the item.

        Returns:
            str: String with item name.
        """
        return self.name

    def to_dict(self) -> Dict[str, object]:
        """
        Convert the item to a dictionary for serialization.

        Returns:
            Dict[str, object]: Dictionary representation of the item.
        """
        return {
            'id': self.id,
            'item_type_id': self.item_type.pid,
            'properties': self.properties,
        }

    @classmethod
    def from_dict(cls, data: Dict[str, object], type_registry: Dict[str, TItemType]) -> 'TItem':
        """
        Create an item instance from a dictionary representation.

        Args:
            data (Dict[str, object]): Dictionary representation of the item.
            type_registry (Dict[str, TItemType]): Dictionary mapping type IDs to TItemType objects.

        Returns:
            TItem: New TItem instance.
        """
        item_type_id: str = data.get('item_type_id')  # type: ignore

        if not item_type_id:
            raise ValueError("Missing item_type_id in data")

        item: TItem = cls(
            item_type_id=item_type_id,
            item_id=data.get('id')  # type: ignore
        )

        # Apply any saved properties
        if 'properties' in data:
            item.properties = data.get('properties', {})  # type: ignore

        return item

    def __eq__(self, other: object) -> bool:
        """
        Check if two items are equal (same ID).

        Args:
            other (object): Another item to compare.

        Returns:
            bool: True if IDs match, False otherwise.
        """
        if not isinstance(other, TItem):
            return False
        return self.id == other.id

    def __hash__(self) -> int:
        """
        Hash based on item ID.

        Returns:
            int: Hash value.
        """
        return hash(self.id)

    def __str__(self) -> str:
        """
        String representation of the item.

        Returns:
            str: Human-readable string.
        """
        return f"{self.name} [{self.id[:8]}]"

    def __repr__(self) -> str:
        """
        Detailed representation of the item.

        Returns:
            str: Debug string.
        """
        return f"TItem(type='{self.item_type.pid}', id='{self.id[:8]}')"
