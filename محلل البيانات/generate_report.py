"""
مولّد التقرير الشامل - EURUSD Angles Analysis
Generates a single comprehensive HTML report from AIB angles CSV data.
"""
import csv
import os
import re
from collections import defaultdict
from datetime import datetime

# ─── Paths ───────────────────────────────────────────────────────────────────
CSV_PATH = os.path.join(os.path.dirname(__file__), "التقارير",
                        "AIB_Report_BT_EURUSD_60_U86400_19991108_to_20001229.csv")
OUT_DIR  = os.path.join(os.path.dirname(__file__), "مخرجات التحليل")
os.makedirs(OUT_DIR, exist_ok=True)

# ─── Helpers ──────────────────────────────────────────────────────────────────
TESTS = ["U1X1", "U2X1", "DLX1", "DRX1"]
GOOD_CLASSES  = {"ZB", "ZC", "ZD", "ZE"}
WEAK_CLASSES  = {"ZF", "ZG", "ZH", "ZO"}
SESSION_MAP   = {"London": "لندن", "NewYork": "نيويورك", "Asia": "آسيا",
                 "Other": "أخرى", "NA": "—"}

def corr_bucket(val):
    try:
        v = float(val)
        if v >= 62:  return "ALPHA عميق"
        if v >= 38:  return "ALPHA منخفض"
        return "BETA"
    except:
        return "غير محدد"

def ratio_bucket(val):
    try:
        v = float(val)
        if v < 80:   return "صغيرة"
        if v < 120:  return "متوسطة"
        return "كبيرة"
    except:
        return "غير محدد"

def lb_bucket(l, b):
    try:
        ratio = float(l) / float(b)
        if ratio < 1.5:  return "صغيرة"
        if ratio < 3:    return "متوسطة"
        return "كبيرة"
    except:
        return "غير محدد"

def pct(n, d):
    return round(100 * n / d, 1) if d else 0.0

def lift(rate, base):
    return round(rate / base, 2) if base else 0.0

def parse_context(s):
    """Parse 'B-ZB-UN' → class string, or return None."""
    if not s or s.strip() in ("", "NA"):
        return None
    m = re.match(r"[BS]-([A-Z]+)-", s.strip())
    return m.group(1) if m else None

# ─── Load CSV ─────────────────────────────────────────────────────────────────
rows = []
with open(CSV_PATH, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for r in reader:
        rows.append(r)

N = len(rows)
print(f"Loaded {N} rows")

# ─── Expand signals ───────────────────────────────────────────────────────────
# Each row × each test_point = one signal
signals = []
for r in rows:
    cls       = r.get("Class", "").strip()
    confirmed = str(r.get("Confirmed", "0")).strip() in ("1", "yes", "Yes", "TRUE", "true")
    corr      = r.get("Corr_pct", "")
    ratio     = r.get("Ratio_U1_U2_pct", "")
    l_pts     = r.get("L_points", "")
    b_pts     = r.get("B_points", "")
    form_time = r.get("FormTime", "")
    angle_id  = r.get("AngleID", "")
    direction = r.get("Dir", "")

    # Left / Right context
    left_classes  = [parse_context(r.get(f"Left_{i}", ""))  for i in range(1, 11)]
    right_classes = [parse_context(r.get(f"Right_{i}", "")) for i in range(1, 11)]
    left_classes  = [c for c in left_classes  if c]
    right_classes = [c for c in right_classes if c]

    for test in TESTS:
        react    = r.get(f"{test}_React", "").strip()
        tp1      = str(r.get(f"{test}_TP1_Hit", "0")).strip() in ("1", "yes", "Yes")
        max_tp   = r.get(f"{test}_MaxTP", "0")
        session  = r.get(f"{test}_Session", "").strip()
        touched  = react in ("BOUNCE", "BREAK")
        success  = react == "BOUNCE" and tp1

        try:
            max_tp_v = float(max_tp)
        except:
            max_tp_v = 0.0

        signals.append({
            "angle_id":    angle_id,
            "form_time":   form_time,
            "direction":   direction,
            "cls":         cls,
            "confirmed":   confirmed,
            "corr":        corr,
            "corr_bucket": corr_bucket(corr),
            "ratio":       ratio,
            "ratio_bkt":   ratio_bucket(ratio),
            "l_pts":       l_pts,
            "b_pts":       b_pts,
            "lb_bkt":      lb_bucket(l_pts, b_pts),
            "test":        test,
            "react":       react,
            "tp1":         tp1,
            "max_tp":      max_tp_v,
            "session":     session,
            "touched":     touched,
            "success":     success,
            "left":        left_classes,
            "right":       right_classes,
        })

total_signals  = len(signals)
touched_sigs   = [s for s in signals if s["touched"]]
success_sigs   = [s for s in signals if s["success"]]
total_touched  = len(touched_sigs)
total_success  = len(success_sigs)
BASE_RATE      = total_success / total_touched if total_touched else 0
print(f"Signals={total_signals}, Touched={total_touched}, Success={total_success}, Base={pct(total_success,total_touched)}%")

# ─── Per-angle test summary (for angle cards) ─────────────────────────────────
angle_map = defaultdict(lambda: {
    "info": {},
    "tests": {}
})
for s in signals:
    aid = s["angle_id"]
    if not angle_map[aid]["info"]:
        angle_map[aid]["info"] = {
            "angle_id": aid, "form_time": s["form_time"],
            "direction": s["direction"], "cls": s["cls"],
            "confirmed": s["confirmed"], "corr": s["corr"],
            "corr_bucket": s["corr_bucket"], "ratio": s["ratio"],
            "l_pts": s["l_pts"], "b_pts": s["b_pts"],
            "left": s["left"], "right": s["right"],
        }
    angle_map[aid]["tests"][s["test"]] = {
        "react": s["react"], "tp1": s["tp1"],
        "max_tp": s["max_tp"], "session": s["session"],
        "success": s["success"],
    }

# ─── Best test per class ───────────────────────────────────────────────────────
# Among touched signals, group by (class, test)
class_test_stats = defaultdict(lambda: {"touched": 0, "success": 0, "max_tp_sum": 0})
for s in touched_sigs:
    k = (s["cls"], s["test"])
    class_test_stats[k]["touched"]    += 1
    class_test_stats[k]["success"]    += int(s["success"])
    class_test_stats[k]["max_tp_sum"] += s["max_tp"]

# group by class → best test
class_best = {}
for (cls, test), st in class_test_stats.items():
    rate = st["success"] / st["touched"] if st["touched"] else 0
    if cls not in class_best or rate > class_best[cls]["rate"]:
        class_best[cls] = {
            "test": test, "rate": rate,
            "touched": st["touched"], "success": st["success"],
            "max_tp_avg": st["max_tp_sum"] / st["touched"] if st["touched"] else 0,
            "lift": lift(rate, BASE_RATE),
        }

# Sort by rate
class_best_sorted = sorted(class_best.items(), key=lambda x: -x[1]["rate"])

# ─── Tier ranking: Class × Test × CorrBucket ─────────────────────────────────
tier_stats = defaultdict(lambda: {"touched": 0, "success": 0})
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bucket"])
    tier_stats[k]["touched"]  += 1
    tier_stats[k]["success"]  += int(s["success"])

tier_list = []
for (cls, test, cbkt), st in tier_stats.items():
    if st["touched"] < 2:
        continue
    rate = st["success"] / st["touched"]
    tier_list.append({
        "cls": cls, "test": test, "corr_bkt": cbkt,
        "touched": st["touched"], "success": st["success"],
        "rate": rate, "lift": lift(rate, BASE_RATE),
    })
tier_list.sort(key=lambda x: -x["rate"])

# ─── Winner characteristics (among SUCCESS signals) ───────────────────────────
def factor_breakdown(sig_pool, base_pool, key_fn, label_fn=None):
    """For each value of key, count success and touched in base_pool."""
    groups = defaultdict(lambda: {"touched": 0, "success": 0})
    for s in base_pool:
        k = key_fn(s)
        groups[k]["touched"]  += 1
        groups[k]["success"]  += int(s["success"])
    result = []
    for k, st in groups.items():
        rate = st["success"] / st["touched"] if st["touched"] else 0
        result.append({
            "label": label_fn(k) if label_fn else k,
            "touched": st["touched"], "success": st["success"],
            "rate": rate, "lift": lift(rate, BASE_RATE),
        })
    result.sort(key=lambda x: -x["rate"])
    return result

winner_corr    = factor_breakdown(success_sigs, touched_sigs, lambda s: s["corr_bucket"])
winner_ratio   = factor_breakdown(success_sigs, touched_sigs, lambda s: s["ratio_bkt"])
winner_lb      = factor_breakdown(success_sigs, touched_sigs, lambda s: s["lb_bkt"])
winner_test    = factor_breakdown(success_sigs, touched_sigs, lambda s: s["test"])
winner_session = factor_breakdown(success_sigs, touched_sigs, lambda s: s["session"],
                                  label_fn=lambda k: SESSION_MAP.get(k, k))
winner_class   = factor_breakdown(success_sigs, touched_sigs, lambda s: s["cls"])
winner_confirmed = factor_breakdown(success_sigs, touched_sigs,
                                    lambda s: "مؤكّدة" if s["confirmed"] else "غير مؤكّدة")

# ─── Combined rules (Class + Test + CorrBucket + Confirmed) ───────────────────
combo_stats = defaultdict(lambda: {"touched": 0, "success": 0})
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bucket"], "مؤكّدة" if s["confirmed"] else "غير مؤكّدة")
    combo_stats[k]["touched"]  += 1
    combo_stats[k]["success"]  += int(s["success"])

combo_list = []
for (cls, test, cbkt, conf), st in combo_stats.items():
    if st["touched"] < 2:
        continue
    rate = st["success"] / st["touched"]
    combo_list.append({
        "cls": cls, "test": test, "corr_bkt": cbkt, "conf": conf,
        "touched": st["touched"], "success": st["success"],
        "rate": rate, "lift": lift(rate, BASE_RATE),
    })
combo_list.sort(key=lambda x: -x["rate"])

# ─── Failure stats ────────────────────────────────────────────────────────────
# touched but NOT success
fail_sigs = [s for s in touched_sigs if not s["success"]]
fail_stats = defaultdict(lambda: {"total": 0, "fail": 0})
for s in touched_sigs:
    k = (s["cls"], s["test"], s["corr_bucket"])
    fail_stats[k]["total"] += 1
    if not s["success"]:
        fail_stats[k]["fail"] += 1

fail_list = []
for (cls, test, cbkt), st in fail_stats.items():
    if st["total"] < 2:
        continue
    fail_rate = st["fail"] / st["total"]
    succ_rate = 1 - fail_rate
    fail_list.append({
        "cls": cls, "test": test, "corr_bkt": cbkt,
        "total": st["total"], "fail": st["fail"],
        "fail_rate": fail_rate, "succ_rate": succ_rate,
    })
fail_list.sort(key=lambda x: -x["fail_rate"])

# ─── Transition matrix (angle sequence by order in dataset) ───────────────────
# Sort rows by FormTime
sorted_rows = sorted(rows, key=lambda r: r.get("FormTime", ""))
row_classes = [r.get("Class", "").strip() for r in sorted_rows]

# Build transition counts
all_classes = sorted(set(row_classes))
trans = defaultdict(lambda: defaultdict(int))
for i in range(len(row_classes) - 1):
    src = row_classes[i]
    dst = row_classes[i+1]
    if src and dst:
        trans[src][dst] += 1

# Normalize to probabilities
trans_prob = {}
for src, targets in trans.items():
    total = sum(targets.values())
    trans_prob[src] = {dst: count/total for dst, count in targets.items()}

# ─── 2-angle sequence rules (success rate of angle B given prev = A) ──────────
seq2_stats = defaultdict(lambda: {"count": 0, "success": 0})
# Map angle_id → success flag (any test succeeded)
angle_any_success = {}
for aid, adat in angle_map.items():
    angle_any_success[aid] = any(t["success"] for t in adat["tests"].values())

# Build ordered angle list
sorted_angle_ids = [r["AngleID"] for r in sorted_rows]
sorted_angle_cls = [r["Class"].strip() for r in sorted_rows]

for i in range(1, len(sorted_angle_ids)):
    prev_cls = sorted_angle_cls[i-1]
    cur_cls  = sorted_angle_cls[i]
    cur_aid  = sorted_angle_ids[i]
    k = (prev_cls, cur_cls)
    seq2_stats[k]["count"]   += 1
    seq2_stats[k]["success"] += int(angle_any_success.get(cur_aid, False))

seq2_list = []
for (prev_cls, cur_cls), st in seq2_stats.items():
    if st["count"] < 2:
        continue
    # base for single-class
    cls_total   = sum(1 for c in sorted_angle_cls if c == cur_cls)
    cls_success = sum(1 for i, c in enumerate(sorted_angle_cls)
                      if c == cur_cls and angle_any_success.get(sorted_angle_ids[i], False))
    cls_base    = cls_success / cls_total if cls_total else 0
    rate = st["success"] / st["count"]
    seq2_list.append({
        "seq": f"{prev_cls}→{cur_cls}",
        "prev": prev_cls, "cur": cur_cls,
        "count": st["count"], "success": st["success"],
        "rate": rate, "cls_base": cls_base,
        "lift": lift(rate, cls_base) if cls_base else 0,
    })
seq2_list.sort(key=lambda x: -x["rate"])

# ─── 3-angle sequence rules ───────────────────────────────────────────────────
seq3_stats = defaultdict(lambda: {"count": 0, "success": 0})
for i in range(2, len(sorted_angle_ids)):
    c0 = sorted_angle_cls[i-2]
    c1 = sorted_angle_cls[i-1]
    c2 = sorted_angle_cls[i]
    k  = (c0, c1, c2)
    seq3_stats[k]["count"]   += 1
    seq3_stats[k]["success"] += int(angle_any_success.get(sorted_angle_ids[i], False))

seq3_list = []
for (c0, c1, c2), st in seq3_stats.items():
    if st["count"] < 2:
        continue
    cls_total   = sum(1 for c in sorted_angle_cls if c == c2)
    cls_success = sum(1 for i, c in enumerate(sorted_angle_cls)
                      if c == c2 and angle_any_success.get(sorted_angle_ids[i], False))
    cls_base = cls_success / cls_total if cls_total else 0
    rate = st["success"] / st["count"]
    seq3_list.append({
        "seq": f"{c0}→{c1}→{c2}",
        "count": st["count"], "success": st["success"],
        "rate": rate, "cls_base": cls_base,
        "lift": lift(rate, cls_base) if cls_base else 0,
    })
seq3_list.sort(key=lambda x: -x["rate"])

# ─── Class-level success stats ────────────────────────────────────────────────
# For summary box per class
class_overall = defaultdict(lambda: {"touched": 0, "success": 0})
for s in touched_sigs:
    class_overall[s["cls"]]["touched"]  += 1
    class_overall[s["cls"]]["success"]  += int(s["success"])

# ─── Session-level overall stats ─────────────────────────────────────────────
session_overall = defaultdict(lambda: {"touched": 0, "success": 0})
for s in touched_sigs:
    session_overall[s["session"]]["touched"]  += 1
    session_overall[s["session"]]["success"]  += int(s["success"])

# ─── Generate HTML ────────────────────────────────────────────────────────────

def rate_color(rate):
    if rate >= 0.50: return "#37d67a"
    if rate >= 0.35: return "#4db1ff"
    if rate >= 0.25: return "#ffd34d"
    return "#ff6b6b"

def lift_badge(lv):
    if lv >= 2.0:  return f'<span style="color:#37d67a;font-weight:bold">×{lv}</span>'
    if lv >= 1.3:  return f'<span style="color:#4db1ff">×{lv}</span>'
    if lv >= 1.0:  return f'<span style="color:#ffd34d">×{lv}</span>'
    return f'<span style="color:#ff6b6b">×{lv}</span>'

def row_style(rate):
    if rate >= 0.50: return 'style="background:#0d2e1a"'
    if rate >= 0.35: return 'style="background:#0d1f2e"'
    if rate < 0.15:  return 'style="background:#2e0d0d"'
    return ""

# ── angle cards HTML ──────────────────────────────────────────────────────────
def make_angle_cards():
    cards_html = ""
    for r in sorted_rows:
        aid  = r["AngleID"]
        adat = angle_map[aid]
        info = adat["info"]
        tests_d = adat["tests"]

        cls  = info["cls"]
        col  = "#37d67a" if cls in GOOD_CLASSES else "#ff6b6b"
        conf = "✔ مؤكّدة" if info["confirmed"] else "✖ غير مؤكّدة"
        conf_col = "#37d67a" if info["confirmed"] else "#ffd34d"
        cb   = info["corr_bucket"]
        cb_col = "#37d67a" if cb == "ALPHA عميق" else ("#4db1ff" if cb == "ALPHA منخفض" else "#ff6b6b")

        left_str  = " · ".join(info["left"][:5])  if info["left"]  else "—"
        right_str = " · ".join(info["right"][:5]) if info["right"] else "—"

        test_rows = ""
        for t in TESTS:
            td = tests_d.get(t, {"react": "—", "tp1": False, "max_tp": 0, "session": "", "success": False})
            react = td["react"] or "—"
            if react == "BOUNCE":
                react_s = '<span style="color:#37d67a">BOUNCE</span>'
            elif react == "BREAK":
                react_s = '<span style="color:#ff6b6b">BREAK</span>'
            elif react == "UNTOUCHED":
                react_s = '<span style="color:#9fb0c0">UNTOUCHED</span>'
            else:
                react_s = f'<span style="color:#9fb0c0">{react}</span>'

            tp1_s   = '<span style="color:#37d67a">✔</span>' if td["tp1"] else '<span style="color:#6f8294">✖</span>'
            succ_s  = '<span style="color:#37d67a;font-weight:bold">نجاح</span>' if td["success"] else ""
            sess    = SESSION_MAP.get(td["session"], td["session"] or "—")
            mtp     = str(int(td["max_tp"])) if td["max_tp"] else "0"

            row_bg  = 'style="background:#0d2e1a"' if td["success"] else ""
            test_rows += f"""
            <tr {row_bg}>
              <td>{t}</td><td>{react_s}</td><td>{tp1_s}</td>
              <td>{mtp}</td><td>{sess}</td><td>{succ_s}</td>
            </tr>"""

        cards_html += f"""
        <div class="angle-card">
          <div class="angle-header">
            <span class="angle-id">#{aid}</span>
            <span class="angle-cls" style="color:{col}">{cls}</span>
            <span class="angle-dir">{info['direction']}</span>
            <span class="angle-time">{info['form_time']}</span>
            <span style="color:{conf_col};font-size:12px">{conf}</span>
          </div>
          <div class="angle-meta">
            <span class="badge">تصحيح: <b style="color:{cb_col}">{info['corr']}% ({cb})</b></span>
            <span class="badge">Ratio: {info['ratio']}%</span>
            <span class="badge">L: {info['l_pts']} | B: {info['b_pts']}</span>
          </div>
          <div class="angle-ctx">
            <span style="color:#9fb0c0;font-size:11px">السياق السابق: <b>{left_str}</b> | التالي: <b>{right_str}</b></span>
          </div>
          <table class="test-table">
            <tr><th>نقطة</th><th>الردّ</th><th>TP1</th><th>MaxTP</th><th>الجلسة</th><th>النتيجة</th></tr>
            {test_rows}
          </table>
        </div>"""
    return cards_html

# ── best-per-class table ──────────────────────────────────────────────────────
def make_class_table():
    html = '<table><tr><th>التصنيف</th><th>أفضل اختبار</th><th>عدد اللمسات</th><th>نجاح</th><th>نسبة النجاح</th><th>المضاعف</th><th>متوسط MaxTP</th></tr>'
    for cls, d in class_best_sorted:
        rc = rate_color(d["rate"])
        html += f"""<tr {row_style(d["rate"])}>
          <td style="color:#ffd34d;font-weight:bold">{cls}</td>
          <td>{d['test']}</td>
          <td>{d['touched']}</td>
          <td>{d['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(d['success'],d['touched'])}%</td>
          <td>{lift_badge(d['lift'])}</td>
          <td>{round(d['max_tp_avg'],1)}</td>
        </tr>"""
    html += "</table>"
    return html

# ── all tests per class ───────────────────────────────────────────────────────
def make_all_tests_table():
    rows_html = ""
    for (cls, test), st in sorted(class_test_stats.items(),
                                   key=lambda x: (-class_overall[x[0][0]]["success"]/max(class_overall[x[0][0]]["touched"],1),
                                                  -(x[1]["success"]/max(x[1]["touched"],1)))):
        rate = st["success"] / st["touched"] if st["touched"] else 0
        lv   = lift(rate, BASE_RATE)
        rows_html += f"""<tr {row_style(rate)}>
          <td>{cls}</td><td>{test}</td>
          <td>{st['touched']}</td><td>{st['success']}</td>
          <td style="color:{rate_color(rate)};font-weight:bold">{pct(st['success'],st['touched'])}%</td>
          <td>{lift_badge(lv)}</td>
        </tr>"""
    return f'<table><tr><th>التصنيف</th><th>الاختبار</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>{rows_html}</table>'

# ── tier table ────────────────────────────────────────────────────────────────
def make_tier_table(tier_list, limit=30):
    html = '<table><tr><th>الرتبة</th><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>المضاعف</th></tr>'
    for i, t in enumerate(tier_list[:limit], 1):
        rc  = rate_color(t["rate"])
        html += f"""<tr {row_style(t["rate"])}>
          <td style="color:#9fb0c0">#{i}</td>
          <td style="color:#ffd34d">{t['cls']}</td>
          <td>{t['test']}</td>
          <td>{t['corr_bkt']}</td>
          <td>{t['touched']}</td>
          <td>{t['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(t['success'],t['touched'])}%</td>
          <td>{lift_badge(t['lift'])}</td>
        </tr>"""
    html += "</table>"
    return html

# ── factor sub-table ─────────────────────────────────────────────────────────
def make_factor_table(data, label_col="القيمة"):
    html = f'<table><tr><th>{label_col}</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for d in data:
        rc = rate_color(d["rate"])
        html += f"""<tr {row_style(d["rate"])}>
          <td>{d['label']}</td>
          <td>{d['touched']}</td>
          <td>{d['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(d['success'],d['touched'])}%</td>
          <td>{lift_badge(d['lift'])}</td>
        </tr>"""
    html += "</table>"
    return html

# ── combo rules table ─────────────────────────────────────────────────────────
def make_combo_table(limit=20):
    html = '<table><tr><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>الحالة</th><th>لمسات</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for c in combo_list[:limit]:
        rc = rate_color(c["rate"])
        html += f"""<tr {row_style(c["rate"])}>
          <td style="color:#ffd34d">{c['cls']}</td>
          <td>{c['test']}</td>
          <td>{c['corr_bkt']}</td>
          <td>{c['conf']}</td>
          <td>{c['touched']}</td>
          <td>{c['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(c['success'],c['touched'])}%</td>
          <td>{lift_badge(c['lift'])}</td>
        </tr>"""
    html += "</table>"
    return html

# ── failure table ─────────────────────────────────────────────────────────────
def make_fail_table(limit=15):
    html = '<table><tr><th>التصنيف</th><th>الاختبار</th><th>التصحيح</th><th>إجمالي</th><th>فشل</th><th>نسبة الفشل</th><th>نسبة النجاح</th></tr>'
    for f in fail_list[:limit]:
        fc = "#ff6b6b" if f["fail_rate"] > 0.8 else "#ffd34d"
        html += f"""<tr style="background:#1a0d0d">
          <td>{f['cls']}</td><td>{f['test']}</td><td>{f['corr_bkt']}</td>
          <td>{f['total']}</td><td>{f['fail']}</td>
          <td style="color:{fc};font-weight:bold">{pct(f['fail'],f['total'])}%</td>
          <td style="color:#9fb0c0">{pct(f['total']-f['fail'],f['total'])}%</td>
        </tr>"""
    html += "</table>"
    return html

# ── transition matrix ─────────────────────────────────────────────────────────
def make_transition_matrix():
    all_cls_sorted = sorted(set(row_classes))
    html  = '<div style="overflow-x:auto"><table><tr><th>من ↓ / إلى →</th>'
    for c in all_cls_sorted:
        html += f"<th>{c}</th>"
    html += "<th>المجموع</th></tr>"
    for src in all_cls_sorted:
        html += f'<tr><td style="color:#ffd34d;font-weight:bold">{src}</td>'
        row_total = sum(trans[src].values()) if src in trans else 0
        for dst in all_cls_sorted:
            cnt  = trans[src].get(dst, 0) if src in trans else 0
            prob = cnt / row_total if row_total else 0
            if cnt == 0:
                html += '<td style="color:#25384a">—</td>'
            else:
                col = rate_color(prob)
                html += f'<td style="color:{col}">{pct(cnt,row_total)}%<br><span style="color:#6f8294;font-size:10px">({cnt})</span></td>'
        html += f'<td style="color:#9fb0c0">{row_total}</td></tr>'
    html += "</table></div>"
    return html

# ── sequence tables ───────────────────────────────────────────────────────────
def make_seq2_table(limit=20):
    html = '<table><tr><th>التسلسل</th><th>عدد</th><th>نجاح</th><th>نسبة</th><th>Base التصنيف</th><th>Lift</th></tr>'
    for s in seq2_list[:limit]:
        rc = rate_color(s["rate"])
        html += f"""<tr {row_style(s["rate"])}>
          <td style="color:#4db1ff;font-weight:bold">{s['seq']}</td>
          <td>{s['count']}</td>
          <td>{s['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(s['success'],s['count'])}%</td>
          <td style="color:#9fb0c0">{pct(int(s['cls_base']*100),100)}%</td>
          <td>{lift_badge(s['lift'])}</td>
        </tr>"""
    html += "</table>"
    return html

def make_seq3_table(limit=15):
    html = '<table><tr><th>التسلسل الثلاثي</th><th>عدد</th><th>نجاح</th><th>نسبة</th><th>Lift</th></tr>'
    for s in seq3_list[:limit]:
        rc = rate_color(s["rate"])
        html += f"""<tr {row_style(s["rate"])}>
          <td style="color:#4db1ff;font-weight:bold">{s['seq']}</td>
          <td>{s['count']}</td>
          <td>{s['success']}</td>
          <td style="color:{rc};font-weight:bold">{pct(s['success'],s['count'])}%</td>
          <td>{lift_badge(s['lift'])}</td>
        </tr>"""
    html += "</table>"
    return html

# ── Top combos highlight (golden trades) ─────────────────────────────────────
top_tiers_gold = [t for t in tier_list if t["rate"] >= 0.5][:5]
top_fail       = [f for f in fail_list if f["fail_rate"] >= 0.7][:5]

def make_golden_box():
    html = '<div class="golden-box"><b>الصفقات الذهبية (نسبة نجاح ≥ 50%):</b><br>'
    if top_tiers_gold:
        for t in top_tiers_gold:
            html += f'<div class="golden-row">{t["cls"]} + {t["test"]} + {t["corr_bkt"]} → <b style="color:#37d67a">{pct(t["success"],t["touched"])}%</b> ({t["touched"]} إشارة, Lift {lift_badge(t["lift"])})</div>'
    else:
        html += '<div style="color:#9fb0c0">لا توجد تركيبات بنسبة ≥ 50%</div>'
    html += '</div>'
    return html

def make_avoid_box():
    html = '<div class="avoid-box"><b>مناطق التجنّب (فشل ≥ 70%):</b><br>'
    if top_fail:
        for f in top_fail:
            html += f'<div class="avoid-row">{f["cls"]} + {f["test"]} + {f["corr_bkt"]} → <b style="color:#ff6b6b">فشل {pct(f["fail"],f["total"])}%</b> ({f["total"]} إشارة)</div>'
    else:
        html += '<div style="color:#9fb0c0">لا توجد مناطق فشل واضحة ≥ 70%</div>'
    html += '</div>'
    return html

# ── Build final HTML ──────────────────────────────────────────────────────────
angle_cards_html    = make_angle_cards()
class_table_html    = make_class_table()
all_tests_html      = make_all_tests_table()
tier_table_html     = make_tier_table(tier_list)
factor_corr_html    = make_factor_table(winner_corr,    "عمق التصحيح")
factor_ratio_html   = make_factor_table(winner_ratio,   "نسبة U1/U2")
factor_lb_html      = make_factor_table(winner_lb,      "نسبة L/B")
factor_test_html    = make_factor_table(winner_test,    "نقطة الاختبار")
factor_session_html = make_factor_table(winner_session, "الجلسة")
factor_class_html   = make_factor_table(winner_class,   "التصنيف")
factor_conf_html    = make_factor_table(winner_confirmed, "حالة التأكيد")
combo_table_html    = make_combo_table()
fail_table_html     = make_fail_table()
trans_matrix_html   = make_transition_matrix()
seq2_table_html     = make_seq2_table()
seq3_table_html     = make_seq3_table()
golden_html         = make_golden_box()
avoid_html          = make_avoid_box()

# ── Best combo single-line summary for the header ────────────────────────────
best_combo = combo_list[0] if combo_list else None
best_combo_str = (f'{best_combo["cls"]} + {best_combo["test"]} + {best_combo["corr_bkt"]} + {best_combo["conf"]}'
                  if best_combo else "—")
best_combo_rate = pct(best_combo["success"], best_combo["touched"]) if best_combo else 0

# ── Summary card stats ────────────────────────────────────────────────────────
confirmed_count = sum(1 for r in rows if str(r.get("Confirmed","0")).strip() in ("1","yes","Yes","TRUE","true"))

HTML = f"""<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<title>تقرير تحليل زوايا EURUSD — شامل</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box;font-family:Arial,Tahoma,sans-serif}}
body{{width:960px;background:#0b1520;color:#e9eef4;padding:30px 32px;margin:0 auto}}
h1{{font-size:26px;color:#4db1ff;text-align:center;margin-bottom:4px}}
h2{{font-size:17px;color:#ffd34d;margin:28px 0 10px;border-right:4px solid #ffd34d;padding-right:9px}}
h3{{font-size:14px;color:#9fb0c0;margin:18px 0 7px}}
.sub{{text-align:center;color:#9fb0c0;font-size:13px;margin:4px 0 20px}}
.stat-row{{display:flex;gap:12px;margin-bottom:14px;flex-wrap:wrap}}
.stat-card{{flex:1;min-width:130px;background:#172533;border-radius:10px;padding:12px 14px}}
.stat-card .t{{font-size:13px;color:#9fb0c0}}.stat-card .v{{font-size:22px;font-weight:bold;margin-top:3px}}
.stat-card .s{{font-size:11px;color:#6f8294}}
table{{width:100%;border-collapse:collapse;margin-top:6px}}
td,th{{padding:8px 10px;font-size:13px;border-bottom:1px solid #1e3244;text-align:right}}
th{{color:#ffd34d;background:#111e2b}}
tr:hover{{background:#1a2e3d}}
.two-col{{display:flex;gap:18px;flex-wrap:wrap}}
.two-col > div{{flex:1;min-width:300px}}
.golden-box{{background:#0a2010;border:1px solid #1c5530;border-radius:10px;padding:14px 16px;margin:12px 0;line-height:2}}
.golden-row{{font-size:13px;margin:3px 0}}
.avoid-box{{background:#200a0a;border:1px solid #552020;border-radius:10px;padding:14px 16px;margin:12px 0;line-height:2}}
.avoid-row{{font-size:13px;margin:3px 0}}
.final-rule{{background:#0e1f30;border:1px solid #245370;border-radius:10px;padding:14px 16px;font-size:14px;margin-top:18px;line-height:2}}
.tag{{display:inline-block;background:#1a2e3d;border-radius:5px;padding:2px 9px;font-size:12px;margin:0 2px}}
/* Angle cards */
.angle-grid{{display:flex;flex-wrap:wrap;gap:14px;margin-top:10px}}
.angle-card{{background:#111e2b;border:1px solid #1e3244;border-radius:10px;padding:12px;width:calc(50% - 7px);min-width:380px}}
.angle-header{{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:6px}}
.angle-id{{color:#6f8294;font-size:12px}}.angle-cls{{font-size:16px;font-weight:bold}}
.angle-dir{{background:#1a2e3d;border-radius:4px;padding:1px 7px;font-size:12px}}
.angle-time{{color:#6f8294;font-size:11px}}
.angle-meta{{display:flex;gap:8px;flex-wrap:wrap;margin:5px 0}}
.badge{{background:#1a2e3d;border-radius:5px;padding:2px 8px;font-size:12px}}
.angle-ctx{{margin:4px 0}}
.test-table td,.test-table th{{font-size:12px;padding:5px 7px}}
.sep{{border-top:2px solid #1e3244;margin:30px 0}}
.foot{{text-align:center;color:#6f8294;font-size:11px;margin-top:22px}}
</style>
</head>
<body>

<h1>تقرير تحليل زوايا AIB — EURUSD H1</h1>
<div class="sub">الفترة: نوفمبر 1999 – ديسمبر 2000 · النجاح = BOUNCE + TP1_Hit=1 · القاعدة العامة = {pct(total_success, total_touched)}%</div>

<!-- ══ 1. Summary Stats ══ -->
<div class="stat-row">
  <div class="stat-card"><div class="t">الزوايا</div><div class="v" style="color:#4db1ff">{N}</div><div class="s">زاوية فريدة</div></div>
  <div class="stat-card"><div class="t">الإشارات الكلية</div><div class="v" style="color:#9fb0c0">{total_signals}</div><div class="s">4 نقاط × {N}</div></div>
  <div class="stat-card"><div class="t">الملموسات</div><div class="v" style="color:#ffd34d">{total_touched}</div><div class="s">{pct(total_touched,total_signals)}% من الكل</div></div>
  <div class="stat-card"><div class="t">النجاحات</div><div class="v" style="color:#37d67a">{total_success}</div><div class="s">BOUNCE+TP1</div></div>
  <div class="stat-card"><div class="t">معدّل النجاح</div><div class="v" style="color:#37d67a">{pct(total_success,total_touched)}%</div><div class="s">Base Rate</div></div>
  <div class="stat-card"><div class="t">المؤكّدات</div><div class="v" style="color:#4db1ff">{confirmed_count}</div><div class="s">{pct(confirmed_count,N)}% من الزوايا</div></div>
  <div class="stat-card"><div class="t">أفضل توليفة</div><div class="v" style="color:#37d67a;font-size:14px">{best_combo_rate}%</div><div class="s">{best_combo_str}</div></div>
</div>

<div class="sep"></div>

<!-- ══ 2. Best Test per Class ══ -->
<h2>أفضل اختبار لكل تصنيف</h2>
{class_table_html}

<h3>جميع الاختبارات لكل تصنيف</h3>
{all_tests_html}

<div class="sep"></div>

<!-- ══ 3. Tier Ranking ══ -->
<h2>تصنيف قوة الدخول — التصنيف × الاختبار × التصحيح</h2>
<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">مرتّبة تنازلياً حسب نسبة النجاح (≥ 2 إشارة لكل تركيبة)</p>
{tier_table_html}

<div class="sep"></div>

<!-- ══ 4. Winner Characteristics ══ -->
<h2>صفات الإشارات الناجحة</h2>
<div class="two-col">
  <div>
    <h3>عمق التصحيح</h3>{factor_corr_html}
    <h3>نقطة الاختبار</h3>{factor_test_html}
    <h3>حالة التأكيد</h3>{factor_conf_html}
  </div>
  <div>
    <h3>نسبة U1/U2</h3>{factor_ratio_html}
    <h3>نسبة L/B</h3>{factor_lb_html}
    <h3>الجلسة</h3>{factor_session_html}
  </div>
</div>
<h3>نسبة النجاح حسب التصنيف</h3>
{factor_class_html}

<div class="sep"></div>

<!-- ══ 5. Golden Trades & Avoid ══ -->
<h2>الصفقات الذهبية ومعايير التجنّب</h2>
{golden_html}
{avoid_html}

<div class="sep"></div>

<!-- ══ 6. Combined Rules ══ -->
<h2>أقوى القوانين المركّبة (Class + Test + Corr + Confirmation)</h2>
{combo_table_html}

<div class="sep"></div>

<!-- ══ 7. Failure Criteria ══ -->
<h2>معايير الفشل — أعلى نسب الفشل</h2>
{fail_table_html}

<div class="sep"></div>

<!-- ══ 8. Transition Matrix ══ -->
<h2>مصفوفة انتقال الزوايا — P(التصنيف التالي | الحالي)</h2>
<p style="color:#9fb0c0;font-size:12px;margin-bottom:8px">النسب المئوية = احتمال الانتقال، الأرقام بين قوسين = عدد مرات الحدوث</p>
{trans_matrix_html}

<div class="sep"></div>

<!-- ══ 9. Sequence Rules ══ -->
<h2>قوانين التسلسل — زاويتان متتاليتان</h2>
{seq2_table_html}

<h2>قوانين التسلسل — ثلاث زوايا متتالية</h2>
{seq3_table_html}

<div class="sep"></div>

<!-- ══ 10. Individual Angle Cards ══ -->
<h2>بطاقات الزوايا التفصيلية ({N} زاوية)</h2>
<div class="angle-grid">
{angle_cards_html}
</div>

<!-- ══ Final Rule ══ -->
<div class="final-rule">
  <b>القانون النهائي:</b> الدخول بأعلى ثقة عند اجتماع:
  <span class="tag">{class_best_sorted[0][0] if class_best_sorted else 'ZD'}</span> +
  <span class="tag">أفضل اختبار</span> +
  <span class="tag">ALPHA عميق ≥62%</span> +
  <span class="tag">L/B صغيرة</span> +
  <span class="tag">جلسة لندن/نيويورك</span> +
  <span class="tag">مؤكّدة</span>
  . التجنّب التام: BETA على DLX1 لتصنيفات {", ".join(sorted(WEAK_CLASSES))}.
</div>

<div class="foot">مستخرج من باك تست EURUSD H1 (1999–2000) · AIB Angles · {datetime.now().strftime('%Y-%m-%d %H:%M')}</div>
</body>
</html>"""

# ─── Save ─────────────────────────────────────────────────────────────────────
out_name = f"تقرير_EURUSD_شامل_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
out_path = os.path.join(OUT_DIR, out_name)
with open(out_path, "w", encoding="utf-8") as f:
    f.write(HTML)

print(f"\n✓ Report saved: {out_path}")
print(f"  Size: {len(HTML):,} chars")
