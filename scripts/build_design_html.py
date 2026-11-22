#!/usr/bin/env python3
"""Generate DESIGN.html from DESIGN.md (durable mirror; see AGENTS.md).

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


def frontmatter_meta(frontmatter):
    name = re.search(r"^name:\s*(.+)$", frontmatter, re.MULTILINE)
    desc = re.search(r"^description:\s*(.+)$", frontmatter, re.MULTILINE)
    return (
        name.group(1).strip() if name else "Design Direction",
        desc.group(1).strip() if desc else "",
    )


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
    if not color_tokens:
        return ""
    chips = []
    for name, hexval in color_tokens:
        chips.append(
            '<div class="design-doc__swatch">'
            f'<span class="design-doc__swatch-color" aria-hidden="true" style="background:{hexval}"></span>'
            f'<span class="design-doc__swatch-label"><code>{name}</code><br>{hexval}</span>'
            "</div>"
        )
    return (
        "<h2>Paleta de color (preview)</h2>\n"
        '<p>Swatches generados directamente de <code>colors:</code> en el frontmatter de '
        "<code>DESIGN.md</code>; ningún valor está inventado aquí.</p>\n"
        f'<div class="design-doc__swatches">{"".join(chips)}</div>'
    )


def inline(text):
    text = html.escape(text, quote=False)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"~~([^~]+)~~", r"<del>\1</del>", text)
    text = re.sub(r"(?<!\*)\*([^*\n]+)\*(?!\*)", r"<em>\1</em>", text)
    return text


TABLE_ROW_RE = re.compile(r"^\s*\|(.+)\|\s*$")
TABLE_SEP_RE = re.compile(r"^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)+\|?\s*$")


def parse_body(body):
    lines = body.split("\n")
    out = []
    i = 0
    n = len(lines)

    def is_blank(s):
        return s.strip() == ""

    while i < n:
        line = lines[i]

        if is_blank(line):
            i += 1
            continue

        heading = re.match(r"^(#{1,3})\s+(.*)$", line)
        if heading:
            level = len(heading.group(1))
            out.append(f"<h{level}>{inline(heading.group(2).strip())}</h{level}>")
            i += 1
            continue

        if TABLE_ROW_RE.match(line) and i + 1 < n and TABLE_SEP_RE.match(lines[i + 1]):
            header_cells = [c.strip() for c in line.strip().strip("|").split("|")]
            i += 2
            rows = []
            while i < n and TABLE_ROW_RE.match(lines[i]):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
                i += 1
            thead = "".join(f"<th>{inline(c)}</th>" for c in header_cells)
            tbody_rows = "".join(
                "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>" for r in rows
            )
            out.append(
                f"<table><thead><tr>{thead}</tr></thead><tbody>{tbody_rows}</tbody></table>"
            )
            continue

        if line.startswith("> "):
            quote_lines = []
            while i < n and lines[i].startswith("> "):
                quote_lines.append(lines[i][2:])
                i += 1
            out.append(f"<blockquote><p>{inline(' '.join(quote_lines))}</p></blockquote>")
            continue

        bullet = re.match(r"^- (.*)$", line)
        if bullet:
            items = []
            while i < n:
                m = re.match(r"^- (.*)$", lines[i])
                if m:
                    items.append([m.group(1)])
                    i += 1
                elif lines[i].startswith("  ") and not is_blank(lines[i]) and items:
                    items[-1].append(lines[i].strip())
                    i += 1
                else:
                    break
            lis = "".join(f"<li>{inline(' '.join(parts))}</li>" for parts in items)
            out.append(f"<ul>{lis}</ul>")
            continue

        numbered = re.match(r"^\d+\.\s+(.*)$", line)
        if numbered:
            items = []
            while i < n:
                m = re.match(r"^\d+\.\s+(.*)$", lines[i])
                if m:
                    items.append([m.group(1)])
                    i += 1
                elif lines[i].startswith("  ") and not is_blank(lines[i]) and items:
                    items[-1].append(lines[i].strip())
                    i += 1
                else:
                    break
            lis = "".join(f"<li>{inline(' '.join(parts))}</li>" for parts in items)
            out.append(f"<ol>{lis}</ol>")
            continue

        para_lines = []
        while i < n and not is_blank(lines[i]) and not re.match(r"^(#{1,3})\s+", lines[i]) \
                and not re.match(r"^- ", lines[i]) and not re.match(r"^\d+\.\s+", lines[i]) \
                and not lines[i].startswith("> ") and not TABLE_ROW_RE.match(lines[i]):
            para_lines.append(lines[i])
            i += 1
        if para_lines:
            out.append(f"<p>{inline(' '.join(para_lines))}</p>")
            continue

        i += 1

    return "\n".join(out)


PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{title} — DESIGN.md</title>
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
        margin: var(--space-xs) 0 var(--space-md);
      }}
      .design-doc__description {{
        font-size: var(--text-body-md-font-size);
        line-height: var(--text-body-md-line-height);
        color: var(--color-on-surface-variant);
        margin: 0 0 var(--space-xl);
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
      .design-doc h3 {{
        font-size: var(--text-body-md-font-size);
        font-weight: 700;
        color: var(--color-primary);
        margin-top: var(--space-lg);
      }}
      .design-doc p, .design-doc li {{
        font-size: var(--text-body-md-font-size);
        line-height: var(--text-body-md-line-height);
      }}
      .design-doc ul, .design-doc ol {{
        padding-left: 1.25rem;
      }}
      .design-doc li + li {{
        margin-top: var(--space-xs);
      }}
      .design-doc code {{
        background: var(--color-surface-container-low);
        color: var(--color-primary);
        border-radius: var(--radius-sm);
        padding: 0.1em 0.35em;
        font-size: 0.92em;
      }}
      .design-doc blockquote {{
        margin: var(--space-md) 0;
        padding: var(--space-sm) var(--space-md);
        border-left: 3px solid var(--color-accent);
        background: var(--color-surface-container-low);
        border-radius: var(--radius-sm);
        color: var(--color-on-surface-variant);
      }}
      .design-doc table {{
        width: 100%;
        border-collapse: collapse;
        margin: var(--space-md) 0;
        font-size: var(--text-body-sm-font-size);
      }}
      .design-doc th, .design-doc td {{
        border: 1px solid var(--color-border);
        padding: var(--space-xs) var(--space-sm);
        text-align: left;
      }}
      .design-doc th {{
        background: var(--color-surface-container-low);
      }}
      .design-doc del {{
        color: var(--color-on-surface-variant);
      }}
      .design-doc__frontmatter {{
        background: var(--color-surface);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-lg);
        padding: var(--space-md);
        overflow-x: auto;
      }}
      .design-doc__frontmatter pre {{
        margin: 0;
        font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
        font-size: var(--text-body-sm-font-size);
        white-space: pre-wrap;
        word-break: break-word;
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
      <p class="design-doc__eyebrow">DESIGN.md — fuente de verdad</p>
      <h1>{title}</h1>
      <p class="design-doc__description">{description}</p>
      <h2>Vista previa en vivo</h2>
      <p>Renderiza el <code>index.html</code> publicado en este mismo worktree/servidor. Puede
        no reflejar aún las secciones de "Dirección del rediseño" todavía no implementadas.</p>
      <div class="design-doc__preview">
        <iframe src="index.html" title="Vista previa en vivo de la Tarjeta digital (index.html)" loading="lazy"></iframe>
        <p class="design-doc__preview-caption">390px de ancho simulado · si se sirve este archivo
          sin servidor (<code>file://</code>), el iframe puede no cargar por restricciones del
          navegador; usa <code>python3 -m http.server</code> para verlo en vivo.</p>
      </div>
{color_swatches_html}
      <h2>Metadata (frontmatter)</h2>
      <div class="design-doc__frontmatter"><pre>{frontmatter_escaped}</pre></div>
{body_html}
    </main>
  </body>
</html>
"""


def build():
    text = DESIGN_MD.read_text(encoding="utf-8")
    frontmatter, body = split_frontmatter(text)
    title, description = frontmatter_meta(frontmatter)
    body_html = parse_body(body)
    color_tokens = parse_colors(frontmatter)
    return PAGE_TEMPLATE.format(
        title=html.escape(title, quote=False),
        description=html.escape(description, quote=False),
        frontmatter_escaped=html.escape(frontmatter.strip("\n"), quote=False),
        color_swatches_html=color_swatches_html(color_tokens),
        body_html=body_html,
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
