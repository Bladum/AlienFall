To load YAML or TOML files in Lua, you'll need to use external modules since standard Lua doesn't have built-in support for these formats. Here are some popular options for each.

YAML Modules
For loading YAML files, lua-yaml is a widely used and well-maintained module. It's built on top of libyaml, a fast and robust C library, making it an efficient choice for parsing YAML data. It can be installed using LuaRocks, the package manager for Lua.

lua-yaml: luarocks install lua-yaml

Usage: It provides a simple API for parsing and serializing YAML.

Parsing: Use yaml.load(yaml_string) to parse a string or yaml.load_file(file_path) to load directly from a file. This function returns a Lua table representing the parsed data.

Serialization: Use yaml.dump(lua_table) to convert a Lua table back into a YAML string.

TOML Modules
For TOML files, the most common and reliable module is lua-toml. Like lua-yaml, it can also be installed via LuaRocks.

lua-toml: luarocks install lua-toml

Usage: It's a pure Lua implementation, so it doesn't require any C dependencies.

Parsing: The primary function is toml.decode(toml_string) which parses a string and returns a Lua table. To load from a file, you'd typically read the file's content into a string first and then pass it to toml.decode.

Serialization: It also offers a toml.encode(lua_table) function to convert a Lua table into a TOML string.

You can also use toml.lua which is another popular choice.

toml.lua: A single-file, pure Lua implementation of a TOML parser.

Usage: It's often included directly in a project rather than installed via a package manager. You can simply require the file and use the parse function to convert a TOML string into a Lua table.
