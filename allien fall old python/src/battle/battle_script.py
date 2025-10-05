"""
TBattleScript: Defines map assembly logic for battle map generation.

Represents a script for map block placement, used to generate a battle map from map blocks in a specific way (by group, size, etc). Each script consists of steps, each describing how to fill part of the map grid.

Classes:
    TBattleScript: Main class for map block placement scripts.

Last standardized: 2025-06-22 (typing enforced)
"""
from typing import List, Set
from battle.battle_script_step import TBattleScriptStep
from battle.map_block import TMapBlock

class TBattleScript:
    """
    Represents a script for map block placement.
    Used to generate a battle map from map blocks in a specific way (by group, size, etc).
    Each script consists of steps, each step describes how to fill part of the map grid.

    Attributes:
        pid (str): Script identifier.
        steps (list[TBattleScriptStep]): List of steps in the script.
        context (set[int | str]): Set of executed step labels.
    """
    def __init__(self, pid: str, data: dict):
        from engine.game import TGame  # Avoid circular import
        self.game: 'TGame' = TGame()

        self.pid: str = pid
        self.steps: List[TBattleScriptStep] = []
        self.context: Set[int | str] = set()  # Set of executed step labels

        if 'steps' in data and isinstance(data['steps'], list):
            for step_data in data['steps']:
                self.steps.append(TBattleScriptStep(step_data))

    def apply_to(self, generator) -> None:
        """
        Apply the script to the generator, filling the block grid according to the steps.
        """
        import random
        import time
        random.seed(time.time())

        block_counts: dict[str, int] = {}

        for step in self.steps:
            chance: float = step.chance
            if chance < 1:
                if random.random() > chance:
                    if step.label:
                        self.context.add(-step.label)
                    continue
            group = step.group
            size = step.size
            name = None
            if step.type == 'add_ufo':
                name = 'small_scout' # step.ufo TODO fix me
            elif step.type == 'add_craft':
                name = 'interceptor' # step.craft TODO fix me
            filtered_blocks = self.filter_blocks(generator, group, size, name)
            if step.condition:
                if not self.meets_conditions(step):
                    if step.label:
                        self.context.add(-step.label)
                    continue
            if not filtered_blocks and step.type != 'fill_block':
                if step.label:
                    self.context.add(-step.label)
                continue
            if step.type == 'add_line':
                self.process_add_line(generator, step, filtered_blocks)
            elif step.type == 'add_block':
                self.process_add_block(generator, step, filtered_blocks, block_counts)
            elif step.type == 'fill_block':
                self.process_fill_block(generator, step, filtered_blocks)
            elif step.type == 'add_ufo':
                self.process_add_special(generator, step, filtered_blocks, 'ufo')
            elif step.type == 'add_craft':
                self.process_add_special(generator, step, filtered_blocks, 'craft')
            if step.label:
                self.context.add(step.label)

    def filter_blocks(self, generator, group: int = None, size: int = None, name: str = None) -> List[TMapBlock]:
        """
        Filter available map block entries by group, size, and/or name.
        """
        blocks: List[TMapBlock] = generator.terrain.map_blocks_entries.copy()
        if group is not None:
            blocks = [b for b in blocks if b.group == group]
        if size is not None:
            blocks = [b for b in blocks if b.size == size]
        if name is not None:
            blocks = [b for b in blocks if b.map == name]
        return blocks

    def place_large_block(self, generator, block_entry, x: int, y: int) -> bool:
        """
        Place a large block on the map grid at (x, y), marking the top-left with the block name and the rest with '-'.
        Returns True if placed, False if not possible.
        """
        width: int = block_entry.size
        height: int = block_entry.size
        if y + height > generator.map_height or x + width > generator.map_width:
            return False
        for dy in range(height):
            for dx in range(width):
                if generator.block_grid[y+dy][x+dx] is not None:
                    return False
        generator.block_grid[y][x] = block_entry.map
        for dy in range(height):
            for dx in range(width):
                if dy != 0 or dx != 0:
                    generator.block_grid[y+dy][x+dx] = '-'
        return True

    def process_add_line(self, generator, step: TBattleScriptStep, blocks: List[TMapBlock]) -> None:
        """
        Add blocks in a line according to direction (horizontal, vertical, or both).
        For 'both', fill both a random row and a random column independently.
        """
        import random
        direction = step.direction
        runs = step.runs
        row = step.row
        col = step.col
        for _ in range(runs):
            if direction == 'horizontal':
                y = row if row is not None else random.randint(0, generator.map_height - 1)
                for x in range(generator.map_width):
                    if generator.block_grid[y][x] is None and blocks:
                        block_entry = random.choice(blocks)
                        self.place_large_block(generator, block_entry, x, y)
            elif direction == 'vertical':
                x = col if col is not None else random.randint(0, generator.map_width - 1)
                for y in range(generator.map_height):
                    if generator.block_grid[y][x] is None and blocks:
                        block_entry = random.choice(blocks)
                        self.place_large_block(generator, block_entry, x, y)
            elif direction == 'both':
                y = row if row is not None else random.randint(0, generator.map_height - 1)
                for x in range(generator.map_width):
                    if generator.block_grid[y][x] is None and blocks:
                        block_entry = random.choice(blocks)
                        self.place_large_block(generator, block_entry, x, y)
                x = col if col is not None else random.randint(0, generator.map_width - 1)
                for y in range(generator.map_height):
                    if generator.block_grid[y][x] is None and blocks:
                        block_entry = random.choice(blocks)
                        self.place_large_block(generator, block_entry, x, y)

    def process_add_block(self, generator, step: TBattleScriptStep, blocks: List[TMapBlock], block_counts: dict[str, int]) -> None:
        """
        Add a random block to a random available position on the map.
        Take into account max count if specified (runs).
        Handles large blocks by only assigning the top-left cell, and marking the rest with '-'.
        Ensures blocks are placed in random positions, not always from top-left.
        """
        import random
        max_count = step.runs
        group_key = f"block_{step.group}_{step.size}"
        current_count = block_counts.get(group_key, 0)
        runs = min(max_count, generator.map_width * generator.map_height - current_count)
        placed = 0
        for _ in range(runs):
            if not blocks:
                break
            block_entry = random.choice(blocks)
            width = block_entry.size
            height = block_entry.size
            possible_positions: List[tuple[int, int]] = []
            for y in range(generator.map_height - height + 1):
                for x in range(generator.map_width - width + 1):
                    fits = True
                    for dy in range(height):
                        for dx in range(width):
                            if generator.block_grid[y+dy][x+dx] is not None:
                                fits = False
                                break
                        if not fits:
                            break
                    if fits:
                        possible_positions.append((x, y))
            if possible_positions:
                x, y = random.choice(possible_positions)
                self.place_large_block(generator, block_entry, x, y)
                placed += 1
            block_counts[group_key] = block_counts.get(group_key, 0) + 1
            current_count = block_counts[group_key]
            if current_count >= max_count:
                break

    def process_fill_block(self, generator, step: TBattleScriptStep, blocks: List[TMapBlock]) -> None:
        """
        Fill all remaining empty positions with random blocks.
        Handles large blocks by only assigning the top-left cell, and marking the rest with '-'.
        Runs up to 1000 times or until all cells are filled.
        """
        import random
        if not blocks or len(blocks) == 0:
            return
        for _ in range(1000):
            empty_found = False
            for y in range(generator.map_height):
                for x in range(generator.map_width):
                    if generator.block_grid[y][x] is None:
                        empty_found = True
                        block_entry = random.choice(blocks)
                        width = block_entry.size
                        height = block_entry.size
                        placed = False
                        for yy in range(generator.map_height - height + 1):
                            for xx in range(generator.map_width - width + 1):
                                if all(generator.block_grid[yy+dy][xx+dx] is None for dy in range(height) for dx in range(width)):
                                    self.place_large_block(generator, block_entry, xx, yy)
                                    placed = True
                                    break
                            if placed:
                                break
                        if not placed:
                            single_blocks = [b for b in blocks if b.size == 1]
                            if single_blocks:
                                self.place_large_block(generator, single_blocks[0], x, y)
                        break
                if empty_found:
                    break
            if not empty_found:
                break

    def process_add_special(self, generator, step: TBattleScriptStep, blocks: List[TMapBlock], special_type: str) -> None:
        """
        Add a special block (by name) to the first available position where it fits, replacing any existing block.
        The special block name is provided as special_type.
        """
        import random
        special_blocks = [b for b in blocks if b.map == special_type]
        if not special_blocks:
            return
        block_entry = special_blocks[0]
        width = block_entry.size
        height = block_entry.size
        for y in range(generator.map_height - height + 1):
            for x in range(generator.map_width - width + 1):
                self.place_large_block(generator, block_entry, x, y)
                return

    def meets_conditions(self, step: TBattleScriptStep) -> bool:
        """
        Check if all conditions for this step are met based on a set of numeric labels.
        Args:
            step (TBattleScriptStep): The step to check conditions for.
        Returns:
            bool: True if all conditions are met, False otherwise
        """
        if not step.condition:
            return True
        for condition in step.condition:
            try:
                condition_value = int(condition)
                if condition_value > 0:
                    if condition_value not in self.context:
                        return False
                elif condition_value < 0:
                    if abs(condition_value) in self.context:
                        return False
            except ValueError:
                continue
        return True
