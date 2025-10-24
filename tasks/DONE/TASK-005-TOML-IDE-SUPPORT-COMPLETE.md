# Task: Enable TOML Validation in VS Code with Language Server

**Status:** TODO
**Priority:** Medium
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:** TASK-001 (GAME_API.toml must exist)

---

## Overview

Implement real-time TOML validation in VS Code editor using Language Server Protocol (LSP) or VS Code extension. Enable auto-completion, error highlighting, and inline documentation while editing mod TOML files, similar to YAML validation from Red Hat.

---

## Purpose

**Why this is needed:**
- Mod creators currently have no editor support
- Typos in field names only caught at runtime
- No autocomplete for valid fields
- No inline documentation
- No real-time type checking
- Manual validation is slow (run script, fix, repeat)
- Poor developer experience compared to modern IDEs

**What problem it solves:**
- Real-time error detection (red squiggles)
- Autocomplete valid field names
- Inline documentation (hover tooltips)
- Enum value suggestions
- Type checking as you type
- Faster mod development
- Better mod quality
- Modern IDE experience

**Reference Example:**
Red Hat YAML extension validates Ansible playbooks, Kubernetes manifests, etc. using schema files and shows errors in real-time. We want the same for our TOML files.

---

## Requirements

### Functional Requirements
- [ ] Real-time syntax validation (highlight TOML syntax errors)
- [ ] Schema-based validation (check against GAME_API.toml)
- [ ] Autocomplete field names based on context
- [ ] Autocomplete enum values
- [ ] Hover tooltips showing field documentation
- [ ] Error messages inline (red squiggles)
- [ ] Warning messages inline (yellow squiggles)
- [ ] Jump to definition (Ctrl+click on reference)
- [ ] Find all references (right-click -> Find References)
- [ ] Validate file location (warn if file in wrong folder)
- [ ] Support all TOML files in mods/ folder
- [ ] Update validation when GAME_API.toml changes

### Technical Requirements
- [ ] VS Code extension OR Language Server Protocol server
- [ ] Works on Windows, macOS, Linux
- [ ] Low CPU/memory usage (responsive editor)
- [ ] Uses GAME_API.toml as schema source
- [ ] Written in TypeScript (for VS Code extension) or Lua (for LSP server)
- [ ] Distributable via VS Code Marketplace OR included in project
- [ ] Configuration in .vscode/settings.json
- [ ] Clear installation/setup instructions

### Acceptance Criteria
- [ ] Extension/LSP server exists and can be installed
- [ ] Opens TOML file in mods/ folder -> validation active
- [ ] Type wrong field name -> red squiggle appears
- [ ] Start typing field name -> autocomplete suggestions appear
- [ ] Hover over field -> documentation tooltip appears
- [ ] Type invalid enum value -> error highlighted
- [ ] Type wrong type (string instead of int) -> error highlighted
- [ ] Missing required field -> error highlighted
- [ ] Performance acceptable (no lag while typing)
- [ ] Documentation explains setup and usage

---

## Plan

### Step 1: Research and Choose Approach
**Description:** Decide on implementation strategy

**Options:**

**Option A: VS Code Extension (Recommended)**
- Pros:
  - Full control over features
  - Direct VS Code API access
  - Can bundle with project
  - TypeScript/JavaScript (common)
- Cons:
  - VS Code specific
  - More complex to build
  - Requires Node.js/TypeScript knowledge

**Option B: Language Server Protocol (LSP)**
- Pros:
  - Works with any LSP-compatible editor
  - Can write in Lua (matches project)
  - Follows standard protocol
- Cons:
  - More setup for users
  - Less direct control
  - Need to implement LSP spec

**Option C: Use Existing Extension + Schema**
- Pros:
  - Fastest to implement
  - Use existing TOML extensions
  - Just need schema file
- Cons:
  - Limited by extension capabilities
  - May not support all features
  - Less customization

**Recommendation:** Start with **Option C** (use existing extension), then move to **Option A** (custom extension) if needed.

**Actions:**
1. Research existing VS Code TOML extensions
2. Check if they support JSON Schema or similar
3. Convert GAME_API.toml to schema format if possible
4. If not possible, proceed with Option A

**Estimated time:** 3-4 hours research and planning

---

### Step 2: Convert GAME_API.toml to JSON Schema
**Description:** Create JSON Schema representation of GAME_API.toml

**Why JSON Schema:**
- Many VS Code extensions support JSON Schema
- Standard format for validation
- Can be generated from GAME_API.toml

**File to create:** `api/GAME_API.schema.json`

**Schema structure:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AlienFall Game API Schema",
  "description": "Schema for game mod TOML files",

  "definitions": {
    "unit": {
      "type": "object",
      "required": ["id", "name", "type"],
      "properties": {
        "id": {
          "type": "string",
          "description": "Unique unit identifier"
        },
        "name": {
          "type": "string",
          "description": "Display name for the unit"
        },
        "type": {
          "type": "string",
          "enum": ["soldier", "alien", "civilian"],
          "description": "Type of unit"
        },
        "stats": {
          "type": "object",
          "properties": {
            "health": {
              "type": "integer",
              "minimum": 1,
              "maximum": 999,
              "description": "Health points"
            },
            "time_units": {
              "type": "integer",
              "minimum": 1,
              "maximum": 255,
              "description": "Time units per turn"
            }
          }
        }
      }
    },

    "item": {
      "type": "object",
      "required": ["id", "name", "type"],
      "properties": {
        "id": {
          "type": "string",
          "description": "Unique item identifier"
        },
        "name": {
          "type": "string",
          "description": "Display name"
        },
        "type": {
          "type": "string",
          "enum": ["weapon", "armor", "equipment", "ammo"],
          "description": "Item type"
        }
      }
    }

    // ... more definitions for all entity types
  }
}
```

**Tool to create:** `tools/schema/generate_json_schema.lua`
- Reads GAME_API.toml
- Converts to JSON Schema
- Writes api/GAME_API.schema.json

**Estimated time:** 6-8 hours

---

### Step 3: Test with Existing TOML Extensions
**Description:** Try existing VS Code TOML extensions with schema

**Extensions to test:**
1. **Even Better TOML** (tamasfe.even-better-toml)
   - Most popular TOML extension
   - Syntax highlighting, formatting
   - Check if supports schema validation

2. **TOML Language Support** (be5invis.toml)
   - Basic TOML support
   - Syntax highlighting

3. **Better TOML** (bungcip.better-toml)
   - Syntax highlighting, validation

**Test configuration:**
```json
// .vscode/settings.json
{
  "evenBetterToml.schema.enabled": true,
  "evenBetterToml.schema.associations": {
    "mods/**/rules/**/*.toml": "api/GAME_API.schema.json"
  }
}
```

**If existing extensions work:**
- Document configuration
- Update .vscode/settings.json
- Create setup guide
- DONE (easiest path)

**If existing extensions don't work:**
- Proceed to Step 4 (build custom extension)

**Estimated time:** 2-3 hours

---

### Step 4: Build Custom VS Code Extension (if needed)
**Description:** Create custom extension with full features

**Project structure:**
```
tools/vscode-extension-alienfall-toml/
├── package.json
├── tsconfig.json
├── src/
│   ├── extension.ts (entry point)
│   ├── schemaLoader.ts
│   ├── validator.ts
│   ├── completion.ts
│   ├── hover.ts
│   └── diagnostics.ts
├── syntaxes/
│   └── alienfall-toml.tmLanguage.json
├── schemas/
│   └── game-api.schema.json
└── README.md
```

**package.json:**
```json
{
  "name": "alienfall-toml",
  "displayName": "AlienFall TOML Support",
  "description": "TOML validation and autocomplete for AlienFall mods",
  "version": "0.1.0",
  "publisher": "alienfall",
  "engines": {
    "vscode": "^1.75.0"
  },
  "categories": ["Programming Languages", "Linters"],
  "activationEvents": [
    "onLanguage:toml"
  ],
  "main": "./out/extension.js",
  "contributes": {
    "languages": [
      {
        "id": "alienfall-toml",
        "aliases": ["AlienFall TOML", "alienfall-toml"],
        "extensions": [".toml"],
        "configuration": "./language-configuration.json"
      }
    ],
    "configuration": {
      "title": "AlienFall TOML",
      "properties": {
        "alienfall-toml.schemaPath": {
          "type": "string",
          "default": "api/GAME_API.toml",
          "description": "Path to GAME_API.toml schema file"
        },
        "alienfall-toml.enableValidation": {
          "type": "boolean",
          "default": true,
          "description": "Enable real-time validation"
        }
      }
    }
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./"
  },
  "devDependencies": {
    "@types/node": "^18.0.0",
    "@types/vscode": "^1.75.0",
    "typescript": "^5.0.0"
  }
}
```

**Estimated time:** 12-16 hours (full extension development)

---

### Step 5: Implement Schema Loader
**Description:** Load and parse GAME_API.toml in extension

**File:** `src/schemaLoader.ts`

```typescript
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

interface FieldDefinition {
  type: string;
  required?: boolean;
  default?: any;
  min?: number;
  max?: number;
  values?: string[];
  description?: string;
}

interface EntityDefinition {
  fields: { [key: string]: FieldDefinition };
}

interface GameAPISchema {
  [entityType: string]: EntityDefinition;
}

export class SchemaLoader {
  private schema: GameAPISchema | null = null;
  private schemaPath: string;

  constructor(workspaceRoot: string) {
    this.schemaPath = path.join(workspaceRoot, 'api', 'GAME_API.toml');
  }

  public load(): GameAPISchema {
    if (this.schema) {
      return this.schema;
    }

    // Read GAME_API.toml
    const content = fs.readFileSync(this.schemaPath, 'utf-8');

    // Parse TOML (use toml parser library)
    this.schema = this.parseTOML(content);

    return this.schema;
  }

  private parseTOML(content: string): GameAPISchema {
    // Use TOML parser library
    // Convert to internal schema format
    // Return parsed schema
  }

  public getDefinition(category: string): EntityDefinition | null {
    const schema = this.load();
    return schema[category] || null;
  }

  public determineCategory(filePath: string): string | null {
    // Extract category from file path
    // mods/*/rules/units/*.toml -> "units"
    // mods/*/rules/items/*.toml -> "items"

    const match = filePath.match(/mods\/[^\/]+\/rules\/([^\/]+)\//);
    return match ? match[1] : null;
  }
}
```

**Estimated time:** 3-4 hours

---

### Step 6: Implement Validator (Diagnostics)
**Description:** Real-time validation and error highlighting

**File:** `src/validator.ts`

```typescript
import * as vscode from 'vscode';
import { SchemaLoader } from './schemaLoader';

export class TOMLValidator {
  private diagnosticCollection: vscode.DiagnosticCollection;
  private schemaLoader: SchemaLoader;

  constructor(context: vscode.ExtensionContext, schemaLoader: SchemaLoader) {
    this.schemaLoader = schemaLoader;
    this.diagnosticCollection = vscode.languages.createDiagnosticCollection('alienfall-toml');
    context.subscriptions.push(this.diagnosticCollection);
  }

  public validate(document: vscode.TextDocument): void {
    if (document.languageId !== 'toml') {
      return;
    }

    // Determine what type of entity this file should be
    const category = this.schemaLoader.determineCategory(document.uri.fsPath);

    if (!category) {
      return; // Not a mod TOML file
    }

    const definition = this.schemaLoader.getDefinition(category);

    if (!definition) {
      return; // No schema for this category
    }

    // Parse TOML document
    const content = document.getText();
    const data = this.parseTOML(content);

    // Validate against schema
    const diagnostics: vscode.Diagnostic[] = [];

    // Check required fields
    for (const [fieldName, fieldDef] of Object.entries(definition.fields)) {
      if (fieldDef.required && !(fieldName in data)) {
        const diagnostic = new vscode.Diagnostic(
          new vscode.Range(0, 0, 0, 0),
          `Missing required field: ${fieldName}`,
          vscode.DiagnosticSeverity.Error
        );
        diagnostics.push(diagnostic);
      }
    }

    // Check field types
    for (const [fieldName, value] of Object.entries(data)) {
      const fieldDef = definition.fields[fieldName];

      if (!fieldDef) {
        // Unknown field
        const range = this.findFieldRange(document, fieldName);
        const diagnostic = new vscode.Diagnostic(
          range,
          `Unknown field: ${fieldName}`,
          vscode.DiagnosticSeverity.Error
        );
        diagnostics.push(diagnostic);
        continue;
      }

      // Validate type
      const typeValid = this.validateType(value, fieldDef.type);

      if (!typeValid) {
        const range = this.findFieldRange(document, fieldName);
        const diagnostic = new vscode.Diagnostic(
          range,
          `Expected type ${fieldDef.type}, got ${typeof value}`,
          vscode.DiagnosticSeverity.Error
        );
        diagnostics.push(diagnostic);
      }

      // Validate enum
      if (fieldDef.type === 'enum' && fieldDef.values) {
        if (!fieldDef.values.includes(value as string)) {
          const range = this.findFieldRange(document, fieldName);
          const diagnostic = new vscode.Diagnostic(
            range,
            `Invalid value. Valid values: ${fieldDef.values.join(', ')}`,
            vscode.DiagnosticSeverity.Error
          );
          diagnostics.push(diagnostic);
        }
      }

      // Validate numeric constraints
      if (fieldDef.type === 'integer' || fieldDef.type === 'float') {
        if (fieldDef.min !== undefined && (value as number) < fieldDef.min) {
          const range = this.findFieldRange(document, fieldName);
          const diagnostic = new vscode.Diagnostic(
            range,
            `Value must be >= ${fieldDef.min}`,
            vscode.DiagnosticSeverity.Error
          );
          diagnostics.push(diagnostic);
        }

        if (fieldDef.max !== undefined && (value as number) > fieldDef.max) {
          const range = this.findFieldRange(document, fieldName);
          const diagnostic = new vscode.Diagnostic(
            range,
            `Value must be <= ${fieldDef.max}`,
            vscode.DiagnosticSeverity.Error
          );
          diagnostics.push(diagnostic);
        }
      }
    }

    // Update diagnostics
    this.diagnosticCollection.set(document.uri, diagnostics);
  }

  private parseTOML(content: string): any {
    // Use TOML parser
    // Return parsed data
  }

  private validateType(value: any, expectedType: string): boolean {
    // Check if value matches expected type
  }

  private findFieldRange(document: vscode.TextDocument, fieldName: string): vscode.Range {
    // Find line where field is defined
    // Return range for highlighting
  }
}
```

**Estimated time:** 5-6 hours

---

### Step 7: Implement Autocomplete
**Description:** Field name and value suggestions

**File:** `src/completion.ts`

```typescript
import * as vscode from 'vscode';
import { SchemaLoader } from './schemaLoader';

export class TOMLCompletionProvider implements vscode.CompletionItemProvider {
  private schemaLoader: SchemaLoader;

  constructor(schemaLoader: SchemaLoader) {
    this.schemaLoader = schemaLoader;
  }

  public provideCompletionItems(
    document: vscode.TextDocument,
    position: vscode.Position
  ): vscode.CompletionItem[] {
    const category = this.schemaLoader.determineCategory(document.uri.fsPath);

    if (!category) {
      return [];
    }

    const definition = this.schemaLoader.getDefinition(category);

    if (!definition) {
      return [];
    }

    const items: vscode.CompletionItem[] = [];

    // Get context (what field are we completing?)
    const line = document.lineAt(position.line).text;
    const context = this.getCompletionContext(document, position);

    if (context.type === 'field') {
      // Suggest field names
      for (const [fieldName, fieldDef] of Object.entries(definition.fields)) {
        const item = new vscode.CompletionItem(fieldName, vscode.CompletionItemKind.Field);
        item.detail = fieldDef.type;
        item.documentation = fieldDef.description;

        // Insert snippet with appropriate value placeholder
        if (fieldDef.type === 'string') {
          item.insertText = new vscode.SnippetString(`${fieldName} = "$1"`);
        } else if (fieldDef.type === 'integer' || fieldDef.type === 'float') {
          item.insertText = new vscode.SnippetString(`${fieldName} = $1`);
        } else if (fieldDef.type === 'boolean') {
          item.insertText = new vscode.SnippetString(`${fieldName} = $1`);
        }

        items.push(item);
      }
    } else if (context.type === 'value' && context.fieldName) {
      // Suggest values for specific field
      const fieldDef = definition.fields[context.fieldName];

      if (fieldDef && fieldDef.type === 'enum' && fieldDef.values) {
        // Suggest enum values
        for (const value of fieldDef.values) {
          const item = new vscode.CompletionItem(value, vscode.CompletionItemKind.Value);
          item.insertText = `"${value}"`;
          items.push(item);
        }
      } else if (fieldDef && fieldDef.type === 'boolean') {
        // Suggest true/false
        items.push(new vscode.CompletionItem('true', vscode.CompletionItemKind.Value));
        items.push(new vscode.CompletionItem('false', vscode.CompletionItemKind.Value));
      }
    }

    return items;
  }

  private getCompletionContext(document: vscode.TextDocument, position: vscode.Position): any {
    // Determine what we're completing
    // Field name or field value?
  }
}
```

**Estimated time:** 4-5 hours

---

### Step 8: Implement Hover Provider
**Description:** Show documentation on hover

**File:** `src/hover.ts`

```typescript
import * as vscode from 'vscode';
import { SchemaLoader } from './schemaLoader';

export class TOMLHoverProvider implements vscode.HoverProvider {
  private schemaLoader: SchemaLoader;

  constructor(schemaLoader: SchemaLoader) {
    this.schemaLoader = schemaLoader;
  }

  public provideHover(
    document: vscode.TextDocument,
    position: vscode.Position
  ): vscode.Hover | null {
    const category = this.schemaLoader.determineCategory(document.uri.fsPath);

    if (!category) {
      return null;
    }

    const definition = this.schemaLoader.getDefinition(category);

    if (!definition) {
      return null;
    }

    // Get word at position
    const range = document.getWordRangeAtPosition(position);

    if (!range) {
      return null;
    }

    const word = document.getText(range);

    // Check if it's a field name
    const fieldDef = definition.fields[word];

    if (fieldDef) {
      const markdown = new vscode.MarkdownString();
      markdown.appendCodeblock(`${word}: ${fieldDef.type}`, 'toml');

      if (fieldDef.description) {
        markdown.appendMarkdown('\n\n' + fieldDef.description);
      }

      if (fieldDef.required) {
        markdown.appendMarkdown('\n\n**Required field**');
      }

      if (fieldDef.default !== undefined) {
        markdown.appendMarkdown(`\n\n**Default:** \`${fieldDef.default}\``);
      }

      if (fieldDef.min !== undefined || fieldDef.max !== undefined) {
        markdown.appendMarkdown(`\n\n**Range:** ${fieldDef.min} - ${fieldDef.max}`);
      }

      if (fieldDef.values) {
        markdown.appendMarkdown(`\n\n**Valid values:** ${fieldDef.values.join(', ')}`);
      }

      return new vscode.Hover(markdown, range);
    }

    return null;
  }
}
```

**Estimated time:** 2-3 hours

---

### Step 9: Register Extension
**Description:** Wire everything together

**File:** `src/extension.ts`

```typescript
import * as vscode from 'vscode';
import { SchemaLoader } from './schemaLoader';
import { TOMLValidator } from './validator';
import { TOMLCompletionProvider } from './completion';
import { TOMLHoverProvider } from './hover';

export function activate(context: vscode.ExtensionContext) {
  console.log('AlienFall TOML extension activated');

  // Get workspace root
  const workspaceRoot = vscode.workspace.workspaceFolders?.[0].uri.fsPath;

  if (!workspaceRoot) {
    return;
  }

  // Initialize schema loader
  const schemaLoader = new SchemaLoader(workspaceRoot);

  // Initialize validator
  const validator = new TOMLValidator(context, schemaLoader);

  // Register validation on document change
  vscode.workspace.onDidChangeTextDocument((event) => {
    if (event.document.languageId === 'toml') {
      validator.validate(event.document);
    }
  });

  // Register validation on document open
  vscode.workspace.onDidOpenTextDocument((document) => {
    if (document.languageId === 'toml') {
      validator.validate(document);
    }
  });

  // Validate all open documents
  vscode.workspace.textDocuments.forEach((document) => {
    if (document.languageId === 'toml') {
      validator.validate(document);
    }
  });

  // Register completion provider
  const completionProvider = new TOMLCompletionProvider(schemaLoader);
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider(
      { language: 'toml', pattern: '**/mods/**/rules/**/*.toml' },
      completionProvider,
      '=', ' ', '.'
    )
  );

  // Register hover provider
  const hoverProvider = new TOMLHoverProvider(schemaLoader);
  context.subscriptions.push(
    vscode.languages.registerHoverProvider(
      { language: 'toml', pattern: '**/mods/**/rules/**/*.toml' },
      hoverProvider
    )
  );
}

export function deactivate() {
  console.log('AlienFall TOML extension deactivated');
}
```

**Estimated time:** 2-3 hours

---

### Step 10: Build and Package Extension
**Description:** Compile and package for distribution

**Build steps:**
```bash
cd tools/vscode-extension-alienfall-toml
npm install
npm run compile
vsce package  # Creates .vsix file
```

**Installation:**
```bash
code --install-extension alienfall-toml-0.1.0.vsix
```

**Or include in project:**
- Place .vsix in tools/vscode-extension/
- Add installation instructions to docs

**Estimated time:** 2-3 hours

---

### Step 11: Documentation
**Description:** Complete setup and usage guide

**Files to create:**
- `tools/vscode-extension-alienfall-toml/README.md` - extension docs
- `docs/IDE_SETUP.md` - setup guide for developers

**Must cover:**
- What the extension does
- How to install
- How to configure
- Features overview
- Troubleshooting
- Development guide (for contributing)

**Estimated time:** 2-3 hours

---

### Step 12: Testing
**Description:** Test extension functionality

**Test scenarios:**
- [ ] Open TOML file in mods/core/rules/units/ -> validation active
- [ ] Type invalid field name -> red squiggle
- [ ] Start typing field name -> autocomplete appears
- [ ] Select autocomplete -> inserts correctly
- [ ] Hover over field -> tooltip appears
- [ ] Type invalid enum -> error highlighted
- [ ] Type out-of-range number -> error highlighted
- [ ] Missing required field -> error shown
- [ ] Update GAME_API.toml -> validation updates
- [ ] Performance acceptable (no lag)

**Estimated time:** 3-4 hours

---

## Implementation Details

### Architecture

**Two possible approaches:**

**Approach 1: Use Existing Extension (Fast)**
- Configure existing TOML extension with JSON Schema
- Create GAME_API.schema.json from GAME_API.toml
- Update .vscode/settings.json
- Done in 8-12 hours

**Approach 2: Custom Extension (Full Control)**
- Build TypeScript VS Code extension
- Full LSP implementation
- Complete control over features
- Takes 30-40 hours

**Recommendation:** Start with Approach 1, move to Approach 2 if needed

### Key Components

**SchemaLoader:** Loads and parses GAME_API.toml
**Validator:** Real-time validation and diagnostics
**CompletionProvider:** Autocomplete suggestions
**HoverProvider:** Documentation tooltips

### Dependencies

- VS Code Extension API
- TOML parser library (e.g., @iarna/toml)
- TypeScript compiler
- VSCE (VS Code extension packager)

---

## Testing Strategy

### Unit Tests
- Test schema loader
- Test validator logic
- Test completion provider
- Test hover provider

### Integration Tests
- Test with real TOML files
- Test all features together
- Test performance

### Manual Testing
- Install extension
- Open mod files
- Test all features
- Check performance

---

## Documentation Updates

### Files to Create
- [ ] `tools/vscode-extension-alienfall-toml/` - extension source
- [ ] `tools/vscode-extension-alienfall-toml/README.md`
- [ ] `docs/IDE_SETUP.md` - setup guide
- [ ] `api/GAME_API.schema.json` - JSON Schema (if needed)

### Files to Update
- [ ] `.vscode/settings.json` - configure extension
- [ ] `.vscode/extensions.json` - recommend extension
- [ ] `tools/README.md` - mention extension
- [ ] `api/MODDING_GUIDE.md` - mention IDE support

---

## Notes

**Similar Tools:**
- Red Hat YAML extension (validates Kubernetes, Ansible)
- Salesforce Extensions (validates Apex, metadata)
- Azure Functions extension (validates function configs)

**Key Features:**
1. Real-time validation (most important)
2. Autocomplete (huge productivity boost)
3. Hover documentation (helps learning)
4. Jump to definition (nice to have)
5. Find references (nice to have)

**Future Enhancements:**
- Snippets for common patterns
- Code actions (quick fixes)
- Formatting (auto-format TOML)
- Refactoring support
- Visual schema browser

---

## Blockers

**Must have:**
- [ ] TASK-001 completed (GAME_API.toml exists)
- [ ] VS Code installed
- [ ] Node.js/TypeScript (if building custom extension)

**Potential issues:**
- TOML parser might not support all features
- Performance with large schemas
- VS Code API limitations

---

## Review Checklist

- [ ] Extension installs correctly
- [ ] Validation works real-time
- [ ] Autocomplete works
- [ ] Hover works
- [ ] Performance acceptable
- [ ] Documentation complete
- [ ] Works on Windows/macOS/Linux
- [ ] Code follows TypeScript best practices

---

## Success Criteria

**Task is DONE when:**
1. Extension/LSP exists and can be installed
2. Real-time validation works
3. Autocomplete works
4. Hover documentation works
5. Performance is acceptable
6. Documentation is complete
7. Manual testing successful
8. Can be distributed to team

**This enables:**
- Faster mod development
- Fewer errors during development
- Better developer experience
- Modern IDE features for TOML editing
- Learning API through autocomplete/hover
