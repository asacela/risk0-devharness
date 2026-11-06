#!/usr/bin/env python3
"""Fill template.html from fragment files and fail loudly on leftovers.
Usage: build.py --mast mast.html --sections sections.html --foot "Updated ..." --out daily.html
mast.html: the inside of <header class="mast"> (see example.html). sections.html: all <details class="sec"> blocks."""
import argparse, re, sys, pathlib

here = pathlib.Path(__file__).parent
ap = argparse.ArgumentParser()
ap.add_argument("--mast", required=True); ap.add_argument("--sections", required=True)
ap.add_argument("--foot", required=True); ap.add_argument("--out", required=True)
a = ap.parse_args()

mast, sections = pathlib.Path(a.mast).read_text(), pathlib.Path(a.sections).read_text()
out = (here / "template.html").read_text()
for k, v in (("{{MAST}}", mast), ("{{SECTIONS}}", sections), ("{{FOOT}}", a.foot)):
    out = out.replace(k, v)

errs = []
if "{{" in out: errs.append("unfilled placeholder")
if out.count("<script>") != 1: errs.append("script count != 1")
if out.count('id="eyebrow"') != 1 or not re.search(r'id="eyebrow" data-updated="\d{4}-\d\d-\d\dT', out): errs.append("eyebrow missing data-updated ISO timestamp")
if out.count('id="spark"') != 1: errs.append("need exactly one #spark")
if out.count('class="vital ') != 4: errs.append("need exactly 4 .vital tiles")
for ex in ("Bold lead phrase", "ExceptionName", "Channel · topic", "One sentence:", "PostHog project name", "Say why", "Item</li>"):
    if ex in out: errs.append("example text left: " + ex)
ids = re.findall(r'data-id="([^"]+)"', out)
if len(ids) != len(set(ids)): errs.append("duplicate data-id")
secs = re.findall(r'<details class="sec"[^>]*id="(s-[a-z]+)"', out)
if len(secs) != len(set(secs)): errs.append("duplicate section id")
if errs:
    sys.exit("build failed: " + "; ".join(errs))
pathlib.Path(a.out).write_text(out)
print(f"ok {a.out}: {len(out)} bytes, sections {secs}, {len(ids)} todo items")
