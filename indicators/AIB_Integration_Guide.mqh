/*
=================================================================
  AIB_Integration_Guide.mqh
  Exact changes to add to AIB_Angles_V535__v2.mq4
=================================================================

1) INCLUDES — add these 3 lines at the VERY END of the file
   (after line 5416, i.e. after the closing brace of SCCMW_TM_Init):

     #include "AIB_ComboTable.mqh"
     #include "AIB_Monitor.mqh"
     #include "AIB_Signal.mqh"


2) OnInit() — add Mon_OnInit() before return (around line 3848):

   BEFORE:
     if(g_quickPanelVisible) CreateQuickPanel();
     return(INIT_SUCCEEDED);

   AFTER:
     if(g_quickPanelVisible) CreateQuickPanel();
     Mon_OnInit();                    // ← add this
     return(INIT_SUCCEEDED);


3) OnDeinit() — add two calls (around line 3852):

   BEFORE:
     void OnDeinit(const int reason)
     {
       if(reason == REASON_REMOVE)
         DeleteAllIndicatorObjects();
       else if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
         DeleteComputedObjects();
     }

   AFTER:
     void OnDeinit(const int reason)
     {
       Mon_OnDeinit(reason);          // ← add FIRST
       Sig_OnDeinit();                // ← add SECOND
       if(reason == REASON_REMOVE)
         DeleteAllIndicatorObjects();
       else if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
         DeleteComputedObjects();
     }


4) OnCalculate() — add two calls at the END of the function,
   just before the final  return(rates_total);

     Mon_OnTick();                    // ← add this
     Sig_OnCalculate();               // ← add this
     return(rates_total);


5) SaveAngleResult() — add Mon hook at the END (around line 3171):

   BEFORE:
     g_angleCache[n] = r;
     g_angleCacheCount = n + 1;
   }

   AFTER:
     g_angleCache[n] = r;
     g_angleCacheCount = n + 1;
     Mon_OnAngleSaved(r);             // ← add this (capture for monitoring)
   }

   Also add the same call in the CACHE UPDATE branch (when record is found):
   BEFORE:
     g_angleCache[i] = r;
     return;

   AFTER:
     g_angleCache[i] = r;
     Mon_OnAngleSaved(r);             // ← add this too
     return;


=================================================================
  File placement (all in same MT4 MQL4/Indicators folder):
    AIB_Angles_V535__v2.mq4     ← main indicator (already there)
    AIB_ComboTable.mqh          ← generated combo lookup table
    AIB_Monitor.mqh             ← monitoring layer (already exists)
    AIB_Signal.mqh              ← trade zone drawing (NEW)
=================================================================

  Notes:
  • TP2%* and TP3%* on labels: the asterisk means conditional on TP1 hit
  • InpSigSpreadPts: broker spread in points (20 = 2 pips for 5-digit)
  • InpSigTP1Pct + InpSigTP2Pct + InpSigTP3Pct should sum to 100
  • InpSigFilterBest: shows only combos with n_ang≥30 AND p_total≥40%
  • Alert fires once per touch. Multi-test alert fires when ≥2 tests active.
  • Rectangle width = g_unitSeconds (86400 for daily units)
  • For historical replay: signals drawn automatically from g_mon[] data
=================================================================
*/
