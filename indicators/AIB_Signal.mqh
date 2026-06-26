//==================================================================
//  AIB_Signal.mqh  v4.2
//
//  Visual zone lifecycle:
//    UNTOUCHED + far  → PREVIEW   (solid, 50% dim, label [P])
//    UNTOUCHED + near → INCOMING  (solid, 20% dim, all labels)
//    PENDING          → ACTIVE    (full brightness)
//    BOUNCE (TP1 hit) → CLOSED/B  (shrink 6 candles, "PROTECTED")
//    BREAK  (SL  hit) → CLOSED/K  (shrink 3 candles, no text)
//    UNTOUCHED after InpSigUntouchedMax newer angles → auto-delete
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep1           = "─── AIB Signal v4.2 ────";
input bool   InpSigEnabled        = true;

input string InpSigSep2           = "─── Display ─────────────";
input bool   InpSigShowPreview    = true;
input bool   InpSigShowPending    = true;
input bool   InpSigShowHistory    = true;
input bool   InpSigFill           = true;

input string InpSigSep3           = "─── Incoming Zone ───────";
input int    InpSigIncomingPips   = 20;    // pips from entry → INCOMING
input int    InpSigIncomingBars   = 1;     // chart candles since formTime → INCOMING
input int    InpSigBreakBars      = 3;     // candles to keep BREAK zone
input int    InpSigBounceBars     = 6;     // candles to keep BOUNCE zone
input int    InpSigUntouchedMax   = 10;    // newer angles before auto-delete

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
input int    InpSigFontSize       = 8;

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

// Dim a color toward black by pct percent (0=unchanged, 50=half brightness, 100=black)
color Sig_Dim(color c, int pct)
{
   if(pct <= 0) return c;
   pct = MathMin(pct, 100);
   int b = ((int)c & 255)         * (100-pct) / 100;
   int g = (((int)c >> 8)  & 255) * (100-pct) / 100;
   int r = (((int)c >> 16) & 255) * (100-pct) / 100;
   return (color)(b | (g<<8) | (r<<16));
}

color Sig_SlBg()      { return (color)C'160,22,22';   }
color Sig_Tp1Bg()     { return (color)C'18,85,45';    }
color Sig_Tp2Bg()     { return (color)C'15,70,62';    }
color Sig_Tp3Bg()     { return (color)C'12,55,72';    }
color Sig_TpHitBg()   { return (color)C'22,115,80';   }
color Sig_FailBg()    { return (color)C'48,10,10';    }
color Sig_EntryLine() { return (color)C'100,145,195'; }

color Sig_LblEntry()  { return (color)C'130,172,218'; }
color Sig_LblSL()     { return (color)C'255,110,110'; }
color Sig_LblTP1()    { return (color)C'90,200,125';  }
color Sig_LblTP2()    { return (color)C'75,175,158';  }
color Sig_LblTP3()    { return (color)C'65,150,185';  }

//══════════════════════════════════════════════════════════════════
//  Classification
//══════════════════════════════════════════════════════════════════
int Sig_Classify(int cidx)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0;
   if(g_combos[cidx].n_ang < 40)       return 1;
   double p = g_combos[cidx].p_total;
   if(p >= 45.0) return 4;
   if(p >= 30.0) return 3;
   if(p >= 10.0) return 2;
   return 1;
}

string Sig_ClsStr(int lvl)
{
   switch(lvl) {
      case 4: return "STRONG";
      case 3: return "GOOD";
      case 2: return "WEAK";
      case 1: return "VERY WEAK";
   }
   return "NO TRADE";
}

color Sig_ClsColor(int lvl)
{
   switch(lvl) {
      case 4: return (color)C'28,190,100';
      case 3: return (color)C'190,155,40';
      case 2: return (color)C'82,118,155';
      case 1: return (color)C'92,92,92';
   }
   return (color)C'52,52,52';
}

color Sig_AdviceColor(int lvl)
{
   if(lvl == 4) return (color)C'218,175,32';
   if(lvl == 3) return (color)C'60,200,90';
   if(lvl >= 1) return (color)C'210,55,55';
   return clrWhite;
}

double Sig_Score(int cidx, int ti)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0.0;
   return g_combos[cidx].nok[ti] * (g_combos[cidx].p1[ti] / 100.0);
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
   ObjectSetInteger(0,nm,OBJPROP_COLOR,      Sig_Blend(c,clrSilver,20));
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

// Returns true if zone is "INCOMING" (price near entry OR zone is brand new)
bool Sig_IsIncoming(int ai, int ti)
{
   double away  = g_mon[ai].test[ti].away;
   double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * away;

   // Price proximity check: use Ask for resistance (away>0), Bid for support (away<0)
   double curPrice = (away > 0 ? Ask : Bid);
   double pips     = MathAbs(curPrice - entry) / Sig_PipSz();
   if(pips <= (double)InpSigIncomingPips) return true;

   // Time proximity: zone formed within InpSigIncomingBars chart candles ago
   long barSecs    = (long)Period() * 60;
   long elapsed    = (long)(Time[0] - g_mon[ai].formTime) / MathMax(barSecs, 1);
   if(elapsed >= 0 && elapsed <= (long)InpSigIncomingBars) return true;

   return false;
}

// Returns true if this UNTOUCHED zone has >= InpSigUntouchedMax newer angles
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
   long gapSecs = 2 * barSecs;   // 2-candle gap between overlapping slots

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
         int idx = members[s];
         zones[idx].grpSlot = (s < slotCount) ? s : -1;
         zones[idx].grpSize = slotCount;
      }
   }

   for(int i = 0; i < n; i++) {
      int  slot = zones[i].grpSlot;
      int  N    = zones[i].grpSize;
      if(slot<0||N<=0) { slot=0; N=1; }
      datetime base    = zones[i].baseTime;
      long     unitLen = (long)g_unitSeconds;
      long     totalGap = gapSecs * (long)(N - 1);
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
//  Draw one zone (all lifecycle states)
//══════════════════════════════════════════════════════════════════
void Sig_DrawZoneV4(SigZone &z)
{
   int  ai = z.ai, ti = z.ti;
   int  react      = g_mon[ai].test[ti].react[0];
   bool isPending  = (react == MON_REACT_PENDING);
   bool bounced    = (react == MON_REACT_BOUNCE);
   bool broke      = (react == MON_REACT_BREAK);
   bool isIncoming = z.isIncoming;
   bool isPreview  = z.isPreview && !isIncoming;   // PREVIEW = untouched AND far

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

   datetime tL = z.slotTL;
   datetime tR = z.slotTR;
   long barSecs = (long)Period() * 60;

   // BREAK: shrink to InpSigBreakBars candles
   if(broke)   tR = tL + (datetime)((long)InpSigBreakBars  * barSecs);
   // BOUNCE: shrink to InpSigBounceBars candles
   if(bounced) tR = tL + (datetime)((long)InpSigBounceBars * barSecs);

   datetime midT = tL + (datetime)((tR - tL) / 2);
   bool narrow   = (z.grpSize > 1);
   int  fsz      = MathMax(5, InpSigFontSize - MathMax(0, z.grpSize-1));

   // Dim factor per state
   int dimPct = 0;
   if(isPreview)  dimPct = 50;
   if(isIncoming) dimPct = 20;
   if(broke)      dimPct = 60;

   // SL zone colors
   color cSL = Sig_Dim(broke ? Sig_FailBg() : Sig_SlBg(), dimPct);
   if(bounced) cSL = Sig_Dim(Sig_Blend(Sig_SlBg(), clrBlack, 30), dimPct);

   // TP colors
   color cTP1 = Sig_Dim(h1 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_Tp1Bg(),clrBlack,55) : Sig_Tp1Bg()), dimPct);
   color cTP2 = Sig_Dim(h2 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_Tp2Bg(),clrBlack,55) : Sig_Tp2Bg()), dimPct);
   color cTP3 = Sig_Dim(h3 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_Tp3Bg(),clrBlack,55) : Sig_Tp3Bg()), dimPct);

   // Rectangles
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL, entry, tR, sl,  cSL,  InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL, entry, tR, tp1, cTP1, InpSigFill);
   if(tp2 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP2"), tL, tp1, tR, tp2, cTP2, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3 != 0.0) Sig_Rect(Sig_N(ai,ti,"TP3"), tL, tp2, tR, tp3, cTP3, InpSigFill);
   else           Sig_DelObj(Sig_N(ai,ti,"TP3"));

   // Entry line (not shown for BREAK/BOUNCE)
   if(!broke && !bounced)
      Sig_HLine(Sig_N(ai,ti,"ELINE"), tL, tR, entry, Sig_Dim(Sig_EntryLine(), dimPct), 1);
   else
      Sig_DelObj(Sig_N(ai,ti,"ELINE"));

   //── Labels by state ───────────────────────────────────────────
   if(broke) {
      // BREAK: no text at all
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));     Sig_DelObj(Sig_N(ai,ti,"LBL_ZONE"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
   }
   else if(bounced) {
      // BOUNCE: only "PROTECTED" in center
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
      double midProt = (entry + tp1) / 2.0;
      Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midProt, "PROTECTED",
               (color)C'200,165,40', fsz, ANCHOR_CENTER);
   }
   else if(isPreview) {
      // PREVIEW: [P] label only in SL zone, no price labels
      Sig_DelObj(Sig_N(ai,ti,"LBL_E"));      Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1"));     Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP1_IN")); Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN"));
      double midSL = (entry + sl) / 2.0;
      string pLbl  = "[P] " + z.code + " " + z.angleCls;
      Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midSL, pLbl,
               Sig_Dim((color)C'165,152,52', 30), fsz, ANCHOR_CENTER);
   }
   else {
      // INCOMING or ACTIVE: full labels
      // SL zone: [STRENGTH] code angleCls
      {
         string zoneLbl = "["+Sig_ClsStr(z.clsLevel)+"] "+z.code+" "+z.angleCls;
         if(isIncoming) zoneLbl = "[I] " + zoneLbl;
         double midSL = (entry + sl) / 2.0;
         Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midSL, zoneLbl,
                  Sig_Dim(clrWhite, dimPct), fsz, ANCHOR_CENTER);
      }

      // Inner TP labels — short if narrow, long otherwise
      {
         string lTP1 = narrow ? "TP1" : "TP1";
         string lTP2 = narrow ? "TP2" : "TP2";
         string lTP3 = narrow ? "TP3" : "TP3";

         double midTP1 = (entry + tp1) / 2.0;
         Sig_Text(Sig_N(ai,ti,"LBL_TP1_IN"), midT, midTP1, lTP1,
                  Sig_Dim(h1 ? clrWhite : Sig_LblTP1(), dimPct), fsz, ANCHOR_CENTER);

         if(tp2 != 0.0) {
            double midTP2 = (tp1 + tp2) / 2.0;
            Sig_Text(Sig_N(ai,ti,"LBL_TP2_IN"), midT, midTP2, lTP2,
                     Sig_Dim(h2 ? clrWhite : Sig_LblTP2(), dimPct), fsz, ANCHOR_CENTER);
         } else { Sig_DelObj(Sig_N(ai,ti,"LBL_TP2_IN")); }

         if(tp3 != 0.0) {
            double midTP3 = (tp2 + tp3) / 2.0;
            Sig_Text(Sig_N(ai,ti,"LBL_TP3_IN"), midT, midTP3, lTP3,
                     Sig_Dim(h3 ? clrWhite : Sig_LblTP3(), dimPct), fsz, ANCHOR_CENTER);
         } else { Sig_DelObj(Sig_N(ai,ti,"LBL_TP3_IN")); }
      }

      // Price labels on right edge — omit if narrow (grpSize > 1)
      if(!narrow) {
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_E"),  tR, entry, "E:", Sig_Dim(Sig_LblEntry(),dimPct), fsz);
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_SL"), tR, sl,    "S:", Sig_Dim(Sig_LblSL(),   dimPct), fsz);
         Sig_PriceLabel(Sig_N(ai,ti,"LBL_T1"), tR, tp1,   "1:", Sig_Dim(Sig_LblTP1(),  dimPct), fsz);
         if(tp2 != 0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T2"), tR, tp2, "2:", Sig_Dim(Sig_LblTP2(),dimPct), fsz);
         else           Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
         if(tp3 != 0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T3"), tR, tp3, "3:", Sig_Dim(Sig_LblTP3(),dimPct), fsz);
         else           Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
      } else {
         // Narrow: short SL/TP labels inside rects, no right-edge price labels
         Sig_DelObj(Sig_N(ai,ti,"LBL_E")); Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
         Sig_DelObj(Sig_N(ai,ti,"LBL_T1")); Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
         Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
         // Replace SL zone label with just "SL"
         double midSL = (entry + sl) / 2.0;
         Sig_Text(Sig_N(ai,ti,"LBL_ZONE"), midT, midSL, "SL",
                  Sig_Dim(clrWhite, dimPct), fsz, ANCHOR_CENTER);
      }
   }

   // Delete legacy PREV_* objects (v4.1 remnants)
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
   int    pendBuy = 0, pendSell = 0;

   for(int i = 0; i < eCount; i++) {
      if(entries[i].isPending) {
         if(entries[i].score > topScore) { topScore = entries[i].score; topIdx = i; }
         if(entries[i].dir == "BUY") pendBuy++; else pendSell++;
      }
      if(entries[i].isIncoming) {
         if(entries[i].score > incScore) { incScore = entries[i].score; incIdx = i; }
      }
   }

   // No PENDING — check INCOMING
   if(topIdx < 0) {
      if(incIdx >= 0) {
         SigEntry inc = entries[incIdx];
         topClsOut = inc.clsLevel;
         return "INCOMING: " + inc.code + " " + inc.dir + " — Approaching. Prepare.";
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

   if(pendBuy > 0 && pendSell > 0)
      return "BUY + SELL conflict — stay flat.";

   SigEntry top = entries[topIdx];
   topClsOut = top.clsLevel;
   int    cnt = pendBuy + pendSell;
   string d   = top.dir;

   if(top.clsLevel == 4) {
      if(cnt >= 2) return StringFormat("STRONG x%d [%s] — Multiple signals. Enter now.", cnt, d);
      return "STRONG: "+top.code+" ["+d+"] — Enter, standard risk.";
   }
   if(top.clsLevel == 3) {
      if(cnt >= 2) return StringFormat("GOOD x%d [%s] — Acceptable. Enter at market.", cnt, d);
      return "GOOD: "+top.code+" ["+d+"] — Acceptable risk. Enter.";
   }
   if(top.clsLevel == 2)
      return "WEAK: "+top.code+" ["+d+"] — Reduce size or avoid.";
   return "VERY WEAK signal. Do not trade — wait for better setup.";
}

//══════════════════════════════════════════════════════════════════
//  Panel — anchored CORNER_LEFT_LOWER
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

   // Count active (PENDING) and coming (INCOMING)
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

   Sig_SRect(Sig_PN("BG"),  PX, base,  PW, totalH,  (color)C'12,15,22', corn);
   Sig_SRect(Sig_PN("HDR"), PX, base,  PW, headerH, (color)C'18,28,50', corn);

   string modeStr = "";
   if(g_sigPickHide) modeStr = " [PICK-HIDE]";
   if(g_sigPickShow) modeStr = " [PICK-SHOW]";
   if(g_sigHideAll)  modeStr = " [HIDDEN]";
   color modeCol = g_sigPickHide ? (color)C'210,140,40' :
                  (g_sigPickShow ? (color)C'210,210,60'  :
                  (g_sigHideAll  ? (color)C'200,68,68'   : (color)C'140,185,240'));

   string hdrTxt = StringFormat("AIB SIGNAL v4.2  %d active  %d coming%s",
                                activeCnt, comingCnt, modeStr);
   Sig_SLabel(Sig_PN("TITLE"), PX+8, base-7, hdrTxt, modeCol, 9, corn);

   int rowBase = headerH + sepH;
   for(int i = 0; i < dispRows; i++) {
      SigEntry e = entries[i];
      // Row marker: ">" PENDING, "~" INCOMING, "." historical
      string mk;
      if(e.isPending)       mk = ">";
      else if(e.isIncoming) mk = "~";
      else                  mk = ".";

      string stateTag = e.isPending ? "[P]" : (e.isIncoming ? "[I]" : "   ");
      string rowTxt = StringFormat("%s %-5s Z%s %-9s %s %s %s",
                                   mk, e.code, e.clsL,
                                   Sig_ClsStr(e.clsLevel),
                                   stateTag, e.testName, e.dir);
      color rowCol = Sig_ClsColor(e.clsLevel);
      if(!e.isPending && !e.isIncoming) rowCol = Sig_Blend(rowCol, clrBlack, 40);
      else if(e.isIncoming) rowCol = Sig_Blend(rowCol, (color)C'120,120,200', 25);
      Sig_SLabel(Sig_PN("ROW"+IntegerToString(i)),
                 PX+6, base-(rowBase+i*ROW_H), rowTxt, rowCol, 8, corn);
   }

   if(eCount > dispRows)
      Sig_SLabel(Sig_PN("MORE"), PX+6, base-(rowBase+dispRows*ROW_H),
                 StringFormat("... +%d more", eCount-dispRows),
                 (color)C'78,78,78', 7, corn);
   else
      Sig_DelObj(Sig_PN("MORE"));
   for(int i = dispRows; i < InpSigMaxRows+2; i++) Sig_DelObj(Sig_PN("ROW"+IntegerToString(i)));

   int nextRelY = rowBase + MathMax(dispRows,1)*ROW_H + 6;

   if(InpSigShowAdvice) {
      nextRelY += sepH;
      int    topCls = 0;
      string advice = Sig_BuildAdvice(entries, eCount, topCls);
      color advBorder = Sig_Blend(Sig_ClsColor(topCls), (color)C'12,16,28', 55);
      Sig_SRect(Sig_PN("ADVBG"),  PX+4, base-nextRelY, PW-8, ADVICE_H, advBorder, corn);
      Sig_SLabel(Sig_PN("ADVHDR"),PX+8, base-(nextRelY+3), "ADVICE",
                 (color)C'88,118,165', 7, corn);

      color advTxtCol = Sig_AdviceColor(topCls);
      int maxCh = (PW-22)/6;
      if(StringLen(advice) > maxCh) {
         int sp = maxCh;
         for(int c = maxCh; c > maxCh-18 && c > 0; c--)
            if(StringGetCharacter(advice,c)==' ') { sp=c; break; }
         Sig_SLabel(Sig_PN("ADVL1"), PX+8, base-(nextRelY+14),
                    StringSubstr(advice,0,sp),   advTxtCol, 8, corn);
         Sig_SLabel(Sig_PN("ADVL2"), PX+8, base-(nextRelY+26),
                    StringSubstr(advice,sp+1),   (color)C'185,185,185', 8, corn);
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
   color cN = (color)C'28,44,72';
   color cA = (color)C'72,44,14';
   color cD = (color)C'68,16,16';

   Sig_SBtn(Sig_BN("HIDEALL"),  bX,               base-btnRelY, BTN_W,BTN_H,"Hide All",
            g_sigHideAll  ? cD : cN, clrWhite, corn);
   Sig_SBtn(Sig_BN("SHOWALL"),  bX+BTN_W+3,       base-btnRelY, BTN_W,BTN_H,"Show All",  cN,clrWhite,corn);
   Sig_SBtn(Sig_BN("PICKHIDE"), bX+(BTN_W+3)*2,   base-btnRelY, BTN_W,BTN_H,"Hide Zone",
            g_sigPickHide ? cA : cN, g_sigPickHide ? clrYellow : clrWhite, corn);
   Sig_SBtn(Sig_BN("PICKSHOW"), bX+(BTN_W+3)*3,   base-btnRelY, BTN_W,BTN_H,"Pick Ang",
            g_sigPickShow ? cA : cN, g_sigPickShow ? clrYellow : clrWhite, corn);
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

      for(int ti = 0; ti < MON_NPTS; ti++) {
         int react = g_mon[ai].test[ti].react[0];
         if(react == MON_REACT_NA) { Sig_DeleteZone(ai,ti); continue; }

         int clsLvl = Sig_Classify(cidx);
         if(clsLvl <= 0) {
            Sig_DeleteZone(ai,ti);
            continue;
         }

         bool isUntouch  = (react == MON_REACT_UNTOUCHED);
         bool isIncoming = false;

         // UNTOUCHED zones: check if old (auto-delete) or incoming
         if(isUntouch) {
            if(Sig_IsOld(ai)) {
               Sig_DeleteZone(ai,ti);
               continue;
            }
            isIncoming = Sig_IsIncoming(ai, ti);
         }

         double score     = Sig_Score(cidx, ti);
         bool   isPreview = isUntouch;   // both PREVIEW and INCOMING are untouched

         double away  = g_mon[ai].test[ti].away;
         double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * away;
         double sl    = entry + g_mon[ai].B * away;
         double tp1   = g_mon[ai].test[ti].tp[0];
         double pMin  = MathMin(MathMin(entry,sl), tp1);
         double pMax  = MathMax(MathMax(entry,sl), tp1);

         // Base time: for UNTOUCHED use formTime; for touched use touchTime
         datetime bTime = isUntouch ? g_mon[ai].formTime : g_mon[ai].test[ti].touchTime;
         if(!isUntouch && bTime <= 0) { Sig_DeleteZone(ai,ti); continue; }

         SigZone z;
         z.ai=ai; z.ti=ti; z.clsLevel=clsLvl; z.score=score;
         z.code=code; z.clsL=clsL; z.dir=dir; z.angleCls=cls; z.isBuy=isBuy;
         z.isPreview=isPreview; z.isIncoming=isIncoming;
         z.pMin=pMin; z.pMax=pMax; z.baseTime=bTime;
         z.grpId=0; z.grpSlot=0; z.grpSize=1;
         z.slotTL=bTime; z.slotTR=bTime+(datetime)g_unitSeconds;
         zones[zCount++]=z;

         SigEntry e;
         e.ai=ai; e.ti=ti; e.clsLevel=clsLvl; e.score=score;
         e.code=code; e.clsL=clsL; e.testName=Sig_TestName(ti); e.dir=dir;
         e.isPending  = (react == MON_REACT_PENDING);
         e.isIncoming = isIncoming;
         entries[eCount++]=e;

         if(!isUntouch) Sig_CheckTouchAlert(ai,ti,code,dir);
      }
   }

   //── Pass 2: resolve time slots ────────────────────────────────
   if(zCount > 0) Sig_ComputeSlots(zones, zCount);

   //── Pass 3: draw ──────────────────────────────────────────────
   for(int i = 0; i < zCount; i++) {
      SigZone z = zones[i];
      int ai=z.ai, ti=z.ti;
      if(!Sig_IsVisible(ai,ti)) {
         Sig_DeleteZone(ai,ti);
         continue;
      }
      Sig_DrawZoneV4(zones[i]);
   }

   // Sort panel entries: PENDING first, then INCOMING, then historical; within each group by score
   for(int i=0; i<eCount-1; i++)
      for(int j=i+1; j<eCount; j++) {
         int pi = entries[i].isPending ? 2 : (entries[i].isIncoming ? 1 : 0);
         int pj = entries[j].isPending ? 2 : (entries[j].isIncoming ? 1 : 0);
         bool swap = (pi < pj) || (pi == pj && entries[i].score < entries[j].score);
         if(swap) { SigEntry tmp=entries[i]; entries[i]=entries[j]; entries[j]=tmp; }
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
