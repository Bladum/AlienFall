#!/bin/bash
# Deploy MkDocs documentation to GitHub Pages

set -e  # Exit on error

echo "================================"
echo "Deploying Alien Fall Wiki"
echo "================================"
echo ""

# Check if mkdocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "Error: mkdocs not installed"
    echo "Install with: pip install mkdocs-material"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "mkdocs.yml" ]; then
    echo "Error: mkdocs.yml not found"
    echo "Run this script from the project root"
    exit 1
fi

# Build the documentation
echo "Building documentation..."
mkdocs build --clean

# Deploy to GitHub Pages
echo ""
echo "Deploying to GitHub Pages..."
mkdocs gh-deploy --force

echo ""
echo "================================"
echo "✓ Deployment complete!"
echo "================================"
echo ""
echo "Documentation available at:"
echo "https://alienfall.github.io/alienfall"
