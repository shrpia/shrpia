#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AIB Angles Expert — Data Analyzer v4
Generates 3 report types for all pairs combined and each pair individually.

Report 1: 1_عوامل_النجاح       — Success factors per test section
Report 2: 2_التقرير_الشامل      — Tier ranking + transitions + angle cards
Report 3: 3_التوليفات_والمقارنة — 3-element combo analysis
"""

import os, sys, re
from pathlib import Path
from datetime import datetime
from collections import defaultdict

try:
    import pandas as pd
    import numpy as np
except ImportError:
    os.system(f"{sys.executable} -m pip install pandas numpy -q")
    import pandas as pd
    import numpy as np

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent
DATA = BASE / "التقارير"
OUT  = BASE / "مخرجات_v4"

# ── Constants ──────────────────────────────────────────────────────────────────
TESTS_6 = [
    # (col_prefix, dir_filter, display_label)
    ("U1X1",  None,   "U1X1"),
    ("U2X1",  None,   "U2X1"),
    ("DLX1",  "BUY",  "BUY-DLX1"),
    ("DRX1",  "BUY",  "BUY-DRX1"),
    ("DLX1",  "SELL", "SELL-DLX1"),
    ("DRX1",  "SELL", "SELL-DRX1"),
]
TEST4      = ["U1X1", "U2X1", "DLX1", "DRX1"]
SESSION_AR = {"London":"لندن","NewYork":"نيويورك","Asia":"آسيا","Other":"أخرى","NA":"—"}
GOOD_CLS   = {"ZB","ZC","ZD","ZE"}
WEAK_CLS   = {"ZF","ZG","ZH","ZO"}

# ── Helpers ────────────────────────────────────────────────────────────────────
def pct(n, d):   return round(100 * n / d, 1) if d else 0.0
def lft(r, b):   return round(r / b, 2) if b else 0.0

def corr_bkt(corr, direction):
    p = "B" if str(direction).upper() == "BUY" else "S"
    v = float(corr)
    if v >= 62:  return f"{p}-ALPHA عميق"
    if v >= 38:  return f"{p}-ALPHA منخفض"
    return f"{p}-BETA"

def ratio_bkt(r):
    r = float(r)
    if r < 60:  return "< 60%"
    if r < 100: return "60-100%"
    if r < 140: return "100-140%"
    return "> 140%"

def prev_cls(s):
    if pd.isna(s) or str(s).strip() in ('', 'nan', 'NA'): return "—"
    m = re.match(r'[BS]-([A-Z]+)-', str(s).strip())
    return m.group(1) if m else "—"

def ctx_classes(row, side, n=5):
    out = []
    for i in range(1, n+1):
        v = str(row.get(f"{side}_{i}", '')).strip()
        m = re.match(r'[BS]-([A-Z]+)-', v)
        if m: out.append(m.group(1))
    return out

def rate_color(r):
    if r >= .50: return "#37d67a"
    if r >= .35: return "#4db1ff"
    if r >= .25: return "#ffd34d"
    return "#ff6b6b"

def row_bg(r):
    if r >= .50:  return 'style="background:#0d2e1a"'
    if r >= .35:  return 'style="background:#0d1f2e"'
    if r < .15:   return 'style="background:#2e0d0d"'
    return ""

def lift_badge(lv):
    if lv >= 2.0:  return f'<span style="color:#37d67a;font-weight:bold">×{lv}</span>'
    if lv >= 1.3:  return f'<span style="color:#4db1ff">×{lv}</span>'
    if lv >= 1.0:  return f'<span style="color:#ffd34d">×{lv}</span>'
    return f'<span style="color:#ff6b6b">×{lv}</span>'

# ── CSS ────────────────────────────────────────────────────────────────────────
CSS = """
*{margin:0;padding:0;box-sizing:border-box;font-family:Arial,Tahoma,sans-serif}
body{max-width:1100px;background:#0b1520;color:#e9eef4;padding:30px 32px;margin:0 auto}
h1{font-size:26px;color:#4db1ff;text-align:center;margin-bottom:4px}
h2{font-size:17px;color:#ffd34d;margin:28px 0 10px;border-right:4px solid #ffd34d;padding-right:9px}
h3{font-size:14px;color:#9fb0c0;margin:16px 0 6px}
.sub{text-align:center;color:#9fb0c0;font-size:13px;margin:4px 0 20px}
.stat-row{display:flex;gap:12px;margin-bottom:14px;flex-wrap:wrap}
.stat-card{flex:1;min-width:110px;background:#172533;border-radius:10px;padding:11px 13px}
.stat-card .t{font-size:12px;color:#9fb0c0}
.stat-card .v{font-size:20px;font-weight:bold;margin-top:3px}
.stat-card .s{font-size:11px;color:#6f8294}
table{width:100%;border-collapse:collapse;margin-top:4px}
td,th{padding:7px 9px;font-size:13px;border-bottom:1px solid #1e3244;text-align:right}
th{color:#ffd34d;background:#111e2b}
tr:hover{background:#1a2e3d}
.two-col{display:flex;gap:16px;flex-wrap:wrap}.two-col>div{flex:1;min-width:280px}
.three-col{display:flex;gap:14px;flex-wrap:wrap}.three-col>div{flex:1;min-width:250px}
.section{background:#0d1a27;border:1px solid #1e3244;border-radius:12px;padding:16px;margin:18px 0}
.sect-hdr{font-size:16px;color:#4db1ff;font-weight:bold;border-bottom:1px solid #1e3244;
          padding-bottom:8px;margin-bottom:12px}
.stat-mini{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:10px}
.sm-card{background:#172533;border-radius:8px;padding:7px 12px;font-size:13px}
.sm-card b{font-size:16px;display:block}
.top3-box{background:#0a1e10;border:1px solid #1a4020;border-radius:8px;padding:12px;margin-top:12px}
.top3-hdr{color:#37d67a;font-size:13px;font-weight:bold;margin-bottom:7px}
.top3-row{font-size:12px;padding:5px 8px;border-radius:4px;margin:3px 0}
.badge{display:inline-block;background:#1a2e3d;border-radius:5px;padding:2px 8px;
       font-size:12px;margin:0 2px}
.angle-card{background:#111e2b;border:1px solid #1e3244;border-radius:10px;
            padding:12px;margin-bottom:10px}
.angle-header{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:6px}
.angle-id{color:#6f8294;font-size:12px}
.angle-cls{font-size:16px;font-weight:bold}
.angle-dir{background:#1a2e3d;border-radius:4px;padding:1px 7px;font-size:12px}
.angle-meta{display:flex;gap:8px;flex-wrap:wrap;margin:4px 0}
.test-table td,.test-table th{font-size:12px;padding:4px 7px}
.sep{border-top:2px solid #1e3244;margin:28px 0}
.foot{text-align:center;color:#6f8294;font-size:11px;margin-top:22px}
.cls-section{background:#0d1a27;border:1px solid #1e3244;border-radius:12px;padding:16px;margin:20px 0}
.cls-hdr{display:flex;gap:10px;align-items:center;flex-wrap:wrap;padding-bottom:8px;border-bottom:1px solid #1e3244;margin-bottom:12px}
.cb-row{margin:8px 0 12px}
.occ-table td,.occ-table th{font-size:12px;padding:5px 7px}
"""

def html_wrap(title, body, ts):
    return (f'<!doctype html><html lang="ar" dir="rtl"><head>'
            f'<meta charset="utf-8"><title>{title}</title>'
            f'<style>{CSS}</style></head><body>\n{body}\n'
            f'<div class="foot">AIB Angles Expert v4 · {ts}</div></body></html>')

# ── Data loading ───────────────────────────────────────────────────────────────

def load_data():
    files = sorted(DATA.glob("*.csv"))
    if not files:
        print(f"ERROR: No CSV files in {DATA}")
        sys.exit(1)
    dfs = []
    for f in files:
        try:
            df = pd.read_csv(f)
            # Extract symbol: look for 6-capital-letter pair in filename
            m = re.search(r'_([A-Z]{6})_', f.stem)
            sym = m.group(1) if m else f.stem[:6].upper()
            df['_symbol'] = sym
            dfs.append(df)
            print(f"  ✓ {f.name}  [{sym}]  {len(df)} rows")
        except Exception as e:
            print(f"  ✗ {f.name}: {e}")
    df = pd.concat(dfs, ignore_index=True)
    print(f"  → Total: {len(df)} rows from {len(dfs)} file(s)")
    return df

def preprocess(df):
    df = df.copy()
    df['_corr_bkt']  = df.apply(lambda r: corr_bkt(r['Corr_pct'], r['Dir']), axis=1)
    df['_ratio_bkt'] = df['Ratio_U1_U2_pct'].apply(ratio_bkt)
    p33 = df['L_points'].quantile(0.33)
    p67 = df['L_points'].quantile(0.67)
    df['_l_bkt'] = df['L_points'].apply(
        lambda v: 'صغيرة' if v <= p33 else ('متوسطة' if v <= p67 else 'كبيرة'))
    df['_prev_cls'] = df['Left_1'].apply(prev_cls)
    # Ensure numeric TP columns
    for t in TEST4:
        df[f'{t}_TP1_Hit'] = pd.to_numeric(df[f'{t}_TP1_Hit'], errors='coerce').fillna(0).astype(int)
    return df

# ── Factor analysis helpers ────────────────────────────────────────────────────

def factor_stats(key_vals, succ_vals, base_rate, min_n=2):
    """Returns sorted list of {label, N, S, rate, lift}."""
    grps = defaultdict(lambda: {'N': 0, 'S': 0})
    for k, s in zip(key_vals, succ_vals):
        k = str(k) if not pd.isna(k) else '—'
        grps[k]['N'] += 1
        grps[k]['S'] += int(bool(s))
    result = []
    for k, g in grps.items():
        n, s = g['N'], g['S']
        if n < min_n: continue
        r = s / n
        result.append({'label': k, 'N': n, 'S': s, 'rate': r, 'lift': lft(r, base_rate)})
    return sorted(result, key=lambda x: -x['rate'])

def factor_tbl(stats, col_name="القيمة"):
    if not stats:
        return '<p style="color:#6f8294;font-size:12px;margin:6px 0">— لا بيانات كافية —</p>'
    h = (f'<table><tr><th>{col_name}</th><th>لمسات</th>'
         f'<th>نجاح</th><th>نسبة</th><th>Lift</th></tr>')
    for d in stats:
        rc = rate_color(d['rate'])
        h += (f'<tr {row_bg(d["rate"])}><td>{d["label"]}</td>'
              f'<td>{d["N"]}</td><td>{d["S"]}</td>'
              f'<td style="color:{rc};font-weight:bold">{pct(d["S"],d["N"])}%</td>'
              f'<td>{lift_badge(d["lift"])}</td></tr>')
    return h + '</table>'

def react_span(react):
    react = str(react).strip()
    if react == 'BOUNCE':    return '<span style="color:#37d67a">BOUNCE</span>'
    if react == 'BREAK':     return '<span style="color:#ff6b6b">BREAK</span>'
    if react == 'UNTOUCHED': return '<span style="color:#6f8294">UNTOUCHED</span>'
    return f'<span style="color:#9fb0c0">{react}</span>'

# ══════════════════════════════════════════════════════════════════════════════
# REPORT 1 — عوامل النجاح قبل الدخول
# ══════════════════════════════════════════════════════════════════════════════

def report1(df, label):
    N = len(df)
    ts = datetime.now().strftime('%Y-%m-%d %H:%M')

    # Overall cross-test base rate
    all_touch = all_succ = 0
    for t in TEST4:
        touched_mask = df[f'{t}_React'].isin(['BOUNCE','BREAK'])
        all_touch += touched_mask.sum()
        all_succ  += (touched_mask & (df[f'{t}_React'] == 'BOUNCE') & (df[f'{t}_TP1_Hit'] == 1)).sum()
    base_rate = all_succ / all_touch if all_touch else 0

    body = f'<h1>عوامل النجاح قبل الدخول</h1>\n'
    body += f'<div class="sub">{label} · {N} زاوية · معدل النجاح الكلي: {pct(all_succ,all_touch)}% · {ts}</div>\n'
    body += f'''<div class="stat-row">
      <div class="stat-card"><div class="t">الزوايا</div>
        <div class="v" style="color:#4db1ff">{N}</div></div>
      <div class="stat-card"><div class="t">الإشارات (4×)</div>
        <div class="v" style="color:#9fb0c0">{N*4}</div></div>
      <div class="stat-card"><div class="t">اللمسات الكلية</div>
        <div class="v" style="color:#ffd34d">{all_touch}</div>
        <div class="s">{pct(all_touch,N*4)}%</div></div>
      <div class="stat-card"><div class="t">النجاحات الكلية</div>
        <div class="v" style="color:#37d67a">{all_succ}</div></div>
      <div class="stat-card"><div class="t">Base Rate</div>
        <div class="v" style="color:#37d67a">{pct(all_succ,all_touch)}%</div></div>
    </div>\n<div class="sep"></div>\n'''

    for (col, dir_filt, test_label) in TESTS_6:
        mask = df[f'{col}_React'].isin(['BOUNCE','BREAK'])
        if dir_filt:
            mask = mask & (df['Dir'] == dir_filt)
        pool = df[mask].copy()
        succ = ((pool[f'{col}_React'] == 'BOUNCE') & (pool[f'{col}_TP1_Hit'] == 1))
        n_t, n_s = len(pool), int(succ.sum())
        tr = n_s / n_t if n_t else 0
        rc = rate_color(tr)

        body += f'<div class="section">\n'
        body += f'<div class="sect-hdr">📍 {test_label}</div>\n'
        body += f'''<div class="stat-mini">
          <div class="sm-card"><b style="color:#ffd34d">{n_t}</b>لمسة</div>
          <div class="sm-card"><b style="color:#37d67a">{n_s}</b>نجاح</div>
          <div class="sm-card"><b style="color:{rc}">{pct(n_s,n_t)}%</b>نسبة النجاح</div>
          <div class="sm-card"><b style="color:#9fb0c0">{pct(tr*100,base_rate*100) if base_rate else "—"}</b>
            <span style="font-size:11px">Lift vs Base</span></div>
        </div>\n'''

        if n_t < 3:
            body += '<p style="color:#6f8294;padding:8px">— بيانات غير كافية —</p></div>\n'
            continue

        sess_vals = pool[f'{col}_Session'].apply(
            lambda s: SESSION_AR.get(str(s).strip(), str(s).strip()))

        body += '<div class="three-col">\n'
        body += ('<div><h3>حسب التصنيف</h3>'
                 + factor_tbl(factor_stats(pool['Class'], succ, tr), 'التصنيف')
                 + '</div>')
        body += ('<div><h3>حسب النطاق (تصحيح)</h3>'
                 + factor_tbl(factor_stats(pool['_corr_bkt'], succ, tr), 'النطاق')
                 + '</div>')
        body += ('<div><h3>حسب نسبة U1/U2</h3>'
                 + factor_tbl(factor_stats(pool['_ratio_bkt'], succ, tr), 'نسبة U1/U2')
                 + '</div>')
        body += '</div>\n'

        body += '<div class="three-col">\n'
        body += ('<div><h3>حسب حجم L (القطر)</h3>'
                 + factor_tbl(factor_stats(pool['_l_bkt'], succ, tr), 'حجم L')
                 + '</div>')
        body += ('<div><h3>حسب الجلسة</h3>'
                 + factor_tbl(factor_stats(sess_vals, succ, tr), 'الجلسة')
                 + '</div>')
        body += ('<div><h3>حسب تصنيف الزاوية السابقة</h3>'
                 + factor_tbl(factor_stats(pool['_prev_cls'], succ, tr, min_n=2), 'التصنيف السابق')
                 + '</div>')
        body += '</div>\n'

        # Top 3 strongest combos for this test
        tmp = pool.copy()
        tmp['_s'] = succ.values
        grp = tmp.groupby(['Class', '_corr_bkt', '_ratio_bkt'])['_s'].agg(['sum','count'])
        grp.columns = ['S','N']
        grp = grp[grp['N'] >= 3].copy()
        if not grp.empty:
            grp['rate'] = grp['S'] / grp['N']
            top3 = grp.sort_values('rate', ascending=False).head(3)
            body += '<div class="top3-box">\n'
            body += '<div class="top3-hdr">⭐ أقوى 3 توليفات لهذا الاختبار</div>\n'
            for rank, ((cls, cb, rb), row) in enumerate(top3.iterrows(), 1):
                r = row['rate']
                bg = '#0d2e1a' if r >= .5 else ('#0d1f2e' if r >= .35 else '#1a1a0d')
                body += (f'<div class="top3-row" style="background:{bg}">'
                         f'<b>#{rank}</b> '
                         f'<span class="badge" style="color:#ffd34d">{cls}</span>'
                         f'<span class="badge" style="color:#4db1ff">{cb}</span>'
                         f'<span class="badge" style="color:#9fb0c0">{rb}</span>'
                         f' → <b style="color:{rate_color(r)}">{pct(int(row["S"]),int(row["N"]))}</b>%'
                         f' <span style="color:#6f8294;font-size:11px">'
                         f'({int(row["N"])} لمسة, {int(row["S"])} نجاح)</span>'
                         f'</div>\n')
            body += '</div>\n'

        body += '</div>\n'  # section

    return html_wrap(f"عوامل النجاح — {label}", body, ts)

# ══════════════════════════════════════════════════════════════════════════════
# REPORT 2 — التقرير الشامل
# ══════════════════════════════════════════════════════════════════════════════

def report2(df, label):
    N = len(df)
    ts = datetime.now().strftime('%Y-%m-%d %H:%M')

    # ── Expand to signal rows ──────────────────────────────────────────────────
    rows_list = []
    for _, row in df.iterrows():
        for t in TEST4:
            react   = str(row.get(f'{t}_React', '')).strip()
            tp1     = int(row.get(f'{t}_TP1_Hit', 0)) == 1
            sess    = str(row.get(f'{t}_Session', '')).strip()
            touched = react in ('BOUNCE','BREAK')
            success = react == 'BOUNCE' and tp1
            rows_list.append({
                'cls': row['Class'], 'dir': row['Dir'],
                'cb': row['_corr_bkt'], 'rb': row['_ratio_bkt'],
                'test': t, 'react': react, 'tp1': tp1, 'sess': sess,
                'touched': touched, 'success': success,
                'aid': row['AngleID'],
            })

    touched_s = [s for s in rows_list if s['touched']]
    succ_s    = [s for s in rows_list if s['success']]
    tot_t, tot_s = len(touched_s), len(succ_s)
    base = tot_s / tot_t if tot_t else 0

    body = f'<h1>التقرير الشامل</h1>\n'
    body += f'<div class="sub">{label} · {N} زاوية · {ts}</div>\n'
    body += f'''<div class="stat-row">
      <div class="stat-card"><div class="t">الزوايا</div>
        <div class="v" style="color:#4db1ff">{N}</div></div>
      <div class="stat-card"><div class="t">الإشارات</div>
        <div class="v" style="color:#9fb0c0">{len(rows_list)}</div>
        <div class="s">4 × {N}</div></div>
      <div class="stat-card"><div class="t">اللمسات</div>
        <div class="v" style="color:#ffd34d">{tot_t}</div>
        <div class="s">{pct(tot_t,len(rows_list))}%</div></div>
      <div class="stat-card"><div class="t">النجاحات</div>
        <div class="v" style="color:#37d67a">{tot_s}</div></div>
      <div class="stat-card"><div class="t">Base Rate</div>
        <div class="v" style="color:#37d67a">{pct(tot_s,tot_t)}%</div></div>
    </div>\n<div class="sep"></div>\n'''

    # ── Tier ranking: Class × Test × CorrBkt ──────────────────────────────────
    body += '<h2>تصنيف قوة الدخول — التصنيف × الاختبار × النطاق</h2>\n'
    body += '<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">مرتّبة تنازلياً · الحد الأدنى 2 إشارة</p>\n'

    tier_d = defaultdict(lambda: {'N':0,'S':0})
    for s in touched_s:
        tier_d[(s['cls'],s['test'],s['cb'])]['N'] += 1
        tier_d[(s['cls'],s['test'],s['cb'])]['S'] += int(s['success'])

    tiers = sorted(
        [{'cls':k[0],'test':k[1],'cb':k[2],'N':g['N'],'S':g['S'],
          'rate':g['S']/g['N'],'lift':lft(g['S']/g['N'],base)}
         for k,g in tier_d.items() if g['N'] >= 2],
        key=lambda x: -x['rate'])

    body += ('<table><tr><th>#</th><th>التصنيف</th><th>الاختبار</th>'
             '<th>النطاق</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>')
    for i, t in enumerate(tiers[:30], 1):
        rc = rate_color(t['rate'])
        body += (f'<tr {row_bg(t["rate"])}>'
                 f'<td style="color:#9fb0c0">#{i}</td>'
                 f'<td style="color:#ffd34d;font-weight:bold">{t["cls"]}</td>'
                 f'<td>{t["test"]}</td><td>{t["cb"]}</td>'
                 f'<td>{t["N"]}</td><td>{t["S"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(t["S"],t["N"])}%</td>'
                 f'<td>{lift_badge(t["lift"])}</td></tr>')
    body += '</table>\n<div class="sep"></div>\n'

    # ── Transition matrix ──────────────────────────────────────────────────────
    body += '<h2>مصفوفة انتقال الزوايا — P(التالي | الحالي)</h2>\n'
    body += '<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">% الانتقال · (عدد)</p>\n'

    sdf      = df.sort_values('FormTime')
    cls_list = sdf['Class'].tolist()
    all_cls  = sorted(set(cls_list))
    trans    = defaultdict(lambda: defaultdict(int))
    for i in range(len(cls_list)-1):
        if cls_list[i] and cls_list[i+1]:
            trans[cls_list[i]][cls_list[i+1]] += 1

    body += '<div style="overflow-x:auto"><table><tr><th>من↓ / إلى→</th>'
    for c in all_cls: body += f'<th>{c}</th>'
    body += '<th>الكل</th></tr>'
    for src in all_cls:
        total = sum(trans[src].values()) if src in trans else 0
        body += f'<tr><td style="color:#ffd34d;font-weight:bold">{src}</td>'
        for dst in all_cls:
            cnt = trans[src].get(dst, 0) if src in trans else 0
            if cnt == 0:
                body += '<td style="color:#25384a">—</td>'
            else:
                prob = cnt/total
                body += (f'<td style="color:{rate_color(prob)}">'
                         f'{pct(cnt,total)}%<br>'
                         f'<span style="color:#6f8294;font-size:10px">({cnt})</span></td>')
        body += f'<td style="color:#9fb0c0">{total}</td></tr>'
    body += '</table></div>\n<div class="sep"></div>\n'

    # ── Sequence rules 2-angle ─────────────────────────────────────────────────
    body += '<h2>قوانين التسلسل — زاويتان متتاليتان</h2>\n'

    aid_list = sdf['AngleID'].tolist()
    any_succ = {}
    for _, row in sdf.iterrows():
        aid = row['AngleID']
        any_succ[aid] = any(
            str(row.get(f'{t}_React','')).strip() == 'BOUNCE'
            and int(row.get(f'{t}_TP1_Hit',0)) == 1
            for t in TEST4)

    seq2 = defaultdict(lambda: {'N':0,'S':0})
    for i in range(1, len(aid_list)):
        k = (cls_list[i-1], cls_list[i])
        seq2[k]['N'] += 1
        seq2[k]['S'] += int(any_succ.get(aid_list[i], False))

    seq2_list = sorted(
        [{'seq':f'{k[0]}→{k[1]}','N':g['N'],'S':g['S'],
          'rate':g['S']/g['N'],'lift':lft(g['S']/g['N'],base)}
         for k,g in seq2.items() if g['N'] >= 2],
        key=lambda x: -x['rate'])

    body += ('<table><tr><th>التسلسل</th><th>عدد</th>'
             '<th>نجاح</th><th>نسبة</th><th>Lift</th></tr>')
    for s in seq2_list[:20]:
        rc = rate_color(s['rate'])
        body += (f'<tr {row_bg(s["rate"])}>'
                 f'<td style="color:#4db1ff;font-weight:bold">{s["seq"]}</td>'
                 f'<td>{s["N"]}</td><td>{s["S"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(s["S"],s["N"])}%</td>'
                 f'<td>{lift_badge(s["lift"])}</td></tr>')
    body += '</table>\n'

    # ── Sequence rules 3-angle ─────────────────────────────────────────────────
    body += '<h2>قوانين التسلسل — ثلاث زوايا متتالية</h2>\n'

    seq3 = defaultdict(lambda: {'N':0,'S':0})
    for i in range(2, len(aid_list)):
        k = (cls_list[i-2], cls_list[i-1], cls_list[i])
        seq3[k]['N'] += 1
        seq3[k]['S'] += int(any_succ.get(aid_list[i], False))

    seq3_list = sorted(
        [{'seq':f'{k[0]}→{k[1]}→{k[2]}','N':g['N'],'S':g['S'],
          'rate':g['S']/g['N'],'lift':lft(g['S']/g['N'],base)}
         for k,g in seq3.items() if g['N'] >= 2],
        key=lambda x: -x['rate'])

    body += ('<table><tr><th>التسلسل الثلاثي</th><th>عدد</th>'
             '<th>نجاح</th><th>نسبة</th><th>Lift</th></tr>')
    for s in seq3_list[:15]:
        rc = rate_color(s['rate'])
        body += (f'<tr {row_bg(s["rate"])}>'
                 f'<td style="color:#4db1ff;font-weight:bold">{s["seq"]}</td>'
                 f'<td>{s["N"]}</td><td>{s["S"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(s["S"],s["N"])}%</td>'
                 f'<td>{lift_badge(s["lift"])}</td></tr>')
    body += '</table>\n<div class="sep"></div>\n'

    # ── Angle cards ────────────────────────────────────────────────────────────
    body += f'<h2>بطاقات الزوايا التفصيلية — {N} زاوية</h2>\n'

    for _, row in sdf.iterrows():
        cls     = row['Class']
        cc      = "#37d67a" if cls in GOOD_CLS else "#ff6b6b"
        left_s  = ' · '.join(ctx_classes(row, 'Left'))  or '—'
        right_s = ' · '.join(ctx_classes(row, 'Right')) or '—'

        trows = ''
        for t in TEST4:
            react = str(row.get(f'{t}_React','—')).strip() or '—'
            tp1   = int(row.get(f'{t}_TP1_Hit',0)) == 1
            sess  = SESSION_AR.get(str(row.get(f'{t}_Session','')).strip(),'—')
            succ  = react == 'BOUNCE' and tp1
            tp1_s = '<span style="color:#37d67a">✔</span>' if tp1 else '<span style="color:#6f8294">✖</span>'
            ss    = '<span style="color:#37d67a;font-weight:bold">نجاح ✓</span>' if succ else ''
            tr_bg = 'style="background:#0d2e1a"' if succ else ''
            trows += (f'<tr {tr_bg}>'
                      f'<td>{t}</td><td>{react_span(react)}</td>'
                      f'<td>{tp1_s}</td><td>{sess}</td><td>{ss}</td></tr>')

        body += f'''<div class="angle-card">
  <div class="angle-header">
    <span class="angle-id">#{row["AngleID"]}</span>
    <span class="angle-cls" style="color:{cc}">{cls}</span>
    <span class="angle-dir">{row["Dir"]}</span>
    <span style="color:#6f8294;font-size:11px">{row.get("FormTime","")}</span>
  </div>
  <div class="angle-meta">
    <span class="badge">تصحيح: <b>{row.get("Corr_pct","")}%</b> ({row["_corr_bkt"]})</span>
    <span class="badge">نسبة U1/U2: {row.get("Ratio_U1_U2_pct","")}% ({row["_ratio_bkt"]})</span>
    <span class="badge">L: {row.get("L_points","")} | B: {row.get("B_points","")}</span>
  </div>
  <div style="color:#9fb0c0;font-size:11px;margin:4px 0">
    السابق: <b>{left_s}</b> | التالي: <b>{right_s}</b>
  </div>
  <table class="test-table">
    <tr><th>نقطة الاختبار</th><th>الردّ</th><th>TP1</th><th>الجلسة</th><th>النتيجة</th></tr>
    {trows}
  </table>
</div>\n'''

    return html_wrap(f"التقرير الشامل — {label}", body, ts)

# ══════════════════════════════════════════════════════════════════════════════
# REPORT 3 — التوليفات والمقارنة
# ══════════════════════════════════════════════════════════════════════════════

def report3(df, label):
    N = len(df)
    ts = datetime.now().strftime('%Y-%m-%d %H:%M')

    # Build touched signals
    sigs = []
    for _, row in df.iterrows():
        for t in TEST4:
            react   = str(row.get(f'{t}_React','')).strip()
            tp1     = int(row.get(f'{t}_TP1_Hit',0)) == 1
            sess    = str(row.get(f'{t}_Session','')).strip()
            touched = react in ('BOUNCE','BREAK')
            success = react == 'BOUNCE' and tp1
            if not touched: continue
            sigs.append({
                'cls': row['Class'], 'cb': row['_corr_bkt'],
                'rb': row['_ratio_bkt'], 'test': t,
                'react': react, 'tp1': tp1, 'sess': sess,
                'b_pts': float(row.get('B_points', 0)),
                'success': success, 'aid': row['AngleID'],
                'form_time': str(row.get('FormTime','')),
            })

    tot_t = len(sigs)
    tot_s = sum(1 for s in sigs if s['success'])
    base  = tot_s / tot_t if tot_t else 0

    body = f'<h1>تقرير التوليفات والمقارنة</h1>\n'
    body += f'<div class="sub">{label} · {N} زاوية · {ts}</div>\n'
    body += f'''<div class="stat-row">
      <div class="stat-card"><div class="t">الزوايا</div>
        <div class="v" style="color:#4db1ff">{N}</div></div>
      <div class="stat-card"><div class="t">الإشارات الملموسة</div>
        <div class="v" style="color:#ffd34d">{tot_t}</div></div>
      <div class="stat-card"><div class="t">النجاحات</div>
        <div class="v" style="color:#37d67a">{tot_s}</div></div>
      <div class="stat-card"><div class="t">Base Rate</div>
        <div class="v" style="color:#37d67a">{pct(tot_s,tot_t)}%</div></div>
    </div>\n<div class="sep"></div>\n'''

    # ── 3-element combos: Class × CorrBkt × RatioBkt ──────────────────────────
    body += '<h2>التوليفات الثلاثية — التصنيف × النطاق × نسبة U1/U2</h2>\n'
    body += '<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">الحد الأدنى 3 إشارات · مرتّبة حسب نسبة النجاح</p>\n'

    c3 = defaultdict(lambda: {'N':0,'S':0,'tests':defaultdict(lambda:{'N':0,'S':0}),'bp':[]})
    for s in sigs:
        k = (s['cls'], s['cb'], s['rb'])
        c3[k]['N'] += 1
        c3[k]['S'] += int(s['success'])
        c3[k]['tests'][s['test']]['N'] += 1
        c3[k]['tests'][s['test']]['S'] += int(s['success'])
        c3[k]['bp'].append(s['b_pts'])

    combos = []
    for k, g in c3.items():
        if g['N'] < 3: continue
        r = g['S'] / g['N']
        # best test by rate
        best_t = max(g['tests'].items(),
                     key=lambda x: x[1]['S']/x[1]['N'] if x[1]['N'] else -1)
        b_avg = round(sum(g['bp'])/len(g['bp']), 1) if g['bp'] else 0
        # per-test breakdown string
        td = ' | '.join(
            f'{t}: {int(d["S"])}/{int(d["N"])}={pct(d["S"],d["N"])}%'
            for t, d in sorted(g['tests'].items()))
        combos.append({
            'cls':k[0],'cb':k[1],'rb':k[2],
            'N':g['N'],'S':g['S'],'rate':r,'lift':lft(r,base),
            'best_t':best_t[0],
            'best_r':best_t[1]['S']/best_t[1]['N'] if best_t[1]['N'] else 0,
            'b_avg':b_avg, 'td':td,
        })
    combos.sort(key=lambda x: -x['rate'])

    body += ('<table><tr><th>التصنيف</th><th>النطاق</th><th>نسبة U1/U2</th>'
             '<th>إشارات</th><th>نجاح</th><th>نسبة النجاح</th><th>Lift</th>'
             '<th>أفضل اختبار</th><th>نسبته</th><th>B (نقطة)</th></tr>')
    for c in combos:
        rc  = rate_color(c['rate'])
        brc = rate_color(c['best_r'])
        body += (f'<tr {row_bg(c["rate"])}>'
                 f'<td style="color:#ffd34d;font-weight:bold">{c["cls"]}</td>'
                 f'<td>{c["cb"]}</td><td>{c["rb"]}</td>'
                 f'<td>{c["N"]}</td><td>{c["S"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(c["S"],c["N"])}%</td>'
                 f'<td>{lift_badge(c["lift"])}</td>'
                 f'<td style="color:#4db1ff">{c["best_t"]}</td>'
                 f'<td style="color:{brc}">{pct(int(round(c["best_r"]*c["N"])),int(round(c["N"])) or 1) if c["N"] else 0}%</td>'
                 f'<td>{c["b_avg"]}</td></tr>')
        # Breakdown row
        body += (f'<tr><td colspan="10" style="color:#6f8294;font-size:11px;'
                 f'padding:3px 9px">{c["td"]}</td></tr>')
    body += '</table>\n<div class="sep"></div>\n'

    # ── Per-angle appearance with test results ─────────────────────────────────
    body += f'<h2>ظهور كل زاوية — النتائج التفصيلية ({N} زاوية)</h2>\n'

    sdf = df.sort_values('FormTime')
    for _, row in sdf.iterrows():
        cls = row['Class']
        cc  = "#37d67a" if cls in GOOD_CLS else "#ff6b6b"
        # Count successes for this angle
        ang_succ = sum(
            1 for t in TEST4
            if str(row.get(f'{t}_React','')).strip() == 'BOUNCE'
            and int(row.get(f'{t}_TP1_Hit',0)) == 1)
        ang_touch = sum(
            1 for t in TEST4
            if str(row.get(f'{t}_React','')).strip() in ('BOUNCE','BREAK'))

        trows = ''
        for t in TEST4:
            react = str(row.get(f'{t}_React','—')).strip() or '—'
            tp1   = int(row.get(f'{t}_TP1_Hit',0)) == 1
            sess  = SESSION_AR.get(str(row.get(f'{t}_Session','')).strip(),'—')
            dur   = str(row.get(f'{t}_Dur','')).strip() or '—'
            succ  = react == 'BOUNCE' and tp1
            b_pts = float(row.get('B_points', 0))
            tp1_s = '<span style="color:#37d67a">✔</span>' if tp1 else '<span style="color:#6f8294">✖</span>'
            ss    = '<span style="color:#37d67a;font-weight:bold">نجاح</span>' if succ else ''
            tr_bg = 'style="background:#0d2e1a"' if succ else ''
            trows += (f'<tr {tr_bg}>'
                      f'<td>{t}</td><td>{react_span(react)}</td>'
                      f'<td>{tp1_s}</td><td>{sess}</td>'
                      f'<td>{b_pts:.1f}</td><td>{dur}</td><td>{ss}</td></tr>')

        body += f'''<div class="angle-card">
  <div class="angle-header">
    <span class="angle-id">#{row["AngleID"]}</span>
    <span class="angle-cls" style="color:{cc}">{cls}</span>
    <span class="angle-dir">{row["Dir"]}</span>
    <span style="color:#6f8294;font-size:11px">{row.get("FormTime","")}</span>
    <span class="badge" style="color:#37d67a">{ang_succ} نجاح / {ang_touch} لمسة</span>
  </div>
  <div class="angle-meta">
    <span class="badge">تصحيح: {row.get("Corr_pct","")}% ({row["_corr_bkt"]})</span>
    <span class="badge">U1/U2: {row.get("Ratio_U1_U2_pct","")}% ({row["_ratio_bkt"]})</span>
    <span class="badge">L: {row.get("L_points","")} | B: {row.get("B_points","")}</span>
  </div>
  <table class="test-table">
    <tr><th>الاختبار</th><th>الردّ</th><th>TP1</th><th>الجلسة</th>
        <th>B (نقطة)</th><th>المدة</th><th>النتيجة</th></tr>
    {trows}
  </table>
</div>\n'''

    return html_wrap(f"التوليفات — {label}", body, ts)

# ══════════════════════════════════════════════════════════════════════════════
# Report 4 — جدول تصنيف الزوايا
# ══════════════════════════════════════════════════════════════════════════════

def report4(df, label):
    N = len(df)
    ts = datetime.now().strftime('%Y-%m-%d %H:%M')
    sdf = df.sort_values('FormTime').reset_index(drop=True)

    def _any_succ(row):
        return any(
            str(row.get(f'{t}_React', '')).strip() == 'BOUNCE'
            and int(row.get(f'{t}_TP1_Hit', 0)) == 1
            for t in TEST4)
    sdf['_any_succ'] = sdf.apply(_any_succ, axis=1)

    body = f'<h1>جدول تصنيف الزوايا — ملف التعريف الشامل</h1>\n'
    body += f'<div class="sub">{label} · {N} زاوية · {ts}</div>\n'

    all_cls = sorted(sdf['Class'].unique())
    body += '<div style="text-align:center;margin:10px 0">'
    for c in all_cls:
        cc = "#37d67a" if c in GOOD_CLS else "#ff6b6b"
        body += f'<a href="#{c}" style="color:{cc};margin:0 8px;font-weight:bold;text-decoration:none">{c}</a>'
    body += '</div>\n<div class="sep"></div>\n'

    for cls in all_cls:
        is_good = cls in GOOD_CLS
        cls_color = "#37d67a" if is_good else "#ff6b6b"
        cls_mask = sdf['Class'] == cls
        cls_df = sdf[cls_mask].copy()
        cls_idxs = sdf.index[cls_mask].tolist()
        count = len(cls_df)
        buy_n = int((cls_df['Dir'] == 'BUY').sum())
        sell_n = int((cls_df['Dir'] == 'SELL').sum())
        cb_cnt = cls_df['_corr_bkt'].value_counts().to_dict()

        t_stats = {}
        for t in TEST4:
            touched = cls_df[f'{t}_React'].isin(['BOUNCE', 'BREAK'])
            succ = (cls_df[f'{t}_React'] == 'BOUNCE') & (cls_df[f'{t}_TP1_Hit'] == 1)
            t_stats[t] = {
                'touch': int(touched.sum()),
                'succ': int(succ.sum()),
                'fail': int((touched & ~succ).sum()),
                'no': int((~touched).sum()),
                'ratio': cls_df[succ]['_ratio_bkt'].value_counts().to_dict()
            }

        family_lbl = (
            "<span style='color:#37d67a;font-size:12px'>(عائلة الأولى — قوية)</span>"
            if is_good else
            "<span style='color:#ff6b6b;font-size:12px'>(عائلة الثانية — ضعيفة)</span>"
        )
        body += f'<div id="{cls}" class="cls-section">\n'
        body += (f'<div class="cls-hdr">'
                 f'<span style="color:{cls_color};font-size:22px;font-weight:bold">{cls}</span>'
                 f'<span style="color:#9fb0c0;font-size:15px"> — {count} ظهور</span>'
                 f'<span class="badge" style="color:#4db1ff">BUY: {buy_n}</span>'
                 f'<span class="badge" style="color:#ff9f6b">SELL: {sell_n}</span>'
                 f'{family_lbl}</div>\n')

        body += '<div class="cb-row">'
        for cb, n in sorted(cb_cnt.items(), key=lambda x: -x[1]):
            body += f'<span class="badge" style="color:#4db1ff">{cb}: {n}</span>'
        body += '</div>\n'

        body += '<h3>إجمالي نتائج الاختبارات لهذا التصنيف</h3>'
        body += ('<table><tr>'
                 '<th>الاختبار</th><th>لمسات</th><th>✓ نجاح</th>'
                 '<th>✗ فشل</th><th>— لم يُلمس</th>'
                 '<th>نسبة U1/U2 عند النجاح</th></tr>')
        for t in TEST4:
            st = t_stats[t]
            ratio_str = '  ·  '.join(f'{k}: {v} مرة' for k, v in st['ratio'].items()) or '—'
            succ_col = "#37d67a" if st['succ'] > 0 else "#6f8294"
            body += (f'<tr><td style="font-weight:bold">{t}</td>'
                     f'<td>{st["touch"]}</td>'
                     f'<td style="color:{succ_col};font-weight:bold">{st["succ"]}</td>'
                     f'<td style="color:#ff6b6b">{st["fail"]}</td>'
                     f'<td style="color:#6f8294">{st["no"]}</td>'
                     f'<td style="font-size:12px;color:#9fb0c0">{ratio_str}</td></tr>')
        body += '</table>\n'

        body += f'<h3>الظهورات الفردية ({count})</h3>'
        body += ('<div style="overflow-x:auto"><table class="occ-table"><tr>'
                 '<th>#</th><th>الوقت</th><th>الاتجاه</th><th>النطاق</th>'
                 '<th>نسبة U1/U2</th><th>الاختبارات الناجحة فقط</th>'
                 '<th>آخر 5 زوايا (الأقدم→الأحدث)</th></tr>')

        for occ_i, idx in enumerate(cls_idxs, 1):
            row = sdf.loc[idx]
            dir_s = row['Dir']
            cb_s = row['_corr_bkt']
            rb_s = row['_ratio_bkt']
            dir_col = "#4db1ff" if dir_s == "BUY" else "#ff9f6b"

            succ_tests = []
            for t in TEST4:
                react = str(row.get(f'{t}_React', '')).strip()
                tp1 = int(row.get(f'{t}_TP1_Hit', 0)) == 1
                if react == 'BOUNCE' and tp1:
                    succ_tests.append(f'<span style="color:#37d67a;font-weight:bold">{t} ✓</span>')
            succ_cell = '&nbsp;&nbsp;'.join(succ_tests) if succ_tests else '<span style="color:#6f8294">—</span>'

            prev_parts = []
            for pos in range(5, 0, -1):
                prev_idx = idx - pos
                if prev_idx >= 0:
                    pr = sdf.loc[prev_idx]
                    pc = pr['Class']
                    pa = pr['_any_succ']
                    pr_rb = pr['_ratio_bkt']
                    if pa:
                        prev_parts.append(
                            f'<span style="color:#37d67a;font-weight:bold">{pc}</span>'
                            f'<span style="color:#6f8294;font-size:10px">(✓{pr_rb})</span>')
                    else:
                        prev_parts.append(f'<span style="color:#9fb0c0">{pc}</span>')
                else:
                    prev_parts.append('<span style="color:#3a4e60">—</span>')
            prev_cell = ' → '.join(prev_parts)

            any_s = row['_any_succ']
            tr_bg = 'style="background:#0d2e1a"' if any_s else ''

            body += (f'<tr {tr_bg}>'
                     f'<td style="color:#6f8294">{occ_i}</td>'
                     f'<td style="font-size:11px;color:#9fb0c0">{str(row.get("FormTime", "")).strip()}</td>'
                     f'<td style="color:{dir_col};font-weight:bold">{dir_s}</td>'
                     f'<td style="font-size:12px">{cb_s}</td>'
                     f'<td>{rb_s}</td>'
                     f'<td>{succ_cell}</td>'
                     f'<td style="font-size:12px">{prev_cell}</td></tr>')

        body += '</table></div>\n</div>\n<div class="sep"></div>\n'

    return html_wrap(f"جدول التصنيف — {label}", body, ts)


# ══════════════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════════════

def generate(df, group_label, out_dir):
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    r1 = report1(df, group_label)
    r2 = report2(df, group_label)
    r3 = report3(df, group_label)
    r4 = report4(df, group_label)

    p1 = out_dir / f"1_عوامل_النجاح_{group_label}.html"
    p2 = out_dir / f"2_التقرير_الشامل_{group_label}.html"
    p3 = out_dir / f"3_التوليفات_{group_label}.html"
    p4 = out_dir / f"4_جدول_التصنيف_{group_label}.html"

    p1.write_text(r1, encoding='utf-8')
    p2.write_text(r2, encoding='utf-8')
    p3.write_text(r3, encoding='utf-8')
    p4.write_text(r4, encoding='utf-8')

    sz = lambda p: f"{p.stat().st_size//1024}KB"
    print(f"    1_عوامل_النجاح      → {sz(p1)}")
    print(f"    2_التقرير_الشامل     → {sz(p2)}")
    print(f"    3_التوليفات          → {sz(p3)}")
    print(f"    4_جدول_التصنيف       → {sz(p4)}")

def main():
    print("=" * 60)
    print("  AIB Angles Expert — Data Analyzer v4")
    print("=" * 60)

    DATA.mkdir(exist_ok=True)
    OUT.mkdir(parents=True, exist_ok=True)

    print("\n[1/3] Loading CSV files...")
    df = load_data()

    print("\n[2/3] Preprocessing...")
    df = preprocess(df)
    print(f"  Corr buckets: {df['_corr_bkt'].value_counts().to_dict()}")
    print(f"  Ratio buckets: {df['_ratio_bkt'].value_counts().to_dict()}")

    print("\n[3/3] Generating reports...")

    # All pairs combined
    all_out = OUT / "كل_الازواج"
    print(f"\n  ► كل الأزواج ({len(df)} زاوية)")
    generate(df, "كل_الازواج", all_out)

    # Per symbol
    for sym, grp in df.groupby('_symbol'):
        sym_out = OUT / sym
        print(f"\n  ► {sym} ({len(grp)} زاوية)")
        generate(grp.reset_index(drop=True), sym, sym_out)

    print(f"\n{'='*60}")
    print(f"  ✓ Done!  Reports → {OUT}")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
