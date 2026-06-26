//==================================================================
//  AIB_Signal.mqh  v4.4
//
//  v4.3 → v4.4 additions (cumulative — no features removed):
//  • New 283-combo table (Confirmed=1, deduped, no ZA class)
//  • 5-tier classification: Full Margin/Strong/Good/Weak/Very Weak
//  • Signal Score = sqrt(n_ang) * nok[best_test] (statistical weight)
//  • Test selection ranked by nok[ti] instead of p1[ti]
//  • Tier 5 (Very Weak) angles skipped entirely
//  • Trade direction per zone: away<0 → BUY, away>0 → SELL
//
//  v4.3 features preserved:
//  • Two themes: InpSigLightBg (dark/white background)
//  • Blue-family color palette (user preference)
//  • Fill opacity control: InpSigFillAlpha (10-100)
//  • Price labels restored: InpSigShowPrices input
//  • Test selection: show all touched + top 2 untouched
//  • cidx==-1 (combo not in table) → zone fully ignored
//  • PREVIEW (50% dim) / INCOMING (20% dim) / ACTIVE / CLOSED states
//  • BREAK: shrink 3 candles, no text
//  • BOUNCE: shrink 6 candles, "PROTECTED"
//  • UNTOUCHED auto-delete after InpSigUntouchedMax newer angles
//  • 2-candle gap between overlapping slots
//  • Sort: PENDING → INCOMING → historical
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep1           = "─── AIB Signal v4.4 ────";
input bool   InpSigEnabled        = true;

input string InpSigSep2           = "─── Display ─────────────";
input bool   InpSigShowPreview    = true;
input bool   InpSigShowPending    = true;
input bool   InpSigShowHistory    = true;
input bool   InpSigFill           = true;
input bool   InpSigShowPrices     = true;    // show price labels on zone right edge

input string InpSigSep3           = "─── Incoming Zone ───────";
input int    InpSigIncomingPips   = 20;
input int    InpSigIncomingBars   = 1;
input int    InpSigBreakBars      = 3;
input int    InpSigBounceBars     = 6;
input int    InpSigUntouchedMax   = 10;

input string InpSigSep4           = "─── Panel ───────────────";
input bool   InpSigShowPanel      = true;
input int    InpSigMaxRows        = 6;
input bool   InpSigShowAdvice     = true;
input int    InpSigPanelX         = 12;
input int    InpSigPanelY         = 5;

input string InpSigSep5           = "─── Trade Sizing ────────";
input double InpSigRiskMoney      = 50.0;
input int    InpSigSpreadPts      = 20;
input int    InpSigTP1Pct         = 50;
input int    InpSigTP2Pct         = 30;
input int    InpSigTP3Pct         = 20;
input bool   InpSigAlerts         = true;
input int    InpSigFontSize       = 10;

input string InpSigSep6           = "─── Theme ───────────────";
input bool   InpSigLightBg        = false;   // true = white/light chart background
input int    InpSigFillAlpha      = 80;      // zone fill opacity 10-100

//─── Layout ────────────────────────────────────────────────────────
#define SIG_PFX   "AIBSIG_"
#define PANEL_W   305
#define ROW_H     16
#define BTN_H     20
#define BTN_W     68
#define ADVICE_H  42

//─── State ─────────────────────────────────────────────────────────
bool     g_sigHideAll   = false;
bool     g_sigPickHide  = false;
bool     g_sigPickShow  = false;
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
   int b = (((int)base)       & 255) * (100-pct)/100 + (((int)mix)       & 255) * pct/100;
   int g = ((((int)base)>> 8) & 255) * (100-pct)/100 + ((((int)mix)>> 8) & 255) * pct/100;
   int r = ((((int)base)>>16) & 255) * (100-pct)/100 + ((((int)mix)>>16) & 255) * pct/100;
   return (color)(b | (g<<8) | (r<<16));
}

// Dim toward background (dark→black, light→white) by pct%
color Sig_Dim(color c, int pct)
{
   if(pct <= 0) return c;
   pct = MathMin(pct, 100);
   color target = InpSigLightBg ? (color)C'255,255,255' : (color)C'0,0,0';
   return Sig_Blend(c, target, pct);
}

// Apply fill opacity by blending toward chart background
color Sig_FillC(color c)
{
   int a = MathMax(10, MathMin(100, InpSigFillAlpha));
   color bg = InpSigLightBg ? (color)C'248,248,255' : (color)C'0,0,8';
   return Sig_Blend(c, bg, 100-a);
}

//──── Zone colors (blue family, theme-aware) ────────────────────
color Sig_SlBg()
{ return InpSigLightBg ? (color)C'195,35,35'  : (color)C'140,20,20'; }

color Sig_Tp1Bg()
{ return InpSigLightBg ? (color)C'20,80,168'  : (color)C'14,52,108'; }

color Sig_Tp2Bg()
{ return InpSigLightBg ? (color)C'15,62,145'  : (color)C'10,40,92';  }

color Sig_Tp3Bg()
{ return InpSigLightBg ? (color)C'10,48,122'  : (color)C'7,28,72';   }

color Sig_TpHitBg()
{ return InpSigLightBg ? (color)C'22,105,210' : (color)C'16,75,158'; }

color Sig_FailBg()
{ return InpSigLightBg ? (color)C'78,15,15'   : (color)C'48,10,10';  }

color Sig_EntryLine()
{ return InpSigLightBg ? (color)C'20,82,188'  : (color)C'75,138,218'; }

//──── Label colors ──────────────────────────────────────────────
color Sig_LblEntry()
{ return InpSigLightBg ? (color)C'12,65,162'  : (color)C'95,162,238'; }

color Sig_LblSL()
{ return InpSigLightBg ? (color)C'178,22,22'  : (color)C'220,80,80';  }

color Sig_LblTP1()
{ return InpSigLightBg ? (color)C'18,78,182'  : (color)C'78,152,225'; }

color Sig_LblTP2()
{ return InpSigLightBg ? (color)C'14,60,155'  : (color)C'60,128,200'; }

color Sig_LblTP3()
{ return InpSigLightBg ? (color)C'10,46,130'  : (color)C'45,105,175'; }

color Sig_ZoneLblColor()
{ return InpSigLightBg ? (color)C'15,20,50'   : clrWhite; }

//──── Panel colors ──────────────────────────────────────────────
color Sig_PanelBg()
{ return InpSigLightBg ? (color)C'230,238,250' : (color)C'12,15,22'; }

color Sig_PanelHdr()
{ return InpSigLightBg ? (color)C'205,220,244' : (color)C'18,28,50'; }

color Sig_PanelTxt()
{ return InpSigLightBg ? (color)C'14,38,90'    : (color)C'138,185,240'; }

color Sig_AdvBorder(color cls)
{ return InpSigLightBg ? Sig_Blend(cls,(color)C'200,212,235',55) : Sig_Blend(cls,(color)C'12,16,28',55); }

color Sig_BtnNormal()  { return InpSigLightBg ? (color)C'175,198,232' : (color)C'28,44,72';  }
color Sig_BtnActive()  { return InpSigLightBg ? (color)C'210,165,60'  : (color)C'72,44,14';  }
color Sig_BtnDanger()  { return InpSigLightBg ? (color)C'210,80,80'   : (color)C'68,16,16';  }
color Sig_BtnText()    { return InpSigLightBg ? (color)C'14,35,88'    : clrWhite;             }

//══════════════════════════════════════════════════════════════════
//  Classification
//══════════════════════════════════════════════════════════════════
// tier: 1=Full Margin, 2=Strong, 3=Good, 4=Weak, 5=Very Weak
// clsLevel: 5=Full Margin, 4=Strong, 3=Good, 2=Weak, 1=Very Weak
int Sig_Classify(int cidx)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0;
   int t = g_combos[cidx].tier;
   if(t < 1 || t > 5) return 0;
   return 6 - t;  // tier1→5, tier2→4, tier3→3, tier4→2, tier5→1
}

string Sig_ClsStr(int lvl)
{
   switch(lvl) {
      case 5: return "Full Margin";
      case 4: return "Strong";
      case 3: return "Good";
      case 2: return "Weak";
      case 1: return "Very Weak";
   }
   return "NO TRADE";
}

color Sig_ClsColor(int lvl)
{
   switch(lvl) {
      case 5: return InpSigLightBg ? (color)C'8,110,45'   : (color)C'20,210,90';
      case 4: return InpSigLightBg ? (color)C'12,128,55'  : (color)C'28,190,100';
      case 3: return InpSigLightBg ? (color)C'138,108,8'  : (color)C'190,155,40';
      case 2: return InpSigLightBg ? (color)C'45,80,125'  : (color)C'82,118,155';
      case 1: return InpSigLightBg ? (color)C'62,62,62'   : (color)C'92,92,92';
   }
   return InpSigLightBg ? (color)C'38,38,38' : (color)C'52,52,52';
}

color Sig_AdviceColor(int lvl)
{
   if(lvl >= 4) return InpSigLightBg ? (color)C'8,148,48'   : (color)C'60,200,90';
   if(lvl == 3) return InpSigLightBg ? (color)C'158,118,0'  : (color)C'218,175,32';
   if(lvl >= 1) return InpSigLightBg ? (color)C'168,28,28'  : (color)C'210,55,55';
   return InpSigLightBg ? (color)C'28,28,28' : clrWhite;
}

double Sig_Score(int cidx, int ti)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0.0;
   return (double)g_combos[cidx].nok[ti];
}

//══════════════════════════════════════════════════════════════════
//  SigZone
//══════════════════════════════════════════════════════════════════
struct SigZone {
   int      ai, ti, clsLevel;
   double   score;
   string   code, clsL, dir, angleCls;
   bool     isBuy, isPreview, isIncoming;
   double   pMin, pMax;
   datetime baseTime;
   int      grpId, grpSlot, grpSize;
   datetime slotTL, slotTR;
};

//══════════════════════════════════════════════════════════════════
//  Drawing primitives
//══════════════════════════════════════════════════════════════════
void Sig_DelObj(const string nm)
{ if(ObjectFind(0,nm)>=0) ObjectDelete(0,nm); }

void Sig_Rect(const string nm, datetime t1, double p1,
              datetime t2, double p2, color c, bool fill, int style=STYLE_SOLID)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,  t1); ObjectSetDouble(0,nm,OBJPROP_PRICE1,p1);
   ObjectSetInteger(0,nm,OBJPROP_TIME2,  t2); ObjectSetDouble(0,nm,OBJPROP_PRICE2,p2);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,  c);  ObjectSetInteger(0,nm,OBJPROP_STYLE,style);
   ObjectSetInteger(0,nm,OBJPROP_FILL,   fill);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,  1);
   ObjectSetInteger(0,nm,OBJPROP_BACK,   false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_HLine(const string nm, datetime t1, datetime t2, double price, color c, int w=1)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,  t1); ObjectSetDouble(0,nm,OBJPROP_PRICE1,price);
   ObjectSetInteger(0,nm,OBJPROP_TIME2,  t2); ObjectSetDouble(0,nm,OBJPROP_PRICE2,price);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,  c);  ObjectSetInteger(0,nm,OBJPROP_WIDTH,w);
   ObjectSetInteger(0,nm,OBJPROP_STYLE,  STYLE_SOLID);
   ObjectSetInteger(0,nm,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_Text(const string nm, datetime t, double p, const string txt,
              color c, int sz, int anchor=ANCHOR_LEFT)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_TEXT,0,t,p);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,   t);   ObjectSetDouble(0,nm,OBJPROP_PRICE1,p);
   ObjectSetString (0,nm,OBJPROP_TEXT,    txt);  ObjectSetInteger(0,nm,OBJPROP_COLOR,c);
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,sz);   ObjectSetString (0,nm,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,  anchor);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_SLabel(const string nm, int x, int y, const string txt, color c,
                int sz, int corner=CORNER_LEFT_UPPER, int anchor=ANCHOR_LEFT_UPPER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,    corner);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE, y);
   ObjectSetString (0,nm,OBJPROP_TEXT,      txt);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,     c);
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,  sz);
   ObjectSetString (0,nm,OBJPROP_FONT,      "Consolas");
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,    anchor);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,      false);
}

void Sig_SRect(const string nm, int x, int y, int w, int h,
               color c, int corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,     corner);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0,nm,OBJPROP_XSIZE,      w);
   ObjectSetInteger(0,nm,OBJPROP_YSIZE,      h);
   ObjectSetInteger(0,nm,OBJPROP_BGCOLOR,    c);
   ObjectSetInteger(0,nm,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,      Sig_Blend(c,clrSilver,18));
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,       false);
}

void Sig_SBtn(const string nm, int x, int y, int w, int h,
              const string txt, color bg, color tc, int corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,    corner);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0,nm,OBJPROP_XSIZE,     w);
   ObjectSetInteger(0,nm,OBJPROP_YSIZE,     h);
   ObjectSetString (0,nm,OBJPROP_TEXT,      txt);
   ObjectSetInteger(0,nm,OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,     tc);
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,  8);
   ObjectSetString (0,nm,OBJPROP_FONT,      "Consolas");
   ObjectSetInteger(0,nm,OBJPROP_STATE,     false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,      false);
}

//══════════════════════════════════════════════════════════════════
//  Object naming + zone cleanup
//══════════════════════════════════════════════════════════════════
string Sig_N(int ai, int ti, const string tag)
{ return SIG_PFX + IntegerToString(ai) + "_" + IntegerToString(ti) + "_" + tag; }
string Sig_PN(const string tag) { return SIG_PFX + "PANEL_" + tag; }
string Sig_BN(const string tag) { return SIG_PFX + "BTN_"   + tag; }

void Sig_DeleteZone(int ai, int ti)
{
   string tags[] = {"SL","TP1","TP2","TP3","ELINE",
                    "LBL_E","LBL_SL","LBL_T1","LBL_T2","LBL_T3",
                    "LBL_ZONE","LBL_TP1_IN","LBL_TP2_IN","LBL_TP3_IN",
                    "PREV_SL","PREV_TP","PREV_LBL"};
   for(int i = 0; i < ArraySize(tags); i++) Sig_DelObj(Sig_N(ai,ti,tags[i]));
}

//══════════════════════════════════════════════════════════════════
//  Domain helpers
//══════════════════════════════════════════════════════════════════
string Sig_TestName(int ti)
{
   switch(ti) { case 0: return "U1X1"; case 1: return "U2X1";
                case 2: return "DLX1"; case 3: return "DRX1"; }
   return "???";
}

double Sig_PipSz()
{
   int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
   return (d==3||d==5) ? Point*10.0 : Point;
}

string Sig_PrevClsLtr(int ai)
{
   datetime best = 0; int bestAi = -1;
   for(int i = 0; i < g_monCount; i++) {
      if(i==ai || !g_mon[i].valid) continue;
      if(g_mon[i].formTime < g_mon[ai].formTime && g_mon[i].formTime > best)
         { best = g_mon[i].formTime; bestAi = i; }
   }
   if(bestAi < 0) return "X";
   string c = g_mon[bestAi].cls;
   return (StringLen(c)>=2 ? StringSubstr(c,1,1) : "X");
}

bool Sig_IsVisible(int ai, int ti)
{
   if(g_sigHideAll) return false;
   if(ai<1024 && ti<4 && g_sigHide[ai][ti]) return false;
   return true;
}

bool Sig_IsIncoming(int ai, int ti)
{
   double away  = g_mon[ai].test[ti].away;
   double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * away;
   double curPrice = (away > 0 ? Ask : Bid);
   double pips     = MathAbs(curPrice - entry) / Sig_PipSz();
   if(pips <= (double)InpSigIncomingPips) return true;
   long barSecs = (long)Period() * 60;
   long elapsed = (long)(Time[0] - g_mon[ai].formTime) / MathMax(barSecs, 1);
   if(elapsed >= 0 && elapsed <= (long)InpSigIncomingBars) return true;
   return false;
}

bool Sig_IsOld(int ai)
{
   int newer = 0;
   for(int i = 0; i < g_monCount; i++) {
      if(i == ai || !g_mon[i].valid) continue;
      if(g_mon[i].formTime > g_mon[ai].formTime) newer++;
   }
   return (newer >= InpSigUntouchedMax);
}

//══════════════════════════════════════════════════════════════════
//  Test selection: which ti to draw for a given angle + combo
//  Rule: show ALL touched (PENDING/BOUNCE/BREAK) + top 2 UNTOUCHED
//        ranked by p1[ti] from combo table.
//        showTi[4] must be pre-allocated and zero-filled.
//══════════════════════════════════════════════════════════════════
void Sig_SelectTests(int ai, int cidx, bool &showTi[])
{
   // Rank valid tests by nok[ti] descending (absolute success count)
   int    rankIdx[4]; ArrayInitialize(rankIdx, 0);
   double rankP1[4];  ArrayInitialize(rankP1,  0.0);
   int rankN = 0;
   for(int ti = 0; ti < MON_NPTS; ti++) {
      if(g_mon[ai].test[ti].react[0] == MON_REACT_NA) continue;
      rankIdx[rankN] = ti;
      rankP1[rankN]  = (cidx >= 0 && cidx < COMBO_COUNT) ? (double)g_combos[cidx].nok[ti] : 0.0;
      rankN++;
   }
   for(int a = 0; a < rankN-1; a++)
      for(int b = a+1; b < rankN; b++)
         if(rankP1[a] < rankP1[b]) {
            double tp = rankP1[a]; rankP1[a] = rankP1[b]; rankP1[b] = tp;
            int    tt = rankIdx[a]; rankIdx[a] = rankIdx[b]; rankIdx[b] = tt;
         }

   int untouchedSlots = 0;
   for(int r = 0; r < rankN; r++) {
      int ti    = rankIdx[r];
      int react = g_mon[ai].test[ti].react[0];
      bool touched = (react == MON_REACT_PENDING ||
                      react == MON_REACT_BOUNCE  ||
                      react == MON_REACT_BREAK);
      if(touched) {
         showTi[ti] = true;
      } else {
         if(untouchedSlots < 2) { showTi[ti] = true; untouchedSlots++; }
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Overlap slot computation with gap between slots
//══════════════════════════════════════════════════════════════════
void Sig_ComputeSlots(SigZone &zones[], int n)
{
   int parent[]; ArrayResize(parent,n);
   for(int i = 0; i < n; i++) parent[i] = i;

   for(int i = 0; i < n; i++)
      for(int j = i+1; j < n; j++) {
         bool priceOvlp = (zones[i].pMin < zones[j].pMax && zones[j].pMin < zones[i].pMax);
         long dt        = MathAbs((long)zones[i].baseTime - (long)zones[j].baseTime);
         bool timeClose = (dt <= (long)(2*g_unitSeconds));
         if(!priceOvlp || !timeClose) continue;
         int ri = i, rj = j;
         while(parent[ri]!=ri) ri=parent[ri];
         while(parent[rj]!=rj) rj=parent[rj];
         if(ri!=rj) parent[ri]=rj;
      }

   for(int i = 0; i < n; i++) {
      int r = i; while(parent[r]!=r) r=parent[r]; parent[i]=r;
   }

   int grpNext = 0;
   int grpMap[];   ArrayResize(grpMap,n);   ArrayInitialize(grpMap,-1);
   int grpSizes[]; ArrayResize(grpSizes,n); ArrayInitialize(grpSizes,0);
   for(int i = 0; i < n; i++) {
      int r = parent[i];
      if(grpMap[r]<0) { grpMap[r]=grpNext++; }
      grpSizes[grpMap[r]]++;
   }

   for(int i = 0; i < n; i++) {
      int r = parent[i];
      zones[i].grpId   = grpMap[r];
      zones[i].grpSize = MathMin(grpSizes[grpMap[r]], 3);
      zones[i].grpSlot = -1;
   }

   long barSecs = (long)Period() * 60;
   long gapSecs = 2 * barSecs;

   for(int g = 0; g < grpNext; g++) {
      int members[]; int mc = 0;
      for(int i = 0; i < n; i++) if(zones[i].grpId==g) mc++;
      ArrayResize(members,mc);
      int mi = 0;
      for(int i = 0; i < n; i++) if(zones[i].grpId==g) members[mi++]=i;
      for(int a = 0; a < mc-1; a++)
         for(int b = a+1; b < mc; b++)
            if(zones[members[a]].clsLevel < zones[members[b]].clsLevel)
               { int tmp=members[a]; members[a]=members[b]; members[b]=tmp; }
      int slotCount = MathMin(mc, 3);
      for(int s = 0; s < mc; s++) {
         zones[members[s]].grpSlot = (s < slotCount) ? s : -1;
         zones[members[s]].grpSize = slotCount;
      }
   }

   for(int i = 0; i < n; i++) {
      int  slot = zones[i].grpSlot;
      int  N    = zones[i].grpSize;
      if(slot<0||N<=0) { slot=0; N=1; }
      datetime base     = zones[i].baseTime;
      long     unitLen  = (long)g_unitSeconds;
      long     totalGap = gapSecs * (long)(N-1);
      long     slotLen  = MathMax((unitLen - totalGap) / (long)N, barSecs);
      zones[i].slotTL   = base + (datetime)((long)slot * (slotLen + gapSecs));
      zones[i].slotTR   = zones[i].slotTL + (datetime)slotLen;
   }
}

//══════════════════════════════════════════════════════════════════
//  Price label at right edge
//══════════════════════════════════════════════════════════════════
void Sig_PriceLabel(const string nm, datetime tR, double price,
                    const string prefix, color c, int sz)
{
   Sig_Text(nm, tR, price, prefix+DoubleToString(price,Digits), c, sz, ANCHOR_LEFT);
}

//══════════════════════════════════════════════════════════════════
//  Draw one zone — all lifecycle states
//══════════════════════════════════════════════════════════════════
void Sig_DrawZoneV4(SigZone &z)
{
   int  ai = z.ai, ti = z.ti;
   int  react      = g_mon[ai].test[ti].react[0];
   bool isPending  = (react == MON_REACT_PENDING);
   bool bounced    = (react == MON_REACT_BOUNCE);
   bool broke      = (react == MON_REACT_BREAK);
   bool isIncoming = z.isIncoming;
   bool isPreview  = z.isPreview && !isIncoming;
   bool narrow     = (z.grpSize > 1);

   if( isPending && !InpSigShowPending) return;
   if(!isPending && !bounced && !broke && !InpSigShowPreview) return;
   if((bounced || broke) && !InpSigShowHistory) return;

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
   bool   h1     = g_mon[ai].test[ti].tpHit[0];
   bool   h2     = g_mon[ai].test[ti].tpHit[1];
   bool   h3     = g_mon[ai].test[ti].tpHit[2];

   datetime tL = z.slotTL, tR = z.slotTR;
   long barSecs = (long)Period() * 60;
   if(broke)   tR = tL + (datetime)((long)InpSigBreakBars  * barSecs);
   if(bounced) tR = tL + (datetime)((long)InpSigBounceBars * barSecs);

   datetime midT = tL + (datetime)((tR - tL) / 2);
   int fsz = (z.grpSize >= 3) ? MathMax(7, InpSigFontSize-2) :
             (z.grpSize == 2) ? MathMax(8, InpSigFontSize-1) :
                                 InpSigFontSize;

   // Dim factor per state
   int dimPct = 0;
   if(isPreview)  dimPct = 50;
   if(isIncoming) dimPct = 20;
   if(broke)      dimPct = 60;

   // Zone rect colors — theme + opacity + state dim
   color cSL  = Sig_Dim(Sig_FillC(broke ? Sig_FailBg() :
                         bounced ? Sig_Blend(Sig_SlBg(),Sig_Dim(clrBlack,0),30) :
                         Sig_SlBg()), dimPct);
   color cTP1 = Sig_Dim(Sig_FillC(h1 ? Sig_TpHitBg() :
                         broke ? Sig_Blend(Sig_Tp1Bg(),Sig_Dim(clrBlack,0),55) :
                         Sig_Tp1Bg()), dimPct);
   color cTP2 = Sig_Dim(Sig_FillC(h2 ? Sig_TpHitBg() :
                         broke ? Sig_Blend(Sig_Tp2Bg(),Sig_Dim(clrBlack,0),55) :
                         Sig_Tp2Bg()), dimPct);
   color cTP3 = Sig_Dim(Sig_FillC(h3 ? Sig_TpHitBg() :
                         broke ? Sig_Blend(Sig_Tp3Bg(),Sig_Dim(clrBlack,0),55) :
                         Sig_Tp3Bg()), dimPct);

   // Rectangles
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL, entry, tR, sl,  cSL,  InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL, entry, tR, tp1, cTP1, InpSigFill);
   if(tp2 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP2"), tL, tp1, tR, tp2, cTP2, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP3"), tL, tp2, tR, tp3, cTP3, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP3"));

   // Entry line
   if(!broke && !bounced)
      Sig_HLine(Sig_N(ai,ti,"ELINE"), tL, tR, entry,
                Sig_Dim(Sig_EntryLine(), dimPct), 1);
   else
      Sig_DelObj(Sig_N(ai,ti,"ELINE"));

   //── Labels by lifecycle state ─────────────────────────────────
   if(broke) {
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));     Sig_DelObj(Sig_N(ai,ti,"LBL_ZONE"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
   }
   else if(bounced) {
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
      double midProt = (entry + tp1) / 2.0;
      Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midProt, "PROTECTED",
               (color)(InpSigLightBg ? C'130,100,0' : C'200,165,40'), fsz, ANCHOR_CENTER);
   }
   else if(isPreview) {
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
      // [P] + strength label with cls color
      double midSL = (entry + sl) / 2.0;
      string pLbl  = "[P] [" + Sig_ClsStr(z.clsLevel) + "] " + z.code;
      Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midSL, pLbl,
               Sig_Dim(Sig_ClsColor(z.clsLevel), 20), fsz, ANCHOR_CENTER);
   }
   else {
      // INCOMING or ACTIVE: full labels

      // SL zone label — shows strength always; narrow = abbreviated
      {
         string slLbl;
         if(narrow)
            slLbl = "SL [" + Sig_ClsStr(z.clsLevel) + "] " + z.code;
         else {
            slLbl = "[" + Sig_ClsStr(z.clsLevel) + "] " + z.code + " " + z.angleCls;
            if(isIncoming) slLbl = "[I] " + slLbl;
         }
         double midSL   = (entry + sl) / 2.0;
         color  slLblC  = narrow ? Sig_ClsColor(z.clsLevel) : Sig_ZoneLblColor();
         Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midSL, slLbl,
                  Sig_Dim(slLblC, dimPct), fsz, ANCHOR_CENTER);
      }

      // Inner TP labels
      {
         double midTP1 = (entry + tp1) / 2.0;
         Sig_Text(Sig_N(ai,ti,"LBL_TP1_IN"), midT, midTP1, "TP1",
                  Sig_Dim(h1 ? Sig_ZoneLblColor() : Sig_LblTP1(), dimPct), fsz, ANCHOR_CENTER);
         if(tp2 != 0.0) {
            double midTP2 = (tp1 + tp2) / 2.0;
            Sig_Text(Sig_N(ai,ti,"LBL_TP2_IN"), midT, midTP2, "TP2",
                     Sig_Dim(h2 ? Sig_ZoneLblColor() : Sig_LblTP2(), dimPct), fsz, ANCHOR_CENTER);
         } else { Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN")); }
         if(tp3 != 0.0) {
            double midTP3 = (tp2 + tp3) / 2.0;
            Sig_Text(Sig_N(ai,ti,"LBL_TP3_IN"), midT, midTP3, "TP3",
                     Sig_Dim(h3 ? Sig_ZoneLblColor() : Sig_LblTP3(), dimPct), fsz, ANCHOR_CENTER);
         } else { Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN")); }
      }

      // Price labels on right edge — controlled by InpSigShowPrices
      if(InpSigShowPrices) {
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_E"),  tR, entry, "E:", Sig_Dim(Sig_LblEntry(),dimPct), fsz);
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_SL"), tR, sl,    "S:", Sig_Dim(Sig_LblSL(),   dimPct), fsz);
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_T1"), tR, tp1,   "1:", Sig_Dim(Sig_LblTP1(),  dimPct), fsz);
         if(tp2 != 0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T2"), tR, tp2, "2:", Sig_Dim(Sig_LblTP2(),dimPct), fsz);
         else           Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
         if(tp3 != 0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T3"), tR, tp3, "3:", Sig_Dim(Sig_LblTP3(),dimPct), fsz);
         else           Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      } else {
         Sig_DelObj(Sig_N(ai,ti,"LBL_E")); Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
         Sig_DelObj(Sig_N(ai,ti,"LBL_T1")); Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
         Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      }
   }

   // Delete legacy PREV_* remnants
   Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
   Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
   Sig_DelObj(Sig_N(ai,ti,"PREV_LBL"));
}

//══════════════════════════════════════════════════════════════════
//  Alerts
//══════════════════════════════════════════════════════════════════
void Sig_InitAlerts()
{
   if(g_sigAlertInit) return;
   ArrayInitialize(g_sigAlertTs, 0);
   ArrayInitialize(g_sigMultiTs, 0);
   g_sigAlertInit = true;
}

void Sig_CheckTouchAlert(int ai, int ti, const string code, const string dir)
{
   if(!InpSigAlerts || ai >= 1024) return;
   datetime touchT = g_mon[ai].test[ti].touchTime;
   if(touchT <= 0 || g_sigAlertTs[ai][ti] == touchT) return;
   g_sigAlertTs[ai][ti] = touchT;
   if(g_mon[ai].test[ti].react[0] == MON_REACT_PENDING) {
      double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * g_mon[ai].test[ti].away;
      Alert("AIB: ", dir, " ", g_mon[ai].cls, " @ ", DoubleToString(entry,Digits),
            "  [", Sig_TestName(ti), "|", code, "]");
   }
}

//══════════════════════════════════════════════════════════════════
//  Panel entry
//══════════════════════════════════════════════════════════════════
struct SigEntry {
   int    ai, ti, clsLevel;
   string code, clsL, testName, dir;
   double score;
   bool   isPending, isIncoming;
};

//══════════════════════════════════════════════════════════════════
//  Advisory text
//══════════════════════════════════════════════════════════════════
string Sig_BuildAdvice(SigEntry &entries[], int eCount, int &topClsOut)
{
   topClsOut = 0;
   if(eCount == 0) return "No signals. Wait for next angle.";

   double topScore = -1; int topIdx = -1;
   double incScore = -1; int incIdx = -1;
   int    pendBuy  = 0,  pendSell  = 0;

   for(int i = 0; i < eCount; i++) {
      if(entries[i].isPending) {
         if(entries[i].score > topScore) { topScore=entries[i].score; topIdx=i; }
         if(entries[i].dir=="BUY") pendBuy++; else pendSell++;
      }
      if(entries[i].isIncoming && entries[i].score > incScore)
         { incScore=entries[i].score; incIdx=i; }
   }

   if(topIdx < 0) {
      if(incIdx >= 0) {
         SigEntry inc = entries[incIdx];
         topClsOut = inc.clsLevel;
         return "INCOMING: "+inc.code+" "+inc.dir+" — Approaching. Prepare.";
      }
      int bounceN = 0, breakN = 0;
      for(int i = 0; i < eCount; i++) {
         int r = g_mon[entries[i].ai].test[entries[i].ti].react[0];
         if(r == MON_REACT_BOUNCE) bounceN++;
         if(r == MON_REACT_BREAK)  breakN++;
      }
      if(bounceN > 0) return StringFormat("%d signal(s) hit target. Watch for new setup.", bounceN);
      if(breakN  > 0) return StringFormat("%d signal(s) stopped out. Wait for next setup.", breakN);
      return "Signals resolved. Monitor for new angles.";
   }

   if(pendBuy > 0 && pendSell > 0) return "BUY + SELL conflict — stay flat.";

   SigEntry top = entries[topIdx];
   topClsOut = top.clsLevel;
   int cnt = pendBuy + pendSell;
   string d = top.dir;

   if(top.clsLevel == 5) {
      if(cnt >= 2) return StringFormat("Full Margin x%d [%s] — Highest confidence. Enter full size.", cnt, d);
      return "Full Margin: "+top.code+" ["+d+"] — Enter full position size.";
   }
   if(top.clsLevel == 4) {
      if(cnt >= 2) return StringFormat("Strong x%d [%s] — Multiple signals. Enter now.", cnt, d);
      return "Strong: "+top.code+" ["+d+"] — Enter, standard risk.";
   }
   if(top.clsLevel == 3) {
      if(cnt >= 2) return StringFormat("Good x%d [%s] — Acceptable. Enter at market.", cnt, d);
      return "Good: "+top.code+" ["+d+"] — Acceptable risk. Enter.";
   }
   if(top.clsLevel == 2) return "Weak: "+top.code+" ["+d+"] — Reduce size or avoid.";
   return "Very Weak signal. Do not trade — wait for better setup.";
}

//══════════════════════════════════════════════════════════════════
//  Panel — CORNER_LEFT_LOWER
//══════════════════════════════════════════════════════════════════
void Sig_DeletePanel()
{
   int tot = ObjectsTotal();
   for(int i = tot-1; i >= 0; i--) {
      string nm = ObjectName(i);
      if(StringFind(nm,SIG_PFX+"PANEL_",0)==0 || StringFind(nm,SIG_PFX+"BTN_",0)==0)
         ObjectDelete(0,nm);
   }
}

void Sig_DrawPanel(SigEntry &entries[], int eCount)
{
   if(!InpSigShowPanel) { Sig_DeletePanel(); return; }

   int activeCnt = 0, comingCnt = 0;
   for(int i = 0; i < eCount; i++) {
      if(entries[i].isPending)  activeCnt++;
      if(entries[i].isIncoming) comingCnt++;
   }

   int dispRows = MathMin(eCount, InpSigMaxRows);
   int headerH  = 24;
   int bodyH    = MathMax(dispRows,1) * ROW_H + 6;
   int adviceH  = InpSigShowAdvice ? ADVICE_H + 6 : 0;
   int btnRowH  = BTN_H + 10;
   int sepH     = 4;
   int totalH   = headerH + sepH + bodyH + (adviceH>0 ? sepH+adviceH : 0) + sepH + btnRowH;

   int PX   = InpSigPanelX;
   int mgn  = MathMax(InpSigPanelY, 0);
   int PW   = PANEL_W;
   int corn = CORNER_LEFT_LOWER;
   int base = totalH + mgn;

   Sig_SRect(Sig_PN("BG"),  PX, base, PW, totalH,  Sig_PanelBg(),  corn);
   Sig_SRect(Sig_PN("HDR"), PX, base, PW, headerH, Sig_PanelHdr(), corn);

   string modeStr = "";
   if(g_sigPickHide) modeStr = " [PICK-HIDE]";
   if(g_sigPickShow) modeStr = " [PICK-SHOW]";
   if(g_sigHideAll)  modeStr = " [HIDDEN]";

   color modeCol = g_sigPickHide ? Sig_BtnActive() :
                  (g_sigPickShow ? Sig_Blend(Sig_BtnActive(),(color)C'200,200,0',30) :
                  (g_sigHideAll  ? Sig_BtnDanger() : Sig_PanelTxt()));

   Sig_SLabel(Sig_PN("TITLE"), PX+8, base-7,
              StringFormat("AIB SIGNAL v4.4  %d active  %d coming%s",
                           activeCnt, comingCnt, modeStr),
              modeCol, 9, corn);

   int rowBase = headerH + sepH;
   for(int i = 0; i < dispRows; i++) {
      SigEntry e = entries[i];
      string mk      = e.isPending ? ">" : (e.isIncoming ? "~" : ".");
      string stateTag = e.isPending ? "[P]" : (e.isIncoming ? "[I]" : "   ");
      string rowTxt = StringFormat("%s %-5s Z%s %-9s %s %s %s",
                                   mk, e.code, e.clsL,
                                   Sig_ClsStr(e.clsLevel),
                                   stateTag, e.testName, e.dir);
      color rowCol = Sig_ClsColor(e.clsLevel);
      if(!e.isPending && !e.isIncoming)
         rowCol = Sig_Blend(rowCol, Sig_PanelBg(), 40);
      else if(e.isIncoming)
         rowCol = Sig_Blend(rowCol, Sig_LblTP1(), 25);
      Sig_SLabel(Sig_PN("ROW"+IntegerToString(i)),
                 PX+6, base-(rowBase+i*ROW_H), rowTxt, rowCol, 8, corn);
   }

   if(eCount > dispRows)
      Sig_SLabel(Sig_PN("MORE"), PX+6, base-(rowBase+dispRows*ROW_H),
                 StringFormat("... +%d more", eCount-dispRows),
                 Sig_Blend(Sig_PanelTxt(),Sig_PanelBg(),50), 7, corn);
   else Sig_DelObj(Sig_PN("MORE"));
   for(int i = dispRows; i < InpSigMaxRows+2; i++) Sig_DelObj(Sig_PN("ROW"+IntegerToString(i)));

   int nextRelY = rowBase + MathMax(dispRows,1)*ROW_H + 6;

   if(InpSigShowAdvice) {
      nextRelY += sepH;
      int    topCls = 0;
      string advice = Sig_BuildAdvice(entries, eCount, topCls);
      Sig_SRect(Sig_PN("ADVBG"),  PX+4, base-nextRelY, PW-8, ADVICE_H,
                Sig_AdvBorder(Sig_ClsColor(topCls)), corn);
      Sig_SLabel(Sig_PN("ADVHDR"),PX+8, base-(nextRelY+3), "ADVICE",
                 Sig_Blend(Sig_PanelTxt(),Sig_PanelBg(),40), 7, corn);
      color advTxtCol = Sig_AdviceColor(topCls);
      int maxCh = (PW-22)/6;
      if(StringLen(advice) > maxCh) {
         int sp = maxCh;
         for(int c = maxCh; c > maxCh-18 && c > 0; c--)
            if(StringGetCharacter(advice,c)==' ') { sp=c; break; }
         Sig_SLabel(Sig_PN("ADVL1"), PX+8, base-(nextRelY+14),
                    StringSubstr(advice,0,sp),  advTxtCol, 8, corn);
         Sig_SLabel(Sig_PN("ADVL2"), PX+8, base-(nextRelY+26),
                    StringSubstr(advice,sp+1),  Sig_Blend(advTxtCol,Sig_PanelBg(),35), 8, corn);
      } else {
         Sig_SLabel(Sig_PN("ADVL1"), PX+8, base-(nextRelY+14), advice, advTxtCol, 8, corn);
         Sig_DelObj(Sig_PN("ADVL2"));
      }
      nextRelY += ADVICE_H + sepH;
   } else {
      Sig_DelObj(Sig_PN("ADVBG")); Sig_DelObj(Sig_PN("ADVHDR"));
      Sig_DelObj(Sig_PN("ADVL1")); Sig_DelObj(Sig_PN("ADVL2"));
   }

   int btnRelY = nextRelY + sepH;
   int bX = PX + 4;
   color btnTxt = Sig_BtnText();

   Sig_SBtn(Sig_BN("HIDEALL"),  bX,               base-btnRelY, BTN_W,BTN_H,"Hide All",
            g_sigHideAll  ? Sig_BtnDanger() : Sig_BtnNormal(), btnTxt, corn);
   Sig_SBtn(Sig_BN("SHOWALL"),  bX+BTN_W+3,       base-btnRelY, BTN_W,BTN_H,"Show All",
            Sig_BtnNormal(), btnTxt, corn);
   Sig_SBtn(Sig_BN("PICKHIDE"), bX+(BTN_W+3)*2,   base-btnRelY, BTN_W,BTN_H,"Hide Zone",
            g_sigPickHide ? Sig_BtnActive() : Sig_BtnNormal(),
            g_sigPickHide ? Sig_BtnText() : btnTxt, corn);
   Sig_SBtn(Sig_BN("PICKSHOW"), bX+(BTN_W+3)*3,   base-btnRelY, BTN_W,BTN_H,"Pick Ang",
            g_sigPickShow ? Sig_BtnActive() : Sig_BtnNormal(),
            g_sigPickShow ? Sig_BtnText() : btnTxt, corn);
}

//══════════════════════════════════════════════════════════════════
//  Button / chart event handling
//══════════════════════════════════════════════════════════════════
void Sig_CheckButtons()
{
   if(ObjectFind(0,Sig_BN("HIDEALL"))>=0 &&
      ObjectGetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE)) {
      g_sigHideAll = !g_sigHideAll;
      if(g_sigHideAll) { g_sigPickHide=false; g_sigPickShow=false; }
      ObjectSetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("SHOWALL"))>=0 &&
      ObjectGetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE)) {
      g_sigHideAll = false;
      if(g_sigHideInit) ArrayInitialize(g_sigHide,false);
      g_sigPickHide=false; g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKHIDE"))>=0 &&
      ObjectGetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE)) {
      g_sigPickHide = !g_sigPickHide;
      if(g_sigPickHide) g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKSHOW"))>=0 &&
      ObjectGetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE)) {
      g_sigPickShow = !g_sigPickShow;
      if(g_sigPickShow) g_sigPickHide=false;
      ObjectSetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE,false); ChartRedraw(0);
   }
}

bool Sig_ParseName(const string nm, int &ai, int &ti)
{
   if(StringFind(nm,SIG_PFX,0)!=0) return false;
   string rest = StringSubstr(nm, StringLen(SIG_PFX));
   int p1 = StringFind(rest,"_",0);    if(p1<0) return false;
   int p2 = StringFind(rest,"_",p1+1); if(p2<0) return false;
   ai = (int)StringToInteger(StringSubstr(rest,0,p1));
   ti = (int)StringToInteger(StringSubstr(rest,p1+1,p2-p1-1));
   return (ai>=0 && ai<1024 && ti>=0 && ti<4);
}

void Sig_OnChartEvent(const int id, const long lparam,
                      const double dparam, const string sparam)
{
   if(!InpSigEnabled) return;
   if(id == CHARTEVENT_OBJECT_CLICK) {
      if(StringFind(sparam,SIG_PFX+"BTN_",0)==0) return;
      if(g_sigPickHide && StringFind(sparam,SIG_PFX,0)==0) {
         int ai=-1, ti=-1;
         if(Sig_ParseName(sparam,ai,ti)) {
            if(!g_sigHideInit) { ArrayInitialize(g_sigHide,false); g_sigHideInit=true; }
            g_sigHide[ai][ti]=true; Sig_DeleteZone(ai,ti);
            g_sigPickHide=false; ChartRedraw(0);
         }
         return;
      }
   }
   if(id == CHARTEVENT_CLICK && g_sigPickShow) {
      datetime clickT=0; double clickP=0.0; int subwin=0;
      if(!ChartXYToTimePrice(0,(int)lparam,(int)dparam,subwin,clickT,clickP)) return;
      int bestAi=-1; long bestDt=LONG_MAX;
      for(int i=0; i<g_monCount; i++) {
         if(!g_mon[i].valid) continue;
         long dt = MathAbs((long)g_mon[i].formTime-(long)clickT);
         if(dt<bestDt) { bestDt=dt; bestAi=i; }
      }
      if(bestAi >= 0) {
         if(!g_sigHideInit) { ArrayInitialize(g_sigHide,false); g_sigHideInit=true; }
         for(int i=0; i<g_monCount&&i<1024; i++)
            for(int t=0; t<4; t++) g_sigHide[i][t]=(i!=bestAi);
         g_sigHideAll=false; g_sigPickShow=false; ChartRedraw(0);
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Sig_OnCalculate — three passes: collect → slots → draw
//══════════════════════════════════════════════════════════════════
void Sig_OnCalculate()
{
   if(!InpSigEnabled) return;
   if(!g_sigHideInit) { ArrayInitialize(g_sigHide,false); g_sigHideInit=true; }
   ComboTable_Init();
   Sig_InitAlerts();
   Sig_CheckButtons();

   SigZone  zones[];   int zCount = 0;
   SigEntry entries[]; int eCount = 0;
   ArrayResize(zones,   g_monCount * MON_NPTS);
   ArrayResize(entries, g_monCount * MON_NPTS);

   //── Pass 1: collect qualifying zones ──────────────────────────
   for(int ai = 0; ai < g_monCount; ai++) {
      if(!g_mon[ai].valid) continue;

      string cls   = g_mon[ai].cls;
      string clsL  = (StringLen(cls)>=2 ? StringSubstr(cls,1,1) : cls);
      string dir   = (g_mon[ai].dir > 0 ? "BUY" : "SELL");
      bool   isBuy = (g_mon[ai].dir > 0);
      double rat   = g_mon[ai].ratio;
      double lu1   = (g_mon[ai].u1R > 1e-10 ? g_mon[ai].L / g_mon[ai].u1R * 100.0 : 0.0);
      string prev  = Sig_PrevClsLtr(ai);
      string code  = ComboCode(cls, dir, rat, lu1, prev);
      int    cidx  = ComboFind(code);

      // cidx==-1: combo not in table → skip this angle entirely
      if(cidx < 0) {
         for(int ti = 0; ti < MON_NPTS; ti++) Sig_DeleteZone(ai,ti);
         continue;
      }

      int clsLvl = Sig_Classify(cidx);
      if(clsLvl <= 1) {  // skip unknown(0) and Very Weak/tier5(1)
         for(int ti = 0; ti < MON_NPTS; ti++) Sig_DeleteZone(ai,ti);
         continue;
      }

      // Determine which tests to show (top 2 untouched + all touched)
      bool showTi[4] = {false, false, false, false};
      Sig_SelectTests(ai, cidx, showTi);

      for(int ti = 0; ti < MON_NPTS; ti++) {
         int react = g_mon[ai].test[ti].react[0];

         // Skip if NA or not selected by ranking
         if(react == MON_REACT_NA || !showTi[ti]) {
            Sig_DeleteZone(ai,ti);
            continue;
         }

         bool isUntouch  = (react == MON_REACT_UNTOUCHED);
         bool isIncoming = false;

         if(isUntouch) {
            if(Sig_IsOld(ai)) { Sig_DeleteZone(ai,ti); continue; }
            isIncoming = Sig_IsIncoming(ai, ti);
         }

         double score  = Sig_Score(cidx, ti);
         bool isPreview = isUntouch;

         double away  = g_mon[ai].test[ti].away;
         double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * away;
         double sl    = entry + g_mon[ai].B * away;
         double tp1   = g_mon[ai].test[ti].tp[0];
         double pMin  = MathMin(MathMin(entry,sl), tp1);
         double pMax  = MathMax(MathMax(entry,sl), tp1);

         // Trade direction is determined by zone's own away value, not parent angle dir
         // away < 0 → entry below anchor, SL below → BUY trade
         // away > 0 → entry above anchor, SL above → SELL trade
         string zoneDir = (away < 0) ? "BUY" : "SELL";
         bool   zoneBuy = (away < 0);

         datetime bTime = isUntouch ? g_mon[ai].formTime : g_mon[ai].test[ti].touchTime;
         if(!isUntouch && bTime <= 0) { Sig_DeleteZone(ai,ti); continue; }

         SigZone z;
         z.ai=ai; z.ti=ti; z.clsLevel=clsLvl; z.score=score;
         z.code=code; z.clsL=clsL; z.dir=zoneDir; z.angleCls=cls; z.isBuy=zoneBuy;
         z.isPreview=isPreview; z.isIncoming=isIncoming;
         z.pMin=pMin; z.pMax=pMax; z.baseTime=bTime;
         z.grpId=0; z.grpSlot=0; z.grpSize=1;
         z.slotTL=bTime; z.slotTR=bTime+(datetime)g_unitSeconds;
         zones[zCount++]=z;

         SigEntry e;
         e.ai=ai; e.ti=ti; e.clsLevel=clsLvl; e.score=score;
         e.code=code; e.clsL=clsL; e.testName=Sig_TestName(ti); e.dir=zoneDir;
         e.isPending  = (react == MON_REACT_PENDING);
         e.isIncoming = isIncoming;
         entries[eCount++]=e;

         if(!isUntouch) Sig_CheckTouchAlert(ai,ti,code,zoneDir);
      }
   }

   //── Pass 2: resolve time slots ────────────────────────────────
   if(zCount > 0) Sig_ComputeSlots(zones, zCount);

   //── Pass 3: draw ──────────────────────────────────────────────
   for(int i = 0; i < zCount; i++) {
      SigZone z = zones[i];
      if(!Sig_IsVisible(z.ai,z.ti)) { Sig_DeleteZone(z.ai,z.ti); continue; }
      Sig_DrawZoneV4(zones[i]);
   }

   // Sort: PENDING first → INCOMING → historical; within group by score desc
   for(int i=0; i<eCount-1; i++)
      for(int j=i+1; j<eCount; j++) {
         int pi = entries[i].isPending ? 2 : (entries[i].isIncoming ? 1 : 0);
         int pj = entries[j].isPending ? 2 : (entries[j].isIncoming ? 1 : 0);
         if(pi < pj || (pi == pj && entries[i].score < entries[j].score))
            { SigEntry tmp=entries[i]; entries[i]=entries[j]; entries[j]=tmp; }
      }

   Sig_DrawPanel(entries, eCount);
   ChartRedraw(0);
}

//══════════════════════════════════════════════════════════════════
//  Deinit
//══════════════════════════════════════════════════════════════════
void Sig_OnDeinit()
{
   int tot = ObjectsTotal();
   for(int i = tot-1; i >= 0; i--) {
      string nm = ObjectName(i);
      if(StringFind(nm,SIG_PFX,0)==0) ObjectDelete(0,nm);
   }
}
