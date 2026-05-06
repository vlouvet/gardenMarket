#!/usr/bin/env python3
"""Idempotently insert PWA meta tags + manifest/icon links into each HTML page.

The block is inserted immediately after the viewport meta tag. If the sentinel
(theme-color tag) is already present we skip the file.
"""

from __future__ import annotations

from pathlib import Path

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"

VIEWPORT = '<meta name="viewport" content="width=device-width, initial-scale=1" />'
SENTINEL = '<meta name="theme-color"'

BLOCK = """\
    <meta name="theme-color" content="#2d6f65" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="default" />
    <meta name="apple-mobile-web-app-title" content="GardenMarket" />
    <meta name="description" content="Local growers, smarter logistics, fresh every week." />
    <link rel="manifest" href="/manifest.json" />
    <link rel="icon" type="image/svg+xml" href="/icon.svg" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png" />
    <link rel="icon" href="/favicon.ico" sizes="any" />
    <link rel="apple-touch-icon" href="/apple-touch-icon.png" />"""


def patch(path: Path) -> str:
    text = path.read_text()
    if SENTINEL in text:
        return "skip"
    if VIEWPORT not in text:
        return "no-viewport"
    new = text.replace(VIEWPORT, VIEWPORT + "\n" + BLOCK)
    path.write_text(new)
    return "patched"


def main() -> None:
    for html in sorted(FRONTEND.glob("*.html")):
        status = patch(html)
        print(f"{status:12} {html.name}")


if __name__ == "__main__":
    main()
