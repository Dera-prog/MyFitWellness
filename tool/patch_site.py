"""Patch the Flutter web build's HTML/manifest for the marketing site.

Usage: python tool/patch_site.py [build_dir]
"""

import json
import pathlib
import sys

TITLE = "MyFitWellness — your gym, your plan, your progress"
DESCRIPTION = (
    "MyFitWellness turns your gym membership into a daily plan: workout "
    "tracking, streaks, goals, meal plans and a coach in your pocket."
)

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "build/site")

index = root / "index.html"
html = index.read_text(encoding="utf-8")

html = html.replace("<title>myfitwellness</title>", f"<title>{TITLE}</title>")
html = html.replace(
    '<meta name="description" content="A new Flutter project.">',
    f'<meta name="description" content="{DESCRIPTION}">',
)
html = html.replace(
    '<meta name="apple-mobile-web-app-title" content="myfitwellness">',
    '<meta name="apple-mobile-web-app-title" content="MyFitWellness">',
)

head_extra = f"""  <meta name="theme-color" content="#06110F">
  <meta property="og:type" content="website">
  <meta property="og:title" content="{TITLE}">
  <meta property="og:description" content="{DESCRIPTION}">
  <meta name="twitter:card" content="summary_large_image">
  <style>html, body {{ margin: 0; background: #F5F7F3; }}</style>
"""
if 'name="theme-color"' not in html:
    html = html.replace("</head>", head_extra + "</head>", 1)
index.write_text(html, encoding="utf-8")

manifest_path = root / "manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest.update(
    {
        "name": "MyFitWellness",
        "short_name": "MyFitWellness",
        "description": DESCRIPTION,
        "theme_color": "#06110F",
        "background_color": "#F5F7F3",
    }
)
manifest_path.write_text(json.dumps(manifest, indent=4) + "\n", encoding="utf-8")

print(f"patched {index} and {manifest_path}")