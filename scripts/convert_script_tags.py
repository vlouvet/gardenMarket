#!/usr/bin/env python3
"""Convert classic deferred scripts to ES module scripts for Vite.

Rules per HTML page:
- If a per-page script (anything other than app.js / plausible) is present,
  drop the explicit app.js script tag (it'll be imported transitively) and
  make the per-page tag `type="module"`.
- If only app.js is present, switch it to `type="module"`.
- Plausible analytics tag is left alone (third-party, classic script).

Idempotent: skips files already converted.
"""

from __future__ import annotations

import re
from pathlib import Path

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"

DEFER_LOCAL = re.compile(
    r'^([ \t]*)<script defer src="([A-Za-z0-9._-]+\.js)"></script>\n',
    re.MULTILINE,
)


def patch(path: Path) -> str:
    text = path.read_text()
    matches = list(DEFER_LOCAL.finditer(text))
    if not matches:
        return "no-local-scripts"

    by_name = {m.group(2): m for m in matches}
    page_scripts = [name for name in by_name if name != "app.js"]

    if not page_scripts:
        # Only app.js — switch to module.
        m = by_name["app.js"]
        replacement = f'{m.group(1)}<script type="module" src="app.js"></script>\n'
        new_text = text[:m.start()] + replacement + text[m.end():]
    else:
        # Drop app.js (if present), make page script(s) modules.
        new_text = text
        if "app.js" in by_name:
            m = by_name["app.js"]
            new_text = new_text[:m.start()] + new_text[m.end():]
        for name in page_scripts:
            old = f'<script defer src="{name}"></script>'
            new = f'<script type="module" src="{name}"></script>'
            new_text = new_text.replace(old, new)

    if new_text == text:
        return "no-change"
    path.write_text(new_text)
    return "patched"


def main() -> None:
    for html in sorted(FRONTEND.glob("*.html")):
        result = patch(html)
        print(f"{html.name:30} {result}")


if __name__ == "__main__":
    main()
