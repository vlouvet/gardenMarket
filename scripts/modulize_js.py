#!/usr/bin/env python3
"""Prepend the correct named import from app.js to each per-page script.

Idempotent: skips files that already start with `import`. Determines the
needed names by static lookup against a known whitelist of helpers.
"""

from __future__ import annotations

import re
from pathlib import Path

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"

HELPERS = [
    "request",
    "getToken",
    "getUser",
    "requireAuth",
    "logout",
    "refreshCurrentUser",
    "showLoading",
    "hideLoading",
    "showError",
    "dismissError",
    "setMessage",
    "storeToken",
    "storeUser",
    "initNav",
    "API_BASE",
    "TOKEN_KEY",
    "USER_KEY",
]

# Files that should NOT get an import line — entrypoint module itself.
SKIP = {"app.js", "vite.config.js"}


def needed_imports(text: str) -> list[str]:
    used = []
    for name in HELPERS:
        if re.search(rf"\b{name}\b", text):
            used.append(name)
    return used


def patch(path: Path) -> str:
    text = path.read_text()
    if text.lstrip().startswith("import "):
        return "skip-already-module"
    used = needed_imports(text)
    if not used:
        return "skip-no-helpers"
    line = f'import {{ {", ".join(used)} }} from "./app.js";\n\n'
    path.write_text(line + text)
    return f"patched ({len(used)} imports)"


def main() -> None:
    for js in sorted(FRONTEND.glob("*.js")):
        if js.name in SKIP:
            continue
        result = patch(js)
        print(f"{js.name:20} {result}")


if __name__ == "__main__":
    main()
