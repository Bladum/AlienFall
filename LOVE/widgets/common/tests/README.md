These are small smoke tests that can be run with plain Lua (they don't require Love2D runtime). 

Run them from the repository root using a system Lua interpreter (Lua 5.1+):

```powershell
lua LOVE/widgets/common/tests/test_container.lua
lua LOVE/widgets/common/tests/test_autocomplete_mixin.lua
```

They print basic success info. They're intended as quick sanity checks for the helper modules.
