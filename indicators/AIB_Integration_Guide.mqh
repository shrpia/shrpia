/*
=================================================================
  AIB_Integration_Guide.mqh
  Exact changes to add to AIB_Angles_V535__v2.mq4
=================================================================

1) INCLUDES — add at the VERY END of the file (after SCCMW_TM_Init):

     #include "AIB_ComboTable.mqh"
     #include "AIB_Monitor.mqh"
     #include "AIB_Signal.mqh"


2) OnInit() — add Mon_OnInit() before return:

   BEFORE:
     if(g_quickPanelVisible) CreateQuickPanel();
     return(INIT_SUCCEEDED);

   AFTER:
     if(g_quickPanelVisible) CreateQuickPanel();
     Mon_OnInit();
     return(INIT_SUCCEEDED);


3) OnDeinit() — add two calls at top:

   BEFORE:
     void OnDeinit(const int reason)
     {
       if(reason == REASON_REMOVE)

   AFTER:
     void OnDeinit(const int reason)
     {
       Mon_OnDeinit(reason);
       Sig_OnDeinit();
       if(reason == REASON_REMOVE)


4) OnCalculate() — add two calls before the final return(rates_total):

     Mon_OnTick();
     Sig_OnCalculate();
     return(rates_total);


5) SaveAngleResult() — add Mon hook at END of both branches:

   UPDATE branch:
     g_angleCache[i] = r;
     Mon_OnAngleSaved(r);     // ← add
     return;

   NEW ENTRY branch:
     g_angleCache[n] = r;
     g_angleCacheCount = n + 1;
     Mon_OnAngleSaved(r);     // ← add
   }


6) OnChartEvent() — add Sig hook as FIRST line inside the function:

   BEFORE:
     void OnChartEvent(const int id,
                       const long &lparam,
                       const double &dparam,
                       const string &sparam)
     {
       if(id == CHARTEVENT_MOUSE_MOVE)

   AFTER:
     void OnChartEvent(const int id,
                       const long &lparam,
                       const double &dparam,
                       const string &sparam)
     {
       Sig_OnChartEvent(id, lparam, dparam, sparam);   // AIB Signal hook
       if(id == CHARTEVENT_MOUSE_MOVE)


=================================================================
  File placement (all in same MT4 MQL4/Indicators folder):
    AIB_Angles_V535__v2.mq4     ← main indicator (already there)
    AIB_ComboTable.mqh          ← auto-generated combo lookup table
    AIB_Monitor.mqh             ← monitoring layer
    AIB_Signal.mqh              ← trade zone drawing (v2.0)
=================================================================

  v2.0 new features:
  • InpSigMinHitPct (default 50%) — zones below threshold suppressed;
    warning shown in panel instead
  • Anticipatory preview (dashed gold) drawn at formTime;
    replaced by real zone when price actually touches
  • Anti-overlap: same-angle tests staggered by ti×unit/5 in time
  • Duration scaled by g_unitSeconds/86400 (studies on U86400)
  • Rating stars: *** ≥65%  ** ≥50%  ~ ≥35%  x <35%
  • Professional signal panel (top-right, screen-anchored):
      - Header: active count + weak count
      - Per signal: rating, code, dir, test, status, hit%, n
      - Weak signals: grayed row (no zone drawn)
      - Mode indicator line when pick mode is active
  • 4 buttons:
      [Hide All]   — toggle hide all zones
      [Show All]   — reveal all zones (clears individual hides too)
      [Hide Zone]  — click button then click on a zone to hide it
      [Pick Angle] — click button then click chart to isolate that angle

  TP2%* and TP3%* labels: asterisk = conditional on TP1 hit
  InpSigSpreadPts: broker spread in points (20 = 2 pips for 5-digit)
  InpSigTP1Pct + InpSigTP2Pct + InpSigTP3Pct should sum to 100
  InpSigFilterBest: also require n_ang≥30 AND p_total≥40%
=================================================================
*/
