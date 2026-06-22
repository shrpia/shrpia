#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
المحلل — محلل بيانات اكسبيرت الزوايا (متعدد الملفات)
ضع ملفات CSV في مجلد "التقارير" ثم شغّل هذا الملف
يجمع كل الملفات ويحللهم كوحدة واحدة ويخرج تقرير واحد شامل
"""

import csv, os, re
from datetime import datetime
from collections import defaultdict
from pathlib import Path

# ─── المسارات ────────────────────────────────────────────────────────────────
BASE_DIR   = Path(__file__).parent
INPUT_DIR  = BASE_DIR / "التقارير"
OUTPUT_DIR = BASE_DIR / "مخرجات التحليل"
OUTPUT_DIR.mkdir(exist_ok=True)

TESTS = ["U1X1", "U2X1", "DLX1", "DRX1"]
GOOD_CLASSES = {"ZB", "ZC", "ZD", "ZE"}
WEAK_CLASSES = {"ZF", "ZG", "ZH", "ZO"}
SESSION_AR   = {"London": "لندن", "NewYork": "نيويورك",
                "Asia": "آسيا", "Other": "أخرى", "NA": "—"}

# ─── مساعدات ──────────────────────────────────────────────────────────────────
def corr_bucket(v):
    try:
        v = float(v)
        if v >= 62: return "ALPHA عميق"
        if v >= 38: return "ALPHA منخفض"
        return "BETA"
    except: return "غير محدد"

def ratio_bucket(v):
    try:
        v = float(v)
        if v < 80:  return "صغيرة"
        if v < 120: return "متوسطة"
        return "كبيرة"
    except: return "غير محدد"

def lb_bucket(l, b):
    try:
        r = float(l) / float(b)
        if r < 1.5: return "صغيرة"
        if r < 3:   return "متوسطة"
        return "كبيرة"
    except: return "غير محدد"

def pct(n, d):  return round(100 * n / d, 1) if d else 0.0
def lft(r, b):  return round(r / b, 2) if b else 0.0

def parse_ctx(s):
    if not s or s.strip() in ("", "NA"): return None
    m = re.match(r"[BS]-([A-Z]+)-", s.strip())
    return m.group(1) if m else None

def rate_color(r):
    if r >= .50: return "#37d67a"
    if r >= .35: return "#4db1ff"
    if r >= .25: return "#ffd34d"
    return "#ff6b6b"

def lift_badge(v):
    if v >= 2.0: return f'<span style="color:#37d67a;font-weight:bold">×{v}</span>'
    if v >= 1.3: return f'<span style="color:#4db1ff">×{v}</span>'
    if v >= 1.0: return f'<span style="color:#ffd34d">×{v}</span>'
    return f'<span style="color:#ff6b6b">×{v}</span>'

def row_style(r):
    if r >= .50: return 'style="background:#0d2e1a"'
    if r >= .35: return 'style="background:#0d1f2e"'
    if r  < .15: return 'style="background:#2e0d0d"'
    return ""

# ─── قراءة كل الملفات ────────────────────────────────────────────────────────
csv_files = sorted(INPUT_DIR.glob("*.csv"))
if not csv_files:
    print("❌ لا توجد ملفات CSV في مجلد التقارير")
    exit(1)

print(f"📂 وجدت {len(csv_files)} ملف:")
file_meta = []   # بيانات كل ملف للعرض في التقرير
all_rows  = []   # كل الصفوف مجموعة

for fp in csv_files:
    with open(fp, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        file_rows = list(reader)

    if not file_rows:
        print(f"  ⚠️  {fp.name} — فارغ، تم تجاهله")
        continue

    # استخرج معلومات الملف من أول صف
    r0     = file_rows[0]
    symbol = r0.get("Symbol", "—").strip()
    tf     = r0.get("TF", "—").strip()
    dates  = sorted(r.get("FormTime","") for r in file_rows if r.get("FormTime","").strip())
    d_from = dates[0][:10]  if dates else "—"
    d_to   = dates[-1][:10] if dates else "—"

    # أضف عمود مصدر لكل صف
    for r in file_rows:
        r["_source_file"] = fp.name
        r["_symbol"]      = symbol
        r["_tf"]          = tf

    all_rows.extend(file_rows)
    meta = {"file": fp.name, "symbol": symbol, "tf": tf,
            "from": d_from, "to": d_to, "count": len(file_rows)}
    file_meta.append(meta)
    print(f"  ✓ {fp.name}  ({symbol} · TF={tf} · {len(file_rows)} زاوية · {d_from} → {d_to})")

N = len(all_rows)
print(f"\n📊 إجمالي الزوايا المدمجة: {N}")

# ─── تمديد الإشارات (كل زاوية × 4 نقاط اختبار) ──────────────────────────────
signals = []
for r in all_rows:
    cls       = r.get("Class", "").strip()
    confirmed = str(r.get("Confirmed", "0")).strip() in ("1","yes","Yes","TRUE","true")
    corr      = r.get("Corr_pct", "")
    ratio     = r.get("Ratio_U1_U2_pct", "")
    l_pts     = r.get("L_points", "")
    b_pts     = r.get("B_points", "")
    symbol    = r.get("_symbol", r.get("Symbol", "—"))
    tf        = r.get("_tf",     r.get("TF", "—"))
    aid       = r.get("AngleID", "")
    direction = r.get("Dir", "")
    form_time = r.get("FormTime", "")
    src_file  = r.get("_source_file", "")

    left_ctx  = [parse_ctx(r.get(f"Left_{i}",""))  for i in range(1,11)]
    right_ctx = [parse_ctx(r.get(f"Right_{i}","")) for i in range(1,11)]
    left_ctx  = [c for c in left_ctx  if c]
    right_ctx = [c for c in right_ctx if c]

    for test in TESTS:
        react   = r.get(f"{test}_React","").strip()
        tp1     = str(r.get(f"{test}_TP1_Hit","0")).strip() in ("1","yes","Yes")
        session = r.get(f"{test}_Session","").strip()
        try:    max_tp = float(r.get(f"{test}_MaxTP","0"))
        except: max_tp = 0.0
        touched = react in ("BOUNCE","BREAK")
        success = react == "BOUNCE" and tp1

        signals.append({
            "angle_id": aid, "form_time": form_time,
            "direction": direction, "cls": cls,
            "confirmed": confirmed, "corr": corr,
            "corr_bkt": corr_bucket(corr),
            "ratio": ratio, "ratio_bkt": ratio_bucket(ratio),
            "l_pts": l_pts, "b_pts": b_pts,
            "lb_bkt": lb_bucket(l_pts, b_pts),
            "test": test, "react": react, "tp1": tp1,
            "max_tp": max_tp, "session": session,
            "touched": touched, "success": success,
            "symbol": symbol, "tf": tf, "src_file": src_file,
            "left": left_ctx, "right": right_ctx,
        })

touched_sigs  = [s for s in signals if s["touched"]]
success_sigs  = [s for s in signals if s["success"]]
T_SIG  = len(signals)
T_TOCH = len(touched_sigs)
T_SUCC = len(success_sigs)
BASE   = T_SUCC / T_TOCH if T_TOCH else 0
confirmed_count = sum(1 for r in all_rows
                      if str(r.get("Confirmed","0")).strip() in ("1","yes","Yes","TRUE","true"))

print(f"إشارات={T_SIG}, ملموسة={T_TOCH}, نجاح={T_SUCC}, Base={pct(T_SUCC,T_TOCH)}%")

# ─── دالة تحليل عامل ─────────────────────────────────────────────────────────
def factor_table(key_fn, label_fn=None, pool=None):
    pool = pool or touched_sigs
    g = defaultdict(lambda: [0, 0])
    for s in pool:
        k = key_fn(s)
        g[k][0] += 1
        g[k][1] += int(s["success"])
    rows = []
    for k, (t, sc) in g.items():
        rate = sc / t if t else 0
        rows.append({"label": label_fn(k) if label_fn else k,
                     "touched": t, "success": sc,
                     "rate": rate, "lift": lft(rate, BASE)})
    rows.sort(key=lambda x: -x["rate"])
    html = '<table><tr><th>القيمة</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for d in rows:
        rc = rate_color(d["rate"])
        html += (f'<tr {row_style(d["rate"])}><td>{d["label"]}</td>'
                 f'<td>{d["touched"]}</td><td>{d["success"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(d["success"],d["touched"])}%</td>'
                 f'<td>{lift_badge(d["lift"])}</td></tr>')
    return html + "</table>"

# ─── أفضل اختبار لكل تصنيف ───────────────────────────────────────────────────
ct_stats = defaultdict(lambda: [0, 0, 0.0])
for s in touched_sigs:
    k = (s["cls"], s["test"])
    ct_stats[k][0] += 1
    ct_stats[k][1] += int(s["success"])
    ct_stats[k][2] += s["max_tp"]

class_best = {}
for (cls, test), (t, sc, mtp) in ct_stats.items():
    rate = sc / t if t else 0
    if cls not in class_best or rate > class_best[cls]["rate"]:
        class_best[cls] = {"test": test, "rate": rate,
                           "touched": t, "success": sc,
                           "mtp_avg": mtp / t if t else 0,
                           "lift": lft(rate, BASE)}
class_best_sorted = sorted(class_best.items(), key=lambda x: -x[1]["rate"])

def class_best_html():
    html = '<table><tr><th>التصنيف</th><th>أفضل اختبار</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th><th>متوسط MaxTP</th></tr>'
    for cls, d in class_best_sorted:
        rc = rate_color(d["rate"])
        html += (f'<tr {row_style(d["rate"])}>'
                 f'<td style="color:#ffd34d;font-weight:bold">{cls}</td>'
                 f'<td>{d["test"]}</td><td>{d["touched"]}</td><td>{d["success"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(d["success"],d["touched"])}%</td>'
                 f'<td>{lift_badge(d["lift"])}</td><td>{round(d["mtp_avg"],1)}</td></tr>')
    return html + "</table>"

def all_tests_html():
    html = '<table><tr><th>التصنيف</th><th>الاختبار</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for (cls, test), (t, sc, _) in sorted(ct_stats.items(),
            key=lambda x: -(x[1][1]/max(x[1][0],1))):
        rate = sc / t if t else 0
        rc = rate_color(rate)
        html += (f'<tr {row_style(rate)}><td>{cls}</td><td>{test}</td>'
                 f'<td>{t}</td><td>{sc}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(sc,t)}%</td>'
                 f'<td>{lift_badge(lft(rate,BASE))}</td></tr>')
    return html + "</table>"

# ─── Tier Ranking ─────────────────────────────────────────────────────────────
tier_stats = defaultdict(lambda: [0, 0])
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bkt"])
    tier_stats[k][0] += 1
    tier_stats[k][1] += int(s["success"])

tier_list = sorted(
    [{"cls": k[0], "test": k[1], "corr_bkt": k[2],
      "touched": v[0], "success": v[1],
      "rate": v[1]/v[0] if v[0] else 0,
      "lift": lft(v[1]/v[0] if v[0] else 0, BASE)}
     for k, v in tier_stats.items() if v[0] >= 2],
    key=lambda x: -x["rate"])

def tier_html(limit=30):
    html = '<table><tr><th>#</th><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for i, t in enumerate(tier_list[:limit], 1):
        rc = rate_color(t["rate"])
        html += (f'<tr {row_style(t["rate"])}>'
                 f'<td style="color:#6f8294">#{i}</td>'
                 f'<td style="color:#ffd34d">{t["cls"]}</td>'
                 f'<td>{t["test"]}</td><td>{t["corr_bkt"]}</td>'
                 f'<td>{t["touched"]}</td><td>{t["success"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(t["success"],t["touched"])}%</td>'
                 f'<td>{lift_badge(t["lift"])}</td></tr>')
    return html + "</table>"

# ─── Combined Rules ───────────────────────────────────────────────────────────
combo_stats = defaultdict(lambda: [0, 0])
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bkt"],
         "مؤكّدة" if s["confirmed"] else "غير مؤكّدة")
    combo_stats[k][0] += 1
    combo_stats[k][1] += int(s["success"])

combo_list = sorted(
    [{"cls": k[0], "test": k[1], "corr_bkt": k[2], "conf": k[3],
      "touched": v[0], "success": v[1],
      "rate": v[1]/v[0] if v[0] else 0,
      "lift": lft(v[1]/v[0] if v[0] else 0, BASE)}
     for k, v in combo_stats.items() if v[0] >= 2],
    key=lambda x: -x["rate"])

def combo_html(limit=20):
    html = '<table><tr><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>الحالة</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for c in combo_list[:limit]:
        rc = rate_color(c["rate"])
        html += (f'<tr {row_style(c["rate"])}>'
                 f'<td style="color:#ffd34d">{c["cls"]}</td>'
                 f'<td>{c["test"]}</td><td>{c["corr_bkt"]}</td><td>{c["conf"]}</td>'
                 f'<td>{c["touched"]}</td><td>{c["success"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(c["success"],c["touched"])}%</td>'
                 f'<td>{lift_badge(c["lift"])}</td></tr>')
    return html + "</table>"

# ─── Failure ──────────────────────────────────────────────────────────────────
fail_stats = defaultdict(lambda: [0, 0])
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bkt"])
    fail_stats[k][0] += 1
    fail_stats[k][1] += int(not s["success"])

fail_list = sorted(
    [{"cls": k[0], "test": k[1], "corr_bkt": k[2],
      "total": v[0], "fail": v[1],
      "fail_rate": v[1]/v[0] if v[0] else 0,
      "succ_rate": 1 - v[1]/v[0] if v[0] else 0}
     for k, v in fail_stats.items() if v[0] >= 2],
    key=lambda x: -x["fail_rate"])

def fail_html(limit=15):
    html = '<table><tr><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>إجمالي</th><th>فشل</th><th>نسبة الفشل</th><th>نسبة النجاح</th></tr>'
    for f in fail_list[:limit]:
        fc = "#ff6b6b" if f["fail_rate"] > .8 else "#ffd34d"
        html += (f'<tr style="background:#1a0d0d">'
                 f'<td>{f["cls"]}</td><td>{f["test"]}</td><td>{f["corr_bkt"]}</td>'
                 f'<td>{f["total"]}</td><td>{f["fail"]}</td>'
                 f'<td style="color:{fc};font-weight:bold">{pct(f["fail"],f["total"])}%</td>'
                 f'<td style="color:#9fb0c0">{pct(f["total"]-f["fail"],f["total"])}%</td></tr>')
    return html + "</table>"

# ─── Transition Matrix ────────────────────────────────────────────────────────
sorted_rows_all = sorted(all_rows, key=lambda r: r.get("FormTime",""))
row_classes  = [r.get("Class","").strip() for r in sorted_rows_all]
row_ang_ids  = [r.get("AngleID","") for r in sorted_rows_all]
all_cls_set  = sorted(set(c for c in row_classes if c))

trans = defaultdict(lambda: defaultdict(int))
for i in range(len(row_classes)-1):
    s, d = row_classes[i], row_classes[i+1]
    if s and d: trans[s][d] += 1

def trans_matrix_html():
    html = '<div style="overflow-x:auto"><table><tr><th>من ↓ / إلى →</th>'
    for c in all_cls_set: html += f"<th>{c}</th>"
    html += "<th>المجموع</th></tr>"
    for src in all_cls_set:
        html += f'<tr><td style="color:#ffd34d;font-weight:bold">{src}</td>'
        total = sum(trans[src].values()) if src in trans else 0
        for dst in all_cls_set:
            cnt = trans[src].get(dst, 0) if src in trans else 0
            if cnt == 0:
                html += '<td style="color:#25384a">—</td>'
            else:
                col = rate_color(cnt/total)
                html += (f'<td style="color:{col}">{pct(cnt,total)}%'
                         f'<br><span style="color:#6f8294;font-size:10px">({cnt})</span></td>')
        html += f'<td style="color:#9fb0c0">{total}</td></tr>'
    return html + "</table></div>"

# ─── Sequence Rules ───────────────────────────────────────────────────────────
# نجاح الزاوية = نجحت على أي اختبار
angle_success = defaultdict(bool)
for s in success_sigs:
    angle_success[s["angle_id"]] = True

def seq_table(n=2, limit=20):
    stats = defaultdict(lambda: [0, 0])
    ids_cls = list(zip(row_ang_ids, row_classes))
    for i in range(n-1, len(ids_cls)):
        seq  = tuple(ids_cls[i-n+1+j][1] for j in range(n))
        aid  = ids_cls[i][0]
        if all(seq):
            stats[seq][0] += 1
            stats[seq][1] += int(angle_success.get(aid, False))

    last_cls_base = defaultdict(lambda: [0, 0])
    for aid, cls in ids_cls:
        if cls:
            last_cls_base[cls][0] += 1
            last_cls_base[cls][1] += int(angle_success.get(aid, False))

    rows_out = []
    for seq, (cnt, sc) in stats.items():
        if cnt < 2: continue
        last  = seq[-1]
        lb_t, lb_s = last_cls_base[last]
        cls_base = lb_s / lb_t if lb_t else 0
        rate = sc / cnt
        rows_out.append({"seq": "→".join(seq), "cnt": cnt, "sc": sc,
                         "rate": rate, "cls_base": cls_base,
                         "lift": lft(rate, cls_base) if cls_base else 0})
    rows_out.sort(key=lambda x: -x["rate"])

    html = '<table><tr><th>التسلسل</th><th>عدد</th><th>نجاح</th><th>نسبة</th><th>Base</th><th>Lift</th></tr>'
    for d in rows_out[:limit]:
        rc = rate_color(d["rate"])
        html += (f'<tr {row_style(d["rate"])}>'
                 f'<td style="color:#4db1ff;font-weight:bold">{d["seq"]}</td>'
                 f'<td>{d["cnt"]}</td><td>{d["sc"]}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(d["sc"],d["cnt"])}%</td>'
                 f'<td style="color:#9fb0c0">{round(d["cls_base"]*100,1)}%</td>'
                 f'<td>{lift_badge(d["lift"])}</td></tr>')
    return html + "</table>"

# ─── Per-symbol breakdown ─────────────────────────────────────────────────────
def symbol_breakdown_html():
    sym_stats = defaultdict(lambda: [0, 0, 0, set()])
    for r in all_rows:
        sym = r.get("_symbol", r.get("Symbol","—"))
        sym_stats[sym][0] += 1
    for s in touched_sigs:
        sym_stats[s["symbol"]][1] += 1
        sym_stats[s["symbol"]][2] += int(s["success"])
        sym_stats[s["symbol"]][3].add(s["cls"])

    html = '<table><tr><th>الزوج</th><th>الزوايا</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>التصنيفات</th></tr>'
    for sym, (ang, tch, sc, classes) in sorted(sym_stats.items()):
        rate = sc / tch if tch else 0
        rc   = rate_color(rate)
        html += (f'<tr><td style="color:#4db1ff;font-weight:bold">{sym}</td>'
                 f'<td>{ang}</td><td>{tch}</td><td>{sc}</td>'
                 f'<td style="color:{rc};font-weight:bold">{pct(sc,tch)}%</td>'
                 f'<td style="color:#9fb0c0">{", ".join(sorted(classes))}</td></tr>')
    return html + "</table>"

# ─── Angle Cards ─────────────────────────────────────────────────────────────
def angle_cards_html():
    angle_map = {}
    for r in sorted_rows_all:
        aid = r.get("AngleID","")
        if aid not in angle_map:
            angle_map[aid] = {"r": r, "tests": {}}
    for s in signals:
        if s["angle_id"] in angle_map:
            angle_map[s["angle_id"]]["tests"][s["test"]] = s

    html = ""
    for aid, adat in angle_map.items():
        r    = adat["r"]
        cls  = r.get("Class","").strip()
        col  = "#37d67a" if cls in GOOD_CLASSES else "#ff6b6b"
        conf = str(r.get("Confirmed","0")).strip() in ("1","yes","Yes","TRUE","true")
        conf_s   = ("✔ مؤكّدة", "#37d67a") if conf else ("✖ غير مؤكّدة", "#ffd34d")
        cb       = corr_bucket(r.get("Corr_pct",""))
        cb_col   = "#37d67a" if cb == "ALPHA عميق" else ("#4db1ff" if cb == "ALPHA منخفض" else "#ff6b6b")

        left_c  = [parse_ctx(r.get(f"Left_{i}",""))  for i in range(1,11)]
        right_c = [parse_ctx(r.get(f"Right_{i}","")) for i in range(1,11)]
        left_s  = " · ".join([c for c in left_c  if c][:5]) or "—"
        right_s = " · ".join([c for c in right_c if c][:5]) or "—"

        test_rows = ""
        for t in TESTS:
            td = adat["tests"].get(t, {})
            react  = td.get("react","—") or "—"
            if react == "BOUNCE":   react_s = '<span style="color:#37d67a">BOUNCE</span>'
            elif react == "BREAK":  react_s = '<span style="color:#ff6b6b">BREAK</span>'
            elif react == "UNTOUCHED": react_s = '<span style="color:#9fb0c0">UNTOUCHED</span>'
            else:                   react_s = f'<span style="color:#9fb0c0">{react}</span>'
            tp1_s  = '<span style="color:#37d67a">✔</span>' if td.get("tp1") else '<span style="color:#6f8294">✖</span>'
            succ_s = '<span style="color:#37d67a;font-weight:bold">نجاح</span>' if td.get("success") else ""
            sess   = SESSION_AR.get(td.get("session",""), td.get("session","—") or "—")
            mtp    = str(int(td["max_tp"])) if td.get("max_tp") else "0"
            rbg    = 'style="background:#0d2e1a"' if td.get("success") else ""
            test_rows += (f'<tr {rbg}><td>{t}</td><td>{react_s}</td>'
                          f'<td>{tp1_s}</td><td>{mtp}</td><td>{sess}</td><td>{succ_s}</td></tr>')

        sym = r.get("_symbol", r.get("Symbol",""))
        html += f"""
<div class="angle-card">
  <div class="angle-header">
    <span class="aid">#{aid}</span>
    <span style="color:{col};font-size:15px;font-weight:bold">{cls}</span>
    <span class="badge">{r.get("Dir","")}</span>
    <span class="badge" style="color:#4db1ff">{sym}</span>
    <span class="ts">{r.get("FormTime","")}</span>
    <span style="color:{conf_s[1]};font-size:11px">{conf_s[0]}</span>
  </div>
  <div class="angle-meta">
    <span class="badge">تصحيح: <b style="color:{cb_col}">{r.get("Corr_pct","")}% ({cb})</b></span>
    <span class="badge">Ratio: {r.get("Ratio_U1_U2_pct","")}%</span>
    <span class="badge">L:{r.get("L_points","")} B:{r.get("B_points","")}</span>
  </div>
  <div class="angle-ctx">
    <span style="color:#9fb0c0;font-size:11px">السابق: <b>{left_s}</b> | التالي: <b>{right_s}</b></span>
  </div>
  <table class="test-table">
    <tr><th>نقطة</th><th>الردّ</th><th>TP1</th><th>MaxTP</th><th>الجلسة</th><th>النتيجة</th></tr>
    {test_rows}
  </table>
</div>"""
    return html

# ─── Sources Table ────────────────────────────────────────────────────────────
def sources_html():
    html = '<table><tr><th>الملف</th><th>الزوج</th><th>الإطار</th><th>من</th><th>إلى</th><th>الزوايا</th></tr>'
    for m in file_meta:
        html += (f'<tr><td style="color:#9fb0c0;font-size:12px">{m["file"]}</td>'
                 f'<td style="color:#4db1ff;font-weight:bold">{m["symbol"]}</td>'
                 f'<td>{m["tf"]}</td><td>{m["from"]}</td><td>{m["to"]}</td>'
                 f'<td style="color:#ffd34d">{m["count"]}</td></tr>')
    return html + "</table>"

# ─── Golden / Avoid boxes ─────────────────────────────────────────────────────
top_gold = [t for t in tier_list if t["rate"] >= .50][:5]
top_fail  = [f for f in fail_list if f["fail_rate"] >= .70][:5]

def golden_html():
    html = '<div class="golden-box"><b>الصفقات الذهبية (نجاح ≥ 50%):</b><br>'
    if top_gold:
        for t in top_gold:
            html += (f'<div class="grow">{t["cls"]} + {t["test"]} + {t["corr_bkt"]}'
                     f' → <b style="color:#37d67a">{pct(t["success"],t["touched"])}%</b>'
                     f' ({t["touched"]} إشارة, {lift_badge(t["lift"])})</div>')
    else:
        html += '<div style="color:#9fb0c0">لا توجد تركيبات بنسبة ≥ 50%</div>'
    return html + '</div>'

def avoid_html():
    html = '<div class="avoid-box"><b>مناطق التجنّب (فشل ≥ 70%):</b><br>'
    if top_fail:
        for f in top_fail:
            html += (f'<div class="grow">{f["cls"]} + {f["test"]} + {f["corr_bkt"]}'
                     f' → <b style="color:#ff6b6b">فشل {pct(f["fail"],f["total"])}%</b>'
                     f' ({f["total"]} إشارة)</div>')
    else:
        html += '<div style="color:#9fb0c0">لا توجد مناطق فشل واضحة ≥ 70%</div>'
    return html + '</div>'

# ─── Symbols list for header ──────────────────────────────────────────────────
symbols_str = " · ".join(sorted(set(m["symbol"] for m in file_meta)))
files_count = len(file_meta)
best_combo  = combo_list[0] if combo_list else None
bc_str  = (f'{best_combo["cls"]} + {best_combo["test"]} + {best_combo["corr_bkt"]} + {best_combo["conf"]}'
           if best_combo else "—")
bc_rate = pct(best_combo["success"], best_combo["touched"]) if best_combo else 0

# ─── Build HTML ───────────────────────────────────────────────────────────────
HTML = f"""<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<title>تقرير AIB الشامل — {symbols_str}</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box;font-family:Arial,Tahoma,sans-serif}}
body{{width:980px;background:#0b1520;color:#e9eef4;padding:30px 32px;margin:0 auto}}
h1{{font-size:26px;color:#4db1ff;text-align:center;margin-bottom:4px}}
h2{{font-size:17px;color:#ffd34d;margin:28px 0 10px;border-right:4px solid #ffd34d;padding-right:9px}}
h3{{font-size:14px;color:#9fb0c0;margin:16px 0 7px}}
.sub{{text-align:center;color:#9fb0c0;font-size:13px;margin:4px 0 20px}}
.stat-row{{display:flex;gap:12px;margin-bottom:14px;flex-wrap:wrap}}
.stat-card{{flex:1;min-width:120px;background:#172533;border-radius:10px;padding:12px 14px}}
.stat-card .t{{font-size:12px;color:#9fb0c0}}.stat-card .v{{font-size:20px;font-weight:bold;margin-top:3px}}
.stat-card .s{{font-size:11px;color:#6f8294}}
table{{width:100%;border-collapse:collapse;margin-top:6px}}
td,th{{padding:8px 10px;font-size:13px;border-bottom:1px solid #1e3244;text-align:right}}
th{{color:#ffd34d;background:#111e2b}}
tr:hover{{background:#1a2e3d}}
.two-col{{display:flex;gap:18px;flex-wrap:wrap}}
.two-col>div{{flex:1;min-width:300px}}
.golden-box{{background:#0a2010;border:1px solid #1c5530;border-radius:10px;padding:14px 16px;margin:12px 0}}
.avoid-box{{background:#200a0a;border:1px solid #552020;border-radius:10px;padding:14px 16px;margin:12px 0}}
.grow{{font-size:13px;margin:5px 0;line-height:1.8}}
.final-rule{{background:#0e1f30;border:1px solid #245370;border-radius:10px;padding:14px 16px;font-size:14px;margin-top:18px;line-height:2}}
.tag{{display:inline-block;background:#1a2e3d;border-radius:5px;padding:2px 9px;font-size:12px;margin:0 2px}}
.sep{{border-top:2px solid #1e3244;margin:28px 0}}
.angle-grid{{display:flex;flex-wrap:wrap;gap:14px;margin-top:10px}}
.angle-card{{background:#111e2b;border:1px solid #1e3244;border-radius:10px;padding:12px;width:calc(50% - 7px);min-width:380px}}
.angle-header{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-bottom:6px}}
.aid{{color:#6f8294;font-size:12px}}.ts{{color:#6f8294;font-size:11px}}
.angle-meta{{display:flex;gap:8px;flex-wrap:wrap;margin:5px 0}}
.badge{{background:#1a2e3d;border-radius:5px;padding:2px 8px;font-size:12px}}
.angle-ctx{{margin:4px 0}}
.test-table td,.test-table th{{font-size:12px;padding:5px 7px}}
.foot{{text-align:center;color:#6f8294;font-size:11px;margin-top:22px}}
</style>
</head>
<body>

<h1>تقرير AIB الشامل — {symbols_str}</h1>
<div class="sub">
  {files_count} ملف مدموج · {N} زاوية · {T_SIG} إشارة · {T_TOCH} ملموسة · {T_SUCC} نجاح · معدّل القاعدة {pct(T_SUCC,T_TOCH)}%
</div>

<!-- ══ 1. إحصاءات عامة ══ -->
<div class="stat-row">
  <div class="stat-card"><div class="t">الزوايا الكلية</div><div class="v" style="color:#4db1ff">{N}</div><div class="s">من {files_count} ملف</div></div>
  <div class="stat-card"><div class="t">الإشارات</div><div class="v" style="color:#9fb0c0">{T_SIG}</div><div class="s">4 نقاط × {N}</div></div>
  <div class="stat-card"><div class="t">الملموسات</div><div class="v" style="color:#ffd34d">{T_TOCH}</div><div class="s">{pct(T_TOCH,T_SIG)}% من الكل</div></div>
  <div class="stat-card"><div class="t">النجاحات</div><div class="v" style="color:#37d67a">{T_SUCC}</div><div class="s">BOUNCE+TP1</div></div>
  <div class="stat-card"><div class="t">معدّل النجاح</div><div class="v" style="color:#37d67a">{pct(T_SUCC,T_TOCH)}%</div><div class="s">Base Rate</div></div>
  <div class="stat-card"><div class="t">المؤكّدات</div><div class="v" style="color:#4db1ff">{confirmed_count}</div><div class="s">{pct(confirmed_count,N)}%</div></div>
  <div class="stat-card"><div class="t">أفضل توليفة</div><div class="v" style="color:#37d67a;font-size:13px">{bc_rate}%</div><div class="s" style="font-size:10px">{bc_str}</div></div>
</div>

<!-- ══ مصادر البيانات ══ -->
<h2>مصادر البيانات (العينات المحللة)</h2>
{sources_html()}
<h3>توزيع الزوايا حسب الزوج والتأطير الزمني</h3>
{symbol_breakdown_html()}

<div class="sep"></div>

<!-- ══ 2. أفضل اختبار لكل تصنيف ══ -->
<h2>أفضل اختبار لكل تصنيف</h2>
{class_best_html()}
<h3>جميع الاختبارات — Class × Test</h3>
{all_tests_html()}

<div class="sep"></div>

<!-- ══ 3. Tier Ranking ══ -->
<h2>تصنيف قوة الدخول — Class × Test × التصحيح</h2>
<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">مرتّبة تنازلياً (≥ 2 إشارة لكل تركيبة)</p>
{tier_html()}

<div class="sep"></div>

<!-- ══ 4. صفات الناجحين ══ -->
<h2>صفات الإشارات الناجحة</h2>
<div class="two-col">
  <div>
    <h3>عمق التصحيح</h3>{factor_table(lambda s: s["corr_bkt"])}
    <h3>نقطة الاختبار</h3>{factor_table(lambda s: s["test"])}
    <h3>حالة التأكيد</h3>{factor_table(lambda s: "مؤكّدة" if s["confirmed"] else "غير مؤكّدة")}
  </div>
  <div>
    <h3>نسبة U1/U2</h3>{factor_table(lambda s: s["ratio_bkt"])}
    <h3>نسبة L/B</h3>{factor_table(lambda s: s["lb_bkt"])}
    <h3>الجلسة</h3>{factor_table(lambda s: s["session"], lambda k: SESSION_AR.get(k,k))}
  </div>
</div>
<h3>التصنيف</h3>{factor_table(lambda s: s["cls"])}
<h3>الزوج</h3>{factor_table(lambda s: s["symbol"])}

<div class="sep"></div>

<!-- ══ 5. الصفقات الذهبية ══ -->
<h2>الصفقات الذهبية ومعايير التجنّب</h2>
{golden_html()}
{avoid_html()}

<div class="sep"></div>

<!-- ══ 6. القوانين المركّبة ══ -->
<h2>أقوى القوانين المركّبة (Class + Test + Corr + Confirmation)</h2>
{combo_html()}

<div class="sep"></div>

<!-- ══ 7. معايير الفشل ══ -->
<h2>معايير الفشل — أعلى نسب الفشل</h2>
{fail_html()}

<div class="sep"></div>

<!-- ══ 8. مصفوفة الانتقال ══ -->
<h2>مصفوفة انتقال الزوايا — P(التصنيف التالي | الحالي)</h2>
<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">النسب المئوية = احتمال الانتقال · الأرقام بين قوسين = عدد مرات الحدوث</p>
{trans_matrix_html()}

<div class="sep"></div>

<!-- ══ 9. قوانين التسلسل ══ -->
<h2>قوانين التسلسل — زاويتان متتاليتان</h2>
{seq_table(n=2)}
<h2>قوانين التسلسل — ثلاث زوايا متتالية</h2>
{seq_table(n=3)}

<div class="sep"></div>

<!-- ══ 10. بطاقات الزوايا ══ -->
<h2>بطاقات الزوايا التفصيلية ({N} زاوية)</h2>
<div class="angle-grid">
{angle_cards_html()}
</div>

<!-- القانون النهائي -->
<div class="final-rule">
  <b>القانون النهائي:</b> ادخل بأعلى ثقة عند اجتماع:
  <span class="tag">{class_best_sorted[0][0] if class_best_sorted else "ZD"}</span>
  + <span class="tag">أفضل اختبار</span>
  + <span class="tag">ALPHA عميق ≥62%</span>
  + <span class="tag">L/B صغيرة</span>
  + <span class="tag">جلسة لندن/نيويورك</span>
  + <span class="tag">مؤكّدة</span>.
  تجنّب: BETA + DLX1 + {", ".join(sorted(WEAK_CLASSES))}.
</div>

<div class="foot">
  AIB Angles Analyzer · {symbols_str} · {N} زاوية من {files_count} ملف · {datetime.now().strftime("%Y-%m-%d %H:%M")}
</div>
</body>
</html>"""

# ─── حفظ التقرير ─────────────────────────────────────────────────────────────
syms_safe = symbols_str.replace(" · ", "_").replace("/", "")
out_name  = f"تقرير_AIB_شامل_{syms_safe}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
out_path  = OUTPUT_DIR / out_name

with open(out_path, "w", encoding="utf-8") as f:
    f.write(HTML)

print(f"\n✅ التقرير جاهز: {out_path}")
print(f"   الحجم: {len(HTML):,} حرف")
