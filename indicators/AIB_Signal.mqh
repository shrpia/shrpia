//==================================================================
//  AIB_Signal.mqh  v2.0 — Trade zone drawing for AIB Angles
//
//  Include order (end of main .mq4):
//    #include "AIB_ComboTable.mqh"
//    #include "AIB_Monitor.mqh"
//    #include "AIB_Signal.mqh"
//
//  Reads:  g_mon[], g_monCount, g_unitSeconds
//
//  Call from main indicator:
//    OnCalculate():   Sig_OnCalculate();
//    OnDeinit():      Sig_OnDeinit();
//    OnChartEvent():  Sig_OnChartEvent(id,lparam,dparam,sparam);
//
//  Features:
//    • InpSigMinHitPct — filter threshold (input, default 50%)
//    • Weak combos: panel warning only, no zone drawn
//    • Anticipatory drawing: preview at formTime (dashed), real zone at touchTime
//    • Anti-overlap: same-angle tests staggered horizontally by ti×unit/5
//    • Duration scaled by g_unitSeconds/86400 (studies on U86400)
//    • Rating stars: ⭐⭐⭐ ≥65%  ⭐⭐ ≥50%  ⚠ ≥35%  ✗ <35%
//    • Professional signal panel (top-right, screen-anchored)
//    • 4 buttons: Hide All | Show All | Hide Zone | Pick Angle
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep          = "──── AIB Signal ────";
input bool   InpSigEnabled      = true;
input double InpSigMinHitPct    = 50.0;   // min TP1 hit% to draw zone
input bool   InpSigFilterBest   = false;  // also require n_ang≥30 & p_total≥40%
input bool   InpSigShowHistory  = true;   // draw completed (past) signals
input bool   InpSigShowPending  = true;   // draw live / pending signals
input bool   InpSigShowPreview  = true;   // draw anticipatory preview (formTime)
input bool   InpSigFill         = true;   // fill rectangles
input double InpSigRiskMoney    = 50.0;   // risk $ per trade
input int    InpSigSpreadPts    = 20;     // spread in points
input int    InpSigTP1Pct       = 50;
input int    InpSigTP2Pct       = 30;
input int    InpSigTP3Pct       = 20;
input bool   InpSigAlerts       = true;
input int    InpSigFontSize     = 8;
input bool   InpSigShowPanel    = true;   // show signal panel

//─── Prefix & panel constants ──────────────────────────────────────
#define SIG_PFX     "AIBSIG_"
#define PANEL_W     390
#define PANEL_X     8
#define PANEL_Y     30
#define PANEL_CORN  CORNER_RIGHT_UPPER
#define ROW_H       17
#define BTN_H       22
#define BTN_W       88

//─── Global state ──────────────────────────────────────────────────
bool     g_sigHideAll   = false;
bool     g_sigPickHide  = false;   // pick-to-hide mode
bool     g_sigPickShow  = false;   // pick-to-show-angle mode

bool     g_sigHide[1024][4];
bool     g_sigHideInit  = false;

datetime g_sigAlertTs[1024][4];
datetime g_sigMultiTs[1024];
bool     g_sigAlertInit = false;

//══════════════════════════════════════════════════════════════════
//  Color helpers
//══════════════════════════════════════════════════════════════════
color Sig_Blend(color base, color mix, int pct)
{
   pct = MathMax(0, MathMin(100, pct));
   int b = (((int)base)&255)*(100-pct)/100 + (((int)mix)&255)*pct/100;
   int g = ((((int)base)>>8)&255)*(100-pct)/100 + ((((int)mix)>>8)&255)*pct/100;
   int r = ((((int)base)>>16)&255)*(100-pct)/100 + ((((int)mix)>>16)&255)*pct/100;
   return (color)(b|(g<<8)|(r<<16));
}
color Sig_ColEntry()  { return clrDeepSkyBlue; }
color Sig_ColSL()     { return Sig_Blend(clrTomato,    clrBlack, 45); }
color Sig_ColTP1()    { return Sig_Blend(clrLimeGreen, clrBlack, 25); }
color Sig_ColTP2()    { return Sig_Blend(clrLimeGreen, clrBlack, 45); }
color Sig_ColTP3()    { return Sig_Blend(clrLimeGreen, clrBlack, 60); }
color Sig_ColHit()    { return Sig_Blend(clrAqua,      clrBlack, 20); }
color Sig_ColFail()   { return Sig_Blend(clrRed,       clrBlack, 15); }
color Sig_ColPend()   { return clrGold; }
color Sig_ColGood()   { return clrLimeGreen; }
color Sig_ColBad()    { return clrTomato; }
color Sig_ColPrev()   { return (color)C'60,55,20'; }  // dark gold for preview bg

//══════════════════════════════════════════════════════════════════
//  Rating helpers
//══════════════════════════════════════════════════════════════════
string Sig_Rating(double p1)
{
   if(p1 >= 65.0) return "***";
   if(p1 >= 50.0) return "** ";
   if(p1 >= 35.0) return "~  ";
   return "x  ";
}
color Sig_RatingColor(double p1)
{
   if(p1 >= 65.0) return clrLimeGreen;
   if(p1 >= 50.0) return clrYellow;
   if(p1 >= 35.0) return clrOrange;
   return clrTomato;
}
bool Sig_IsStrong(double p1) { return (p1 >= InpSigMinHitPct); }

//══════════════════════════════════════════════════════════════════
//  Duration scaling  (studies on U86400; scale to current unit)
//══════════════════════════════════════════════════════════════════
double Sig_ScaleDur(double hours)
{
   if(g_unitSeconds <= 0) return hours;
   return hours * (g_unitSeconds / 86400.0);
}

//══════════════════════════════════════════════════════════════════
//  Object naming
//══════════════════════════════════════════════════════════════════
string Sig_N(int ai, int ti, const string tag)
{
   return SIG_PFX + IntegerToString(ai) + "_" + IntegerToString(ti) + "_" + tag;
}
string Sig_PN(const string tag) { return SIG_PFX + "PANEL_" + tag; }
string Sig_BN(const string tag) { return SIG_PFX + "BTN_"   + tag; }

//══════════════════════════════════════════════════════════════════
//  Primitive drawing
//══════════════════════════════════════════════════════════════════
void Sig_DelObj(const string nm)
{
   if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
}

void Sig_Rect(const string nm, datetime t1, double p1, datetime t2, double p2,
              color c, bool fill, int style=STYLE_SOLID)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, nm, OBJPROP_TIME1,  t1);
   ObjectSetDouble (0, nm, OBJPROP_PRICE1, p1);
   ObjectSetInteger(0, nm, OBJPROP_TIME2,  t2);
   ObjectSetDouble (0, nm, OBJPROP_PRICE2, p2);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,  c);
   ObjectSetInteger(0, nm, OBJPROP_STYLE,  style);
   ObjectSetInteger(0, nm, OBJPROP_FILL,   fill);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH,  1);
   ObjectSetInteger(0, nm, OBJPROP_BACK,   false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN,      false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES,  OBJ_ALL_PERIODS);
}

void Sig_HLine(const string nm, datetime t1, datetime t2, double price, color c, int w=1)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, nm, OBJPROP_TIME1,  t1);
   ObjectSetDouble (0, nm, OBJPROP_PRICE1, price);
   ObjectSetInteger(0, nm, OBJPROP_TIME2,  t2);
   ObjectSetDouble (0, nm, OBJPROP_PRICE2, price);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,  c);
   ObjectSetInteger(0, nm, OBJPROP_STYLE,  STYLE_SOLID);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH,  w);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT,   false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES,  OBJ_ALL_PERIODS);
}

void Sig_Text(const string nm, datetime t, double p, const string txt, color c, int sz, int anchor)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_TEXT, 0, t, p);
   ObjectSetInteger(0, nm, OBJPROP_TIME1,   t);
   ObjectSetDouble (0, nm, OBJPROP_PRICE1,  p);
   ObjectSetString (0, nm, OBJPROP_TEXT,    txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,   c);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,sz);
   ObjectSetString (0, nm, OBJPROP_FONT,   "Consolas");
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR,  anchor);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES,  OBJ_ALL_PERIODS);
}

void Sig_RLabel(const string nm, datetime t, double p, const string txt, color c)
{
   Sig_Text(nm, t, p, txt, c, InpSigFontSize, ANCHOR_LEFT);
}

void Sig_CLabel(const string nm, datetime t, double p, const string txt, color c)
{
   Sig_Text(nm, t, p, txt, c, InpSigFontSize+1, ANCHOR_CENTER);
}

//─── Screen-anchored label (panel) ─────────────────────────────────
void Sig_SLabel(const string nm, int x, int y, const string txt, color c,
                int sz, int corner, int anchor=ANCHOR_LEFT_UPPER)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER,    corner);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetString (0, nm, OBJPROP_TEXT,      txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,     c);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,  sz);
   ObjectSetString (0, nm, OBJPROP_FONT,     "Consolas");
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR,    anchor);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, nm, OBJPROP_BACK,      false);
}

void Sig_SRect(const string nm, int x, int y, int w, int h, color c, int corner)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER,    corner);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, nm, OBJPROP_YSIZE,     h);
   ObjectSetInteger(0, nm, OBJPROP_BGCOLOR,   c);
   ObjectSetInteger(0, nm, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,     Sig_Blend(c, clrSilver, 30));
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, nm, OBJPROP_BACK,      false);
}

void Sig_SBtn(const string nm, int x, int y, int w, int h,
              const string txt, color bg, color tc, int corner, bool pressed=false)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER,    corner);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, nm, OBJPROP_YSIZE,     h);
   ObjectSetString (0, nm, OBJPROP_TEXT,      txt);
   ObjectSetInteger(0, nm, OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,     tc);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,  8);
   ObjectSetString (0, nm, OBJPROP_FONT,     "Consolas");
   ObjectSetInteger(0, nm, OBJPROP_STATE,     pressed);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, nm, OBJPROP_BACK,      false);
}

//══════════════════════════════════════════════════════════════════
//  Zone cleanup
//══════════════════════════════════════════════════════════════════
void Sig_DeleteZone(int ai, int ti)
{
   string tags[] = {"SL","TP1","TP2","TP3","ELINE","LBL_E","LBL_SL","LBL_T1","LBL_T2","LBL_T3","INFO",
                    "PREV_SL","PREV_TP","PREV_INFO"};
   for(int i=0; i<ArraySize(tags); i++) Sig_DelObj(Sig_N(ai,ti,tags[i]));
}

//══════════════════════════════════════════════════════════════════
//  Domain helpers
//══════════════════════════════════════════════════════════════════
string Sig_TestName(int ti)
{
   switch(ti) {
      case 0: return "U1X1";
      case 1: return "U2X1";
      case 2: return "DLX1";
      case 3: return "DRX1";
   }
   return "???";
}

double Sig_PipSz()
{
   int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
   return (d==3||d==5) ? Point*10.0 : Point;
}

string Sig_PrevClsLtr(int ai)
{
   datetime best = 0;
   int bestAi = -1;
   for(int i=0; i<g_monCount; i++) {
      if(i==ai || !g_mon[i].valid) continue;
      if(g_mon[i].formTime < g_mon[ai].formTime && g_mon[i].formTime > best) {
         best = g_mon[i].formTime;
         bestAi = i;
      }
   }
   if(bestAi < 0) return "X";
   string c = g_mon[bestAi].cls;
   return (StringLen(c) >= 2 ? StringSubstr(c,1,1) : "X");
}

double Sig_Lots(double entry, double slPrice, int pct)
{
   if(pct <= 0) return 0.0;
   double spd  = InpSigSpreadPts * Point;
   double dist = MathAbs(entry - slPrice) + spd;
   if(dist <= 0.0) return 0.0;
   double tkSz  = MarketInfo(Symbol(), MODE_TICKSIZE);  if(tkSz<=0) tkSz=Point;
   double tkVal = MarketInfo(Symbol(), MODE_TICKVALUE); if(tkVal<=0) return 0.0;
   double lossPerLot = (dist/tkSz)*tkVal;
   if(lossPerLot<=0) return 0.0;
   double lots = (InpSigRiskMoney * pct / 100.0) / lossPerLot;
   double step = MarketInfo(Symbol(), MODE_LOTSTEP); if(step<=0) step=0.01;
   lots = MathFloor(lots/step)*step;
   double mn = MarketInfo(Symbol(), MODE_MINLOT);
   double mx = MarketInfo(Symbol(), MODE_MAXLOT);
   return NormalizeDouble(MathMax(mn, MathMin(mx, lots)), 2);
}

double Sig_LossUSD(double entry, double slPrice, double lots)
{
   double spd  = InpSigSpreadPts * Point;
   double dist = MathAbs(entry - slPrice) + spd;
   double tkSz  = MarketInfo(Symbol(), MODE_TICKSIZE);  if(tkSz<=0) tkSz=Point;
   double tkVal = MarketInfo(Symbol(), MODE_TICKVALUE); if(tkVal<=0) return 0.0;
   return lots * (dist/tkSz) * tkVal;
}

//══════════════════════════════════════════════════════════════════
//  Zone visibility check (respects hide flags + global toggle)
//══════════════════════════════════════════════════════════════════
bool Sig_IsVisible(int ai, int ti)
{
   if(g_sigHideAll) return false;
   if(ai < 1024 && ti < 4 && g_sigHide[ai][ti]) return false;
   return true;
}

//══════════════════════════════════════════════════════════════════
//  Anti-overlap: time offset for same-angle tests
//══════════════════════════════════════════════════════════════════
datetime Sig_ZoneStart(datetime base, int ti)
{
   // Stagger each test by ti × 1/5 unit so they don't stack on the same pixel column
   int step = g_unitSeconds / 5;
   return base + (datetime)(ti * step);
}

//══════════════════════════════════════════════════════════════════
//  Draw one complete trade zone (actual touch)
//══════════════════════════════════════════════════════════════════
bool Sig_DrawZone(int ai, int ti, int cidx, string code, double p1val, bool isStrong)
{
   int react = g_mon[ai].test[ti].react[0];
   bool isPending = (react == MON_REACT_PENDING);
   bool bounced   = (react == MON_REACT_BOUNCE);
   bool broke     = (react == MON_REACT_BREAK);

   if(isPending && !InpSigShowPending)  return false;
   if(!isPending && !InpSigShowHistory) return false;

   double away   = g_mon[ai].test[ti].away;
   double anchor = g_mon[ai].test[ti].anchor;
   double L      = g_mon[ai].L;
   double B      = g_mon[ai].B;
   double entry  = anchor + L * away;
   double sl     = entry  + B * away;
   double tp1    = g_mon[ai].test[ti].tp[0];
   double tp2    = g_mon[ai].test[ti].tp[1];
   int    nTP    = g_mon[ai].test[ti].nTP;
   double tp3    = (nTP >= 3 ? g_mon[ai].test[ti].tp[2] : 0.0);

   datetime touchT = g_mon[ai].test[ti].touchTime;
   datetime tL = Sig_ZoneStart(touchT, ti);
   datetime tR = tL + (datetime)g_unitSeconds;

   //── Colors ──────────────────────────────────────────────────────
   color cSL = broke ? Sig_ColFail() : Sig_ColSL();
   if(bounced) cSL = Sig_Blend(cSL, clrBlack, 35);

   bool h1 = g_mon[ai].test[ti].tpHit[0];
   bool h2 = g_mon[ai].test[ti].tpHit[1];
   bool h3 = g_mon[ai].test[ti].tpHit[2];
   color cTP1 = h1 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP1(),clrBlack,55) : Sig_ColTP1());
   color cTP2 = h2 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP2(),clrBlack,55) : Sig_ColTP2());
   color cTP3 = h3 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP3(),clrBlack,55) : Sig_ColTP3());

   //── Rectangles ──────────────────────────────────────────────────
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL, entry, tR, sl,  cSL,  InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL, entry, tR, tp1, cTP1, InpSigFill);
   if(tp2 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP2"), tL, entry, tR, tp2, cTP2, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP3"), tL, entry, tR, tp3, cTP3, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP3"));

   Sig_HLine(Sig_N(ai,ti,"ELINE"), tL, tR, entry, Sig_ColEntry(), 2);

   //── Labels (right edge → text runs rightward) ───────────────────
   double lots1   = Sig_Lots(entry, sl, InpSigTP1Pct);
   double lots2   = Sig_Lots(entry, sl, InpSigTP2Pct);
   double lots3   = Sig_Lots(entry, sl, InpSigTP3Pct);
   double lossUSD = Sig_LossUSD(entry, sl, lots1+lots2+lots3);
   double pip     = Sig_PipSz();
   double slPips  = (pip>0 ? MathAbs(entry-sl)/pip : 0);

   Sig_RLabel(Sig_N(ai,ti,"LBL_E"), tR, entry,
      StringFormat("Entry %s  [%.2f+%.2f+%.2f]L", DoubleToString(entry,Digits), lots1, lots2, lots3),
      Sig_ColEntry());

   Sig_RLabel(Sig_N(ai,ti,"LBL_SL"), tR, sl,
      StringFormat("SL %s  -$%.0f  %.0fp", DoubleToString(sl,Digits), lossUSD, slPips), cSL);

   double d1s = Sig_ScaleDur(cidx>=0 ? g_combos[cidx].d1[ti] : 0.0);
   Sig_RLabel(Sig_N(ai,ti,"LBL_T1"), tR, tp1,
      StringFormat("TP1 %s  %.0f%%  %s%s", DoubleToString(tp1,Digits),
                   p1val, ComboDurStr(d1s), h1?" v":""), cTP1);

   if(tp2 != 0.0) {
      double p2v = (cidx>=0 ? g_combos[cidx].p2[ti] : 0.0);
      double d2s = Sig_ScaleDur(cidx>=0 ? g_combos[cidx].d2[ti] : 0.0);
      Sig_RLabel(Sig_N(ai,ti,"LBL_T2"), tR, tp2,
         StringFormat("TP2 %s  %.0f%%*  %s%s", DoubleToString(tp2,Digits),
                      p2v, ComboDurStr(d2s), h2?" v":""), cTP2);
   } else Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));

   if(tp3 != 0.0) {
      double p3v = (cidx>=0 ? g_combos[cidx].p3[ti] : 0.0);
      double d3s = Sig_ScaleDur(cidx>=0 ? g_combos[cidx].d3[ti] : 0.0);
      Sig_RLabel(Sig_N(ai,ti,"LBL_T3"), tR, tp3,
         StringFormat("TP3 %s  %.0f%%*  %s%s", DoubleToString(tp3,Digits),
                      p3v, ComboDurStr(d3s), h3?" v":""), cTP3);
   } else Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));

   //── Center info label ───────────────────────────────────────────
   string rat   = Sig_Rating(p1val);
   color  ratC  = Sig_RatingColor(p1val);
   string statS = isPending ? "PENDING" : (bounced ? "BOUNCE v" : "BREAK x");
   color  statC = isPending ? Sig_ColPend() : (bounced ? Sig_ColGood() : Sig_ColBad());
   double midP  = (entry + (broke ? sl : tp1)) / 2.0;
   datetime midT = tL + (datetime)((tR-tL)/2);
   string line2 = (cidx>=0)
      ? StringFormat("%s | %s: %.0f%%  n=%d", Sig_TestName(ti), rat, p1val, g_combos[cidx].n_ang)
      : StringFormat("%s | %s: n/a", Sig_TestName(ti), rat);

   Sig_CLabel(Sig_N(ai,ti,"INFO"), midT, midP,
              code + "  " + statS + "\n" + line2, statC);

   return true;
}

//══════════════════════════════════════════════════════════════════
//  Draw anticipatory preview zone (before touch — at formTime)
//══════════════════════════════════════════════════════════════════
void Sig_DrawPreview(int ai, int ti, int cidx, string code, double p1val)
{
   if(!InpSigShowPreview) { Sig_DelObj(Sig_N(ai,ti,"PREV_SL")); Sig_DelObj(Sig_N(ai,ti,"PREV_TP")); Sig_DelObj(Sig_N(ai,ti,"PREV_INFO")); return; }

   double away   = g_mon[ai].test[ti].away;
   double anchor = g_mon[ai].test[ti].anchor;
   double L      = g_mon[ai].L;
   double B      = g_mon[ai].B;
   double entry  = anchor + L * away;
   double sl     = entry  + B * away;
   double tp1    = g_mon[ai].test[ti].tp[0];

   // Position at formTime, staggered
   datetime tL = Sig_ZoneStart(g_mon[ai].formTime, ti);
   datetime tR = tL + (datetime)g_unitSeconds;

   // Use dashed style + dimmer colors to distinguish from real zones
   color cPrev = Sig_ColPrev();
   color cGr   = Sig_Blend(Sig_ColTP1(), clrBlack, 60);

   Sig_Rect(Sig_N(ai,ti,"PREV_SL"), tL, entry, tR, sl,  cPrev, false, STYLE_DASH);
   Sig_Rect(Sig_N(ai,ti,"PREV_TP"), tL, entry, tR, tp1, cGr,   false, STYLE_DASH);

   double midP  = (entry + tp1) / 2.0;
   datetime midT = tL + (datetime)((tR-tL)/2);
   string line2 = (cidx>=0)
      ? StringFormat("%s | %.0f%%  n=%d", Sig_TestName(ti), p1val, g_combos[cidx].n_ang)
      : StringFormat("%s", Sig_TestName(ti));

   Sig_CLabel(Sig_N(ai,ti,"PREV_INFO"), midT, midP,
              code + "  [PREVIEW]\n" + line2, Sig_ColPend());
}

//══════════════════════════════════════════════════════════════════
//  Alert logic
//══════════════════════════════════════════════════════════════════
void Sig_InitAlerts()
{
   if(g_sigAlertInit) return;
   ArrayInitialize(g_sigAlertTs, 0);
   ArrayInitialize(g_sigMultiTs, 0);
   g_sigAlertInit = true;
}

void Sig_CheckTouchAlert(int ai, int ti, string code)
{
   if(!InpSigAlerts || ai>=1024) return;
   datetime touchT = g_mon[ai].test[ti].touchTime;
   if(touchT<=0 || g_sigAlertTs[ai][ti]==touchT) return;
   int react = g_mon[ai].test[ti].react[0];
   if(react == MON_REACT_PENDING) {
      g_sigAlertTs[ai][ti] = touchT;
      double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * g_mon[ai].test[ti].away;
      string dir   = (g_mon[ai].dir>0 ? "BUY" : "SELL");
      Alert(StringFormat("AIB Signal: %s %s @ %s  [%s | %s]",
                         dir, g_mon[ai].cls, DoubleToString(entry,Digits),
                         Sig_TestName(ti), code));
   } else {
      g_sigAlertTs[ai][ti] = touchT;
   }
}

void Sig_CheckMultiAlert(int ai)
{
   if(!InpSigAlerts || ai>=1024) return;
   if(g_sigMultiTs[ai]==g_mon[ai].formTime) return;
   int active = 0;
   for(int ti=0; ti<MON_NPTS; ti++)
      if(g_mon[ai].test[ti].react[0]==MON_REACT_PENDING) active++;
   if(active >= 2) {
      g_sigMultiTs[ai] = g_mon[ai].formTime;
      Alert(StringFormat("AIB Signal: %d tests ACTIVE for %s %s",
                         active, g_mon[ai].cls, (g_mon[ai].dir>0?"BUY":"SELL")));
   }
}

//══════════════════════════════════════════════════════════════════
//  Signal Panel — professional screen-anchored overlay
//══════════════════════════════════════════════════════════════════

struct SigEntry {
   int    ai, ti;
   string code, testName, dir, rating, status;
   double p1val;
   color  rcolor, scolor;
   bool   isWeak, isPending, isPreview;
   int    nAng;
};

void Sig_DeletePanel()
{
   int tot = ObjectsTotal();
   for(int i=tot-1; i>=0; i--) {
      string nm = ObjectName(i);
      if(StringFind(nm, SIG_PFX+"PANEL_", 0)==0 || StringFind(nm, SIG_PFX+"BTN_", 0)==0)
         ObjectDelete(0, nm);
   }
}

void Sig_DrawPanel(SigEntry &entries[], int eCount, int weakCount)
{
   if(!InpSigShowPanel) { Sig_DeletePanel(); return; }

   int strongCount = eCount - weakCount;

   // Compute panel height
   int headerH   = 28;
   int sepH      = 8;
   int btnRowH   = BTN_H + 6;
   int totalRows = eCount + (weakCount>0 ? 1 : 0);
   int bodyH     = totalRows * ROW_H + 4;
   int totalH    = headerH + sepH + bodyH + sepH + btnRowH + 4;
   if(totalH < 80) totalH = 80;

   // Background
   Sig_SRect(Sig_PN("BG"), PANEL_X, PANEL_Y, PANEL_W, totalH,
             (color)C'18,22,36', PANEL_CORN);

   // Header bar
   Sig_SRect(Sig_PN("HDR"), PANEL_X, PANEL_Y, PANEL_W, headerH,
             (color)C'30,45,80', PANEL_CORN);

   string hdrTxt = StringFormat("AIB Signal  |  %d strong  %d weak",
                                 strongCount, weakCount);
   int hX = PANEL_X + PANEL_W - 6;
   int hY = PANEL_Y + 8;
   Sig_SLabel(Sig_PN("TITLE"), hX, hY, hdrTxt,
              (color)C'180,210,255', 10, PANEL_CORN, ANCHOR_RIGHT_UPPER);

   // Mode indicator
   string modeStr = "";
   color  modeCol = clrSilver;
   if(g_sigPickHide) { modeStr = " [PICK: click zone to HIDE]";   modeCol = clrOrange; }
   if(g_sigPickShow) { modeStr = " [PICK: click chart to SHOW]";  modeCol = clrYellow; }
   if(g_sigHideAll)  { modeStr = " [ALL HIDDEN]";                 modeCol = clrTomato; }
   if(StringLen(modeStr) > 0)
      Sig_SLabel(Sig_PN("MODE"), hX, hY+13, modeStr, modeCol, 8, PANEL_CORN, ANCHOR_RIGHT_UPPER);
   else
      Sig_DelObj(Sig_PN("MODE"));

   // Signal rows
   int rowY = PANEL_Y + headerH + sepH;
   int rX   = PANEL_X + PANEL_W - 6;
   for(int i=0; i<eCount; i++) {
      string rowNm = Sig_PN("ROW" + IntegerToString(i));
      string rowTxt;
      color  rowCol;
      if(entries[i].isPreview) {
         rowTxt = StringFormat("%-5s  %-4s  %-4s  PREVIEW  %.0f%%  n=%d",
                               entries[i].code, entries[i].dir, entries[i].testName,
                               entries[i].p1val, entries[i].nAng);
         rowCol = (color)C'100,90,30';
      } else if(entries[i].isWeak) {
         rowTxt = StringFormat("%-5s  %-4s  %-4s  WEAK  %.0f%%  n=%d",
                               entries[i].code, entries[i].dir, entries[i].testName,
                               entries[i].p1val, entries[i].nAng);
         rowCol = (color)C'80,40,40';
      } else {
         string hideMark = (entries[i].ai<1024 && entries[i].ti<4 && g_sigHide[entries[i].ai][entries[i].ti]) ? " [H]" : "";
         rowTxt = StringFormat("%s  %-5s  %-4s  %-4s  %-8s  %.0f%%  n=%d%s",
                               entries[i].rating, entries[i].code, entries[i].dir,
                               entries[i].testName, entries[i].status,
                               entries[i].p1val, entries[i].nAng, hideMark);
         rowCol = entries[i].rcolor;
      }
      Sig_SLabel(rowNm, rX, rowY + i*ROW_H, rowTxt, rowCol, 8, PANEL_CORN, ANCHOR_RIGHT_UPPER);
   }

   // Separator before weak-count summary
   if(weakCount > 0) {
      string sumTxt = StringFormat("--- %d weak signal(s) suppressed (< %.0f%%) ---",
                                   weakCount, InpSigMinHitPct);
      Sig_SLabel(Sig_PN("WEAK"), rX, rowY + eCount*ROW_H,
                 sumTxt, (color)C'90,60,60', 8, PANEL_CORN, ANCHOR_RIGHT_UPPER);
   } else {
      Sig_DelObj(Sig_PN("WEAK"));
   }

   // Button row
   int btnY = PANEL_Y + totalH - btnRowH;
   int bW   = BTN_W;
   int gap  = 4;
   // Buttons are right-aligned; positions from right edge going left
   // [Hide All] [Show All] [Hide Zone] [Pick Angle]
   int b4X = PANEL_X;
   int b3X = b4X + bW + gap;
   int b2X = b3X + bW + gap;
   int b1X = b2X + bW + gap;

   color cBtnNorm  = (color)C'40,55,90';
   color cBtnAct   = (color)C'90,55,20';
   color cBtnDanger= (color)C'80,25,25';

   Sig_SBtn(Sig_BN("HIDEALL"),  b1X, btnY, bW, BTN_H, "Hide All",
            g_sigHideAll ? cBtnDanger : cBtnNorm, clrWhite, PANEL_CORN);
   Sig_SBtn(Sig_BN("SHOWALL"),  b2X, btnY, bW, BTN_H, "Show All",
            cBtnNorm, clrWhite, PANEL_CORN);
   Sig_SBtn(Sig_BN("PICKHIDE"), b3X, btnY, bW, BTN_H, "Hide Zone",
            g_sigPickHide ? cBtnAct : cBtnNorm, g_sigPickHide ? clrYellow : clrWhite, PANEL_CORN);
   Sig_SBtn(Sig_BN("PICKSHOW"), b4X, btnY, bW, BTN_H, "Pick Angle",
            g_sigPickShow ? cBtnAct : cBtnNorm, g_sigPickShow ? clrYellow : clrWhite, PANEL_CORN);
}

//══════════════════════════════════════════════════════════════════
//  Button state check (call each tick — no OnChartEvent needed
//  for Hide All / Show All; pick modes finalized in OnChartEvent)
//══════════════════════════════════════════════════════════════════
void Sig_CheckButtons()
{
   // Hide All
   if(ObjectFind(0, Sig_BN("HIDEALL")) >= 0 &&
      ObjectGetInteger(0, Sig_BN("HIDEALL"), OBJPROP_STATE)) {
      g_sigHideAll = !g_sigHideAll;
      if(g_sigHideAll) { g_sigPickHide = false; g_sigPickShow = false; }
      ObjectSetInteger(0, Sig_BN("HIDEALL"), OBJPROP_STATE, false);
      ChartRedraw(0);
   }
   // Show All
   if(ObjectFind(0, Sig_BN("SHOWALL")) >= 0 &&
      ObjectGetInteger(0, Sig_BN("SHOWALL"), OBJPROP_STATE)) {
      g_sigHideAll = false;
      if(g_sigHideInit)
         ArrayInitialize(g_sigHide, false);
      g_sigPickHide = false;
      g_sigPickShow = false;
      ObjectSetInteger(0, Sig_BN("SHOWALL"), OBJPROP_STATE, false);
      ChartRedraw(0);
   }
   // Hide Zone pick mode toggle
   if(ObjectFind(0, Sig_BN("PICKHIDE")) >= 0 &&
      ObjectGetInteger(0, Sig_BN("PICKHIDE"), OBJPROP_STATE)) {
      g_sigPickHide = !g_sigPickHide;
      if(g_sigPickHide) g_sigPickShow = false;
      ObjectSetInteger(0, Sig_BN("PICKHIDE"), OBJPROP_STATE, false);
      ChartRedraw(0);
   }
   // Pick Angle mode toggle
   if(ObjectFind(0, Sig_BN("PICKSHOW")) >= 0 &&
      ObjectGetInteger(0, Sig_BN("PICKSHOW"), OBJPROP_STATE)) {
      g_sigPickShow = !g_sigPickShow;
      if(g_sigPickShow) g_sigPickHide = false;
      ObjectSetInteger(0, Sig_BN("PICKSHOW"), OBJPROP_STATE, false);
      ChartRedraw(0);
   }
}

//══════════════════════════════════════════════════════════════════
//  Parse ai/ti from object name (format: AIBSIG_<ai>_<ti>_<tag>)
//══════════════════════════════════════════════════════════════════
bool Sig_ParseName(const string nm, int &ai, int &ti)
{
   if(StringFind(nm, SIG_PFX, 0) != 0) return false;
   string rest = StringSubstr(nm, StringLen(SIG_PFX));
   int p1 = StringFind(rest, "_", 0);
   if(p1 < 0) return false;
   int p2 = StringFind(rest, "_", p1+1);
   if(p2 < 0) return false;
   ai = (int)StringToInteger(StringSubstr(rest, 0, p1));
   ti = (int)StringToInteger(StringSubstr(rest, p1+1, p2-p1-1));
   return (ai >= 0 && ai < 1024 && ti >= 0 && ti < 4);
}

//══════════════════════════════════════════════════════════════════
//  OnChartEvent hook — handles pick-mode interactions
//══════════════════════════════════════════════════════════════════
void Sig_OnChartEvent(const int id, const long lparam,
                      const double dparam, const string sparam)
{
   if(!InpSigEnabled) return;

   if(id == CHARTEVENT_OBJECT_CLICK) {
      // Ignore our own buttons (handled in Sig_CheckButtons via OBJPROP_STATE)
      if(StringFind(sparam, SIG_PFX+"BTN_", 0) == 0) return;

      // "Hide Zone" pick mode: clicking on any AIBSIG_ zone object hides it
      if(g_sigPickHide && StringFind(sparam, SIG_PFX, 0) == 0) {
         int ai=-1, ti=-1;
         if(Sig_ParseName(sparam, ai, ti)) {
            if(!g_sigHideInit) { ArrayInitialize(g_sigHide, false); g_sigHideInit=true; }
            g_sigHide[ai][ti] = true;
            Sig_DeleteZone(ai, ti);
            g_sigPickHide = false;
            ChartRedraw(0);
         }
         return;
      }
   }

   // "Pick Angle" mode: CHARTEVENT_CLICK — find nearest angle by time
   if(id == CHARTEVENT_CLICK && g_sigPickShow) {
      int x = (int)lparam;
      int y = (int)dparam;
      datetime clickT = 0; double clickP = 0.0; int subwin = 0;
      if(!ChartXYToTimePrice(0, x, y, subwin, clickT, clickP)) return;

      // Find angle whose formTime is closest to click time
      int bestAi  = -1;
      long bestDt = LONG_MAX;
      for(int i=0; i<g_monCount; i++) {
         if(!g_mon[i].valid) continue;
         long dt = MathAbs((long)g_mon[i].formTime - (long)clickT);
         if(dt < bestDt) { bestDt = dt; bestAi = i; }
      }

      if(bestAi >= 0) {
         // Show only this angle's zones; hide all others
         if(!g_sigHideInit) { ArrayInitialize(g_sigHide, false); g_sigHideInit=true; }
         for(int i=0; i<g_monCount && i<1024; i++)
            for(int ti=0; ti<4; ti++)
               g_sigHide[i][ti] = (i != bestAi);
         g_sigHideAll  = false;
         g_sigPickShow = false;
         ChartRedraw(0);
      }
      return;
   }
}

//══════════════════════════════════════════════════════════════════
//  Main entry:  Sig_OnCalculate()
//══════════════════════════════════════════════════════════════════
void Sig_OnCalculate()
{
   if(!InpSigEnabled) return;
   if(!g_sigHideInit) { ArrayInitialize(g_sigHide, false); g_sigHideInit=true; }
   ComboTable_Init();
   Sig_InitAlerts();
   Sig_CheckButtons();

   // Build signal entry list for panel
   SigEntry entries[]; int eCount = 0; int weakCount = 0;
   ArrayResize(entries, g_monCount * MON_NPTS);

   for(int ai=0; ai<g_monCount; ai++) {
      if(!g_mon[ai].valid) continue;

      string cls  = g_mon[ai].cls;
      string dir  = (g_mon[ai].dir > 0 ? "BUY" : "SELL");
      double rat  = g_mon[ai].ratio;
      double lu1  = (g_mon[ai].u1R > 1e-10 ? g_mon[ai].L/g_mon[ai].u1R*100.0 : 0.0);
      string prev = Sig_PrevClsLtr(ai);
      string code = ComboCode(cls, dir, rat, lu1, prev);
      int    cidx = ComboFind(code);

      if(InpSigFilterBest && !ComboIsBest(cidx)) {
         for(int ti=0; ti<MON_NPTS; ti++) Sig_DeleteZone(ai, ti);
         continue;
      }

      Sig_CheckMultiAlert(ai);

      for(int ti=0; ti<MON_NPTS; ti++) {
         int react = g_mon[ai].test[ti].react[0];
         if(react == MON_REACT_NA) { Sig_DeleteZone(ai, ti); continue; }

         double p1val = (cidx>=0 ? g_combos[cidx].p1[ti] : 0.0);
         bool   strong = Sig_IsStrong(p1val);

         // Anticipatory preview (UNTOUCHED = never reached price yet)
         if(react == MON_REACT_UNTOUCHED) {
            if(strong)
               Sig_DrawPreview(ai, ti, cidx, code, p1val);
            else {
               Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
               Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
               Sig_DelObj(Sig_N(ai,ti,"PREV_INFO"));
            }
            Sig_DeleteZone(ai, ti);   // make sure no stale real zone exists

            if(cidx >= 0) {
               SigEntry e;
               e.ai=ai; e.ti=ti; e.code=code; e.testName=Sig_TestName(ti);
               e.dir=dir; e.rating=Sig_Rating(p1val); e.status="PREVIEW";
               e.p1val=p1val; e.rcolor=Sig_RatingColor(p1val);
               e.scolor=Sig_ColPend(); e.isWeak=!strong; e.isPending=false;
               e.isPreview=true; e.nAng=(cidx>=0?g_combos[cidx].n_ang:0);
               entries[eCount++] = e;
               if(!strong) weakCount++;
            }
            continue;
         }

         // Real zone (touched)
         datetime touchT = g_mon[ai].test[ti].touchTime;
         if(touchT <= 0) { Sig_DeleteZone(ai, ti); continue; }

         // Remove preview objects now that price has touched
         Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_INFO"));

         Sig_CheckTouchAlert(ai, ti, code);

         if(!strong) {
            Sig_DeleteZone(ai, ti);
            weakCount++;
            if(cidx >= 0) {
               SigEntry e;
               e.ai=ai; e.ti=ti; e.code=code; e.testName=Sig_TestName(ti);
               e.dir=dir; e.rating=Sig_Rating(p1val); e.status="WEAK";
               e.p1val=p1val; e.rcolor=(color)C'90,50,50';
               e.scolor=clrTomato; e.isWeak=true; e.isPending=false;
               e.isPreview=false; e.nAng=(cidx>=0?g_combos[cidx].n_ang:0);
               entries[eCount++] = e;
            }
            continue;
         }

         // Visibility check
         bool visible = Sig_IsVisible(ai, ti);
         if(!visible) { Sig_DeleteZone(ai, ti); }
         else {
            bool hist   = (react==MON_REACT_BOUNCE || react==MON_REACT_BREAK);
            bool isPend = (react==MON_REACT_PENDING);
            if(isPend && !InpSigShowPending)  { Sig_DeleteZone(ai,ti); }
            else if(hist && !InpSigShowHistory) { Sig_DeleteZone(ai,ti); }
            else Sig_DrawZone(ai, ti, cidx, code, p1val, strong);
         }

         // Panel entry
         if(cidx >= 0) {
            string statStr;
            color  statCol;
            if(react==MON_REACT_PENDING) { statStr="PENDING"; statCol=Sig_ColPend(); }
            else if(react==MON_REACT_BOUNCE) { statStr="BOUNCE v"; statCol=Sig_ColGood(); }
            else { statStr="BREAK x"; statCol=Sig_ColBad(); }

            SigEntry e;
            e.ai=ai; e.ti=ti; e.code=code; e.testName=Sig_TestName(ti);
            e.dir=dir; e.rating=Sig_Rating(p1val); e.status=statStr;
            e.p1val=p1val; e.rcolor=Sig_RatingColor(p1val);
            e.scolor=statCol; e.isWeak=false; e.isPending=(react==MON_REACT_PENDING);
            e.isPreview=false; e.nAng=g_combos[cidx].n_ang;
            entries[eCount++] = e;
         }
      }
   }

   // Sort panel entries: strong first (by p1 desc), then weak
   for(int i=0; i<eCount-1; i++)
      for(int j=i+1; j<eCount; j++)
         if((!entries[i].isWeak && entries[j].isWeak) ? false :
            (entries[i].isWeak && !entries[j].isWeak) ? true :
            (entries[i].p1val < entries[j].p1val)) {
            SigEntry tmp = entries[i]; entries[i] = entries[j]; entries[j] = tmp;
         }

   // Draw panel
   Sig_DrawPanel(entries, eCount, weakCount);
   ChartRedraw(0);
}

//══════════════════════════════════════════════════════════════════
//  Deinit — remove all objects
//══════════════════════════════════════════════════════════════════
void Sig_OnDeinit()
{
   int tot = ObjectsTotal();
   for(int i=tot-1; i>=0; i--) {
      string nm = ObjectName(i);
      if(StringFind(nm, SIG_PFX, 0) == 0)
         ObjectDelete(0, nm);
   }
}
