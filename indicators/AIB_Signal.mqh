//==================================================================
//  AIB_Signal.mqh  v3.0 — Clean visual output for AIB Angles
//
//  v3.0: Score-based strength system, simplified zone labels,
//        advisory panel, calm colors, 3-criteria quality filter.
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep1            = "─── AIB Signal v3.0 ────";
input bool   InpSigEnabled         = true;

input string InpSigSep2            = "─── Quality Filter ──────";
input double InpSigMinHitPct       = 50.0;  // Min TP1 hit% (historical)
input int    InpSigMinTouchCount   = 30;    // Min historical touches nt[ti]
input int    InpSigMinSuccessCount = 15;    // Min historical wins   nok[ti]
input bool   InpSigShowPreview     = true;  // Draw anticipatory preview

input string InpSigSep3            = "─── Panel ───────────────";
input bool   InpSigShowPanel       = true;
input int    InpSigMaxRows         = 6;     // Max signal rows in panel
input bool   InpSigShowAdvice      = true;  // Advisory recommendation box
input int    InpSigPanelX          = 12;    // Panel X from left (px)
input int    InpSigPanelY          = 300;   // Panel Y from top  (px)
input bool   InpSigShowPending     = true;
input bool   InpSigShowHistory     = true;
input bool   InpSigFill            = true;

input string InpSigSep4            = "─── Trade Sizing ────────";
input double InpSigRiskMoney       = 50.0;
input int    InpSigSpreadPts       = 20;
input int    InpSigTP1Pct          = 50;
input int    InpSigTP2Pct          = 30;
input int    InpSigTP3Pct          = 20;
input bool   InpSigAlerts          = true;
input int    InpSigFontSize        = 8;

//─── Layout constants ──────────────────────────────────────────────
#define SIG_PFX    "AIBSIG_"
#define PANEL_W    295
#define ROW_H      16
#define BTN_H      20
#define BTN_W      65
#define ADVICE_H   40

//─── Global state ──────────────────────────────────────────────────
bool     g_sigHideAll   = false;
bool     g_sigPickHide  = false;
bool     g_sigPickShow  = false;
bool     g_sigHide[1024][4];
bool     g_sigHideInit  = false;
datetime g_sigAlertTs[1024][4];
datetime g_sigMultiTs[1024];
bool     g_sigAlertInit = false;

//══════════════════════════════════════════════════════════════════
//  Color helpers — calm palette
//══════════════════════════════════════════════════════════════════
color Sig_Blend(color base, color mix, int pct)
{
   pct = MathMax(0, MathMin(100, pct));
   int b = (((int)base)&255)*(100-pct)/100       + (((int)mix)&255)*pct/100;
   int g = ((((int)base)>>8)&255)*(100-pct)/100  + ((((int)mix)>>8)&255)*pct/100;
   int r = ((((int)base)>>16)&255)*(100-pct)/100 + ((((int)mix)>>16)&255)*pct/100;
   return (color)(b|(g<<8)|(r<<16));
}
color Sig_BuySlBg()   { return (color)C'18,50,92';  }  // dark steel blue (SL/BUY)
color Sig_SellSlBg()  { return (color)C'84,20,38';  }  // dark crimson   (SL/SELL)
color Sig_TpBg()      { return (color)C'14,72,38';  }  // dark green     (TP zones)
color Sig_TpHitBg()   { return (color)C'14,82,68';  }  // dark teal      (TP hit)
color Sig_FailBg()    { return (color)C'52,12,12';  }  // very dark red  (SL hit)
color Sig_PrevBg()    { return (color)C'44,40,10';  }  // dark gold      (preview outline)
color Sig_EntryLine() { return (color)C'120,160,210'; } // soft blue line (entry)

//══════════════════════════════════════════════════════════════════
//  Strength score and categories
//  Score = nok[ti] * (p1[ti]/100)  — rewards count AND rate
//══════════════════════════════════════════════════════════════════
double Sig_Score(int cidx, int ti)
{
   if(cidx < 0 || cidx >= COMBO_COUNT) return 0.0;
   return g_combos[cidx].nok[ti] * (g_combos[cidx].p1[ti] / 100.0);
}

int Sig_StrengthLevel(double score)
{
   if(score >= 25.0) return 6;  // FULL MARGIN
   if(score >= 17.0) return 5;  // VERY STRONG
   if(score >= 12.0) return 4;  // STRONG
   if(score >=  8.0) return 3;  // GOOD
   if(score >=  5.0) return 2;  // WEAK
   if(score >=  2.0) return 1;  // VERY WEAK
   return 0;                     // NO TRADE
}

string Sig_StrengthStr(int lvl)
{
   switch(lvl) {
      case 6: return "FULL MARGIN";
      case 5: return "VERY STRONG";
      case 4: return "STRONG";
      case 3: return "GOOD";
      case 2: return "WEAK";
      case 1: return "VERY WEAK";
   }
   return "NO TRADE";
}

color Sig_StrengthColor(int lvl)
{
   switch(lvl) {
      case 6: return (color)C'0,215,110';    // emerald
      case 5: return (color)C'78,195,78';    // green
      case 4: return (color)C'195,185,52';   // gold
      case 3: return (color)C'195,132,38';   // amber
      case 2: return (color)C'132,132,132';  // gray
      case 1: return (color)C'88,88,88';     // dark gray
   }
   return (color)C'58,58,58';
}

bool Sig_IsQualified(int cidx, int ti)
{
   if(cidx < 0) return false;
   return (g_combos[cidx].p1[ti]  >= InpSigMinHitPct     &&
           (double)g_combos[cidx].nt[ti]  >= InpSigMinTouchCount  &&
           (double)g_combos[cidx].nok[ti] >= InpSigMinSuccessCount);
}

//══════════════════════════════════════════════════════════════════
//  Drawing primitives
//══════════════════════════════════════════════════════════════════
void Sig_DelObj(const string nm)
{ if(ObjectFind(0,nm)>=0) ObjectDelete(0,nm); }

void Sig_Rect(const string nm, datetime t1, double p1, datetime t2, double p2,
              color c, bool fill, int style=STYLE_SOLID)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,  t1); ObjectSetDouble(0,nm,OBJPROP_PRICE1,p1);
   ObjectSetInteger(0,nm,OBJPROP_TIME2,  t2); ObjectSetDouble(0,nm,OBJPROP_PRICE2,p2);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,  c);  ObjectSetInteger(0,nm,OBJPROP_STYLE, style);
   ObjectSetInteger(0,nm,OBJPROP_FILL,   fill);ObjectSetInteger(0,nm,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,nm,OBJPROP_BACK,   false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_HLine(const string nm, datetime t1, datetime t2, double price, color c, int w=1)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,  t1); ObjectSetDouble(0,nm,OBJPROP_PRICE1,price);
   ObjectSetInteger(0,nm,OBJPROP_TIME2,  t2); ObjectSetDouble(0,nm,OBJPROP_PRICE2,price);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,  c);  ObjectSetInteger(0,nm,OBJPROP_WIDTH, w);
   ObjectSetInteger(0,nm,OBJPROP_STYLE,  STYLE_SOLID);
   ObjectSetInteger(0,nm,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_Text(const string nm, datetime t, double p, const string txt,
              color c, int sz, int anchor=ANCHOR_CENTER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_TEXT,0,t,p);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,   t);   ObjectSetDouble(0,nm,OBJPROP_PRICE1,p);
   ObjectSetString (0,nm,OBJPROP_TEXT,    txt);  ObjectSetInteger(0,nm,OBJPROP_COLOR, c);
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
   ObjectSetString (0,nm,OBJPROP_FONT,     "Consolas");
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,    anchor);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,      false);
}

void Sig_SRect(const string nm, int x, int y, int w, int h,
               color c, int corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,      corner);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0,nm,OBJPROP_XSIZE,       w);
   ObjectSetInteger(0,nm,OBJPROP_YSIZE,       h);
   ObjectSetInteger(0,nm,OBJPROP_BGCOLOR,     c);
   ObjectSetInteger(0,nm,OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,       Sig_Blend(c,clrSilver,25));
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,        false);
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
   ObjectSetString (0,nm,OBJPROP_FONT,     "Consolas");
   ObjectSetInteger(0,nm,OBJPROP_STATE,     false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,      false);
}

//══════════════════════════════════════════════════════════════════
//  Object naming + zone cleanup
//══════════════════════════════════════════════════════════════════
string Sig_N(int ai, int ti, const string tag)
{ return SIG_PFX+IntegerToString(ai)+"_"+IntegerToString(ti)+"_"+tag; }
string Sig_PN(const string tag) { return SIG_PFX+"PANEL_"+tag; }
string Sig_BN(const string tag) { return SIG_PFX+"BTN_"+tag;   }

void Sig_DeleteZone(int ai, int ti)
{
   string tags[] = {"SL","TP1","TP2","TP3","ELINE","SL_LBL","PREV_SL","PREV_TP","PREV_INFO"};
   for(int i=0;i<ArraySize(tags);i++) Sig_DelObj(Sig_N(ai,ti,tags[i]));
}

//══════════════════════════════════════════════════════════════════
//  Domain helpers
//══════════════════════════════════════════════════════════════════
string Sig_TestName(int ti)
{
   switch(ti){case 0:return "U1X1";case 1:return "U2X1";case 2:return "DLX1";case 3:return "DRX1";}
   return "???";
}
double Sig_PipSz()
{
   int d=(int)MarketInfo(Symbol(),MODE_DIGITS);
   return (d==3||d==5) ? Point*10.0 : Point;
}
double Sig_ScaleDur(double hours)
{
   if(g_unitSeconds<=0) return hours;
   return hours*(g_unitSeconds/86400.0);
}
string Sig_PrevClsLtr(int ai)
{
   datetime best=0; int bestAi=-1;
   for(int i=0;i<g_monCount;i++) {
      if(i==ai||!g_mon[i].valid) continue;
      if(g_mon[i].formTime<g_mon[ai].formTime && g_mon[i].formTime>best)
         { best=g_mon[i].formTime; bestAi=i; }
   }
   if(bestAi<0) return "X";
   string c=g_mon[bestAi].cls;
   return (StringLen(c)>=2 ? StringSubstr(c,1,1) : "X");
}
bool Sig_IsVisible(int ai, int ti)
{
   if(g_sigHideAll) return false;
   if(ai<1024 && ti<4 && g_sigHide[ai][ti]) return false;
   return true;
}
datetime Sig_ZoneStart(datetime base, int ti)
{ return base+(datetime)(ti*(g_unitSeconds/5)); }

//══════════════════════════════════════════════════════════════════
//  Draw trade zone — only SL label with code+class+strength
//══════════════════════════════════════════════════════════════════
bool Sig_DrawZone(int ai, int ti, string code, string clsL,
                  double score, int lvl, bool isBuy)
{
   int  react    = g_mon[ai].test[ti].react[0];
   bool isPending= (react==MON_REACT_PENDING);
   bool bounced  = (react==MON_REACT_BOUNCE);
   bool broke    = (react==MON_REACT_BREAK);

   if(isPending && !InpSigShowPending)  return false;
   if(!isPending && !InpSigShowHistory) return false;

   double away  = g_mon[ai].test[ti].away;
   double anchor= g_mon[ai].test[ti].anchor;
   double L     = g_mon[ai].L;
   double B     = g_mon[ai].B;
   double entry = anchor + L * away;
   double sl    = entry  + B * away;
   double tp1   = g_mon[ai].test[ti].tp[0];
   double tp2   = g_mon[ai].test[ti].tp[1];
   int    nTP   = g_mon[ai].test[ti].nTP;
   double tp3   = (nTP>=3 ? g_mon[ai].test[ti].tp[2] : 0.0);

   datetime touchT = g_mon[ai].test[ti].touchTime;
   datetime tL = Sig_ZoneStart(touchT, ti);
   datetime tR = tL + (datetime)g_unitSeconds;

   bool h1=g_mon[ai].test[ti].tpHit[0];
   bool h2=g_mon[ai].test[ti].tpHit[1];
   bool h3=g_mon[ai].test[ti].tpHit[2];

   //── Zone bg colors ─────────────────────────────────────────────
   color cSL;
   if(broke)        cSL = Sig_FailBg();
   else if(isBuy)   cSL = Sig_BuySlBg();
   else             cSL = Sig_SellSlBg();
   if(bounced)      cSL = Sig_Blend(cSL, clrBlack, 30);

   color cTP1 = h1 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_TpBg(),clrBlack,55) : Sig_TpBg());
   color cTP2 = h2 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_TpBg(),clrBlack,60) : Sig_Blend(Sig_TpBg(),clrBlack,10));
   color cTP3 = h3 ? Sig_TpHitBg() : (broke ? Sig_Blend(Sig_TpBg(),clrBlack,65) : Sig_Blend(Sig_TpBg(),clrBlack,18));

   //── Draw rectangles ────────────────────────────────────────────
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL, entry, tR, sl,  cSL,  InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL, entry, tR, tp1, cTP1, InpSigFill);
   if(tp2!=0.0) Sig_Rect(Sig_N(ai,ti,"TP2"),tL,entry,tR,tp2,cTP2,InpSigFill);
   else         Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3!=0.0) Sig_Rect(Sig_N(ai,ti,"TP3"),tL,entry,tR,tp3,cTP3,InpSigFill);
   else         Sig_DelObj(Sig_N(ai,ti,"TP3"));

   //── Entry line ─────────────────────────────────────────────────
   Sig_HLine(Sig_N(ai,ti,"ELINE"), tL, tR, entry, Sig_EntryLine(), 1);

   //── Single WHITE label inside SL zone only ─────────────────────
   //   SL hit → delete text (keep rectangles dimmed)
   if(broke) {
      Sig_DelObj(Sig_N(ai,ti,"SL_LBL"));
   } else {
      double   slMid = (entry + sl) / 2.0;
      datetime lblT  = tL + (datetime)((tR-tL)/2);
      string   lblTxt= code + "  Z" + clsL + "  " + Sig_StrengthStr(lvl);
      Sig_Text(Sig_N(ai,ti,"SL_LBL"), lblT, slMid, lblTxt,
               clrWhite, InpSigFontSize, ANCHOR_CENTER);
   }
   return true;
}

//══════════════════════════════════════════════════════════════════
//  Draw anticipatory preview (dashed, before price arrives)
//══════════════════════════════════════════════════════════════════
void Sig_DrawPreview(int ai, int ti, string code, string clsL, int lvl)
{
   if(!InpSigShowPreview) {
      Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
      Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
      Sig_DelObj(Sig_N(ai,ti,"PREV_INFO"));
      return;
   }
   double away  = g_mon[ai].test[ti].away;
   double entry = g_mon[ai].test[ti].anchor + g_mon[ai].L * away;
   double sl    = entry + g_mon[ai].B * away;
   double tp1   = g_mon[ai].test[ti].tp[0];

   datetime tL   = Sig_ZoneStart(g_mon[ai].formTime, ti);
   datetime tR   = tL + (datetime)g_unitSeconds;
   datetime midT = tL + (datetime)((tR-tL)/2);
   double   midP = (entry + tp1) / 2.0;

   Sig_Rect(Sig_N(ai,ti,"PREV_SL"), tL, entry, tR, sl,  Sig_PrevBg(),
            false, STYLE_DASH);
   Sig_Rect(Sig_N(ai,ti,"PREV_TP"), tL, entry, tR, tp1,
            Sig_Blend(Sig_TpBg(),clrBlack,58), false, STYLE_DASH);

   string lblTxt = "[" + Sig_StrengthStr(lvl) + "]  " + code + " Z" + clsL + "  PREVIEW";
   Sig_Text(Sig_N(ai,ti,"PREV_INFO"), midT, midP, lblTxt,
            (color)C'175,162,58', InpSigFontSize-1, ANCHOR_CENTER);
}

//══════════════════════════════════════════════════════════════════
//  Alerts
//══════════════════════════════════════════════════════════════════
void Sig_InitAlerts()
{
   if(g_sigAlertInit) return;
   ArrayInitialize(g_sigAlertTs,0);
   ArrayInitialize(g_sigMultiTs,0);
   g_sigAlertInit=true;
}
void Sig_CheckTouchAlert(int ai, int ti, string code, string dir)
{
   if(!InpSigAlerts || ai>=1024) return;
   datetime touchT=g_mon[ai].test[ti].touchTime;
   if(touchT<=0 || g_sigAlertTs[ai][ti]==touchT) return;
   g_sigAlertTs[ai][ti]=touchT;
   if(g_mon[ai].test[ti].react[0]==MON_REACT_PENDING) {
      double entry=g_mon[ai].test[ti].anchor+g_mon[ai].L*g_mon[ai].test[ti].away;
      Alert("AIB: ",dir," ",g_mon[ai].cls," @ ",DoubleToString(entry,Digits),
            "  [",Sig_TestName(ti),"|",code,"]");
   }
}

//══════════════════════════════════════════════════════════════════
//  Signal entry struct
//══════════════════════════════════════════════════════════════════
struct SigEntry {
   int    ai, ti, lvl;
   string code, clsL, testName, dir;
   double score;
   bool   isPending;
};

//══════════════════════════════════════════════════════════════════
//  Advisory recommendation
//══════════════════════════════════════════════════════════════════
string Sig_BuildAdvice(SigEntry &entries[], int eCount)
{
   if(eCount==0) return "No qualified signals. Wait for next angle.";

   // Find top pending by score + count directions
   double topScore=-1; int topIdx=-1;
   int    pendBuy=0, pendSell=0;
   for(int i=0;i<eCount;i++) {
      if(!entries[i].isPending) continue;
      if(entries[i].score>topScore) { topScore=entries[i].score; topIdx=i; }
      if(entries[i].dir=="BUY") pendBuy++; else pendSell++;
   }

   // All resolved — no pending
   if(topIdx<0) {
      int bounceN=0, breakN=0;
      for(int i=0;i<eCount;i++) {
         int r=g_mon[entries[i].ai].test[entries[i].ti].react[0];
         if(r==MON_REACT_BOUNCE) bounceN++;
         if(r==MON_REACT_BREAK)  breakN++;
      }
      if(bounceN>0) return StringFormat("%d signal(s) hit target. Watch for new angles.",bounceN);
      if(breakN>0)  return StringFormat("%d signal(s) stopped out. Wait for next setup.",breakN);
      return "Signals resolved. Monitor chart for new angles.";
   }

   if(pendBuy>0 && pendSell>0)
      return "BUY + SELL conflict. Stay flat — wait for one side to dominate.";

   SigEntry top = entries[topIdx];
   int   cnt = pendBuy + pendSell;
   string d  = top.dir;

   if(top.lvl>=6)
      return "FULL MARGIN: "+top.code+" "+top.testName+" ["+d+"] — Trade max confidence.";
   if(top.lvl==5) {
      if(cnt>=2) return StringFormat("VERY STRONG x%d [%s] — Multiple signals. Enter now.",cnt,d);
      return "VERY STRONG: "+top.code+" ["+d+"] — Enter, standard risk.";
   }
   if(top.lvl==4) return "STRONG: "+top.code+" ["+d+"] — Enter, manage risk carefully.";
   if(top.lvl==3) return "GOOD signal: "+top.code+" ["+d+"] — Acceptable. Enter at market.";
   return "Low-quality signals only. Reduce size or wait for better setup.";
}

//══════════════════════════════════════════════════════════════════
//  Panel drawing — bottom-left, compact
//══════════════════════════════════════════════════════════════════
void Sig_DeletePanel()
{
   int tot=ObjectsTotal();
   for(int i=tot-1;i>=0;i--) {
      string nm=ObjectName(i);
      if(StringFind(nm,SIG_PFX+"PANEL_",0)==0 || StringFind(nm,SIG_PFX+"BTN_",0)==0)
         ObjectDelete(0,nm);
   }
}

void Sig_DrawPanel(SigEntry &entries[], int eCount)
{
   if(!InpSigShowPanel) { Sig_DeletePanel(); return; }

   int dispRows = MathMin(eCount, InpSigMaxRows);
   int headerH  = 24;
   int bodyH    = MathMax(dispRows,1)*ROW_H + 6;
   int adviceH  = InpSigShowAdvice ? ADVICE_H+6 : 0;
   int btnRowH  = BTN_H + 10;
   int sepH     = 4;
   int totalH   = headerH + sepH + bodyH + (adviceH>0?sepH+adviceH:0) + sepH + btnRowH;
   int PX=InpSigPanelX, PY=InpSigPanelY, PW=PANEL_W;
   int corn=CORNER_LEFT_UPPER;

   //── Background + header ────────────────────────────────────────
   Sig_SRect(Sig_PN("BG"),  PX, PY, PW, totalH, (color)C'13,16,23', corn);
   Sig_SRect(Sig_PN("HDR"), PX, PY, PW, headerH,(color)C'20,30,52', corn);

   string modeStr="";
   if(g_sigPickHide) modeStr=" [PICK-HIDE]";
   if(g_sigPickShow) modeStr=" [PICK-SHOW]";
   if(g_sigHideAll)  modeStr=" [HIDDEN]";
   color modeCol = g_sigPickHide ? clrOrange : (g_sigPickShow ? clrYellow :
                   (g_sigHideAll ? (color)C'200,78,78' : (color)C'155,195,255'));

   Sig_SLabel(Sig_PN("TITLE"), PX+8, PY+7,
              StringFormat("AIB SIGNAL  %d active%s", eCount, modeStr),
              modeCol, 9, corn);

   //── Signal rows ────────────────────────────────────────────────
   int rowY = PY + headerH + sepH;
   for(int i=0;i<dispRows;i++) {
      SigEntry e = entries[i];
      // Strength marker
      string mk = (e.lvl>=5 ? ">" : (e.lvl>=3 ? "-" : "."));
      // Row: "> BB4SF  ZB  FULL MARGIN  U1X1  BUY"
      string rowTxt = StringFormat("%s %-5s  Z%s  %-12s  %s  %s",
                                   mk, e.code, e.clsL,
                                   Sig_StrengthStr(e.lvl),
                                   e.testName, e.dir);
      color rowCol = Sig_StrengthColor(e.lvl);
      if(!e.isPending) rowCol = Sig_Blend(rowCol, clrBlack, 38);
      Sig_SLabel(Sig_PN("ROW"+IntegerToString(i)),
                 PX+6, rowY+i*ROW_H, rowTxt, rowCol, 8, corn);
   }

   // Clip indicator
   if(eCount>dispRows) {
      Sig_SLabel(Sig_PN("MORE"), PX+6, rowY+dispRows*ROW_H,
                 StringFormat("... +%d more", eCount-dispRows),
                 (color)C'88,88,88', 7, corn);
   } else {
      Sig_DelObj(Sig_PN("MORE"));
   }
   // Clear unused rows
   for(int i=dispRows;i<InpSigMaxRows+2;i++) Sig_DelObj(Sig_PN("ROW"+IntegerToString(i)));

   //── Advisory box ───────────────────────────────────────────────
   int nextY = rowY + MathMax(dispRows,1)*ROW_H + 6;
   if(InpSigShowAdvice) {
      nextY += sepH;
      string advice = Sig_BuildAdvice(entries, eCount);
      Sig_SRect(Sig_PN("ADVBG"), PX+4, nextY, PW-8, ADVICE_H, (color)C'18,24,38', corn);
      Sig_SLabel(Sig_PN("ADVHDR"), PX+8, nextY+3, "ADVICE",
                 (color)C'95,125,175', 7, corn);
      // Split into 2 lines at space boundary
      int maxCh = (PW-20)/6;
      if(StringLen(advice)>maxCh) {
         int sp = maxCh;
         for(int c=maxCh;c>maxCh-18&&c>0;c--)
            if(StringGetCharacter(advice,c)==' '){sp=c;break;}
         Sig_SLabel(Sig_PN("ADVL1"), PX+8, nextY+14,
                    StringSubstr(advice,0,sp), clrWhite, 8, corn);
         Sig_SLabel(Sig_PN("ADVL2"), PX+8, nextY+26,
                    StringSubstr(advice,sp+1), (color)C'198,198,198', 8, corn);
      } else {
         Sig_SLabel(Sig_PN("ADVL1"), PX+8, nextY+14, advice, clrWhite, 8, corn);
         Sig_DelObj(Sig_PN("ADVL2"));
      }
      nextY += ADVICE_H + sepH;
   } else {
      Sig_DelObj(Sig_PN("ADVBG")); Sig_DelObj(Sig_PN("ADVHDR"));
      Sig_DelObj(Sig_PN("ADVL1")); Sig_DelObj(Sig_PN("ADVL2"));
   }

   //── Buttons ────────────────────────────────────────────────────
   int btnY = nextY + sepH;
   int bX   = PX+4;
   color cN = (color)C'32,48,78';
   color cA = (color)C'78,48,16';
   color cD = (color)C'72,18,18';

   Sig_SBtn(Sig_BN("HIDEALL"),  bX,              btnY, BTN_W, BTN_H, "Hide All",
            g_sigHideAll ? cD : cN, clrWhite, corn);
   Sig_SBtn(Sig_BN("SHOWALL"),  bX+BTN_W+3,      btnY, BTN_W, BTN_H, "Show All",  cN, clrWhite, corn);
   Sig_SBtn(Sig_BN("PICKHIDE"), bX+(BTN_W+3)*2,  btnY, BTN_W, BTN_H, "Hide Zone",
            g_sigPickHide ? cA : cN, g_sigPickHide ? clrYellow : clrWhite, corn);
   Sig_SBtn(Sig_BN("PICKSHOW"), bX+(BTN_W+3)*3,  btnY, BTN_W, BTN_H, "Pick Ang",
            g_sigPickShow ? cA : cN, g_sigPickShow ? clrYellow : clrWhite, corn);
}

//══════════════════════════════════════════════════════════════════
//  Button state + chart event
//══════════════════════════════════════════════════════════════════
void Sig_CheckButtons()
{
   if(ObjectFind(0,Sig_BN("HIDEALL"))>=0 && ObjectGetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE)) {
      g_sigHideAll=!g_sigHideAll;
      if(g_sigHideAll){g_sigPickHide=false;g_sigPickShow=false;}
      ObjectSetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("SHOWALL"))>=0 && ObjectGetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE)) {
      g_sigHideAll=false;
      if(g_sigHideInit) ArrayInitialize(g_sigHide,false);
      g_sigPickHide=false; g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKHIDE"))>=0 && ObjectGetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE)) {
      g_sigPickHide=!g_sigPickHide;
      if(g_sigPickHide) g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE,false); ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKSHOW"))>=0 && ObjectGetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE)) {
      g_sigPickShow=!g_sigPickShow;
      if(g_sigPickShow) g_sigPickHide=false;
      ObjectSetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE,false); ChartRedraw(0);
   }
}

bool Sig_ParseName(const string nm, int &ai, int &ti)
{
   if(StringFind(nm,SIG_PFX,0)!=0) return false;
   string rest=StringSubstr(nm,StringLen(SIG_PFX));
   int p1=StringFind(rest,"_",0); if(p1<0) return false;
   int p2=StringFind(rest,"_",p1+1); if(p2<0) return false;
   ai=(int)StringToInteger(StringSubstr(rest,0,p1));
   ti=(int)StringToInteger(StringSubstr(rest,p1+1,p2-p1-1));
   return (ai>=0&&ai<1024&&ti>=0&&ti<4);
}

void Sig_OnChartEvent(const int id, const long lparam,
                      const double dparam, const string sparam)
{
   if(!InpSigEnabled) return;
   if(id==CHARTEVENT_OBJECT_CLICK) {
      if(StringFind(sparam,SIG_PFX+"BTN_",0)==0) return;
      if(g_sigPickHide && StringFind(sparam,SIG_PFX,0)==0) {
         int ai=-1,ti=-1;
         if(Sig_ParseName(sparam,ai,ti)) {
            if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
            g_sigHide[ai][ti]=true; Sig_DeleteZone(ai,ti);
            g_sigPickHide=false; ChartRedraw(0);
         }
         return;
      }
   }
   if(id==CHARTEVENT_CLICK && g_sigPickShow) {
      datetime clickT=0; double clickP=0.0; int subwin=0;
      if(!ChartXYToTimePrice(0,(int)lparam,(int)dparam,subwin,clickT,clickP)) return;
      int bestAi=-1; long bestDt=LONG_MAX;
      for(int i=0;i<g_monCount;i++) {
         if(!g_mon[i].valid) continue;
         long dt=MathAbs((long)g_mon[i].formTime-(long)clickT);
         if(dt<bestDt){bestDt=dt;bestAi=i;}
      }
      if(bestAi>=0) {
         if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
         for(int i=0;i<g_monCount&&i<1024;i++)
            for(int t=0;t<4;t++) g_sigHide[i][t]=(i!=bestAi);
         g_sigHideAll=false; g_sigPickShow=false; ChartRedraw(0);
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Main: Sig_OnCalculate()
//══════════════════════════════════════════════════════════════════
void Sig_OnCalculate()
{
   if(!InpSigEnabled) return;
   if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
   ComboTable_Init();
   Sig_InitAlerts();
   Sig_CheckButtons();

   SigEntry entries[];
   int eCount=0;
   ArrayResize(entries, g_monCount*MON_NPTS);

   for(int ai=0;ai<g_monCount;ai++) {
      if(!g_mon[ai].valid) continue;

      string cls  = g_mon[ai].cls;
      string clsL = (StringLen(cls)>=2 ? StringSubstr(cls,1,1) : cls);
      string dir  = (g_mon[ai].dir>0 ? "BUY" : "SELL");
      bool   isBuy= (g_mon[ai].dir>0);
      double rat  = g_mon[ai].ratio;
      double lu1  = (g_mon[ai].u1R>1e-10 ? g_mon[ai].L/g_mon[ai].u1R*100.0 : 0.0);
      string prev = Sig_PrevClsLtr(ai);
      string code = ComboCode(cls, dir, rat, lu1, prev);
      int    cidx = ComboFind(code);

      for(int ti=0;ti<MON_NPTS;ti++) {
         int react=g_mon[ai].test[ti].react[0];
         if(react==MON_REACT_NA) { Sig_DeleteZone(ai,ti); continue; }

         //── 3-criteria quality filter ───────────────────────────
         if(!Sig_IsQualified(cidx,ti)) {
            Sig_DeleteZone(ai,ti);
            Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
            Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
            Sig_DelObj(Sig_N(ai,ti,"PREV_INFO"));
            continue;
         }

         double score = Sig_Score(cidx,ti);
         int    lvl   = Sig_StrengthLevel(score);

         //── UNTOUCHED → preview ─────────────────────────────────
         if(react==MON_REACT_UNTOUCHED) {
            Sig_DrawPreview(ai,ti,code,clsL,lvl);
            Sig_DeleteZone(ai,ti);
            SigEntry e; e.ai=ai;e.ti=ti;e.lvl=lvl;e.code=code;e.clsL=clsL;
            e.testName=Sig_TestName(ti);e.dir=dir;e.score=score;e.isPending=false;
            entries[eCount++]=e;
            continue;
         }

         //── Touched → real zone ─────────────────────────────────
         datetime touchT=g_mon[ai].test[ti].touchTime;
         if(touchT<=0){Sig_DeleteZone(ai,ti);continue;}

         Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_INFO"));
         Sig_CheckTouchAlert(ai,ti,code,dir);

         if(Sig_IsVisible(ai,ti)) {
            bool hist  =(react==MON_REACT_BOUNCE||react==MON_REACT_BREAK);
            bool isPend=(react==MON_REACT_PENDING);
            if(isPend && !InpSigShowPending)       Sig_DeleteZone(ai,ti);
            else if(hist && !InpSigShowHistory)    Sig_DeleteZone(ai,ti);
            else Sig_DrawZone(ai,ti,code,clsL,score,lvl,isBuy);
         } else {
            Sig_DeleteZone(ai,ti);
         }

         SigEntry e; e.ai=ai;e.ti=ti;e.lvl=lvl;e.code=code;e.clsL=clsL;
         e.testName=Sig_TestName(ti);e.dir=dir;e.score=score;
         e.isPending=(react==MON_REACT_PENDING);
         entries[eCount++]=e;
      }
   }

   // Sort by score descending (strongest first)
   for(int i=0;i<eCount-1;i++)
      for(int j=i+1;j<eCount;j++)
         if(entries[i].score<entries[j].score)
            { SigEntry tmp=entries[i]; entries[i]=entries[j]; entries[j]=tmp; }

   Sig_DrawPanel(entries,eCount);
   ChartRedraw(0);
}

//══════════════════════════════════════════════════════════════════
//  Deinit — remove all objects
//══════════════════════════════════════════════════════════════════
void Sig_OnDeinit()
{
   int tot=ObjectsTotal();
   for(int i=tot-1;i>=0;i--) {
      string nm=ObjectName(i);
      if(StringFind(nm,SIG_PFX,0)==0) ObjectDelete(0,nm);
   }
}
