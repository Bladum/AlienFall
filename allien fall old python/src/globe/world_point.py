"""
TWorldPoint: Represents a position on the world map (tile coordinates).
Provides utility methods for position handling.

Classes:
    TWorldPoint: Utility class for world map positions.

Last standardized: 2025-06-30
"""

from typing import Tuple, Any

class TWorldPoint:
    """
    Represents a position on the world map (tile coordinates).
    Provides utility methods for position handling.

    Attributes:
        x (int): X coordinate.
        y (int): Y coordinate.
    """
    def __init__(self, x: int, y: int) -> None:
        self.x: int = int(x)
        self.y: int = int(y)

    @classmethod
    def from_tuple(cls, tuple_pos: Tuple[int, int]) -> 'TWorldPoint':
        """Create a TWorldPoint from a tuple (x, y)."""
        return cls(tuple_pos[0], tuple_pos[1])

    @classmethod
    def from_iterable(cls, iterable: Any) -> 'TWorldPoint':
        """Create a TWorldPoint from any iterable with two elements (x, y)."""
        x, y = iterable
        return cls(x, y)

    def to_tuple(self) -> Tuple[int, int]:
        """Return the point as a tuple (x, y)."""
        return (self.x, self.y)

    def distance_to(self, other: 'TWorldPoint') -> float:
        """Calculate Euclidean distance to another TWorldPoint."""
        import math
        return math.hypot(self.x - other.x, self.y - other.y)

    def manhattan_distance(self, other: 'TWorldPoint') -> int:
        """Calculate Manhattan distance between two points."""
        return abs(self.x - other.x) + abs(self.y - other.y)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, TWorldPoint):
            return NotImplemented
        return self.x == other.x and self.y == other.y

    def __hash__(self) -> int:
        return hash((self.x, self.y))

    def __repr__(self) -> str:
        return f"TWorldPoint({self.x}, {self.y})"

    def __add__(self, other: 'TWorldPoint') -> 'TWorldPoint':
        """Add two points together."""
        return TWorldPoint(self.x + other.x, self.y + other.y)

    def __sub__(self, other: 'TWorldPoint') -> 'TWorldPoint':
        """Subtract one point from another."""
        return TWorldPoint(self.x - other.x, self.y - other.y)

    def scale(self, factor: int) -> 'TWorldPoint':
        """Scale the point by a factor."""
        return TWorldPoint(self.x * factor, self.y * factor)

    def is_within_bounds(self, width: int, height: int) -> bool:
        """Check if the point is within map boundaries."""
        return 0 <= self.x < width and 0 <= self.y < height

    def midpoint(self, other: 'TWorldPoint') -> 'TWorldPoint':
        """Find the midpoint between this point and another."""
        return TWorldPoint((self.x + other.x) // 2, (self.y + other.y) // 2)

    def get_adjacent_points(self) -> Tuple['TWorldPoint', ...]:
        """Get the four adjacent points (N, E, S, W)"""
        directions = [(0, -1), (1, 0), (0, 1), (-1, 0)]  # N, E, S, W
        return tuple(TWorldPoint(self.x + dx, self.y + dy) for dx, dy in directions)

    def get_adjacent_points_with_diagonals(self) -> Tuple['TWorldPoint', ...]:
        """Get all eight adjacent points (including diagonals)"""
        directions = [
            (-1, -1), (0, -1), (1, -1),
            (-1, 0),           (1, 0),
            (-1, 1),  (0, 1),  (1, 1)
        ]
        return tuple(TWorldPoint(self.x + dx, self.y + dy) for dx, dy in directions)

    def round_to_grid(self, grid_size: int) -> 'TWorldPoint':
        """Round coordinates to the nearest grid position"""
        return TWorldPoint(
            round(self.x / grid_size) * grid_size,
            round(self.y / grid_size) * grid_size
        )
