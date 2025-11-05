#!/usr/bin/env python3
"""
Advanced standardizer that extracts actual headings and regenerates TOC correctly.
"""

import os
import re
from pathlib import Path
from typing import List, Tuple

class AdvancedMechanicsStandardizer:
    def __init__(self, mechanics_dir: str):
        self.mechanics_dir = Path(mechanics_dir)
        self.files = list(self.mechanics_dir.glob("*.md"))
        self.files.sort()

    def _text_to_anchor(self, text: str) -> str:
        """Convert heading text to anchor ID (lowercase, hyphens)."""
        # Remove emojis and special characters
        text = re.sub(r'[^\w\s-]', '', text)
        text = text.lower().strip()
        text = re.sub(r'\s+', '-', text)
        return text

    def extract_all_headings(self, content: str) -> List[Tuple[int, str, str]]:
        """Extract all markdown headings with their anchor IDs."""
        headings = []
        for match in re.finditer(r'^(#{1,6})\s+(.+?)(?:\s*\{#(.+?)\})?\s*$', content, re.MULTILINE):
            level = len(match.group(1))
            text = match.group(2).strip()
            # Remove leading/trailing whitespace and special chars
            text = re.sub(r'[*`_~]', '', text).strip()
            anchor = match.group(3) if match.group(3) else self._text_to_anchor(text)
            headings.append((level, text, anchor))
        return headings

    def find_toc_section(self, content: str) -> Tuple[int, int]:
        """Find line numbers of existing TOC section."""
        lines = content.split('\n')
        toc_start = -1
        toc_end = -1

        for i, line in enumerate(lines):
            if re.match(r'^##\s+(Table of Contents|TOC|Contents)', line):
                toc_start = i
            elif toc_start != -1:
                # TOC ends at next section or separator
                if line.startswith('---') or re.match(r'^##[^#]', line):
                    toc_end = i
                    break

        return (toc_start, toc_end)

    def generate_toc_lines(self, headings: List[Tuple[int, str, str]], skip_level_1: bool = True) -> List[str]:
        """Generate TOC lines from headings."""
        if not headings:
            return []

        toc_lines = ["## Table of Contents", ""]

        # Skip level 1 (main title)
        relevant_headings = [h for h in headings if not (skip_level_1 and h[0] == 1)]

        if not relevant_headings:
            return toc_lines

        # Find minimum level for proper indentation
        min_level = min(h[0] for h in relevant_headings)

        for level, text, anchor in relevant_headings:
            indent = "  " * (level - min_level)
            link = f"[{text}](#{anchor})"
            toc_lines.append(f"{indent}- {link}")

        return toc_lines

    def rebuild_content(self, filepath: Path) -> Tuple[str, int]:
        """Rebuild content with proper TOC.
        Returns (new_content, num_changes)"""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        lines = content.split('\n')

        # Find main title
        title = ""
        title_idx = -1
        for i, line in enumerate(lines):
            if line.startswith('# '):
                title = line[2:].strip()
                title_idx = i
                break

        if not title:
            return content, 0

        # Find and extract frontmatter
        frontmatter_lines = []
        frontmatter_end = -1
        for i in range(title_idx + 1, len(lines)):
            line = lines[i]
            if line.startswith('>'):
                frontmatter_lines.append(line)
            elif line.strip() == '':
                if frontmatter_lines:
                    frontmatter_end = i
                    break
            elif frontmatter_lines:
                frontmatter_end = i
                break

        # Get content after title and frontmatter
        content_start = frontmatter_end + 1 if frontmatter_end != -1 else title_idx + 1
        rest_content = '\n'.join(lines[content_start:])

        # Extract all headings from rest of content
        headings = self.extract_all_headings(rest_content)

        # Find and remove old TOC
        toc_start, toc_end = self.find_toc_section(rest_content)

        if toc_start != -1 and toc_end != -1:
            # Remove old TOC
            rest_lines = rest_content.split('\n')
            rest_content = '\n'.join(rest_lines[toc_end:])

        # Generate new TOC
        toc_lines = self.generate_toc_lines(headings, skip_level_1=True)

        # Build new content
        output_lines = []
        output_lines.append(f"# {title}")
        output_lines.append('')

        if frontmatter_lines:
            output_lines.extend(frontmatter_lines)
            output_lines.append('')

        output_lines.append('')
        output_lines.extend(toc_lines)
        output_lines.append('')
        output_lines.append('---')
        output_lines.append('')

        # Add rest of content, cleaning up extra blank lines at start
        rest_lines = rest_content.split('\n')
        for i, line in enumerate(rest_lines):
            if i == 0:
                # Skip leading blank lines
                if line.strip():
                    output_lines.append(line)
            else:
                output_lines.append(line)

        new_content = '\n'.join(output_lines)

        # Count changes
        num_changes = 1 if new_content != content else 0

        return new_content, num_changes

    def process_all_files(self) -> dict:
        """Process all files and return results."""
        results = {
            'total': len(self.files),
            'updated': 0,
            'failed': 0,
            'details': []
        }

        for filepath in self.files:
            try:
                new_content, changes = self.rebuild_content(filepath)

                if changes > 0:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    results['updated'] += 1
                    status = "✓ UPDATED"
                else:
                    status = "= UNCHANGED"

                results['details'].append({
                    'file': filepath.name,
                    'status': status,
                    'changes': changes
                })

            except Exception as e:
                results['failed'] += 1
                results['details'].append({
                    'file': filepath.name,
                    'status': '✗ FAILED',
                    'error': str(e)[:50]
                })

        return results

def main():
    mechanics_dir = r"c:\Users\tombl\Documents\Projects\design\mechanics"

    print("\n" + "=" * 80)
    print("ADVANCED MECHANICS STANDARDIZER - TOC REGENERATION")
    print("=" * 80 + "\n")

    standardizer = AdvancedMechanicsStandardizer(mechanics_dir)
    print(f"Processing {len(standardizer.files)} mechanics files...\n")

    results = standardizer.process_all_files()

    print("RESULTS:")
    print("-" * 80)
    for detail in results['details']:
        print(f"{detail['status']:12} {detail['file']:40}", end="")
        if detail.get('error'):
            print(f" {detail['error']}")
        else:
            print()

    print()
    print("SUMMARY:")
    print(f"  Total files:   {results['total']}")
    print(f"  Updated:       {results['updated']}")
    print(f"  Failed:        {results['failed']}")
    print()
    print("=" * 80 + "\n")

if __name__ == '__main__':
    main()
