# Documentation Export Pipeline

This directory contains tools for exporting the Alien Fall wiki documentation to various formats.

---

## Available Export Formats

### 1. GitHub Pages (MkDocs)
**Live website with search, navigation, and theme**

**Setup:**
```bash
# Install MkDocs with Material theme
pip install mkdocs-material

# Install optional plugins
pip install mkdocs-git-revision-date-localized-plugin
pip install mkdocs-minify-plugin
```

**Build locally:**
```bash
# From project root
mkdocs serve

# Open browser to http://localhost:8000
```

**Deploy to GitHub Pages:**
```bash
# Linux/macOS
./tools/docs/deploy_docs.sh

# Windows PowerShell
.\tools\docs\deploy_docs.ps1

# Or directly with mkdocs
mkdocs gh-deploy
```

**Result:** Documentation available at `https://alienfall.github.io/alienfall`

---

### 2. PDF Export
**Single PDF file with all documentation**

**Setup:**
```bash
# Install pandoc
# Windows: choco install pandoc
# macOS: brew install pandoc
# Linux: apt-get install pandoc

# Install LaTeX (for PDF generation)
# Windows: choco install miktex
# macOS: brew install basictex
# Linux: apt-get install texlive-latex-base
```

**Generate PDF:**
```bash
python tools/docs/generate_pdf.py

# Output: dist/AlienFall_Documentation.pdf
```

**Features:**
- Auto-generated table of contents
- Numbered sections
- Syntax-highlighted code blocks
- Page breaks between documents
- Searchable text

---

### 3. In-Game Help System
**Context-sensitive help accessible in-game**

**Status:** Planned for v0.5.0

**Design:**
- Markdown files loaded at runtime
- F1 key opens context-sensitive help
- Search functionality
- Bookmark favorite pages
- Offline-first (no internet required)

**Implementation Notes:**
```lua
-- HelpSystem.lua
function HelpSystem:showHelp(topic)
    local doc = self:loadMarkdown("wiki/" .. topic .. ".md")
    local rendered = self:renderMarkdown(doc)
    self.help_window:setContent(rendered)
    self.help_window:show()
end

-- Usage in game
if key == "f1" then
    HelpSystem:showHelp("battlescape/Combat")
end
```

---

## Configuration

### MkDocs Configuration
Edit `mkdocs.yml` in project root:

```yaml
site_name: Alien Fall Wiki
theme:
  name: material
  palette:
    primary: indigo
    accent: blue
nav:
  # Define navigation structure
```

### PDF Configuration
Edit `tools/docs/generate_pdf.py`:

```python
# Document order
DOCUMENT_ORDER = [
    "README.md",
    "meta/tutorials/QuickStart_Guide.md",
    # ... add more documents
]

# PDF settings
PANDOC_OPTIONS = [
    "--toc",  # Table of contents
    "--number-sections",
    "--highlight-style", "tango",
]
```

---

## Automation

### GitHub Actions (CI/CD)
**Auto-deploy on push to main branch**

Create `.github/workflows/docs.yml`:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'wiki/**'
      - 'mkdocs.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'
      
      - name: Install dependencies
        run: |
          pip install mkdocs-material
          pip install mkdocs-git-revision-date-localized-plugin
      
      - name: Deploy docs
        run: mkdocs gh-deploy --force
```

---

## Export Quality Checklist

Before deploying documentation:

- [ ] All markdown files use valid syntax
- [ ] Internal links use correct format `[[page]]` or `[text](page.md)`
- [ ] Images referenced exist in correct locations
- [ ] Code blocks have language specified for syntax highlighting
- [ ] Mermaid diagrams render correctly
- [ ] No broken links (run link checker)
- [ ] Table of contents accurate
- [ ] Search functionality works
- [ ] Mobile responsive (for web version)
- [ ] PDF generates without errors

---

## Troubleshooting

### MkDocs build fails
**Error:** `Config file 'mkdocs.yml' does not exist`
**Solution:** Run from project root directory

**Error:** `Could not import extension...`
**Solution:** Install missing plugin with `pip install <plugin-name>`

### PDF generation fails
**Error:** `pandoc: command not found`
**Solution:** Install pandoc (see setup instructions above)

**Error:** `pdflatex not found`
**Solution:** Install LaTeX distribution (MiKTeX, BasicTeX, or TeX Live)

**Error:** `Package inputenc Error: Unicode character`
**Solution:** Ensure all markdown files use UTF-8 encoding

### GitHub Pages not updating
**Error:** Changes not visible on site
**Solution:** 
1. Check GitHub Actions tab for deployment status
2. Clear browser cache
3. Wait 5-10 minutes for CDN propagation
4. Verify `gh-pages` branch updated

---

## Maintenance

### Regular Tasks
- **Weekly:** Check for broken links
- **Monthly:** Update PDF export
- **Release:** Full documentation review and export update

### Version Tagging
Tag documentation versions to match game releases:

```bash
# Tag current documentation
git tag -a docs-v0.4.0 -m "Documentation for v0.4.0"
git push origin docs-v0.4.0

# MkDocs versioning (requires mike)
pip install mike
mike deploy --push --update-aliases 0.4 latest
```

---

## Related Documentation

- [[../../wiki/meta/community/Contributing_Guidelines]] - How to contribute
- [[../../wiki/DOCUMENTATION_IMPROVEMENT_PLAN]] - Documentation roadmap
- MkDocs Documentation: https://www.mkdocs.org/
- Material Theme: https://squidfunk.github.io/mkdocs-material/
- Pandoc Manual: https://pandoc.org/MANUAL.html

---

**Last Updated:** September 30, 2025  
**Maintainer:** Documentation Team
