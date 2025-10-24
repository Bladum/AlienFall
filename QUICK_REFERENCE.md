# Quick Reference: API Validation & Mock Data Tools

**Last Updated:** October 24, 2025

---

## 🚀 Quick Start

### Validate a Mod

```bash
lovec tools/validators/validate_mod.lua mods/core
```

### Generate Test Data

```bash
lovec tools/generators/generate_mock_data.lua
```

---

## 📋 Validator Commands

```bash
# Basic validation
lovec tools/validators/validate_mod.lua mods/core

# Show all files
lovec tools/validators/validate_mod.lua mods/core --verbose

# JSON output (for CI/CD)
lovec tools/validators/validate_mod.lua mods/core --json

# Only validate units
lovec tools/validators/validate_mod.lua mods/core --category units

# Save report
lovec tools/validators/validate_mod.lua mods/core --output report.md

# Custom schema
lovec tools/validators/validate_mod.lua mods/core --schema custom.toml
```

**Result:** `0` = pass, `1` = errors

---

## 🎲 Generator Commands

```bash
# Default (realistic mod)
lovec tools/generators/generate_mock_data.lua

# Minimal (fast tests)
lovec tools/generators/generate_mock_data.lua --strategy minimal

# Coverage (all features)
lovec tools/generators/generate_mock_data.lua --strategy coverage

# Stress test (large mod)
lovec tools/generators/generate_mock_data.lua --strategy stress --count 10

# Reproducible (same seed = same data)
lovec tools/generators/generate_mock_data.lua --seed 42

# Only units and items
lovec tools/generators/generate_mock_data.lua --categories units,items

# Custom location
lovec tools/generators/generate_mock_data.lua --output mods/my_mod
```

---

## 📁 File Structure

### Validator

```
tools/validators/
├── validate_mod.lua          # Main script
├── lib/
│   ├── schema_loader.lua     # Loads GAME_API.toml
│   ├── file_scanner.lua      # Finds & categorizes files
│   ├── type_validator.lua    # Validates types & values
│   └── report_generator.lua  # Formats output
└── README.md                 # Full documentation
```

### Generator

```
tools/generators/
├── generate_mock_data.lua    # Main script
├── lib/
│   ├── name_generator.lua    # Realistic names
│   ├── id_generator.lua      # Consistent IDs
│   ├── data_generator.lua    # Generate values
│   └── toml_writer.lua       # Write TOML files
└── README.md                 # Full documentation
```

### Schema & Guides

```
api/
├── GAME_API.toml             # Master schema
├── GAME_API_GUIDE.md         # How to read schema
├── SYNCHRONIZATION_GUIDE.md  # Keep things in sync
└── MODDING_GUIDE.md          # For mod creators
```

---

## 🔍 Common Validation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Type mismatch | Wrong type (e.g., `"25"` not `25`) | Remove quotes for numbers |
| Invalid enum | Wrong value | Check GAME_API.toml for valid options |
| Below minimum | Value too low | Increase to min value |
| Exceeds maximum | Value too high | Decrease to max value |
| Required field missing | Forgot a field | Add field with valid value |
| Pattern mismatch | Wrong format (e.g., `My-Item` not `my_item`) | Use snake_case |
| Unknown field | Not in schema | Check schema or remove field |

---

## 🎯 Generation Strategies

| Strategy | Size | Speed | Use Case |
|----------|------|-------|----------|
| minimal | ~8 entities | 100ms | Tests, CI/CD |
| coverage | ~30 entities | 250ms | API validation |
| realistic | ~50 entities | 400ms | Gameplay testing |
| stress | ~500+ entities | 3-8s | Performance testing |

---

## 🔗 Integration Examples

### CI/CD Pipeline

```bash
# Generate test mod
lovec tools/generators/generate_mock_data.lua --seed $CI_COMMIT_SHA

# Validate it
lovec tools/validators/validate_mod.lua mods/synth_mod --json > validation.json

# Fail if errors
if [ $? -ne 0 ]; then exit 1; fi
```

### Pre-commit Hook

```bash
#!/bin/bash
lovec tools/validators/validate_mod.lua mods/core
if [ $? -ne 0 ]; then
  echo "Validation failed - commit blocked"
  exit 1
fi
```

### VS Code Task

Add to `.vscode/tasks.json`:

```json
{
  "label": "🔍 Validate Core Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/validators/validate_mod.lua", "mods/core"],
  "group": "test"
}
```

---

## 📊 Output Formats

### Console (Default)

```
✓ Valid file
✗ File with errors
⚠ File with warnings
```

### JSON (Machine-Readable)

```json
{
  "summary": { "filesChecked": 45, "totalErrors": 3 },
  "files": [{"path": "...", "errors": [...]}]
}
```

### Markdown (Documentation)

```markdown
# Validation Report
## Errors
### file.toml
- Error message
```

---

## 🛠️ Development Workflow

### Step 1: Generate Test Mod
```bash
lovec tools/generators/generate_mock_data.lua --output mods/test
```

### Step 2: Validate It
```bash
lovec tools/validators/validate_mod.lua mods/test
```

### Step 3: Load in Game
```bash
lovec engine  # Game loads mods automatically
```

### Step 4: Test Your Mod
Edit TOML files, re-validate, reload in game

---

## 📚 Documentation Links

- **Full Validator Guide:** `tools/validators/README.md`
- **Full Generator Guide:** `tools/generators/README.md`
- **Schema Guide:** `api/GAME_API_GUIDE.md`
- **Sync Guide:** `api/SYNCHRONIZATION_GUIDE.md`
- **Completion Summary:** `COMPLETION_SUMMARY.md`

---

## 🐛 Troubleshooting

### Validator won't start
- Use `lovec`, not `lua`
- Check `api/GAME_API.toml` exists

### Generator creates empty folders
- Check output path is writable
- Use `--categories units` to test one type

### Validation passes but mod won't load
- Check TOML file encoding (must be UTF-8)
- Verify field names match exactly (case-sensitive)
- Check for hidden special characters

### Slow generation
- Use `--strategy minimal` for testing
- Use `--categories units,items` to limit types
- Reduce `--count` multiplier for stress tests

---

## 🎓 Learning Path

1. **Start:** Read `tools/validators/README.md`
2. **Try:** Run basic validation
3. **Learn:** Read `api/GAME_API_GUIDE.md`
4. **Generate:** Try mock data generator
5. **Integrate:** Add to your workflow
6. **Advanced:** Read sync guide, customize

---

## 📞 Support

**For issues:**
1. Check documentation in tool README
2. Review GAME_API.toml for field definitions
3. Test with `--strategy minimal`
4. Run with `--verbose` for details
5. Check error messages for hints

---

## ✅ Checklist

- [ ] Validator works on your mod: `lovec tools/validators/validate_mod.lua mods/your_mod`
- [ ] Generator creates mod: `lovec tools/generators/generate_mock_data.lua`
- [ ] Generated mod validates: Run validator on generated mod
- [ ] Exit codes work: Check `$?` or `%ERRORLEVEL%`
- [ ] JSON output works: Add `--json` to commands
- [ ] Documentation is clear: Read README files

---

**Questions? Check the full documentation!**
