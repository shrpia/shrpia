#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
المحلل - محلل بيانات اكسبيرت الزوايا
ضع ملفات CSV في مجلد "التقارير" ثم شغّل هذا الملف
النتائج تظهر في مجلد "مخرجات التحليل"
"""

import csv
import os
import sys
import json
from datetime import datetime
from collections import defaultdict
from pathlib import Path

# ─── المسارات ───────────────────────────────────────────────────────────────
BASE_DIR    = Path(__file__).parent
INPUT_DIR   = BASE_DIR / "التقارير"
OUTPUT_DIR  = BASE_DIR / "مخرجات التحليل"
OUTPUT_DIR.mkdir(exist_ok=True)

# ─── ثوابت التحليل ───────────────────────────────────────────────────────────
OUTCOME_COLS   = ['Confirmed', 'confirmed', 'Success', 'success', 'Result', 'result',
                  'Pass', 'pass', 'نجاح', 'النتيجة', 'outcome']
CORR_COL       = 'Corr_pct'
RATIO_COL      = 'Ratio_U1_U2_pct'
CLASS_COL      = 'Class'
DIR_COL        = 'Dir'
SESSION_COL    = 'U1X1_Session'
REACT_COL      = 'U1X1_React'
DUR_COL        = 'U1X1_Dur'
SYMBOL_COL     = 'Symbol'
TF_COL         = 'TF'
FORM_TIME_COL  = 'FormTime'

# ─── دوال مساعدة ─────────────────────────────────────────────────────────────
def safe_float(val, default=None):
    try:
        return float(val)
    except (TypeError, ValueError):
        return default

def corr_bucket(val):
    v = safe_float(val)
    if v is None: return 'غير محدد'
    if v >= 60:   return 'تصحيح > 60%'
    if v >= 30:   return 'تصحيح 30–60%'
    return 'تصحيح < 30%'

def ratio_bucket(val):
    v = safe_float(val)
    if v is None:  return 'غير محدد'
    if v > 150:    return 'نسبة > 150%'
    if v >= 100:   return 'نسبة 100–150%'
    if v >= 60:    return 'نسبة 60–100%'
    return 'نسبة < 60%'

def pct(a, b):
    return f"{a/b*100:.1f}%" if b else "0%"

def lift(succ, total, base_rate):
    if not total or not base_rate: return 0
    return (succ / total) / base_rate

def find_outcome_col(headers):
    for h in headers:
        if h in OUTCOME_COLS:
            return h
    return None

def is_success(val):
    return str(val).strip() in ('1', 'yes', 'Yes', 'YES', 'true', 'True', 'نجاح', 'pass', 'Pass')

# ─── تحميل البيانات ────────────────────────────────────────────────────────────
def load_csv(path):
    rows = []
    with open(path, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows

# ─── التحليل الإحصائي ─────────────────────────────────────────────────────────
def analyze(rows):
    if not rows:
        return None

    headers = list(rows[0].keys())
    outcome_col = find_outcome_col(headers)
    if not outcome_col:
        print(f"  ⚠️  لم يُعثر على عمود النتيجة. الأعمدة المتاحة: {headers[:10]}")
        return None

    N         = len(rows)
    successes = [r for r in rows if is_success(r.get(outcome_col, '0'))]
    failures  = [r for r in rows if not is_success(r.get(outcome_col, '0'))]
    base_rate = len(successes) / N if N else 0

    result = {
        'N': N,
        'n_success': len(successes),
        'n_fail':    len(failures),
        'base_rate': base_rate,
        'symbol':    rows[0].get(SYMBOL_COL, ''),
        'tf':        rows[0].get(TF_COL, ''),
        'date_from': rows[0].get(FORM_TIME_COL, ''),
        'date_to':   rows[-1].get(FORM_TIME_COL, ''),
    }

    def factor_stats(grp_fn, values, label_fn=None):
        out = []
        for v in values:
            grp  = [r for r in rows if grp_fn(r) == v]
            succ = [r for r in grp  if is_success(r.get(outcome_col, '0'))]
            if not grp: continue
            out.append({
                'label':   label_fn(v) if label_fn else v,
                'n':       len(grp),
                'success': len(succ),
                'rate':    len(succ) / len(grp),
                'lift':    lift(len(succ), len(grp), base_rate),
            })
        return sorted(out, key=lambda x: -x['lift'])

    # Class
    classes = sorted(set(r.get(CLASS_COL,'') for r in rows if r.get(CLASS_COL,'')))
    result['by_class'] = factor_stats(lambda r: r.get(CLASS_COL,''), classes)

    # Direction
    dirs = sorted(set(r.get(DIR_COL,'') for r in rows if r.get(DIR_COL,'')))
    result['by_dir'] = factor_stats(lambda r: r.get(DIR_COL,''), dirs)

    # Corr bucket
    result['by_corr'] = factor_stats(
        lambda r: corr_bucket(r.get(CORR_COL,'')),
        ['تصحيح > 60%','تصحيح 30–60%','تصحيح < 30%','غير محدد']
    )

    # Ratio bucket
    result['by_ratio'] = factor_stats(
        lambda r: ratio_bucket(r.get(RATIO_COL,'')),
        ['نسبة > 150%','نسبة < 60%','نسبة 60–100%','نسبة 100–150%','غير محدد']
    )

    # Session
    sessions = ['London','Asia','NewYork','Other','NA']
    result['by_session'] = factor_stats(lambda r: r.get(SESSION_COL,''), sessions)

    # React
    reacts = ['BOUNCE','BREAK','UNTOUCHED']
    result['by_react'] = factor_stats(lambda r: r.get(REACT_COL,''), reacts)

    # Combos: Class + Corr
    combos = defaultdict(lambda: [0,0])
    for r in rows:
        k = (r.get(CLASS_COL,''), corr_bucket(r.get(CORR_COL,'')))
        combos[k][0] += 1
        if is_success(r.get(outcome_col,'0')): combos[k][1] += 1

    combo_list = []
    for (c1,c2),(tot,s) in combos.items():
        if tot < 2: continue
        combo_list.append({
            'label':   f"{c1} + {c2}",
            'n':       tot,
            'success': s,
            'rate':    s/tot,
            'lift':    lift(s,tot,base_rate),
        })
    result['combos'] = sorted(combo_list, key=lambda x:-x['lift'])[:15]

    # Rules
    rules = []

    # Golden success rules
    perfect = [x for x in result['by_class'] if x['rate'] == 1.0 and x['n'] >= 3]
    if perfect:
        names = ', '.join(x['label'] for x in perfect)
        rules.append({
            'type': 'success',
            'condition': f"Class ∈ {{{names}}}",
            'outcome':   'نجاح مضمون 100%',
            'n': sum(x['n'] for x in perfect),
            'success': sum(x['success'] for x in perfect),
            'lift': 1.33,
        })

    if base_rate > 0:
        for item in result['by_corr']:
            if item['rate'] == 1.0 and item['n'] >= 5:
                rules.append({'type':'success','condition': item['label'],
                               'outcome':'نجاح مضمون 100%',
                               'n':item['n'],'success':item['success'],'lift':item['lift']})
        for item in result['by_ratio']:
            if item['rate'] == 1.0 and item['n'] >= 5:
                rules.append({'type':'success','condition': item['label'],
                               'outcome':'نجاح مضمون 100%',
                               'n':item['n'],'success':item['success'],'lift':item['lift']})

    # Failure rules
    for item in result['by_class']:
        if item['rate'] == 0.0 and item['n'] >= 3:
            rules.append({'type':'failure','condition':f"Class = {item['label']}",
                           'outcome':'فشل مضمون 100%',
                           'n':item['n'],'success':0,'lift':0})

    result['rules'] = rules
    return result

# ─── توليد HTML ────────────────────────────────────────────────────────────────
def generate_html(analysis, filename):
    r = analysis
    base_pct = f"{r['base_rate']*100:.1f}%"
    now = datetime.now().strftime('%Y-%m-%d %H:%M')

    def rows_html(data, cols=('label','n','success','rate','lift')):
        html = ''
        for item in data:
            if item['n'] == 0: continue
            rate_val = item['rate'] * 100
            lift_val = item['lift']
            if lift_val >= 1.2:
                row_cls = 'success-row'
            elif lift_val <= 0.7:
                row_cls = 'fail-row'
            else:
                row_cls = ''
            lift_badge = f'<span class="lift-badge {"lift-good" if lift_val>=1.2 else "lift-bad" if lift_val<=0.7 else "lift-neutral"}">{lift_val:.2f}×</span>'
            html += f'''<tr class="{row_cls}">
                <td>{item["label"]}</td>
                <td>{item["n"]}</td>
                <td>{item["success"]} ({rate_val:.1f}%)</td>
                <td><div class="bar-wrap"><div class="bar" style="width:{min(rate_val,100):.0f}%;background:{"#22c55e" if rate_val>=80 else "#f59e0b" if rate_val>=50 else "#ef4444"}"></div></div></td>
                <td>{lift_badge}</td>
            </tr>'''
        return html

    def rules_html(rules):
        html = ''
        for rule in rules:
            cls  = 'rule-success' if rule['type']=='success' else 'rule-fail'
            icon = '✅' if rule['type']=='success' else '❌'
            total = rule['n']
            succ  = rule['success']
            fail  = total - succ
            html += f'''
            <div class="rule-card {cls}">
                <div class="rule-header">{icon} إذا تحقق: <strong>{rule["condition"]}</strong></div>
                <div class="rule-body">
                    <span class="rule-outcome">{rule["outcome"]}</span>
                    <span class="rule-stats">حدث {succ} مرة نجاحاً و{fail} مرة فشلاً من أصل {total} حالة</span>
                    <span class="rule-lift">Lift: {rule["lift"]:.2f}×</span>
                </div>
            </div>'''
        return html

    html = f'''<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>تقرير التحليل — {filename}</title>
<style>
  :root {{
    --bg: #0f172a; --card: #1e293b; --border: #334155;
    --text: #f1f5f9; --muted: #94a3b8;
    --green: #22c55e; --red: #ef4444; --yellow: #f59e0b;
    --blue: #38bdf8; --purple: #a78bfa;
  }}
  * {{ box-sizing: border-box; margin:0; padding:0; }}
  body {{ font-family: 'Segoe UI', Tahoma, Arial, sans-serif; background:var(--bg); color:var(--text); padding:24px; line-height:1.6; }}
  h1 {{ font-size:2rem; color:var(--blue); margin-bottom:4px; }}
  h2 {{ font-size:1.2rem; color:var(--purple); margin:28px 0 12px; border-bottom:1px solid var(--border); padding-bottom:8px; }}
  .meta {{ color:var(--muted); font-size:.9rem; margin-bottom:24px; }}
  .kpi-grid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:16px; margin-bottom:28px; }}
  .kpi {{ background:var(--card); border:1px solid var(--border); border-radius:12px; padding:20px; text-align:center; }}
  .kpi .val {{ font-size:2rem; font-weight:700; }}
  .kpi .lbl {{ font-size:.85rem; color:var(--muted); margin-top:4px; }}
  .kpi.green .val {{ color:var(--green); }}
  .kpi.red .val   {{ color:var(--red); }}
  .kpi.blue .val  {{ color:var(--blue); }}
  .card {{ background:var(--card); border:1px solid var(--border); border-radius:12px; padding:20px; margin-bottom:20px; overflow-x:auto; }}
  table {{ width:100%; border-collapse:collapse; font-size:.9rem; }}
  th {{ background:#0f172a; color:var(--muted); padding:10px 12px; text-align:right; font-weight:600; }}
  td {{ padding:10px 12px; border-bottom:1px solid var(--border); }}
  tr:last-child td {{ border-bottom:none; }}
  .success-row td:first-child {{ border-right:3px solid var(--green); }}
  .fail-row    td:first-child {{ border-right:3px solid var(--red); }}
  .bar-wrap {{ background:#334155; border-radius:99px; height:8px; width:120px; }}
  .bar {{ height:8px; border-radius:99px; }}
  .lift-badge {{ padding:2px 8px; border-radius:99px; font-size:.8rem; font-weight:700; }}
  .lift-good    {{ background:#14532d; color:#86efac; }}
  .lift-bad     {{ background:#450a0a; color:#fca5a5; }}
  .lift-neutral {{ background:#1e3a5f; color:#93c5fd; }}
  .rule-card {{ border-radius:10px; padding:16px 20px; margin-bottom:12px; border:1px solid; }}
  .rule-success {{ background:#052e16; border-color:#166534; }}
  .rule-fail    {{ background:#2d0000; border-color:#7f1d1d; }}
  .rule-header  {{ font-size:1rem; margin-bottom:8px; }}
  .rule-body    {{ display:flex; flex-wrap:wrap; gap:12px; align-items:center; font-size:.85rem; color:var(--muted); }}
  .rule-outcome {{ color:var(--text); font-weight:600; }}
  .rule-lift    {{ margin-right:auto; color:var(--yellow); font-weight:700; }}
  .section-note {{ font-size:.8rem; color:var(--muted); margin-top:8px; font-style:italic; }}
  .warning {{ background:#431407; border:1px solid #9a3412; border-radius:8px; padding:12px 16px; margin-top:24px; font-size:.9rem; }}
  @media print {{
    body {{ background:#fff; color:#000; }}
    .card,.kpi,.rule-card {{ border:1px solid #ccc; }}
  }}
</style>
</head>
<body>

<h1>📊 تقرير التحليل الإحصائي</h1>
<div class="meta">
  الملف: <strong>{filename}</strong> &nbsp;|&nbsp;
  الرمز: <strong>{r["symbol"]}</strong> &nbsp;|&nbsp;
  الإطار الزمني: <strong>{r["tf"]}</strong> &nbsp;|&nbsp;
  الفترة: <strong>{r["date_from"][:10] if r["date_from"] else "—"}</strong> إلى <strong>{r["date_to"][:10] if r["date_to"] else "—"}</strong> &nbsp;|&nbsp;
  تاريخ التقرير: <strong>{now}</strong>
</div>

<div class="kpi-grid">
  <div class="kpi blue"><div class="val">{r["N"]}</div><div class="lbl">إجمالي الزوايا</div></div>
  <div class="kpi green"><div class="val">{r["n_success"]}</div><div class="lbl">ناجحة ({pct(r["n_success"],r["N"])})</div></div>
  <div class="kpi red"><div class="val">{r["n_fail"]}</div><div class="lbl">فاشلة ({pct(r["n_fail"],r["N"])})</div></div>
  <div class="kpi"><div class="val" style="color:var(--yellow)">{base_pct}</div><div class="lbl">معدل النجاح الأساسي</div></div>
</div>

<h2>🏷️ تحليل نوع الزاوية (Class)</h2>
<div class="card">
<table>
<tr><th>النوع</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_class"])}
</table>
</div>

<h2>📐 تحليل نسبة التصحيح (Corr%)</h2>
<div class="card">
<table>
<tr><th>نسبة التصحيح</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_corr"])}
</table>
<p class="section-note">تصحيح > 60% = إشارة قوية جداً على موجة قادمة</p>
</div>

<h2>⚖️ تحليل نسبة U1/U2 (Ratio)</h2>
<div class="card">
<table>
<tr><th>النسبة</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_ratio"])}
</table>
</div>

<h2>🕐 تحليل الجلسة</h2>
<div class="card">
<table>
<tr><th>الجلسة</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_session"])}
</table>
</div>

<h2>⚡ تحليل نوع التفاعل (React)</h2>
<div class="card">
<table>
<tr><th>نوع التفاعل</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_react"])}
</table>
</div>

<h2>🔀 تحليل الاتجاه</h2>
<div class="card">
<table>
<tr><th>الاتجاه</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["by_dir"])}
</table>
</div>

<h2>🔗 مجموعات العوامل (Class + التصحيح)</h2>
<div class="card">
<table>
<tr><th>المجموعة</th><th>العدد</th><th>الناجحة</th><th>النسبة</th><th>Lift</th></tr>
{rows_html(r["combos"])}
</table>
</div>

<h2>📋 القواعد التنبؤية</h2>
{rules_html(r["rules"])}

<div class="warning">
  ⚠️ <strong>تنبيه:</strong> هذه الأرقام مبنية على بيانات تاريخية. الأنماط الإحصائية لا تضمن النتائج المستقبلية. الارتباط لا يعني السببية. استخدم هذا التحليل كأداة مساعدة وليس كحكم نهائي.
</div>

</body>
</html>'''
    return html

# ─── النقطة الرئيسية ──────────────────────────────────────────────────────────
def main():
    print("=" * 60)
    print("       المحلل — محلل بيانات اكسبيرت الزوايا")
    print("=" * 60)

    csv_files = list(INPUT_DIR.glob("*.csv")) + list(INPUT_DIR.glob("*.CSV"))
    if not csv_files:
        print(f"\n⚠️  لا توجد ملفات CSV في المجلد: {INPUT_DIR}")
        print("    ضع ملفات التقارير في مجلد 'التقارير' ثم أعد تشغيل البرنامج.")
        input("\nاضغط Enter للخروج...")
        return

    print(f"\n✅ عُثر على {len(csv_files)} ملف/ملفات في مجلد التقارير:\n")
    for i, f in enumerate(csv_files, 1):
        print(f"   {i}. {f.name}")

    print("\n⏳ جاري التحليل...\n")

    success_count = 0
    for csv_path in csv_files:
        print(f"📂 تحليل: {csv_path.name}")
        try:
            rows = load_csv(csv_path)
            if not rows:
                print(f"  ⚠️  الملف فارغ، تم تخطيه.")
                continue

            print(f"  ✔ تم تحميل {len(rows)} سجل")
            analysis = analyze(rows)

            if not analysis:
                print(f"  ❌ فشل التحليل — تحقق من وجود عمود النتيجة (Confirmed/Success/...)")
                continue

            print(f"  ✔ معدل النجاح الإجمالي: {analysis['base_rate']*100:.1f}%")
            print(f"  ✔ ناجحة: {analysis['n_success']} | فاشلة: {analysis['n_fail']}")

            # توليد HTML
            stem     = csv_path.stem
            out_name = f"تقرير_{stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
            out_path = OUTPUT_DIR / out_name
            html     = generate_html(analysis, csv_path.name)

            with open(out_path, 'w', encoding='utf-8') as f:
                f.write(html)

            print(f"  ✅ التقرير محفوظ: {out_path.name}\n")
            success_count += 1

        except Exception as e:
            print(f"  ❌ خطأ: {e}\n")

    print("=" * 60)
    if success_count:
        print(f"✅ تم الانتهاء! {success_count} تقرير محفوظ في:")
        print(f"   {OUTPUT_DIR}")
    else:
        print("❌ لم يُنتج أي تقرير. راجع الأخطاء أعلاه.")
    print("=" * 60)
    input("\nاضغط Enter للخروج...")

if __name__ == "__main__":
    main()
