//==================================================================
//  AIB_Monitor.mqh
//  Geometry + reaction tracking for AIB Signal indicator
//
//  Called from AIB_Angles_V535_Signal.mq4:
//    Mon_OnInit()          → in OnInit()
//    Mon_OnDeinit(reason)  → in OnDeinit()
//    Mon_OnTick()          → in OnCalculate() before Sig_OnCalculate()
//    Mon_OnAngleSaved(r)   → in SaveAngleResult() after cache update
//
//  Geometry (original):
//    diagTop = max(r.drawP1, r.drawP2)
//    diagBot = min(r.drawP1, r.drawP2)
//    L = diagTop - diagBot          (drawn diagonal range)
//    B = 0.236 * u2R               (stop buffer = 23.6% of U2 correction)
//    formTime = r.u1End            (angle confirmed when U1 unit closes)
//
//  Test levels (BUY):
//    U1X1: anchor=u1H, away=+1, level=u1H+L. TPs=[u1H-L, dB-L, u2L-L]
//    U2X1: anchor=u2L, away=-1, level=u2L-L. TPs=[u2L+L, dT+L, u1H+L]
//    DLX1: anchor=dT,  away=+1, level=dT+L.  TPs=[dB-L, u2L-L]
//    DRX1: anchor=dB,  away=-1, level=dB-L.  TPs=[dT+L, u2H+L]
//  SELL is the vertical mirror.
//==================================================================

#define MON_NPTS             4
#define MON_REACT_UNTOUCHED  0
#define MON_REACT_BOUNCE     1
#define MON_REACT_BREAK     (-1)
#define MON_REACT_NA        (-2)
#define MON_REACT_PENDING   (-3)

//── Structs ────────────────────────────────────────────────────────
struct MonTest {
   double   anchor;      // reference price; level = anchor + L * away
   double   away;        // +1=test above entry, -1=test below entry
   double   tp[3];       // TP1, TP2, TP3 absolute prices
   int      nTP;         // 2 or 3
   int      react[3];    // [0]=X1 result; [1],[2]=NA (X2/X3 not tracked)
   bool     tpHit[3];    // which TPs were reached
   datetime touchTime;   // bar time when zone was first touched
};

struct MonAngle {
   bool     valid;
   int      u1Id, u2Id;
   datetime formTime;    // = r.u1End (angle confirmed when U1 unit closes)
   int      dir;         // +1=BUY, -1=SELL
   string   cls;         // "ZB".."ZH"
   bool     confirmed;
   double   u1H, u1L;   // U1 unit high/low
   double   u2H, u2L;   // U2 unit high/low
   double   u1R, u2R;   // U1/U2 ranges
   double   ratio;       // u1R/u2R * 100
   double   corrPct;
   double   diagTop;     // max(drawP1, drawP2)
   double   diagBot;     // min(drawP1, drawP2)
   double   L;           // diagTop - diagBot (diagonal range)
   double   B;           // 0.236 * u2R (stop buffer)
   MonTest  test[MON_NPTS];
};

MonAngle g_mon[];
int      g_monCount = 0;

//══════════════════════════════════════════════════════════════════
//  Geometry helpers
//══════════════════════════════════════════════════════════════════
void Mon_BuildTest(int ai, int ti, double anchor, double away, double &tps[], int ntp)
{
   g_mon[ai].test[ti].anchor    = anchor;
   g_mon[ai].test[ti].away      = away;
   g_mon[ai].test[ti].nTP       = ntp;
   g_mon[ai].test[ti].react[0]  = MON_REACT_UNTOUCHED;
   g_mon[ai].test[ti].react[1]  = MON_REACT_NA;
   g_mon[ai].test[ti].react[2]  = MON_REACT_NA;
   g_mon[ai].test[ti].touchTime = 0;
   for(int i = 0; i < 3; i++) {
      g_mon[ai].test[ti].tp[i]    = (i < ntp ? tps[i] : 0.0);
      g_mon[ai].test[ti].tpHit[i] = false;
   }
}

void Mon_GeoRebuild(int ai)
{
   double L  = g_mon[ai].L;
   double dT = g_mon[ai].diagTop;
   double dB = g_mon[ai].diagBot;
   double u1H = g_mon[ai].u1H,  u1L = g_mon[ai].u1L;
   double u2H = g_mon[ai].u2H,  u2L = g_mon[ai].u2L;
   double tps[3];

   if(g_mon[ai].dir > 0)
   {
      // ── BUY ──
      // U1X1: tests resistance above u1H. entry=u1H+L. Bounce → targets DOWN (3 TPs)
      tps[0]=u1H-L; tps[1]=dB-L; tps[2]=u2L-L;
      Mon_BuildTest(ai, 0, u1H, +1.0, tps, 3);

      // U2X1: tests support below u2L. entry=u2L-L. Bounce → targets UP (3 TPs)
      tps[0]=u2L+L; tps[1]=dT+L; tps[2]=u1H+L;
      Mon_BuildTest(ai, 1, u2L, -1.0, tps, 3);

      // DLX1 (BZL): tests resistance above diagTop. entry=dT+L. Bounce → targets DOWN (2 TPs)
      tps[0]=dB-L; tps[1]=u2L-L; tps[2]=0.0;
      Mon_BuildTest(ai, 2, dT, +1.0, tps, 2);

      // DRX1 (BZR): tests support below diagBot. entry=dB-L. Bounce → targets UP (2 TPs)
      tps[0]=dT+L; tps[1]=u2H+L; tps[2]=0.0;
      Mon_BuildTest(ai, 3, dB, -1.0, tps, 2);
   }
   else
   {
      // ── SELL (vertical mirror) ──
      // U1X1: tests support below u1L. entry=u1L-L. Bounce → targets UP (3 TPs)
      tps[0]=u1L+L; tps[1]=dT+L; tps[2]=u2H+L;
      Mon_BuildTest(ai, 0, u1L, -1.0, tps, 3);

      // U2X1: tests resistance above u2H. entry=u2H+L. Bounce → targets DOWN (3 TPs)
      tps[0]=u2H-L; tps[1]=dB-L; tps[2]=u1L-L;
      Mon_BuildTest(ai, 1, u2H, +1.0, tps, 3);

      // DLX1 (SZL): tests support below diagBot. entry=dB-L. Bounce → targets UP (2 TPs)
      tps[0]=dT+L; tps[1]=u2H+L; tps[2]=0.0;
      Mon_BuildTest(ai, 2, dB, -1.0, tps, 2);

      // DRX1 (SZR): tests resistance above diagTop. entry=dT+L. Bounce → targets DOWN (2 TPs)
      tps[0]=dB-L; tps[1]=u2L-L; tps[2]=0.0;
      Mon_BuildTest(ai, 3, dT, +1.0, tps, 2);
   }
}

//══════════════════════════════════════════════════════════════════
//  Resolve SL-vs-TP1 order inside a single chart candle via M1 drill-down
//  Used only when ONE candle touches BOTH levels (ambiguous on its own).
//  Returns: +1 = TP1 reached first (valid BOUNCE)
//           -1 = SL reached first (BREAK)
//            0 = undeterminable (no M1 data) → caller treats as BREAK
//  HARD RULE: a setup is "protected" only if TP1 is confirmed before SL.
//══════════════════════════════════════════════════════════════════
int Mon_ResolveOrderM1(datetime barTime, double away, double sl, double tp1)
{
   datetime bStart = barTime;
   datetime bEnd   = barTime + (datetime)((long)Period() * 60 - 1);

   int iLo = iBarShift(Symbol(), PERIOD_M1, bStart, false); // oldest (largest index)
   int iHi = iBarShift(Symbol(), PERIOD_M1, bEnd,   false); // newest (smallest index)
   if(iLo < 0 || iHi < 0 || iLo < iHi) return 0;            // no usable M1 data

   for(int b = iLo; b >= iHi; b--) {
      double mh = iHigh(Symbol(), PERIOD_M1, b);
      double ml = iLow (Symbol(), PERIOD_M1, b);
      bool tHit = (away > 0 ? ml <= tp1 : mh >= tp1);
      bool sHit = (away > 0 ? mh >= sl  : ml <= sl);
      if(tHit && sHit) return -1;  // both in same M1 bar → still ambiguous → conservative
      if(sHit)         return -1;  // SL first
      if(tHit)         return +1;  // TP1 first
   }
   return 0;
}

//══════════════════════════════════════════════════════════════════
//  Internal: historical scan for one angle (called once on creation)
//══════════════════════════════════════════════════════════════════
void Mon_ScanHistory(int ai)
{
   if(!g_mon[ai].valid) return;

   int    bars  = iBars(Symbol(), 0);
   double L     = g_mon[ai].L;
   double B     = g_mon[ai].B;

   int startBar = iBarShift(Symbol(), 0, g_mon[ai].formTime, false);
   if(startBar < 0) startBar = bars - 1;

   for(int ti = 0; ti < MON_NPTS; ti++)
   {
      if(g_mon[ai].test[ti].react[0] != MON_REACT_UNTOUCHED) continue;

      double away  = g_mon[ai].test[ti].away;
      double entry = g_mon[ai].test[ti].anchor + L * away;
      double sl    = entry + B * away;
      double tp1   = g_mon[ai].test[ti].tp[0];
      double tp2   = g_mon[ai].test[ti].tp[1];
      double tp3   = g_mon[ai].test[ti].tp[2];
      int    nTP   = g_mon[ai].test[ti].nTP;

      for(int b = startBar; b >= 0; b--)
      {
         double hi  = iHigh(Symbol(), 0, b);
         double lo  = iLow(Symbol(), 0, b);
         int    cur = g_mon[ai].test[ti].react[0];

         //── Phase 1: detect touch ────────────────────────────────
         if(cur == MON_REACT_UNTOUCHED)
         {
            bool touched = (away > 0 ? hi >= entry : lo <= entry);
            if(touched) {
               g_mon[ai].test[ti].touchTime = iTime(Symbol(), 0, b);
               g_mon[ai].test[ti].react[0]  = MON_REACT_PENDING;
               cur = MON_REACT_PENDING;
            }
         }

         //── Phase 2: resolve PENDING — protected ONLY if TP1 before SL ──
         if(cur == MON_REACT_PENDING)
         {
            bool tp1Hit = (away > 0 ? lo <= tp1 : hi >= tp1);
            bool slHit  = (away > 0 ? hi >= sl   : lo <= sl);

            // Same candle touched both → resolve true order via M1.
            // Protected only if M1 confirms TP1 first; otherwise it's a BREAK.
            bool tp1Wins = tp1Hit;
            if(tp1Hit && slHit)
               tp1Wins = (Mon_ResolveOrderM1(iTime(Symbol(),0,b), away, sl, tp1) > 0);

            if(tp1Wins) {
               g_mon[ai].test[ti].tpHit[0] = true;
               g_mon[ai].test[ti].react[0]  = MON_REACT_BOUNCE;
               cur = MON_REACT_BOUNCE;
               if(nTP >= 2 && (away > 0 ? lo <= tp2 : hi >= tp2))
                  g_mon[ai].test[ti].tpHit[1] = true;
               if(nTP >= 3 && (away > 0 ? lo <= tp3 : hi >= tp3))
                  g_mon[ai].test[ti].tpHit[2] = true;
            }
            else if(slHit) {
               g_mon[ai].test[ti].react[0] = MON_REACT_BREAK;
               cur = MON_REACT_BREAK;
            }
         }

         //── Phase 3: track TP2/TP3 after BOUNCE ─────────────────
         if(cur == MON_REACT_BOUNCE)
         {
            if(nTP >= 2 && !g_mon[ai].test[ti].tpHit[1])
               if(away > 0 ? lo <= tp2 : hi >= tp2)
                  g_mon[ai].test[ti].tpHit[1] = true;
            if(nTP >= 3 && !g_mon[ai].test[ti].tpHit[2])
               if(away > 0 ? lo <= tp3 : hi >= tp3)
                  g_mon[ai].test[ti].tpHit[2] = true;
         }

         if(cur == MON_REACT_BREAK || cur == MON_REACT_BOUNCE) break;
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Mon_OnAngleSaved — called when an angle is created or updated
//══════════════════════════════════════════════════════════════════
void Mon_OnAngleSaved(const AngleResult &r)
{
   if(!r.valid || !r.confirmed) return;
   if(r.classText == "" || r.dirState == 0) return;

   double u1R = r.u1High - r.u1Low;
   double u2R = r.u2High - r.u2Low;
   if(u1R < Point * 2 || u2R < Point * 2) return;

   // Diagonal endpoints from drawn angle line
   double diA = r.drawP1, diB = r.drawP2;
   if(diA <= 0.0 || diB <= 0.0) {
      // Fallback: BUY diagonal = u1High→u2Low; SELL = u1Low→u2High
      if(r.dirState > 0) { diA = r.u1High; diB = r.u2Low;  }
      else               { diA = r.u1Low;  diB = r.u2High; }
   }
   double diagTop = MathMax(diA, diB);
   double diagBot = MathMin(diA, diB);
   double L = diagTop - diagBot;
   if(L <= 0.0) return;

   double B = 0.236 * u2R;

   // Find existing slot or allocate new one
   int ai = -1;
   for(int i = 0; i < g_monCount; i++)
      if(g_mon[i].valid && g_mon[i].u1Id == r.u1Id && g_mon[i].u2Id == r.u2Id)
         { ai = i; break; }

   bool isNew = (ai < 0);
   if(isNew) {
      ai = g_monCount;
      ArrayResize(g_mon, g_monCount + 1);
      g_monCount++;
   }

   // Descriptive fields always refreshed
   g_mon[ai].valid    = true;
   g_mon[ai].u1Id     = r.u1Id;
   g_mon[ai].u2Id     = r.u2Id;
   g_mon[ai].formTime = (r.u1End > 0 ? r.u1End : r.u1Start);
   g_mon[ai].dir      = (r.dirState > 0 ? +1 : -1);
   g_mon[ai].cls      = (r.classText != "" ? r.classText : r.angleName);
   g_mon[ai].confirmed= r.confirmed;
   g_mon[ai].u1H = r.u1High;  g_mon[ai].u1L = r.u1Low;
   g_mon[ai].u2H = r.u2High;  g_mon[ai].u2L = r.u2Low;
   g_mon[ai].u1R = u1R;       g_mon[ai].u2R = u2R;
   g_mon[ai].ratio   = (u2R > 1e-10 ? 100.0 * u1R / u2R : 0.0);
   g_mon[ai].corrPct = r.correctionPct;
   g_mon[ai].diagTop = diagTop;
   g_mon[ai].diagBot = diagBot;
   g_mon[ai].L       = L;
   g_mon[ai].B       = B;

   if(isNew) {
      Mon_GeoRebuild(ai);
      Mon_ScanHistory(ai);
   }
   // Updates keep reaction progress untouched (geometry only refreshes on isNew)
}

//══════════════════════════════════════════════════════════════════
//  Mon_OnTick — incremental check on current bar
//══════════════════════════════════════════════════════════════════
void Mon_OnTick()
{
   static int s_prevBars = 0;
   int curBars = iBars(Symbol(), 0);

   if(s_prevBars == 0) {
      for(int ai = 0; ai < g_monCount; ai++)
         Mon_ScanHistory(ai);
      s_prevBars = curBars;
      return;
   }

   double   hi0 = High[0], lo0 = Low[0];
   datetime t0  = Time[0];

   for(int ai = 0; ai < g_monCount; ai++)
   {
      if(!g_mon[ai].valid) continue;
      if(t0 < g_mon[ai].formTime) continue;
      double L = g_mon[ai].L;
      double B = g_mon[ai].B;

      for(int ti = 0; ti < MON_NPTS; ti++)
      {
         int cur = g_mon[ai].test[ti].react[0];
         if(cur == MON_REACT_BREAK || cur == MON_REACT_NA || cur == MON_REACT_BOUNCE) continue;

         double away  = g_mon[ai].test[ti].away;
         double entry = g_mon[ai].test[ti].anchor + L * away;
         double sl    = entry + B * away;
         double tp1   = g_mon[ai].test[ti].tp[0];
         double tp2   = g_mon[ai].test[ti].tp[1];
         double tp3   = g_mon[ai].test[ti].tp[2];
         int    nTP   = g_mon[ai].test[ti].nTP;

         //── Detect touch ─────────────────────────────────────────
         if(cur == MON_REACT_UNTOUCHED)
         {
            bool touched = (away > 0 ? hi0 >= entry : lo0 <= entry);
            if(touched) {
               g_mon[ai].test[ti].touchTime = t0;
               g_mon[ai].test[ti].react[0]  = MON_REACT_PENDING;
               cur = MON_REACT_PENDING;
            }
         }

         //── Resolve PENDING — protected ONLY if TP1 before SL ──────
         if(cur == MON_REACT_PENDING)
         {
            bool tp1Hit = (away > 0 ? lo0 <= tp1 : hi0 >= tp1);
            bool slHit  = (away > 0 ? hi0 >= sl   : lo0 <= sl);

            // Same candle touched both → resolve true order via M1.
            bool tp1Wins = tp1Hit;
            if(tp1Hit && slHit)
               tp1Wins = (Mon_ResolveOrderM1(t0, away, sl, tp1) > 0);

            if(tp1Wins) {
               g_mon[ai].test[ti].tpHit[0] = true;
               g_mon[ai].test[ti].react[0]  = MON_REACT_BOUNCE;
               cur = MON_REACT_BOUNCE;
               if(nTP >= 2 && (away > 0 ? lo0 <= tp2 : hi0 >= tp2))
                  g_mon[ai].test[ti].tpHit[1] = true;
               if(nTP >= 3 && (away > 0 ? lo0 <= tp3 : hi0 >= tp3))
                  g_mon[ai].test[ti].tpHit[2] = true;
            }
            else if(slHit) {
               g_mon[ai].test[ti].react[0] = MON_REACT_BREAK;
               cur = MON_REACT_BREAK;
            }
         }

         //── Track TP2/TP3 after BOUNCE ────────────────────────────
         if(cur == MON_REACT_BOUNCE)
         {
            if(nTP >= 2 && !g_mon[ai].test[ti].tpHit[1])
               if(away > 0 ? lo0 <= tp2 : hi0 >= tp2)
                  g_mon[ai].test[ti].tpHit[1] = true;
            if(nTP >= 3 && !g_mon[ai].test[ti].tpHit[2])
               if(away > 0 ? lo0 <= tp3 : hi0 >= tp3)
                  g_mon[ai].test[ti].tpHit[2] = true;
         }
      }
   }
   s_prevBars = curBars;
}

//══════════════════════════════════════════════════════════════════
//  Lifecycle
//══════════════════════════════════════════════════════════════════
void Mon_OnInit()
{
   ArrayResize(g_mon, 0);
   g_monCount = 0;
}

void Mon_OnDeinit(const int reason)
{
   g_monCount = 0;
   ArrayResize(g_mon, 0);
}
