//==================================================================
//  AIB_Signal.mqh  — Trade zone drawing for AIB Angles indicator
//
//  Include order in main indicator (.mq4):
//    #include "AIB_ComboTable.mqh"
//    #include "AIB_Monitor.mqh"
//    #include "AIB_Signal.mqh"
//
//  Reads from:
//    g_mon[]         (MonAngle array, defined in AIB_Monitor.mqh)
//    g_monCount      (int)
//    g_unitSeconds   (int, seconds per unit — 86400 for daily)
//
//  Visual style mirrors OTE DRAW (OTEV7.mq4):
//    - 1 SL rectangle  (darkened red)
//    - 1-3 TP rectangles (stacked, darkened green, lighter = closer)
//    - Entry horizontal line (deep sky blue)
//    - Price labels on RIGHT side of rectangles
//    - COMBO CODE + hit-rate in center info label
//    - Rectangle width = g_unitSeconds (one trading unit)
//
//  Spread handling:
//    - For SELL (away=+1): SL sits above entry → risk = B + spread
//    - For BUY  (away=-1): SL sits below entry → risk = B + spread
//    - Spread adds only to LOT CALCULATION, not to displayed SL price
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep          = "──── AIB Signal ────";
input bool   InpSigEnabled      = true;
input bool   InpSigFilterBest   = false;   // only n_ang≥30 & p_total≥40%
input bool   InpSigShowHistory  = true;    // draw completed (past) signals
input bool   InpSigShowPending  = true;    // draw live / pending signals
input bool   InpSigFill         = true;    // fill rectangles
input double InpSigRiskMoney    = 50.0;    // risk $ per trade
input int    InpSigSpreadPts    = 20;      // spread in points (added to risk distance)
input int    InpSigTP1Pct       = 50;      // lot % allocated to TP1
input int    InpSigTP2Pct       = 30;      // lot % allocated to TP2
input int    InpSigTP3Pct       = 20;      // lot % allocated to TP3
input bool   InpSigAlerts       = true;    // popup alert on new touch
input int    InpSigFontSize     = 8;       // label font size

//─── Object prefix ─────────────────────────────────────────────────
#define SIG_PFX  "AIBSIG_"

//─── Alert tracking (global arrays, not static locals) ─────────────
datetime g_sigAlertTs[1024][4];
datetime g_sigMultiTs[1024];
bool     g_sigAlertInit = false;

//══════════════════════════════════════════════════════════════════
//  Color helpers (self-contained — no dependency on OTE DRAW)
//══════════════════════════════════════════════════════════════════
color Sig_Blend(color base, color mix, int mixPct)
{
   mixPct = MathMax(0, MathMin(100, mixPct));
   int b  = (((int)base)&255)*(100-mixPct)/100 + (((int)mix)&255)*mixPct/100;
   int g  = ((((int)base)>>8)&255)*(100-mixPct)/100 + ((((int)mix)>>8)&255)*mixPct/100;
   int r  = ((((int)base)>>16)&255)*(100-mixPct)/100 + ((((int)mix)>>16)&255)*mixPct/100;
   return (color)(b|(g<<8)|(r<<16));
}

color Sig_ColEntry()  { return clrDeepSkyBlue; }
color Sig_ColSL()     { return Sig_Blend(clrTomato,    clrBlack, 45); }
color Sig_ColTP1()    { return Sig_Blend(clrLimeGreen, clrBlack, 35); }  // brightest
color Sig_ColTP2()    { return Sig_Blend(clrLimeGreen, clrBlack, 50); }
color Sig_ColTP3()    { return Sig_Blend(clrLimeGreen, clrBlack, 62); }  // darkest
color Sig_ColHit()    { return Sig_Blend(clrAqua,      clrBlack, 25); }  // TP hit (cyan)
color Sig_ColFail()   { return Sig_Blend(clrRed,       clrBlack, 15); }  // SL hit
color Sig_ColPend()   { return clrGold; }
color Sig_ColGood()   { return clrLimeGreen; }
color Sig_ColBad()    { return clrTomato; }

//══════════════════════════════════════════════════════════════════
//  Object naming
//══════════════════════════════════════════════════════════════════
string Sig_N(int ai, int ti, const string tag)
{
   return SIG_PFX + IntegerToString(ai) + "_" + IntegerToString(ti) + "_" + tag;
}

//══════════════════════════════════════════════════════════════════
//  Primitive drawing helpers
//══════════════════════════════════════════════════════════════════
void Sig_DelObj(const string nm)
{
   if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
}

void Sig_Rect(const string nm, datetime t1, double p1, datetime t2, double p2, color c, bool fill)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, nm, OBJPROP_TIME1,  t1);
   ObjectSetDouble (0, nm, OBJPROP_PRICE1, p1);
   ObjectSetInteger(0, nm, OBJPROP_TIME2,  t2);
   ObjectSetDouble (0, nm, OBJPROP_PRICE2, p2);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,  c);
   ObjectSetInteger(0, nm, OBJPROP_FILL,   fill);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH,  1);
   ObjectSetInteger(0, nm, OBJPROP_BACK,   false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
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
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

void Sig_Text(const string nm, datetime t, double p, const string txt, color c, int sz, int anchor)
{
   if(ObjectFind(0, nm) < 0) ObjectCreate(0, nm, OBJ_TEXT, 0, t, p);
   ObjectSetInteger(0, nm, OBJPROP_TIME1,  t);
   ObjectSetDouble (0, nm, OBJPROP_PRICE1, p);
   ObjectSetString (0, nm, OBJPROP_TEXT,   txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,  c);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, sz);
   ObjectSetString (0, nm, OBJPROP_FONT,  "Consolas");
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, nm, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

// Helper: label anchored to LEFT (appears to the right of the price point)
void Sig_RLabel(const string nm, datetime t, double p, const string txt, color c)
{
   Sig_Text(nm, t, p, txt, c, InpSigFontSize, ANCHOR_LEFT);
}

// Helper: label anchored to CENTER
void Sig_CLabel(const string nm, datetime t, double p, const string txt, color c)
{
   Sig_Text(nm, t, p, txt, c, InpSigFontSize+1, ANCHOR_CENTER);
}

//══════════════════════════════════════════════════════════════════
//  Zone cleanup
//══════════════════════════════════════════════════════════════════
void Sig_DeleteZone(int ai, int ti)
{
   Sig_DelObj(Sig_N(ai,ti,"SL"));
   Sig_DelObj(Sig_N(ai,ti,"TP1"));
   Sig_DelObj(Sig_N(ai,ti,"TP2"));
   Sig_DelObj(Sig_N(ai,ti,"TP3"));
   Sig_DelObj(Sig_N(ai,ti,"ELINE"));
   Sig_DelObj(Sig_N(ai,ti,"LBL_E"));
   Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
   Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));
   Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
   Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
   Sig_DelObj(Sig_N(ai,ti,"INFO"));
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

// Pip size that accounts for 3/5 digit brokers
double Sig_PipSz()
{
   int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
   double pt = Point;
   return (d==3||d==5) ? pt*10.0 : pt;
}

// Find the class letter of the latest angle that formed BEFORE g_mon[ai]
string Sig_PrevClsLtr(int ai)
{
   datetime best = 0;
   int bestAi = -1;
   for(int i = 0; i < g_monCount; i++) {
      if(i==ai || !g_mon[i].valid) continue;
      if(g_mon[i].formTime < g_mon[ai].formTime && g_mon[i].formTime > best) {
         best = g_mon[i].formTime;
         bestAi = i;
      }
   }
   if(bestAi < 0) return "X";
   string c = g_mon[bestAi].cls;          // e.g. "ZB"
   return (StringLen(c) >= 2 ? StringSubstr(c,1,1) : "X");
}

// Calculate lot size for one TP tranche (pct% of total risk capital)
double Sig_Lots(double entry, double slPrice, int pct)
{
   if(pct <= 0) return 0.0;
   double spd  = InpSigSpreadPts * Point;
   double dist = MathAbs(entry - slPrice) + spd;
   if(dist <= 0.0) return 0.0;
   double tkSz  = MarketInfo(Symbol(), MODE_TICKSIZE);
   double tkVal = MarketInfo(Symbol(), MODE_TICKVALUE);
   if(tkSz<=0.0) tkSz = Point;
   if(tkVal<=0.0) return 0.0;
   double lossPerLot = (dist/tkSz)*tkVal;
   if(lossPerLot<=0.0) return 0.0;
   double portLots = (InpSigRiskMoney * pct / 100.0) / lossPerLot;
   double step = MarketInfo(Symbol(), MODE_LOTSTEP); if(step<=0.0) step=0.01;
   portLots = MathFloor(portLots/step)*step;
   double mn = MarketInfo(Symbol(), MODE_MINLOT);
   double mx = MarketInfo(Symbol(), MODE_MAXLOT);
   return NormalizeDouble(MathMax(mn, MathMin(mx, portLots)), 2);
}

double Sig_LossUSD(double entry, double slPrice, double lots)
{
   double spd  = InpSigSpreadPts * Point;
   double dist = MathAbs(entry - slPrice) + spd;
   double tkSz  = MarketInfo(Symbol(), MODE_TICKSIZE); if(tkSz<=0.0) tkSz=Point;
   double tkVal = MarketInfo(Symbol(), MODE_TICKVALUE); if(tkVal<=0.0) return 0.0;
   return lots * (dist/tkSz) * tkVal;
}

//══════════════════════════════════════════════════════════════════
//  Draw one complete trade zone for angle ai, test point ti
//══════════════════════════════════════════════════════════════════
bool Sig_DrawZone(int ai, int ti)
{
   if(ai<0||ai>=g_monCount||ti<0||ti>=MON_NPTS) return false;
   if(!g_mon[ai].valid) return false;

   datetime touchT = g_mon[ai].test[ti].touchTime;
   if(touchT <= 0) return false;                         // never touched

   int react = g_mon[ai].test[ti].react[0];
   if(react==MON_REACT_UNTOUCHED || react==MON_REACT_NA) {
      Sig_DeleteZone(ai, ti);
      return false;
   }

   bool isPending = (react == MON_REACT_PENDING);
   bool bounced   = (react == MON_REACT_BOUNCE);
   bool broke     = (react == MON_REACT_BREAK);

   if(isPending && !InpSigShowPending)  { Sig_DeleteZone(ai,ti); return false; }
   if(!isPending && !InpSigShowHistory) { Sig_DeleteZone(ai,ti); return false; }

   //── Geometry ──────────────────────────────────────────────────
   double away   = g_mon[ai].test[ti].away;
   double anchor = g_mon[ai].test[ti].anchor;
   double L      = g_mon[ai].L;
   double B      = g_mon[ai].B;
   double entry  = anchor + L * away;         // level = anchor + 1×L×away
   double sl     = entry  + B * away;         // SL sits B beyond the entry level
   double tp1    = g_mon[ai].test[ti].tp[0];
   double tp2    = g_mon[ai].test[ti].tp[1];
   int    nTP    = g_mon[ai].test[ti].nTP;
   double tp3    = (nTP >= 3 ? g_mon[ai].test[ti].tp[2] : 0.0);

   datetime tL = touchT;
   datetime tR = touchT + (datetime)g_unitSeconds;    // one unit wide

   //── Combo lookup ──────────────────────────────────────────────
   string cls  = g_mon[ai].cls;
   string dir  = (g_mon[ai].dir > 0 ? "BUY" : "SELL");
   double rat  = g_mon[ai].ratio;
   double lu1  = (g_mon[ai].u1R > 1e-10 ? g_mon[ai].L/g_mon[ai].u1R*100.0 : 0.0);
   string prev = Sig_PrevClsLtr(ai);
   string code = ComboCode(cls, dir, rat, lu1, prev);
   int    cidx = ComboFind(code);

   if(InpSigFilterBest && !ComboIsBest(cidx)) {
      Sig_DeleteZone(ai, ti);
      return false;
   }

   //── Color selection ───────────────────────────────────────────
   // SL rectangle: brighter on BREAK (SL was hit), dimmed on BOUNCE
   color cSL = broke ? Sig_ColFail() : Sig_ColSL();
   if(bounced) cSL = Sig_Blend(cSL, clrBlack, 35);   // dim SL on success

   // TP rectangles: standard unless TP was hit (cyan) or broke (dim)
   bool h1 = g_mon[ai].test[ti].tpHit[0];
   bool h2 = g_mon[ai].test[ti].tpHit[1];
   bool h3 = g_mon[ai].test[ti].tpHit[2];
   color cTP1 = h1 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP1(),clrBlack,55) : Sig_ColTP1());
   color cTP2 = h2 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP2(),clrBlack,55) : Sig_ColTP2());
   color cTP3 = h3 ? Sig_ColHit() : (broke ? Sig_Blend(Sig_ColTP3(),clrBlack,55) : Sig_ColTP3());

   //── Rectangles ────────────────────────────────────────────────
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL, entry, tR, sl,  cSL,  InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL, entry, tR, tp1, cTP1, InpSigFill);
   if(tp2 != 0.0)
      Sig_Rect(Sig_N(ai,ti,"TP2"), tL, entry, tR, tp2, cTP2, InpSigFill);
   else
      Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3 != 0.0)
      Sig_Rect(Sig_N(ai,ti,"TP3"), tL, entry, tR, tp3, cTP3, InpSigFill);
   else
      Sig_DelObj(Sig_N(ai,ti,"TP3"));

   // Entry line (horizontal, spans full width)
   Sig_HLine(Sig_N(ai,ti,"ELINE"), tL, tR, entry, Sig_ColEntry(), 2);

   //── Lot calculations ──────────────────────────────────────────
   double lots1   = Sig_Lots(entry, sl, InpSigTP1Pct);
   double lots2   = Sig_Lots(entry, sl, InpSigTP2Pct);
   double lots3   = Sig_Lots(entry, sl, InpSigTP3Pct);
   double lossUSD = Sig_LossUSD(entry, sl, lots1+lots2+lots3);
   double pip     = Sig_PipSz();
   double slPips  = (pip>0 ? MathAbs(entry-sl)/pip : 0);

   //── Price labels (right edge of rect, anchored LEFT → text runs right) ──
   // Entry label  — "Entry 1.23456 | [0.03+0.02+0.02]"
   Sig_RLabel(Sig_N(ai,ti,"LBL_E"), tR, entry,
              StringFormat("Entry %s  [%.2f+%.2f+%.2f]L",
                           DoubleToString(entry,Digits), lots1, lots2, lots3),
              Sig_ColEntry());

   // SL label  — "SL 1.23400  -$50  45p"
   Sig_RLabel(Sig_N(ai,ti,"LBL_SL"), tR, sl,
              StringFormat("SL %s  -$%.0f  %.0fp",
                           DoubleToString(sl,Digits), lossUSD, slPips),
              cSL);

   // TP1 label  — "TP1 1.23560  42%  2.1d"
   double p1   = (cidx>=0 ? g_combos[cidx].p1[ti] : 0.0);
   double d1   = (cidx>=0 ? g_combos[cidx].d1[ti] : 0.0);
   string h1s  = (h1 ? " ✓" : "");
   Sig_RLabel(Sig_N(ai,ti,"LBL_T1"), tR, tp1,
              StringFormat("TP1 %s  %.0f%%  %s%s",
                           DoubleToString(tp1,Digits), p1, ComboDurStr(d1), h1s),
              cTP1);

   // TP2 label
   if(tp2 != 0.0) {
      double p2 = (cidx>=0 ? g_combos[cidx].p2[ti] : 0.0);
      double d2 = (cidx>=0 ? g_combos[cidx].d2[ti] : 0.0);
      string h2s = (h2 ? " ✓" : "");
      Sig_RLabel(Sig_N(ai,ti,"LBL_T2"), tR, tp2,
                 StringFormat("TP2 %s  %.0f%%*  %s%s",
                              DoubleToString(tp2,Digits), p2, ComboDurStr(d2), h2s),
                 cTP2);
   } else Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));

   // TP3 label
   if(tp3 != 0.0) {
      double p3 = (cidx>=0 ? g_combos[cidx].p3[ti] : 0.0);
      double d3 = (cidx>=0 ? g_combos[cidx].d3[ti] : 0.0);
      string h3s = (h3 ? " ✓" : "");
      Sig_RLabel(Sig_N(ai,ti,"LBL_T3"), tR, tp3,
                 StringFormat("TP3 %s  %.0f%%*  %s%s",
                              DoubleToString(tp3,Digits), p3, ComboDurStr(d3), h3s),
                 cTP3);
   } else Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));

   //── Center info label (combo code + outcome) ──────────────────
   // Vertical center between entry and TP1 (or SL if broke)
   double midP  = (entry + (broke ? sl : tp1)) / 2.0;
   datetime midT = tL + (datetime)((tR - tL) / 2);

   string statusStr = isPending ? "⟳" : (bounced ? "✓ BOUNCE" : "✗ BREAK");
   color  statusCol = isPending ? Sig_ColPend() : (bounced ? Sig_ColGood() : Sig_ColBad());

   string infoLine2 = (cidx>=0)
      ? StringFormat("%s: %.0f%%  n=%d", Sig_TestName(ti), p1, g_combos[cidx].n_ang)
      : StringFormat("%s: n/a", Sig_TestName(ti));

   Sig_CLabel(Sig_N(ai,ti,"INFO"), midT, midP,
              code + " | " + statusStr + "\n" + infoLine2,
              statusCol);

   return true;
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

void Sig_CheckNewTouchAlert(int ai, int ti)
{
   if(!InpSigAlerts || ai>=1024) return;
   datetime touchT = g_mon[ai].test[ti].touchTime;
   if(touchT <= 0) return;
   if(g_sigAlertTs[ai][ti] == touchT) return;  // already alerted for this touch
   int react = g_mon[ai].test[ti].react[0];
   if(react==MON_REACT_UNTOUCHED||react==MON_REACT_NA||react==MON_REACT_PENDING) {
      // alert on first pending touch
      if(react == MON_REACT_PENDING) {
         g_sigAlertTs[ai][ti] = touchT;
         double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * g_mon[ai].test[ti].away;
         string prev  = Sig_PrevClsLtr(ai);
         string dir   = (g_mon[ai].dir>0 ? "BUY" : "SELL");
         string code  = ComboCode(g_mon[ai].cls, dir, g_mon[ai].ratio,
                                   (g_mon[ai].u1R>1e-10?g_mon[ai].L/g_mon[ai].u1R*100.0:0.0),
                                   prev);
         Alert(StringFormat("AIB Signal: %s %s @ %s  [%s | %s]",
                            dir, g_mon[ai].cls,
                            DoubleToString(entry, Digits),
                            Sig_TestName(ti), code));
      }
   } else {
      g_sigAlertTs[ai][ti] = touchT;   // mark even on resolved (no duplicate)
   }
}

void Sig_CheckMultiAlert(int ai)
{
   if(!InpSigAlerts || ai>=1024) return;
   if(g_sigMultiTs[ai] == g_mon[ai].formTime) return;
   int active = 0;
   for(int ti=0; ti<MON_NPTS; ti++)
      if(g_mon[ai].test[ti].react[0]==MON_REACT_PENDING) active++;
   if(active >= 2) {
      g_sigMultiTs[ai] = g_mon[ai].formTime;
      Alert(StringFormat("AIB Signal: %d tests ACTIVE for %s %s — watch all!",
                         active, g_mon[ai].cls, (g_mon[ai].dir>0?"BUY":"SELL")));
   }
}

//══════════════════════════════════════════════════════════════════
//  Main entry points — call from indicator lifecycle
//══════════════════════════════════════════════════════════════════

// Call from OnCalculate()
void Sig_OnCalculate()
{
   if(!InpSigEnabled) return;
   ComboTable_Init();
   Sig_InitAlerts();

   for(int ai = 0; ai < g_monCount; ai++) {
      if(!g_mon[ai].valid) continue;
      Sig_CheckMultiAlert(ai);
      for(int ti = 0; ti < MON_NPTS; ti++) {
         Sig_CheckNewTouchAlert(ai, ti);
         Sig_DrawZone(ai, ti);
      }
   }
}

// Call from OnDeinit()
void Sig_OnDeinit()
{
   int total = ObjectsTotal();
   for(int i = total-1; i >= 0; i--) {
      string nm = ObjectName(i);
      if(StringFind(nm, SIG_PFX, 0) == 0)
         ObjectDelete(0, nm);
   }
}
