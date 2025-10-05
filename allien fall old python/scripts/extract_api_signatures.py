import ast
import os
import sys
from pathlib import Path
from typing import List, Optional

try:
    from ast import unparse  # Python 3.9+
except ImportError:
    import astunparse
    def unparse(node):
        return astunparse.unparse(node).strip()

IGNORED_DIRS = {"__pycache__", ".venv", ".git"}


def is_property(func: ast.FunctionDef) -> bool:
    for d in func.decorator_list:
        if isinstance(d, ast.Name) and d.id == "property":
            return True
        if isinstance(d, ast.Attribute) and d.attr == "getter":
            return True
    return False


def is_classmethod(func: ast.FunctionDef) -> bool:
    for d in func.decorator_list:
        if isinstance(d, ast.Name) and d.id == "classmethod":
            return True
    return False


def is_staticmethod(func: ast.FunctionDef) -> bool:
    for d in func.decorator_list:
        if isinstance(d, ast.Name) and d.id == "staticmethod":
            return True
    return False


def format_arg(arg: ast.arg, default: Optional[ast.AST]) -> str:
    name = arg.arg
    ann = None
    if arg.annotation is not None:
        try:
            ann = unparse(arg.annotation)
        except Exception:
            ann = None
    s = name
    if ann:
        s += f": {ann}"
    if default is not None:
        # Avoid exposing literal defaults; keep as ellipsis to match "no bodies" intent
        s += " = ..."
    return s


def build_signature(args: ast.arguments, returns: Optional[ast.AST]) -> str:
    parts: List[str] = []

    # Positional and pos-only
    posonly_count = len(getattr(args, "posonlyargs", []))
    # Combine posonly and args for defaults alignment
    all_pos = list(getattr(args, "posonlyargs", [])) + list(args.args)
    defaults = list(args.defaults)
    # Align defaults to the last N positional args
    default_pad = len(all_pos) - len(defaults)
    defaults_aligned: List[Optional[ast.AST]] = [None] * default_pad + defaults

    for a, d in zip(all_pos, defaults_aligned):
        parts.append(format_arg(a, d))

    if posonly_count:
        # Insert / marker between pos-only and normal positional
        if posonly_count <= len(parts):
            parts.insert(posonly_count, "/")

    if args.vararg is not None:
        va = args.vararg
        ann = None
        if va.annotation is not None:
            try:
                ann = unparse(va.annotation)
            except Exception:
                ann = None
        s = f"*{va.arg}"
        if ann:
            s += f": {ann}"
        parts.append(s)
    else:
        # If there are kwonlyargs but no *vararg, we need a bare *
        if args.kwonlyargs:
            parts.append("*")

    for a, d in zip(args.kwonlyargs, args.kw_defaults):
        parts.append(format_arg(a, d))

    if args.kwarg is not None:
        ka = args.kwarg
        ann = None
        if ka.annotation is not None:
            try:
                ann = unparse(ka.annotation)
            except Exception:
                ann = None
        s = f"**{ka.arg}"
        if ann:
            s += f": {ann}"
        parts.append(s)

    sig = ", ".join(parts)

    ret = None
    if returns is not None:
        try:
            ret = unparse(returns)
        except Exception:
            ret = None

    if ret:
        return f"({sig}) -> {ret}"
    return f"({sig})"


esscape = str.replace


def extract_from_file(py_path: Path) -> str:
    try:
        src = py_path.read_text(encoding="utf-8")
    except Exception:
        return ""

    try:
        tree = ast.parse(src, filename=str(py_path), type_comments=True)
    except SyntaxError:
        return ""

    rel = py_path.as_posix()
    lines: List[str] = []
    lines.append(f"### {rel}")

    classes = [n for n in tree.body if isinstance(n, ast.ClassDef)]

    if not classes:
        # No classes; still show file header to indicate scan coverage
        lines.append("")
        return "\n".join(lines)

    for cls in classes:
        base_names: List[str] = []
        for b in cls.bases:
            try:
                base_names.append(unparse(b))
            except Exception:
                base_names.append("<base>")
        bases = f"({', '.join(base_names)})" if base_names else ""
        lines.append(f"\n#### class {cls.name}{bases}:")

        # Class attributes (Assign / AnnAssign at class scope)
        attrs: List[str] = []
        for node in cls.body:
            if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
                name = node.target.id
                ann = None
                if node.annotation is not None:
                    try:
                        ann = unparse(node.annotation)
                    except Exception:
                        ann = None
                if ann:
                    attrs.append(f"- {name}: {ann}{' = ...' if node.value is not None else ''}")
                else:
                    attrs.append(f"- {name}{' = ...' if node.value is not None else ''}")
            elif isinstance(node, ast.Assign):
                names = [t.id for t in node.targets if isinstance(t, ast.Name)]
                for name in names:
                    attrs.append(f"- {name} = ...")
        if attrs:
            lines.append("- Attributes:")
            lines.extend(attrs)

        # Methods and properties
        props: List[str] = []
        methods: List[str] = []
        for node in cls.body:
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                sig = build_signature(node.args, node.returns)
                kind = ""
                if isinstance(node, ast.AsyncFunctionDef):
                    kind = "[async] "
                if is_property(node):
                    props.append(f"- {node.name}{sig}")
                else:
                    if is_classmethod(node):
                        kind += "[classmethod] "
                    if is_staticmethod(node):
                        kind += "[staticmethod] "
                    methods.append(f"- {kind}{node.name}{sig}")
        if props:
            lines.append("- Properties:")
            lines.extend(props)
        if methods:
            lines.append("- Methods:")
            lines.extend(methods)

    lines.append("")
    return "\n".join(lines)


def walk_src(src_dir: Path) -> List[Path]:
    paths: List[Path] = []
    for root, dirs, files in os.walk(src_dir):
        # prune ignored dirs
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]
        for f in files:
            if f.endswith(".py"):
                paths.append(Path(root) / f)
    return sorted(paths)


def main():
    if len(sys.argv) < 3:
        print("Usage: extract_api_signatures.py <src_dir> <output_file>")
        sys.exit(2)
    src_dir = Path(sys.argv[1]).resolve()
    out_file = Path(sys.argv[2]).resolve()

    files = walk_src(src_dir)

    out_lines: List[str] = []
    out_lines.append("# Full API signatures (classes, methods, properties)\n")
    out_lines.append(f"Source: {src_dir}")
    out_lines.append("")

    for p in files:
        out = extract_from_file(p)
        if out.strip():
            out_lines.append(out)

    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text("\n".join(out_lines), encoding="utf-8")
    print(f"Wrote signatures to {out_file}")


if __name__ == "__main__":
    main()
