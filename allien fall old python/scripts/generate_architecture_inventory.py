import ast
import os
from pathlib import Path
from typing import List, Optional

try:
    from ast import unparse  # 3.9+
except Exception:  # pragma: no cover
    import astunparse
    def unparse(node):
        return astunparse.unparse(node).strip()

SRC = Path('src').resolve()
OUT = Path('wiki/architecture_inventory.md').resolve()

IGNORE_DIRS = {'.git', '.venv', '__pycache__'}


def should_skip(path: Path) -> bool:
    p = path.as_posix().lower()
    if '/test/' in p or '\\test\\' in p:
        return True
    name = path.name.lower()
    if name.startswith('test_'):
        return True
    return False


def walk_py_files(root: Path) -> List[Path]:
    files: List[Path] = []
    for r, dirs, fnames in os.walk(root):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        for f in fnames:
            if f.endswith('.py'):
                p = Path(r) / f
                if not should_skip(p):
                    files.append(p)
    return sorted(files)


def get_top_module(path: Path) -> str:
    # src/<top>/<rest>
    parts = path.relative_to(SRC).parts
    return parts[0] if parts else ''


def summarize_class(cls: ast.ClassDef) -> dict:
    purpose = ''
    if ast.get_docstring(cls):
        purpose = ast.get_docstring(cls).strip().splitlines()[0]
    bases = []
    for b in cls.bases:
        try:
            bases.append(unparse(b))
        except Exception:
            bases.append('<base>')

    attrs: List[str] = []
    props: List[str] = []
    methods: List[str] = []

    def is_property(func: ast.FunctionDef) -> bool:
        for d in func.decorator_list:
            if isinstance(d, ast.Name) and d.id == 'property':
                return True
        return False

    def build_sig(args: ast.arguments, returns: Optional[ast.AST]) -> str:
        parts: List[str] = []
        # combine posonly + args with redacted defaults
        all_pos = list(getattr(args, 'posonlyargs', [])) + list(args.args)
        for a in all_pos:
            name = a.arg
            ann = None
            if a.annotation is not None:
                try:
                    ann = unparse(a.annotation)
                except Exception:
                    ann = None
            parts.append(f"{name}{f': {ann}' if ann else ''}")
        if args.vararg is not None:
            name = args.vararg.arg
            ann = None
            if args.vararg.annotation is not None:
                try:
                    ann = unparse(args.vararg.annotation)
                except Exception:
                    ann = None
            parts.append(f"*{name}{f': {ann}' if ann else ''}")
        elif args.kwonlyargs:
            parts.append('*')
        for a in args.kwonlyargs:
            name = a.arg
            ann = None
            if a.annotation is not None:
                try:
                    ann = unparse(a.annotation)
                except Exception:
                    ann = None
            parts.append(f"{name}{f': {ann}' if ann else ''}")
        if args.kwarg is not None:
            name = args.kwarg.arg
            ann = None
            if args.kwarg.annotation is not None:
                try:
                    ann = unparse(args.kwarg.annotation)
                except Exception:
                    ann = None
            parts.append(f"**{name}{f': {ann}' if ann else ''}")
        ret = None
        if returns is not None:
            try:
                ret = unparse(returns)
            except Exception:
                ret = None
        sig = f"({', '.join(parts)})"
        return f"{sig}{f' -> {ret}' if ret else ''}"

    for node in cls.body:
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            attrs.append(node.target.id)
        elif isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name):
                    attrs.append(t.id)
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            name = node.name
            sig = build_sig(node.args, node.returns)
            if is_property(node):
                props.append(f"{name}{sig}")
            else:
                methods.append(f"{name}{sig}")

    return {
        'name': cls.name,
        'bases': bases,
        'purpose': purpose,
        'attributes': attrs,
        'properties': props,
        'methods': methods,
    }


def extract_file(path: Path) -> dict:
    try:
        src = path.read_text(encoding='utf-8')
    except Exception:
        return {'file': path, 'classes': []}
    try:
        tree = ast.parse(src, filename=str(path), type_comments=True)
    except SyntaxError:
        return {'file': path, 'classes': []}

    classes = [n for n in tree.body if isinstance(n, ast.ClassDef)]
    return {'file': path, 'classes': [summarize_class(c) for c in classes]}


def main():
    files = walk_py_files(SRC)
    by_module = {}
    for f in files:
        top = get_top_module(f)
        by_module.setdefault(top, []).append(f)

    lines: List[str] = []
    lines.append('# Module-by-module class inventory (human-friendly)\n')
    lines.append('This inventory excludes tests and includes class purposes (first docstring line), attributes, properties, and method signatures without bodies.\n')

    for mod in sorted(by_module.keys()):
        lines.append(f"## Module: {mod}\n")
        for f in sorted(by_module[mod], key=lambda p: p.as_posix()):
            data = extract_file(f)
            classes = data['classes']
            if not classes:
                continue
            rel = f.relative_to(SRC).as_posix()
            lines.append(f"### File: {rel}")
            for c in classes:
                bases = f" ({', '.join(c['bases'])})" if c['bases'] else ''
                lines.append(f"- Class: {c['name']}{bases}")
                if c['purpose']:
                    lines.append(f"  - Purpose: {c['purpose']}")
                if c['attributes']:
                    lines.append(f"  - Attributes: {', '.join(sorted(set(c['attributes'])))}")
                if c['properties']:
                    lines.append("  - Properties:")
                    for p in c['properties']:
                        lines.append(f"    - {p}")
                if c['methods']:
                    lines.append("  - Methods:")
                    for m in c['methods']:
                        lines.append(f"    - {m}")
            lines.append('')
        lines.append('')

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding='utf-8')
    print(f"Wrote {OUT}")


if __name__ == '__main__':
    main()
