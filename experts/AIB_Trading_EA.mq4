//+------------------------------------------------------------------+
//|  AIB_Trading_EA.mq4  — Auto-trading EA built on AIB Angles      |
//|                                                                  |
//|  Place all 3 files in the SAME folder:                          |
//|    AIB_Trading_EA.mq4   (MQL4/Experts)                          |
//|    AIB_ComboTable.mqh   (copy here from Indicators)             |
//|    AIB_Monitor.mqh      (copy here from Indicators)             |
//|                                                                  |
//|  Works as standalone EA — do NOT attach the indicator too.       |
//+------------------------------------------------------------------+
#property strict

//── Inputs ───────────────────────────────────────────────────────────
input string   InpEASep1          = "═══ Angle Detection ═══";
input int      InpEAUnitSeconds   = 86400;   // Unit size in seconds (86400=Daily)
input int      InpEAUnitsToScan   = 120;     // How many units to scan back
input double   InpEACorrMin       = 0.292;   // Min correction ratio (not used in engine but kept)
input double   InpEACorrMax       = 0.618;   // Max correction ratio
input int      InpTouchTolerancePoints = 2;  // Touch tolerance (points)

input string   InpEASep2          = "═══ Signal Filter ════";
input double   InpEAMinHitPct     = 50.0;    // Min TP1 hit% to enter trade
input int      InpEAMinTouchCount = 30;      // Min historical touches nt[ti]
input int      InpEAMinSuccessCount = 15;    // Min historical wins   nok[ti]
input int      InpEAMaxTestsPerAngle = 2;    // Max top-ranked tests to trade per angle
input bool     InpEAOnlyBestCombo = false;   // Also require n_ang>=30 & p_total>=40%

input string   InpEASep3          = "═══ Risk Management ═══";
input double   InpEARiskMoney     = 50.0;    // Risk $ per trade (full position)
input int      InpEASpreadPts     = 20;      // Broker spread in points
input int      InpEATP1ClosePct   = 50;      // % of position to close at TP1
input int      InpEATP2ClosePct   = 40;      // % of position to close at TP2
                                              // Remaining % targets TP3 (if exists)
input int      InpEASlippage      = 3;       // Max slippage in points

input string   InpEASep4          = "═══ Report ═══════════";
input string   InpEAReportPrefix  = "AIB_EA"; // Report file prefix

//── Compatibility globals (read by included AIB_Monitor.mqh) ─────────
int    g_unitSeconds          = 86400;  // set from input in OnInit
bool   InpShowUnconfirmedAngles = false; // EA only trades confirmed angles

//══════════════════════════════════════════════════════════════════════
//  STRUCT DEFINITIONS  (copies from AIB_Angles_V535 main indicator)
//══════════════════════════════════════════════════════════════════════
struct UnitInfo
{
   datetime start, end;
   double   hi, lo;
   datetime hiTime, loTime;
   double   firstOpen, lastClose;
   double   level0, level23, level38, level61, level76, level100;
   double   levelNeg61, level161;
   int      shiftStart, shiftEnd, id;
   bool     processedSequentially, valid;
};

struct AngleResult
{
   bool     valid, confirmed, unconfirmed, candidateBuy, candidateSell;
   string   angleName, angleDisplayText, classText;
   int      dirState, u1Id, u2Id;
   datetime u1Start, u2Start, u1End, u2End;
   double   u1High, u1Low, u2High, u2Low;
   double   correctionPct, correctionValue;
   color    u1LegColor, u2LegColor;
   datetime drawT1, drawT2;
   double   drawP1, drawP2;
};

struct DirectionCheckResult  { int state; };
struct RangeCheckResult      { int state; };
struct OrderCheckResult      { int state; };
struct CloseCheckResult      { int state; };
struct RetestCheckResult     { bool state; };
struct ExtensionCheckResult  { bool reached161; bool reachedNeg61; };

struct SupervisorFacts
{
   DirectionCheckResult dir;
   RangeCheckResult     range;
   OrderCheckResult     order;
   CloseCheckResult     close;
   RetestCheckResult    retest;
   ExtensionCheckResult ext;
};

struct PairScanInfo
{
   bool     hasBreakUp, hasBreakDown;
   datetime firstBreakUpTime, firstBreakDownTime;
   bool     hasRetestUp, hasRetestDown;
   bool     reached161, reachedNeg61;
};

//── Includes (must come AFTER struct definitions) ────────────────────
#include "AIB_ComboTable.mqh"
#include "AIB_Monitor.mqh"

//══════════════════════════════════════════════════════════════════════
//  EA TRADE TRACKING
//══════════════════════════════════════════════════════════════════════
struct EATrade
{
   int    ai, ti;
   int    ticket1, ticket2, ticket3;  // MT4 order tickets (-1 = not placed)
   bool   beApplied;                  // SL moved to entry after TP1
   string code;                       // 5-char combo code
   double entryPrice;
   double slPrice;
   bool   fullyDone;                  // all tickets closed
};

EATrade g_eaTrades[];
int     g_eaTradeCount = 0;

//── Per-combo statistics for final report ────────────────────────────
struct ComboStat
{
   string code;
   int    total;
   int    slHit;
   int    tp1Only;
   int    tp12;
   int    tp123;
   double pnlTotal;
};

ComboStat g_comboStats[];
int       g_comboStatCount = 0;

//── Scan state ───────────────────────────────────────────────────────
bool     g_eaInited     = false;
datetime g_lastScanBar  = 0;

//══════════════════════════════════════════════════════════════════════
//  ANGLE ENGINE — extracted from AIB_Angles_V535 main indicator
//══════════════════════════════════════════════════════════════════════
int ShiftAtOrAfter(datetime t)
{
   int s = iBarShift(Symbol(), Period(), t, false);
   if(s < 0) return(-1);
   while(s > 0 && iTime(Symbol(), Period(), s) < t) s--;
   return(s);
}
int ShiftBefore(datetime t)
{
   int s = iBarShift(Symbol(), Period(), t, false);
   if(s < 0) return(-1);
   if(iTime(Symbol(), Period(), s) == t) s++;
   return(s);
}

bool BuildUnit(datetime start, datetime end, UnitInfo &u)
{
   u.start = start; u.end = end; u.valid = false;
   u.hiTime = 0; u.loTime = 0; u.firstOpen = 0; u.lastClose = 0;
   u.processedSequentially = false;

   int shOldest = ShiftAtOrAfter(start);
   int shNewest = ShiftBefore(end);
   if(shOldest < 0 || shNewest < 0) return(false);
   if(shOldest < shNewest) return(false);

   double hi = -1e100, lo = 1e100;
   for(int s = shNewest; s <= shOldest; s++) {
      datetime bt = iTime(Symbol(), Period(), s);
      if(bt < start || bt >= end) continue;
      double h = iHigh(Symbol(), Period(), s);
      double l = iLow (Symbol(), Period(), s);
      if(h > hi) { hi = h; u.hiTime = bt; }
      if(l < lo) { lo = l; u.loTime = bt; }
   }
   if(hi <= -1e90 || lo >= 1e90) return(false);

   u.hi = hi; u.lo = lo;
   u.firstOpen  = iOpen (Symbol(), Period(), shOldest);
   u.lastClose  = iClose(Symbol(), Period(), shNewest);
   double R = hi - lo;
   u.level0     = lo;
   u.level23    = lo + 0.236 * R;
   u.level38    = lo + 0.382 * R;
   u.level61    = lo + 0.618 * R;
   u.level76    = lo + 0.764 * R;
   u.level100   = hi;
   u.levelNeg61 = lo - 0.618 * R;
   u.level161   = lo + 1.618 * R;
   u.shiftStart = shOldest;
   u.shiftEnd   = shNewest;
   u.id         = (int)start;
   u.valid      = true;
   return(true);
}

datetime FloorTimeToUnit(datetime t, int sec)
{
   if(sec <= 0) return t;
   if(sec < 86400) {
      int sh = iBarShift(Symbol(), PERIOD_D1, t, true);
      datetime ds = (sh >= 0 ? iTime(Symbol(), PERIOD_D1, sh) : 0);
      if(ds <= 0) ds = t - (t % 86400);
      int delta = int(t - ds); if(delta < 0) delta = 0;
      return ds + (delta / sec) * sec;
   }
   if(sec < 604800) {
      int k = MathMax(1, sec / 86400);
      int sh = iBarShift(Symbol(), PERIOD_D1, t, true);
      datetime ds = (sh >= 0 ? iTime(Symbol(), PERIOD_D1, sh) : 0);
      if(ds <= 0) ds = t - (t % 86400);
      long dn = long(ds / 86400);
      return datetime((dn - (dn % k)) * 86400);
   }
   int kW = MathMax(1, sec / 604800);
   int shW = iBarShift(Symbol(), PERIOD_W1, t, true);
   datetime ws = (shW >= 0 ? iTime(Symbol(), PERIOD_W1, shW) : 0);
   if(ws <= 0) ws = t - (t % 604800);
   long wn = long(ws / 604800);
   return datetime((wn - (wn % kW)) * 604800);
}

double CalcCorrectionPercent(UnitInfo &refU, UnitInfo &formU, const DirectionCheckResult &dir)
{
   double span = MathAbs(refU.hi - refU.lo);
   if(span <= 0.0) return(0.0);
   if(dir.state ==  1) return(100.0 * (formU.lo - refU.lo) / span);
   if(dir.state == -1) return(100.0 * (refU.hi - formU.hi) / span);
   return(0.0);
}

CloseCheckResult RunCloseChecker(UnitInfo &refU, UnitInfo &formU)
{
   CloseCheckResult r; r.state = 99;
   double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point * 0.2;
   if     (formU.lastClose > refU.hi + tol) r.state =  1;
   else if(formU.lastClose < refU.lo - tol) r.state = -1;
   else r.state = 0;
   return(r);
}

DirectionCheckResult RunDirectionChecker(UnitInfo &refU, UnitInfo &formU)
{
   DirectionCheckResult r; r.state = 0;
   double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point * 0.2;
   bool bull = (formU.hi > refU.hi + tol && formU.lo > refU.lo + tol);
   bool bear = (formU.hi < refU.hi - tol && formU.lo < refU.lo - tol);
   if(bull) r.state =  1;
   else if(bear) r.state = -1;
   return(r);
}

RangeCheckResult RunRangeChecker(UnitInfo &refU, UnitInfo &formU, const DirectionCheckResult &dir)
{
   RangeCheckResult r; r.state = 0;
   double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point * 0.2;
   if(dir.state == 1) {
      if(formU.lo >= refU.level38 - tol && formU.lo <= refU.level76 + tol) r.state = 1;
      else if(formU.lo > refU.level0 + tol && formU.lo < refU.level38 - tol) r.state = 2;
   } else if(dir.state == -1) {
      if(formU.hi > refU.level23 + tol && formU.hi <= refU.level61 + tol) r.state = 1;
      else if(formU.hi > refU.level61 + tol && formU.hi < refU.level100 - tol) r.state = 2;
   }
   return(r);
}

bool ScanPairInfo(UnitInfo &refU, UnitInfo &formU, PairScanInfo &ps)
{
   ps.hasBreakUp = ps.hasBreakDown = false;
   ps.firstBreakUpTime = ps.firstBreakDownTime = 0;
   ps.hasRetestUp = ps.hasRetestDown = false;
   ps.reached161 = ps.reachedNeg61 = false;

   int sh1 = iBarShift(Symbol(), Period(), formU.start, false);
   int sh2 = iBarShift(Symbol(), Period(), formU.end,   false);
   if(sh1 < 0 || sh2 < 0) return(false);
   int fromS = MathMin(sh1, sh2), toS = MathMax(sh1, sh2);
   bool bUpSeen = false, bDnSeen = false;

   for(int s = toS; s >= fromS; s--) {
      datetime bt = iTime(Symbol(), Period(), s);
      double bh = iHigh(Symbol(), Period(), s);
      double bl = iLow (Symbol(), Period(), s);
      if(!bUpSeen && bh > refU.hi) { ps.hasBreakUp = true; ps.firstBreakUpTime = bt; bUpSeen = true; }
      if(!bDnSeen && bl < refU.lo) { ps.hasBreakDown = true; ps.firstBreakDownTime = bt; bDnSeen = true; }
      if(bUpSeen && bl <= refU.hi && bh >= refU.lo) ps.hasRetestUp = true;
      if(bDnSeen && bl <= refU.hi && bh >= refU.lo) ps.hasRetestDown = true;
      if(bh >= refU.level161)   ps.reached161 = true;
      if(bl <= refU.levelNeg61) ps.reachedNeg61 = true;
   }
   return(true);
}

OrderCheckResult RunOrderChecker(UnitInfo &refU, UnitInfo &formU,
                                  const DirectionCheckResult &dir, const PairScanInfo &ps)
{
   OrderCheckResult r; r.state = 0;
   if(dir.state == 1) {
      if(ps.hasBreakUp && formU.loTime > 0) {
         if(ps.firstBreakUpTime < formU.loTime)  r.state = 1;
         else if(formU.loTime < ps.firstBreakUpTime) r.state = 2;
      }
   } else if(dir.state == -1) {
      if(ps.hasBreakDown && formU.hiTime > 0) {
         if(ps.firstBreakDownTime < formU.hiTime)  r.state = 1;
         else if(formU.hiTime < ps.firstBreakDownTime) r.state = 2;
      }
   }
   return(r);
}

RetestCheckResult RunRetestChecker(const DirectionCheckResult &dir, const PairScanInfo &ps)
{
   RetestCheckResult r; r.state = false;
   if(dir.state ==  1) r.state = ps.hasRetestUp;
   if(dir.state == -1) r.state = ps.hasRetestDown;
   return(r);
}

ExtensionCheckResult RunExtensionChecker(const DirectionCheckResult &dir, const PairScanInfo &ps)
{
   ExtensionCheckResult r;
   r.reached161   = (dir.state ==  1 && ps.reached161);
   r.reachedNeg61 = (dir.state == -1 && ps.reachedNeg61);
   return(r);
}

int GetExtensionState(const ExtensionCheckResult &ext, int dirState)
{
   if(dirState ==  1 && ext.reached161)   return(1);
   if(dirState == -1 && ext.reachedNeg61) return(-1);
   return(0);
}

bool BuildSupervisorFacts(UnitInfo &refU, UnitInfo &formU, SupervisorFacts &f)
{
   f.dir = RunDirectionChecker(refU, formU);
   if(f.dir.state == 0) return(false);
   f.range = RunRangeChecker(refU, formU, f.dir);
   if(f.range.state == 0) return(false);
   f.close = RunCloseChecker(refU, formU);
   if(f.close.state == 99) return(false);
   PairScanInfo ps;
   if(!ScanPairInfo(refU, formU, ps)) return(false);
   f.order = RunOrderChecker(refU, formU, f.dir, ps);
   if(f.order.state == 0) return(false);
   f.retest = RunRetestChecker(f.dir, ps);
   f.ext    = RunExtensionChecker(f.dir, ps);
   return(true);
}

string SupervisorDecideAngle(const SupervisorFacts &f)
{
   if(f.dir.state == 1) {
      if(f.range.state == 1) {
         if(f.ext.reached161) return("");
         if(f.order.state == 2) {
            if(!f.retest.state && f.close.state == 1) return("ZA");
            if( f.retest.state && f.close.state == 1) return("ZB");
            if( f.retest.state && f.close.state == 0) return("ZC");
         } else if(f.order.state == 1) {
            if(f.close.state == 1) return("ZD");
            if(f.close.state == 0) return("ZE");
         }
      } else if(f.range.state == 2) {
         if(!f.ext.reached161) return("");
         if(f.order.state == 2) {
            if(f.close.state == 1) return("ZF");
            if(f.close.state == 0) return("ZG");
         } else if(f.order.state == 1) {
            if(f.close.state == 0) return("ZO");
            if(f.close.state == 1) return("ZH");
         }
      }
   } else if(f.dir.state == -1) {
      if(f.range.state == 1) {
         if(f.ext.reachedNeg61) return("");
         if(f.order.state == 2) {
            if(!f.retest.state && f.close.state == -1) return("ZA");
            if( f.retest.state && f.close.state == -1) return("ZB");
            if( f.retest.state && f.close.state ==  0) return("ZC");
         } else if(f.order.state == 1) {
            if(f.close.state == -1) return("ZD");
            if(f.close.state ==  0) return("ZE");
         }
      } else if(f.range.state == 2) {
         if(!f.ext.reachedNeg61) return("");
         if(f.order.state == 2) {
            if(f.close.state == -1) return("ZF");
            if(f.close.state ==  0) return("ZG");
         } else if(f.order.state == 1) {
            if(f.close.state ==  0) return("ZO");
            if(f.close.state == -1) return("ZH");
         }
      }
   }
   return("");
}

bool IsAngleConfirmedModern(const SupervisorFacts &sf, const string cls)
{
   if(cls == "") return(false);
   if(sf.dir.state == 0 || sf.range.state == 0 || sf.order.state == 0 || sf.close.state == 99)
      return(false);
   int extState = GetExtensionState(sf.ext, sf.dir.state);
   if(sf.range.state == 1) {
      if(cls == "ZA") return(!sf.retest.state && ((sf.dir.state == 1 && sf.close.state == 1)||(sf.dir.state == -1 && sf.close.state == -1)));
      if(cls == "ZB") return( sf.retest.state && ((sf.dir.state == 1 && sf.close.state == 1)||(sf.dir.state == -1 && sf.close.state == -1)));
      if(cls == "ZC") return( sf.retest.state && sf.close.state == 0);
      if(cls == "ZD") return((sf.dir.state == 1 && sf.close.state == 1)||(sf.dir.state == -1 && sf.close.state == -1));
      if(cls == "ZE") return(sf.close.state == 0);
   }
   if(sf.range.state == 2) {
      if(cls == "ZF") return((extState == sf.dir.state) && ((sf.dir.state == 1 && sf.close.state == 1)||(sf.dir.state == -1 && sf.close.state == -1)));
      if(cls == "ZG") return((extState == sf.dir.state) && sf.close.state == 0);
      if(cls == "ZO") return((extState == sf.dir.state) && sf.close.state == 0);
      if(cls == "ZH") return((extState == sf.dir.state) && ((sf.dir.state == 1 && sf.close.state == 1)||(sf.dir.state == -1 && sf.close.state == -1)));
   }
   return(false);
}

//── Build units going backward from current bar ──────────────────────
int EA_BuildUnits(UnitInfo &U[], int maxUnits)
{
   ArrayResize(U, 0);
   datetime now  = (Bars > 0 ? iTime(Symbol(), Period(), 0) + PeriodSeconds() : TimeCurrent());
   datetime rBnd = FloorTimeToUnit(now, g_unitSeconds);

   int count = 0;
   while(count < maxUnits) {
      datetime lBnd = FloorTimeToUnit(rBnd - 1, g_unitSeconds);
      if(lBnd <= 0 || lBnd >= rBnd) break;
      UnitInfo u;
      if(BuildUnit(lBnd, rBnd, u)) {
         u.id = (int)lBnd;
         int sz = ArraySize(U);
         ArrayResize(U, sz + 1);
         U[sz] = u;
         count++;
      }
      rBnd = lBnd;
   }
   return ArraySize(U);
}

//── Process one (refU, formU) pair, register angle in g_mon[] ───────
bool EA_ProcessPair(UnitInfo &refU, UnitInfo &formU)
{
   if(!refU.valid || !formU.valid) return false;
   SupervisorFacts sf;
   if(!BuildSupervisorFacts(refU, formU, sf)) return false;
   string cls = SupervisorDecideAngle(sf);
   if(cls == "") return false;
   if(!IsAngleConfirmedModern(sf, cls)) return false;

   AngleResult ar;
   ar.valid = true; ar.confirmed = true; ar.unconfirmed = false;
   ar.candidateBuy = false; ar.candidateSell = false;
   ar.angleName = cls; ar.classText = cls; ar.angleDisplayText = "";
   ar.dirState  = sf.dir.state;
   ar.u1Id = formU.id; ar.u2Id = refU.id;
   ar.u1Start = formU.start; ar.u2Start = refU.start;
   ar.u1End   = formU.end;   ar.u2End   = refU.end;
   ar.u1High = formU.hi; ar.u1Low = formU.lo;
   ar.u2High = refU.hi;  ar.u2Low = refU.lo;
   ar.correctionPct = CalcCorrectionPercent(refU, formU, sf.dir);
   ar.correctionValue = ar.correctionPct;
   ar.u1LegColor = clrNONE; ar.u2LegColor = clrNONE;
   if(ar.dirState ==  1) { ar.drawP1 = refU.hi;  ar.drawP2 = formU.lo; }
   else                  { ar.drawP1 = refU.lo;  ar.drawP2 = formU.hi; }
   ar.drawT1 = refU.start; ar.drawT2 = formU.start;

   Mon_OnAngleSaved(ar);
   return true;
}

//── Scan all unit pairs and register angles ──────────────────────────
void EA_ScanAngles()
{
   UnitInfo units[];
   int n = EA_BuildUnits(units, InpEAUnitsToScan);
   if(n < 3) return;

   // units[0]=newest, units[n-1]=oldest
   // For each pair: units[k+1]=older=refU, units[k]=newer=formU
   for(int k = 0; k < n - 1; k++) {
      UnitInfo formU = units[k];
      UnitInfo refU  = units[k + 1];
      if(!formU.processedSequentially)
         EA_ProcessPair(refU, formU);
   }
}

//══════════════════════════════════════════════════════════════════════
//  COMBO HELPERS
//══════════════════════════════════════════════════════════════════════
string EA_PrevClsLtr(int ai)
{
   datetime best = 0; int bestAi = -1;
   for(int i = 0; i < g_monCount; i++) {
      if(i == ai || !g_mon[i].valid) continue;
      if(g_mon[i].formTime < g_mon[ai].formTime && g_mon[i].formTime > best) {
         best = g_mon[i].formTime; bestAi = i;
      }
   }
   if(bestAi < 0) return "X";
   string c = g_mon[bestAi].cls;
   return (StringLen(c) >= 2 ? StringSubstr(c, 1, 1) : "X");
}

//══════════════════════════════════════════════════════════════════════
//  LOT CALCULATION
//══════════════════════════════════════════════════════════════════════
double EA_CalcTotalLots(double entry, double sl)
{
   double dist = MathAbs(entry - sl) + InpEASpreadPts * Point;
   if(dist <= 0) return(MarketInfo(Symbol(), MODE_MINLOT));
   double tkSz  = MarketInfo(Symbol(), MODE_TICKSIZE);  if(tkSz  <= 0) tkSz  = Point;
   double tkVal = MarketInfo(Symbol(), MODE_TICKVALUE); if(tkVal <= 0) return(MarketInfo(Symbol(), MODE_MINLOT));
   double lossPerLot = (dist / tkSz) * tkVal;
   if(lossPerLot <= 0) return(MarketInfo(Symbol(), MODE_MINLOT));
   double lots = InpEARiskMoney / lossPerLot;
   double step = MarketInfo(Symbol(), MODE_LOTSTEP); if(step <= 0) step = 0.01;
   lots = MathFloor(lots / step) * step;
   double mn = MarketInfo(Symbol(), MODE_MINLOT);
   double mx = MarketInfo(Symbol(), MODE_MAXLOT);
   return NormalizeDouble(MathMax(mn, MathMin(mx, lots)), 2);
}

//══════════════════════════════════════════════════════════════════════
//  TRADE TRACKING HELPERS
//══════════════════════════════════════════════════════════════════════
bool EA_IsEntered(int ai, int ti)
{
   for(int i = 0; i < g_eaTradeCount; i++)
      if(g_eaTrades[i].ai == ai && g_eaTrades[i].ti == ti)
         return true;
   return false;
}

void EA_TrackTrade(int ai, int ti, int t1, int t2, int t3,
                   const string code, double entryP, double slP)
{
   if(g_eaTradeCount >= ArraySize(g_eaTrades))
      ArrayResize(g_eaTrades, g_eaTradeCount + 64);
   g_eaTrades[g_eaTradeCount].ai          = ai;
   g_eaTrades[g_eaTradeCount].ti          = ti;
   g_eaTrades[g_eaTradeCount].ticket1     = t1;
   g_eaTrades[g_eaTradeCount].ticket2     = t2;
   g_eaTrades[g_eaTradeCount].ticket3     = t3;
   g_eaTrades[g_eaTradeCount].beApplied   = false;
   g_eaTrades[g_eaTradeCount].code        = code;
   g_eaTrades[g_eaTradeCount].entryPrice  = entryP;
   g_eaTrades[g_eaTradeCount].slPrice     = slP;
   g_eaTrades[g_eaTradeCount].fullyDone   = false;
   g_eaTradeCount++;
}

//══════════════════════════════════════════════════════════════════════
//  PLACE PENDING ORDER for one angle test
//══════════════════════════════════════════════════════════════════════
bool EA_PlaceTrade(int ai, int ti, string code)
{
   double away   = g_mon[ai].test[ti].away;
   double anchor = g_mon[ai].test[ti].anchor;
   double L      = g_mon[ai].L;
   double B      = g_mon[ai].B;
   double entry  = NormalizeDouble(anchor + L * away, Digits);
   double sl     = NormalizeDouble(entry  + B * away, Digits);
   double tp1    = NormalizeDouble(g_mon[ai].test[ti].tp[0], Digits);
   double tp2    = NormalizeDouble(g_mon[ai].test[ti].tp[1], Digits);
   int    nTP    = g_mon[ai].test[ti].nTP;
   double tp3    = (nTP >= 3 ? NormalizeDouble(g_mon[ai].test[ti].tp[2], Digits) : 0.0);

   double totalLots = EA_CalcTotalLots(entry, sl);
   if(totalLots <= 0) return false;

   int pct3 = MathMax(0, 100 - InpEATP1ClosePct - InpEATP2ClosePct);
   double step = MarketInfo(Symbol(), MODE_LOTSTEP); if(step <= 0) step = 0.01;
   double mn   = MarketInfo(Symbol(), MODE_MINLOT);

   double lots1 = NormalizeDouble(MathMax(mn, MathFloor(totalLots * InpEATP1ClosePct / 100.0 / step) * step), 2);
   double lots2 = NormalizeDouble(MathMax(mn, MathFloor(totalLots * InpEATP2ClosePct / 100.0 / step) * step), 2);
   double lots3 = (nTP >= 3 && pct3 > 0)
                  ? NormalizeDouble(MathMax(mn, MathFloor(totalLots * pct3 / 100.0 / step) * step), 2)
                  : 0.0;

   // Determine pending order type
   // away > 0 → SELL zone (level is ABOVE anchor) → SellLimit or SellStop
   // away < 0 → BUY  zone (level is BELOW anchor) → BuyLimit  or BuyStop
   int otype;
   double curBid = MarketInfo(Symbol(), MODE_BID);
   double curAsk = MarketInfo(Symbol(), MODE_ASK);
   if(away > 0) {
      otype = (curBid < entry - InpEASpreadPts * Point) ? OP_SELLLIMIT : OP_SELLSTOP;
   } else {
      otype = (curAsk > entry + InpEASpreadPts * Point) ? OP_BUYLIMIT  : OP_BUYSTOP;
   }

   string cmt = StringFormat("AIB_%s_%d_%d", code, ai, ti);
   color  clr = (away > 0 ? clrRed : clrBlue);

   // TP1 order
   int t1 = OrderSend(Symbol(), otype, lots1, entry, InpEASlippage, sl, tp1, cmt + "_1", 0, 0, clr);
   if(t1 < 0) {
      Print("AIB EA: TP1 OrderSend failed for ", code, " ai=", ai, " ti=", ti, " err=", GetLastError());
      return false;
   }

   // TP2 order
   int t2 = -1;
   if(lots2 >= mn && tp2 != 0.0) {
      t2 = OrderSend(Symbol(), otype, lots2, entry, InpEASlippage, sl, tp2, cmt + "_2", 0, 0, clr);
      if(t2 < 0) Print("AIB EA: TP2 OrderSend failed: ", GetLastError());
   }

   // TP3 order
   int t3 = -1;
   if(nTP >= 3 && lots3 >= mn && tp3 != 0.0) {
      t3 = OrderSend(Symbol(), otype, lots3, entry, InpEASlippage, sl, tp3, cmt + "_3", 0, 0, clr);
      if(t3 < 0) Print("AIB EA: TP3 OrderSend failed: ", GetLastError());
   }

   EA_TrackTrade(ai, ti, t1, t2, t3, code, entry, sl);
   Print("AIB EA: Placed ", (otype==OP_SELLLIMIT||otype==OP_SELLSTOP?"SELL":"BUY"),
         " pending  code=", code, "  entry=", entry, "  SL=", sl, "  lots=", lots1+lots2+lots3);
   return true;
}

//══════════════════════════════════════════════════════════════════════
//  CHECK FOR NEW SIGNALS — place pending orders for new angles
//  3-criteria filter: p1 >= MinHitPct AND nt >= MinTouchCount AND nok >= MinSuccessCount
//  Score = nok * (p1/100) — top InpEAMaxTestsPerAngle tests per angle
//══════════════════════════════════════════════════════════════════════
double EA_TestScore(int cidx, int ti)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0.0;
   return g_combos[cidx].nok[ti] * (g_combos[cidx].p1[ti] / 100.0);
}

bool EA_IsQualified(int cidx, int ti)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return false;
   return (g_combos[cidx].p1[ti]  >= InpEAMinHitPct      &&
           g_combos[cidx].nt[ti]  >= InpEAMinTouchCount   &&
           g_combos[cidx].nok[ti] >= InpEAMinSuccessCount);
}

void EA_CheckNewSignals()
{
   ComboTable_Init();

   for(int ai = 0; ai < g_monCount; ai++) {
      if(!g_mon[ai].valid) continue;

      string cls  = g_mon[ai].cls;
      string dir  = (g_mon[ai].dir > 0 ? "BUY" : "SELL");
      double rat  = g_mon[ai].ratio;
      double lu1  = (g_mon[ai].u1R > 1e-10 ? g_mon[ai].L / g_mon[ai].u1R * 100.0 : 0.0);
      string prev = EA_PrevClsLtr(ai);
      string code = ComboCode(cls, dir, rat, lu1, prev);
      int    cidx = ComboFind(code);

      if(cidx < 0) continue;  // unknown combo → skip
      if(InpEAOnlyBestCombo && !ComboIsBest(cidx)) continue;

      // Collect qualifying tests and their scores
      int    qualTi[4];
      double qualSc[4];
      int    qualN = 0;

      for(int ti = 0; ti < MON_NPTS; ti++) {
         if(g_mon[ai].test[ti].react[0] == MON_REACT_NA) continue;
         if(g_mon[ai].test[ti].done)                      continue;
         if(EA_IsEntered(ai, ti))                         continue;
         if(!EA_IsQualified(cidx, ti))                    continue;

         double sc = EA_TestScore(cidx, ti);
         // Insert sorted descending by score
         int ins = qualN;
         for(int j = 0; j < qualN; j++) {
            if(sc > qualSc[j]) { ins = j; break; }
         }
         for(int j = qualN; j > ins; j--) {
            qualTi[j] = qualTi[j-1];
            qualSc[j] = qualSc[j-1];
         }
         qualTi[ins] = ti;
         qualSc[ins] = sc;
         qualN++;
      }

      // Place trades for top InpEAMaxTestsPerAngle only
      int limit = MathMin(qualN, InpEAMaxTestsPerAngle);
      for(int k = 0; k < limit; k++)
         EA_PlaceTrade(ai, qualTi[k], code);
   }
}

//══════════════════════════════════════════════════════════════════════
//  TRADE MANAGEMENT — Move SL to breakeven after TP1 hit
//══════════════════════════════════════════════════════════════════════
void EA_MoveSLtoBE(int idx)
{
   double beP = NormalizeDouble(g_eaTrades[idx].entryPrice, Digits);
   string prefix = StringFormat("AIB_%s_%d_%d", g_eaTrades[idx].code,
                                 g_eaTrades[idx].ai, g_eaTrades[idx].ti);

   for(int i = 0; i < OrdersTotal(); i++) {
      if(!OrderSelect(i, SELECT_BY_POS)) continue;
      if(OrderSymbol() != Symbol())       continue;
      if(OrderCloseTime() > 0)            continue;  // already closed
      if(StringFind(OrderComment(), prefix) != 0) continue;

      // Check SL is not already at BE (avoid unnecessary modify)
      if(MathAbs(OrderStopLoss() - beP) < Point * 0.5) continue;

      bool ok = OrderModify(OrderTicket(), OrderOpenPrice(), beP, OrderTakeProfit(), 0, clrGold);
      if(!ok) Print("AIB EA: BE modify failed ticket=", OrderTicket(), " err=", GetLastError());
      else     Print("AIB EA: SL moved to BE for ticket=", OrderTicket());
   }
}

void EA_ManageTrades()
{
   for(int i = 0; i < g_eaTradeCount; i++) {
      if(g_eaTrades[i].fullyDone)   continue;
      if(g_eaTrades[i].beApplied)   continue;
      if(g_eaTrades[i].ticket1 < 0) continue;

      // Check if TP1 ticket is closed in profit
      if(!OrderSelect(g_eaTrades[i].ticket1, SELECT_BY_TICKET)) continue;
      if(OrderCloseTime() > 0 && OrderProfit() > 0) {
         g_eaTrades[i].beApplied = true;
         EA_MoveSLtoBE(i);
      }
   }
}

//══════════════════════════════════════════════════════════════════════
//  REPORT GENERATION
//══════════════════════════════════════════════════════════════════════
int EA_FindComboStat(const string code)
{
   for(int i = 0; i < g_comboStatCount; i++)
      if(g_comboStats[i].code == code) return i;
   return -1;
}

int EA_EnsureComboStat(const string code)
{
   int idx = EA_FindComboStat(code);
   if(idx >= 0) return idx;
   if(g_comboStatCount >= ArraySize(g_comboStats))
      ArrayResize(g_comboStats, g_comboStatCount + 32);
   g_comboStats[g_comboStatCount].code     = code;
   g_comboStats[g_comboStatCount].total    = 0;
   g_comboStats[g_comboStatCount].slHit    = 0;
   g_comboStats[g_comboStatCount].tp1Only  = 0;
   g_comboStats[g_comboStatCount].tp12     = 0;
   g_comboStats[g_comboStatCount].tp123    = 0;
   g_comboStats[g_comboStatCount].pnlTotal = 0.0;
   return g_comboStatCount++;
}

void EA_CollectTradeStats()
{
   for(int i = 0; i < g_eaTradeCount; i++) {
      int ai = g_eaTrades[i].ai;
      int ti = g_eaTrades[i].ti;
      if(ai >= g_monCount || !g_mon[ai].valid) continue;

      int idx = EA_EnsureComboStat(g_eaTrades[i].code);
      g_comboStats[idx].total++;

      // Determine outcome from Monitor data
      int react = g_mon[ai].test[ti].react[0];
      bool h1 = g_mon[ai].test[ti].tpHit[0];
      bool h2 = g_mon[ai].test[ti].tpHit[1];
      bool h3 = g_mon[ai].test[ti].tpHit[2];

      if(react == MON_REACT_BOUNCE) {
         if(h3)       g_comboStats[idx].tp123++;
         else if(h2)  g_comboStats[idx].tp12++;
         else if(h1)  g_comboStats[idx].tp1Only++;
         else         g_comboStats[idx].slHit++;  // bounced but no TP hit? edge case
      } else if(react == MON_REACT_BREAK) {
         g_comboStats[idx].slHit++;
      }
      // Pending/Untouched → not counted (still open or expired)

      // PnL from actual MT4 orders
      for(int t = 0; t < OrdersHistoryTotal(); t++) {
         if(!OrderSelect(t, SELECT_BY_POS, MODE_HISTORY)) continue;
         if(OrderSymbol() != Symbol()) continue;
         string prefix = StringFormat("AIB_%s_%d_%d", g_eaTrades[i].code, ai, ti);
         if(StringFind(OrderComment(), prefix) == 0)
            g_comboStats[idx].pnlTotal += OrderProfit() + OrderSwap() + OrderCommission();
      }
   }
}

void EA_WriteReport()
{
   EA_CollectTradeStats();

   string fname = StringFormat("%s_%s_%d_U%d.csv",
                               InpEAReportPrefix, Symbol(), Period(), g_unitSeconds);
   int h = FileOpen(fname, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, ',');
   if(h == INVALID_HANDLE) {
      Print("AIB EA: Cannot open report file: ", fname, " err=", GetLastError());
      return;
   }

   FileWrite(h, "ComboCode,TotalTrades,SL_Hit,TP1_Only,TP1_TP2,TP1_TP2_TP3,WinRate%,NetPnL_USD");

   for(int i = 0; i < g_comboStatCount; i++) {
      int   tot  = g_comboStats[i].total;
      int   wins = g_comboStats[i].tp1Only + g_comboStats[i].tp12 + g_comboStats[i].tp123;
      double wr  = (tot > 0 ? 100.0 * wins / tot : 0.0);
      FileWrite(h,
         g_comboStats[i].code,
         tot,
         g_comboStats[i].slHit,
         g_comboStats[i].tp1Only,
         g_comboStats[i].tp12,
         g_comboStats[i].tp123,
         StringFormat("%.1f", wr),
         StringFormat("%.2f", g_comboStats[i].pnlTotal));
   }

   FileClose(h);
   Print("AIB EA: Report written → Common\\Files\\", fname);
}

//══════════════════════════════════════════════════════════════════════
//  EA LIFECYCLE
//══════════════════════════════════════════════════════════════════════
int OnInit()
{
   g_unitSeconds = InpEAUnitSeconds;
   if(g_unitSeconds <= 0) g_unitSeconds = 86400;

   Mon_OnInit();
   ComboTable_Init();

   ArrayResize(g_eaTrades,    64);
   ArrayResize(g_comboStats,  32);
   g_eaTradeCount    = 0;
   g_comboStatCount  = 0;
   g_lastScanBar     = 0;
   g_eaInited        = true;

   Print("AIB Trading EA initialized  Unit=", g_unitSeconds, "s  MinHit=", InpEAMinHitPct,
         "%  MinNt=", InpEAMinTouchCount, "  MinNok=", InpEAMinSuccessCount,
         "  MaxTests=", InpEAMaxTestsPerAngle, "  Risk=$", InpEARiskMoney);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if(!g_eaInited) return;

   // Full rescan only on bar close (or first run)
   datetime curBar = iTime(Symbol(), Period(), 0);
   if(curBar != g_lastScanBar) {
      g_lastScanBar = curBar;
      EA_ScanAngles();
      Mon_OnTick();
      EA_CheckNewSignals();
   }

   // Manage open trades on every tick (check BE SL)
   EA_ManageTrades();
}

void OnDeinit(const int reason)
{
   // Final scan pass
   EA_ScanAngles();
   Mon_OnTick();

   // Write backtest/live report
   EA_WriteReport();

   Mon_OnDeinit(reason);

   Print("AIB EA: Deinitialized. Trades placed: ", g_eaTradeCount,
         "  Combos tracked: ", g_comboStatCount);
}
