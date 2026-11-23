#!/usr/bin/env python3
"""Generate harness-status.html from feature_list.json (durable mirror; see AGENTS.md).

Shows only the *relational* view that raw feature_list.json hides: overall
progress, counts by status, and which features are ready to work vs blocked by
their dependencies. It does NOT duplicate each feature's prose
(user_visible_behavior / verification / evidence) — that lives in
feature_list.json and docs/specs/. This page links there; it does not copy it.

Usage:
  python3 scripts/build_status_html.py          # (re)writes visual/harness-status.html
  python3 scripts/build_status_html.py --check   # exit 1 if visual/harness-status.html is stale
"""
import html
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FEATURE_LIST = ROOT / "feature_list.json"
STATUS_HTML = ROOT / "visual" / "harness-status.html"
SPECS_DIR = ROOT / "docs" / "specs"

# A feature counts as finished for progress/readiness once it reaches one of these.
DONE = {"accepted", "passing"}


def esc(text):
    return html.escape(str(text), quote=True)


def status_kind(status):
    """Map a raw status to a stable CSS modifier. Unknown statuses stay neutral."""
    if status in DONE:
        return "done"
    if status in ("not_started", "blocked", "failing"):
        return "pending"
    return "neutral"


def load_features():
    data = json.loads(FEATURE_LIST.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise SystemExit("feature_list.json is not a JSON array")
    return data


def counts_by_status(features):
    counts = {}
    for item in features:
        status = item.get("status", "unknown")
        counts[status] = counts.get(status, 0) + 1
    # Deterministic order: DONE statuses first, then the rest alphabetically.
    return sorted(counts.items(), key=lambda kv: (kv[0] not in DONE, kv[0]))


def summary_chips_html(features):
    chips = []
    for status, n in counts_by_status(features):
        chips.append(
            f'<span class="status-chip status-chip--{status_kind(status)}">'
            f'<code>{esc(status)}</code> {n}</span>'
        )
    return "".join(chips)


def spec_cell(feature_id):
    """Link the id to its spec file when it exists; otherwise plain code."""
    code = f"<code>{esc(feature_id)}</code>"
    if (SPECS_DIR / f"{feature_id}.md").exists():
        return f'<a href="../docs/specs/{esc(feature_id)}.md">{code}</a>'
    return code


def deps_cell(item, done_ids):
    deps = item.get("depends_on") or []
    if not deps:
        return '<span class="deps deps--none">—</span>'
    if item.get("status") in DONE:
        # Already finished; dependency readiness is moot.
        return " ".join(f"<code>{esc(d)}</code>" for d in deps)
    missing = [d for d in deps if d not in done_ids]
    if not missing:
        return '<span class="deps deps--ready">lista · deps ✓</span>'
    chips = " ".join(f"<code>{esc(d)}</code>" for d in missing)
    return f'<span class="deps deps--blocked">bloqueada por {chips}</span>'


def rows_html(features, done_ids):
    rows = []
    for item in features:
        fid = item.get("id", "")
        status = item.get("status", "unknown")
        rows.append(
            "<tr>"
            f'<td class="col-id">{spec_cell(fid)}</td>'
            f'<td class="col-area">{esc(item.get("area", ""))}</td>'
            f'<td class="col-title">{esc(item.get("title", ""))}</td>'
            f'<td class="col-status"><span class="badge badge--{status_kind(status)}">{esc(status)}</span></td>'
            f'<td class="col-deps">{deps_cell(item, done_ids)}</td>'
            "</tr>"
        )
    return "".join(rows)


PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Harness status — feature_list.json</title>
    <link rel="icon" href="data:,">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap">
    <link rel="stylesheet" href="../styles.css">
    <style>
      body {{
        background: var(--color-background);
        color: var(--color-on-surface);
        font-family: var(--font-family-base);
        margin: 0;
      }}
      .status-doc {{
        max-width: 64rem;
        margin: 0 auto;
        padding: var(--space-xl) var(--space-gutter) calc(var(--space-xl) * 2);
      }}
      .status-doc__eyebrow {{
        font-size: var(--text-label-sm-font-size);
        font-weight: var(--text-label-sm-font-weight);
        line-height: var(--text-label-sm-line-height);
        letter-spacing: var(--text-label-sm-letter-spacing);
        text-transform: uppercase;
        color: var(--color-primary);
      }}
      .status-doc h1 {{
        font-size: var(--text-headline-lg-font-size);
        font-weight: var(--text-headline-lg-font-weight);
        line-height: var(--text-headline-lg-line-height);
        letter-spacing: var(--text-headline-lg-letter-spacing);
        margin: var(--space-xs) 0 var(--space-lg);
      }}
      .status-doc h2 {{
        font-size: var(--text-headline-md-font-size);
        font-weight: var(--text-headline-md-font-weight);
        line-height: var(--text-headline-md-line-height);
        letter-spacing: var(--text-headline-md-letter-spacing);
        border-top: 1px solid var(--color-border);
        margin-top: var(--space-xl);
        padding-top: var(--space-lg);
      }}
      .status-doc p {{
        font-size: var(--text-body-md-font-size);
        line-height: var(--text-body-md-line-height);
        color: var(--color-on-surface-variant);
      }}
      .status-doc code {{
        background: var(--color-surface-container-low);
        color: var(--color-primary);
        border-radius: var(--radius-sm);
        padding: 0.1em 0.35em;
        font-size: 0.92em;
      }}
      .status-doc a {{ color: var(--color-primary); }}
      .progress {{
        margin: var(--space-md) 0 var(--space-sm);
      }}
      .progress__meta {{
        display: flex;
        justify-content: space-between;
        font-size: var(--text-body-sm-font-size);
        color: var(--color-on-surface-variant);
        margin-bottom: var(--space-xs);
      }}
      .progress__track {{
        height: 0.75rem;
        background: var(--color-surface-container-low);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-full);
        overflow: hidden;
      }}
      .progress__fill {{
        height: 100%;
        background: var(--color-primary);
        border-radius: var(--radius-full);
      }}
      .status-chips {{
        display: flex;
        flex-wrap: wrap;
        gap: var(--space-sm);
        margin: var(--space-md) 0;
      }}
      .status-chip {{
        display: inline-flex;
        align-items: center;
        gap: 0.4em;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-full);
        padding: var(--space-xs) var(--space-sm);
        font-size: var(--text-body-sm-font-size);
      }}
      .status-chip code {{ background: transparent; padding: 0; }}
      .status-chip--done {{ border-color: var(--color-primary); color: var(--color-primary); }}
      .status-chip--pending {{ color: var(--color-on-surface-variant); }}
      .table-scroll {{ overflow-x: auto; }}
      table.features {{
        width: 100%;
        border-collapse: collapse;
        margin: var(--space-md) 0;
        font-size: var(--text-body-sm-font-size);
      }}
      .features th, .features td {{
        text-align: left;
        padding: var(--space-xs) var(--space-sm);
        border-bottom: 1px solid var(--color-border);
        vertical-align: top;
      }}
      .features th {{
        color: var(--color-on-surface-variant);
        font-weight: var(--text-body-md-font-weight);
        white-space: nowrap;
      }}
      .features .col-title {{ color: var(--color-on-surface); }}
      .features .col-area {{ color: var(--color-on-surface-variant); }}
      .badge {{
        display: inline-block;
        border-radius: var(--radius-sm);
        padding: 0.1em 0.5em;
        font-size: 0.85em;
        white-space: nowrap;
      }}
      .badge--done {{ background: var(--color-primary); color: var(--color-on-primary); }}
      .badge--pending {{ background: var(--color-surface-container-low); color: var(--color-on-surface-variant); border: 1px solid var(--color-border); }}
      .badge--neutral {{ background: var(--color-surface-container-low); color: var(--color-on-surface-variant); border: 1px solid var(--color-border); }}
      .deps code {{ font-size: 0.85em; }}
      .deps--none {{ color: var(--color-outline); }}
      .deps--ready {{ color: var(--color-primary); }}
      .deps--blocked {{ color: var(--color-error); }}
      .status-doc__note {{
        margin-top: var(--space-xl);
        font-size: var(--text-body-sm-font-size);
        color: var(--color-on-surface-variant);
      }}
    </style>
  </head>
  <body>
    <main class="status-doc">
      <p class="status-doc__eyebrow">feature_list.json — status</p>
      <h1>Estado del harness</h1>

      <div class="progress">
        <div class="progress__meta">
          <span>Avance (accepted · passing)</span>
          <span><strong>{done}/{total}</strong> · {pct}%</span>
        </div>
        <div class="progress__track" role="progressbar" aria-valuemin="0" aria-valuemax="{total}" aria-valuenow="{done}">
          <div class="progress__fill" style="width:{pct}%"></div>
        </div>
      </div>

      <div class="status-chips">{chips}</div>

      <h2>Features</h2>
      <p>Orden de <code>feature_list.json</code>. El <code>id</code> enlaza a su spec en
        <code>docs/specs/</code> cuando existe. La columna de dependencias deriva readiness: una
        feature pendiente está <em>lista</em> si todas sus <code>depends_on</code> están en
        <code>accepted</code>/<code>passing</code>, o <em>bloqueada</em> indicando cuáles faltan.</p>
      <div class="table-scroll">
        <table class="features">
          <thead>
            <tr><th>id</th><th>área</th><th>título</th><th>estado</th><th>dependencias</th></tr>
          </thead>
          <tbody>{rows}</tbody>
        </table>
      </div>

      <p class="status-doc__note">Página generada por <code>scripts/build_status_html.py</code> desde
        <code>feature_list.json</code>. Es un espejo de solo lectura; no se edita a mano ni es una
        fuente de verdad distinta. La prosa de cada feature (comportamiento, verificación, evidencia)
        vive en <code>feature_list.json</code> y <code>docs/specs/</code>.</p>
    </main>
  </body>
</html>
"""


def build():
    features = load_features()
    total = len(features)
    done_ids = {item.get("id") for item in features if item.get("status") in DONE}
    done = len(done_ids)
    pct = round(done * 100 / total) if total else 0
    return PAGE_TEMPLATE.format(
        done=done,
        total=total,
        pct=pct,
        chips=summary_chips_html(features),
        rows=rows_html(features, done_ids),
    )


def main():
    generated = build()
    if "--check" in sys.argv[1:]:
        current = STATUS_HTML.read_text(encoding="utf-8") if STATUS_HTML.exists() else None
        if current != generated:
            print("FAILED - visual/harness-status.html is stale relative to feature_list.json; "
                  "run: python3 scripts/build_status_html.py", file=sys.stderr)
            sys.exit(1)
        print("[ok] visual/harness-status.html matches feature_list.json")
        return
    STATUS_HTML.parent.mkdir(parents=True, exist_ok=True)
    STATUS_HTML.write_text(generated, encoding="utf-8")
    print(f"wrote {STATUS_HTML}")


if __name__ == "__main__":
    main()
