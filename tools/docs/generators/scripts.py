"""Generated regions read from the Python scripts: their command-line options, from the ``add_argument`` calls.

``<!-- generated: options-generate-matrix -->`` and ``<!-- generated: options-get-app-info -->``. The table shows
what the parser accepts, which is what a caller can rely on (the scripts' own ``--help`` text is written by hand).
"""

from __future__ import annotations

import ast

from hardfoc_mkdocs_theme.paths import repo_root

ROOT = repo_root()


def _value(node):
    try:
        return ast.literal_eval(node)
    except ValueError:
        return None


def _options(script: str):
    def fill() -> str:
        tree = ast.parse((ROOT / script).read_text(encoding="utf-8"))
        rows = ["| Argument | Values | Default | Description |", "| --- | --- | --- | --- |"]
        for node in ast.walk(tree):
            if not (isinstance(node, ast.Call) and getattr(node.func, "attr", "") == "add_argument"):
                continue
            names = [_value(a) for a in node.args]
            kw = {k.arg: _value(k.value) for k in node.keywords}
            if kw.get("action") == "store_true":
                values = "flag"
            elif kw.get("choices"):
                values = ", ".join(f"`{c}`" for c in kw["choices"])
            elif not str(names[0]).startswith("-"):
                values = "positional" + (", optional" if kw.get("nargs") == "?" else "")
            else:
                values = "value"
            default = kw.get("default")
            default = f"`{default}`" if default not in (None, False) else "-"
            name = " / ".join(f"`{n}`" for n in names)
            rows.append(f"| {name} | {values} | {default} | {kw.get('help', '')} |")
        return "\n".join(rows) + "\n"

    return fill


REGIONS = {
    "options-generate-matrix": _options("generate_matrix.py"),
    "options-get-app-info": _options("get_app_info.py"),
}
