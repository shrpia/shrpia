//==================================================================
//  AIB_Signal.mqh  v4.0
//
//  v4.0: p_total + n_ang classification, overlap slot-splitting,
//        price labels at zone edge, all-TP colored rects,
//        calm palette, advisory panel bottom-left.
//==================================================================

//─── Inputs ────────────────────────────────────────────────────────
input string InpSigSep1          = "─── AIB Signal v4.0 ────";
input bool   InpSigEnabled       = true;

input string InpSigSep2          = "─── Quality Filter ──────";
input int    InpSigMinNAng       = 40;   // Min appearances (n_ang) — combos below skipped
input bool   InpSigShowPreview   = true; // Draw anticipatory preview

input string InpSigSep3          = "─── Panel ───────────────";
input bool   InpSigShowPanel     = true;
input int    InpSigMaxRows       = 6;
input bool   InpSigShowAdvice    = true;
input int    InpSigPanelX        = 12;
input int    InpSigPanelY        = 300;
input bool   InpSigShowPending   = true;
input bool   InpSigShowHistory   = true;
input bool   InpSigFill          = true;

input string InpSigSep4          = "─── Trade Sizing ────────";
input double InpSigRiskMoney     = 50.0;
input int    InpSigSpreadPts     = 20;
input int    InpSigTP1Pct        = 50;
input int    InpSigTP2Pct        = 30;
input int    InpSigTP3Pct        = 20;
input bool   InpSigAlerts        = true;
input int    InpSigFontSize      = 8;

//─── Layout constants ──────────────────────────────────────────────
#define SIG_PFX   "AIBSIG_"
#define PANEL_W   305
#define ROW_H     16
#define BTN_H     20
#define BTN_W     68
#define ADVICE_H  42

//─── Global state ──────────────────────────────────────────────────
bool     g_sigHideAll  = false;
bool     g_sigPickHide = false;
bool     g_sigPickShow = false;
bool     g_sigHide[1024][4];
bool     g_sigHideInit = false;
datetime g_sigAlertTs[1024][4];
datetime g_sigMultiTs[1024];
bool     g_sigAlertInit= false;

//══════════════════════════════════════════════════════════════════
//  Calm color palette
//══════════════════════════════════════════════════════════════════
color Sig_Blend(color base, color mix, int pct)
{
   pct=MathMax(0,MathMin(100,pct));
   int b=(((int)base)&255)*(100-pct)/100       +(((int)mix)&255)*pct/100;
   int g=((((int)base)>>8)&255)*(100-pct)/100  +((((int)mix)>>8)&255)*pct/100;
   int r=((((int)base)>>16)&255)*(100-pct)/100 +((((int)mix)>>16)&255)*pct/100;
   return(color)(b|(g<<8)|(r<<16));
}

// Zone backgrounds
color Sig_BuySlBg()  { return(color)C'15,45,82';  }  // deep navy  (BUY SL)
color Sig_SellSlBg() { return(color)C'78,16,32';  }  // deep wine  (SELL SL)
color Sig_Tp1Bg()    { return(color)C'18,85,45';  }  // forest grn (TP1)
color Sig_Tp2Bg()    { return(color)C'15,70,62';  }  // teal       (TP2)
color Sig_Tp3Bg()    { return(color)C'12,55,72';  }  // steel blue (TP3)
color Sig_TpHitBg()  { return(color)C'22,115,80'; }  // bright teal(TP hit)
color Sig_FailBg()   { return(color)C'48,10,10';  }  // near-black red (SL hit)
color Sig_PrevBg()   { return(color)C'40,36,8';   }  // dark gold  (preview)
color Sig_EntryLine(){ return(color)C'100,145,195'; } // soft blue  (entry)

// Price label colors
color Sig_LblEntry() { return(color)C'130,172,218'; }
color Sig_LblSL()    { return(color)C'200,120,120'; }
color Sig_LblTP1()   { return(color)C'90,200,125';  }
color Sig_LblTP2()   { return(color)C'75,175,158';  }
color Sig_LblTP3()   { return(color)C'65,150,185';  }

//══════════════════════════════════════════════════════════════════
//  Classification — v4.0: based on p_total + n_ang threshold
//  Returns: 4=STRONG, 3=GOOD, 2=WEAK, 1=VERY WEAK, 0=NO TRADE
//══════════════════════════════════════════════════════════════════
int Sig_Classify(int cidx)
{
   if(cidx<0||cidx>=COMBO_COUNT) return 0;
   if(g_combos[cidx].n_ang<InpSigMinNAng) return 0;
   double p=g_combos[cidx].p_total;
   if(p>=45.0) return 4;
   if(p>=30.0) return 3;
   if(p>=10.0) return 2;
   return 1;
}

string Sig_ClsStr(int lvl)
{
   switch(lvl){
      case 4: return "STRONG";
      case 3: return "GOOD";
      case 2: return "WEAK";
      case 1: return "VERY WEAK";
   }
   return "NO TRADE";
}

color Sig_ClsColor(int lvl)
{
   switch(lvl){
      case 4: return(color)C'28,190,100';  // emerald
      case 3: return(color)C'190,155,40';  // gold
      case 2: return(color)C'82,118,155';  // steel
      case 1: return(color)C'92,92,92';    // dark gray
   }
   return(color)C'52,52,52';              // near-black
}

// Score used only for ranking; NOT for classification
double Sig_Score(int cidx,int ti)
{
   if(cidx<0||cidx>=COMBO_COUNT) return 0.0;
   return g_combos[cidx].nok[ti]*(g_combos[cidx].p1[ti]/100.0);
}

//══════════════════════════════════════════════════════════════════
//  SigZone struct — one drawable zone
//══════════════════════════════════════════════════════════════════
struct SigZone {
   int      ai,ti,clsLevel;
   double   score;
   string   code,clsL,dir;
   bool     isBuy,isPreview;
   double   pMin,pMax;   // price range for overlap detection
   datetime baseTime;    // formTime(preview) or touchTime(real)
   // Assigned by Sig_ComputeSlots:
   int      grpId,grpSlot,grpSize;
   datetime slotTL,slotTR;
};

//══════════════════════════════════════════════════════════════════
//  Drawing primitives
//══════════════════════════════════════════════════════════════════
void Sig_DelObj(const string nm)
{ if(ObjectFind(0,nm)>=0) ObjectDelete(0,nm); }

void Sig_Rect(const string nm,datetime t1,double p1,datetime t2,double p2,
              color c,bool fill,int style=STYLE_SOLID)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,  t1); ObjectSetDouble(0,nm,OBJPROP_PRICE1,p1);
   ObjectSetInteger(0,nm,OBJPROP_TIME2,  t2); ObjectSetDouble(0,nm,OBJPROP_PRICE2,p2);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,  c);  ObjectSetInteger(0,nm,OBJPROP_STYLE, style);
   ObjectSetInteger(0,nm,OBJPROP_FILL,   fill);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,  1);
   ObjectSetInteger(0,nm,OBJPROP_BACK,   false);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_HLine(const string nm,datetime t1,datetime t2,double price,color c,int w=1)
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

void Sig_Text(const string nm,datetime t,double p,const string txt,
              color c,int sz,int anchor=ANCHOR_LEFT)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_TEXT,0,t,p);
   ObjectSetInteger(0,nm,OBJPROP_TIME1,   t);   ObjectSetDouble(0,nm,OBJPROP_PRICE1,p);
   ObjectSetString (0,nm,OBJPROP_TEXT,    txt);  ObjectSetInteger(0,nm,OBJPROP_COLOR, c);
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,sz);   ObjectSetString (0,nm,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,  anchor);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
}

void Sig_SLabel(const string nm,int x,int y,const string txt,color c,
                int sz,int corner=CORNER_LEFT_UPPER,int anchor=ANCHOR_LEFT_UPPER)
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

void Sig_SRect(const string nm,int x,int y,int w,int h,
               color c,int corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,      corner);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0,nm,OBJPROP_XSIZE,       w);
   ObjectSetInteger(0,nm,OBJPROP_YSIZE,       h);
   ObjectSetInteger(0,nm,OBJPROP_BGCOLOR,     c);
   ObjectSetInteger(0,nm,OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,       Sig_Blend(c,clrSilver,20));
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0,nm,OBJPROP_BACK,        false);
}

void Sig_SBtn(const string nm,int x,int y,int w,int h,
              const string txt,color bg,color tc,int corner=CORNER_LEFT_UPPER)
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
string Sig_N(int ai,int ti,const string tag)
{ return SIG_PFX+IntegerToString(ai)+"_"+IntegerToString(ti)+"_"+tag; }
string Sig_PN(const string tag){ return SIG_PFX+"PANEL_"+tag; }
string Sig_BN(const string tag){ return SIG_PFX+"BTN_"+tag;   }

void Sig_DeleteZone(int ai,int ti)
{
   string tags[]={"SL","TP1","TP2","TP3","ELINE",
                  "LBL_E","LBL_SL","LBL_T1","LBL_T2","LBL_T3",
                  "PREV_SL","PREV_TP","PREV_LBL"};
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
   return(d==3||d==5)?Point*10.0:Point;
}
string Sig_PrevClsLtr(int ai)
{
   datetime best=0; int bestAi=-1;
   for(int i=0;i<g_monCount;i++){
      if(i==ai||!g_mon[i].valid) continue;
      if(g_mon[i].formTime<g_mon[ai].formTime&&g_mon[i].formTime>best)
         {best=g_mon[i].formTime;bestAi=i;}
   }
   if(bestAi<0) return "X";
   string c=g_mon[bestAi].cls;
   return(StringLen(c)>=2?StringSubstr(c,1,1):"X");
}
bool Sig_IsVisible(int ai,int ti)
{
   if(g_sigHideAll) return false;
   if(ai<1024&&ti<4&&g_sigHide[ai][ti]) return false;
   return true;
}

//══════════════════════════════════════════════════════════════════
//  Overlap slot computation
//  Groups zones whose price ranges overlap AND are within 2 units
//  in time. Splits the unit period into grpSize equal slots.
//  Max 3 zones per group; strongest (highest clsLevel) gets slot 0.
//══════════════════════════════════════════════════════════════════
void Sig_ComputeSlots(SigZone &zones[], int n)
{
   // Union-Find arrays
   int parent[];
   ArrayResize(parent,n);
   for(int i=0;i<n;i++) parent[i]=i;

   // Find root
   // (inline path-compressed find via loop)

   // Merge overlapping pairs
   for(int i=0;i<n;i++)
      for(int j=i+1;j<n;j++){
         // Price overlap check
         bool priceOvlp=(zones[i].pMin<zones[j].pMax && zones[j].pMin<zones[i].pMax);
         // Time proximity: within 2 units
         long dt=MathAbs((long)zones[i].baseTime-(long)zones[j].baseTime);
         bool timeClose=(dt<=(long)(2*g_unitSeconds));
         if(!priceOvlp||!timeClose) continue;
         // Union i and j
         int ri=i, rj=j;
         while(parent[ri]!=ri) ri=parent[ri];
         while(parent[rj]!=rj) rj=parent[rj];
         if(ri!=rj) parent[ri]=rj;
      }

   // Compress roots
   for(int i=0;i<n;i++){
      int r=i; while(parent[r]!=r) r=parent[r];
      parent[i]=r;
   }

   // Collect group members per root, sort descending by clsLevel
   int grpNext=0;
   int grpMap[];   // maps root-index → group-id
   ArrayResize(grpMap,n); ArrayInitialize(grpMap,-1);

   // Assign group IDs and counts
   int grpSizes[];
   ArrayResize(grpSizes,n); ArrayInitialize(grpSizes,0);
   for(int i=0;i<n;i++){
      int r=parent[i];
      if(grpMap[r]<0){ grpMap[r]=grpNext++; }
      grpSizes[grpMap[r]]++;
   }

   // Initialise slot fields
   for(int i=0;i<n;i++){
      int r=parent[i];
      zones[i].grpId=grpMap[r];
      zones[i].grpSize=MathMin(grpSizes[grpMap[r]],3);
      zones[i].grpSlot=-1;
   }

   // Per group: sort members by clsLevel desc, assign slots 0..N-1
   for(int g=0;g<grpNext;g++){
      // Collect indices in this group
      int members[];
      int mc=0;
      for(int i=0;i<n;i++) if(zones[i].grpId==g) mc++;
      ArrayResize(members,mc);
      int mi=0;
      for(int i=0;i<n;i++) if(zones[i].grpId==g) members[mi++]=i;
      // Sort by clsLevel desc (simple bubble)
      for(int a=0;a<mc-1;a++)
         for(int b=a+1;b<mc;b++)
            if(zones[members[a]].clsLevel<zones[members[b]].clsLevel)
               {int tmp=members[a];members[a]=members[b];members[b]=tmp;}
      // Cap at 3
      int slotCount=MathMin(mc,3);
      for(int s=0;s<mc;s++){
         int idx=members[s];
         int slot=(s<slotCount)?s:-1;
         zones[idx].grpSlot=slot;
         zones[idx].grpSize=slotCount;
      }
   }

   // Compute slotTL / slotTR
   for(int i=0;i<n;i++){
      int slot=zones[i].grpSlot;
      int N   =zones[i].grpSize;
      if(slot<0||N<=0){ slot=0; N=1; }
      datetime base=zones[i].baseTime;
      long slotLen=(long)(g_unitSeconds/N);
      zones[i].slotTL=base+(datetime)(slot*slotLen);
      zones[i].slotTR=zones[i].slotTL+(datetime)slotLen;
   }
}

//══════════════════════════════════════════════════════════════════
//  Draw price label at right edge of zone (OBJ_TEXT anchored LEFT)
//══════════════════════════════════════════════════════════════════
void Sig_PriceLabel(const string nm,datetime tR,double price,
                    const string prefix,color c,int sz)
{
   string txt=prefix+DoubleToString(price,Digits);
   Sig_Text(nm,tR,price,txt,c,sz,ANCHOR_LEFT);
}

//══════════════════════════════════════════════════════════════════
//  Draw one zone from a SigZone descriptor
//══════════════════════════════════════════════════════════════════
void Sig_DrawZoneV4(SigZone &z)
{
   int  ai=z.ai, ti=z.ti;
   int  react=g_mon[ai].test[ti].react[0];
   bool isPending=(react==MON_REACT_PENDING);
   bool bounced  =(react==MON_REACT_BOUNCE);
   bool broke    =(react==MON_REACT_BREAK);

   if(isPending &&!InpSigShowPending) return;
   if(!isPending&&!InpSigShowHistory) return;

   double away  =g_mon[ai].test[ti].away;
   double anchor=g_mon[ai].test[ti].anchor;
   double L     =g_mon[ai].L;
   double B     =g_mon[ai].B;
   double entry =anchor+L*away;
   double sl    =entry +B*away;
   double tp1   =g_mon[ai].test[ti].tp[0];
   double tp2   =g_mon[ai].test[ti].tp[1];
   int    nTP   =g_mon[ai].test[ti].nTP;
   double tp3   =(nTP>=3?g_mon[ai].test[ti].tp[2]:0.0);
   bool   h1    =g_mon[ai].test[ti].tpHit[0];
   bool   h2    =g_mon[ai].test[ti].tpHit[1];
   bool   h3    =g_mon[ai].test[ti].tpHit[2];

   datetime tL=z.slotTL, tR=z.slotTR;

   // Font size: shrink by 1 for each extra zone beyond 1
   int fsz=InpSigFontSize-MathMax(0,z.grpSize-1);
   fsz=MathMax(5,fsz);

   //── Zone bg colors ─────────────────────────────────────────────
   color cSL;
   if(broke)       cSL=Sig_FailBg();
   else if(z.isBuy) cSL=Sig_BuySlBg();
   else             cSL=Sig_SellSlBg();
   if(bounced) cSL=Sig_Blend(cSL,clrBlack,30);

   color cTP1=h1?Sig_TpHitBg():(broke?Sig_Blend(Sig_Tp1Bg(),clrBlack,55):Sig_Tp1Bg());
   color cTP2=h2?Sig_TpHitBg():(broke?Sig_Blend(Sig_Tp2Bg(),clrBlack,55):Sig_Tp2Bg());
   color cTP3=h3?Sig_TpHitBg():(broke?Sig_Blend(Sig_Tp3Bg(),clrBlack,55):Sig_Tp3Bg());

   //── Rectangles ─────────────────────────────────────────────────
   Sig_Rect(Sig_N(ai,ti,"SL"),  tL,entry,tR,sl,  cSL, InpSigFill);
   Sig_Rect(Sig_N(ai,ti,"TP1"), tL,entry,tR,tp1, cTP1,InpSigFill);
   if(tp2!=0.0) Sig_Rect(Sig_N(ai,ti,"TP2"),tL,entry,tR,tp2,cTP2,InpSigFill);
   else         Sig_DelObj(Sig_N(ai,ti,"TP2"));
   if(tp3!=0.0) Sig_Rect(Sig_N(ai,ti,"TP3"),tL,entry,tR,tp3,cTP3,InpSigFill);
   else         Sig_DelObj(Sig_N(ai,ti,"TP3"));

   //── Entry line ─────────────────────────────────────────────────
   Sig_HLine(Sig_N(ai,ti,"ELINE"),tL,tR,entry,Sig_EntryLine(),1);

   //── Price labels at right edge ─────────────────────────────────
   if(!broke){
      Sig_PriceLabel(Sig_N(ai,ti,"LBL_E"), tR,entry,"E:",Sig_LblEntry(),fsz);
      Sig_PriceLabel(Sig_N(ai,ti,"LBL_SL"),tR,sl,   "S:",Sig_LblSL(),  fsz);
      Sig_PriceLabel(Sig_N(ai,ti,"LBL_T1"),tR,tp1,  "1:",Sig_LblTP1(), fsz);
      if(tp2!=0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T2"),tR,tp2,"2:",Sig_LblTP2(),fsz);
      else         Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      if(tp3!=0.0) Sig_PriceLabel(Sig_N(ai,ti,"LBL_T3"),tR,tp3,"3:",Sig_LblTP3(),fsz);
      else         Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
   } else {
      Sig_DelObj(Sig_N(ai,ti,"LBL_E")); Sig_DelObj(Sig_N(ai,ti,"LBL_SL"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T1")); Sig_DelObj(Sig_N(ai,ti,"LBL_T2"));
      Sig_DelObj(Sig_N(ai,ti,"LBL_T3"));
   }
}

//══════════════════════════════════════════════════════════════════
//  Draw preview zone
//══════════════════════════════════════════════════════════════════
void Sig_DrawPreviewV4(SigZone &z)
{
   if(!InpSigShowPreview){
      Sig_DelObj(Sig_N(z.ai,z.ti,"PREV_SL"));
      Sig_DelObj(Sig_N(z.ai,z.ti,"PREV_TP"));
      Sig_DelObj(Sig_N(z.ai,z.ti,"PREV_LBL"));
      return;
   }
   int ai=z.ai, ti=z.ti;
   double away  =g_mon[ai].test[ti].away;
   double entry =g_mon[ai].test[ti].anchor+g_mon[ai].L*away;
   double sl    =entry+g_mon[ai].B*away;
   double tp1   =g_mon[ai].test[ti].tp[0];

   datetime tL=z.slotTL, tR=z.slotTR;
   datetime midT=tL+(datetime)((tR-tL)/2);
   double   midP=(entry+tp1)/2.0;

   int fsz=InpSigFontSize-MathMax(0,z.grpSize-1);
   fsz=MathMax(5,fsz);

   Sig_Rect(Sig_N(ai,ti,"PREV_SL"),tL,entry,tR,sl, Sig_PrevBg(),false,STYLE_DASH);
   Sig_Rect(Sig_N(ai,ti,"PREV_TP"),tL,entry,tR,tp1,
            Sig_Blend(Sig_Tp1Bg(),clrBlack,60),false,STYLE_DASH);

   string lbl="["+Sig_ClsStr(z.clsLevel)+"] "+z.code+" Z"+z.clsL+" PREV";
   Sig_Text(Sig_N(ai,ti,"PREV_LBL"),midT,midP,lbl,
            (color)C'165,152,52',fsz,ANCHOR_CENTER);
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
void Sig_CheckTouchAlert(int ai,int ti,const string code,const string dir)
{
   if(!InpSigAlerts||ai>=1024) return;
   datetime touchT=g_mon[ai].test[ti].touchTime;
   if(touchT<=0||g_sigAlertTs[ai][ti]==touchT) return;
   g_sigAlertTs[ai][ti]=touchT;
   if(g_mon[ai].test[ti].react[0]==MON_REACT_PENDING){
      double entry=g_mon[ai].test[ti].anchor+g_mon[ai].L*g_mon[ai].test[ti].away;
      Alert("AIB: ",dir," ",g_mon[ai].cls," @ ",DoubleToString(entry,Digits),
            "  [",Sig_TestName(ti),"|",code,"]");
   }
}

//══════════════════════════════════════════════════════════════════
//  Panel entry struct
//══════════════════════════════════════════════════════════════════
struct SigEntry {
   int    ai,ti,clsLevel;
   string code,clsL,testName,dir;
   double score;
   bool   isPending;
};

//══════════════════════════════════════════════════════════════════
//  Advisory text — classification-aware
//══════════════════════════════════════════════════════════════════
string Sig_BuildAdvice(SigEntry &entries[],int eCount,int &topClsOut)
{
   topClsOut=0;
   if(eCount==0) return "No qualified signals. Wait for next angle.";

   double topScore=-1; int topIdx=-1;
   int    pendBuy=0,pendSell=0;
   for(int i=0;i<eCount;i++){
      if(!entries[i].isPending) continue;
      if(entries[i].score>topScore){topScore=entries[i].score;topIdx=i;}
      if(entries[i].dir=="BUY") pendBuy++; else pendSell++;
   }

   if(topIdx<0){
      int bounceN=0,breakN=0;
      for(int i=0;i<eCount;i++){
         int r=g_mon[entries[i].ai].test[entries[i].ti].react[0];
         if(r==MON_REACT_BOUNCE) bounceN++;
         if(r==MON_REACT_BREAK)  breakN++;
      }
      if(bounceN>0) return StringFormat("%d signal(s) hit target. Watch for new setup.",bounceN);
      if(breakN>0)  return StringFormat("%d signal(s) stopped out. Wait for next setup.",breakN);
      return "Signals resolved. Monitor for new angles.";
   }

   if(pendBuy>0&&pendSell>0)
      return "BUY + SELL conflict — stay flat until one side clears.";

   SigEntry top=entries[topIdx];
   topClsOut=top.clsLevel;
   int   cnt=pendBuy+pendSell;
   string d=top.dir;

   if(top.clsLevel==4){
      if(cnt>=2) return StringFormat("STRONG x%d [%s] — Multiple signals. Enter now.",cnt,d);
      return "STRONG: "+top.code+" ["+d+"] — Enter, standard risk.";
   }
   if(top.clsLevel==3){
      if(cnt>=2) return StringFormat("GOOD x%d [%s] — Acceptable. Enter at market.",cnt,d);
      return "GOOD: "+top.code+" ["+d+"] — Acceptable risk. Enter.";
   }
   if(top.clsLevel==2)
      return "WEAK signal: "+top.code+" ["+d+"] — Reduce size or wait.";
   return "VERY WEAK signals only. Wait for better classification.";
}

//══════════════════════════════════════════════════════════════════
//  Panel drawing
//══════════════════════════════════════════════════════════════════
void Sig_DeletePanel()
{
   int tot=ObjectsTotal();
   for(int i=tot-1;i>=0;i--){
      string nm=ObjectName(i);
      if(StringFind(nm,SIG_PFX+"PANEL_",0)==0||StringFind(nm,SIG_PFX+"BTN_",0)==0)
         ObjectDelete(0,nm);
   }
}

void Sig_DrawPanel(SigEntry &entries[],int eCount)
{
   if(!InpSigShowPanel){Sig_DeletePanel();return;}

   int dispRows=MathMin(eCount,InpSigMaxRows);
   int headerH =24;
   int bodyH   =MathMax(dispRows,1)*ROW_H+6;
   int adviceH =InpSigShowAdvice?ADVICE_H+6:0;
   int btnRowH =BTN_H+10;
   int sepH    =4;
   int totalH  =headerH+sepH+bodyH+(adviceH>0?sepH+adviceH:0)+sepH+btnRowH;
   int PX=InpSigPanelX, PY=InpSigPanelY, PW=PANEL_W;
   int corn=CORNER_LEFT_UPPER;

   Sig_SRect(Sig_PN("BG"), PX,PY,PW,totalH,(color)C'12,15,22',corn);
   Sig_SRect(Sig_PN("HDR"),PX,PY,PW,headerH,(color)C'18,28,50',corn);

   string modeStr="";
   if(g_sigPickHide) modeStr=" [PICK-HIDE]";
   if(g_sigPickShow) modeStr=" [PICK-SHOW]";
   if(g_sigHideAll)  modeStr=" [HIDDEN]";
   color modeCol=g_sigPickHide?(color)C'210,140,40':
                 (g_sigPickShow?(color)C'210,210,60':
                 (g_sigHideAll?(color)C'200,68,68':(color)C'140,185,240'));

   Sig_SLabel(Sig_PN("TITLE"),PX+8,PY+7,
              StringFormat("AIB SIGNAL v4.0  %d active%s",eCount,modeStr),
              modeCol,9,corn);

   int rowY=PY+headerH+sepH;
   for(int i=0;i<dispRows;i++){
      SigEntry e=entries[i];
      string mk=(e.clsLevel>=4?">":".");
      string pStr=(e.isPending?"[P]":"   ");
      string rowTxt=StringFormat("%s %-5s Z%s %-9s %s %s %s",
                                  mk,e.code,e.clsL,
                                  Sig_ClsStr(e.clsLevel),
                                  pStr,e.testName,e.dir);
      color rowCol=Sig_ClsColor(e.clsLevel);
      if(!e.isPending) rowCol=Sig_Blend(rowCol,clrBlack,40);
      Sig_SLabel(Sig_PN("ROW"+IntegerToString(i)),
                 PX+6,rowY+i*ROW_H,rowTxt,rowCol,8,corn);
   }

   if(eCount>dispRows)
      Sig_SLabel(Sig_PN("MORE"),PX+6,rowY+dispRows*ROW_H,
                 StringFormat("... +%d more",eCount-dispRows),
                 (color)C'78,78,78',7,corn);
   else
      Sig_DelObj(Sig_PN("MORE"));

   for(int i=dispRows;i<InpSigMaxRows+2;i++) Sig_DelObj(Sig_PN("ROW"+IntegerToString(i)));

   int nextY=rowY+MathMax(dispRows,1)*ROW_H+6;
   if(InpSigShowAdvice){
      nextY+=sepH;
      int topCls=0;
      string advice=Sig_BuildAdvice(entries,eCount,topCls);
      color advBorder=Sig_Blend(Sig_ClsColor(topCls),(color)C'12,16,28',55);
      Sig_SRect(Sig_PN("ADVBG"),PX+4,nextY,PW-8,ADVICE_H,advBorder,corn);
      Sig_SLabel(Sig_PN("ADVHDR"),PX+8,nextY+3,"ADVICE",
                 (color)C'88,118,165',7,corn);
      color advTxtCol=Sig_ClsColor(topCls);
      int maxCh=(PW-22)/6;
      if(StringLen(advice)>maxCh){
         int sp=maxCh;
         for(int c=maxCh;c>maxCh-18&&c>0;c--)
            if(StringGetCharacter(advice,c)==' '){sp=c;break;}
         Sig_SLabel(Sig_PN("ADVL1"),PX+8,nextY+14,
                    StringSubstr(advice,0,sp),advTxtCol,8,corn);
         Sig_SLabel(Sig_PN("ADVL2"),PX+8,nextY+26,
                    StringSubstr(advice,sp+1),(color)C'185,185,185',8,corn);
      } else {
         Sig_SLabel(Sig_PN("ADVL1"),PX+8,nextY+14,advice,advTxtCol,8,corn);
         Sig_DelObj(Sig_PN("ADVL2"));
      }
      nextY+=ADVICE_H+sepH;
   } else {
      Sig_DelObj(Sig_PN("ADVBG")); Sig_DelObj(Sig_PN("ADVHDR"));
      Sig_DelObj(Sig_PN("ADVL1")); Sig_DelObj(Sig_PN("ADVL2"));
   }

   int btnY=nextY+sepH;
   int bX  =PX+4;
   color cN=(color)C'28,44,72';
   color cA=(color)C'72,44,14';
   color cD=(color)C'68,16,16';

   Sig_SBtn(Sig_BN("HIDEALL"), bX,             btnY,BTN_W,BTN_H,"Hide All",
            g_sigHideAll?cD:cN,clrWhite,corn);
   Sig_SBtn(Sig_BN("SHOWALL"), bX+BTN_W+3,     btnY,BTN_W,BTN_H,"Show All",  cN,clrWhite,corn);
   Sig_SBtn(Sig_BN("PICKHIDE"),bX+(BTN_W+3)*2, btnY,BTN_W,BTN_H,"Hide Zone",
            g_sigPickHide?cA:cN,g_sigPickHide?clrYellow:clrWhite,corn);
   Sig_SBtn(Sig_BN("PICKSHOW"),bX+(BTN_W+3)*3, btnY,BTN_W,BTN_H,"Pick Ang",
            g_sigPickShow?cA:cN,g_sigPickShow?clrYellow:clrWhite,corn);
}

//══════════════════════════════════════════════════════════════════
//  Button / chart event handling
//══════════════════════════════════════════════════════════════════
void Sig_CheckButtons()
{
   if(ObjectFind(0,Sig_BN("HIDEALL"))>=0&&ObjectGetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE)){
      g_sigHideAll=!g_sigHideAll;
      if(g_sigHideAll){g_sigPickHide=false;g_sigPickShow=false;}
      ObjectSetInteger(0,Sig_BN("HIDEALL"),OBJPROP_STATE,false);ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("SHOWALL"))>=0&&ObjectGetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE)){
      g_sigHideAll=false;
      if(g_sigHideInit) ArrayInitialize(g_sigHide,false);
      g_sigPickHide=false;g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("SHOWALL"),OBJPROP_STATE,false);ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKHIDE"))>=0&&ObjectGetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE)){
      g_sigPickHide=!g_sigPickHide;
      if(g_sigPickHide) g_sigPickShow=false;
      ObjectSetInteger(0,Sig_BN("PICKHIDE"),OBJPROP_STATE,false);ChartRedraw(0);
   }
   if(ObjectFind(0,Sig_BN("PICKSHOW"))>=0&&ObjectGetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE)){
      g_sigPickShow=!g_sigPickShow;
      if(g_sigPickShow) g_sigPickHide=false;
      ObjectSetInteger(0,Sig_BN("PICKSHOW"),OBJPROP_STATE,false);ChartRedraw(0);
   }
}

bool Sig_ParseName(const string nm,int &ai,int &ti)
{
   if(StringFind(nm,SIG_PFX,0)!=0) return false;
   string rest=StringSubstr(nm,StringLen(SIG_PFX));
   int p1=StringFind(rest,"_",0); if(p1<0) return false;
   int p2=StringFind(rest,"_",p1+1); if(p2<0) return false;
   ai=(int)StringToInteger(StringSubstr(rest,0,p1));
   ti=(int)StringToInteger(StringSubstr(rest,p1+1,p2-p1-1));
   return(ai>=0&&ai<1024&&ti>=0&&ti<4);
}

void Sig_OnChartEvent(const int id,const long lparam,
                      const double dparam,const string sparam)
{
   if(!InpSigEnabled) return;
   if(id==CHARTEVENT_OBJECT_CLICK){
      if(StringFind(sparam,SIG_PFX+"BTN_",0)==0) return;
      if(g_sigPickHide&&StringFind(sparam,SIG_PFX,0)==0){
         int ai=-1,ti=-1;
         if(Sig_ParseName(sparam,ai,ti)){
            if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
            g_sigHide[ai][ti]=true;Sig_DeleteZone(ai,ti);
            g_sigPickHide=false;ChartRedraw(0);
         }
         return;
      }
   }
   if(id==CHARTEVENT_CLICK&&g_sigPickShow){
      datetime clickT=0; double clickP=0.0; int subwin=0;
      if(!ChartXYToTimePrice(0,(int)lparam,(int)dparam,subwin,clickT,clickP)) return;
      int bestAi=-1; long bestDt=LONG_MAX;
      for(int i=0;i<g_monCount;i++){
         if(!g_mon[i].valid) continue;
         long dt=MathAbs((long)g_mon[i].formTime-(long)clickT);
         if(dt<bestDt){bestDt=dt;bestAi=i;}
      }
      if(bestAi>=0){
         if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
         for(int i=0;i<g_monCount&&i<1024;i++)
            for(int t=0;t<4;t++) g_sigHide[i][t]=(i!=bestAi);
         g_sigHideAll=false;g_sigPickShow=false;ChartRedraw(0);
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Main: Sig_OnCalculate()  —  three-pass: collect → slots → draw
//══════════════════════════════════════════════════════════════════
void Sig_OnCalculate()
{
   if(!InpSigEnabled) return;
   if(!g_sigHideInit){ArrayInitialize(g_sigHide,false);g_sigHideInit=true;}
   ComboTable_Init();
   Sig_InitAlerts();
   Sig_CheckButtons();

   // Pass 1: Collect qualifying zones
   SigZone  zones[];
   int      zCount=0;
   SigEntry entries[];
   int      eCount=0;
   ArrayResize(zones,   g_monCount*MON_NPTS);
   ArrayResize(entries, g_monCount*MON_NPTS);

   for(int ai=0;ai<g_monCount;ai++){
      if(!g_mon[ai].valid) continue;

      string cls  =g_mon[ai].cls;
      string clsL =(StringLen(cls)>=2?StringSubstr(cls,1,1):cls);
      string dir  =(g_mon[ai].dir>0?"BUY":"SELL");
      bool   isBuy=(g_mon[ai].dir>0);
      double rat  =g_mon[ai].ratio;
      double lu1  =(g_mon[ai].u1R>1e-10?g_mon[ai].L/g_mon[ai].u1R*100.0:0.0);
      string prev =Sig_PrevClsLtr(ai);
      string code =ComboCode(cls,dir,rat,lu1,prev);
      int    cidx =ComboFind(code);

      for(int ti=0;ti<MON_NPTS;ti++){
         int react=g_mon[ai].test[ti].react[0];
         if(react==MON_REACT_NA){ Sig_DeleteZone(ai,ti); continue; }

         // v4.0 classification filter
         int clsLvl=Sig_Classify(cidx);
         if(clsLvl<=0){
            Sig_DeleteZone(ai,ti);
            Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
            Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
            Sig_DelObj(Sig_N(ai,ti,"PREV_LBL"));
            continue;
         }

         double score=Sig_Score(cidx,ti);
         bool   isPreview=(react==MON_REACT_UNTOUCHED);

         // Compute price range for overlap detection
         double away  =g_mon[ai].test[ti].away;
         double entry =g_mon[ai].test[ti].anchor+g_mon[ai].L*away;
         double sl    =entry+g_mon[ai].B*away;
         double tp1   =g_mon[ai].test[ti].tp[0];
         double pMin  =MathMin(MathMin(entry,sl),tp1);
         double pMax  =MathMax(MathMax(entry,sl),tp1);

         // Base time: formTime for preview, touchTime for real
         datetime bTime=(isPreview?g_mon[ai].formTime:g_mon[ai].test[ti].touchTime);
         if(!isPreview&&bTime<=0){ Sig_DeleteZone(ai,ti); continue; }

         SigZone z;
         z.ai=ai; z.ti=ti; z.clsLevel=clsLvl; z.score=score;
         z.code=code; z.clsL=clsL; z.dir=dir; z.isBuy=isBuy;
         z.isPreview=isPreview;
         z.pMin=pMin; z.pMax=pMax; z.baseTime=bTime;
         z.grpId=0; z.grpSlot=0; z.grpSize=1;
         z.slotTL=bTime; z.slotTR=bTime+(datetime)g_unitSeconds;
         zones[zCount++]=z;

         // Collect panel entry
         SigEntry e;
         e.ai=ai; e.ti=ti; e.clsLevel=clsLvl; e.score=score;
         e.code=code; e.clsL=clsL; e.testName=Sig_TestName(ti); e.dir=dir;
         e.isPending=(react==MON_REACT_PENDING);
         entries[eCount++]=e;

         if(!isPreview) Sig_CheckTouchAlert(ai,ti,code,dir);
      }
   }

   // Pass 2: Compute time slots for overlapping zones
   if(zCount>0) Sig_ComputeSlots(zones,zCount);

   // Pass 3: Draw
   for(int i=0;i<zCount;i++){
      SigZone z=zones[i];
      int ai=z.ai, ti=z.ti;
      if(!Sig_IsVisible(ai,ti)){
         Sig_DeleteZone(ai,ti);
         Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_LBL"));
         continue;
      }
      if(z.isPreview){
         Sig_DrawPreviewV4(zones[i]);
         Sig_DeleteZone(ai,ti);
      } else {
         Sig_DelObj(Sig_N(ai,ti,"PREV_SL"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_TP"));
         Sig_DelObj(Sig_N(ai,ti,"PREV_LBL"));
         Sig_DrawZoneV4(zones[i]);
      }
   }

   // Sort panel entries by score descending
   for(int i=0;i<eCount-1;i++)
      for(int j=i+1;j<eCount;j++)
         if(entries[i].score<entries[j].score)
            {SigEntry tmp=entries[i];entries[i]=entries[j];entries[j]=tmp;}

   Sig_DrawPanel(entries,eCount);
   ChartRedraw(0);
}

//══════════════════════════════════════════════════════════════════
//  Deinit
//══════════════════════════════════════════════════════════════════
void Sig_OnDeinit()
{
   int tot=ObjectsTotal();
   for(int i=tot-1;i>=0;i--){
      string nm=ObjectName(i);
      if(StringFind(nm,SIG_PFX,0)==0) ObjectDelete(0,nm);
   }
}
