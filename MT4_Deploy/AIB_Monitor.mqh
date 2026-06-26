//==================================================================
//  AIB_Monitor.mqh
//  Monitoring layer — tracks AIB angle test zones, price reactions
//
//  Called from AIB_Angles_V535_Signal.mq4:
//    Mon_OnInit()          → in OnInit()
//    Mon_OnDeinit(reason)  → in OnDeinit()
//    Mon_OnTick()          → in OnCalculate() before Sig_OnCalculate()
//    Mon_OnAngleSaved(r)   → in SaveAngleResult() after cache update
//
//  Zone geometry (BUY, away=-1):
//    U1X1 (ti=0): entry at correction low (u2Low)
//    U2X1 (ti=1): entry 10% of u1R below correction low
//    DLX1 (ti=2): entry at 38.2% Fibonacci retracement of U1
//    DRX1 (ti=3): entry at 61.8% Fibonacci retracement of U1
//  SELL mirrors BUY (away=+1, levels reflected upward)
//
//  L = u2 correction range (zone body height)
//  B = L * 0.25 (stop buffer below entry for BUY, above for SELL)
//==================================================================

//── Constants ──────────────────────────────────────────────────────
#define MON_NPTS             4
#define MON_REACT_UNTOUCHED  0
#define MON_REACT_BOUNCE     1
#define MON_REACT_BREAK     (-1)
#define MON_REACT_NA        (-2)
#define MON_REACT_PENDING   (-3)
#define MON_MAX_RECORDS      512

//── Structs ────────────────────────────────────────────────────────
struct MonTest {
   int      react[1];    // MON_REACT_* — [0] only
   double   away;        // direction sign: -1=BUY zone, +1=SELL zone
   double   anchor;      // reference price; entry = anchor + L*away
   double   tp[3];       // TP1, TP2, TP3 absolute prices
   int      nTP;         // valid TPs (2 for DLX1/DRX1, 3 for U1X1/U2X1)
   bool     tpHit[3];    // which TPs were reached
   datetime touchTime;   // bar time when entry zone was first touched
};

struct MonRecord {
   bool     valid;
   datetime formTime;    // angle confirmed (u2 end time)
   string   cls;         // "ZB".."ZH"
   int      dir;         // +1=BUY, -1=SELL
   double   ratio;       // U1/U2 range ratio * 100
   double   u1R;         // U1 range (u1High - u1Low)
   double   L;           // zone body = u2 correction range
   double   B;           // stop buffer = L * 0.25
   MonTest  test[MON_NPTS];
   int      u1Id;        // angle identity
   int      u2Id;
};

//── Globals ────────────────────────────────────────────────────────
MonRecord g_mon[MON_MAX_RECORDS];
int       g_monCount = 0;

//══════════════════════════════════════════════════════════════════
//  Internal: full historical scan for one record
//══════════════════════════════════════════════════════════════════
void Mon_ScanHistory(int ai)
{
   if(ai < 0 || ai >= g_monCount || !g_mon[ai].valid) return;

   int    bars   = iBars(Symbol(), 0);
   bool   isBuy  = (g_mon[ai].dir > 0);
   double L      = g_mon[ai].L;
   double B      = g_mon[ai].B;

   // Start scanning from the bar at formTime
   int startBar = iBarShift(Symbol(), 0, g_mon[ai].formTime, false);
   if(startBar < 0 || startBar >= bars) startBar = bars - 1;

   for(int ti = 0; ti < MON_NPTS; ti++)
   {
      // Only scan if still UNTOUCHED
      if(g_mon[ai].test[ti].react[0] != MON_REACT_UNTOUCHED) continue;

      double entry  = g_mon[ai].test[ti].anchor + L * g_mon[ai].test[ti].away;
      double sl     = entry + B * g_mon[ai].test[ti].away;
      double tp1    = g_mon[ai].test[ti].tp[0];
      double tp2    = g_mon[ai].test[ti].tp[1];
      double tp3    = g_mon[ai].test[ti].tp[2];
      int    nTP    = g_mon[ai].test[ti].nTP;

      // Scan oldest→newest (high bar index = oldest in MT4)
      for(int b = startBar; b >= 0; b--)
      {
         double hi = iHigh(Symbol(), 0, b);
         double lo = iLow(Symbol(), 0, b);

         int curReact = g_mon[ai].test[ti].react[0];

         //── Phase 1: detect entry touch ──────────────────────────
         if(curReact == MON_REACT_UNTOUCHED)
         {
            bool touched = isBuy ? (lo <= entry) : (hi >= entry);
            if(touched)
            {
               g_mon[ai].test[ti].touchTime = iTime(Symbol(), 0, b);
               g_mon[ai].test[ti].react[0]  = MON_REACT_PENDING;
               curReact = MON_REACT_PENDING;
            }
         }

         //── Phase 2: resolve PENDING ─────────────────────────────
         if(curReact == MON_REACT_PENDING)
         {
            // TP1 takes priority over SL on the same bar
            bool tp1Hit = isBuy ? (hi >= tp1) : (lo <= tp1);
            bool slHit  = isBuy ? (lo <= sl)  : (hi >= sl);

            if(tp1Hit)
            {
               g_mon[ai].test[ti].tpHit[0] = true;
               g_mon[ai].test[ti].react[0]  = MON_REACT_BOUNCE;
               curReact = MON_REACT_BOUNCE;
               // Check TP2/TP3 on same bar
               if(nTP >= 2 && (isBuy ? (hi >= tp2) : (lo <= tp2)))
                  g_mon[ai].test[ti].tpHit[1] = true;
               if(nTP >= 3 && (isBuy ? (hi >= tp3) : (lo <= tp3)))
                  g_mon[ai].test[ti].tpHit[2] = true;
            }
            else if(slHit)
            {
               g_mon[ai].test[ti].react[0] = MON_REACT_BREAK;
               curReact = MON_REACT_BREAK;
            }
         }

         //── Phase 3: TP2/TP3 progression after BOUNCE ───────────
         if(curReact == MON_REACT_BOUNCE)
         {
            if(nTP >= 2 && !g_mon[ai].test[ti].tpHit[1])
               if(isBuy ? (hi >= tp2) : (lo <= tp2))
                  g_mon[ai].test[ti].tpHit[1] = true;
            if(nTP >= 3 && !g_mon[ai].test[ti].tpHit[2])
               if(isBuy ? (hi >= tp3) : (lo <= tp3))
                  g_mon[ai].test[ti].tpHit[2] = true;
         }

         // Terminal states: stop scanning this test
         if(curReact == MON_REACT_BREAK || curReact == MON_REACT_BOUNCE) break;
      }
   }
}

//══════════════════════════════════════════════════════════════════
//  Mon_OnAngleSaved — called when an angle is created or updated
//══════════════════════════════════════════════════════════════════
void Mon_OnAngleSaved(const AngleResult &r)
{
   // Only track fully confirmed angles with a class
   if(!r.valid || !r.confirmed) return;
   if(r.classText == "" || r.dirState == 0) return;

   double u1R = r.u1High - r.u1Low;
   double u2R = r.u2High - r.u2Low;
   if(u1R < Point * 2 || u2R < Point * 2) return;

   // Find existing record by unit IDs, else allocate new slot
   int ai = -1;
   for(int i = 0; i < g_monCount; i++)
   {
      if(g_mon[i].valid && g_mon[i].u1Id == r.u1Id && g_mon[i].u2Id == r.u2Id)
      { ai = i; break; }
   }
   if(ai < 0)
   {
      if(g_monCount >= MON_MAX_RECORDS) return;
      ai = g_monCount;
      g_monCount++;
   }

   bool isBuy = (r.dirState > 0);
   double away = isBuy ? -1.0 : 1.0;

   // Fill record fields
   g_mon[ai].valid    = true;
   g_mon[ai].formTime = r.u2End;
   g_mon[ai].cls      = r.classText;
   g_mon[ai].dir      = r.dirState;
   g_mon[ai].u1Id     = r.u1Id;
   g_mon[ai].u2Id     = r.u2Id;
   g_mon[ai].u1R      = u1R;
   g_mon[ai].L        = u2R;
   g_mon[ai].B        = u2R * 0.25;
   g_mon[ai].ratio    = u1R / u2R * 100.0;

   // Reference price for each test (the actual entry level)
   double rp[4];
   if(isBuy)
   {
      rp[0] = r.u2Low;                        // U1X1: correction bottom
      rp[1] = r.u2Low - u1R * 0.10;           // U2X1: 10% below correction low
      rp[2] = r.u1High - 0.382 * u1R;         // DLX1: 38.2% fib of U1
      rp[3] = r.u1High - 0.618 * u1R;         // DRX1: 61.8% fib of U1
   }
   else
   {
      rp[0] = r.u2High;                        // U1X1: correction top
      rp[1] = r.u2High + u1R * 0.10;          // U2X1: 10% above correction high
      rp[2] = r.u1Low  + 0.382 * u1R;         // DLX1: 38.2% fib of U1
      rp[3] = r.u1Low  + 0.618 * u1R;         // DRX1: 61.8% fib of U1
   }

   // TP levels (shared for all tests, based on angle geometry)
   double tp1 = isBuy ? r.u2High              : r.u2Low;
   double tp2 = isBuy ? r.u1High              : r.u1Low;
   double tp3 = isBuy ? (r.u1High + u1R*0.618): (r.u1Low - u1R*0.618);

   for(int ti = 0; ti < MON_NPTS; ti++)
   {
      // Only reset if newly added (don't wipe existing history on update)
      bool isNew = (g_mon[ai].test[ti].touchTime == 0 &&
                    g_mon[ai].test[ti].react[0] == MON_REACT_UNTOUCHED);

      // anchor set so that: entry = anchor + L*away
      // → anchor = rp[ti] - L*away
      g_mon[ai].test[ti].away   = away;
      g_mon[ai].test[ti].anchor = rp[ti] - g_mon[ai].L * away;
      g_mon[ai].test[ti].tp[0]  = tp1;
      g_mon[ai].test[ti].tp[1]  = tp2;
      g_mon[ai].test[ti].nTP    = (ti < 2) ? 3 : 2;
      if(g_mon[ai].test[ti].nTP >= 3)
         g_mon[ai].test[ti].tp[2] = tp3;
      else
         g_mon[ai].test[ti].tp[2] = 0.0;

      if(isNew)
      {
         g_mon[ai].test[ti].react[0]  = MON_REACT_UNTOUCHED;
         g_mon[ai].test[ti].touchTime = 0;
         g_mon[ai].test[ti].tpHit[0]  = false;
         g_mon[ai].test[ti].tpHit[1]  = false;
         g_mon[ai].test[ti].tpHit[2]  = false;
      }
   }

   // Immediately scan history for this angle
   Mon_ScanHistory(ai);
}

//══════════════════════════════════════════════════════════════════
//  Mon_OnTick — called every OnCalculate(); checks current bar
//══════════════════════════════════════════════════════════════════
void Mon_OnTick()
{
   static int s_prevBars = 0;
   int curBars = iBars(Symbol(), 0);
   bool freshLoad = (s_prevBars == 0);

   if(freshLoad)
   {
      // Full history scan for all records on first load
      for(int ai = 0; ai < g_monCount; ai++)
         Mon_ScanHistory(ai);
      s_prevBars = curBars;
      return;
   }

   // Incremental check: current bar only
   double hi0 = High[0];
   double lo0 = Low[0];
   datetime t0 = Time[0];

   for(int ai = 0; ai < g_monCount; ai++)
   {
      if(!g_mon[ai].valid) continue;
      bool isBuy = (g_mon[ai].dir > 0);
      double L   = g_mon[ai].L;
      double B   = g_mon[ai].B;

      for(int ti = 0; ti < MON_NPTS; ti++)
      {
         int curReact = g_mon[ai].test[ti].react[0];
         // Terminal or NA states: skip
         if(curReact == MON_REACT_BREAK || curReact == MON_REACT_NA) continue;

         double entry = g_mon[ai].test[ti].anchor + L * g_mon[ai].test[ti].away;
         double sl    = entry + B * g_mon[ai].test[ti].away;
         double tp1   = g_mon[ai].test[ti].tp[0];
         double tp2   = g_mon[ai].test[ti].tp[1];
         double tp3   = g_mon[ai].test[ti].tp[2];
         int    nTP   = g_mon[ai].test[ti].nTP;

         //── Detect touch ─────────────────────────────────────────
         if(curReact == MON_REACT_UNTOUCHED && t0 >= g_mon[ai].formTime)
         {
            bool touched = isBuy ? (lo0 <= entry) : (hi0 >= entry);
            if(touched)
            {
               g_mon[ai].test[ti].touchTime = t0;
               g_mon[ai].test[ti].react[0]  = MON_REACT_PENDING;
               curReact = MON_REACT_PENDING;
            }
         }

         //── Resolve PENDING ──────────────────────────────────────
         if(curReact == MON_REACT_PENDING)
         {
            bool tp1Hit = isBuy ? (hi0 >= tp1) : (lo0 <= tp1);
            bool slHit  = isBuy ? (lo0 <= sl)  : (hi0 >= sl);

            if(tp1Hit)
            {
               g_mon[ai].test[ti].tpHit[0] = true;
               g_mon[ai].test[ti].react[0]  = MON_REACT_BOUNCE;
               curReact = MON_REACT_BOUNCE;
               if(nTP >= 2 && (isBuy ? (hi0 >= tp2) : (lo0 <= tp2)))
                  g_mon[ai].test[ti].tpHit[1] = true;
               if(nTP >= 3 && (isBuy ? (hi0 >= tp3) : (lo0 <= tp3)))
                  g_mon[ai].test[ti].tpHit[2] = true;
            }
            else if(slHit)
            {
               g_mon[ai].test[ti].react[0] = MON_REACT_BREAK;
               curReact = MON_REACT_BREAK;
            }
         }

         //── TP2/TP3 progression after BOUNCE ─────────────────────
         if(curReact == MON_REACT_BOUNCE)
         {
            if(nTP >= 2 && !g_mon[ai].test[ti].tpHit[1])
               if(isBuy ? (hi0 >= tp2) : (lo0 <= tp2))
                  g_mon[ai].test[ti].tpHit[1] = true;
            if(nTP >= 3 && !g_mon[ai].test[ti].tpHit[2])
               if(isBuy ? (hi0 >= tp3) : (lo0 <= tp3))
                  g_mon[ai].test[ti].tpHit[2] = true;
         }
      }
   }
   s_prevBars = curBars;
}

//══════════════════════════════════════════════════════════════════
//  Mon_OnInit / Mon_OnDeinit
//══════════════════════════════════════════════════════════════════
void Mon_OnInit()
{
   g_monCount = 0;
   // MT4 zero-initializes static struct arrays; valid=false for all
}

void Mon_OnDeinit(const int reason)
{
   g_monCount = 0;
}
