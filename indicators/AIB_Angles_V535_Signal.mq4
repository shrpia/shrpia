//+------------------------------------------------------------------+
//|  AIB_Angles_TrueAngles_G3_v10_TFfix.mq4                         |
//|  MT4 - True Angles by Fixed Units (Chart Window)                 |
//|                                                                  |
//|  v10 – TF Isolation Fix (base: v09_smart_renderer_persistent)    |
//|  ─────────────────────────────────────────────────────────────── |
//|  ROOT CAUSE OF THE BUG:                                          |
//|  All object names contained Symbol()+Period() but PREFIX was     |
//|  still "AIBANG_" for all TFs. So DeleteAllIndicatorObjects()     |
//|  deleted every AIBANG_* object regardless of TF. LoadAngles      |
//|  FromChart() also searched by partial prefix, risking cross-TF   |
//|  contamination.                                                   |
//|                                                                  |
//|  FIX: g_tfPrefix = "AIBANG_{Symbol}_{Period}_{UnitSec}_"         |
//|  - All angle/unit objects use g_tfPrefix (TF+unit isolated)      |
//|  - Delete functions use g_tfPrefix → never touch other combos    |
//|  - LoadAnglesFromChart searches g_tfPrefix+"ANG_" only           |
//|  - InitTFPrefix() called in OnInit + on every TF/unit change     |
//|  - UI buttons/clones/rects keep plain PREFIX (TF-independent)    |
//|  - HideObjectsOfOtherTFs uses prefix-only match (no token parse) |
//|  - DeleteAllIndicatorObjects cleans ALL AIBANG_ on removal       |
//|  All original logic, ZA–ZH, smart renderer, persistence kept.    |
//+------------------------------------------------------------------+
#property strict
// v47: stronger supervisor classification + wider visible-range scan budget + preserved legacy geometry
#property indicator_chart_window
#property indicator_plots 0
#define OBJ_PREFIX "AIB_"

// Some MT4 builds require explicitly enabling chart object events.
#ifndef CHART_EVENT_OBJECT_CLICK
#define CHART_EVENT_OBJECT_CLICK 1
#endif
#ifndef CHART_EVENT_OBJECT_CREATE
#define CHART_EVENT_OBJECT_CREATE 2
#endif
#ifndef CHART_EVENT_OBJECT_DELETE
#define CHART_EVENT_OBJECT_DELETE 3
#endif
#ifndef CHART_EVENT_OBJECT_CHANGE
#define CHART_EVENT_OBJECT_CHANGE 4
#endif
#ifndef CHART_EVENT_OBJECT_DRAG
#define CHART_EVENT_OBJECT_DRAG 5
#endif
#ifndef CHART_EVENT_MOUSE_MOVE
#define CHART_EVENT_MOUSE_MOVE 6
#endif

// Compatibility: some older MT4 builds may miss this constant.
#ifndef CHARTEVENT_OBJECT_DBLCLICK
  #define CHARTEVENT_OBJECT_DBLCLICK 17
#endif

//-------------------- Inputs --------------------
input bool   InpEnableOnStart        = true;      // Enable on start
input bool   InpDynamicVisible       = true;      // Draw only visible range
input int    InpUnitsToShow          = 60;        // If not dynamic: completed units to scan
input int    InpMinRangePoints       = 30;        // Min impulse range (points)

// Correction limits (as ratio of Unit2 range) - applies to both BUY and SELL angles
// Example: 0.292 = 29.20% , 0.618 = 61.80%
input double InpCorrMin            = 0.292;  // Min correction
input double InpCorrMax            = 0.618;  // Max correction

// Break search: correction must happen first, then break
input int    InpBreakLookAheadUnits  = 1;         // Allow break in Unit2 and next N units (0=only Unit2)

// Draw unconfirmed angles
input bool   InpDrawUnconfirmed      = false;     // Draw angles without break yet
input bool   InpShowUnitVerticalLines = false;    // Show diagnostic vertical unit lines
input bool   InpColorUnitLinesByAngleState = true; // Color unit lines by visible angle state
input bool   InpShowUnconfirmedAngles = true;      // Render unconfirmed/candidate angles
input bool   InpShowAngleVerticalLegs = true;    // Draw vertical legs for angle results
input bool   InpShowVerticalLegsForUnconfirmed = true; // Draw vertical legs for unconfirmed angles

// Appearance (directional)
// Positive move (BUY / upward impulse): unit lines = Yellow, angle lines = White (defaults)
// Negative move (SELL / downward impulse): unit lines = White, angle lines = Yellow (defaults)
input color  InpUnitLineColorUp      = clrYellow; // Unit lines color when move is UP (BUY)
input color  InpUnitLineColorDown    = clrWhite;  // Unit lines color when move is DOWN (SELL)
input color  InpAngleLineColorUp     = clrWhite;  // Angle line color when move is UP (BUY)
input color  InpAngleLineColorDown   = clrYellow; // Angle line color when move is DOWN (SELL)

// Line thickness (requested default = 3)
input int    InpUnitLineWidth        = 3;         // Unit line width
input int    InpAngleLineWidth       = 3;         // Angle line width

input bool   InpRangeRectFilled     = true;      // Range 23.60 rectangle filled
input color  InpRangeRectColor      = clrMagenta; // Range rectangle color
input int    InpRangeRectBorder     = 1;          // Range rectangle border width

// Text toggles (DEFAULT: only classification ON)
input bool   InpShowAngleText        = false;     // Show BUY/SELL text
input bool   InpShowCorrectionText   = false;     // Show correction % text
input color  InpAngleTextColor       = clrOrange; // Angle text color
input color  InpCorrectionTextColor  = clrOrange; // Correction text color
input color  InpClassTextColor       = clrWhite;  // Classification text color
input int    InpTextFontSize         = 12;        // Text size
input int    InpLabelYOffsetPoints   = 10;        // Label offset \(points\)
// --- Classification text (NEW) ---
input bool   InpShowClassText       = true;     // Show classification (ZA/ZB/ZC)
input int    InpClassFontSize       = 16;       // Classification font size
input int    InpClassYOffsetPoints  = 18;       // Classification offset (points)

// --- Button sizing (NEW) ---
input int    InpBtnXDistance        = 240;      // Panel X distance from right edge
input int    InpBtnYBase            = 20;       // Panel Y base
input int    InpBtnWidth            = 135;      // Panel button width      // Panel button width
input int    InpBtnHeight           = 26;       // Panel button height       // Panel button height
input int    InpBtnGap              = 6;        // Panel vertical gap
input int    InpBtnFontSize         = 11;       // Panel font size       // Panel font size
input bool   InpUIScaleAuto         = true;     // Auto scale UI for different screens (recommended)
input double InpUIScaleManual       = 1.0;      // Manual UI scale when Auto is false
input double InpUIScaleMin          = 0.75;     // Auto scale lower bound
input double InpUIScaleMax          = 1.60;     // Auto scale upper bound


// --- Quick Text toggle button colors (NEW) ---
input color  InpBtnBg               = clrTeal;   // Toggle button background color
input color  InpBtnFg               = clrWhite;  // Toggle button text color

// --- ZB/ZC close-away filter (NEW) ---
input int    InpCloseAwayPoints     = 10;       // Min distance (points) for "away" close in ZB
input int    InpTouchTolerancePoints= 2;        // Tolerance (points) for touch/retest checks

// --- ZE extension classification (NEW) ---
input double InpZEExtensionRatio    = 1.618;    // ZE target = U2 range * this ratio beyond U2 boundary
input double InpZEMinPullbackRatio  = 0.050;    // Minimum pullback inside U1 as fraction of U2 range

// Clone settings
input bool   InpCloneUseSourceColor  = true;      // Clone uses same color as the source line (recommended)
input color  InpCloneAngleColor      = clrWhite;  // Clone color for angle lines
input color  InpCloneUnitColor       = clrYellow; // Clone color for unit lines
input int    InpCloneOffsetPips      = 10;        // Default clone offset (pips)
input int    InpCloneOffsetBars      = 4;         // Default clone offset (bars, time)
input int    InpDoubleClickMs        = 700;       // Double-click window (ms)

// Rectangle settings
input bool   InpRectFilled           = true;      // Rectangle filled
input int    InpRectOpacity          = 30;        // 0..255 (lower=more transparent)
input color  InpRectColor            = clrGold;   // Rectangle border/fill base color

//-------------------- SCCMW-compatible unit logic (NEW, keeps all old features) --------------------
// When enabled, the indicator builds unit boundaries like SCCMW TimeManager for H4/D1/W1/MN1
// (broker calendar based on higher timeframe bars), avoiding epoch/seconds drift.
input bool   InpUseSCCMWUnitLogic     = true;      // Use SCCMW unit logic (H4+)
input int    InpSCCMW_H4_Mode         = 1;         // H4 units: 1=W (default), 2=W2
input int    InpSCCMW_D1_Mode         = 1;         // D1 units: 1=MN,2=MN2,3=MN3,4=MN4
input int    InpSCCMW_MN1_Mode        = 12;        // MN1 units (months): 12=Y,24=Y2,60=Y5,120=Y10

// UI: show angle name under correction % text
input bool   InpShowAngleNameUnderCorrection = true; // Show ZA/ZB/ZC under correction text
input color  InpAngleNameTextColor           = clrAqua; // Angle name color
input int    InpAngleNameYOffsetPoints       = 14;      // Y offset (points)

//-------------------- Auto follow SCCMW panel unit (optional) --------------------
// MT4 can't read another indicator's inputs directly. If SCCMW writes "Unit: 15m" on chart
// as a label/text object, this option can auto-sync g_unitSeconds to it.
input bool   InpAutoFollowSCCMWPanel   = true;     // Auto sync unit from SCCMW panel text
input string InpSCCMWUnitObjectName    = "";       // Optional: exact object name that contains "Unit:" text
input int    InpAutoFollowCheckMs      = 600;      // Throttle (ms)

//-------------------- Quick Text Panel --------------------
input bool   InpShowQuickTextPanel     = true;   // Show quick text panel (letters/numbers)
input bool   InpShowQuickTextToggleBtn = true;   // Show TXT toggle button
input int    InpQuickTextCorner        = CORNER_LEFT_UPPER; // Panel corner
input int    InpQuickTextX             = 8;      // Panel X distance
input int    InpQuickTextY             = 8;      // Panel Y distance
input int    InpQuickTextBtnW          = 42;     // Base item width     // Base item width     // Button width
input int    InpQuickTextBtnH          = 18;     // Button height
input int    InpQuickTextGapX          = 16;     // Gap X     // Gap X      // Gap X
input int    InpQuickTextGapY          = 8;      // Gap Y      // Gap Y
input int    InpQuickTextPadX          = 8;      // Extra padding inside item width
input bool   InpQuickTextNoWrap        = true;   // Keep single row (no wrap)
input string InpQuickTextFont          = "Arial"; // Panel font
input int    InpQuickTextFontSize      = 14;     // Panel font size     // Panel font size     // Panel font size
input color  InpQuickTextColorLetters  = clrAqua;   // Panel: letters color (a,b,c,A,B,C,X,E,D,Y,...)
input color  InpQuickTextColorRoman    = clrDeepSkyBlue; // Panel: roman numerals color (i,ii,iii,...)
input color  InpQuickTextColorDigits   = clrLime;   // Panel: digits color (1..13)
input color  InpQuickTextColorZLabels  = clrAqua;   // Panel: Z-labels color (ZA..ZZ)
input color  InpQuickTextColorRS       = clrYellow; // Panel: R/S labels color (R0..R3, S0..S3)

input color  InpQuickTextBgColor       = clrNONE;   // Panel background (unused for labels)

// Classification dynamic spacing (prevents overlaps with angle/unit lines across zoom levels)
input bool   InpClassDynamicOffset     = true;   // Dynamic class label offset (recommended)
input double InpClassDynFracBuy        = 0.010;  // BUY: fraction of visible price span
input double InpClassDynFracSell       = 0.016;  // SELL: fraction of visible price span (usually larger)
input int    InpClassSellExtraGapPoints = 12;     // SELL: extra gap above angle line (points)

input string InpCloneTextFont          = "Arial"; // Cloned text font
input int    InpCloneTextFontSize      = 14;      // Cloned text size
input color  InpCloneTextColor         = clrAqua; // Cloned text color
input bool   InpCloneTextAtMouse       = true;   // Place clone at mouse position
input int    InpCloneTextYOffsetPoints = 0;      // Extra Y offset (points) for cloned text
input int    InpCloneUnderPanelPips    = 5;      // When clicking panel items: place clone this many pips below the item

// Reference helper lines
input int    InpRefLineWidth          = 3;      // Helper reference lines width
input int    InpRefLineSpacingPips    = 12;     // Vertical spacing between helper lines
input int    InpRefCloneOffsetPips    = 6;      // Clone offset below helper lines
input int    InpRefAnchorCorner       = CORNER_LEFT_LOWER; // Helper lines screen corner
input int    InpRefAnchorX            = 18;     // Helper lines X distance from corner
input int    InpRefAnchorY            = 48;     // Helper lines Y distance from corner
input int    InpRefLinePixelLength    = 170;    // Helper lines visible screen length in pixels

//-------------------- Unit selection UI --------------------
// Dropdown-like: a "UNIT" button toggles a list of option buttons.

//-------------------- Globals --------------------

// Quick text panel state
bool g_quickPanelVisible = true;
int  g_qtFontSizeAct = 16;
int  g_qtBtnHAct = 18;
int  g_qtBtnWMinAct = 34;
int  g_qtPadXAct = 8;
int  g_qtGapXAct = 10;
int  g_qtGapYAct = 2;
int  g_mouseX = 0;
int  g_mouseY = 0;

#define BTN_TXT       "AIB_TXT_TOGGLE"
#define QT_PREFIX     "AIB_QT_"
#define REF_PREFIX    "AIB_REF_"
#define NOTE_PREFIX   "AIB_NOTE_"
#define HOVER_TIP_NAME "AIB_HOVER_TIP"
// v10 TF FIX: PREFIX is now static base. All angle/unit objects use g_tfPrefix (TF-aware).
// UI buttons, clones, rects use plain PREFIX (TF-independent, shared across TFs on same chart).
string PREFIX       = "AIBANG_";
string g_tfPrefix   = "AIBANG_";   // set in OnInit + on TF change via InitTFPrefix()
string BTN_ANG      = "AIBANG_BTN";
string BTN_UNIT     = "AIBANG_UNIT";
string BTN_RANGE    = "AIBANG_RANGE236";
string BTN_COPY     = "AIBANG_COPY";
string BTN_REFL     = "AIBANG_REFL";
string BTN_CLS      = "AIBANG_CLS";    // runtime toggle: show/hide classification labels
string BTN_OPT_PRE  = "AIBANG_OPT_";

// Called in OnInit and whenever TF or unit changes.
// Result example: "AIBANG_GBPUSD_60_3600_"  (symbol + period + unitSeconds = fully unique per TF+unit combo)
void InitTFPrefix()
{
  g_tfPrefix = StringFormat("AIBANG_%s_%d_%d_", Symbol(), Period(), g_unitSeconds);
}

string PREFS_GV     = "AIBANG_enabled";
bool   g_enabled    = true;
bool   g_rangeEnabled = false;    // Toggle: allow drawing 0..23.6 rect by double-click in zone
bool   g_copyEnabled  = true;     // Toggle: allow cloning lines by double-click
bool   g_refLinesActive = false;  // helper 3-line tool active
bool   g_showClassText  = true;   // runtime toggle: show/hide classification labels (ZA/ZB/…)
int    g_lastHoverU1Id  = -999;  // u1Id of angle whose leg is currently hovered (-999 = none)
uint   g_lastHoverMs    = 0;     // throttle: last time hover check ran
int    g_refAnchorFontDummy = 0;
datetime g_lastBarTime = 0;
datetime g_lastUnitAnchor = 0;
datetime g_lastVisibleLeft = 0;
datetime g_lastVisibleRight = 0;

// lightweight redraw throttling (avoids heavy redraw on every mouse move)
uint   g_lastEvtDrawMs = 0;
bool   g_needRedraw    = false;

// SCCMW panel unit sync throttle
uint   g_lastUnitSyncMs = 0;

// SCCMW-like TimeManager state
bool   g_tmInited = false;
bool   g_tmHasSunday = false;
bool   g_tmStartAfterHour = false;
datetime g_tmSessionFrom = 0;
datetime g_tmSessionTo = 0;

// double click tracking
string g_lastClickObj = "";
int    g_lastClickMs  = 0;
int    g_dblMs        = 700;

// chart click double-click tracking (more robust than matching exact x/y)
int    g_lastChartClickMs = 0;
int    g_lastChartClickX  = -100000;
int    g_lastChartClickY  = -100000;
// unit selection
int    g_unitSeconds = 3600; // default 1h
bool   g_optsVisible = false;

// clone bookkeeping
int    g_cloneCounter = 0;

//-------------------- Helpers --------------------
double PipValue()
{
  if(Digits == 3 || Digits == 5) return(10.0 * Point);
  return(Point);
}

int NowMs()
{
  // GetTickCount exists in MT4
  return((int)GetTickCount());
}

bool IsDoubleClick(string key)
{
   int t = NowMs();
   if(key == g_lastClickObj && (t - g_lastClickMs) <= g_dblMs)
   {
      g_lastClickObj = "";
      g_lastClickMs  = 0;
      return(true);
   }
   g_lastClickObj = key;
   g_lastClickMs  = t;
   return(false);
}

bool IsDoubleClickXY(int x, int y, int tol)
{
   static int lastX = -99999, lastY = -99999, lastT = 0;
   int t = NowMs();
   if(MathAbs(x - lastX) <= tol && MathAbs(y - lastY) <= tol && (t - lastT) <= g_dblMs)
   {
      lastX = -99999; lastY = -99999; lastT = 0;
      return(true);
   }
   lastX = x; lastY = y; lastT = t;
   return(false);
}


bool LoadEnabled()
{
  if(!GlobalVariableCheck(PREFS_GV))
    return(InpEnableOnStart);
  return(GlobalVariableGet(PREFS_GV) > 0.5);
}

void SaveEnabled(bool v)
{
  GlobalVariableSet(PREFS_GV, v ? 1.0 : 0.0);
}

// Delete objects by prefix (but keep clones)
void ObjDelByPrefix(string pre)
{
  // v10 TF FIX: only operates on objects starting with pre (caller must pass g_tfPrefix).
  // Never deletes UI controls, clones, rects, ref lines.
  int total = ObjectsTotal(0,0,-1);
  for(int i=total-1; i>=0; i--)
  {
    string n = ObjectName(0, i);
    if(StringFind(n, pre) == 0)
    {
      if(n==BTN_ANG || n==BTN_UNIT || n==BTN_COPY || n==BTN_RANGE || n==BTN_TXT || n==BTN_REFL) continue;
      if(StringFind(n, BTN_OPT_PRE) == 0) continue;
      if(StringFind(n, QT_PREFIX)  == 0) continue;
      if(StringFind(n, PREFIX+"CLONE_") == 0) continue;
      if(StringFind(n, PREFIX+"RECT_")  == 0) continue;
      if(StringFind(n, REF_PREFIX) == 0) continue;
      ObjectDelete(0, n);
    }
  }
}

void DeleteObjectsByPrefixRaw(string pre)
{
  int total = ObjectsTotal(0,0,-1);
  for(int i=total-1; i>=0; i--)
  {
    string n = ObjectName(0, i);
    if(StringFind(n, pre) == 0)
      ObjectDelete(0, n);
  }
}

void DeleteAllIndicatorObjects()
{
  // On full removal: wipe ALL indicator objects across every TF+unit combo.
  DeleteObjectsByPrefixRaw("AIBANG_");   // angle objects, buttons, clones, rects, status
  DeleteObjectsByPrefixRaw(QT_PREFIX);   // "AIB_QT_"  quick text panel
  DeleteObjectsByPrefixRaw(REF_PREFIX);  // "AIB_REF_" reference lines
  DeleteObjectsByPrefixRaw(NOTE_PREFIX); // "AIB_NOTE_" text clone notes (were not deleted before)
  DeleteObjectsByPrefixRaw(BTN_TXT);     // "AIB_TXT_TOGGLE" text toggle button
  ObjectDelete(0, HOVER_TIP_NAME);       // hover tooltip label
  Comment("");
}


//-------------------- Drawing primitives --------------------
void DrawVSegment(string name, datetime t, double y1, double y2, color c, int w, bool lock)
{
  if(ObjectFind(0, name) < 0)
  {
    ObjectCreate(0, name, OBJ_TREND, 0, t, y1, t, y2);
    // v10 TF FIX: new objects are visible on ALL periods initially,
    // but we immediately restrict to current TF only.
    ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  }
  ObjectSetInteger(0, name, OBJPROP_RAY, false);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, w);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, lock ? false : true);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, lock ? true : false);
  ObjectSetInteger(0, name, OBJPROP_READONLY, lock ? true : false);
}

void DrawAngleLine(string name, datetime t1, double p1, datetime t2, double p2, color c, int w, bool lock)
{
  bool isNew = (ObjectFind(0, name) < 0);
  if(isNew)
    ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
  ObjectSetInteger(0, name, OBJPROP_RAY, false);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, w);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, lock ? false : true);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, lock ? true : false);
  ObjectSetInteger(0, name, OBJPROP_READONLY, lock ? true : false);
}

void DrawText(string name, datetime t, double p, string txt, color c)
{
  if(ObjectFind(0, name) < 0)
    ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpTextFontSize);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void DrawTextSized(string name, datetime t, double p, string txt, color c, int fsize)
{
  if(ObjectFind(0, name) < 0)
    ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fsize);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}


color ColorWithAlpha(color base, int alpha)
{
  int r = (base & 0xFF);
  int g = ((base >> 8) & 0xFF);
  int b = ((base >> 16) & 0xFF);
  // In MT4, colors are 0x00BBGGRR. Alpha not supported directly.
  // We'll approximate by using base color; fill transparency is controlled by OBJPROP_BACK and style.
  return((color)(r | (g<<8) | (b<<16)));
}

void DrawLockedRect(string name, datetime t1, double p1, datetime t2, double p2)
{
  if(ObjectFind(0, name) < 0)
    ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
  ObjectSetInteger(0, name, OBJPROP_COLOR, InpRectColor);
  ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
  ObjectSetInteger(0, name, OBJPROP_BACK, true);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
  ObjectSetInteger(0, name, OBJPROP_READONLY, false);
  // store original bounds to lock size
  string meta = StringFormat("RECTLOCK|%d|%.10f|%d|%.10f", (int)t1, p1, (int)t2, p2);
  ObjectSetString(0, name, OBJPROP_TOOLTIP, meta);
}

//-------------------- Unit building --------------------
struct UnitInfo
{
  datetime start;
  datetime end;
  double   hi;
  double   lo;
  datetime hiTime;
  datetime loTime;
  double   firstOpen;
  double   lastClose;
  double   level0;
  double   level23;
  double   level38;
  double   level61;
  double   level76;
  double   level100;
  double   levelNeg61;
  double   level161;
  int      shiftStart;
  int      shiftEnd;
  int      id;
  bool     processedSequentially;
  bool     valid;
};

struct UnitBoundary
{
  datetime startTime;
  datetime endTime;
};

// Cached units: built once on first load / timeframe-or-unit change / new unit close.
// Dynamic panning should only change the visible scan window, not rebuild units from scratch.
UnitInfo g_unitCache[];
int      g_unitCacheCount = 0;

struct AngleResult
{
  bool      valid;

  bool      confirmed;
  bool      unconfirmed;

  bool      candidateBuy;
  bool      candidateSell;

  string    angleName;
  string    angleDisplayText;
  string    classText;

  int       dirState; // 1 bullish, -1 bearish
  int       u1Id;
  int       u2Id;

  datetime  u1Start;
  datetime  u2Start;
  datetime  u1End;
  datetime  u2End;

  double    u1High;
  double    u1Low;
  double    u2High;
  double    u2Low;

  double    correctionPct;
  double    correctionValue;

  color     u1LegColor;
  color     u2LegColor;

  datetime  drawT1;
  double    drawP1;
  datetime  drawT2;
  double    drawP2;
};

AngleResult g_angleCache[];
int         g_angleCacheCount = 0;
int         g_lastProcessedUnitId = -1;
bool        g_scaleInitialized = false;
bool        g_scaleReleasedByUser = false;
datetime    g_cacheLeftTime = 0;
datetime    g_cacheRightTime = 0;
bool        g_chartAnglesLoaded = false;
datetime    g_lastProcessedBarPersistent = 0;
bool        g_unitStateBullish[];
bool        g_unitStateBearish[];
bool        g_unitStateBullishCand[];
bool        g_unitStateBearishCand[];

struct DirectionCheckResult
{
  int state; // 1=BULLISH, -1=BEARISH, 0=NONE
};

struct RangeCheckResult
{
  int state; // buy:1=B-ALPHA 2=B-BETA ; sell:1=S-ALPHA 2=S-BETA ; 0=NONE
};

struct OrderCheckResult
{
  int state; // buy:1=K1 2=R1 ; sell:1=SK1 2=SR1 ; 0=NONE
};

struct CloseCheckResult
{
  int state; // 1=ABOVE, 0=IN, -1=BELOW, 99=NONE
};

struct RetestCheckResult
{
  bool state;
};

struct ExtensionCheckResult
{
  bool reached161;
  bool reachedNeg61;
};

struct SupervisorFacts
{
  DirectionCheckResult dir;
  RangeCheckResult range;
  OrderCheckResult order;
  CloseCheckResult close;
  RetestCheckResult retest;
  ExtensionCheckResult ext;
};


color GetUnitLegColor(const UnitInfo &u)
{
  if(u.lastClose >= u.firstOpen)
    return InpAngleLineColorUp;
  return InpAngleLineColorDown;
}

double CalcCorrectionPercent(UnitInfo &refU, UnitInfo &formU, const DirectionCheckResult &dir)
{
  double span = MathAbs(refU.hi - refU.lo);
  if(span <= 0.0) return(0.0);

  if(dir.state == 1)
    return(100.0 * (formU.lo - refU.lo) / span);

  if(dir.state == -1)
    return(100.0 * (refU.hi - formU.hi) / span);

  return(0.0);
}

int GetExtensionState(const ExtensionCheckResult &ext, int dirState)
{
  if(dirState == 1 && ext.reached161) return(1);
  if(dirState == -1 && ext.reachedNeg61) return(-1);
  return(0);
}

bool IsAngleConfirmedModern(const SupervisorFacts &sf, const string cls)
{
  if(cls == "") return(false);
  if(sf.dir.state == 0 || sf.range.state == 0 || sf.order.state == 0 || sf.close.state == 99) return(false);
  int extState = GetExtensionState(sf.ext, sf.dir.state);

  if(sf.range.state == 1)
  {
    if(cls == "ZA")
      return((!sf.retest.state) && ((sf.dir.state == 1 && sf.close.state == 1) || (sf.dir.state == -1 && sf.close.state == -1)));
    if(cls == "ZB")
      return(sf.retest.state && ((sf.dir.state == 1 && sf.close.state == 1) || (sf.dir.state == -1 && sf.close.state == -1)));
    if(cls == "ZC")
      return(sf.retest.state && sf.close.state == 0);
    if(cls == "ZD")
      return((sf.dir.state == 1 && sf.close.state == 1) || (sf.dir.state == -1 && sf.close.state == -1));
    if(cls == "ZE")
      return(sf.close.state == 0);
  }

  if(sf.range.state == 2)
  {
    if(cls == "ZF") return((extState == sf.dir.state) && ((sf.dir.state == 1 && sf.close.state == 1) || (sf.dir.state == -1 && sf.close.state == -1)));
    if(cls == "ZG") return((extState == sf.dir.state) && sf.close.state == 0);
    if(cls == "ZO") return((extState == sf.dir.state) && sf.close.state == 0);
    if(cls == "ZH") return((extState == sf.dir.state) && ((sf.dir.state == 1 && sf.close.state == 1) || (sf.dir.state == -1 && sf.close.state == -1)));
  }

  return(false);
}

bool IsAngleUnconfirmedModern(const SupervisorFacts &sf, const string cls)
{
  if(cls == "") return(false);
  if(IsAngleConfirmedModern(sf, cls)) return(false);
  if(sf.dir.state == 0 || sf.range.state == 0 || sf.order.state == 0) return(false);
  return(true);
}

bool IsModernCandidate(const SupervisorFacts &sf, bool &candBuy, bool &candSell)
{
  candBuy = false;
  candSell = false;

  if(sf.dir.state == 0) return(false);
  if(sf.range.state == 0) return(false);

  if(sf.dir.state == 1) candBuy = true;
  else if(sf.dir.state == -1) candSell = true;

  return(candBuy || candSell);
}

// Safe shift helpers for time ranges (handles weekend gaps and boundaries)
// Time[] series: Time(0) newest, increasing shift = older bar
int ShiftAtOrAfter(datetime t)
{
  // returns shift of the FIRST bar whose open time is >= t (i.e., at/after boundary)
  int s = iBarShift(Symbol(), Period(), t, false); // bar at/before t
  if(s < 0) return(-1);
  // if this bar is still before the boundary (gap case), walk to newer bars
  while(s > 0 && iTime(Symbol(), Period(), s) < t) s--;
  return(s);
}
int ShiftBefore(datetime t)
{
  // returns shift of the LAST bar whose open time is < t (end is exclusive)
  int s = iBarShift(Symbol(), Period(), t, false); // bar at/before t
  if(s < 0) return(-1);
  if(iTime(Symbol(), Period(), s) == t) s++;       // exclude exact boundary bar
  return(s);
}

// Backward-compatible helper used by some scan routines
int FindShiftByTime(datetime t)
{
  int s = iBarShift(Symbol(), Period(), t, false);
  return(s);
}

bool BuildUnit(datetime start, datetime end, UnitInfo &u)
{
  u.start = start;
  u.end   = end;
  u.valid = false;
  u.hiTime = 0;
  u.loTime = 0;
  u.firstOpen = 0.0;
  u.lastClose = 0.0;
  u.level0 = 0.0;
  u.level23 = 0.0;
  u.level38 = 0.0;
  u.level61 = 0.0;
  u.level76 = 0.0;
  u.level100 = 0.0;
  u.levelNeg61 = 0.0;
  u.level161 = 0.0;
  u.id = 0;
  u.processedSequentially = false;

  // start < end (older -> newer). We include bars with time in [start, end)
  int shOldest = ShiftAtOrAfter(start);  // closest bar at/after start (oldest included)
  int shNewest = ShiftBefore(end);       // closest bar strictly before end (newest included)
  if(shOldest < 0 || shNewest < 0) return(false);

  // If range is empty (e.g., no bars between boundaries), reject
  if(shOldest < shNewest) return(false);

  double hi = -1e100, lo = 1e100;
  for(int s=shNewest; s<=shOldest; s++)
  {
    datetime bt = iTime(Symbol(), Period(), s);
    if(bt < start || bt >= end) continue; // strict membership
    double h = iHigh(Symbol(), Period(), s);
    double l = iLow(Symbol(), Period(), s);
    if(h > hi) { hi = h; u.hiTime = bt; }
    if(l < lo) { lo = l; u.loTime = bt; }
  }
  if(hi <= -1e90 || lo >= 1e90) return(false);

  u.hi = hi;
  u.lo = lo;
  u.firstOpen = iOpen(Symbol(), Period(), shOldest);
  u.lastClose = iClose(Symbol(), Period(), shNewest);
  double R = u.hi - u.lo;
  u.level0   = u.lo;
  u.level23  = u.lo + 0.236 * R;
  u.level38  = u.lo + 0.382 * R;
  u.level61  = u.lo + 0.618 * R;
  u.level76  = u.lo + 0.764 * R;
  u.level100 = u.hi;
  u.levelNeg61 = u.lo - 0.618 * R;
  u.level161 = u.lo + 1.618 * R;
  u.shiftStart = shOldest;
  u.shiftEnd   = shNewest;
  u.id = (int)u.start;
  u.valid = true;
  return(true);
}

// Find first time of extreme inside [start,end]
bool FindFirstTimeOfLow(datetime start, datetime end, double lowValue, datetime &outT)
{
  int shOldest = ShiftAtOrAfter(start);
  int shNewest = ShiftBefore(end);
  if(shOldest < 0 || shNewest < 0) return(false);
  if(shOldest < shNewest) { int tmp=shOldest; shOldest=shNewest; shNewest=tmp; }
  // iterate from older to newer to find FIRST occurrence in time
  for(int s=shOldest; s>=shNewest; s--)
  {
    if(MathAbs(iLow(Symbol(), Period(), s) - lowValue) <= (Point*0.5))
    {
      outT = iTime(Symbol(), Period(), s);
      return(true);
    }
  }
  return(false);
}

bool FindFirstTimeOfHigh(datetime start, datetime end, double highValue, datetime &outT)
{
  int shOldest = ShiftAtOrAfter(start);
  int shNewest = ShiftBefore(end);
  if(shOldest < 0 || shNewest < 0) return(false);
  if(shOldest < shNewest) { int tmp=shOldest; shOldest=shNewest; shNewest=tmp; }
  for(int s=shOldest; s>=shNewest; s--)
  {
    if(MathAbs(iHigh(Symbol(), Period(), s) - highValue) <= (Point*0.5))
    {
      outT = iTime(Symbol(), Period(), s);
      return(true);
    }
  }
  return(false);
}


// Find first break (high) in a window [fromT .. toT] (inclusive), returns earliest break time in that window.
bool FindFirstBreakHigh(datetime fromT, datetime toT, double level, datetime &outT)
{
  // use afterT just before fromT to include breaks at fromT
  datetime afterT = fromT - 1;
  return(FindFirstBreakHighAfter(fromT, toT, level, afterT, outT));
}

// Find first break (low) in a window [fromT .. toT] (inclusive), returns earliest break time in that window.
bool FindFirstBreakLow(datetime fromT, datetime toT, double level, datetime &outT)
{
  datetime afterT = fromT - 1;
  return(FindFirstBreakLowAfter(fromT, toT, level, afterT, outT));
}

bool FindLastBreakHigh(datetime fromT, datetime toT, double level, datetime &outT)
{
  outT = 0;
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = Point*0.2;
  for(int s=shTo; s<=shFrom; s++)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    if(iHigh(Symbol(), Period(), s) > level + tol)
      outT = tt;
  }
  return(outT > 0);
}

bool FindLastBreakLow(datetime fromT, datetime toT, double level, datetime &outT)
{
  outT = 0;
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = Point*0.2;
  for(int s=shTo; s<=shFrom; s++)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    if(iLow(Symbol(), Period(), s) < level - tol)
      outT = tt;
  }
  return(outT > 0);
}

// Find first break after a given time
bool FindFirstBreakHighAfter(datetime fromT, datetime toT, double level, datetime afterT, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt <= afterT) continue;
    if(iHigh(Symbol(), Period(), s) > level + (Point*0.2))
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}

bool FindFirstBreakLowAfter(datetime fromT, datetime toT, double level, datetime afterT, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt <= afterT) continue;
    if(iLow(Symbol(), Period(), s) < level - (Point*0.2))
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}


// Find first time price touches a level inside a window (used to enforce "correction before break")
bool FindFirstTouchLow(datetime fromT, datetime toT, double level, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  for(int s=shFrom; s>=shTo; s--)
  {
    if(iLow(Symbol(), Period(), s) <= level + (Point*0.2))
    {
      outT = iTime(Symbol(), Period(), s);
      return(true);
    }
  }
  return(false);
}

bool FindFirstTouchHigh(datetime fromT, datetime toT, double level, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  for(int s=shFrom; s>=shTo; s--)
  {
    if(iHigh(Symbol(), Period(), s) >= level - (Point*0.2))
    {
      outT = iTime(Symbol(), Period(), s);
      return(true);
    }
  }
  return(false);
}

// Touch check (wick/close/anything): does any bar in [start,end] reach level?
bool AnyTouchLevel(datetime start, datetime end, double level, bool isHighTouch)
{
  int shOldest = ShiftAtOrAfter(start);
  int shNewest = ShiftBefore(end);
  if(shOldest < 0 || shNewest < 0) return(false);
  if(shOldest < shNewest) { int tmp=shOldest; shOldest=shNewest; shNewest=tmp; }
  for(int s=shOldest; s>=shNewest; s--)
  {
    if(isHighTouch)
    {
      if(iHigh(Symbol(), Period(), s) >= level - (Point*0.2)) return(true);
    }
    else
    {
      if(iLow(Symbol(), Period(), s) <= level + (Point*0.2)) return(true);
    }
  }
  return(false);
}


//-------------------- Unit helpers (NEW) --------------------
double UnitClosePrice(UnitInfo &u)
{
  // Close of the last bar inside the unit [u.start, u.end]
  // Use (u.end - 1 second) to ensure we pick a bar strictly inside the unit even if u.end aligns to bar open.
  datetime t = u.end - 1;
  int sh = iBarShift(Symbol(), Period(), t, false);
  if(sh < 0) sh = 0;
  return(iClose(Symbol(), Period(), sh));
}

bool AnyRetestAfter(datetime breakTime, datetime unitEnd, double level, bool isSell)
{
  // isSell=false => BUY retest means price comes back DOWN to level (low touch)
  // isSell=true  => SELL retest means price comes back UP to level (high touch)
  int tolPts = MathMax(0, InpTouchTolerancePoints);
  double tol = tolPts * Point;

  int shFrom = FindShiftByTime(breakTime);
  int shTo   = FindShiftByTime(unitEnd);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }

  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt <= breakTime) continue;

    if(isSell)
    {
      if(iHigh(Symbol(), Period(), s) >= level - tol) return(true);
    }
    else
    {
      if(iLow(Symbol(), Period(), s) <= level + tol) return(true);
    }
  }
  return(false);
}



double IntervalMinLow(datetime fromT, datetime toT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = 1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double l = iLow(Symbol(), Period(), s);
    if(l < v) v = l;
  }
  return(v);
}

double IntervalMaxHigh(datetime fromT, datetime toT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(-1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = -1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double h = iHigh(Symbol(), Period(), s);
    if(h > v) v = h;
  }
  return(v);
}

bool CloseInsideU2(UnitInfo &refU, UnitInfo &formU)
{
  double c = UnitClosePrice(formU);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point;
  return(c >= refU.lo - tol && c <= refU.hi + tol);
}

bool CloseOutsideU2InDirection(bool isSell, UnitInfo &refU, UnitInfo &formU)
{
  double c = UnitClosePrice(formU);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point;
  if(isSell) return(c < refU.lo - tol);
  return(c > refU.hi + tol);
}

double IntervalMinLowBefore(datetime fromT, datetime breakT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(breakT);
  if(shFrom < 0 || shTo < 0) return(1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = 1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt >= breakT) continue;
    double l = iLow(Symbol(), Period(), s);
    if(l < v) v = l;
  }
  return(v);
}

double IntervalMaxHighBefore(datetime fromT, datetime breakT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(breakT);
  if(shFrom < 0 || shTo < 0) return(-1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = -1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt >= breakT) continue;
    double h = iHigh(Symbol(), Period(), s);
    if(h > v) v = h;
  }
  return(v);
}

double IntervalMinLowAfter(datetime breakT, datetime toT)
{
  int shFrom = FindShiftByTime(breakT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = 1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt <= breakT || tt > toT) continue;
    double l = iLow(Symbol(), Period(), s);
    if(l < v) v = l;
  }
  return(v);
}

double IntervalMaxHighAfter(datetime breakT, datetime toT)
{
  int shFrom = FindShiftByTime(breakT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(-1e100);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double v = -1e100;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt <= breakT || tt > toT) continue;
    double h = iHigh(Symbol(), Period(), s);
    if(h > v) v = h;
  }
  return(v);
}


bool FindFirstTouchLowInBand(datetime fromT, datetime toT, double upperLevel, double lowerLevel, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double l = iLow(Symbol(), Period(), s);
    if(l <= upperLevel + tol && l >= lowerLevel - tol)
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}

bool FindFirstTouchHighInBand(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double h = iHigh(Symbol(), Period(), s);
    if(h >= lowerLevel - tol && h <= upperLevel + tol)
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}



bool FindLastTouchLowInBand(datetime fromT, datetime toT, double upperLevel, double lowerLevel, datetime &outT)
{
  outT = 0;
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  for(int s=shTo; s<=shFrom; s++)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double l = iLow(Symbol(), Period(), s);
    if(l <= upperLevel + tol && l >= lowerLevel - tol)
    {
      outT = tt;
    }
  }
  return(outT > 0);
}

bool FindLastTouchHighInBand(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT)
{
  outT = 0;
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  for(int s=shTo; s<=shFrom; s++)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    double h = iHigh(Symbol(), Period(), s);
    if(h >= lowerLevel - tol && h <= upperLevel + tol)
    {
      outT = tt;
    }
  }
  return(outT > 0);
}

bool FindStrictLowCorrectionInBand(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT)
{
  outT = 0;
  if(fromT >= toT) return(false);
  double minL = IntervalMinLow(fromT, toT);
  if(minL == 1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  // Correction must stay entirely inside the allowed low band: it may not go below lowerLevel,
  // and it must at least touch/enter the band up to upperLevel.
  if(minL < lowerLevel - tol) return(false);
  if(minL > upperLevel + tol) return(false);
  return(FindLastTouchLowInBand(fromT, toT, upperLevel, lowerLevel, outT));
}

bool FindStrictHighCorrectionInBand(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT)
{
  outT = 0;
  if(fromT >= toT) return(false);
  double maxH = IntervalMaxHigh(fromT, toT);
  if(maxH == -1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  // Correction must stay entirely inside the allowed high band: it may not go above upperLevel,
  // and it must at least touch/enter the band down to lowerLevel.
  if(maxH > upperLevel + tol) return(false);
  if(maxH < lowerLevel - tol) return(false);
  return(FindLastTouchHighInBand(fromT, toT, lowerLevel, upperLevel, outT));
}
bool FindStrictLowCorrectionWave(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT, double &outLow)
{
  outT = 0; outLow = 1e100;
  if(!FindStrictLowCorrectionInBand(fromT, toT, lowerLevel, upperLevel, outT)) return(false);
  // Use the wave segment up to the qualifying touch time, not the whole interval,
  // so later unrelated movement does not corrupt the correction-wave extreme.
  outLow = IntervalMinLow(fromT, outT);
  if(outLow == 1e100) return(false);
  return(true);
}

bool FindStrictHighCorrectionWave(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT, double &outHigh)
{
  outT = 0; outHigh = -1e100;
  if(!FindStrictHighCorrectionInBand(fromT, toT, lowerLevel, upperLevel, outT)) return(false);
  // Use the wave segment up to the qualifying touch time, not the whole interval.
  outHigh = IntervalMaxHigh(fromT, outT);
  if(outHigh == -1e100) return(false);
  return(true);
}


bool FindStrictLowCorrectionWaveFirst(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT, double &outLow)
{
  outT = 0; outLow = 1e100;
  if(fromT >= toT) return(false);
  double minL = IntervalMinLow(fromT, toT);
  if(minL == 1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  if(minL < lowerLevel - tol) return(false);
  if(minL > upperLevel + tol) return(false);
  if(!FindFirstTouchLowInBand(fromT, toT, upperLevel, lowerLevel, outT)) return(false);
  outLow = IntervalMinLow(fromT, outT);
  if(outLow == 1e100) return(false);
  return(true);
}

bool FindStrictHighCorrectionWaveFirst(datetime fromT, datetime toT, double lowerLevel, double upperLevel, datetime &outT, double &outHigh)
{
  outT = 0; outHigh = -1e100;
  if(fromT >= toT) return(false);
  double maxH = IntervalMaxHigh(fromT, toT);
  if(maxH == -1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  if(maxH > upperLevel + tol) return(false);
  if(maxH < lowerLevel - tol) return(false);
  if(!FindFirstTouchHighInBand(fromT, toT, lowerLevel, upperLevel, outT)) return(false);
  outHigh = IntervalMaxHigh(fromT, outT);
  if(outHigh == -1e100) return(false);
  return(true);
}
bool FindFirstReachHigh(datetime fromT, datetime toT, double target, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = Point*0.2;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    if(iHigh(Symbol(), Period(), s) >= target - tol)
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}

bool FindFirstReachLow(datetime fromT, datetime toT, double target, datetime &outT)
{
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  if(shFrom < shTo) { int t=shFrom; shFrom=shTo; shTo=t; }
  double tol = Point*0.2;
  for(int s=shFrom; s>=shTo; s--)
  {
    datetime tt = iTime(Symbol(), Period(), s);
    if(tt < fromT || tt > toT) continue;
    if(iLow(Symbol(), Period(), s) <= target + tol)
    {
      outT = tt;
      return(true);
    }
  }
  return(false);
}



struct PairEvents
{
  double R, level23, level38, level61, level76, target161, targetN61, closeU;
  bool closeInside, closeAbove, closeBelow;
  double formLow, formHigh;
  datetime breakUp, breakDown;
  datetime extBuy, extSell;
  bool retestUp, retestDown;
  double preMinLow, postMinLow, postExtMinLow;
  double preMaxHigh, postMaxHigh, postExtMaxHigh;
  // strict-wave extremes used for per-angle classification only
  double preMainBuyLow, preDeepBuyLow, postMainBuyLow, postDeepBuyLow, postExtDeepBuyLow;
  double preMainSellHigh, preDeepSellHigh, postMainSellHigh, postDeepSellHigh, postExtDeepSellHigh;
  datetime preMainBuyTime, preMainSellTime;
  datetime preDeepBuyTime, preDeepSellTime;
  datetime postMainBuyTime, postMainSellTime;
  datetime postDeepBuyTime, postDeepSellTime;
  datetime postExtDeepBuyTime, postExtDeepSellTime;
};

void InitPairEvents(PairEvents &ev)
{
  ev.R=0; ev.level23=0; ev.level38=0; ev.level61=0; ev.level76=0; ev.target161=0; ev.targetN61=0; ev.closeU=0;
  ev.closeInside=false; ev.closeAbove=false; ev.closeBelow=false;
  ev.breakUp=0; ev.breakDown=0; ev.extBuy=0; ev.extSell=0;
  ev.retestUp=false; ev.retestDown=false;
  ev.preMinLow=1e100; ev.postMinLow=1e100; ev.postExtMinLow=1e100;
  ev.preMaxHigh=-1e100; ev.postMaxHigh=-1e100; ev.postExtMaxHigh=-1e100;
  ev.preMainBuyLow=1e100; ev.preDeepBuyLow=1e100; ev.postMainBuyLow=1e100; ev.postDeepBuyLow=1e100; ev.postExtDeepBuyLow=1e100;
  ev.preMainSellHigh=-1e100; ev.preDeepSellHigh=-1e100; ev.postMainSellHigh=-1e100; ev.postDeepSellHigh=-1e100; ev.postExtDeepSellHigh=-1e100;
  ev.preMainBuyTime=0; ev.preMainSellTime=0;
  ev.preDeepBuyTime=0; ev.preDeepSellTime=0;
  ev.postMainBuyTime=0; ev.postMainSellTime=0;
  ev.postDeepBuyTime=0; ev.postDeepSellTime=0;
  ev.postExtDeepBuyTime=0; ev.postExtDeepSellTime=0;
}

bool HasInterval(datetime fromT, datetime toT)
{
  if(fromT >= toT) return(false);
  int shFrom = FindShiftByTime(fromT);
  int shTo   = FindShiftByTime(toT);
  if(shFrom < 0 || shTo < 0) return(false);
  return(true);
}

bool InBandInclusive(double v, double lo, double hi, double tol)
{
  return(v >= lo - tol && v <= hi + tol);
}

bool InBandStrictUpper(double v, double lo, double hi, double tol)
{
  return(v >= lo - tol && v < hi - tol);
}

bool InBandStrictLower(double v, double lo, double hi, double tol)
{
  return(v > lo + tol && v <= hi + tol);
}


bool HasBuyOverflow(double lowVal, UnitInfo &refU)
{
  if(lowVal==1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(lowVal < refU.lo - tol);
}

bool HasSellOverflow(double highVal, UnitInfo &refU)
{
  if(highVal==-1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(highVal > refU.hi + tol);
}

bool ExtractPairEvents(UnitInfo &refU, UnitInfo &formU, PairEvents &ev)
{
  InitPairEvents(ev);
  ev.R = refU.hi - refU.lo;
  ev.formLow = formU.lo; ev.formHigh = formU.hi;
  if(ev.R <= 0.0) return(false);

  ev.level23   = refU.lo + 0.236 * ev.R;
  ev.level38   = refU.lo + 0.382 * ev.R;
  ev.level61   = refU.lo + 0.618 * ev.R;
  ev.level76   = refU.lo + 0.764 * ev.R;
  ev.target161 = refU.lo + 1.618 * ev.R; // 161.80 line of U2
  ev.targetN61 = refU.lo - 0.618 * ev.R; // -61.80 line of U2
  ev.closeU    = UnitClosePrice(formU);

  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  ev.closeInside = (ev.closeU >= refU.lo - tol && ev.closeU <= refU.hi + tol);
  ev.closeAbove  = (ev.closeU >  refU.hi + tol);
  ev.closeBelow  = (ev.closeU <  refU.lo - tol);

  FindFirstBreakHigh(formU.start, formU.end, refU.hi, ev.breakUp);
  FindFirstBreakLow (formU.start, formU.end, refU.lo, ev.breakDown);

  if(ev.breakUp > 0)
  {
    if(HasInterval(formU.start, ev.breakUp - 1))
    {
      ev.preMinLow = IntervalMinLow(formU.start, ev.breakUp - 1);
      // Classification must rely on strict correction waves only.
      // Touch-only detections must never overwrite strict times.
      FindStrictLowCorrectionWave(formU.start, ev.breakUp - 1, ev.level38, ev.level76, ev.preMainBuyTime, ev.preMainBuyLow);
      FindStrictLowCorrectionWave(formU.start, ev.breakUp - 1, refU.lo, ev.level38, ev.preDeepBuyTime, ev.preDeepBuyLow);
    }
    if(HasInterval(ev.breakUp + 1, formU.end))
    {
      ev.postMinLow = IntervalMinLow(ev.breakUp + 1, formU.end);
      FindStrictLowCorrectionWaveFirst(ev.breakUp + 1, formU.end, ev.level38, ev.level76, ev.postMainBuyTime, ev.postMainBuyLow);
      FindStrictLowCorrectionWaveFirst(ev.breakUp + 1, formU.end, refU.lo, ev.level38, ev.postDeepBuyTime, ev.postDeepBuyLow);
    }

    FindFirstReachHigh(ev.breakUp, formU.end, ev.target161, ev.extBuy);
    if(ev.extBuy > 0 && HasInterval(ev.extBuy + 1, formU.end))
    {
      ev.postExtMinLow = IntervalMinLow(ev.extBuy + 1, formU.end);
      FindStrictLowCorrectionWaveFirst(ev.extBuy + 1, formU.end, refU.lo, ev.level38, ev.postExtDeepBuyTime, ev.postExtDeepBuyLow);
    }

    ev.retestUp = AnyRetestAfter(ev.breakUp, formU.end, refU.hi, false);
  }

  if(ev.breakDown > 0)
  {
    if(HasInterval(formU.start, ev.breakDown - 1))
    {
      ev.preMaxHigh = IntervalMaxHigh(formU.start, ev.breakDown - 1);
      // Classification must rely on strict correction waves only.
      // Touch-only detections must never overwrite strict times.
      FindStrictHighCorrectionWave(formU.start, ev.breakDown - 1, ev.level23, ev.level61, ev.preMainSellTime, ev.preMainSellHigh);
      FindStrictHighCorrectionWave(formU.start, ev.breakDown - 1, ev.level61, refU.hi, ev.preDeepSellTime, ev.preDeepSellHigh);
    }
    if(HasInterval(ev.breakDown + 1, formU.end))
    {
      ev.postMaxHigh = IntervalMaxHigh(ev.breakDown + 1, formU.end);
      FindStrictHighCorrectionWaveFirst(ev.breakDown + 1, formU.end, ev.level23, ev.level61, ev.postMainSellTime, ev.postMainSellHigh);
      FindStrictHighCorrectionWaveFirst(ev.breakDown + 1, formU.end, ev.level61, refU.hi, ev.postDeepSellTime, ev.postDeepSellHigh);
    }

    FindFirstReachLow(ev.breakDown, formU.end, ev.targetN61, ev.extSell);
    if(ev.extSell > 0 && HasInterval(ev.extSell + 1, formU.end))
    {
      ev.postExtMaxHigh = IntervalMaxHigh(ev.extSell + 1, formU.end);
      FindStrictHighCorrectionWaveFirst(ev.extSell + 1, formU.end, ev.level61, refU.hi, ev.postExtDeepSellTime, ev.postExtDeepSellHigh);
    }

    ev.retestDown = AnyRetestAfter(ev.breakDown, formU.end, refU.lo, true);
  }
  return(true);
}

// --- Family gates and strict zone logic (U2 reference, U1 formation) ---
// First family: ZA/ZB/ZC/ZD/ZE
//   BUY correction must stay inside [76.40 .. 38.20] of U2 => low in [Level38 .. Level76]
//   SELL correction must stay inside [23.60 .. 61.80] of U2 => high in [Level23 .. Level61]
// Second family: ZF/ZG/ZO/ZH
//   BUY correction must stay inside [0 .. 38.20] of U2 => low in [U2.low .. Level38)
//   SELL correction must stay inside (61.80 .. 100] of U2 => high in (Level61 .. U2.high]

bool BuyAngleEntryGate(PairEvents &ev)
{
  // Global BUY gate: at least one strict correction wave inside U1 versus U2 must reach 76.40 of U2.
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  bool preOk  = (ev.preMinLow     != 1e100 && ev.preMinLow     <= ev.level76 + tol);
  bool postOk = (ev.postMinLow    != 1e100 && ev.postMinLow    <= ev.level76 + tol);
  bool extOk  = (ev.postExtMinLow != 1e100 && ev.postExtMinLow <= ev.level76 + tol);
  return(preOk || postOk || extOk);
}

bool SellAngleEntryGate(PairEvents &ev)
{
  // Global SELL gate: at least one strict correction wave inside U1 versus U2 must reach 23.60 of U2.
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  bool preOk  = (ev.preMaxHigh     != -1e100 && ev.preMaxHigh     >= ev.level23 - tol);
  bool postOk = (ev.postMaxHigh    != -1e100 && ev.postMaxHigh    >= ev.level23 - tol);
  bool extOk  = (ev.postExtMaxHigh != -1e100 && ev.postExtMaxHigh >= ev.level23 - tol);
  return(preOk || postOk || extOk);
}

bool BuyMainWaveGate(PairEvents &ev, double low)
{
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(low != 1e100 && low <= ev.level76 + tol && low >= ev.level38 - tol);
}

bool SellMainWaveGate(PairEvents &ev, double high)
{
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(high != -1e100 && high >= ev.level23 - tol && high <= ev.level61 + tol);
}

bool BuyDeepWaveGate(PairEvents &ev, UnitInfo &refU, double low)
{
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(low != 1e100 && low <= ev.level38 + tol && low >= refU.lo - tol);
}

bool SellDeepWaveGate(PairEvents &ev, UnitInfo &refU, double high)
{
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  return(high != -1e100 && high >= ev.level61 - tol && high <= refU.hi + tol);
}

bool BuyPreMainValid(PairEvents &ev)
{
  if(ev.breakUp <= 0 || ev.preMainBuyTime <= 0) return(false);
  return(BuyMainWaveGate(ev, ev.preMainBuyLow));
}

bool SellPreMainValid(PairEvents &ev)
{
  if(ev.breakDown <= 0 || ev.preMainSellTime <= 0) return(false);
  return(SellMainWaveGate(ev, ev.preMainSellHigh));
}

bool BuyPreDeepValid(PairEvents &ev, UnitInfo &refU)
{
  if(ev.breakUp <= 0 || ev.preDeepBuyTime <= 0) return(false);
  return(BuyDeepWaveGate(ev, refU, ev.preDeepBuyLow));
}

bool SellPreDeepValid(PairEvents &ev, UnitInfo &refU)
{
  if(ev.breakDown <= 0 || ev.preDeepSellTime <= 0) return(false);
  return(SellDeepWaveGate(ev, refU, ev.preDeepSellHigh));
}

bool BuyBreakFirst(PairEvents &ev)
{
  // Break-first BUY only if there is no qualifying pre-break correction wave in either family.
  if(ev.breakUp <= 0) return(false);
  return(ev.preMainBuyTime <= 0 && ev.preDeepBuyTime <= 0);
}

bool SellBreakFirst(PairEvents &ev)
{
  // Break-first SELL only if there is no qualifying pre-break correction wave in either family.
  if(ev.breakDown <= 0) return(false);
  return(ev.preMainSellTime <= 0 && ev.preDeepSellTime <= 0);
}

bool BuyPostMainValid(PairEvents &ev)
{
  if(ev.breakUp <= 0 || ev.postMainBuyTime <= 0) return(false);
  return(BuyMainWaveGate(ev, ev.postMainBuyLow));
}

bool SellPostMainValid(PairEvents &ev)
{
  if(ev.breakDown <= 0 || ev.postMainSellTime <= 0) return(false);
  return(SellMainWaveGate(ev, ev.postMainSellHigh));
}

bool BuyPostExtDeepValid(PairEvents &ev, UnitInfo &refU)
{
  if(ev.extBuy <= 0 || ev.postExtDeepBuyTime <= 0) return(false);
  return(BuyDeepWaveGate(ev, refU, ev.postExtDeepBuyLow));
}

bool SellPostExtDeepValid(PairEvents &ev, UnitInfo &refU)
{
  if(ev.extSell <= 0 || ev.postExtDeepSellTime <= 0) return(false);
  return(SellDeepWaveGate(ev, refU, ev.postExtDeepSellHigh));
}

bool NoDeepPreBreakBuy(PairEvents &ev)  { return(ev.preDeepBuyTime <= 0); }
bool NoDeepPreBreakSell(PairEvents &ev) { return(ev.preDeepSellTime <= 0); }
bool NoMainPreBreakBuy(PairEvents &ev)  { return(ev.preMainBuyTime <= 0); }
bool NoMainPreBreakSell(PairEvents &ev) { return(ev.preMainSellTime <= 0); }

bool NoExtensionBuy(PairEvents &ev)      { return(ev.extBuy <= 0); }
bool NoExtensionSell(PairEvents &ev)     { return(ev.extSell <= 0); }


bool BuyPostMainPathClean(PairEvents &ev)
{
  if(ev.postMainBuyTime<=0) return(false);
  // The first qualifying event after break must be the main correction path itself.
  if(ev.postDeepBuyTime>0 && ev.postDeepBuyTime <= ev.postMainBuyTime) return(false);
  if(ev.extBuy>0 && ev.extBuy <= ev.postMainBuyTime) return(false);
  return(true);
}

bool SellPostMainPathClean(PairEvents &ev)
{
  if(ev.postMainSellTime<=0) return(false);
  if(ev.postDeepSellTime>0 && ev.postDeepSellTime <= ev.postMainSellTime) return(false);
  if(ev.extSell>0 && ev.extSell <= ev.postMainSellTime) return(false);
  return(true);
}



bool NearEq(double a, double b, double tol) { return(MathAbs(a-b) <= tol); }

bool BuyPostMainFinalInZone(PairEvents &ev)
{
  if(ev.postMainBuyTime<=0 || ev.postMainBuyLow==1e100 || ev.postMinLow==1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  // No lower low after the accepted post-main wave; otherwise the path changed.
  if(ev.postMinLow < ev.postMainBuyLow - tol) return(false);
  return(BuyMainWaveGate(ev, ev.postMinLow));
}

bool SellPostMainFinalInZone(PairEvents &ev)
{
  if(ev.postMainSellTime<=0 || ev.postMainSellHigh==-1e100 || ev.postMaxHigh==-1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  // No higher high after the accepted post-main wave; otherwise the path changed.
  if(ev.postMaxHigh > ev.postMainSellHigh + tol) return(false);
  return(SellMainWaveGate(ev, ev.postMaxHigh));
}

bool BuyPreMainFinalInZone(PairEvents &ev)
{
  if(ev.preMainBuyTime<=0 || ev.preMainBuyLow==1e100 || ev.preMinLow==1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  if(ev.preMinLow < ev.preMainBuyLow - tol) return(false);
  return(BuyMainWaveGate(ev, ev.preMinLow));
}

bool SellPreMainFinalInZone(PairEvents &ev)
{
  if(ev.preMainSellTime<=0 || ev.preMainSellHigh==-1e100 || ev.preMaxHigh==-1e100) return(false);
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  if(ev.preMaxHigh > ev.preMainSellHigh + tol) return(false);
  return(SellMainWaveGate(ev, ev.preMaxHigh));
}

bool IsZA_Buy(PairEvents &ev)
{
  if(!BuyPreMainValid(ev)) return(false);
  if(!BuyPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakBuy(ev)) return(false);
  if(ev.breakUp <= 0 || ev.preMainBuyTime <= 0 || ev.preMainBuyTime >= ev.breakUp) return(false);
  if(ev.retestUp) return(false);
  if(ev.postMainBuyTime > 0 || ev.postDeepBuyTime > 0) return(false); // no qualifying post-break correction for ZA
  if(!NoExtensionBuy(ev)) return(false);
  return(ev.closeAbove);
}

bool IsZA_Sell(PairEvents &ev)
{
  if(!SellPreMainValid(ev)) return(false);
  if(!SellPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakSell(ev)) return(false);
  if(ev.breakDown <= 0 || ev.preMainSellTime <= 0 || ev.preMainSellTime >= ev.breakDown) return(false);
  if(ev.retestDown) return(false);
  if(ev.postMainSellTime > 0 || ev.postDeepSellTime > 0) return(false);
  if(!NoExtensionSell(ev)) return(false);
  return(ev.closeBelow);
}

bool IsZB_Buy(PairEvents &ev)
{
  if(!BuyPreMainValid(ev)) return(false);
  if(!BuyPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakBuy(ev)) return(false);
  if(ev.breakUp <= 0 || ev.preMainBuyTime <= 0 || ev.preMainBuyTime >= ev.breakUp) return(false);
  if(!ev.retestUp) return(false);
  if(ev.postMainBuyTime <= 0 || ev.postMainBuyTime <= ev.breakUp) return(false); // retest must produce a valid main-family post-break correction
  if(ev.postDeepBuyTime > 0) return(false);
  if(!NoExtensionBuy(ev)) return(false);
  return(ev.closeAbove);
}

bool IsZB_Sell(PairEvents &ev)
{
  if(!SellPreMainValid(ev)) return(false);
  if(!SellPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakSell(ev)) return(false);
  if(ev.breakDown <= 0 || ev.preMainSellTime <= 0 || ev.preMainSellTime >= ev.breakDown) return(false);
  if(!ev.retestDown) return(false);
  if(ev.postMainSellTime <= 0 || ev.postMainSellTime <= ev.breakDown) return(false);
  if(ev.postDeepSellTime > 0) return(false);
  if(!NoExtensionSell(ev)) return(false);
  return(ev.closeBelow);
}

bool IsZC_Buy(PairEvents &ev)
{
  if(!BuyPreMainValid(ev)) return(false);
  if(!BuyPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakBuy(ev)) return(false);
  if(ev.breakUp <= 0 || ev.preMainBuyTime <= 0 || ev.preMainBuyTime >= ev.breakUp) return(false);
  if(!ev.retestUp) return(false);
  if(ev.postMainBuyTime <= 0 || ev.postMainBuyTime <= ev.breakUp) return(false); // retest must produce a valid main-family post-break correction
  if(ev.postDeepBuyTime > 0) return(false);
  if(!NoExtensionBuy(ev)) return(false);
  return(ev.closeInside);
}

bool IsZC_Sell(PairEvents &ev)
{
  if(!SellPreMainValid(ev)) return(false);
  if(!SellPreMainFinalInZone(ev)) return(false);
  if(!NoDeepPreBreakSell(ev)) return(false);
  if(ev.breakDown <= 0 || ev.preMainSellTime <= 0 || ev.preMainSellTime >= ev.breakDown) return(false);
  if(!ev.retestDown) return(false);
  if(ev.postMainSellTime <= 0 || ev.postMainSellTime <= ev.breakDown) return(false);
  if(ev.postDeepSellTime > 0) return(false);
  if(!NoExtensionSell(ev)) return(false);
  return(ev.closeInside);
}

bool IsZD_Buy(PairEvents &ev)
{
  if(!BuyBreakFirst(ev)) return(false);
  if(!BuyPostMainValid(ev)) return(false);
  if(!BuyPostMainPathClean(ev)) return(false);
  if(!BuyPostMainFinalInZone(ev)) return(false);
  if(ev.retestUp) return(false); // break-first ZD should not end as retest-inside structure
  return(ev.closeAbove);
}

bool IsZD_Sell(PairEvents &ev)
{
  if(!SellBreakFirst(ev)) return(false);
  if(!SellPostMainValid(ev)) return(false);
  if(!SellPostMainPathClean(ev)) return(false);
  if(!SellPostMainFinalInZone(ev)) return(false);
  if(ev.retestDown) return(false);
  return(ev.closeBelow);
}

bool IsZE_Buy(PairEvents &ev)
{
  if(!BuyBreakFirst(ev)) return(false);
  if(!BuyPostMainValid(ev)) return(false);
  if(!BuyPostMainPathClean(ev)) return(false);
  if(!BuyPostMainFinalInZone(ev)) return(false);
  return(ev.closeInside);
}

bool IsZE_Sell(PairEvents &ev)
{
  if(!SellBreakFirst(ev)) return(false);
  if(!SellPostMainValid(ev)) return(false);
  if(!SellPostMainPathClean(ev)) return(false);
  if(!SellPostMainFinalInZone(ev)) return(false);
  return(ev.closeInside);
}

bool IsZF_Buy(UnitInfo &refU, PairEvents &ev)
{
  if(!BuyPreDeepValid(ev, refU)) return(false);
  if(ev.preMainBuyTime > ev.preDeepBuyTime) return(false);
  if(ev.breakUp <= 0 || ev.preDeepBuyTime <= 0 || ev.preDeepBuyTime >= ev.breakUp) return(false);
  if(ev.extBuy <= 0 || ev.extBuy <= ev.breakUp) return(false);
  if(ev.postMainBuyTime > 0 || ev.postDeepBuyTime > 0 || ev.postExtDeepBuyTime > 0) return(false);
  return(ev.closeAbove);
}

bool IsZF_Sell(UnitInfo &refU, PairEvents &ev)
{
  if(!SellPreDeepValid(ev, refU)) return(false);
  if(ev.preMainSellTime > ev.preDeepSellTime) return(false);
  if(ev.breakDown <= 0 || ev.preDeepSellTime <= 0 || ev.preDeepSellTime >= ev.breakDown) return(false);
  if(ev.extSell <= 0 || ev.extSell <= ev.breakDown) return(false);
  if(ev.postMainSellTime > 0 || ev.postDeepSellTime > 0 || ev.postExtDeepSellTime > 0) return(false);
  return(ev.closeBelow);
}

bool IsZG_Buy(UnitInfo &refU, PairEvents &ev)
{
  if(!BuyPreDeepValid(ev, refU)) return(false);
  if(ev.preMainBuyTime > ev.preDeepBuyTime) return(false);
  if(ev.breakUp <= 0 || ev.preDeepBuyTime <= 0 || ev.preDeepBuyTime >= ev.breakUp) return(false);
  if(ev.extBuy <= 0 || ev.extBuy <= ev.breakUp) return(false);
  if(ev.postMainBuyTime > 0 || ev.postDeepBuyTime > 0 || ev.postExtDeepBuyTime > 0) return(false);
  return(ev.closeInside);
}

bool IsZG_Sell(UnitInfo &refU, PairEvents &ev)
{
  if(!SellPreDeepValid(ev, refU)) return(false);
  if(ev.preMainSellTime > ev.preDeepSellTime) return(false);
  if(ev.breakDown <= 0 || ev.preDeepSellTime <= 0 || ev.preDeepSellTime >= ev.breakDown) return(false);
  if(ev.extSell <= 0 || ev.extSell <= ev.breakDown) return(false);
  if(ev.postMainSellTime > 0 || ev.postDeepSellTime > 0 || ev.postExtDeepSellTime > 0) return(false);
  return(ev.closeInside);
}

bool IsZO_Buy(UnitInfo &refU, PairEvents &ev)
{
  if(!BuyBreakFirst(ev)) return(false);
  if(ev.extBuy <= 0 || ev.extBuy <= ev.breakUp) return(false);
  if(ev.postMainBuyTime > 0) return(false);
  if(!BuyPostExtDeepValid(ev, refU)) return(false);
  if(ev.postExtDeepBuyTime <= 0 || ev.postExtDeepBuyTime <= ev.extBuy) return(false);
  return(ev.closeInside);
}

bool IsZO_Sell(UnitInfo &refU, PairEvents &ev)
{
  if(!SellBreakFirst(ev)) return(false);
  if(ev.extSell <= 0 || ev.extSell <= ev.breakDown) return(false);
  if(ev.postMainSellTime > 0) return(false);
  if(!SellPostExtDeepValid(ev, refU)) return(false);
  if(ev.postExtDeepSellTime <= 0 || ev.postExtDeepSellTime <= ev.extSell) return(false);
  return(ev.closeInside);
}

bool IsZH_Buy(UnitInfo &refU, PairEvents &ev)
{
  if(!BuyBreakFirst(ev)) return(false);
  if(ev.extBuy <= 0 || ev.extBuy <= ev.breakUp) return(false);
  if(ev.postMainBuyTime > 0) return(false);
  if(!BuyPostExtDeepValid(ev, refU)) return(false);
  if(ev.postExtDeepBuyTime <= 0 || ev.postExtDeepBuyTime <= ev.extBuy) return(false);
  return(ev.closeAbove);
}

bool IsZH_Sell(UnitInfo &refU, PairEvents &ev)
{
  if(!SellBreakFirst(ev)) return(false);
  if(ev.extSell <= 0 || ev.extSell <= ev.breakDown) return(false);
  if(ev.postMainSellTime > 0) return(false);
  if(!SellPostExtDeepValid(ev, refU)) return(false);
  if(ev.postExtDeepSellTime <= 0 || ev.postExtDeepSellTime <= ev.extSell) return(false);
  return(ev.closeBelow);
}






CloseCheckResult RunCloseChecker(UnitInfo &refU, UnitInfo &formU)
{
  CloseCheckResult r; r.state = 99;
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;

  if(formU.lastClose > refU.hi + tol) r.state = 1;
  else if(formU.lastClose < refU.lo - tol) r.state = -1;
  else if(formU.lastClose >= refU.lo - tol && formU.lastClose <= refU.hi + tol) r.state = 0;

  return(r);
}

DirectionCheckResult RunDirectionChecker(UnitInfo &refU, UnitInfo &formU)
{
  DirectionCheckResult r; r.state = 0;
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;
  bool bull = (formU.hi > refU.hi + tol && formU.lo > refU.lo + tol);
  bool bear = (formU.hi < refU.hi - tol && formU.lo < refU.lo - tol);
  if(bull) r.state = 1;
  else if(bear) r.state = -1;
  return(r);
}

RangeCheckResult RunRangeChecker(UnitInfo &refU, UnitInfo &formU, const DirectionCheckResult &dir)
{
  RangeCheckResult r; r.state = 0;
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;

  if(dir.state == 1)
  {
    if(formU.lo >= refU.level38 - tol && formU.lo <= refU.level76 + tol)
      r.state = 1; // B_ALPHA
    else if(formU.lo > refU.level0 + tol && formU.lo < refU.level38 - tol)
      r.state = 2; // B_BETA
  }
  else if(dir.state == -1)
  {
    if(formU.hi > refU.level23 + tol && formU.hi <= refU.level61 + tol)
      r.state = 1; // S_ALPHA
    else if(formU.hi > refU.level61 + tol && formU.hi < refU.level100 - tol)
      r.state = 2; // S_BETA
  }
  return(r);
}

OrderCheckResult RunOrderChecker(UnitInfo &formU, PairEvents &ev, const DirectionCheckResult &dir)
{
  OrderCheckResult r; r.state = 0;
  if(dir.state == 1)
  {
    datetime tLowF = formU.loTime;
    if(ev.breakUp > 0 && tLowF > 0)
    {
      if(ev.breakUp < tLowF) r.state = 1; // K1
      else if(tLowF < ev.breakUp) r.state = 2; // R1
    }
  }
  else if(dir.state == -1)
  {
    datetime tHighF = formU.hiTime;
    if(ev.breakDown > 0 && tHighF > 0)
    {
      if(ev.breakDown < tHighF) r.state = 1; // SK1
      else if(tHighF < ev.breakDown) r.state = 2; // SR1
    }
  }
  return(r);
}

struct PairScanInfo
{
  bool      hasBreakUp;
  bool      hasBreakDown;
  datetime  firstBreakUpTime;
  datetime  firstBreakDownTime;
  bool      hasRetestUp;
  bool      hasRetestDown;
  bool      reached161;
  bool      reachedNeg61;
};

bool ScanPairInfo(UnitInfo &refU, UnitInfo &formU, PairScanInfo &ps)
{
  ps.hasBreakUp = false;
  ps.hasBreakDown = false;
  ps.firstBreakUpTime = 0;
  ps.firstBreakDownTime = 0;
  ps.hasRetestUp = false;
  ps.hasRetestDown = false;
  ps.reached161 = false;
  ps.reachedNeg61 = false;

  int sh1 = iBarShift(NULL, 0, formU.start, false);
  int sh2 = iBarShift(NULL, 0, formU.end, false);
  if(sh1 < 0 || sh2 < 0) return(false);

  int fromShift = MathMin(sh1, sh2);
  int toShift   = MathMax(sh1, sh2);
  bool breakUpSeen = false;
  bool breakDnSeen = false;

  for(int s = toShift; s >= fromShift; s--)
  {
    datetime bt = Time[s];
    double bh = High[s];
    double bl = Low[s];

    if(!breakUpSeen && bh > refU.hi)
    {
      ps.hasBreakUp = true;
      ps.firstBreakUpTime = bt;
      breakUpSeen = true;
    }
    if(!breakDnSeen && bl < refU.lo)
    {
      ps.hasBreakDown = true;
      ps.firstBreakDownTime = bt;
      breakDnSeen = true;
    }

    if(breakUpSeen && bl <= refU.hi && bh >= refU.lo)
      ps.hasRetestUp = true;
    if(breakDnSeen && bl <= refU.hi && bh >= refU.lo)
      ps.hasRetestDown = true;

    if(bh >= refU.level161) ps.reached161 = true;
    if(bl <= refU.levelNeg61) ps.reachedNeg61 = true;
  }

  return(true);
}

OrderCheckResult RunOrderChecker(UnitInfo &refU, UnitInfo &formU, const DirectionCheckResult &dir, const PairScanInfo &ps)
{
  OrderCheckResult r; r.state = 0;

  if(dir.state == 1)
  {
    if(ps.hasBreakUp && formU.loTime > 0)
    {
      if(ps.firstBreakUpTime < formU.loTime) r.state = 1; // K1
      else if(formU.loTime < ps.firstBreakUpTime) r.state = 2; // R1
    }
  }
  else if(dir.state == -1)
  {
    if(ps.hasBreakDown && formU.hiTime > 0)
    {
      if(ps.firstBreakDownTime < formU.hiTime) r.state = 1; // SK1
      else if(formU.hiTime < ps.firstBreakDownTime) r.state = 2; // SR1
    }
  }
  return(r);
}

RetestCheckResult RunRetestChecker(const DirectionCheckResult &dir, const PairScanInfo &ps)
{
  RetestCheckResult r; r.state = false;
  if(dir.state == 1) r.state = ps.hasRetestUp;
  else if(dir.state == -1) r.state = ps.hasRetestDown;
  return(r);
}

ExtensionCheckResult RunExtensionChecker(const DirectionCheckResult &dir, const PairScanInfo &ps)
{
  ExtensionCheckResult r;
  r.reached161 = (dir.state == 1 && ps.reached161);
  r.reachedNeg61 = (dir.state == -1 && ps.reachedNeg61);
  return(r);
}

bool BuildSupervisorFacts(UnitInfo &refU, UnitInfo &formU, SupervisorFacts &f)
{
  f.dir   = RunDirectionChecker(refU, formU);
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
  f.ext = RunExtensionChecker(f.dir, ps);
  return(true);
}

string SupervisorDecideAngle(const SupervisorFacts &f)
{
  if(f.dir.state == 1)
  {
    if(f.range.state == 1) // B-ALPHA
    {
      if(f.ext.reached161) return("");
      if(f.order.state == 2) // R1
      {
        if(!f.retest.state && f.close.state == 1) return("ZA");
        if( f.retest.state && f.close.state == 1) return("ZB");
        if( f.retest.state && f.close.state == 0) return("ZC");
      }
      else if(f.order.state == 1) // K1
      {
        if(f.close.state == 1) return("ZD");
        if(f.close.state == 0) return("ZE");
      }
    }
    else if(f.range.state == 2) // B-BETA
    {
      if(!f.ext.reached161) return("");
      if(f.order.state == 2)
      {
        if(f.close.state == 1) return("ZF");
        if(f.close.state == 0) return("ZG");
      }
      else if(f.order.state == 1)
      {
        if(f.close.state == 0) return("ZO");
        if(f.close.state == 1) return("ZH");
      }
    }
  }
  else if(f.dir.state == -1)
  {
    if(f.range.state == 1) // S-ALPHA
    {
      if(f.ext.reachedNeg61) return("");
      if(f.order.state == 2) // SR1
      {
        if(!f.retest.state && f.close.state == -1) return("ZA");
        if( f.retest.state && f.close.state == -1) return("ZB");
        if( f.retest.state && f.close.state == 0)  return("ZC");
      }
      else if(f.order.state == 1) // SK1
      {
        if(f.close.state == -1) return("ZD");
        if(f.close.state == 0)  return("ZE");
      }
    }
    else if(f.range.state == 2) // S-BETA
    {
      if(!f.ext.reachedNeg61) return("");
      if(f.order.state == 2)
      {
        if(f.close.state == -1) return("ZF");
        if(f.close.state == 0)  return("ZG");
      }
      else if(f.order.state == 1)
      {
        if(f.close.state == 0)  return("ZO");
        if(f.close.state == -1) return("ZH");
      }
    }
  }
  return("");
}

int BuildUnitsSCCMW(UnitInfo &U[], int maxUnits, datetime tFrom, datetime tTo)
{
  ArrayResize(U, 0);
  SCCMW_TM_Init();

  // Use last available bar as anchor — works even when market is closed/weekend.
  datetime lastBar = (Bars > 0) ? Time[0] : TimeCurrent();
  datetime anchor = (tTo > 0 ? tTo : lastBar);
  datetime startLimit = tFrom;
  if(startLimit==0) startLimit = anchor - (MathMax(5, maxUnits+2) * MathMax(g_unitSeconds, PeriodSeconds(Period())));

  datetime currentStart = SCCMW_TM_FixTimeGaps(SCCMW_TM_GetFirstPeriodForAnchor(anchor), true);
  if(currentStart <= 0) return(0);
  if(currentStart > anchor) currentStart = anchor;

  UnitInfo u0;
  if(currentStart < anchor && BuildUnit(currentStart, anchor, u0))
  {
    int sz=ArraySize(U); ArrayResize(U, sz+1); U[sz]=u0;
  }

  datetime rightBoundary = currentStart;
  int added = 0;
  while(added < maxUnits)
  {
    datetime leftBoundary = SCCMW_TM_FixTimeGaps(SCCMW_TM_GetNextPeriod(rightBoundary, false));
    if(leftBoundary <= 0 || leftBoundary >= rightBoundary) break;
    if(rightBoundary < startLimit) break;

    UnitInfo u;
    if(BuildUnit(leftBoundary, rightBoundary, u))
    {
      int sz2 = ArraySize(U); ArrayResize(U, sz2+1); U[sz2] = u;
      added++;
    }
    rightBoundary = leftBoundary;
  }
  return(ArraySize(U));
}

int BuildUnitsLegacy(UnitInfo &U[], int maxUnits, datetime tFrom, datetime tTo)
{
  ArrayResize(U, 0);
  int sec = g_unitSeconds;

  datetime anchor = (tTo>0 ? tTo : Time[0]); // dynamic-visible anchor: build units around the right edge of the requested window

  datetime lastBoundary = (datetime)((long)anchor - ((long)anchor % sec));
  if(lastBoundary > anchor) lastBoundary -= sec;

  datetime startLimit = tFrom;
  datetime endLimit   = anchor;
  if(startLimit==0 || endLimit==0)
  {
    startLimit = anchor - (sec*maxUnits);
    endLimit   = anchor;
  }

  UnitInfo u0;
  if(lastBoundary < anchor)
  {
    if(BuildUnit(lastBoundary, anchor, u0))
    {
      int sz0 = ArraySize(U);
      ArrayResize(U, sz0+1);
      U[sz0] = u0;
    }
  }
  else
  {
    UnitInfo u0b;
    if(BuildUnit(anchor-sec, anchor, u0b))
    {
      int sz0 = ArraySize(U);
      ArrayResize(U, sz0+1);
      U[sz0] = u0b;
    }
    lastBoundary = anchor;
  }

  int added = 0;
  datetime end = lastBoundary;
  while(added < maxUnits)
  {
    datetime start = end - sec;
    if(end < startLimit) break;
    if(start > endLimit)
    {
      end = start;
      continue;
    }

    UnitInfo u;
    if(BuildUnit(start, end, u))
    {
      int sz = ArraySize(U);
      ArrayResize(U, sz+1);
      U[sz] = u;
      added++;
    }
    end = start;
  }

  return(ArraySize(U));
}

int BuildUnits(UnitInfo &U[], int maxUnits, datetime tFrom, datetime tTo)
{
  if(InpUseSCCMWUnitLogic)
  {
    int n = BuildUnitsSCCMW(U, maxUnits, tFrom, tTo);
    // SCCMW relies on a higher-TF series (e.g. D1 for H1 charts, W1 for H4 charts).
    // If that series is not yet loaded in MT4 or the requested range is beyond its
    // available history, GetNextPeriod returns last_time and the loop exits with 0 units.
    // Fall back to pure-time-math boundaries so historical scrolling always works.
    if(n > 0) return(n);
  }
  return(BuildUnitsLegacy(U, maxUnits, tFrom, tTo));
}


datetime GetCurrentUnitAnchor()
{
  // Use last available bar — valid even when market is closed/weekend.
  datetime refTime = (Bars > 0) ? Time[0] : TimeCurrent();

  if(InpUseSCCMWUnitLogic)
  {
    SCCMW_TM_Init();
    datetime a = SCCMW_TM_FixTimeGaps(SCCMW_TM_GetFirstPeriodForAnchor(refTime), true);
    if(a > 0) return(a);
  }

  EnsureValidUnitSeconds();
  int sec = g_unitSeconds;
  if(sec <= 0) sec = PeriodSeconds(Period());
  if(sec <= 0) sec = 60;
  datetime a2 = (datetime)((long)refTime - ((long)refTime % sec));
  if(a2 > refTime) a2 -= sec;
  return(a2);
}

int GetCacheMaxUnits()
{
  int bars = Bars;
  int approx = bars;
  if(approx < 8000) approx = 8000;
  if(approx > 120000) approx = 120000;
  return(approx);
}

void UpdateCacheCoverage()
{
  if(g_unitCacheCount <= 0)
  {
    g_cacheLeftTime = 0;
    g_cacheRightTime = 0;
    return;
  }
  g_cacheRightTime = g_unitCache[0].end;
  g_cacheLeftTime  = g_unitCache[g_unitCacheCount-1].start;
}

void NormalizeUnitCache()
{
  if(g_unitCacheCount <= 1)
  {
    UpdateCacheCoverage();
    return;
  }

  UnitInfo clean[];
  int cn = 0;
  ArrayResize(clean, 0);

  for(int i=0; i<g_unitCacheCount; i++)
  {
    bool exists = false;
    for(int j=0; j<cn; j++)
    {
      if(clean[j].id == g_unitCache[i].id)
      {
        exists = true;
        break;
      }
    }
    if(exists) continue;

    ArrayResize(clean, cn+1);
    clean[cn] = g_unitCache[i];
    cn++;
  }

  for(int a=0; a<cn-1; a++)
  {
    for(int b=a+1; b<cn; b++)
    {
      if(clean[a].start < clean[b].start)
      {
        UnitInfo tmp = clean[a];
        clean[a] = clean[b];
        clean[b] = tmp;
      }
    }
  }

  ArrayResize(g_unitCache, cn);
  for(int k=0; k<cn; k++) g_unitCache[k] = clean[k];
  g_unitCacheCount = cn;
  UpdateCacheCoverage();
}

void RunScaleManagerOnce()
{
  if(g_scaleReleasedByUser) return;
  if(g_scaleInitialized) return;
  if(!InpUIScaleAuto) return;
  g_scaleInitialized = true;
}

int ReadM30SeparatorTimes(datetime &times[])
{
  ArrayResize(times, 0);
  int count = 0;

  int total = ObjectsTotal(0, 0, -1);
  for(int i=0; i<total; i++)
  {
    string name = ObjectName(0, i);
    if(name == "") continue;

    int type = (int)ObjectGetInteger(0, name, OBJPROP_TYPE);
    if(type != OBJ_VLINE) continue;

    bool isM30Separator = false;
    if(StringFind(name, "SCCMW", 0) >= 0) isM30Separator = true;
    if(StringFind(name, "SEP", 0) >= 0)   isM30Separator = true;
    if(StringFind(name, "UNIT", 0) >= 0)  isM30Separator = true;

    if(!isM30Separator) continue;

    datetime t = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME);
    if(t <= 0) continue;

    ArrayResize(times, count+1);
    times[count++] = t;
  }

  return(count);
}

int NormalizeM30SeparatorTimes(datetime &times[])
{
  int n = ArraySize(times);
  if(n <= 1) return(n);

  for(int a=0; a<n-1; a++)
    for(int b=a+1; b<n; b++)
      if(times[a] > times[b])
      {
        datetime tmp = times[a];
        times[a] = times[b];
        times[b] = tmp;
      }

  datetime clean[];
  int cn = 0;
  for(int i=0; i<n; i++)
  {
    if(cn == 0 || clean[cn-1] != times[i])
    {
      ArrayResize(clean, cn+1);
      clean[cn++] = times[i];
    }
  }

  ArrayResize(times, cn);
  for(int k=0; k<cn; k++) times[k] = clean[k];
  return(cn);
}

bool IsValidM30Boundary(datetime s, datetime e)
{
  if(e <= s) return(false);

  int sh1 = iBarShift(NULL, PERIOD_M30, s, false);
  int sh2 = iBarShift(NULL, PERIOD_M30, e, false);
  if(sh1 < 0 || sh2 < 0) return(false);

  int bars = MathAbs(sh1 - sh2);
  if(bars < 1) return(false);

  int mins = (int)((e - s) / 60);
  if(mins < 600 || mins > 900) return(false);

  return(true);
}

int BuildM30BoundariesFromSeparators(datetime fromTime, datetime toTime, UnitBoundary &B[])
{
  ArrayResize(B, 0);

  datetime sepTimes[];
  int n = ReadM30SeparatorTimes(sepTimes);
  if(n <= 1) return(0);

  n = NormalizeM30SeparatorTimes(sepTimes);
  if(n <= 1) return(0);

  int count = 0;
  for(int i=0; i<n-1; i++)
  {
    datetime s = sepTimes[i];
    datetime e = sepTimes[i+1];

    if(e <= s) continue;
    if(e < fromTime || s > toTime) continue;
    if(!IsValidM30Boundary(s, e)) continue;

    ArrayResize(B, count+1);
    B[count].startTime = s;
    B[count].endTime   = e;
    count++;
  }

  return(count);
}

int ResolveBoundaries_M30_Fallback(datetime fromTime, datetime toTime, UnitBoundary &B[])
{
  ArrayResize(B, 0);

  int shFrom = iBarShift(NULL, PERIOD_M30, fromTime, false);
  int shTo   = iBarShift(NULL, PERIOD_M30, toTime, false);
  if(shFrom < 0 || shTo < 0) return(0);

  int oldest = MathMax(shFrom, shTo);
  int newest = MathMin(shFrom, shTo);

  datetime anchors[];
  int ac = 0;

  for(int s=oldest; s>=newest; s--)
  {
    datetime bt = iTime(NULL, PERIOD_M30, s);
    MqlDateTime dt; TimeToStruct(bt, dt);

    if(dt.min == 0 && (dt.hour == 0 || dt.hour == 12))
    {
      ArrayResize(anchors, ac+1);
      anchors[ac++] = bt;
    }
  }

  if(ac <= 1) return(0);
  NormalizeM30SeparatorTimes(anchors);

  int bn = 0;
  for(int i=0; i<ac-1; i++)
  {
    datetime s = anchors[i];
    datetime e = anchors[i+1];
    if(!IsValidM30Boundary(s, e)) continue;

    ArrayResize(B, bn+1);
    B[bn].startTime = s;
    B[bn].endTime   = e;
    bn++;
  }

  return(bn);
}

int ResolveUnitBoundariesForCache(datetime fromTime, datetime toTime, UnitBoundary &B[])
{
  ArrayResize(B, 0);

  if(Period() == PERIOD_M30)
  {
    int bn = BuildM30BoundariesFromSeparators(fromTime, toTime, B);
    if(bn > 0) return(bn);
    return ResolveBoundaries_M30_Fallback(fromTime, toTime, B);
  }

  UnitInfo tmp[];
  int maxUnits = GetCacheMaxUnits();
  int n = BuildUnits(tmp, maxUnits, fromTime, toTime);
  if(n <= 0) return(0);

  ArrayResize(B, n);
  int bn=0;
  for(int i=0; i<n; i++)
  {
    if(!tmp[i].valid) continue;
    B[bn].startTime = tmp[i].start;
    B[bn].endTime   = tmp[i].end;
    bn++;
  }
  ArrayResize(B, bn);
  return(bn);
}

bool BuildUnitFromBoundary(const UnitBoundary &b, UnitInfo &u)
{
  return BuildUnit(b.startTime, b.endTime, u);
}

void RebuildUnitCache()
{
  ArrayResize(g_unitCache, 0);
  g_unitCacheCount = 0;
  ArrayResize(g_angleCache, 0);
  g_angleCacheCount = 0;
  g_lastProcessedUnitId = -1;

  datetime visL=0, visR=0;
  if(InpDynamicVisible)
    GetVisibleTimeRange(visL, visR);

  datetime buildFrom = (visL > 0 ? visL : 0);
  datetime buildTo   = (visR > 0 ? visR : Time[0]);

  UnitBoundary B[];
  int bn = ResolveUnitBoundariesForCache(buildFrom, buildTo, B);
  if(bn <= 0) return;

  for(int i=0; i<bn; i++)
  {
    UnitInfo u;
    if(!BuildUnitFromBoundary(B[i], u))
      continue;

    u.id = (int)u.start;
    u.processedSequentially = FormationUnitProcessedByCache(u.id);

    ArrayResize(g_unitCache, g_unitCacheCount+1);
    g_unitCache[g_unitCacheCount] = u;
    g_unitCacheCount++;
  }

  NormalizeUnitCache();
}

bool AngleResultExists(int u2Id, int u1Id)
{
  for(int i=0; i<g_angleCacheCount; i++)
    if(g_angleCache[i].valid && g_angleCache[i].u2Id == u2Id && g_angleCache[i].u1Id == u1Id)
      return(true);
  return(false);
}

bool FormationUnitProcessedByCache(int u1Id)
{
  for(int i=0; i<g_angleCacheCount; i++)
    if(g_angleCache[i].valid && g_angleCache[i].u1Id == u1Id)
      return(true);
  return(false);
}

void MergeOlderUnitsIntoCache(UnitInfo &tmp[], int n)
{
  if(n <= 0) return;
  for(int i=n-1; i>=0; i--)
  {
    UnitInfo u = tmp[i];
    u.id = (int)u.start;
    u.processedSequentially = FormationUnitProcessedByCache(u.id);
    bool exists = false;
    for(int j=0; j<g_unitCacheCount; j++)
    {
      if(g_unitCache[j].id == u.id) { exists = true; break; }
    }
    if(exists) continue;
    int old = g_unitCacheCount;
    ArrayResize(g_unitCache, old+1);
    g_unitCache[old] = u;
    g_unitCache[old].processedSequentially = FormationUnitProcessedByCache(u.id);
    g_unitCacheCount = old+1;
  }
  NormalizeUnitCache();
}

void EnsureCacheCoversVisibleRange(datetime tLeft, datetime tRight)
{
  if(g_unitCacheCount <= 0)
  {
    RebuildUnitCache();
    return;
  }

  bool needLeft  = (tLeft  > 0 && (g_cacheLeftTime == 0 || tLeft  < g_cacheLeftTime));
  bool needRight = (tRight > 0 && (g_cacheRightTime == 0 || tRight > g_cacheRightTime));
  if(!needLeft && !needRight) return;

  if(needLeft)
  {
    UnitBoundary B[];
    int bn = ResolveUnitBoundariesForCache(tLeft, g_cacheLeftTime, B);
    if(bn > 0)
    {
      UnitInfo tmp[];
      int tn = 0;
      ArrayResize(tmp, 0);
      for(int i=0; i<bn; i++)
      {
        UnitInfo u;
        if(!BuildUnitFromBoundary(B[i], u)) continue;
        u.id = (int)u.start;
        u.processedSequentially = FormationUnitProcessedByCache(u.id);
        ArrayResize(tmp, tn+1);
        tmp[tn++] = u;
      }
      MergeOlderUnitsIntoCache(tmp, tn);
    }
  }

  if(needRight)
  {
    UnitBoundary B[];
    int bn = ResolveUnitBoundariesForCache(g_cacheRightTime, tRight, B);
    if(bn > 0)
    {
      UnitInfo merged[];
      int m=0;
      ArrayResize(merged, 0);

      for(int i=0; i<bn; i++)
      {
        UnitInfo u;
        if(!BuildUnitFromBoundary(B[i], u)) continue;
        u.id = (int)u.start;
        u.processedSequentially = FormationUnitProcessedByCache(u.id);
        ArrayResize(merged, m+1);
        merged[m++] = u;
      }

      for(int j=0; j<g_unitCacheCount; j++)
      {
        UnitInfo u = g_unitCache[j];
        bool exists=false;
        for(int z=0; z<m; z++)
        {
          if(merged[z].id == u.id) { exists=true; break; }
        }
        if(exists) continue;
        ArrayResize(merged, m+1);
        merged[m++] = u;
      }

      ArrayResize(g_unitCache, m);
      for(int q=0; q<m; q++) g_unitCache[q] = merged[q];
      g_unitCacheCount = m;
      NormalizeUnitCache();
    }
  }
}

void GetVisibleUnitIndexWindow(UnitInfo &U[], int n, datetime tLeft, datetime tRight, int padUnits, int &outFirst, int &outLast)
{
  outFirst = 1;
  outLast  = MathMax(1, n-2);
  if(n < 3 || tLeft<=0 || tRight<=0) return;

  int minIdx = 1000000;
  int maxIdx = -1;
  for(int k=1; k<=n-2; k++)
  {
    UnitInfo formU = U[k];
    UnitInfo refU  = U[k+1];
    if(!formU.valid || !refU.valid) continue;

    // v11/v12-style visible-range behavior:
    // only classify/draw pairs whose visible time span intersects the current screen range.
    datetime pairLeft  = refU.start;
    datetime pairRight = formU.end;
    if(pairRight < tLeft || pairLeft > tRight) continue;

    if(k < minIdx) minIdx = k;
    if(k > maxIdx) maxIdx = k;
  }

  if(maxIdx < 0)
  {
    outFirst = 1;
    outLast  = 0;
    return;
  }

  // padUnits intentionally ignored in G3 visible-mode: only what is visible on screen.
  outFirst = MathMax(1, minIdx);
  outLast  = MathMin(n-2, maxIdx);
}

bool GetDynamicBuildWindow(datetime &buildFrom, datetime &buildTo, datetime &visLeft, datetime &visRight)
{
  buildFrom = 0; buildTo = Time[0]; visLeft = 0; visRight = 0;
  if(!InpDynamicVisible) return(false);
  GetVisibleTimeRange(visLeft, visRight);
  if(visLeft <= 0 || visRight <= 0) return(false);

  int padSec = g_unitSeconds;
  if(padSec <= 0) padSec = PeriodSeconds(Period());
  if(padSec <= 0) padSec = 60;

  // Wider buffer around the visible window so units just outside the screen are still built
  // and can participate in angle detection when the user pans left/right.
  buildFrom = visLeft  - 20 * padSec;
  buildTo   = visRight + 10 * padSec;
  if(buildFrom < 0) buildFrom = 0;
  if(buildTo <= 0) buildTo = visRight;
  return(true);
}

int CalcVisibleUnitBudget(datetime tLeft, datetime tRight)
{
  EnsureValidUnitSeconds();
  if(tLeft<=0 || tRight<=0)
    return(MathMax(3, InpUnitsToShow));

  long span = (long)tRight - (long)tLeft;
  if(span < 0) span = -span;

  int baseSec = g_unitSeconds;
  if(baseSec <= 0)
    baseSec = PeriodSeconds(Period());
  if(baseSec <= 0)
    baseSec = 60;

  // Build significantly more units than the theoretical visible count so dynamic panning can
  // discover angles on newly visible units without feeling capped to a small historical window.
  int budget = (int)MathCeil((double)span / (double)baseSec);
  budget = budget * 3 + 20;
  if(budget < 12) budget = 12;
  if(budget < InpUnitsToShow) budget = InpUnitsToShow;
  if(budget > 2500) budget = 2500;
  return(budget);
}



// ---- Imported support functions from v47 for compile completeness ----

int GetUnitOptions(int tf, int &opts[])
{
  ArrayResize(opts, 0);
  if(tf == PERIOD_M1)
  {
    int a[4]={15*60,30*60,60*60,2*60*60};
    ArrayResize(opts,4);
    for(int i=0;i<4;i++) opts[i]=a[i];
    return(4);
  }
  if(tf == PERIOD_M5)
  {
    int a[2]={3*60*60,4*60*60};
    ArrayResize(opts,2);
    for(int i=0;i<2;i++) opts[i]=a[i];
    return(2);
  }
  if(tf == PERIOD_M15)
  {
    int a[2]={6*60*60,8*60*60};
    ArrayResize(opts,2);
    for(int i=0;i<2;i++) opts[i]=a[i];
    return(2);
  }
  if(tf == PERIOD_M30)
  {
    int a[1]={12*60*60};
    ArrayResize(opts,1); opts[0]=a[0]; return(1);
  }
  if(tf == PERIOD_H1)
  {
    int a[1]={24*60*60};
    ArrayResize(opts,1); opts[0]=a[0]; return(1);
  }
  if(tf == PERIOD_H4)
  {
    int a[2]={7*24*60*60,14*24*60*60};
    ArrayResize(opts,2); opts[0]=a[0]; opts[1]=a[1]; return(2);
  }
  if(tf == PERIOD_D1)
  {
    int a[4]={30*24*60*60,60*24*60*60,90*24*60*60,120*24*60*60};
    ArrayResize(opts,4); for(int i=0;i<4;i++) opts[i]=a[i]; return(4);
  }
  if(tf == PERIOD_W1)
  {
    int a[1]={6*30*24*60*60};
    ArrayResize(opts,1); opts[0]=a[0]; return(1);
  }
  if(tf == PERIOD_MN1)
  {
    int a[4]={365*24*60*60,2*365*24*60*60,5*365*24*60*60,10*365*24*60*60};
    ArrayResize(opts,4); for(int i=0;i<4;i++) opts[i]=a[i]; return(4);
  }
  int a0[1]={60*60};
  ArrayResize(opts,1); opts[0]=a0[0]; return(1);
}


bool TrySyncUnitFromSCCMWPanel()
{
  if(!InpAutoFollowSCCMWPanel) return(false);
  static int s_lastSyncPeriod = -1;
  uint now = GetTickCount();
  int curTf = Period();

  // Keep syncing lightweight: only force immediate sync when timeframe changes,
  // otherwise throttle panel scans aggressively.
  int minWait = MathMax(1200, InpAutoFollowCheckMs);
  if(s_lastSyncPeriod == curTf && (now - g_lastUnitSyncMs) < (uint)minWait) return(false);

  s_lastSyncPeriod = curTf;
  g_lastUnitSyncMs = now;

  int sec = -1;
  if(StringLen(InpSCCMWUnitObjectName) > 0 && ObjectFind(0, InpSCCMWUnitObjectName) >= 0)
  {
    string t = ObjectGetString(0, InpSCCMWUnitObjectName, OBJPROP_TEXT);
    sec = ParseUnitSecondsFromText(t);
  }
  else
  {
    // Strategy 2: scan text/label objects for "UNIT:" keyword
    int total = ObjectsTotal();
    int scan = MathMin(total, 250);
    for(int i=total-1; i>=0 && scan>0; i--, scan--)
    {
      string name = ObjectName(i);
      int type = ObjectType(name);
      if(type!=OBJ_LABEL && type!=OBJ_TEXT) continue;
      string t = ObjectGetString(0, name, OBJPROP_TEXT);
      if(StringFind(ToUpper(t), "UNIT") < 0) continue;
      int tmp = ParseUnitSecondsFromText(t);
      if(tmp > 0) { sec = tmp; break; }
    }

    // Strategy 3: scan SCCMW P_NAME_ objects (text like "6H (الوحدة الزمنية)")
    if(sec <= 0)
    {
      int opts[]; int nOpts = GetUnitOptions(Period(), opts);
      for(int i=ObjectsTotal()-1; i>=0; i--)
      {
        string nm = ObjectName(i);
        if(StringFind(nm, "P_NAME_") < 0) continue;
        int tp = ObjectType(nm);
        if(tp!=OBJ_LABEL && tp!=OBJ_TEXT) continue;
        string t = ObjectGetString(0, nm, OBJPROP_TEXT);
        int tmp = ParseUnitSecondsFromSCCMWName(t);
        if(tmp <= 0) continue;
        for(int j=0; j<nOpts; j++)
          if(opts[j]==tmp) { sec=tmp; break; }
        if(sec > 0) break;
      }
    }
  }

  if(sec > 0 && sec != g_unitSeconds)
  {
    g_unitSeconds = sec;
    EnsureValidUnitSeconds();
    return(true);
  }
  return(false);
}


datetime SCCMW_TM_FixTimeGaps(datetime t, bool fix=false)
{
  int currentBar = iBarShift(Symbol(), Period(), t);
  if(currentBar < 0) currentBar = iBarShift(Symbol(), Period(), t, true);
  if(currentBar < 0) return(t);

  datetime realBarTime = iTime(Symbol(), Period(), currentBar--);
  int safe = 30;
  while(safe > 0 && realBarTime < t && currentBar >= 0)
  {
    safe--;
    realBarTime = iTime(Symbol(), Period(), currentBar--);
  }

  if(g_tmHasSunday && TimeDayOfWeek(t) == 1)
  {
    int safer = 1;
    int probe = currentBar + safer;
    if(probe < 0) probe = 0;
    realBarTime = iTime(Symbol(), Period(), probe);
    while(safer < 5 && TimeDayOfWeek(realBarTime) != 0 && TimeDayOfWeek(realBarTime) != 5)
    {
      safer++;
      probe = currentBar + safer;
      if(probe < 0) probe = 0;
      realBarTime = iTime(Symbol(), Period(), probe);
    }
  }
  return(realBarTime);
}


datetime SCCMW_TM_GetFirstPeriodForAnchor(datetime anchor)
{
  SCCMW_TM_Init();
  int tf = Period();
  int unitTF = SCCMW_GetUnitTF(tf);
  int barsAsUnit = SCCMW_GetBarsAsUnit(tf);
  if(unitTF <= 0 || barsAsUnit <= 0) return(anchor);

  int shift = iBarShift(Symbol(), unitTF, anchor);
  if(shift < 0) shift = iBarShift(Symbol(), unitTF, anchor, true);
  if(shift < 0) shift = 0;
  int sf = shift / barsAsUnit;
  datetime frst = iTime(Symbol(), unitTF, sf * barsAsUnit);
  if(frst <= 0) frst = anchor;

  string thisdate = TimeToStr(frst, TIME_DATE);
  int temp_hour = TimeHour(frst);

  switch(tf)
  {
    case PERIOD_M1:
      if(g_unitSeconds == 2*60*60)
      {
        int thour = (int)TimeHour(g_tmSessionFrom);
        if(MathMod(temp_hour - thour + 24, 2) != 0) frst -= PeriodSeconds(PERIOD_H1);
      }
      return(frst);

    case PERIOD_M5:
      if(g_unitSeconds == 3*60*60)
      {
        if(g_tmStartAfterHour)
        {
          if(temp_hour>=22) return(StringToTime(thisdate+" 22:00"));
          if(temp_hour>=19) return(StringToTime(thisdate+" 19:00"));
          if(temp_hour>=16) return(StringToTime(thisdate+" 16:00"));
          if(temp_hour>=13) return(StringToTime(thisdate+" 13:00"));
          if(temp_hour>=10) return(StringToTime(thisdate+" 10:00"));
          if(temp_hour>=7)  return(StringToTime(thisdate+" 07:00"));
          if(temp_hour>=4)  return(StringToTime(thisdate+" 04:00"));
          return(StringToTime(thisdate+" 01:00"));
        }
        else
        {
          if(temp_hour>=21) return(StringToTime(thisdate+" 21:00"));
          if(temp_hour>=18) return(StringToTime(thisdate+" 18:00"));
          if(temp_hour>=15) return(StringToTime(thisdate+" 15:00"));
          if(temp_hour>=12) return(StringToTime(thisdate+" 12:00"));
          if(temp_hour>=9)  return(StringToTime(thisdate+" 09:00"));
          if(temp_hour>=6)  return(StringToTime(thisdate+" 06:00"));
          if(temp_hour>=3)  return(StringToTime(thisdate+" 03:00"));
          return(StringToTime(thisdate+" 00:00"));
        }
      }
      break;

    case PERIOD_M15:
      if(g_tmStartAfterHour)
      {
        if(g_unitSeconds == 6*60*60)
        {
          if(temp_hour>=19) return(StringToTime(thisdate+" 19:00"));
          if(temp_hour>=13) return(StringToTime(thisdate+" 13:00"));
          if(temp_hour>=7)  return(StringToTime(thisdate+" 07:00"));
          return(StringToTime(thisdate+" 01:00"));
        }
        else
        {
          if(temp_hour>=17) return(StringToTime(thisdate+" 17:00"));
          if(temp_hour>=9)  return(StringToTime(thisdate+" 09:00"));
          return(StringToTime(thisdate+" 01:00"));
        }
      }
      else
      {
        if(g_unitSeconds == 6*60*60)
        {
          if(temp_hour>=18) return(StringToTime(thisdate+" 18:00"));
          if(temp_hour>=12) return(StringToTime(thisdate+" 12:00"));
          if(temp_hour>=6)  return(StringToTime(thisdate+" 06:00"));
          return(StringToTime(thisdate+" 00:00"));
        }
        else
        {
          if(temp_hour>=16) return(StringToTime(thisdate+" 16:00"));
          if(temp_hour>=8)  return(StringToTime(thisdate+" 08:00"));
          return(StringToTime(thisdate+" 00:00"));
        }
      }
      break;

    case PERIOD_M30:
      if(g_tmStartAfterHour)
      {
        if(temp_hour>=13) return(StringToTime(thisdate+" 13:00"));
        return(StringToTime(thisdate+" 01:00"));
      }
      else
      {
        if(temp_hour>=12) return(StringToTime(thisdate+" 12:00"));
        return(StringToTime(thisdate+" 00:00"));
      }

    case PERIOD_H1:
      if(TimeDayOfWeek(frst)==0) frst += PeriodSeconds(PERIOD_D1);
      return(frst);

    case PERIOD_D1:
    {
      int temp_month = TimeMonth(frst);
      int y = TimeYear(frst);
      string ys = IntegerToString(y);
      if(g_unitSeconds >= 120*24*60*60)
      {
        if(temp_month>=9) return(StringToTime(ys+".9.1 00:00"));
        if(temp_month>=5) return(StringToTime(ys+".5.1 00:00"));
        return(StringToTime(ys+".1.1 00:00"));
      }
      if(g_unitSeconds >= 90*24*60*60)
      {
        if(temp_month>=10) return(StringToTime(ys+".10.1 00:00"));
        if(temp_month>=7)  return(StringToTime(ys+".7.1 00:00"));
        if(temp_month>=4)  return(StringToTime(ys+".4.1 00:00"));
        return(StringToTime(ys+".1.1 00:00"));
      }
      if(g_unitSeconds >= 60*24*60*60)
      {
        if(temp_month>=11) return(StringToTime(ys+".11.1 00:00"));
        if(temp_month>=9)  return(StringToTime(ys+".9.1 00:00"));
        if(temp_month>=7)  return(StringToTime(ys+".7.1 00:00"));
        if(temp_month>=5)  return(StringToTime(ys+".5.1 00:00"));
        if(temp_month>=3)  return(StringToTime(ys+".3.1 00:00"));
        return(StringToTime(ys+".1.1 00:00"));
      }
      return(frst);
    }

    case PERIOD_W1:
    {
      int temp_month = TimeMonth(frst);
      string ys = IntegerToString(TimeYear(frst));
      if(temp_month>=6) return(StringToTime(ys+".7.1 00:00"));
      return(StringToTime(ys+".1.1 00:00"));
    }

    case PERIOD_MN1:
    {
      int thisyear = TimeYear(frst);
      int div = 12;
      if(g_unitSeconds >= 10*365*24*60*60) div = 10;
      else if(g_unitSeconds >= 5*365*24*60*60) div = 5;
      else if(g_unitSeconds >= 2*365*24*60*60) div = 2;
      else div = 1;
      if(div > 1)
      {
        int mod = (int)MathMod(thisyear, div);
        thisyear -= mod;
      }
      return(StringToTime(IntegerToString(thisyear)+".1.1 00:00"));
    }
  }
  return(frst);
}


datetime SCCMW_TM_GetNextPeriod(datetime last_time, bool reverse=false)
{
  SCCMW_TM_Init();
  int tf = Period();
  int unitTF = SCCMW_GetUnitTF(tf);
  int barsAsUnit = SCCMW_GetBarsAsUnit(tf);
  if(unitTF <= 0 || barsAsUnit <= 0) return(last_time);

  int current_bar = iBarShift(Symbol(), tf, last_time);
  int current_bar_f = iBarShift(Symbol(), unitTF, last_time);
  if(current_bar < 0 || current_bar_f < 0) return(last_time);

  int next_bar_f = reverse && current_bar>1 ? current_bar_f-barsAsUnit : current_bar_f+barsAsUnit;
  datetime next_unit = iTime(Symbol(), unitTF, next_bar_f);
  if(next_unit <= 0) return(last_time);

  switch(tf)
  {
    case PERIOD_H1:
    {
      if(TimeDayOfWeek(next_unit) == 0)
      {
        datetime t2 = iTime(Symbol(), unitTF, next_bar_f + 2);
        if(t2 > 0 && TimeDayOfWeek(t2) == 5) next_unit = t2;
      }
      return(next_unit);
    }
    case PERIOD_M5:
      if(g_unitSeconds == 3*60*60 && g_tmStartAfterHour)
      {
        int nh = TimeHour(next_unit);
        if(nh==21||nh==18||nh==15||nh==12||nh==9||nh==6||nh==3||nh==0) return(next_unit + PeriodSeconds(PERIOD_H1));
      }
      return(next_unit);

    case PERIOD_M15:
      if(g_tmStartAfterHour)
      {
        int nh = TimeHour(next_unit);
        if(g_unitSeconds == 6*60*60)
        {
          if(nh==18||nh==12||nh==6||nh==0) return(next_unit + PeriodSeconds(PERIOD_H1));
        }
        else
        {
          if(nh==16||nh==8||nh==0) return(next_unit + PeriodSeconds(PERIOD_H1));
        }
      }
      return(next_unit);

    case PERIOD_M30:
      if(g_tmStartAfterHour)
      {
        int nh = TimeHour(next_unit);
        if(nh==12||nh==0) return(next_unit + PeriodSeconds(PERIOD_H1));
      }
      return(next_unit);

    case PERIOD_MN1:
    {
      int year = TimeYear(iTime(Symbol(), tf, current_bar));
      int div = 1;
      if(g_unitSeconds >= 10*365*24*60*60) div = 10;
      else if(g_unitSeconds >= 5*365*24*60*60) div = 5;
      else if(g_unitSeconds >= 2*365*24*60*60) div = 2;
      if(reverse) year += div;
      else year -= div;
      return(StringToTime(IntegerToString(year)+".1.1 00:00"));
    }
  }
  return(next_unit);
}
//-------------------- Sequential angle result cache --------------------
void SaveAngleResult(const AngleResult &r)
{
  for(int i=0; i<g_angleCacheCount; i++)
  {
    if(g_angleCache[i].u1Id == r.u1Id && g_angleCache[i].u2Id == r.u2Id)
    {
      g_angleCache[i] = r;
      Mon_OnAngleSaved(r);         // signal hook
      return;
    }
  }
  int n = g_angleCacheCount;
  ArrayResize(g_angleCache, n + 1);
  g_angleCache[n] = r;
  g_angleCacheCount = n + 1;
  Mon_OnAngleSaved(r);             // signal hook
}

bool HasAngleResultForU1(const int u1Id)
{
  for(int i=0; i<g_angleCacheCount; i++)
    if(g_angleCache[i].valid && g_angleCache[i].u1Id == u1Id)
      return(true);
  return(false);
}

bool IsCandidateStillValidByRange(UnitInfo &refU, UnitInfo &formU, int dirState)
{
  double tol = MathMax(0, InpTouchTolerancePoints) * Point + Point*0.2;

  if(dirState == 1)
  {
    if(formU.lo <= refU.level38 - tol)
      return(false);
    return(true);
  }

  if(dirState == -1)
  {
    if(formU.hi >= refU.level61 + tol)
      return(false);
    return(true);
  }

  return(false);
}

void DrawAngleVerticalLeg(string name, datetime t, double pLow, double pHigh, color clr, int width=1)
{
  DrawVSegment(name, t, pLow, pHigh, clr, width, true);
  StoreCloneMeta(name, t, pLow, t, pHigh);
}

bool ShouldRenderVerticalLegsForAngle(AngleResult &ar)
{
  if(!InpShowAngleVerticalLegs) return(false);
  if(ar.confirmed) return(true);
  if(ar.unconfirmed && InpShowVerticalLegsForUnconfirmed) return(true);
  return(false);
}

bool ProcessPairSequentially(UnitInfo &refU, UnitInfo &formU)
{
  if(!refU.valid || !formU.valid) return(false);

  SupervisorFacts sf;
  if(!BuildSupervisorFacts(refU, formU, sf)) return(false);

  string cls = SupervisorDecideAngle(sf);
  bool candBuy=false, candSell=false;
  bool hasCandidate = IsModernCandidate(sf, candBuy, candSell);
  bool hasConfirmed = (cls != "");

  if(!hasConfirmed && hasCandidate)
  {
    if(!IsCandidateStillValidByRange(refU, formU, sf.dir.state))
      hasCandidate = false;
  }

  if(!hasConfirmed && !hasCandidate)
    return(false);

  AngleResult ar;
  ar.valid       = true;
  ar.angleName   = cls;
  if(cls != "") ar.classText = cls;
  else if(hasCandidate) ar.classText = "";
  else ar.classText = "";
  ar.dirState    = sf.dir.state;
  ar.u1Id        = formU.id;
  ar.u2Id        = refU.id;
  ar.u1Start     = formU.start;
  ar.u2Start     = refU.start;
  ar.u1End       = formU.end;
  ar.u2End       = refU.end;
  ar.u1High      = formU.hi;
  ar.u1Low       = formU.lo;
  ar.u2High      = refU.hi;
  ar.u2Low       = refU.lo;
  ar.candidateBuy  = candBuy;
  ar.candidateSell = candSell;
  ar.confirmed   = IsAngleConfirmedModern(sf, cls);
  ar.unconfirmed = (!ar.confirmed && hasCandidate);
  ar.correctionPct   = CalcCorrectionPercent(refU, formU, sf.dir);
  ar.correctionValue = ar.correctionPct;
  ar.u1LegColor = clrNONE;
  ar.u2LegColor = clrNONE;

  if(ar.confirmed)
  {
    if(ar.dirState == 1) ar.angleDisplayText = "Confirmed angle \"BUY\"";
    else ar.angleDisplayText = "Confirmed angle \"SELL\"";
  }
  else if(ar.unconfirmed)
  {
    if(ar.dirState == 1) ar.angleDisplayText = "Unconfirmed angle \"BUY\"";
    else ar.angleDisplayText = "Unconfirmed angle \"SELL\"";
  }
  else
  {
    ar.angleDisplayText = "";
  }

  if(ar.dirState == 1)
  {
    ar.drawT1 = refU.start;
    ar.drawP1 = refU.hi;
    ar.drawT2 = formU.start;
    ar.drawP2 = formU.lo;
  }
  else if(ar.dirState == -1)
  {
    ar.drawT1 = refU.start;
    ar.drawP1 = refU.lo;
    ar.drawT2 = formU.start;
    ar.drawP2 = formU.hi;
  }
  else
  {
    return(false);
  }

  SaveAngleResult(ar);
  return(true);
}

void ProcessNewClosedUnitSequentially()
{
  if(g_unitCacheCount < 3) return;

  NormalizeUnitCache();

  for(int k = g_unitCacheCount - 2; k >= 1; k--)
  {
    if(!g_unitCache[k].valid || !g_unitCache[k+1].valid) continue;
    if(g_unitCache[k].processedSequentially) continue;

    UnitInfo U1 = g_unitCache[k];
    UnitInfo U2 = g_unitCache[k+1];
    ProcessPairSequentially(U2, U1);
    g_unitCache[k].processedSequentially = true;
    g_lastProcessedUnitId = g_unitCache[k].id;
  }
}

void ProcessUnprocessedHistoricalPairsInRange(datetime tLeft, datetime tRight)
{
  if(g_unitCacheCount < 3) return;

  NormalizeUnitCache();

  for(int k = 1; k <= g_unitCacheCount - 2; k++)
  {
    if(!g_unitCache[k].valid || !g_unitCache[k+1].valid) continue;

    UnitInfo formU = g_unitCache[k];
    UnitInfo refU  = g_unitCache[k+1];
    datetime pairLeft = refU.start;
    datetime pairRight = formU.end;
    if(pairRight < tLeft || pairLeft > tRight) continue;
    if(g_unitCache[k].processedSequentially || AngleResultExists(refU.id, formU.id))
    {
      g_unitCache[k].processedSequentially = true;
      continue;
    }

    ProcessPairSequentially(refU, formU);
    g_unitCache[k].processedSequentially = true;
  }
}



bool HasVisibleBullishAngleOnUnit(int unitId, datetime tLeft, datetime tRight)
{
  for(int i=0; i<g_angleCacheCount; i++)
  {
    if(!g_angleCache[i].valid) continue;
    if(g_angleCache[i].dirState != 1) continue;

    datetime leftT  = MathMin(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    datetime rightT = MathMax(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    if(tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;

    if(g_angleCache[i].u1Id == unitId || g_angleCache[i].u2Id == unitId)
      return(true);
  }
  return(false);
}

bool HasVisibleBearishAngleOnUnit(int unitId, datetime tLeft, datetime tRight)
{
  for(int i=0; i<g_angleCacheCount; i++)
  {
    if(!g_angleCache[i].valid) continue;
    if(g_angleCache[i].dirState != -1) continue;

    datetime leftT  = MathMin(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    datetime rightT = MathMax(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    if(tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;

    if(g_angleCache[i].u1Id == unitId || g_angleCache[i].u2Id == unitId)
      return(true);
  }
  return(false);
}

bool HasVisibleBullishCandidateOnUnit(int unitId, datetime tLeft, datetime tRight)
{
  for(int i=0; i<g_angleCacheCount; i++)
  {
    if(!g_angleCache[i].valid || !g_angleCache[i].candidateBuy) continue;
    datetime leftT  = MathMin(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    datetime rightT = MathMax(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    if(tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;
    if(g_angleCache[i].u1Id == unitId || g_angleCache[i].u2Id == unitId) return(true);
  }
  return(false);
}

bool HasVisibleBearishCandidateOnUnit(int unitId, datetime tLeft, datetime tRight)
{
  for(int i=0; i<g_angleCacheCount; i++)
  {
    if(!g_angleCache[i].valid || !g_angleCache[i].candidateSell) continue;
    datetime leftT  = MathMin(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    datetime rightT = MathMax(g_angleCache[i].drawT1, g_angleCache[i].drawT2);
    if(tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;
    if(g_angleCache[i].u1Id == unitId || g_angleCache[i].u2Id == unitId) return(true);
  }
  return(false);
}


string MakeAngleObjectName(const AngleResult &ar)
{
  return(StringFormat("%sANG_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string MakeLegRefName(const AngleResult &ar)
{
  return(StringFormat("%sLEGREF_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string MakeLegForName(const AngleResult &ar)
{
  return(StringFormat("%sLEGFOR_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string MakeAngleTextName(const AngleResult &ar)
{
  return(StringFormat("%sANGTXT_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string MakeClassTextName(const AngleResult &ar)
{
  return(StringFormat("%sCLS_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string MakeCorrTextName(const AngleResult &ar)
{
  return(StringFormat("%sCORR_%d_%d", g_tfPrefix, ar.u2Id, ar.u1Id));
}

string SerializeAngleMeta(const AngleResult &ar)
{
  return(StringFormat("ANGDATA|%d|%s|%d|%d|%d|%d|%d|%.10f|%d|%.10f|%d|%d|%.10f|%.10f|%.10f|%.10f",
    ar.dirState, ar.classText, (ar.confirmed?1:0), (ar.unconfirmed?1:0),
    (ar.candidateBuy?1:0), (ar.candidateSell?1:0),
    (int)ar.drawT1, ar.drawP1, (int)ar.drawT2, ar.drawP2,
    (int)ar.u1Start, (int)ar.u2Start, ar.u1High, ar.u1Low, ar.u2High, ar.u2Low));
}

bool ParseAngleMeta(const string meta, AngleResult &ar)
{
  string parts[];
  int n = StringSplit(meta, 124, parts);
  if(n < 17) return(false);
  if(parts[0] != "ANGDATA") return(false);

  ar.valid = true;
  ar.dirState = (int)StringToInteger(parts[1]);
  ar.classText = parts[2];
  ar.angleName = ar.classText;
  ar.confirmed = (StringToInteger(parts[3]) != 0);
  ar.unconfirmed = (StringToInteger(parts[4]) != 0);
  ar.candidateBuy = (StringToInteger(parts[5]) != 0);
  ar.candidateSell = (StringToInteger(parts[6]) != 0);
  ar.drawT1 = (datetime)StringToInteger(parts[7]);
  ar.drawP1 = StringToDouble(parts[8]);
  ar.drawT2 = (datetime)StringToInteger(parts[9]);
  ar.drawP2 = StringToDouble(parts[10]);
  ar.u1Start = (datetime)StringToInteger(parts[11]);
  ar.u2Start = (datetime)StringToInteger(parts[12]);
  ar.u1High = StringToDouble(parts[13]);
  ar.u1Low = StringToDouble(parts[14]);
  ar.u2High = StringToDouble(parts[15]);
  ar.u2Low = StringToDouble(parts[16]);
  ar.u1Id = (int)ar.u1Start;
  ar.u2Id = (int)ar.u2Start;
  ar.angleDisplayText = ar.confirmed ? (ar.dirState==1 ? "Confirmed angle \"BUY\"" : "Confirmed angle \"SELL\"") : (ar.unconfirmed ? (ar.dirState==1 ? "Unconfirmed angle \"BUY\"" : "Unconfirmed angle \"SELL\"") : "");
  ar.correctionValue = 0.0;
  ar.correctionPct = 0.0;
  return(true);
}

void SaveAngleMetaToObject(const string objName, const AngleResult &ar)
{
  if(ObjectFind(0, objName) >= 0)
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, SerializeAngleMeta(ar));
}

bool LoadAngleMetaFromObject(const string objName, AngleResult &ar)
{
  if(ObjectFind(0, objName) < 0) return(false);
  string meta = ObjectGetString(0, objName, OBJPROP_TOOLTIP);
  if(meta == "") return(false);
  return(ParseAngleMeta(meta, ar));
}

// Delete ALL computed angle/unit objects across every TF+unit combo.
// Leaves UI buttons, clones, rects and status label untouched.
// Called on every TF or unit change to guarantee a clean slate.
void DeleteComputedObjects()
{
  int total = ObjectsTotal(0,0,-1);
  for(int i=total-1; i>=0; i--)
  {
    string nm = ObjectName(0,i);
    if(StringFind(nm,"AIBANG_") != 0) continue;
    // Protect TF-independent objects
    if(nm==BTN_ANG||nm==BTN_UNIT||nm==BTN_COPY||nm==BTN_RANGE||nm==BTN_REFL||nm==BTN_CLS) continue;
    if(StringFind(nm,BTN_OPT_PRE)==0) continue;
    if(StringFind(nm,PREFIX+"CLONE_")==0) continue;
    if(StringFind(nm,PREFIX+"RECT_") ==0) continue;
    if(nm==PREFIX+"STATUS") continue;
    ObjectDelete(0, nm);
  }
}

// Kept for backward compatibility — now simply calls DeleteComputedObjects.
void HideObjectsOfOtherTFs() { DeleteComputedObjects(); }
void ShowCurrentTFObjects()   { }
bool AngleExistsOnChart(int u2Id, int u1Id, string &objName)
{
  objName = StringFormat("%sANG_%d_%d", g_tfPrefix, u2Id, u1Id);
  return(ObjectFind(0, objName) >= 0);
}

bool IsSameAngleAlreadyDrawn(const string objName, const AngleResult &ar)
{
  AngleResult old;
  if(!LoadAngleMetaFromObject(objName, old)) return(false);
  if(old.dirState    != ar.dirState)    return(false);
  if(old.confirmed   != ar.confirmed)   return(false);
  if(old.unconfirmed != ar.unconfirmed) return(false);
  if(old.classText   != ar.classText)   return(false);
  if(old.candidateBuy  != ar.candidateBuy)  return(false);
  if(old.candidateSell != ar.candidateSell) return(false);
  return(true);
}

void LoadAnglesFromChart()
{
  ArrayResize(g_angleCache, 0);
  g_angleCacheCount = 0;

  // v10 TF FIX: only load objects that belong to current TF (g_tfPrefix = "AIBANG_GBPUSD_60_")
  string angPrefix = g_tfPrefix + "ANG_";
  int total = ObjectsTotal(0,0,-1);
  for(int i=0; i<total; i++)
  {
    string n = ObjectName(0, i);
    if(n == "") continue;
    if(StringFind(n, angPrefix, 0) != 0) continue;   // wrong TF → skip
    AngleResult ar;
    if(!LoadAngleMetaFromObject(n, ar)) continue;
    SaveAngleResult(ar);
  }
}

int FindUnitCacheIndexById(const int unitId)
{
  for(int i=0; i<g_unitCacheCount; i++)
    if(g_unitCache[i].valid && g_unitCache[i].id == unitId)
      return(i);
  return(-1);
}

void BuildUnitAngleStateIndex(datetime tLeft, datetime tRight)
{
  ArrayResize(g_unitStateBullish, g_unitCacheCount);
  ArrayResize(g_unitStateBearish, g_unitCacheCount);
  ArrayResize(g_unitStateBullishCand, g_unitCacheCount);
  ArrayResize(g_unitStateBearishCand, g_unitCacheCount);
  for(int i=0; i<g_unitCacheCount; i++)
  {
    g_unitStateBullish[i] = false;
    g_unitStateBearish[i] = false;
    g_unitStateBullishCand[i] = false;
    g_unitStateBearishCand[i] = false;
  }

  for(int j=0; j<g_angleCacheCount; j++)
  {
    AngleResult ar = g_angleCache[j];
    if(!ar.valid) continue;
    datetime leftT  = MathMin(ar.drawT1, ar.drawT2);
    datetime rightT = MathMax(ar.drawT1, ar.drawT2);
    if(InpDynamicVisible && tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;

    int idx1 = FindUnitCacheIndexById(ar.u1Id);
    int idx2 = FindUnitCacheIndexById(ar.u2Id);
    if(idx1 >= 0)
    {
      if(ar.confirmed && ar.dirState == 1) g_unitStateBullish[idx1] = true;
      if(ar.confirmed && ar.dirState == -1) g_unitStateBearish[idx1] = true;
      if(ar.candidateBuy) g_unitStateBullishCand[idx1] = true;
      if(ar.candidateSell) g_unitStateBearishCand[idx1] = true;
    }
    if(idx2 >= 0)
    {
      if(ar.confirmed && ar.dirState == 1) g_unitStateBullish[idx2] = true;
      if(ar.confirmed && ar.dirState == -1) g_unitStateBearish[idx2] = true;
      if(ar.candidateBuy) g_unitStateBullishCand[idx2] = true;
      if(ar.candidateSell) g_unitStateBearishCand[idx2] = true;
    }
  }
}

void SmartDrawAngle(const AngleResult &ar, datetime tLeft, datetime tRight)
{
  string objName = MakeAngleObjectName(ar);
  if(ObjectFind(0, objName) >= 0 && IsSameAngleAlreadyDrawn(objName, ar))
    return;

  AngleResult copy = ar;
  RenderAngleLikeV11(copy, tLeft, tRight);
  SaveAngleMetaToObject(objName, copy);
}

bool IsSellVisualAngle(const AngleResult &ar)
{
  if(ar.confirmed && ar.dirState == -1)
    return(true);

  if(ar.unconfirmed && ar.candidateSell)
    return(true);

  return(false);
}

color GetAngleUnitColorLikeV11(const AngleResult &ar)
{
  return(IsSellVisualAngle(ar) ? InpUnitLineColorDown : InpUnitLineColorUp);
}

color GetAngleLineColorLikeV11(const AngleResult &ar)
{
  return(IsSellVisualAngle(ar) ? InpAngleLineColorDown : InpAngleLineColorUp);
}

double GetV11TextAnchorPrice(AngleResult &ar, int level)
{
  double step = 10 * Point;
  if(ar.dirState == 1)
    return(ar.drawP2 + (level * step));
  return(ar.drawP2 - (level * step));
}

void ComputeV11TextLayout(AngleResult &ar, double &corrPrice, double &anglePrice, double &classPrice)
{
  double yOff = InpLabelYOffsetPoints * Point;
  double yClsOff = InpClassYOffsetPoints * Point;
  double visSpan = 0.0;
  double pmax = WindowPriceMax();
  double pmin = WindowPriceMin();
  if(pmax > pmin) visSpan = (pmax - pmin);

  if(ar.dirState == 1)
  {
    corrPrice  = ar.u1Low - yOff;
    anglePrice = ar.u2High + 2.0 * yOff;
    double dynOff = MathMax(yClsOff, visSpan * InpClassDynFracBuy);
    classPrice = corrPrice - dynOff;
  }
  else
  {
    corrPrice  = ar.u1High + yOff;
    anglePrice = ar.u1High + 2.0 * yOff;
    double dynOff = MathMax(yClsOff, visSpan * InpClassDynFracSell);
    classPrice = corrPrice + dynOff + InpClassSellExtraGapPoints * Point;
  }
}

void RenderAngleLikeV11(AngleResult &ar, datetime tLeft, datetime tRight)
{
  if(!ar.valid) return;
  if(!ar.confirmed && !ar.unconfirmed) return;
  if(!ar.confirmed && ar.unconfirmed && !InpShowUnconfirmedAngles) return;

  datetime leftT  = MathMin(ar.drawT1, ar.drawT2);
  datetime rightT = MathMax(ar.drawT1, ar.drawT2);
  if(tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) return;

  color legClr  = GetAngleUnitColorLikeV11(ar);
  color clrLine = GetAngleLineColorLikeV11(ar);

  if(ShouldRenderVerticalLegsForAngle(ar))
  {
    string legRef = MakeLegRefName(ar);
    string legFor = MakeLegForName(ar);
    DrawAngleVerticalLeg(legRef, ar.u2Start, ar.u2Low, ar.u2High, legClr, InpUnitLineWidth);
    DrawAngleVerticalLeg(legFor, ar.u1Start, ar.u1Low, ar.u1High, legClr, InpUnitLineWidth);
  }

  string al = MakeAngleObjectName(ar);
  DrawAngleLine(al, ar.drawT1, ar.drawP1, ar.drawT2, ar.drawP2, clrLine, InpAngleLineWidth, true);
  StoreCloneMeta(al, ar.drawT1, ar.drawP1, ar.drawT2, ar.drawP2);

  double corrPrice, anglePrice, classPrice;
  ComputeV11TextLayout(ar, corrPrice, anglePrice, classPrice);

  if(InpShowCorrectionText)
  {
    string txCorr = MakeCorrTextName(ar);
    string corrText = StringFormat("%.1f", ar.correctionValue);
    DrawAngleText(txCorr, corrText, ar.drawT2, corrPrice, clrLine);
  }

  if(InpShowAngleText && ar.angleDisplayText != "")
  {
    string txAng = MakeAngleTextName(ar);
    DrawAngleText(txAng, ar.angleDisplayText, ar.drawT2, anglePrice, clrLine);
  }

  if(g_showClassText && ar.classText != "")
  {
    string txClass = MakeClassTextName(ar);
    DrawAngleText(txClass, ar.classText, ar.drawT2, classPrice, InpClassTextColor);
  }
}

void DeleteAllClassTextObjects()
{
  string clsPrefix = g_tfPrefix + "CLS_";
  int total = ObjectsTotal(0,0,-1);
  for(int i=total-1; i>=0; i--)
  {
    string nm = ObjectName(0, i);
    if(StringFind(nm, clsPrefix) == 0)
      ObjectDelete(0, nm);
  }
}

// Redraw only classification text objects for visible angles that are missing their CLS_ label.
// Bypasses SmartDrawAngle's skip-if-exists logic — used when toggling ZZ button back ON.
void RedrawClassTextObjects()
{
  datetime tLeft = 0, tRight = 0;
  if(InpDynamicVisible)
    GetVisibleTimeRange(tLeft, tRight);

  for(int j = 0; j < g_angleCacheCount; j++)
  {
    AngleResult ar = g_angleCache[j];
    if(!ar.valid || ar.classText == "") continue;
    if(!ar.confirmed && !ar.unconfirmed) continue;
    if(!ar.confirmed && ar.unconfirmed && !InpShowUnconfirmedAngles) continue;

    datetime leftT  = MathMin(ar.drawT1, ar.drawT2);
    datetime rightT = MathMax(ar.drawT1, ar.drawT2);
    if(InpDynamicVisible && tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)) continue;

    double corrPrice, anglePrice, classPrice;
    ComputeV11TextLayout(ar, corrPrice, anglePrice, classPrice);
    DrawAngleText(MakeClassTextName(ar), ar.classText, ar.drawT2, classPrice, InpClassTextColor);
  }
  ChartRedraw(0);
}

//-------------------- Core build/draw --------------------
void BuildAndDraw()
{
  if(!g_enabled)
  {
    DeleteAllIndicatorObjects();
    return;
  }

  datetime tLeft = 0, tRight = 0;
  if(InpDynamicVisible)
    GetVisibleTimeRange(tLeft, tRight);

  string stName = PREFIX + "STATUS";
  if(ObjectFind(0, stName) < 0)
  {
    ObjectCreate(0, stName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, stName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, stName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, stName, OBJPROP_YDISTANCE, InpBtnYBase + 6*(InpBtnHeight+InpBtnGap) + 10);
    ObjectSetInteger(0, stName, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, stName, OBJPROP_COLOR, clrSilver);
    ObjectSetString(0, stName, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, stName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, stName, OBJPROP_HIDDEN, true);
  }

  if(g_unitCacheCount <= 0)
  {
    ObjectSetString(0, stName, OBJPROP_TEXT, "Units:0  Visible angles:0");
    CreateOrUpdateUI();
    return;
  }

  BuildUnitAngleStateIndex(tLeft, tRight);

  int visibleAngles = 0;

  for(int i=0; i<g_unitCacheCount; i++)
  {
    UnitInfo u = g_unitCache[i];
    if(!u.valid) continue;
    if(InpDynamicVisible && tLeft > 0 && tRight > 0 && (u.end < tLeft || u.start > tRight)) continue;

    color unitClr = InpUnitLineColorUp;
    if(InpColorUnitLinesByAngleState && i < ArraySize(g_unitStateBullish))
    {
      if(g_unitStateBearish[i] || g_unitStateBearishCand[i])
        unitClr = InpUnitLineColorDown;
      else if(g_unitStateBullish[i] || g_unitStateBullishCand[i])
        unitClr = InpUnitLineColorUp;
    }

    if(InpShowUnitVerticalLines)
    {
      string nU = StringFormat("%sU_%d", g_tfPrefix, u.id);
      DrawVSegment(nU, u.start, u.lo, u.hi, unitClr, InpUnitLineWidth, true);
      StoreCloneMeta(nU, u.start, u.lo, u.start, u.hi);
    }
  }

  for(int j=0; j<g_angleCacheCount; j++)
  {
    if(!g_angleCache[j].valid) continue;
    if(!g_angleCache[j].confirmed && !g_angleCache[j].unconfirmed) continue;
    if(!g_angleCache[j].confirmed && g_angleCache[j].unconfirmed && !InpShowUnconfirmedAngles) continue;

    datetime leftT  = MathMin(g_angleCache[j].drawT1, g_angleCache[j].drawT2);
    datetime rightT = MathMax(g_angleCache[j].drawT1, g_angleCache[j].drawT2);
    if(!(InpDynamicVisible && tLeft > 0 && tRight > 0 && (rightT < tLeft || leftT > tRight)))
    {
      SmartDrawAngle(g_angleCache[j], tLeft, tRight);
      visibleAngles++;
    }
  }

  ObjectSetString(0, stName, OBJPROP_TEXT, StringFormat("Units:%d  Visible angles:%d", g_unitCacheCount, visibleAngles));
  CreateOrUpdateUI();
}

int OnInit()
{
  EnsureValidUnitSeconds(); // must run BEFORE InitTFPrefix so unit is valid when building the prefix
  InitTFPrefix();           // sets g_tfPrefix = "AIBANG_{Symbol}_{Period}_{UnitSec}_"
  g_tmInited     = false;   // force fresh session-time detection on every load/TF-change
  g_showClassText = InpShowClassText; // sync runtime toggle to input default
  DeleteComputedObjects();  // remove any stale objects from previous TF/unit (safe, UI/clones kept)
  LoadAnglesFromChart();    // reads only objects matching g_tfPrefix (will find nothing after delete)
  g_chartAnglesLoaded = true;
  g_enabled = LoadEnabled();
  CreateOrUpdateUI();
  if(g_quickPanelVisible) CreateQuickPanel();
  Mon_OnInit();                     // AIB Monitor init
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  Mon_OnDeinit(reason);           // AIB Monitor cleanup
  Sig_OnDeinit();                  // AIB Signal cleanup
  if(reason == REASON_REMOVE)
    DeleteAllIndicatorObjects();
  else if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
    DeleteComputedObjects();  // clean slate before switching TF or reloading
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  bool unitSynced = TrySyncUnitFromSCCMWPanel();
  CreateOrUpdateUI();
  if(rates_total < 30) return(rates_total);

  static int  lastPeriod = -1;
  static int  lastUnitSeconds = -1;
  static bool lastQuickPanelVisible = false;
  static bool lastRefLinesActive = false;
  static long lastChartW = -1;
  static long lastChartH = -1;

  int  curPeriod = Period();
  long chartW = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
  long chartH = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

  bool timeframeChanged = (lastPeriod != curPeriod);
  bool unitChanged      = (unitSynced || lastUnitSeconds != g_unitSeconds);
  bool chartResized     = (lastChartW != chartW || lastChartH != chartH);
  bool panelVisChanged  = (lastQuickPanelVisible != g_quickPanelVisible);
  bool refVisChanged    = (lastRefLinesActive != g_refLinesActive);

  if(timeframeChanged || unitChanged)
  {
    if(timeframeChanged) lastPeriod = curPeriod;
    if(unitChanged)      lastUnitSeconds = g_unitSeconds;
    InitTFPrefix();           // update g_tfPrefix to new TF+unit combo
    DeleteComputedObjects();  // hard-delete all stale computed objects (any TF/unit)
  }

  datetime t0 = time[0];
  bool newBar = (prev_calculated == 0 || t0 != g_lastBarTime);
  datetime unitAnchor = GetCurrentUnitAnchor();
  bool newUnitClosed = (prev_calculated == 0 || g_lastUnitAnchor == 0 || unitAnchor != g_lastUnitAnchor);

  bool visibleWindowChanged = false;
  if(InpDynamicVisible)
  {
    datetime vl=0, vr=0;
    GetVisibleTimeRange(vl, vr);
    if(vl>0 && vr>0)
    {
      int ps = PeriodSeconds(Period());
      if(ps <= 0) ps = 60;
      visibleWindowChanged = (prev_calculated == 0 || g_lastVisibleLeft == 0 || g_lastVisibleRight == 0 || MathAbs((long)vl - (long)g_lastVisibleLeft) > ps || MathAbs((long)vr - (long)g_lastVisibleRight) > ps);
      g_lastVisibleLeft = vl;
      g_lastVisibleRight = vr;
    }
  }

  bool needCacheRebuild = (prev_calculated == 0) || timeframeChanged || unitChanged || newUnitClosed;
  bool needVisibleRefresh = visibleWindowChanged;

  if(needCacheRebuild)
  {
    g_lastBarTime = t0;
    g_lastUnitAnchor = unitAnchor;
    RebuildUnitCache();
    LoadAnglesFromChart();
    ProcessNewClosedUnitSequentially();

    if(InpDynamicVisible && g_lastVisibleLeft > 0 && g_lastVisibleRight > 0)
    {
      EnsureCacheCoversVisibleRange(g_lastVisibleLeft, g_lastVisibleRight);
      ProcessUnprocessedHistoricalPairsInRange(g_lastVisibleLeft, g_lastVisibleRight);
    }

    if(prev_calculated == 0)
      RunScaleManagerOnce();

    BuildAndDraw();
  }
  else if(needVisibleRefresh)
  {
    if(InpDynamicVisible && g_lastVisibleLeft > 0 && g_lastVisibleRight > 0)
    {
      EnsureCacheCoversVisibleRange(g_lastVisibleLeft, g_lastVisibleRight);
      ProcessUnprocessedHistoricalPairsInRange(g_lastVisibleLeft, g_lastVisibleRight);
    }
    BuildAndDraw();
  }
  else if(newBar)
  {
    g_lastBarTime = t0;
  }

  // Quick panel: only rebuild when visibility/layout state actually changes.
  if(g_quickPanelVisible)
  {
    if(panelVisChanged || timeframeChanged || chartResized || prev_calculated == 0)
      CreateQuickPanel();
  }
  else if(panelVisChanged || prev_calculated == 0)
  {
    DeleteQuickPanel();
  }

  // Reference helper lines: keep them lightweight as screen-anchored UI helpers.
  if(g_refLinesActive)
  {
    if(refVisChanged || timeframeChanged || chartResized || prev_calculated == 0)
      UpdateReferenceLines();
  }
  else if(refVisChanged || prev_calculated == 0)
  {
    DeleteReferenceLines();
  }

  lastQuickPanelVisible = g_quickPanelVisible;
  lastRefLinesActive = g_refLinesActive;
  lastChartW = chartW;
  lastChartH = chartH;

  Mon_OnTick();                   // AIB Monitor scan
  Sig_OnCalculate();               // AIB Signal draw
  return(rates_total);
}


//-------------------- Quick Text Panel --------------------
string QuickItems[140];
int    QuickRow[140];
int QuickItemCount()
{
  // Row 0: A B C X + ZA..ZZ
  // Row 1: R0..R3 and S0..S3
  // Row 2: 1..16
  int n=0;

  // --- Row 0: A B C X + ZA..ZZ ---
  int row=0;
  // Extra quick letters
  string extra0[] = {"A","B","C","X"};
  for(int e=0;e<ArraySize(extra0) && n<140;e++)
  {
    QuickItems[n]=extra0[e]; QuickRow[n]=row; n++;
  }

  for(int k=0;k<26 && n<140;k++)
  {
    string z = "Z" + CharToString((uchar)('A'+k));
    QuickItems[n]=z; QuickRow[n]=row; n++;
  }

  // --- Row 1: R/S levels ---
  row=1;
  string row1[] = {"R0","R1","R2","R3","S0","S1","S2","S3"};
  int r1=ArraySize(row1);
  for(int j=0;j<r1 && n<140;j++) { QuickItems[n]=row1[j]; QuickRow[n]=row; n++; }

  // --- Row 2: 1..16 ---
  row=2;
  for(int d=1; d<=16 && n<140; d++)
  {
    QuickItems[n]=IntegerToString(d);
    QuickRow[n]=row;
    n++;
  }

  return(n);
}


// Normalize quick item for category checks: strips surrounding (), [].
string QT_Normalize(string s)
{
  string t=s;
  // remove parentheses/brackets
  // IMPORTANT (MT4): StringReplace returns number of replacements and modifies the string by reference.
  // Do NOT assign its return value to the string.
  StringReplace(t,"(","");
  StringReplace(t,")","");
  StringReplace(t,"[","");
  StringReplace(t,"]","");
  // trim spaces
  t = StringTrimLeft(StringTrimRight(t));
  return(t);
}

bool QT_IsDigits(const string s)
{
  if(StringLen(s)<=0) return(false);
  for(int i=0;i<StringLen(s);i++)
  {
    int c = StringGetChar(s,i);
    if(c < '0' || c > '9') return(false);
  }
  return(true);
}

bool QT_IsRoman(const string s)
{
  // roman tokens we use are i, ii, iii, iv, v (lowercase)
  string t = QT_Normalize(s);
  StringToLower(t);
  if(t=="i" || t=="ii" || t=="iii" || t=="iv" || t=="v") return(true);
  return(false);
}

color QT_ColorFor(const string item)
{
  string t = QT_Normalize(item);

  // Z-labels (ZA..ZZ)
  if(StringLen(t)==2 && StringSubstr(t,0,1)=="Z")
  {
    int c = StringGetChar(t,1);
    if(c>='A' && c<='Z') return(InpQuickTextColorZLabels);
  }

  // R/S levels (R0..R3, S0..S3)
  if(StringLen(t)==2 && (StringSubstr(t,0,1)=="R" || StringSubstr(t,0,1)=="S"))
  {
    int d = StringGetChar(t,1);
    if(d>='0' && d<='9') return(InpQuickTextColorRS);
  }

  if(QT_IsDigits(t)) return(InpQuickTextColorDigits);
  if(QT_IsRoman(t))  return(InpQuickTextColorRoman);
  return(InpQuickTextColorLetters);
}


void DeleteQuickPanel()
{
  DeleteObjectsByPrefixRaw(QT_PREFIX);
}

void CreateQuickPanel()
{
  DeleteQuickPanel();
  if(!g_quickPanelVisible) return;  int n = QuickItemCount();

  // Responsive scaling for panel as well
  double scale = 1.0;
  if(InpUIScaleAuto)
  {
    long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
    long ch = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
    if(cw <= 0) cw = 1920;
    if(ch <= 0) ch = 1080;
    double sx = (double)cw / 1920.0;
    double sy = (double)ch / 1080.0;
    scale = MathMin(sx, sy);
    if(scale < InpUIScaleMin) scale = InpUIScaleMin;
    if(scale > InpUIScaleMax) scale = InpUIScaleMax;
  }
  else
  {
    scale = InpUIScaleManual;
    if(scale < 0.30) scale = 0.30;
    if(scale > 3.00) scale = 3.00;
  }

  int corner = InpQuickTextCorner;
  int x0 = (int)MathRound(InpQuickTextX * scale);
  int y0 = (int)MathRound(InpQuickTextY * scale);

  g_qtFontSizeAct = MathMax(10, (int)MathRound(InpQuickTextFontSize * scale));
  g_qtBtnWMinAct  = MathMax(18, (int)MathRound(InpQuickTextBtnW * scale));
  g_qtBtnHAct     = MathMax(14, (int)MathRound(InpQuickTextBtnH * scale));
  g_qtGapXAct     = MathMax(2,  (int)MathRound(InpQuickTextGapX * scale));
  g_qtGapYAct     = MathMax(0,  (int)MathRound(InpQuickTextGapY * scale));
  g_qtPadXAct     = MathMax(4,  (int)MathRound(InpQuickTextPadX * scale));

  int x=x0, y=y0;
  int curRow = -1;

  int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);

  // Reserve space on the right for the main control buttons so the quick panel
  // never overlaps with them (different screens / DPI / window sizes).
  int maxX = chartW - 20;
  if(corner == CORNER_LEFT_UPPER || corner == CORNER_LEFT_LOWER)
  {
    int btnX = (int)MathRound(InpBtnXDistance * scale);
    int btnW = (int)MathRound(MathMax(InpBtnWidth, 50) * scale);
    int leftEdgeButtons = chartW - btnX - btnW;
    maxX = MathMin(maxX, leftEdgeButtons - 16);
    if(maxX < 120) maxX = chartW - 20;
  }

  // If panel would exceed available width, shrink it (font + gaps) once.
  // This keeps layout stable (no drifting) and prevents overlap.
  int maxRow = -1;
  for(int i=0;i<n;i++) if(QuickRow[i] > maxRow) maxRow = QuickRow[i];
  if(maxRow < 0) maxRow = 0;

  int availW = maxX - x0;
  if(availW > 80)
  {
    int worstW = 0;
    for(int r=0;r<=maxRow;r++)
    {
      int rowW = 0;
      for(int i=0;i<n;i++)
      {
        if(QuickRow[i] != r) continue;
        string t = QuickItems[i];
        int estW = (int)(0.80*g_qtFontSizeAct*StringLen(t)) + g_qtPadXAct*2;
        int itemW = MathMax(g_qtBtnWMinAct, estW);
        rowW += itemW;
        // add gaps between items
        rowW += g_qtGapXAct;
      }
      if(rowW > worstW) worstW = rowW;
    }
    if(worstW > availW)
    {
      double shrink = (double)availW / (double)worstW;
      if(shrink < 0.55) shrink = 0.55;
      if(shrink > 1.00) shrink = 1.00;
      g_qtFontSizeAct = MathMax(10, (int)MathRound(g_qtFontSizeAct * shrink));
      g_qtBtnWMinAct  = MathMax(14, (int)MathRound(g_qtBtnWMinAct  * shrink));
      g_qtGapXAct     = MathMax(1,  (int)MathRound(g_qtGapXAct     * shrink));
      g_qtPadXAct     = MathMax(2,  (int)MathRound(g_qtPadXAct     * shrink));
    }
  }

  for(int i=0;i<n;i++)
  {
    if(QuickRow[i] != curRow)
    {
      curRow = QuickRow[i];
      x = x0;
      y = y0 + curRow * (g_qtBtnHAct + g_qtGapYAct + 2);
    }

    string name = QT_PREFIX + IntegerToString(i);
    string txt  = QuickItems[i];

    int estW = (int)(0.80*g_qtFontSizeAct*StringLen(txt)) + g_qtPadXAct*2;
    int itemW = MathMax(g_qtBtnWMinAct, estW);

    // Prevent overlap with buttons / right edge. If user forced no-wrap, we still
    // keep items within maxX by shrinking above; this is just a safety wrap.
    if((x + itemW > maxX) && !InpQuickTextNoWrap)
    {
      x = x0;
      y += g_qtBtnHAct + g_qtGapYAct;
    }

    if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

    ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, g_qtFontSizeAct);
    ObjectSetString(0, name, OBJPROP_FONT, InpQuickTextFont);
    ObjectSetInteger(0, name, OBJPROP_COLOR, QT_ColorFor(txt));
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetString(0, name, OBJPROP_TEXT, txt);

    x += itemW + g_qtGapXAct;
  }
}


// Convert current stored mouse x,y to time/price
bool MouseToTimePrice(datetime &t, double &p)
{
  long chart_id = 0;
  int subwin = 0;
  datetime tt;
  double   pp;
  if(ChartXYToTimePrice(chart_id, g_mouseX, g_mouseY, subwin, tt, pp))
  {
    t = tt; p = pp;
    return(true);
  }
  return(false);
}

// Pip size helper (MT4): for 5/3 digit symbols, 1 pip = 10 points, else 1 pip = 1 point.
double PipSize()
{
  int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
  if(d==5 || d==3) return(10.0*Point);
  return(Point);
}

// Create a clone under the clicked QuickText panel item (in screen space).
bool CreateTextCloneFromPanel(const string panelObjName, const string txt)
{
  // Get panel item's screen position
  if(ObjectFind(0, panelObjName) < 0) return(false);
  int corner = (int)ObjectGetInteger(0, panelObjName, OBJPROP_CORNER);
  int x = (int)ObjectGetInteger(0, panelObjName, OBJPROP_XDISTANCE);

  // Chart pixels
  int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
  int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

  // Recompute the same scale used by the panel (must be stable; never cumulative)
  double scale = 1.0;
  if(InpUIScaleAuto)
  {
    long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
    long ch = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
    if(cw <= 0) cw = 1920;
    if(ch <= 0) ch = 1080;
    double sx = (double)cw / 1920.0;
    double sy = (double)ch / 1080.0;
    scale = MathMin(sx, sy);
    if(scale < InpUIScaleMin) scale = InpUIScaleMin;
    if(scale > InpUIScaleMax) scale = InpUIScaleMax;
  }
  else
  {
    scale = InpUIScaleManual;
    if(scale < 0.30) scale = 0.30;
    if(scale > 3.00) scale = 3.00;
  }

  int y0 = (int)MathRound(InpQuickTextY * scale);

  // Center X of the clicked label (estimate width same as panel drawing)
  int estW = (int)(0.80*g_qtFontSizeAct*StringLen(txt)) + g_qtPadXAct*2;
  int itemW = MathMax(g_qtBtnWMinAct, estW);
  int px = x + itemW/2;

  // Place clones BELOW the entire panel (below the last row), not just below the clicked item.
  int n = QuickItemCount();
  int maxRow = 0;
  for(int i=0;i<n;i++) if(QuickRow[i] > maxRow) maxRow = QuickRow[i];
  int rows = maxRow + 1;
  int panelH = rows * g_qtBtnHAct + (rows-1) * (g_qtGapYAct + 2) + 6;
  int py = y0 + panelH + 6; // a bit below the panel

  // Corner-relative -> absolute pixels
  if(corner == CORNER_RIGHT_UPPER || corner == CORNER_RIGHT_LOWER) px = chartW - px;
  if(corner == CORNER_LEFT_LOWER  || corner == CORNER_RIGHT_LOWER) py = chartH - py;

  datetime t=0; double p=0.0;
  int subwin=0;
  if(!ChartXYToTimePrice(0, px, py, subwin, t, p))
  {
    // fallback
    t = Time[0];
    p = Bid;
  }

  // Put it UNDER by pips (additional)
  p -= InpCloneUnderPanelPips * PipSize();
  p += InpCloneTextYOffsetPoints * Point;

  string name = NOTE_PREFIX + IntegerToString(GetTickCount());
  ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetString(0, name, OBJPROP_FONT, InpCloneTextFont);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpCloneTextFontSize);
  ObjectSetInteger(0, name, OBJPROP_COLOR, InpCloneTextColor);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
  ObjectSetInteger(0, name, OBJPROP_BACK, false);
  return(true);
}

void CreateTextClone(string txt)
{
  datetime t=0; double p=0.0;
  bool ok = false;
  if(InpCloneTextAtMouse) ok = MouseToTimePrice(t,p);

  if(!ok)
  {
    t = Time[0];
    p = Bid;
  }

  p += InpCloneTextYOffsetPoints * Point;

  string name = NOTE_PREFIX + IntegerToString(GetTickCount());
  ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetString(0, name, OBJPROP_FONT, InpCloneTextFont);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpCloneTextFontSize);
  ObjectSetInteger(0, name, OBJPROP_COLOR, InpCloneTextColor);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
  ObjectSetInteger(0, name, OBJPROP_BACK, false);
}


bool IsReferenceLine(const string name)
{
  return(StringFind(name, REF_PREFIX) == 0);
}

void DeleteReferenceLines()
{
  int total = ObjectsTotal(0,0,-1);
  for(int i=total-1;i>=0;i--)
  {
    string n = ObjectName(0,i);
    if(StringFind(n, REF_PREFIX) == 0)
      ObjectDelete(0, n);
  }
}

void UpdateReferenceLines()
{
  if(!g_refLinesActive) return;

  double scale = 1.0;
  if(InpUIScaleAuto)
  {
    long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
    long ch = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
    if(cw <= 0) cw = 1920;
    if(ch <= 0) ch = 1080;
    double sx = (double)cw / 1920.0;
    double sy = (double)ch / 1080.0;
    scale = MathMin(sx, sy);
    if(scale < InpUIScaleMin) scale = InpUIScaleMin;
    if(scale > InpUIScaleMax) scale = InpUIScaleMax;
  }
  else
  {
    scale = InpUIScaleManual;
    if(scale < 0.30) scale = 0.30;
    if(scale > 3.00) scale = 3.00;
  }

  int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
  int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
  int x1 = (int)MathRound(InpRefAnchorX * scale);
  int y1 = (int)MathRound(InpRefAnchorY * scale);
  int pxLen = MathMax(40, (int)MathRound(InpRefLinePixelLength * scale));
  int dy = MathMax(8, (int)MathRound(InpRefLineSpacingPips * 1.5 * scale));
  int corner = InpRefAnchorCorner;

  int ax = x1;
  int ay = y1;
  if(corner == CORNER_RIGHT_UPPER || corner == CORNER_RIGHT_LOWER) ax = chartW - x1;
  if(corner == CORNER_LEFT_LOWER  || corner == CORNER_RIGHT_LOWER) ay = chartH - y1;

  color cols[3] = {clrRed, clrWhite, clrAqua};
  for(int i=0;i<3;i++)
  {
    int yy = ay - i*dy;
    int xx1 = ax;
    int xx2 = ax + pxLen;
    if(xx2 > chartW-4) xx2 = chartW-4;
    if(xx1 < 4) xx1 = 4;
    if(xx2 <= xx1+10) xx2 = xx1 + 10;

    datetime tA; double pA;
    datetime tB; double pB;
    int subwinA=0, subwinB=0;
    bool okA = ChartXYToTimePrice(0, xx1, yy, subwinA, tA, pA);
    bool okB = ChartXYToTimePrice(0, xx2, yy, subwinB, tB, pB);
    if(!okA || !okB)
    {
      tA = Time[MathMin(Bars-1, 30)];
      tB = tA + g_unitSeconds;
      pA = Bid - i*MathMax(2, InpRefLineSpacingPips)*PipSize();
      pB = pA;
    }
    else
    {
      tB = tA + g_unitSeconds;
      pB = pA;
    }

    string nm = REF_PREFIX + IntegerToString(i+1);
    if(ObjectFind(0, nm) < 0)
      ObjectCreate(0, nm, OBJ_TREND, 0, tA, pA, tB, pB);
    else
    {
      ObjectMove(0, nm, 0, tA, pA);
      ObjectMove(0, nm, 1, tB, pB);
    }
    ObjectSetInteger(0, nm, OBJPROP_RAY, false);
    ObjectSetInteger(0, nm, OBJPROP_WIDTH, InpRefLineWidth);
    ObjectSetInteger(0, nm, OBJPROP_COLOR, cols[i]);
    ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, nm, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, nm, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, nm, OBJPROP_BACK, false);
    StoreCloneMeta(nm, tA, pA, tB, pB);
  }
}

void CreateCloneFromReferenceLine(string src)
{
  int type = (int)ObjectGetInteger(0, src, OBJPROP_TYPE);
  if(type != OBJ_TREND) return;
  datetime t1 = (datetime)ObjectGetInteger(0, src, OBJPROP_TIME1);
  datetime t2 = (datetime)ObjectGetInteger(0, src, OBJPROP_TIME2);
  double p1 = ObjectGetDouble(0, src, OBJPROP_PRICE1) - InpRefCloneOffsetPips * PipSize();
  double p2 = ObjectGetDouble(0, src, OBJPROP_PRICE2) - InpRefCloneOffsetPips * PipSize();
  string nm = MakeCloneName();
  ObjectCreate(0, nm, OBJ_TREND, 0, t1, p1, t2, p2);
  ObjectSetInteger(0, nm, OBJPROP_RAY, false);
  ObjectSetInteger(0, nm, OBJPROP_WIDTH, (int)ObjectGetInteger(0, src, OBJPROP_WIDTH));
  ObjectSetInteger(0, nm, OBJPROP_COLOR, (color)ObjectGetInteger(0, src, OBJPROP_COLOR));
  ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, true);
  ObjectSetInteger(0, nm, OBJPROP_READONLY, false);
  ObjectSetInteger(0, nm, OBJPROP_SELECTED, true);
  ObjectSetInteger(0, nm, OBJPROP_HIDDEN, false);
  ObjectSetInteger(0, nm, OBJPROP_BACK, false);
  StoreCloneMeta(nm, t1, p1, t2, p2);
}



//-------------------- Restored helper functions from stable clone/panel builds --------------------
bool IsOriginalLine(string name)
{
  if(StringFind(name, PREFIX) != 0) return(false);
  if(StringFind(name, PREFIX+"CLONE_") == 0) return(false);
  if(StringFind(name, PREFIX+"RECT_")  == 0) return(false);
  if(StringFind(name, REF_PREFIX) == 0) return(false);
  int type = (int)ObjectGetInteger(0, name, OBJPROP_TYPE);
  return(type == OBJ_TREND);
}

bool IsClone(string name)
{
  return(StringFind(name, PREFIX+"CLONE_") == 0);
}

bool IsRectClone(string name)
{
  return(StringFind(name, PREFIX+"RECT_") == 0);
}

string GetSelectedOriginalLine()
{
  int total = ObjectsTotal(0,0,-1);
  for(int i=0;i<total;i++)
  {
    string n = ObjectName(0,i);
    if(!IsOriginalLine(n)) continue;
    if((bool)ObjectGetInteger(0, n, OBJPROP_SELECTED))
      return(n);
  }
  return("");
}

double _DistPointToSeg(double px,double py,double x1,double y1,double x2,double y2)
{
  double vx=x2-x1, vy=y2-y1;
  double wx=px-x1, wy=py-y1;
  double c1 = vx*wx + vy*wy;
  if(c1<=0) return(MathSqrt((px-x1)*(px-x1)+(py-y1)*(py-y1)));
  double c2 = vx*vx + vy*vy;
  if(c2<=c1) return(MathSqrt((px-x2)*(px-x2)+(py-y2)*(py-y2)));
  double b = c1/c2;
  double bx = x1 + b*vx;
  double by = y1 + b*vy;
  return(MathSqrt((px-bx)*(px-bx)+(py-by)*(py-by)));
}

string FindNearestOriginalLineByXY(int x,int y,int maxDistPx)
{
  string best="";
  double bestD=1e100;
  int total = ObjectsTotal(0,0,-1);
  for(int i=0;i<total;i++)
  {
    string n = ObjectName(0,i);
    if(!IsOriginalLine(n)) continue;
    datetime t1 = (datetime)ObjectGetInteger(0, n, OBJPROP_TIME1);
    datetime t2 = (datetime)ObjectGetInteger(0, n, OBJPROP_TIME2);
    double p1 = ObjectGetDouble(0, n, OBJPROP_PRICE1);
    double p2 = ObjectGetDouble(0, n, OBJPROP_PRICE2);

    int x1,y1,x2,y2;
    if(!ChartTimePriceToXY(0, 0, t1, p1, x1, y1)) continue;
    if(!ChartTimePriceToXY(0, 0, t2, p2, x2, y2)) continue;

    double d=_DistPointToSeg((double)x,(double)y,(double)x1,(double)y1,(double)x2,(double)y2);
    if(d<bestD){ bestD=d; best=n; }
  }
  if(best!="" && bestD <= (double)maxDistPx) return(best);
  return("");
}

string MakeCloneName()
{
  g_cloneCounter++;
  return(StringFormat("%sCLONE_%d", PREFIX, g_cloneCounter));
}

string MakeRectName()
{
  g_cloneCounter++;
  return(StringFormat("%sRECT_%d", PREFIX, g_cloneCounter));
}

void StoreCloneMeta(string name, datetime t1,double p1,datetime t2,double p2)
{
  int dt = (int)(t2 - t1);
  double dp = p2 - p1;
  datetime midT = t1 + (dt/2);
  double midP = p1 + (dp/2.0);
  string meta = StringFormat("LOCK|%d|%.10f|%d|%.10f", (int)midT, midP, dt, dp);
  string old = ObjectGetString(0, name, OBJPROP_TOOLTIP);
  if(old != "" && StringFind(old, "LOCK|") != 0)
    meta = meta + "|TIP:" + old;
  ObjectSetString(0, name, OBJPROP_TOOLTIP, meta);
}

bool ParseLockMeta(string meta, datetime &midT, double &midP, int &dt, double &dp)
{
  if(StringFind(meta, "LOCK|") != 0) return(false);
  string parts[];
  int n = StringSplit(meta, '|', parts);
  if(n < 5) return(false);
  midT = (datetime)StrToInteger(parts[1]);
  midP = StrToDouble(parts[2]);
  dt   = (int)StrToInteger(parts[3]);
  dp   = StrToDouble(parts[4]);
  return(true);
}

bool ParseRectMeta(string meta, datetime &t1, double &p1, datetime &t2, double &p2)
{
  if(StringFind(meta, "RECTLOCK|") != 0) return(false);
  string parts[];
  int n = StringSplit(meta, '|', parts);
  if(n < 5) return(false);
  t1 = (datetime)StrToInteger(parts[1]);
  p1 = StrToDouble(parts[2]);
  t2 = (datetime)StrToInteger(parts[3]);
  p2 = StrToDouble(parts[4]);
  return(true);
}

void SetRectLockMeta(const string name)
{
  datetime t1=(datetime)ObjectGetInteger(0, name, OBJPROP_TIME1);
  datetime t2=(datetime)ObjectGetInteger(0, name, OBJPROP_TIME2);
  double   p1=ObjectGetDouble(0, name, OBJPROP_PRICE1);
  double   p2=ObjectGetDouble(0, name, OBJPROP_PRICE2);
  string meta = StringFormat("RECTLOCK|%d|%.10f|%d|%.10f",(int)t1,p1,(int)t2,p2);
  ObjectSetString(0, name, OBJPROP_TOOLTIP, meta);
}

void CreateCloneFromLine(string src)
{
  int type = (int)ObjectGetInteger(0, src, OBJPROP_TYPE);
  if(type != OBJ_TREND) return;
  datetime t1 = (datetime)ObjectGetInteger(0, src, OBJPROP_TIME1);
  datetime t2 = (datetime)ObjectGetInteger(0, src, OBJPROP_TIME2);
  double p1 = ObjectGetDouble(0, src, OBJPROP_PRICE1);
  double p2 = ObjectGetDouble(0, src, OBJPROP_PRICE2);

  double off = InpCloneOffsetPips * PipValue();
  int barSec = Period() * 60;
  if(barSec <= 0) barSec = 60;
  int dtShift = InpCloneOffsetBars * barSec;
  t1 += dtShift;
  t2 += dtShift;
  p1 += off;
  p2 += off;

  string nm = MakeCloneName();
  ObjectCreate(0, nm, OBJ_TREND, 0, t1, p1, t2, p2);
  ObjectSetInteger(0, nm, OBJPROP_RAY, false);
  ObjectSetInteger(0, nm, OBJPROP_WIDTH, (int)ObjectGetInteger(0, src, OBJPROP_WIDTH));
  color c_src = (color)ObjectGetInteger(0, src, OBJPROP_COLOR);
  color c_use = c_src;
  if(!InpCloneUseSourceColor)
     c_use = (StringFind(src, "AL_") >= 0) ? InpCloneAngleColor : InpCloneUnitColor;
  ObjectSetInteger(0, nm, OBJPROP_COLOR, c_use);
  ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, true);
  ObjectSetInteger(0, nm, OBJPROP_READONLY, false);
  ObjectSetInteger(0, nm, OBJPROP_SELECTED, true);
  StoreCloneMeta(nm, t1, p1, t2, p2);
}

void EnforceCloneLock(string name)
{
  string meta = ObjectGetString(0, name, OBJPROP_TOOLTIP);
  datetime midT0; double midP0; int dt0; double dp0;
  if(!ParseLockMeta(meta, midT0, midP0, dt0, dp0)) return;

  datetime t1 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME1);
  datetime t2 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME2);
  double p1 = ObjectGetDouble(0, name, OBJPROP_PRICE1);
  double p2 = ObjectGetDouble(0, name, OBJPROP_PRICE2);

  datetime midT = (datetime)(t1 + (int)((t2 - t1)/2));
  double midP = (p1 + p2)/2.0;

  int dT = (int)(midT - midT0);
  double dP = (midP - midP0);

  datetime newMidT = midT0 + dT;
  double   newMidP = midP0 + dP;
  datetime newT1 = newMidT - (dt0/2);
  datetime newT2 = newT1 + dt0;
  double   newP1 = newMidP - (dp0/2.0);
  double   newP2 = newP1 + dp0;

  ObjectSetInteger(0, name, OBJPROP_TIME1, newT1);
  ObjectSetDouble(0, name, OBJPROP_PRICE1, newP1);
  ObjectSetInteger(0, name, OBJPROP_TIME2, newT2);
  ObjectSetDouble(0, name, OBJPROP_PRICE2, newP2);
  StoreCloneMeta(name, newT1, newP1, newT2, newP2);
}

void EnforceOriginalLock(string name)
{
  string meta = ObjectGetString(0, name, OBJPROP_TOOLTIP);
  datetime midT0; double midP0; int dt0; double dp0;
  if(!ParseLockMeta(meta, midT0, midP0, dt0, dp0)) return;

  datetime t1 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME1);
  datetime t2 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME2);
  double p1 = ObjectGetDouble(0, name, OBJPROP_PRICE1);
  double p2 = ObjectGetDouble(0, name, OBJPROP_PRICE2);

  datetime midT = (datetime)(t1 + (int)((t2 - t1)/2));
  double midP = (p1 + p2)/2.0;
  if(midT != midT0 || MathAbs(midP - midP0) > (Point*0.1))
  {
    datetime newT1 = midT0 - (dt0/2);
    datetime newT2 = newT1 + dt0;
    double   newP1 = midP0 - (dp0/2.0);
    double   newP2 = newP1 + dp0;
    ObjectSetInteger(0, name, OBJPROP_TIME1, newT1);
    ObjectSetDouble(0, name, OBJPROP_PRICE1, newP1);
    ObjectSetInteger(0, name, OBJPROP_TIME2, newT2);
    ObjectSetDouble(0, name, OBJPROP_PRICE2, newP2);
  }
}

void EnforceRectLock(string name)
{
  string meta = ObjectGetString(0, name, OBJPROP_TOOLTIP);
  datetime t10; double p10; datetime t20; double p20;
  if(!ParseRectMeta(meta, t10, p10, t20, p20)) return;

  datetime t1 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME1);
  datetime t2 = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME2);
  double p1 = ObjectGetDouble(0, name, OBJPROP_PRICE1);
  double p2 = ObjectGetDouble(0, name, OBJPROP_PRICE2);

  datetime curMidT = (datetime)(t1 + (int)((t2 - t1)/2));
  double curMidP = (p1 + p2)/2.0;
  datetime orgMidT = (datetime)(t10 + (int)((t20 - t10)/2));
  double orgMidP = (p10 + p20)/2.0;

  int dT = (int)(curMidT - orgMidT);
  double dP = curMidP - orgMidP;

  datetime nt1 = t10 + dT;
  datetime nt2 = t20 + dT;
  double np1 = p10 + dP;
  double np2 = p20 + dP;

  ObjectSetInteger(0, name, OBJPROP_TIME1, nt1);
  ObjectSetDouble(0, name, OBJPROP_PRICE1, np1);
  ObjectSetInteger(0, name, OBJPROP_TIME2, nt2);
  ObjectSetDouble(0, name, OBJPROP_PRICE2, np2);

  SetRectLockMeta(name);
}

void DrawAngleText(string name, string txt, datetime t, double p, color c)
{
  DrawTextSized(name, t, p, txt, c, InpClassFontSize);
}

bool CreateRange236RectAtTime(const datetime tClick)
{
   datetime t0 = FloorTimeToUnit(tClick, g_unitSeconds);
   UnitInfo u;
   if(!BuildUnit(t0, t0 + g_unitSeconds, u))
      return(false);

   double p0   = u.lo;
   double p236 = u.lo + (u.hi - u.lo) * 0.236;
   string name = MakeRectName();
   DrawLockedRect(name, u.start, p0, u.end, p236);
   SetRectLockMeta(name);
   return(true);
}

bool TryCreateRange236RectAtTimePrice(const datetime tClick, const double priceClick)
{
   datetime t0 = FloorTimeToUnit(tClick, g_unitSeconds);
   UnitInfo u;
   if(!BuildUnit(t0, t0 + g_unitSeconds, u))
      return(false);

   double p0   = u.lo;
   double p236 = u.lo + (u.hi - u.lo) * 0.236;
   double pMin = MathMin(p0, p236);
   double pMax = MathMax(p0, p236);

   double eps = (u.hi - u.lo) * 0.0005;
   if(priceClick < pMin - eps || priceClick > pMax + eps)
      return(false);

   return(CreateRange236RectAtTime(tClick));
}

// ---------- Hover tooltip helpers ----------
void ShowHoverTooltip(string txt, int x, int y)
{
  if(ObjectFind(0, HOVER_TIP_NAME) < 0)
  {
    ObjectCreate(0, HOVER_TIP_NAME, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_HIDDEN,     true);
    ObjectSetString (0, HOVER_TIP_NAME, OBJPROP_FONT,       "Arial Bold");
    ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_FONTSIZE,   10);
    ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_BACK,       false);
  }
  ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
  ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_XDISTANCE, x);
  ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_YDISTANCE, MathMax(5, y));
  ObjectSetString (0, HOVER_TIP_NAME, OBJPROP_TEXT,      txt);
  ObjectSetInteger(0, HOVER_TIP_NAME, OBJPROP_COLOR,     clrWhite);
}

void HideHoverTooltip()
{
  if(ObjectFind(0, HOVER_TIP_NAME) >= 0)
    ObjectDelete(0, HOVER_TIP_NAME);
  g_lastHoverU1Id = -999;
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  Sig_OnChartEvent(id, lparam, dparam, sparam);   // AIB Signal hook

  if(id == CHARTEVENT_MOUSE_MOVE)
  {
    g_mouseX = (int)lparam;
    g_mouseY = (int)dparam;

    // Hover tooltip: throttle to 60ms to keep mouse events lightweight
    uint _hMs = GetTickCount();
    if(_hMs - g_lastHoverMs >= 60)
    {
      g_lastHoverMs = _hMs;

      datetime mouseTime = 0; double mousePrice = 0.0; int subWin = 0;
      if(ChartXYToTimePrice(0, g_mouseX, g_mouseY, subWin, mouseTime, mousePrice) && mouseTime > 0)
      {
        // Tolerance: ±2 bars around the formation-unit start time
        int toleranceSec = 2 * PeriodSeconds(Period());
        bool foundLeg = false;

        for(int _j = 0; _j < g_angleCacheCount; _j++)
        {
          AngleResult _ar = g_angleCache[_j];
          if(!_ar.valid || (!_ar.confirmed && !_ar.unconfirmed)) continue;
          if(MathAbs((long)mouseTime - (long)_ar.u1Start) <= toleranceSec)
          {
            if(g_lastHoverU1Id != _ar.u1Id)
            {
              g_lastHoverU1Id = _ar.u1Id;
              double refRange  = _ar.u2High - _ar.u2Low;
              double formRange = _ar.u1High - _ar.u1Low;
              double ratio     = (refRange > 1e-10) ? (formRange / refRange * 100.0) : 0.0;
              ShowHoverTooltip(StringFormat("%.1f%%", ratio), g_mouseX + 16, g_mouseY - 22);
            }
            foundLeg = true;
            break;
          }
        }
        if(!foundLeg) HideHoverTooltip();
      }
    }
    return;
  }


  // Keep chart interactions lightweight.
  // When market is live, OnCalculate fires on every tick and handles visible-range rebuilds.
  // When market is closed (no ticks), we must handle scrolling here so historical data renders.
  if(id==CHARTEVENT_CHART_CHANGE || id==CHARTEVENT_MOUSE_WHEEL)
  {
    uint now = GetTickCount();
    if(now - g_lastEvtDrawMs > 180)
    {
      g_lastEvtDrawMs = now;
      CreateOrUpdateUI();
      if(g_refLinesActive) UpdateReferenceLines();
      if(g_quickPanelVisible) CreateQuickPanel();
      else DeleteQuickPanel();

      // When InpDynamicVisible is ON, check if the visible window shifted.
      // This is the only way scrolling works when market is closed (no ticks → no OnCalculate).
      if(InpDynamicVisible && g_enabled)
      {
        datetime vl = 0, vr = 0;
        GetVisibleTimeRange(vl, vr);
        if(vl > 0 && vr > 0)
        {
          int ps = PeriodSeconds(Period());
          if(ps <= 0) ps = 60;
          bool rangeChanged = (g_lastVisibleLeft == 0 || g_lastVisibleRight == 0 ||
                               MathAbs((long)vl - (long)g_lastVisibleLeft)  > ps ||
                               MathAbs((long)vr - (long)g_lastVisibleRight) > ps);
          if(rangeChanged)
          {
            g_lastVisibleLeft  = vl;
            g_lastVisibleRight = vr;
            EnsureCacheCoversVisibleRange(vl, vr);
            ProcessUnprocessedHistoricalPairsInRange(vl, vr);
            BuildAndDraw();
            ChartRedraw(0);
            return;
          }
        }
      }

      ChartRedraw(0);
    }
    return;
  }
  if(id == CHARTEVENT_OBJECT_DBLCLICK)
  {
    // Some MT4 builds send a dedicated double-click event for objects.
    if(g_copyEnabled && IsReferenceLine(sparam))
    {
      CreateCloneFromReferenceLine(sparam);
      return;
    }
    if(g_copyEnabled && IsOriginalLine(sparam))
    {
      CreateCloneFromLine(sparam);
      return;
    }
  }
  if(id == CHARTEVENT_OBJECT_CLICK)
  {

    // Quick text toggle
    if(sparam == BTN_TXT)
    {
      g_quickPanelVisible = !g_quickPanelVisible;
      if(g_quickPanelVisible) CreateQuickPanel();
      else DeleteQuickPanel();
      CreateOrUpdateUI();
      ChartRedraw(0);
      return;
    }

    // Quick text buttons
    if(g_copyEnabled && IsReferenceLine(sparam))
    {
      CreateCloneFromReferenceLine(sparam);
      return;
    }

    if(StringFind(sparam, QT_PREFIX, 0) == 0)
    {
      int idx = (int)StringToInteger(StringSubstr(sparam, StringLen(QT_PREFIX)));
      int n = QuickItemCount();
	      if(idx >= 0 && idx < n)
	      {
	        // Always place under the clicked panel item (as requested).
	        if(!CreateTextCloneFromPanel(sparam, QuickItems[idx]))
	          CreateTextClone(QuickItems[idx]);
	      }
      return;
    }


    // UI buttons
    if(sparam == BTN_ANG)
    {
      g_enabled = !g_enabled;
      SaveEnabled(g_enabled);
      CreateOrUpdateUI();
      BuildAndDraw();
      if(g_refLinesActive) UpdateReferenceLines();
      if(g_quickPanelVisible) CreateQuickPanel();
      else DeleteQuickPanel();
      return;
    }
        if(sparam == BTN_COPY)
    {
      g_copyEnabled = !g_copyEnabled;
      CreateOrUpdateUI();
      return;
    }
    if(sparam == BTN_RANGE)
    {
      g_rangeEnabled = !g_rangeEnabled;
      CreateOrUpdateUI();
      return;
    }
    if(sparam == BTN_REFL)
    {
      g_refLinesActive = !g_refLinesActive;
      CreateOrUpdateUI();
      if(g_refLinesActive) UpdateReferenceLines();
      else DeleteReferenceLines();
      return;
    }
    if(sparam == BTN_CLS)
    {
      g_showClassText = !g_showClassText;
      if(!g_showClassText)
        DeleteAllClassTextObjects(); // instantly remove all labels from chart
      else
        RedrawClassTextObjects();    // restore labels without retriggering SmartDrawAngle skip logic
      CreateOrUpdateUI();
      return;
    }
if(sparam == BTN_UNIT)
    {
      g_optsVisible = !g_optsVisible;
      CreateOrUpdateUI();
      return;
    }
    if(StringFind(sparam, BTN_OPT_PRE) == 0)
    {
      int idx = (int)StrToInteger(StringSubstr(sparam, StringLen(BTN_OPT_PRE)));
      int opts[]; int n=GetUnitOptions(Period(), opts);
      if(idx>=0 && idx<n)
      {
        g_unitSeconds = opts[idx];
        g_optsVisible = false;
        InitTFPrefix();          // update prefix to new TF+unit combo
        DeleteComputedObjects(); // hard-delete all stale computed objects before redraw
        CreateOrUpdateUI();
        BuildAndDraw();
        if(g_quickPanelVisible) CreateQuickPanel();
        else DeleteQuickPanel();
      }
      return;
    }

    // double click on original line => clone (when COPY is ON)
    if(g_copyEnabled && IsOriginalLine(sparam))
    {
      if(IsDoubleClick("OBJ|"+sparam))
      {
        CreateCloneFromLine(sparam);
      }
      return;
    }
  }
  else if(id == CHARTEVENT_CLICK)
  {
    int x = (int)lparam;
    int y = (int)dparam;


    // 1) Try cloning by proximity on DOUBLE-CLICK anywhere near a line (robust across MT4 builds)
    
if(IsDoubleClickXY(x, y, 12))
{
  // 1) COPY: clone nearest original line if double-click occurred near it
  if(g_copyEnabled)
  {
    string near = FindNearestOriginalLineByXY(x, y, 8);
    if(near != "")
    {
      CreateCloneFromLine(near);
      return;
    }
  }

  // 2) RANGE 23.60: if enabled and double-click is inside the 0..23.6 zone of the unit under mouse, draw its rectangle
  if(g_rangeEnabled)
  {
    datetime t; double p;
    int subwin=0;
    if(ChartXYToTimePrice(0, x, y, subwin, t, p))
    {
      TryCreateRange236RectAtTimePrice(t, p);
      return;
    }
  }

  return;
}

    // Also support "double click" using currently selected original line (if selection works on your terminal)
    string sel = GetSelectedOriginalLine();
    if(g_copyEnabled && sel != "" && IsDoubleClick("SEL|"+sel))
    {
      CreateCloneFromLine(sel);
      return;
    }
  }
  else if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_CHANGE)
  {
    // enforce lock for clones and rectangles
    if(IsClone(sparam))
      EnforceCloneLock(sparam);
    else if(IsOriginalLine(sparam))
      EnforceOriginalLock(sparam);
    else if(IsRectClone(sparam))
      EnforceRectLock(sparam);
  }
}
// Floors time to the start of the unit, aligned to broker day/week opens (avoids UTC-epoch misalignment)
datetime FloorTimeToUnit(datetime t, int sec)
{
   if(sec<=0) return t;
   // Intraday: align to broker day open (D1 bar)
   if(sec < 86400)
   {
      int sh = iBarShift(Symbol(), PERIOD_D1, t, true);
      datetime dayStart = (sh>=0 ? iTime(Symbol(), PERIOD_D1, sh) : 0);
      if(dayStart<=0) dayStart = t - (t % 86400);
      int delta = int(t - dayStart);
      if(delta<0) delta = 0;
      return dayStart + (delta/sec)*sec;
   }
   // Day-multiples (>=1D and <1W): align to broker day open, then group by K days since epoch (server time)
   if(sec < 604800)
   {
      int k = MathMax(1, sec/86400);
      int sh = iBarShift(Symbol(), PERIOD_D1, t, true);
      datetime dayStart = (sh>=0 ? iTime(Symbol(), PERIOD_D1, sh) : 0);
      if(dayStart<=0) dayStart = t - (t % 86400);
      long dayNum = long(dayStart/86400);
      long baseDay = dayNum - (dayNum % k);
      return datetime(baseDay*86400);
   }
   // Week-multiples (>=1W): align to broker week open (W1 bar), then group by K weeks since epoch
   int kW = MathMax(1, sec/604800);
   int shW = iBarShift(Symbol(), PERIOD_W1, t, true);
   datetime weekStart = (shW>=0 ? iTime(Symbol(), PERIOD_W1, shW) : 0);
   if(weekStart<=0) weekStart = t - (t % 604800);
   long weekNum = long(weekStart/604800);
   long baseW = weekNum - (weekNum % kW);
   return datetime(baseW*604800);
}


void ButtonCreateOrUpdate(string name, string txt, int corner, int x, int y, int w, int h, color bg, color fg, int fontSize)
{
  if(ObjectFind(0, name) < 0)
    ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
  ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
  ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
  ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
  ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
  ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
  ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

string UnitNameFromSeconds(int sec)
{
  int tf = Period();
  if(tf == PERIOD_H1)
  {
    int d = (int)MathRound((double)sec / 86400.0);
    if(d >= 1 && MathAbs(sec - d*86400) <= 60) return(StringFormat("%dD", d));
  }
  if(tf == PERIOD_H4)
  {
    int w = (int)MathRound((double)sec / (7.0*86400.0));
    if(w >= 1 && MathAbs(sec - w*7*86400) <= 4*3600) return(StringFormat("%dW", w));
  }
  if(tf == PERIOD_D1)
  {
    int m = (int)MathRound((double)sec / (30.0*86400.0));
    if(m >= 1) return(StringFormat("%dM", m));
  }
  if(tf == PERIOD_W1)
  {
    int m6 = (int)MathRound((double)sec / (30.0*86400.0));
    if(m6 >= 1) return(StringFormat("%dM", m6));
  }
  if(tf == PERIOD_MN1)
  {
    int y = (int)MathRound((double)sec / (365.0*86400.0));
    if(y >= 1) return(StringFormat("%dY", y));
  }

  if(sec%86400==0) return(StringFormat("%dD", sec/86400));
  if(sec%(7*86400)==0) return(StringFormat("%dW", sec/(7*86400)));
  if(sec%3600==0) return(StringFormat("%dh", sec/3600));
  if(sec%60==0)   return(StringFormat("%dm", sec/60));
  return(StringFormat("%ds", sec));
}

void EnsureValidUnitSeconds()
{
  int opts[]; int n=GetUnitOptions(Period(), opts);
  bool ok=false;
  for(int i=0;i<n;i++) if(opts[i]==g_unitSeconds) ok=true;
  if(!ok)
    g_unitSeconds = opts[0];
}


string ToUpper(string s){ StringToUpper(s); return(s); }


int ParseUnitSecondsFromSCCMWName(string txt)
{
  // Parses SCCMW period name text like "6H (الوحدة الزمنية)" or "8H (...)"
  // Returns seconds, or -1 if not recognised.
  string su = ToUpper(txt);
  int i=0, len=StringLen(su);
  while(i<len && StringGetChar(su,i)==' ') i++;   // skip leading spaces
  int start=i;
  while(i<len) { ushort c=StringGetChar(su,i); if(c<'0'||c>'9') break; i++; }
  if(i==start || i>=len) return(-1);
  int n=(int)StringToInteger(StringSubstr(su,start,i-start));
  if(n<=0) return(-1);
  string suf=StringSubstr(su,i,1);
  if(suf=="H") return(n*3600);
  if(suf=="M") return(n*60);
  if(suf=="D") return(n*86400);
  return(-1);
}


int ParseUnitSecondsFromText(string txt)
{
  string s = ToUpper(txt);
  int p = StringFind(s, "UNIT");
  if(p < 0) return(-1);
  // Find ':' after UNIT
  int c = StringFind(s, ":", p);
  if(c < 0) return(-1);
  string tail = s;
  tail = StringSubstr(tail, c+1);
  // trim spaces
  while(StringLen(tail)>0 && (StringGetChar(tail,0)==' ' || StringGetChar(tail,0)=='\t'))
    tail = StringSubstr(tail,1);
  // extract token up to space
  int sp = StringFind(tail, " ");
  if(sp > 0) tail = StringSubstr(tail,0,sp);

  // formats: 15M, 30M, 1H, 2H, 168H
  if(StringLen(tail) < 2) return(-1);
  int last = StringLen(tail)-1;
  string suf = StringSubstr(tail, last, 1);
  string num = StringSubstr(tail, 0, last);
  int n = (int)StrToInteger(num);
  if(n <= 0) return(-1);
  if(suf=="M") return(n*60);
  if(suf=="H") return(n*60*60);
  if(suf=="D") return(n*24*60*60);
  return(-1);
}


void CreateOrUpdateUI()
{
  EnsureValidUnitSeconds();

  // --- Responsive UI scaling (fix different screens / DPI) ---
  double scale = 1.0;
  if(InpUIScaleAuto)
  {
    long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
    long ch = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
    if(cw <= 0) cw = 1920;
    if(ch <= 0) ch = 1080;

    double sx = (double)cw / 1920.0;
    double sy = (double)ch / 1080.0;
    scale = MathMin(sx, sy);
    if(scale < InpUIScaleMin) scale = InpUIScaleMin;
    if(scale > InpUIScaleMax) scale = InpUIScaleMax;
  }
  else
  {
    scale = InpUIScaleManual;
    if(scale < 0.30) scale = 0.30;
    if(scale > 3.00) scale = 3.00;
  }

  int corner = CORNER_RIGHT_UPPER;

  int x     = (int)MathRound(InpBtnXDistance * scale);
  int yBase = (int)MathRound(InpBtnYBase * scale);
  int w     = (int)MathRound(InpBtnWidth * scale);
  int h     = (int)MathRound(InpBtnHeight * scale);
  int gap   = (int)MathRound(InpBtnGap * scale);
  int fsz   = (int)MathRound(InpBtnFontSize * scale);

  // compact defaults (smaller buttons, short labels)
  w = MathMax(52, w/3);
  h = MathMax(18, h/2);
  gap = MathMax(2, gap/2);
  fsz = MathMax(9, fsz-3);

  color onBg  = clrTeal;
  color offBg = clrRed;
  color fg    = clrWhite;

  ButtonCreateOrUpdate(BTN_ANG,  "AN", corner, x, yBase, w, h, g_enabled ? onBg : offBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_UNIT, "U:" + UnitNameFromSeconds(g_unitSeconds), corner, x, yBase + (h+gap), w, h, onBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_COPY, "CP", corner, x, yBase + 2*(h+gap), w, h, g_copyEnabled ? onBg : offBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_RANGE, "23", corner, x, yBase + 3*(h+gap), w, h, g_rangeEnabled ? onBg : offBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_TXT,  "TX", corner, x, yBase + 4*(h+gap), w, h, g_quickPanelVisible ? onBg : offBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_REFL, "L3", corner, x, yBase + 5*(h+gap), w, h, g_refLinesActive ? onBg : offBg, fg, fsz);
  ButtonCreateOrUpdate(BTN_CLS,  "ZZ", corner, x, yBase + 6*(h+gap), w, h, g_showClassText ? onBg : offBg, fg, fsz);

  int opts[]; int n = GetUnitOptions(Period(), opts);
  for(int i=0;i<n;i++)
  {
    string nm = BTN_OPT_PRE + IntegerToString(i);
    if(g_optsVisible)
      ButtonCreateOrUpdate(nm, UnitNameFromSeconds(opts[i]), corner, x, yBase + 6*(h+gap) + (i+1)*(h+2), w, h, clrDarkSlateGray, fg, fsz);
    else
    {
      if(ObjectFind(0,nm)>=0) ObjectDelete(0,nm);
    }
  }
  for(int k=n;k<20;k++)
  {
    string nm2 = BTN_OPT_PRE + IntegerToString(k);
    if(ObjectFind(0,nm2)>=0) ObjectDelete(0,nm2);
  }
}


void GetVisibleTimeRange(datetime &tLeft, datetime &tRight)
{
  int leftShift = WindowFirstVisibleBar();
  int bars = WindowBarsPerChart();
  int rightShift = leftShift - bars + 1;
  if(rightShift < 0) rightShift = 0;
  tLeft  = iTime(Symbol(), Period(), leftShift);
  tRight = iTime(Symbol(), Period(), rightShift);
  if(tLeft > tRight) { datetime tmp=tLeft; tLeft=tRight; tRight=tmp; }
}


int SCCMW_GetUnitTF(int tf)
{
  if(tf==PERIOD_M1)
  {
    if(g_unitSeconds == 15*60) return(PERIOD_M15);
    if(g_unitSeconds == 30*60) return(PERIOD_M30);
    return(PERIOD_H1);
  }
  if(tf==PERIOD_M5)
  {
    if(g_unitSeconds == 3*60*60) return(PERIOD_H1);
    return(PERIOD_H4);
  }
  if(tf==PERIOD_M15)
  {
    if(g_unitSeconds == 6*60*60) return(PERIOD_H1);
    return(PERIOD_H4);
  }
  if(tf==PERIOD_M30) return(PERIOD_H4);
  if(tf==PERIOD_H1)  return(PERIOD_D1);
  if(tf==PERIOD_H4)  return(PERIOD_W1);
  if(tf==PERIOD_D1)  return(PERIOD_MN1);
  if(tf==PERIOD_W1)  return(PERIOD_MN1);
  if(tf==PERIOD_MN1) return(PERIOD_MN1);
  return(0);
}


int SCCMW_GetBarsAsUnit(int tf)
{
  if(tf==PERIOD_M1)
  {
    if(g_unitSeconds == 15*60) return(1);
    if(g_unitSeconds == 30*60) return(1);
    if(g_unitSeconds == 2*60*60) return(2);
    return(1);
  }
  if(tf==PERIOD_M5)
  {
    if(g_unitSeconds == 3*60*60) return(3);
    return(1);
  }
  if(tf==PERIOD_M15)
  {
    if(g_unitSeconds == 6*60*60) return(6);
    return(2);
  }
  if(tf==PERIOD_M30) return(3);
  if(tf==PERIOD_H1)  return(1);
  if(tf==PERIOD_H4)
  {
    if(g_unitSeconds >= 14*24*60*60) return(2);
    return(1);
  }
  if(tf==PERIOD_D1)
  {
    if(g_unitSeconds >= 120*24*60*60) return(4);
    if(g_unitSeconds >= 90*24*60*60)  return(3);
    if(g_unitSeconds >= 60*24*60*60)  return(2);
    return(1);
  }
  if(tf==PERIOD_W1)  return(6);
  if(tf==PERIOD_MN1)
  {
    if(g_unitSeconds >= 10*365*24*60*60) return(120);
    if(g_unitSeconds >= 5*365*24*60*60)  return(60);
    if(g_unitSeconds >= 2*365*24*60*60)  return(24);
    return(12);
  }
  return(1);
}


void SCCMW_TM_Init()
{
  if(g_tmInited) return;
  g_tmInited = true;
  g_tmHasSunday = false;
  g_tmStartAfterHour = false;
  g_tmSessionFrom = 0;
  g_tmSessionTo = 0;

  datetime fromD=0, toD=0;
  if(SymbolInfoSessionTrade(Symbol(), 5, 0, fromD, toD))
  {
    g_tmSessionFrom = fromD;
    g_tmSessionTo   = toD;
    g_tmStartAfterHour = (TimeHour(fromD) == 1);
  }

  if(Period() == PERIOD_H1)
  {
    int day = TimeDayOfWeek(iTime(Symbol(), PERIOD_D1, 0));
    int counter = 1;
    int next = TimeDayOfWeek(iTime(Symbol(), PERIOD_D1, counter++));
    if(day==0 || next==0) g_tmHasSunday = true;
    while(!g_tmHasSunday && next != day && counter < 7)
    {
      if(next == 0) { g_tmHasSunday = true; break; }
      next = TimeDayOfWeek(iTime(Symbol(), PERIOD_D1, counter++));
    }
  }
}

//──────────────────────────────────────────────────────────────────────────
// AIB Signal Engine — include order matters:
//   1. ComboTable  : 441-combo lookup (auto-generated, do not edit)
//   2. Monitor     : per-bar streaming test evaluation + CSV report
//   3. Signal      : trade zone drawing (OTE-style rectangles + labels)
//──────────────────────────────────────────────────────────────────────────
#include "AIB_ComboTable.mqh"
#include "AIB_Monitor.mqh"
#include "AIB_Signal.mqh"
