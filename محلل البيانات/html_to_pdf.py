#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
html_to_pdf — يحوّل تقارير HTML إلى PDF
ضع ملفات HTML في مجلد "مخرجات التحليل" ثم شغّل هذا الملف
"""

import os
import sys
from pathlib import Path

try:
    import weasyprint
except ImportError:
    print("⚙️  جاري تثبيت weasyprint...")
    os.system(f"{sys.executable} -m pip install weasyprint")
    import weasyprint

# ─── المسارات ────────────────────────────────────────────────────────────────
BASE_DIR   = Path(__file__).parent
OUTPUT_DIR = BASE_DIR / "مخرجات التحليل"

if not OUTPUT_DIR.exists():
    print("❌ مجلد 'مخرجات التحليل' غير موجود")
    sys.exit(1)

# ─── ابحث عن ملفات HTML ──────────────────────────────────────────────────────
html_files = sorted(OUTPUT_DIR.glob("*.html"))

if not html_files:
    print("❌ لا توجد ملفات HTML في مجلد مخرجات التحليل")
    sys.exit(1)

print(f"📄 وجدت {len(html_files)} ملف HTML:\n")

converted = 0
failed    = 0

for html_path in html_files:
    pdf_path = html_path.with_suffix(".pdf")

    # تخطّ إذا PDF موجود وأحدث من HTML
    if pdf_path.exists() and pdf_path.stat().st_mtime > html_path.stat().st_mtime:
        print(f"  ⏭️  {html_path.name} — PDF محدّث بالفعل، تم تخطّيه")
        continue

    print(f"  🔄 {html_path.name}")
    try:
        html_url = html_path.as_uri()
        weasyprint.HTML(url=html_url).write_pdf(str(pdf_path))
        size_kb = pdf_path.stat().st_size // 1024
        print(f"     ✅ → {pdf_path.name}  ({size_kb} KB)")
        converted += 1
    except Exception as e:
        print(f"     ❌ فشل: {e}")
        failed += 1

print(f"\n{'─'*50}")
print(f"✅ تم تحويل: {converted} ملف")
if failed:
    print(f"❌ فشل:      {failed} ملف")
print(f"📁 المخرجات في: {OUTPUT_DIR}")
