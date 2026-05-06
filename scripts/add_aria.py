#!/usr/bin/env python3
"""Idempotently add ARIA attributes / semantic markers across HTML pages.

- <nav class="nav-links">           -> + aria-label="Primary"
- <div class="footer-links">...</div> -> <nav class="footer-links" aria-label="Footer">...</nav>
- <p ... class="message"></p>       -> + role="status" aria-live="polite"
"""

from __future__ import annotations

import re
from pathlib import Path

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"


def patch(path: Path) -> list[str]:
    text = path.read_text()
    original = text
    notes: list[str] = []

    if 'class="nav-links"' in text and 'aria-label="Primary"' not in text:
        text = text.replace(
            '<nav class="nav-links">',
            '<nav class="nav-links" aria-label="Primary">',
        )
        notes.append("nav")

    if '<div class="footer-links">' in text:
        text = text.replace(
            '<div class="footer-links">',
            '<nav class="footer-links" aria-label="Footer">',
        )
        # Close the matching </div> that follows the footer-links block.
        # The footer block consistently ends with the link list closing
        # immediately followed by </footer>; replace the pattern unambiguously.
        text = re.sub(
            r'(<nav class="footer-links" aria-label="Footer">.*?)</div>(\s*</footer>)',
            r'\1</nav>\2',
            text,
            flags=re.DOTALL,
        )
        notes.append("footer")

    # Add role/aria-live to .message paragraphs that don't have it yet.
    def message_repl(match: re.Match) -> str:
        tag = match.group(0)
        if 'role="status"' in tag:
            return tag
        # Insert before the trailing '>'
        return tag[:-1] + ' role="status" aria-live="polite">'

    new_text, n = re.subn(
        r'<p[^>]*class="message"[^>]*>',
        message_repl,
        text,
    )
    if n:
        text = new_text
        notes.append(f"messages({n})")

    if text != original:
        path.write_text(text)
    return notes


def main() -> None:
    for html in sorted(FRONTEND.glob("*.html")):
        notes = patch(html)
        tag = ", ".join(notes) if notes else "no-change"
        print(f"{html.name:30} {tag}")


if __name__ == "__main__":
    main()
