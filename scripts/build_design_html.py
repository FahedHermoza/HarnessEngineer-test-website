#!/usr/bin/env python3
"""Generate DESIGN.html from DESIGN.md (durable mirror; see AGENTS.md).

Shows only a live preview (iframe of index.html) and a color palette
generated from DESIGN.md's frontmatter `colors:` block. The rest of
DESIGN.md's content lives in DESIGN.md itself; this page does not duplicate it.

Usage:
  python3 scripts/build_design_html.py          # (re)writes DESIGN.html
  python3 scripts/build_design_html.py --check  # exit 1 if DESIGN.html is stale
"""
import html
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESIGN_MD = ROOT / "DESIGN.md"
DESIGN_HTML = ROOT / "DESIGN.html"


def split_frontmatter(text):
    if not text.startswith("---\n"):
        return "", text
    end = text.find("\n---\n", 4)
    if end == -1:
        return "", text
    frontmatter = text[4:end]
    body = text[end + 5:]
    return frontmatter, body


def frontmatter_title(frontmatter):
    name = re.search(r"^name:\s*(.+)$", frontmatter, re.MULTILINE)
    return name.group(1).strip() if name else "Design Direction"


def parse_colors(frontmatter):
    block = re.search(r"^colors:[ \t]*\n((?:[ \t]+\S.*\n?)+)", frontmatter, re.MULTILINE)
    if not block:
        return []
    tokens = []
    for line in block.group(1).splitlines():
        m = re.match(r"^[ \t]+([A-Za-z0-9_-]+):\s*'?(#[0-9A-Fa-f]{3,8})'?", line)
        if m:
            tokens.append((m.group(1), m.group(2)))
    return tokens


def color_swatches_html(color_tokens):
    chips = []
    for name, hexval in color_tokens:
        chips.append(
            '<div class="design-doc__swatch">'
            f'<span class="design-doc__swatch-color" aria-hidden="true" style="background:{hexval}"></span>'
            f'<span class="design-doc__swatch-label"><code>{name}</code><br>{hexval}</span>'
            "</div>"
        )
    return "".join(chips)


PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{title} — preview</title>
    <link rel="icon" href="data:,">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap">
    <link rel="stylesheet" href="styles.css">
    <style>
      body {{
        background: var(--color-background);
        color: var(--color-on-surface);
        font-family: var(--font-family-base);
        margin: 0;
      }}
      .design-doc {{
        max-width: 48rem;
        margin: 0 auto;
        padding: var(--space-xl) var(--space-gutter) calc(var(--space-xl) * 2);
      }}
      .design-doc__eyebrow {{
        font-size: var(--text-label-sm-font-size);
        font-weight: var(--text-label-sm-font-weight);
        line-height: var(--text-label-sm-line-height);
        letter-spacing: var(--text-label-sm-letter-spacing);
        text-transform: uppercase;
        color: var(--color-primary);
      }}
      .design-doc h1 {{
        font-size: var(--text-headline-lg-font-size);
        font-weight: var(--text-headline-lg-font-weight);
        line-height: var(--text-headline-lg-line-height);
        letter-spacing: var(--text-headline-lg-letter-spacing);
        margin: var(--space-xs) 0 var(--space-xl);
      }}
      .design-doc h2 {{
        font-size: var(--text-headline-md-font-size);
        font-weight: var(--text-headline-md-font-weight);
        line-height: var(--text-headline-md-line-height);
        letter-spacing: var(--text-headline-md-letter-spacing);
        border-top: 1px solid var(--color-border);
        margin-top: var(--space-xl);
        padding-top: var(--space-lg);
      }}
      .design-doc p {{
        font-size: var(--text-body-md-font-size);
        line-height: var(--text-body-md-line-height);
        color: var(--color-on-surface-variant);
      }}
      .design-doc code {{
        background: var(--color-surface-container-low);
        color: var(--color-primary);
        border-radius: var(--radius-sm);
        padding: 0.1em 0.35em;
        font-size: 0.92em;
      }}
      .design-doc__preview {{
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--space-sm);
        margin: var(--space-md) 0 var(--space-xl);
      }}
      .design-doc__preview iframe {{
        width: 420px;
        max-width: 100%;
        height: 860px;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-lg);
        background: var(--color-background);
      }}
      .design-doc__preview-caption {{
        font-size: var(--text-body-sm-font-size);
        color: var(--color-on-surface-variant);
        text-align: center;
        max-width: 38rem;
      }}
      .design-doc__swatches {{
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(9rem, 1fr));
        gap: var(--space-sm);
        margin: var(--space-md) 0;
      }}
      .design-doc__swatch {{
        display: flex;
        align-items: center;
        gap: var(--space-sm);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-sm);
        padding: var(--space-xs);
      }}
      .design-doc__swatch-color {{
        display: block;
        width: 2rem;
        height: 2rem;
        flex-shrink: 0;
        border-radius: var(--radius-sm);
        border: 1px solid var(--color-border);
      }}
      .design-doc__swatch-label {{
        font-size: var(--text-body-sm-font-size);
        line-height: 1.3;
      }}
    </style>
  </head>
  <body>
    <main class="design-doc">
      <p class="design-doc__eyebrow">DESIGN.md — preview</p>
      <h1>{title}</h1>

      <h2>Vista previa en vivo</h2>
      <p>Renderiza el <code>index.html</code> publicado en este mismo worktree/servidor. Puede
        no reflejar aún las secciones de "Dirección del rediseño" todavía no implementadas.</p>
      <div class="design-doc__preview">
        <iframe src="index.html" title="Vista previa en vivo de la Tarjeta digital (index.html)" loading="lazy"></iframe>
        <p class="design-doc__preview-caption">390px de ancho simulado · si se sirve este archivo
          sin servidor (<code>file://</code>), el iframe puede no cargar por restricciones del
          navegador; usa <code>python3 -m http.server</code> para verlo en vivo.</p>
      </div>

      <h2>Paleta de color</h2>
      <p>Swatches generados directamente de <code>colors:</code> en el frontmatter de
        <code>DESIGN.md</code>; ningún valor está inventado aquí. El resto del contenido de
        <code>DESIGN.md</code> (tipografía, layout, componentes, dirección del rediseño) vive
        únicamente en <code>DESIGN.md</code>.</p>
      <div class="design-doc__swatches">{color_swatches_html}</div>
    </main>
  </body>
</html>
"""


def build():
    text = DESIGN_MD.read_text(encoding="utf-8")
    frontmatter, _body = split_frontmatter(text)
    title = frontmatter_title(frontmatter)
    color_tokens = parse_colors(frontmatter)
    return PAGE_TEMPLATE.format(
        title=html.escape(title, quote=False),
        color_swatches_html=color_swatches_html(color_tokens),
    )


def main():
    generated = build()
    if "--check" in sys.argv[1:]:
        current = DESIGN_HTML.read_text(encoding="utf-8") if DESIGN_HTML.exists() else None
        if current != generated:
            print("FAILED - DESIGN.html is stale relative to DESIGN.md; "
                  "run: python3 scripts/build_design_html.py", file=sys.stderr)
            sys.exit(1)
        print("[ok] DESIGN.html matches DESIGN.md")
        return
    DESIGN_HTML.write_text(generated, encoding="utf-8")
    print(f"wrote {DESIGN_HTML}")


if __name__ == "__main__":
    main()
