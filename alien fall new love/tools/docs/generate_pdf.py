#!/usr/bin/env python3
"""
PDF Documentation Generator for Alien Fall Wiki

This script compiles the wiki markdown files into a single PDF document
using markdown-pdf or pandoc.

Usage:
    python tools/docs/generate_pdf.py

Output:
    dist/AlienFall_Documentation.pdf
"""

import os
import sys
import subprocess
from pathlib import Path
import datetime

# Configuration
WIKI_DIR = Path("wiki")
OUTPUT_DIR = Path("dist")
OUTPUT_FILE = OUTPUT_DIR / "AlienFall_Documentation.pdf"
TEMP_FILE = OUTPUT_DIR / "combined.md"

# Document order (mirrors navigation structure)
DOCUMENT_ORDER = [
    "README.md",
    "meta/tutorials/QuickStart_Guide.md",
    "meta/tutorials/First_Mission_Walkthrough.md",
    "meta/tutorials/Base_Building_101.md",
    "meta/tutorials/Research_Strategy_Guide.md",
    "meta/tutorials/Tactical_Combat_Basics.md",
    "meta/tutorials/Intermediate_Strategies.md",
    "meta/Glossary.md",
    "geoscape/README.md",
    "battlescape/README.md",
    "basescape/README.md",
    "economy/README.md",
    "units/README.md",
    "items/README.md",
    "mods/README.md",
    "mods/Getting_Started.md",
    "mods/API_Reference.md",
    "meta/content_pipeline/README.md",
    "technical/README.md",
    "integration/README.md",
    "meta/community/README.md",
    "meta/community/FAQ.md",
    "meta/community/Contributing_Guidelines.md",
]

def check_dependencies():
    """Check if required tools are installed."""
    tools = ["pandoc"]
    missing = []
    
    for tool in tools:
        try:
            subprocess.run([tool, "--version"], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            missing.append(tool)
    
    if missing:
        print(f"Error: Missing required tools: {', '.join(missing)}")
        print("\nInstall with:")
        print("  Windows: choco install pandoc")
        print("  macOS: brew install pandoc")
        print("  Linux: apt-get install pandoc")
        sys.exit(1)

def combine_markdown_files():
    """Combine all markdown files into single document."""
    print("Combining markdown files...")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    with open(TEMP_FILE, 'w', encoding='utf-8') as outfile:
        # Add title page
        outfile.write("---\n")
        outfile.write("title: Alien Fall - Complete Documentation\n")
        outfile.write(f"date: {datetime.date.today().strftime('%B %d, %Y')}\n")
        outfile.write("author: Alien Fall Development Team\n")
        outfile.write("---\n\n")
        outfile.write("# Alien Fall\n\n")
        outfile.write("## Complete Documentation\n\n")
        outfile.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")
        outfile.write("---\n\n")
        outfile.write("\\pagebreak\n\n")
        
        # Add table of contents placeholder
        outfile.write("# Table of Contents\n\n")
        outfile.write("*Generated automatically by pandoc*\n\n")
        outfile.write("\\pagebreak\n\n")
        
        # Combine documents in order
        for doc_path in DOCUMENT_ORDER:
            file_path = WIKI_DIR / doc_path
            
            if not file_path.exists():
                print(f"Warning: File not found: {file_path}")
                continue
            
            print(f"  Adding: {doc_path}")
            
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                
                # Add section break
                outfile.write(f"\n\n\\pagebreak\n\n")
                
                # Write content
                outfile.write(content)
                outfile.write("\n\n")
    
    print(f"Combined markdown saved to: {TEMP_FILE}")

def generate_pdf():
    """Generate PDF from combined markdown using pandoc."""
    print("Generating PDF...")
    
    cmd = [
        "pandoc",
        str(TEMP_FILE),
        "-o", str(OUTPUT_FILE),
        "--from", "markdown",
        "--to", "pdf",
        "--toc",  # Table of contents
        "--toc-depth=3",
        "--number-sections",
        "--highlight-style", "tango",
        "--pdf-engine", "pdflatex",
        "-V", "geometry:margin=1in",
        "-V", "fontsize=11pt",
        "-V", "documentclass=report",
        "-V", "colorlinks=true",
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"\n✓ PDF generated successfully: {OUTPUT_FILE}")
        print(f"  File size: {OUTPUT_FILE.stat().st_size / 1024 / 1024:.2f} MB")
    except subprocess.CalledProcessError as e:
        print(f"\nError generating PDF:")
        print(e.stderr)
        sys.exit(1)

def cleanup():
    """Remove temporary files."""
    if TEMP_FILE.exists():
        TEMP_FILE.unlink()
        print(f"Cleaned up temporary file: {TEMP_FILE}")

def main():
    """Main execution."""
    print("=" * 60)
    print("Alien Fall Documentation - PDF Generator")
    print("=" * 60)
    print()
    
    check_dependencies()
    combine_markdown_files()
    generate_pdf()
    cleanup()
    
    print("\n" + "=" * 60)
    print("✓ PDF generation complete!")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nOperation cancelled by user.")
        cleanup()
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
