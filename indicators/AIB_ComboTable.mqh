// AIB_ComboTable.mqh
// Auto-generated — do not edit manually
// Combos: 283 | MIN_ANGLES=15 | Data: 1999-2026 | 7 pairs | Confirmed=1 only
//
// COMBO CODE FORMAT (5 chars): {CLASS}{DIR}{RATIO}{L_SIZE}{PREV}
//   CLASS : ZB→B  ZC→C  ZD→D  ZE→E  ZF→F  ZG→G  ZH→H  ZO→O
//   DIR   : B=BUY  S=SELL
//   RATIO : 4=>140%  3=100-140%  2=60-100%  1=<60%  (U1/U2 ratio)
//   L_SIZE: S=small(≤46.3%)  M=medium(46.3-70.9%)  L=large(>70.9%)
//   PREV  : prev angle class letter, X=none
//
// Test index: U1X1=0  U2X1=1  DLX1=2  DRX1=3
// tier: 1=Full Margin  2=Strong  3=Good  4=Weak  5=Very Weak
// test_rank[i]: rank of test i within combo (1=best by nok)
// signal_score: sqrt(n_ang)*nok[best_test]
// p1[i]: TP1 hit%  p2[i]: TP2% given TP1  p3[i]: TP3% given TP1
// d1/d2/d3[i]: avg hours to TP1/TP2/TP3

#define COMBO_P33   46.2687
#define COMBO_P67   70.9266
#define COMBO_COUNT 283

struct ComboRec {
   string code;          // 5-char combo identifier
   string cls;           // ZB..ZO
   string dir;           // BUY or SELL
   int    n_ang;         // angle count (sample size)
   int    tier;          // 1=Full Margin  2=Strong  3=Good  4=Weak  5=Very Weak
   double signal_score;  // sqrt(n_ang)*nok[best_test]  — ranking metric
   int    test_rank[4];  // rank within combo 1=best 4=worst [U1X1,U2X1,DLX1,DRX1]
   double p1[4];         // TP1 hit rate % [U1X1,U2X1,DLX1,DRX1]
   double p2[4];         // TP2% given TP1 hit
   double p3[4];         // TP3% given TP1 hit
   double d1[4];         // avg hours to TP1
   double d2[4];         // avg hours to TP2
   double d3[4];         // avg hours to TP3
   int    nt[4];         // touch count per test
   int    nok[4];        // TP1 hit count per test
};

ComboRec g_combos[COMBO_COUNT];
bool     g_combos_init = false;

void ComboTable_Init() {
   if(g_combos_init) return;
   int i = 0;

   // BB4SF | ZB/BUY | n_ang=106 | Full Margin | score=504.5
   g_combos[i].code="BB4SF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=106; g_combos[i].tier=1; g_combos[i].signal_score=504.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=52.13; g_combos[i].p1[1]=33.85; g_combos[i].p1[2]=4.72; g_combos[i].p1[3]=31.94;
   g_combos[i].p2[0]=57.14; g_combos[i].p2[1]=72.73; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=55.10; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=264.2; g_combos[i].d1[1]=435.4; g_combos[i].d1[2]=179.8; g_combos[i].d1[3]=336.4;
   g_combos[i].d2[0]=390.1; g_combos[i].d2[1]=424.2; g_combos[i].d2[2]=228.8; g_combos[i].d2[3]=336.4;
   g_combos[i].d3[0]=446.1; g_combos[i].d3[1]=610.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=94; g_combos[i].nt[1]=65; g_combos[i].nt[2]=106; g_combos[i].nt[3]=72;
   g_combos[i].nok[0]=49; g_combos[i].nok[1]=22; g_combos[i].nok[2]=5; g_combos[i].nok[3]=23;
   i++;

   // BB4SB | ZB/BUY | n_ang=123 | Full Margin | score=465.8
   g_combos[i].code="BB4SB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=123; g_combos[i].tier=1; g_combos[i].signal_score=465.80;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=42.42; g_combos[i].p1[1]=36.84; g_combos[i].p1[2]=4.17; g_combos[i].p1[3]=40.23;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.24; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=242.1; g_combos[i].d1[1]=322.4; g_combos[i].d1[2]=216.8; g_combos[i].d1[3]=378.4;
   g_combos[i].d2[0]=349.0; g_combos[i].d2[1]=529.9; g_combos[i].d2[2]=567.0; g_combos[i].d2[3]=378.4;
   g_combos[i].d3[0]=382.5; g_combos[i].d3[1]=588.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=99; g_combos[i].nt[1]=76; g_combos[i].nt[2]=120; g_combos[i].nt[3]=87;
   g_combos[i].nok[0]=42; g_combos[i].nok[1]=28; g_combos[i].nok[2]=5; g_combos[i].nok[3]=35;
   i++;

   // FB4SB | ZF/BUY | n_ang=119 | Full Margin | score=381.8
   g_combos[i].code="FB4SB"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=119; g_combos[i].tier=1; g_combos[i].signal_score=381.80;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=33.98; g_combos[i].p1[1]=28.36; g_combos[i].p1[2]=9.24; g_combos[i].p1[3]=20.83;
   g_combos[i].p2[0]=65.71; g_combos[i].p2[1]=68.42; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.14; g_combos[i].p3[1]=47.37; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=231.4; g_combos[i].d1[1]=449.9; g_combos[i].d1[2]=209.1; g_combos[i].d1[3]=373.1;
   g_combos[i].d2[0]=376.0; g_combos[i].d2[1]=493.6; g_combos[i].d2[2]=214.9; g_combos[i].d2[3]=373.1;
   g_combos[i].d3[0]=419.6; g_combos[i].d3[1]=500.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=103; g_combos[i].nt[1]=67; g_combos[i].nt[2]=119; g_combos[i].nt[3]=72;
   g_combos[i].nok[0]=35; g_combos[i].nok[1]=19; g_combos[i].nok[2]=11; g_combos[i].nok[3]=15;
   i++;

   // BB4SO | ZB/BUY | n_ang=106 | Full Margin | score=380.9
   g_combos[i].code="BB4SO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=106; g_combos[i].tier=1; g_combos[i].signal_score=380.94;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=41.57; g_combos[i].p1[1]=34.78; g_combos[i].p1[2]=1.89; g_combos[i].p1[3]=27.71;
   g_combos[i].p2[0]=70.27; g_combos[i].p2[1]=70.83; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=54.05; g_combos[i].p3[1]=41.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=238.6; g_combos[i].d1[1]=290.8; g_combos[i].d1[2]=78.5; g_combos[i].d1[3]=436.1;
   g_combos[i].d2[0]=401.0; g_combos[i].d2[1]=315.8; g_combos[i].d2[2]=122.0; g_combos[i].d2[3]=436.1;
   g_combos[i].d3[0]=372.6; g_combos[i].d3[1]=368.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=89; g_combos[i].nt[1]=69; g_combos[i].nt[2]=106; g_combos[i].nt[3]=83;
   g_combos[i].nok[0]=37; g_combos[i].nok[1]=24; g_combos[i].nok[2]=2; g_combos[i].nok[3]=23;
   i++;

   // BB2MB | ZB/BUY | n_ang=111 | Full Margin | score=368.8
   g_combos[i].code="BB2MB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=111; g_combos[i].tier=1; g_combos[i].signal_score=368.75;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=38.46; g_combos[i].p1[1]=33.93; g_combos[i].p1[2]=24.24; g_combos[i].p1[3]=28.00;
   g_combos[i].p2[0]=68.57; g_combos[i].p2[1]=63.16; g_combos[i].p2[2]=54.17; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.71; g_combos[i].p3[1]=57.89; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=176.0; g_combos[i].d1[1]=421.8; g_combos[i].d1[2]=310.9; g_combos[i].d1[3]=436.6;
   g_combos[i].d2[0]=384.9; g_combos[i].d2[1]=591.9; g_combos[i].d2[2]=315.0; g_combos[i].d2[3]=436.6;
   g_combos[i].d3[0]=469.5; g_combos[i].d3[1]=611.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=91; g_combos[i].nt[1]=56; g_combos[i].nt[2]=99; g_combos[i].nt[3]=75;
   g_combos[i].nok[0]=35; g_combos[i].nok[1]=19; g_combos[i].nok[2]=24; g_combos[i].nok[3]=21;
   i++;

   // BB4SE | ZB/BUY | n_ang=98 | Full Margin | score=356.4
   g_combos[i].code="BB4SE"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=98; g_combos[i].tier=1; g_combos[i].signal_score=356.38;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=40.91; g_combos[i].p1[1]=34.48; g_combos[i].p1[2]=1.03; g_combos[i].p1[3]=37.31;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.11; g_combos[i].p3[1]=55.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=209.6; g_combos[i].d1[1]=342.8; g_combos[i].d1[2]=95.0; g_combos[i].d1[3]=328.8;
   g_combos[i].d2[0]=492.3; g_combos[i].d2[1]=390.6; g_combos[i].d2[2]=107.0; g_combos[i].d2[3]=328.8;
   g_combos[i].d3[0]=524.9; g_combos[i].d3[1]=480.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=88; g_combos[i].nt[1]=58; g_combos[i].nt[2]=97; g_combos[i].nt[3]=67;
   g_combos[i].nok[0]=36; g_combos[i].nok[1]=20; g_combos[i].nok[2]=1; g_combos[i].nok[3]=25;
   i++;

   // BB2SF | ZB/BUY | n_ang=76 | Full Margin | score=348.7
   g_combos[i].code="BB2SF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=76; g_combos[i].tier=1; g_combos[i].signal_score=348.71;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=55.56; g_combos[i].p1[1]=46.51; g_combos[i].p1[2]=27.63; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=77.50; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=165.8; g_combos[i].d1[1]=485.0; g_combos[i].d1[2]=274.3; g_combos[i].d1[3]=336.9;
   g_combos[i].d2[0]=374.6; g_combos[i].d2[1]=564.9; g_combos[i].d2[2]=405.1; g_combos[i].d2[3]=336.9;
   g_combos[i].d3[0]=471.8; g_combos[i].d3[1]=652.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=72; g_combos[i].nt[1]=43; g_combos[i].nt[2]=76; g_combos[i].nt[3]=60;
   g_combos[i].nok[0]=40; g_combos[i].nok[1]=20; g_combos[i].nok[2]=21; g_combos[i].nok[3]=30;
   i++;

   // BB3SO | ZB/BUY | n_ang=85 | Full Margin | score=322.7
   g_combos[i].code="BB3SO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=85; g_combos[i].tier=1; g_combos[i].signal_score=322.68;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=46.67; g_combos[i].p1[1]=37.74; g_combos[i].p1[2]=14.81; g_combos[i].p1[3]=42.42;
   g_combos[i].p2[0]=82.86; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=55.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=145.3; g_combos[i].d1[1]=464.6; g_combos[i].d1[2]=308.5; g_combos[i].d1[3]=377.5;
   g_combos[i].d2[0]=309.1; g_combos[i].d2[1]=522.1; g_combos[i].d2[2]=415.1; g_combos[i].d2[3]=377.5;
   g_combos[i].d3[0]=350.2; g_combos[i].d3[1]=629.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=75; g_combos[i].nt[1]=53; g_combos[i].nt[2]=81; g_combos[i].nt[3]=66;
   g_combos[i].nok[0]=35; g_combos[i].nok[1]=20; g_combos[i].nok[2]=12; g_combos[i].nok[3]=28;
   i++;

   // BB3SF | ZB/BUY | n_ang=99 | Full Margin | score=308.4
   g_combos[i].code="BB3SF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=99; g_combos[i].tier=1; g_combos[i].signal_score=308.45;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=38.75; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=14.14; g_combos[i].p1[3]=32.43;
   g_combos[i].p2[0]=70.97; g_combos[i].p2[1]=63.16; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=48.39; g_combos[i].p3[1]=26.32; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=256.3; g_combos[i].d1[1]=338.2; g_combos[i].d1[2]=195.7; g_combos[i].d1[3]=197.8;
   g_combos[i].d2[0]=384.8; g_combos[i].d2[1]=317.5; g_combos[i].d2[2]=322.3; g_combos[i].d2[3]=197.8;
   g_combos[i].d3[0]=386.6; g_combos[i].d3[1]=334.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=80; g_combos[i].nt[1]=57; g_combos[i].nt[2]=99; g_combos[i].nt[3]=74;
   g_combos[i].nok[0]=31; g_combos[i].nok[1]=19; g_combos[i].nok[2]=14; g_combos[i].nok[3]=24;
   i++;

   // EB1LF | ZE/BUY | n_ang=97 | Full Margin | score=305.3
   g_combos[i].code="EB1LF"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=97; g_combos[i].tier=1; g_combos[i].signal_score=305.31;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=38.27; g_combos[i].p1[1]=26.47; g_combos[i].p1[2]=29.27; g_combos[i].p1[3]=19.23;
   g_combos[i].p2[0]=80.65; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=79.17; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=64.52; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=297.1; g_combos[i].d1[1]=367.8; g_combos[i].d1[2]=434.0; g_combos[i].d1[3]=342.3;
   g_combos[i].d2[0]=423.9; g_combos[i].d2[1]=509.7; g_combos[i].d2[2]=516.2; g_combos[i].d2[3]=342.3;
   g_combos[i].d3[0]=513.8; g_combos[i].d3[1]=515.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=81; g_combos[i].nt[1]=68; g_combos[i].nt[2]=82; g_combos[i].nt[3]=78;
   g_combos[i].nok[0]=31; g_combos[i].nok[1]=18; g_combos[i].nok[2]=24; g_combos[i].nok[3]=15;
   i++;

   // BB2SB | ZB/BUY | n_ang=71 | Full Margin | score=278.1
   g_combos[i].code="BB2SB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=71; g_combos[i].tier=1; g_combos[i].signal_score=278.06;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=53.23; g_combos[i].p1[1]=39.47; g_combos[i].p1[2]=26.09; g_combos[i].p1[3]=46.30;
   g_combos[i].p2[0]=69.70; g_combos[i].p2[1]=53.33; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.45; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=242.0; g_combos[i].d1[1]=361.5; g_combos[i].d1[2]=123.8; g_combos[i].d1[3]=318.8;
   g_combos[i].d2[0]=482.2; g_combos[i].d2[1]=394.1; g_combos[i].d2[2]=325.4; g_combos[i].d2[3]=318.8;
   g_combos[i].d3[0]=522.5; g_combos[i].d3[1]=489.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=62; g_combos[i].nt[1]=38; g_combos[i].nt[2]=69; g_combos[i].nt[3]=54;
   g_combos[i].nok[0]=33; g_combos[i].nok[1]=15; g_combos[i].nok[2]=18; g_combos[i].nok[3]=25;
   i++;

   // BB3SB | ZB/BUY | n_ang=88 | Full Margin | score=243.9
   g_combos[i].code="BB3SB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=88; g_combos[i].tier=1; g_combos[i].signal_score=243.90;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=27.78; g_combos[i].p1[2]=18.18; g_combos[i].p1[3]=38.33;
   g_combos[i].p2[0]=69.23; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.85; g_combos[i].p3[1]=53.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=274.4; g_combos[i].d1[1]=421.0; g_combos[i].d1[2]=293.8; g_combos[i].d1[3]=374.3;
   g_combos[i].d2[0]=455.9; g_combos[i].d2[1]=504.0; g_combos[i].d2[2]=437.4; g_combos[i].d2[3]=374.3;
   g_combos[i].d3[0]=422.6; g_combos[i].d3[1]=622.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=78; g_combos[i].nt[1]=54; g_combos[i].nt[2]=88; g_combos[i].nt[3]=60;
   g_combos[i].nok[0]=26; g_combos[i].nok[1]=15; g_combos[i].nok[2]=16; g_combos[i].nok[3]=23;
   i++;

   // DB4SO | ZD/BUY | n_ang=63 | Full Margin | score=238.1
   g_combos[i].code="DB4SO"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=63; g_combos[i].tier=1; g_combos[i].signal_score=238.12;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=55.56; g_combos[i].p1[1]=36.59; g_combos[i].p1[2]=6.45; g_combos[i].p1[3]=46.51;
   g_combos[i].p2[0]=56.67; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=56.67; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=162.7; g_combos[i].d1[1]=331.4; g_combos[i].d1[2]=20.5; g_combos[i].d1[3]=240.2;
   g_combos[i].d2[0]=290.3; g_combos[i].d2[1]=370.2; g_combos[i].d2[2]=36.2; g_combos[i].d2[3]=240.2;
   g_combos[i].d3[0]=333.6; g_combos[i].d3[1]=505.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=54; g_combos[i].nt[1]=41; g_combos[i].nt[2]=62; g_combos[i].nt[3]=43;
   g_combos[i].nok[0]=30; g_combos[i].nok[1]=15; g_combos[i].nok[2]=4; g_combos[i].nok[3]=20;
   i++;

   // EB2MF | ZE/BUY | n_ang=89 | Full Margin | score=226.4
   g_combos[i].code="EB2MF"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=89; g_combos[i].tier=1; g_combos[i].signal_score=226.42;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=29.51; g_combos[i].p1[1]=31.43; g_combos[i].p1[2]=33.80; g_combos[i].p1[3]=22.78;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=45.45; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.11; g_combos[i].p3[1]=45.45; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=386.4; g_combos[i].d1[1]=411.2; g_combos[i].d1[2]=427.0; g_combos[i].d1[3]=301.8;
   g_combos[i].d2[0]=414.9; g_combos[i].d2[1]=443.3; g_combos[i].d2[2]=473.7; g_combos[i].d2[3]=301.8;
   g_combos[i].d3[0]=548.1; g_combos[i].d3[1]=455.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=61; g_combos[i].nt[1]=70; g_combos[i].nt[2]=71; g_combos[i].nt[3]=79;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=22; g_combos[i].nok[2]=24; g_combos[i].nok[3]=18;
   i++;

   // EB1LB | ZE/BUY | n_ang=91 | Full Margin | score=219.4
   g_combos[i].code="EB1LB"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=91; g_combos[i].tier=1; g_combos[i].signal_score=219.41;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=33.82; g_combos[i].p1[1]=38.18; g_combos[i].p1[2]=27.54; g_combos[i].p1[3]=22.22;
   g_combos[i].p2[0]=82.61; g_combos[i].p2[1]=47.62; g_combos[i].p2[2]=63.16; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.83; g_combos[i].p3[1]=47.62; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=348.9; g_combos[i].d1[1]=375.1; g_combos[i].d1[2]=263.2; g_combos[i].d1[3]=337.4;
   g_combos[i].d2[0]=383.9; g_combos[i].d2[1]=456.5; g_combos[i].d2[2]=387.9; g_combos[i].d2[3]=337.4;
   g_combos[i].d3[0]=456.9; g_combos[i].d3[1]=467.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=68; g_combos[i].nt[1]=55; g_combos[i].nt[2]=69; g_combos[i].nt[3]=72;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=21; g_combos[i].nok[2]=19; g_combos[i].nok[3]=16;
   i++;

   // DB2SB | ZD/BUY | n_ang=58 | Full Margin | score=213.2
   g_combos[i].code="DB2SB"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=58; g_combos[i].tier=1; g_combos[i].signal_score=213.24;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=54.90; g_combos[i].p1[1]=57.50; g_combos[i].p1[2]=26.79; g_combos[i].p1[3]=34.09;
   g_combos[i].p2[0]=78.57; g_combos[i].p2[1]=60.87; g_combos[i].p2[2]=86.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=67.86; g_combos[i].p3[1]=47.83; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=223.0; g_combos[i].d1[1]=336.5; g_combos[i].d1[2]=191.5; g_combos[i].d1[3]=270.4;
   g_combos[i].d2[0]=309.3; g_combos[i].d2[1]=412.6; g_combos[i].d2[2]=260.5; g_combos[i].d2[3]=270.4;
   g_combos[i].d3[0]=434.5; g_combos[i].d3[1]=389.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=51; g_combos[i].nt[1]=40; g_combos[i].nt[2]=56; g_combos[i].nt[3]=44;
   g_combos[i].nok[0]=28; g_combos[i].nok[1]=23; g_combos[i].nok[2]=15; g_combos[i].nok[3]=15;
   i++;

   // BB2MF | ZB/BUY | n_ang=85 | Full Margin | score=212.1
   g_combos[i].code="BB2MF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=85; g_combos[i].tier=1; g_combos[i].signal_score=212.05;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=34.33; g_combos[i].p1[1]=21.43; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=36.84;
   g_combos[i].p2[0]=69.57; g_combos[i].p2[1]=55.56; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=39.13; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=259.5; g_combos[i].d1[1]=473.0; g_combos[i].d1[2]=241.1; g_combos[i].d1[3]=419.6;
   g_combos[i].d2[0]=462.1; g_combos[i].d2[1]=656.6; g_combos[i].d2[2]=469.1; g_combos[i].d2[3]=419.6;
   g_combos[i].d3[0]=445.7; g_combos[i].d3[1]=555.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=67; g_combos[i].nt[1]=42; g_combos[i].nt[2]=78; g_combos[i].nt[3]=57;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=9; g_combos[i].nok[2]=18; g_combos[i].nok[3]=21;
   i++;

   // BB4SG | ZB/BUY | n_ang=75 | Full Margin | score=190.5
   g_combos[i].code="BB4SG"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=75; g_combos[i].tier=1; g_combos[i].signal_score=190.53;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=42.22; g_combos[i].p1[2]=2.67; g_combos[i].p1[3]=41.18;
   g_combos[i].p2[0]=54.55; g_combos[i].p2[1]=73.68; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=31.58; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=322.8; g_combos[i].d1[1]=515.2; g_combos[i].d1[2]=59.0; g_combos[i].d1[3]=430.7;
   g_combos[i].d2[0]=530.1; g_combos[i].d2[1]=522.0; g_combos[i].d2[2]=91.0; g_combos[i].d2[3]=430.7;
   g_combos[i].d3[0]=561.7; g_combos[i].d3[1]=534.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=66; g_combos[i].nt[1]=45; g_combos[i].nt[2]=75; g_combos[i].nt[3]=51;
   g_combos[i].nok[0]=22; g_combos[i].nok[1]=19; g_combos[i].nok[2]=2; g_combos[i].nok[3]=21;
   i++;

   // FB4SG | ZF/BUY | n_ang=97 | Full Margin | score=187.1
   g_combos[i].code="FB4SG"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=97; g_combos[i].tier=1; g_combos[i].signal_score=187.13;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=21.18; g_combos[i].p1[1]=31.67; g_combos[i].p1[2]=8.33; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=89.47; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=68.42; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=203.7; g_combos[i].d1[1]=441.1; g_combos[i].d1[2]=277.8; g_combos[i].d1[3]=481.7;
   g_combos[i].d2[0]=410.2; g_combos[i].d2[1]=467.7; g_combos[i].d2[2]=306.9; g_combos[i].d2[3]=481.7;
   g_combos[i].d3[0]=421.4; g_combos[i].d3[1]=548.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=85; g_combos[i].nt[1]=60; g_combos[i].nt[2]=96; g_combos[i].nt[3]=60;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=19; g_combos[i].nok[2]=8; g_combos[i].nok[3]=15;
   i++;

   // BB4SD | ZB/BUY | n_ang=70 | Full Margin | score=184.1
   g_combos[i].code="BB4SD"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=70; g_combos[i].tier=1; g_combos[i].signal_score=184.07;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=34.92; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=2.86; g_combos[i].p1[3]=42.55;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=84.62; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=30.77; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=149.2; g_combos[i].d1[1]=428.7; g_combos[i].d1[2]=282.0; g_combos[i].d1[3]=327.0;
   g_combos[i].d2[0]=424.4; g_combos[i].d2[1]=525.0; g_combos[i].d2[2]=336.0; g_combos[i].d2[3]=327.0;
   g_combos[i].d3[0]=496.1; g_combos[i].d3[1]=743.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=63; g_combos[i].nt[1]=39; g_combos[i].nt[2]=70; g_combos[i].nt[3]=47;
   g_combos[i].nok[0]=22; g_combos[i].nok[1]=13; g_combos[i].nok[2]=2; g_combos[i].nok[3]=20;
   i++;

   // EB2MB | ZE/BUY | n_ang=83 | Full Margin | score=182.2
   g_combos[i].code="EB2MB"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=83; g_combos[i].tier=1; g_combos[i].signal_score=182.21;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=21.67; g_combos[i].p1[1]=32.69; g_combos[i].p1[2]=30.30; g_combos[i].p1[3]=30.30;
   g_combos[i].p2[0]=46.15; g_combos[i].p2[1]=82.35; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=30.77; g_combos[i].p3[1]=64.71; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=311.6; g_combos[i].d1[1]=367.3; g_combos[i].d1[2]=317.9; g_combos[i].d1[3]=291.4;
   g_combos[i].d2[0]=456.8; g_combos[i].d2[1]=522.6; g_combos[i].d2[2]=337.8; g_combos[i].d2[3]=291.4;
   g_combos[i].d3[0]=410.0; g_combos[i].d3[1]=493.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=60; g_combos[i].nt[1]=52; g_combos[i].nt[2]=66; g_combos[i].nt[3]=66;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=17; g_combos[i].nok[2]=20; g_combos[i].nok[3]=20;
   i++;

   // FB4SE | ZF/BUY | n_ang=114 | Full Margin | score=181.5
   g_combos[i].code="FB4SE"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=114; g_combos[i].tier=1; g_combos[i].signal_score=181.51;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=18.28; g_combos[i].p1[1]=20.27; g_combos[i].p1[2]=6.19; g_combos[i].p1[3]=16.00;
   g_combos[i].p2[0]=47.06; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.06; g_combos[i].p3[1]=53.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=241.1; g_combos[i].d1[1]=306.1; g_combos[i].d1[2]=244.6; g_combos[i].d1[3]=501.6;
   g_combos[i].d2[0]=457.1; g_combos[i].d2[1]=457.6; g_combos[i].d2[2]=255.3; g_combos[i].d2[3]=501.6;
   g_combos[i].d3[0]=487.5; g_combos[i].d3[1]=522.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=93; g_combos[i].nt[1]=74; g_combos[i].nt[2]=113; g_combos[i].nt[3]=75;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=15; g_combos[i].nok[2]=7; g_combos[i].nok[3]=12;
   i++;

   // DB2SO | ZD/BUY | n_ang=48 | Full Margin | score=180.1
   g_combos[i].code="DB2SO"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=48; g_combos[i].tier=1; g_combos[i].signal_score=180.13;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=56.52; g_combos[i].p1[1]=53.33; g_combos[i].p1[2]=19.15; g_combos[i].p1[3]=55.00;
   g_combos[i].p2[0]=76.92; g_combos[i].p2[1]=93.75; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.85; g_combos[i].p3[1]=81.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=221.2; g_combos[i].d1[1]=325.1; g_combos[i].d1[2]=205.7; g_combos[i].d1[3]=301.5;
   g_combos[i].d2[0]=414.6; g_combos[i].d2[1]=415.7; g_combos[i].d2[2]=329.1; g_combos[i].d2[3]=301.5;
   g_combos[i].d3[0]=484.0; g_combos[i].d3[1]=508.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=30; g_combos[i].nt[2]=47; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=26; g_combos[i].nok[1]=16; g_combos[i].nok[2]=9; g_combos[i].nok[3]=22;
   i++;

   // BB3SE | ZB/BUY | n_ang=65 | Full Margin | score=177.4
   g_combos[i].code="BB3SE"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=65; g_combos[i].tier=1; g_combos[i].signal_score=177.37;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=40.74; g_combos[i].p1[1]=40.00; g_combos[i].p1[2]=14.06; g_combos[i].p1[3]=37.25;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=68.75; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=54.55; g_combos[i].p3[1]=56.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=250.2; g_combos[i].d1[1]=341.9; g_combos[i].d1[2]=264.8; g_combos[i].d1[3]=310.4;
   g_combos[i].d2[0]=373.7; g_combos[i].d2[1]=444.1; g_combos[i].d2[2]=298.8; g_combos[i].d2[3]=310.4;
   g_combos[i].d3[0]=397.2; g_combos[i].d3[1]=564.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=54; g_combos[i].nt[1]=40; g_combos[i].nt[2]=64; g_combos[i].nt[3]=51;
   g_combos[i].nok[0]=22; g_combos[i].nok[1]=16; g_combos[i].nok[2]=9; g_combos[i].nok[3]=19;
   i++;

   // BB2SO | ZB/BUY | n_ang=50 | Full Margin | score=162.6
   g_combos[i].code="BB2SO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=50; g_combos[i].tier=1; g_combos[i].signal_score=162.63;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=51.11; g_combos[i].p1[1]=62.07; g_combos[i].p1[2]=42.00; g_combos[i].p1[3]=40.91;
   g_combos[i].p2[0]=73.91; g_combos[i].p2[1]=77.78; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=43.48; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=214.6; g_combos[i].d1[1]=297.1; g_combos[i].d1[2]=164.1; g_combos[i].d1[3]=244.2;
   g_combos[i].d2[0]=340.9; g_combos[i].d2[1]=391.1; g_combos[i].d2[2]=370.8; g_combos[i].d2[3]=244.2;
   g_combos[i].d3[0]=450.8; g_combos[i].d3[1]=468.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=45; g_combos[i].nt[1]=29; g_combos[i].nt[2]=50; g_combos[i].nt[3]=44;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=18; g_combos[i].nok[2]=21; g_combos[i].nok[3]=18;
   i++;

   // FB4SO | ZF/BUY | n_ang=103 | Full Margin | score=162.4
   g_combos[i].code="FB4SO"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=103; g_combos[i].tier=1; g_combos[i].signal_score=162.38;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=18.18; g_combos[i].p1[1]=16.98; g_combos[i].p1[2]=3.88; g_combos[i].p1[3]=17.86;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=77.78; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=37.50; g_combos[i].p3[1]=55.56; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=195.4; g_combos[i].d1[1]=269.9; g_combos[i].d1[2]=453.5; g_combos[i].d1[3]=284.1;
   g_combos[i].d2[0]=499.2; g_combos[i].d2[1]=342.0; g_combos[i].d2[2]=460.2; g_combos[i].d2[3]=284.1;
   g_combos[i].d3[0]=575.7; g_combos[i].d3[1]=369.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=88; g_combos[i].nt[1]=53; g_combos[i].nt[2]=103; g_combos[i].nt[3]=56;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=9; g_combos[i].nok[2]=4; g_combos[i].nok[3]=10;
   i++;

   // EB2MO | ZE/BUY | n_ang=73 | Full Margin | score=162.3
   g_combos[i].code="EB2MO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=73; g_combos[i].tier=1; g_combos[i].signal_score=162.34;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=32.20; g_combos[i].p1[1]=35.56; g_combos[i].p1[2]=14.06; g_combos[i].p1[3]=29.09;
   g_combos[i].p2[0]=63.16; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=88.89; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.89; g_combos[i].p3[1]=56.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=254.5; g_combos[i].d1[1]=329.3; g_combos[i].d1[2]=282.0; g_combos[i].d1[3]=287.1;
   g_combos[i].d2[0]=323.1; g_combos[i].d2[1]=448.9; g_combos[i].d2[2]=371.8; g_combos[i].d2[3]=287.1;
   g_combos[i].d3[0]=453.4; g_combos[i].d3[1]=486.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=59; g_combos[i].nt[1]=45; g_combos[i].nt[2]=64; g_combos[i].nt[3]=55;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=16; g_combos[i].nok[2]=9; g_combos[i].nok[3]=16;
   i++;

   // FB4SD | ZF/BUY | n_ang=70 | Full Margin | score=159.0
   g_combos[i].code="FB4SD"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=70; g_combos[i].tier=1; g_combos[i].signal_score=158.97;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=24.56; g_combos[i].p1[1]=29.27; g_combos[i].p1[2]=11.43; g_combos[i].p1[3]=41.30;
   g_combos[i].p2[0]=42.86; g_combos[i].p2[1]=91.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=35.71; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=292.5; g_combos[i].d1[1]=548.8; g_combos[i].d1[2]=254.5; g_combos[i].d1[3]=400.8;
   g_combos[i].d2[0]=473.7; g_combos[i].d2[1]=580.5; g_combos[i].d2[2]=290.1; g_combos[i].d2[3]=400.8;
   g_combos[i].d3[0]=456.4; g_combos[i].d3[1]=590.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=57; g_combos[i].nt[1]=41; g_combos[i].nt[2]=70; g_combos[i].nt[3]=46;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=12; g_combos[i].nok[2]=8; g_combos[i].nok[3]=19;
   i++;

   // BB4SC | ZB/BUY | n_ang=69 | Full Margin | score=157.8
   g_combos[i].code="BB4SC"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=69; g_combos[i].tier=1; g_combos[i].signal_score=157.83;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=32.76; g_combos[i].p1[1]=42.22; g_combos[i].p1[2]=8.70; g_combos[i].p1[3]=22.22;
   g_combos[i].p2[0]=63.16; g_combos[i].p2[1]=84.21; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.89; g_combos[i].p3[1]=57.89; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=169.4; g_combos[i].d1[1]=298.7; g_combos[i].d1[2]=179.3; g_combos[i].d1[3]=461.3;
   g_combos[i].d2[0]=339.4; g_combos[i].d2[1]=396.7; g_combos[i].d2[2]=249.2; g_combos[i].d2[3]=461.3;
   g_combos[i].d3[0]=360.2; g_combos[i].d3[1]=395.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=58; g_combos[i].nt[1]=45; g_combos[i].nt[2]=69; g_combos[i].nt[3]=45;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=19; g_combos[i].nok[2]=6; g_combos[i].nok[3]=10;
   i++;

   // EB2LB | ZE/BUY | n_ang=76 | Full Margin | score=156.9
   g_combos[i].code="EB2LB"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=76; g_combos[i].tier=1; g_combos[i].signal_score=156.92;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.00; g_combos[i].p1[1]=31.25; g_combos[i].p1[2]=22.58; g_combos[i].p1[3]=22.41;
   g_combos[i].p2[0]=94.44; g_combos[i].p2[1]=86.67; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=77.78; g_combos[i].p3[1]=86.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=251.1; g_combos[i].d1[1]=291.0; g_combos[i].d1[2]=320.9; g_combos[i].d1[3]=364.9;
   g_combos[i].d2[0]=325.2; g_combos[i].d2[1]=459.8; g_combos[i].d2[2]=485.1; g_combos[i].d2[3]=364.9;
   g_combos[i].d3[0]=428.9; g_combos[i].d3[1]=468.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=60; g_combos[i].nt[1]=48; g_combos[i].nt[2]=62; g_combos[i].nt[3]=58;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=15; g_combos[i].nok[2]=14; g_combos[i].nok[3]=13;
   i++;

   // EB2LF | ZE/BUY | n_ang=83 | Strong | score=154.9
   g_combos[i].code="EB2LF"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=83; g_combos[i].tier=2; g_combos[i].signal_score=154.88;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=19.12; g_combos[i].p1[3]=28.81;
   g_combos[i].p2[0]=53.33; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=61.54; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=356.6; g_combos[i].d1[1]=342.5; g_combos[i].d1[2]=391.5; g_combos[i].d1[3]=504.6;
   g_combos[i].d2[0]=417.9; g_combos[i].d2[1]=619.0; g_combos[i].d2[2]=403.4; g_combos[i].d2[3]=504.6;
   g_combos[i].d3[0]=452.5; g_combos[i].d3[1]=622.1; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=65; g_combos[i].nt[1]=48; g_combos[i].nt[2]=68; g_combos[i].nt[3]=59;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=12; g_combos[i].nok[2]=13; g_combos[i].nok[3]=17;
   i++;

   // BB3SC | ZB/BUY | n_ang=44 | Strong | score=152.6
   g_combos[i].code="BB3SC"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=44; g_combos[i].tier=2; g_combos[i].signal_score=152.56;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=56.10; g_combos[i].p1[1]=41.38; g_combos[i].p1[2]=11.36; g_combos[i].p1[3]=27.27;
   g_combos[i].p2[0]=60.87; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=43.48; g_combos[i].p3[1]=58.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=241.9; g_combos[i].d1[1]=371.3; g_combos[i].d1[2]=163.6; g_combos[i].d1[3]=361.1;
   g_combos[i].d2[0]=345.4; g_combos[i].d2[1]=474.7; g_combos[i].d2[2]=189.0; g_combos[i].d2[3]=361.1;
   g_combos[i].d3[0]=444.5; g_combos[i].d3[1]=490.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=41; g_combos[i].nt[1]=29; g_combos[i].nt[2]=44; g_combos[i].nt[3]=33;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=12; g_combos[i].nok[2]=5; g_combos[i].nok[3]=9;
   i++;

   // BB3SG | ZB/BUY | n_ang=63 | Strong | score=150.8
   g_combos[i].code="BB3SG"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=63; g_combos[i].tier=2; g_combos[i].signal_score=150.81;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=29.82; g_combos[i].p1[1]=30.00; g_combos[i].p1[2]=17.74; g_combos[i].p1[3]=39.58;
   g_combos[i].p2[0]=70.59; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=41.18; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=139.2; g_combos[i].d1[1]=470.6; g_combos[i].d1[2]=339.1; g_combos[i].d1[3]=314.6;
   g_combos[i].d2[0]=394.5; g_combos[i].d2[1]=552.0; g_combos[i].d2[2]=379.4; g_combos[i].d2[3]=314.6;
   g_combos[i].d3[0]=625.1; g_combos[i].d3[1]=665.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=57; g_combos[i].nt[1]=40; g_combos[i].nt[2]=62; g_combos[i].nt[3]=48;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=12; g_combos[i].nok[2]=11; g_combos[i].nok[3]=19;
   i++;

   // DB4SD | ZD/BUY | n_ang=51 | Strong | score=150.0
   g_combos[i].code="DB4SD"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=51; g_combos[i].tier=2; g_combos[i].signal_score=149.97;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=45.65; g_combos[i].p1[1]=22.86; g_combos[i].p1[2]=4.00; g_combos[i].p1[3]=27.78;
   g_combos[i].p2[0]=61.90; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.14; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=127.5; g_combos[i].d1[1]=230.5; g_combos[i].d1[2]=17.5; g_combos[i].d1[3]=274.5;
   g_combos[i].d2[0]=279.9; g_combos[i].d2[1]=309.3; g_combos[i].d2[2]=18.0; g_combos[i].d2[3]=274.5;
   g_combos[i].d3[0]=319.2; g_combos[i].d3[1]=442.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=35; g_combos[i].nt[2]=50; g_combos[i].nt[3]=36;
   g_combos[i].nok[0]=21; g_combos[i].nok[1]=8; g_combos[i].nok[2]=2; g_combos[i].nok[3]=10;
   i++;

   // BB3SD | ZB/BUY | n_ang=57 | Strong | score=143.4
   g_combos[i].code="BB3SD"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=57; g_combos[i].tier=2; g_combos[i].signal_score=143.45;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=40.91; g_combos[i].p1[1]=34.09; g_combos[i].p1[2]=22.22; g_combos[i].p1[3]=36.54;
   g_combos[i].p2[0]=72.22; g_combos[i].p2[1]=73.33; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=55.56; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=160.0; g_combos[i].d1[1]=286.7; g_combos[i].d1[2]=208.9; g_combos[i].d1[3]=356.1;
   g_combos[i].d2[0]=423.4; g_combos[i].d2[1]=531.9; g_combos[i].d2[2]=338.1; g_combos[i].d2[3]=356.1;
   g_combos[i].d3[0]=410.9; g_combos[i].d3[1]=538.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=44; g_combos[i].nt[1]=44; g_combos[i].nt[2]=54; g_combos[i].nt[3]=52;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=15; g_combos[i].nok[2]=12; g_combos[i].nok[3]=19;
   i++;

   // DB3SF | ZD/BUY | n_ang=54 | Strong | score=139.6
   g_combos[i].code="DB3SF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=54; g_combos[i].tier=2; g_combos[i].signal_score=139.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=38.78; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=14.81; g_combos[i].p1[3]=37.14;
   g_combos[i].p2[0]=78.95; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=52.63; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=337.2; g_combos[i].d1[1]=330.3; g_combos[i].d1[2]=148.1; g_combos[i].d1[3]=327.0;
   g_combos[i].d2[0]=554.3; g_combos[i].d2[1]=585.2; g_combos[i].d2[2]=333.2; g_combos[i].d2[3]=327.0;
   g_combos[i].d3[0]=480.5; g_combos[i].d3[1]=664.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=49; g_combos[i].nt[1]=30; g_combos[i].nt[2]=54; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=10; g_combos[i].nok[2]=8; g_combos[i].nok[3]=13;
   i++;

   // BB2MO | ZB/BUY | n_ang=65 | Strong | score=137.1
   g_combos[i].code="BB2MO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=65; g_combos[i].tier=2; g_combos[i].signal_score=137.06;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=21.82; g_combos[i].p1[1]=26.47; g_combos[i].p1[2]=27.42; g_combos[i].p1[3]=20.93;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=44.44; g_combos[i].p2[2]=76.47; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=44.44; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=363.2; g_combos[i].d1[1]=501.8; g_combos[i].d1[2]=303.3; g_combos[i].d1[3]=280.2;
   g_combos[i].d2[0]=487.2; g_combos[i].d2[1]=622.8; g_combos[i].d2[2]=441.5; g_combos[i].d2[3]=280.2;
   g_combos[i].d3[0]=640.8; g_combos[i].d3[1]=670.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=55; g_combos[i].nt[1]=34; g_combos[i].nt[2]=62; g_combos[i].nt[3]=43;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=9; g_combos[i].nok[2]=17; g_combos[i].nok[3]=9;
   i++;

   // EB2ME | ZE/BUY | n_ang=52 | Strong | score=137.0
   g_combos[i].code="EB2ME"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=52; g_combos[i].tier=2; g_combos[i].signal_score=137.01;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=36.11; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=32.50; g_combos[i].p1[3]=41.30;
   g_combos[i].p2[0]=76.92; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=69.23; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.54; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=383.8; g_combos[i].d1[1]=293.2; g_combos[i].d1[2]=291.5; g_combos[i].d1[3]=248.2;
   g_combos[i].d2[0]=301.6; g_combos[i].d2[1]=393.7; g_combos[i].d2[2]=485.6; g_combos[i].d2[3]=248.2;
   g_combos[i].d3[0]=481.2; g_combos[i].d3[1]=355.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=36; g_combos[i].nt[1]=36; g_combos[i].nt[2]=40; g_combos[i].nt[3]=46;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=8; g_combos[i].nok[2]=13; g_combos[i].nok[3]=19;
   i++;

   // BB2MD | ZB/BUY | n_ang=57 | Strong | score=135.9
   g_combos[i].code="BB2MD"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=57; g_combos[i].tier=2; g_combos[i].signal_score=135.90;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=40.00; g_combos[i].p1[2]=22.22; g_combos[i].p1[3]=36.36;
   g_combos[i].p2[0]=72.22; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=263.3; g_combos[i].d1[1]=306.7; g_combos[i].d1[2]=159.6; g_combos[i].d1[3]=365.2;
   g_combos[i].d2[0]=322.0; g_combos[i].d2[1]=390.7; g_combos[i].d2[2]=269.2; g_combos[i].d2[3]=365.2;
   g_combos[i].d3[0]=410.0; g_combos[i].d3[1]=405.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=48; g_combos[i].nt[1]=40; g_combos[i].nt[2]=54; g_combos[i].nt[3]=44;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=16; g_combos[i].nok[2]=12; g_combos[i].nok[3]=16;
   i++;

   // DB2MB | ZD/BUY | n_ang=54 | Strong | score=132.3
   g_combos[i].code="DB2MB"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=54; g_combos[i].tier=2; g_combos[i].signal_score=132.27;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=39.13; g_combos[i].p1[1]=32.50; g_combos[i].p1[2]=34.00; g_combos[i].p1[3]=31.11;
   g_combos[i].p2[0]=72.22; g_combos[i].p2[1]=84.62; g_combos[i].p2[2]=70.59; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=76.92; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=273.2; g_combos[i].d1[1]=268.8; g_combos[i].d1[2]=257.6; g_combos[i].d1[3]=378.8;
   g_combos[i].d2[0]=291.6; g_combos[i].d2[1]=450.4; g_combos[i].d2[2]=327.2; g_combos[i].d2[3]=378.8;
   g_combos[i].d3[0]=290.6; g_combos[i].d3[1]=483.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=40; g_combos[i].nt[2]=50; g_combos[i].nt[3]=45;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=13; g_combos[i].nok[2]=17; g_combos[i].nok[3]=14;
   i++;

   // FB4SF | ZF/BUY | n_ang=85 | Strong | score=129.1
   g_combos[i].code="FB4SF"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=85; g_combos[i].tier=2; g_combos[i].signal_score=129.07;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=18.06; g_combos[i].p1[1]=13.73; g_combos[i].p1[2]=8.33; g_combos[i].p1[3]=26.42;
   g_combos[i].p2[0]=53.85; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.85; g_combos[i].p3[1]=28.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=129.6; g_combos[i].d1[1]=517.7; g_combos[i].d1[2]=339.1; g_combos[i].d1[3]=448.6;
   g_combos[i].d2[0]=266.9; g_combos[i].d2[1]=559.7; g_combos[i].d2[2]=255.0; g_combos[i].d2[3]=448.6;
   g_combos[i].d3[0]=270.1; g_combos[i].d3[1]=425.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=72; g_combos[i].nt[1]=51; g_combos[i].nt[2]=84; g_combos[i].nt[3]=53;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=7; g_combos[i].nok[2]=7; g_combos[i].nok[3]=14;
   i++;

   // DB4SF | ZD/BUY | n_ang=56 | Strong | score=127.2
   g_combos[i].code="DB4SF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=56; g_combos[i].tier=2; g_combos[i].signal_score=127.22;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=34.69; g_combos[i].p1[1]=34.15; g_combos[i].p1[2]=7.14; g_combos[i].p1[3]=27.27;
   g_combos[i].p2[0]=76.47; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.59; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=90.5; g_combos[i].d1[1]=349.5; g_combos[i].d1[2]=94.5; g_combos[i].d1[3]=325.4;
   g_combos[i].d2[0]=279.4; g_combos[i].d2[1]=409.1; g_combos[i].d2[2]=102.5; g_combos[i].d2[3]=325.4;
   g_combos[i].d3[0]=353.6; g_combos[i].d3[1]=352.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=49; g_combos[i].nt[1]=41; g_combos[i].nt[2]=56; g_combos[i].nt[3]=44;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=14; g_combos[i].nok[2]=4; g_combos[i].nok[3]=12;
   i++;

   // DB4SB | ZD/BUY | n_ang=51 | Strong | score=121.4
   g_combos[i].code="DB4SB"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=51; g_combos[i].tier=2; g_combos[i].signal_score=121.40;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=36.96; g_combos[i].p1[1]=28.95; g_combos[i].p1[2]=3.92; g_combos[i].p1[3]=28.21;
   g_combos[i].p2[0]=76.47; g_combos[i].p2[1]=81.82; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.59; g_combos[i].p3[1]=72.73; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=98.6; g_combos[i].d1[1]=298.5; g_combos[i].d1[2]=231.5; g_combos[i].d1[3]=312.3;
   g_combos[i].d2[0]=322.4; g_combos[i].d2[1]=362.9; g_combos[i].d2[2]=250.0; g_combos[i].d2[3]=312.3;
   g_combos[i].d3[0]=328.2; g_combos[i].d3[1]=403.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=38; g_combos[i].nt[2]=51; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=11; g_combos[i].nok[2]=2; g_combos[i].nok[3]=11;
   i++;

   // EB1MF | ZE/BUY | n_ang=44 | Strong | score=119.4
   g_combos[i].code="EB1MF"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=44; g_combos[i].tier=2; g_combos[i].signal_score=119.40;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=47.22; g_combos[i].p1[1]=60.71; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=76.47; g_combos[i].p2[1]=52.94; g_combos[i].p2[2]=53.85; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=29.41; g_combos[i].p3[1]=41.18; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=225.0; g_combos[i].d1[1]=413.6; g_combos[i].d1[2]=320.9; g_combos[i].d1[3]=353.2;
   g_combos[i].d2[0]=443.7; g_combos[i].d2[1]=545.0; g_combos[i].d2[2]=524.9; g_combos[i].d2[3]=353.2;
   g_combos[i].d3[0]=738.4; g_combos[i].d3[1]=545.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=36; g_combos[i].nt[1]=28; g_combos[i].nt[2]=39; g_combos[i].nt[3]=36;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=17; g_combos[i].nok[2]=13; g_combos[i].nok[3]=18;
   i++;

   // DB2MO | ZD/BUY | n_ang=42 | Strong | score=116.7
   g_combos[i].code="DB2MO"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=42; g_combos[i].tier=2; g_combos[i].signal_score=116.65;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=53.33; g_combos[i].p1[2]=43.90; g_combos[i].p1[3]=18.18;
   g_combos[i].p2[0]=85.71; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=88.89; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=81.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=287.9; g_combos[i].d1[1]=321.1; g_combos[i].d1[2]=205.7; g_combos[i].d1[3]=194.0;
   g_combos[i].d2[0]=300.8; g_combos[i].d2[1]=485.4; g_combos[i].d2[2]=225.8; g_combos[i].d2[3]=194.0;
   g_combos[i].d3[0]=367.6; g_combos[i].d3[1]=597.6; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=30; g_combos[i].nt[2]=41; g_combos[i].nt[3]=33;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=16; g_combos[i].nok[2]=18; g_combos[i].nok[3]=6;
   i++;

   // EB1LO | ZE/BUY | n_ang=52 | Strong | score=115.4
   g_combos[i].code="EB1LO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=52; g_combos[i].tier=2; g_combos[i].signal_score=115.38;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=24.32; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=28.21; g_combos[i].p1[3]=35.56;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=41.67; g_combos[i].p2[2]=72.73; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=41.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=199.0; g_combos[i].d1[1]=350.9; g_combos[i].d1[2]=305.0; g_combos[i].d1[3]=500.6;
   g_combos[i].d2[0]=273.0; g_combos[i].d2[1]=468.2; g_combos[i].d2[2]=377.0; g_combos[i].d2[3]=500.6;
   g_combos[i].d3[0]=287.2; g_combos[i].d3[1]=472.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=37; g_combos[i].nt[1]=33; g_combos[i].nt[2]=39; g_combos[i].nt[3]=45;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=12; g_combos[i].nok[2]=11; g_combos[i].nok[3]=16;
   i++;

   // HB4SB | ZH/BUY | n_ang=46 | Strong | score=115.3
   g_combos[i].code="HB4SB"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=46; g_combos[i].tier=2; g_combos[i].signal_score=115.30;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=40.48; g_combos[i].p1[1]=37.14; g_combos[i].p1[2]=6.52; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=70.59; g_combos[i].p2[1]=92.31; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.59; g_combos[i].p3[1]=69.23; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=74.8; g_combos[i].d1[1]=216.8; g_combos[i].d1[2]=262.7; g_combos[i].d1[3]=243.9;
   g_combos[i].d2[0]=154.9; g_combos[i].d2[1]=238.6; g_combos[i].d2[2]=288.7; g_combos[i].d2[3]=243.9;
   g_combos[i].d3[0]=156.9; g_combos[i].d3[1]=324.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=42; g_combos[i].nt[1]=35; g_combos[i].nt[2]=46; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=13; g_combos[i].nok[2]=3; g_combos[i].nok[3]=7;
   i++;

   // FB4MB | ZF/BUY | n_ang=63 | Strong | score=111.1
   g_combos[i].code="FB4MB"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=63; g_combos[i].tier=2; g_combos[i].signal_score=111.12;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=27.45; g_combos[i].p1[1]=15.79; g_combos[i].p1[2]=16.13; g_combos[i].p1[3]=17.95;
   g_combos[i].p2[0]=57.14; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=90.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.14; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=357.4; g_combos[i].d1[1]=378.5; g_combos[i].d1[2]=364.8; g_combos[i].d1[3]=569.3;
   g_combos[i].d2[0]=335.0; g_combos[i].d2[1]=457.3; g_combos[i].d2[2]=343.9; g_combos[i].d2[3]=569.3;
   g_combos[i].d3[0]=353.4; g_combos[i].d3[1]=306.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=51; g_combos[i].nt[1]=38; g_combos[i].nt[2]=62; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=6; g_combos[i].nok[2]=10; g_combos[i].nok[3]=7;
   i++;

   // DB4SE | ZD/BUY | n_ang=48 | Strong | score=110.8
   g_combos[i].code="DB4SE"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=48; g_combos[i].tier=2; g_combos[i].signal_score=110.85;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=38.10; g_combos[i].p1[1]=40.00; g_combos[i].p1[2]=6.25; g_combos[i].p1[3]=18.75;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=56.25; g_combos[i].p3[1]=41.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=94.2; g_combos[i].d1[1]=445.4; g_combos[i].d1[2]=228.7; g_combos[i].d1[3]=296.2;
   g_combos[i].d2[0]=377.0; g_combos[i].d2[1]=451.0; g_combos[i].d2[2]=290.3; g_combos[i].d2[3]=296.2;
   g_combos[i].d3[0]=416.8; g_combos[i].d3[1]=571.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=42; g_combos[i].nt[1]=30; g_combos[i].nt[2]=48; g_combos[i].nt[3]=32;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=12; g_combos[i].nok[2]=3; g_combos[i].nok[3]=6;
   i++;

   // FB4SC | ZF/BUY | n_ang=72 | Strong | score=110.3
   g_combos[i].code="FB4SC"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=72; g_combos[i].tier=2; g_combos[i].signal_score=110.31;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=13.56; g_combos[i].p1[1]=18.60; g_combos[i].p1[2]=5.56; g_combos[i].p1[3]=27.66;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=87.50; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=151.2; g_combos[i].d1[1]=360.9; g_combos[i].d1[2]=208.8; g_combos[i].d1[3]=247.8;
   g_combos[i].d2[0]=365.4; g_combos[i].d2[1]=271.4; g_combos[i].d2[2]=291.2; g_combos[i].d2[3]=247.8;
   g_combos[i].d3[0]=437.4; g_combos[i].d3[1]=497.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=59; g_combos[i].nt[1]=43; g_combos[i].nt[2]=72; g_combos[i].nt[3]=47;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=8; g_combos[i].nok[2]=4; g_combos[i].nok[3]=13;
   i++;

   // EB2LO | ZE/BUY | n_ang=62 | Strong | score=110.2
   g_combos[i].code="EB2LO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=62; g_combos[i].tier=2; g_combos[i].signal_score=110.24;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=16.67; g_combos[i].p1[1]=34.15; g_combos[i].p1[2]=6.25; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=314.8; g_combos[i].d1[1]=374.1; g_combos[i].d1[2]=661.0; g_combos[i].d1[3]=316.1;
   g_combos[i].d2[0]=437.7; g_combos[i].d2[1]=431.8; g_combos[i].d2[2]=745.5; g_combos[i].d2[3]=316.1;
   g_combos[i].d3[0]=548.0; g_combos[i].d3[1]=391.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=48; g_combos[i].nt[1]=41; g_combos[i].nt[2]=48; g_combos[i].nt[3]=45;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=14; g_combos[i].nok[2]=3; g_combos[i].nok[3]=12;
   i++;

   // CB1LF | ZC/BUY | n_ang=45 | Strong | score=107.3
   g_combos[i].code="CB1LF"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=45; g_combos[i].tier=2; g_combos[i].signal_score=107.33;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=44.44; g_combos[i].p1[1]=23.08; g_combos[i].p1[2]=35.14; g_combos[i].p1[3]=43.24;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=16.67; g_combos[i].p2[2]=76.92; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=68.75; g_combos[i].p3[1]=16.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=276.4; g_combos[i].d1[1]=623.5; g_combos[i].d1[2]=399.1; g_combos[i].d1[3]=369.8;
   g_combos[i].d2[0]=340.0; g_combos[i].d2[1]=820.0; g_combos[i].d2[2]=514.5; g_combos[i].d2[3]=369.8;
   g_combos[i].d3[0]=500.0; g_combos[i].d3[1]=820.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=36; g_combos[i].nt[1]=26; g_combos[i].nt[2]=37; g_combos[i].nt[3]=37;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=6; g_combos[i].nok[2]=13; g_combos[i].nok[3]=16;
   i++;

   // BB2SG | ZB/BUY | n_ang=39 | Strong | score=106.2
   g_combos[i].code="BB2SG"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=39; g_combos[i].tier=2; g_combos[i].signal_score=106.16;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=47.22; g_combos[i].p1[1]=39.13; g_combos[i].p1[2]=18.92; g_combos[i].p1[3]=48.28;
   g_combos[i].p2[0]=88.24; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.59; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=224.5; g_combos[i].d1[1]=360.9; g_combos[i].d1[2]=291.7; g_combos[i].d1[3]=414.1;
   g_combos[i].d2[0]=312.1; g_combos[i].d2[1]=449.2; g_combos[i].d2[2]=482.4; g_combos[i].d2[3]=414.1;
   g_combos[i].d3[0]=363.8; g_combos[i].d3[1]=540.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=36; g_combos[i].nt[1]=23; g_combos[i].nt[2]=37; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=9; g_combos[i].nok[2]=7; g_combos[i].nok[3]=14;
   i++;

   // DB2MF | ZD/BUY | n_ang=48 | Strong | score=103.9
   g_combos[i].code="DB2MF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=48; g_combos[i].tier=2; g_combos[i].signal_score=103.92;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=28.57; g_combos[i].p1[1]=26.47; g_combos[i].p1[2]=34.88; g_combos[i].p1[3]=30.00;
   g_combos[i].p2[0]=70.00; g_combos[i].p2[1]=55.56; g_combos[i].p2[2]=86.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=55.56; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=314.6; g_combos[i].d1[1]=449.0; g_combos[i].d1[2]=143.6; g_combos[i].d1[3]=290.8;
   g_combos[i].d2[0]=308.1; g_combos[i].d2[1]=442.2; g_combos[i].d2[2]=186.0; g_combos[i].d2[3]=290.8;
   g_combos[i].d3[0]=438.8; g_combos[i].d3[1]=478.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=34; g_combos[i].nt[2]=43; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=9; g_combos[i].nok[2]=15; g_combos[i].nok[3]=12;
   i++;

   // DB3SB | ZD/BUY | n_ang=42 | Strong | score=103.7
   g_combos[i].code="DB3SB"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=42; g_combos[i].tier=2; g_combos[i].signal_score=103.69;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=46.43; g_combos[i].p1[2]=26.19; g_combos[i].p1[3]=45.71;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=84.62; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=77.78; g_combos[i].p3[1]=69.23; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=265.4; g_combos[i].d1[1]=286.2; g_combos[i].d1[2]=148.9; g_combos[i].d1[3]=374.2;
   g_combos[i].d2[0]=433.0; g_combos[i].d2[1]=375.6; g_combos[i].d2[2]=214.2; g_combos[i].d2[3]=374.2;
   g_combos[i].d3[0]=382.0; g_combos[i].d3[1]=457.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=39; g_combos[i].nt[1]=28; g_combos[i].nt[2]=42; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=13; g_combos[i].nok[2]=11; g_combos[i].nok[3]=16;
   i++;

   // DB3SE | ZD/BUY | n_ang=37 | Strong | score=103.4
   g_combos[i].code="DB3SE"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=37; g_combos[i].tier=2; g_combos[i].signal_score=103.41;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=48.57; g_combos[i].p1[1]=47.62; g_combos[i].p1[2]=18.92; g_combos[i].p1[3]=44.44;
   g_combos[i].p2[0]=70.59; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.82; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=131.6; g_combos[i].d1[1]=442.5; g_combos[i].d1[2]=323.1; g_combos[i].d1[3]=251.2;
   g_combos[i].d2[0]=370.5; g_combos[i].d2[1]=536.7; g_combos[i].d2[2]=311.5; g_combos[i].d2[3]=251.2;
   g_combos[i].d3[0]=425.4; g_combos[i].d3[1]=563.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=21; g_combos[i].nt[2]=37; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=10; g_combos[i].nok[2]=7; g_combos[i].nok[3]=12;
   i++;

   // BB2MG | ZB/BUY | n_ang=50 | Strong | score=99.0
   g_combos[i].code="BB2MG"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=50; g_combos[i].tier=2; g_combos[i].signal_score=98.99;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.00; g_combos[i].p1[1]=45.16; g_combos[i].p1[2]=20.00; g_combos[i].p1[3]=22.86;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=64.29; g_combos[i].p2[2]=88.89; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.33; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=295.5; g_combos[i].d1[1]=402.0; g_combos[i].d1[2]=210.0; g_combos[i].d1[3]=431.6;
   g_combos[i].d2[0]=350.0; g_combos[i].d2[1]=584.0; g_combos[i].d2[2]=279.0; g_combos[i].d2[3]=431.6;
   g_combos[i].d3[0]=465.9; g_combos[i].d3[1]=532.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=40; g_combos[i].nt[1]=31; g_combos[i].nt[2]=45; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=14; g_combos[i].nok[2]=9; g_combos[i].nok[3]=8;
   i++;

   // HB4SD | ZH/BUY | n_ang=41 | Strong | score=89.6
   g_combos[i].code="HB4SD"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=41; g_combos[i].tier=2; g_combos[i].signal_score=89.64;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=30.30; g_combos[i].p1[2]=14.63; g_combos[i].p1[3]=40.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=157.1; g_combos[i].d1[1]=196.9; g_combos[i].d1[2]=95.8; g_combos[i].d1[3]=218.4;
   g_combos[i].d2[0]=238.8; g_combos[i].d2[1]=267.1; g_combos[i].d2[2]=114.0; g_combos[i].d2[3]=218.4;
   g_combos[i].d3[0]=324.8; g_combos[i].d3[1]=174.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=33; g_combos[i].nt[2]=41; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=10; g_combos[i].nok[2]=6; g_combos[i].nok[3]=14;
   i++;

   // CB2MB | ZC/BUY | n_ang=45 | Strong | score=87.2
   g_combos[i].code="CB2MB"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=45; g_combos[i].tier=2; g_combos[i].signal_score=87.21;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=23.53; g_combos[i].p1[1]=46.43; g_combos[i].p1[2]=34.21; g_combos[i].p1[3]=27.03;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=69.23; g_combos[i].p2[2]=76.92; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=61.54; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=374.5; g_combos[i].d1[1]=428.5; g_combos[i].d1[2]=214.9; g_combos[i].d1[3]=323.5;
   g_combos[i].d2[0]=592.8; g_combos[i].d2[1]=567.2; g_combos[i].d2[2]=302.5; g_combos[i].d2[3]=323.5;
   g_combos[i].d3[0]=483.2; g_combos[i].d3[1]=634.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=34; g_combos[i].nt[1]=28; g_combos[i].nt[2]=38; g_combos[i].nt[3]=37;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=13; g_combos[i].nok[2]=13; g_combos[i].nok[3]=10;
   i++;

   // DB3SD | ZD/BUY | n_ang=37 | Good | score=85.2
   g_combos[i].code="DB3SD"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=37; g_combos[i].tier=3; g_combos[i].signal_score=85.16;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=38.24; g_combos[i].p1[1]=43.48; g_combos[i].p1[2]=13.51; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=69.23; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.85; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=115.8; g_combos[i].d1[1]=235.8; g_combos[i].d1[2]=268.4; g_combos[i].d1[3]=268.6;
   g_combos[i].d2[0]=220.9; g_combos[i].d2[1]=351.8; g_combos[i].d2[2]=283.0; g_combos[i].d2[3]=268.6;
   g_combos[i].d3[0]=376.7; g_combos[i].d3[1]=447.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=34; g_combos[i].nt[1]=23; g_combos[i].nt[2]=37; g_combos[i].nt[3]=28;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=10; g_combos[i].nok[2]=5; g_combos[i].nok[3]=14;
   i++;

   // FB4ME | ZF/BUY | n_ang=59 | Good | score=84.5
   g_combos[i].code="FB4ME"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=59; g_combos[i].tier=3; g_combos[i].signal_score=84.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=24.44; g_combos[i].p1[1]=15.00; g_combos[i].p1[2]=14.29; g_combos[i].p1[3]=12.50;
   g_combos[i].p2[0]=54.55; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=54.55; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=278.5; g_combos[i].d1[1]=467.7; g_combos[i].d1[2]=257.5; g_combos[i].d1[3]=683.2;
   g_combos[i].d2[0]=401.3; g_combos[i].d2[1]=680.0; g_combos[i].d2[2]=287.5; g_combos[i].d2[3]=683.2;
   g_combos[i].d3[0]=403.3; g_combos[i].d3[1]=723.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=45; g_combos[i].nt[1]=40; g_combos[i].nt[2]=56; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=6; g_combos[i].nok[2]=8; g_combos[i].nok[3]=5;
   i++;

   // DB2SF | ZD/BUY | n_ang=34 | Good | score=81.6
   g_combos[i].code="DB2SF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=81.63;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=63.64; g_combos[i].p1[2]=24.24; g_combos[i].p1[3]=28.00;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=87.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=55.56; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=310.8; g_combos[i].d1[1]=410.2; g_combos[i].d1[2]=161.2; g_combos[i].d1[3]=378.4;
   g_combos[i].d2[0]=389.0; g_combos[i].d2[1]=437.6; g_combos[i].d2[2]=182.7; g_combos[i].d2[3]=378.4;
   g_combos[i].d3[0]=396.8; g_combos[i].d3[1]=392.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=22; g_combos[i].nt[2]=33; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=14; g_combos[i].nok[2]=8; g_combos[i].nok[3]=7;
   i++;

   // FB4MO | ZF/BUY | n_ang=53 | Good | score=80.1
   g_combos[i].code="FB4MO"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=53; g_combos[i].tier=3; g_combos[i].signal_score=80.08;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=23.91; g_combos[i].p1[1]=18.18; g_combos[i].p1[2]=6.00; g_combos[i].p1[3]=14.29;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=81.82; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=310.6; g_combos[i].d1[1]=431.5; g_combos[i].d1[2]=260.0; g_combos[i].d1[3]=526.0;
   g_combos[i].d2[0]=414.2; g_combos[i].d2[1]=574.0; g_combos[i].d2[2]=218.5; g_combos[i].d2[3]=526.0;
   g_combos[i].d3[0]=417.4; g_combos[i].d3[1]=727.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=33; g_combos[i].nt[2]=50; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=6; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // CB1LB | ZC/BUY | n_ang=35 | Good | score=76.9
   g_combos[i].code="CB1LB"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=35; g_combos[i].tier=3; g_combos[i].signal_score=76.91;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=44.44; g_combos[i].p1[1]=37.93; g_combos[i].p1[2]=46.43; g_combos[i].p1[3]=18.75;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=72.73; g_combos[i].p2[2]=92.31; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=91.67; g_combos[i].p3[1]=72.73; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=293.1; g_combos[i].d1[1]=377.9; g_combos[i].d1[2]=425.5; g_combos[i].d1[3]=312.5;
   g_combos[i].d2[0]=408.1; g_combos[i].d2[1]=516.2; g_combos[i].d2[2]=533.1; g_combos[i].d2[3]=312.5;
   g_combos[i].d3[0]=543.9; g_combos[i].d3[1]=517.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=29; g_combos[i].nt[2]=28; g_combos[i].nt[3]=32;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=11; g_combos[i].nok[2]=13; g_combos[i].nok[3]=6;
   i++;

   // BB2SD | ZB/BUY | n_ang=34 | Good | score=75.8
   g_combos[i].code="BB2SD"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=75.80;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=60.00; g_combos[i].p1[2]=32.35; g_combos[i].p1[3]=48.15;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=72.73; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=191.2; g_combos[i].d1[1]=268.8; g_combos[i].d1[2]=258.9; g_combos[i].d1[3]=407.2;
   g_combos[i].d2[0]=324.1; g_combos[i].d2[1]=377.9; g_combos[i].d2[2]=242.2; g_combos[i].d2[3]=407.2;
   g_combos[i].d3[0]=303.3; g_combos[i].d3[1]=507.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=30; g_combos[i].nt[1]=20; g_combos[i].nt[2]=34; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=12; g_combos[i].nok[2]=11; g_combos[i].nok[3]=13;
   i++;

   // EB2MG | ZE/BUY | n_ang=32 | Good | score=73.5
   g_combos[i].code="EB2MG"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=32; g_combos[i].tier=3; g_combos[i].signal_score=73.54;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=28.57; g_combos[i].p1[1]=40.74; g_combos[i].p1[2]=36.00; g_combos[i].p1[3]=43.33;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=54.55; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=36.36; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=207.8; g_combos[i].d1[1]=329.9; g_combos[i].d1[2]=457.6; g_combos[i].d1[3]=411.2;
   g_combos[i].d2[0]=367.7; g_combos[i].d2[1]=572.8; g_combos[i].d2[2]=565.7; g_combos[i].d2[3]=411.2;
   g_combos[i].d3[0]=390.8; g_combos[i].d3[1]=466.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=21; g_combos[i].nt[1]=27; g_combos[i].nt[2]=25; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=11; g_combos[i].nok[2]=9; g_combos[i].nok[3]=13;
   i++;

   // HB4SF | ZH/BUY | n_ang=37 | Good | score=73.0
   g_combos[i].code="HB4SF"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=37; g_combos[i].tier=3; g_combos[i].signal_score=72.99;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=26.92; g_combos[i].p1[2]=8.11; g_combos[i].p1[3]=44.44;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=85.71; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=470.4; g_combos[i].d1[1]=211.1; g_combos[i].d1[2]=193.7; g_combos[i].d1[3]=224.8;
   g_combos[i].d2[0]=624.8; g_combos[i].d2[1]=121.0; g_combos[i].d2[2]=224.7; g_combos[i].d2[3]=224.8;
   g_combos[i].d3[0]=520.8; g_combos[i].d3[1]=282.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=26; g_combos[i].nt[2]=37; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=7; g_combos[i].nok[2]=3; g_combos[i].nok[3]=12;
   i++;

   // CB2ME | ZC/BUY | n_ang=31 | Good | score=72.4
   g_combos[i].code="CB2ME"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=31; g_combos[i].tier=3; g_combos[i].signal_score=72.38;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=37.04; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=48.15; g_combos[i].p1[3]=12.00;
   g_combos[i].p2[0]=70.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=76.92; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=255.2; g_combos[i].d1[1]=131.0; g_combos[i].d1[2]=330.2; g_combos[i].d1[3]=134.7;
   g_combos[i].d2[0]=279.6; g_combos[i].d2[1]=287.2; g_combos[i].d2[2]=248.6; g_combos[i].d2[3]=134.7;
   g_combos[i].d3[0]=332.5; g_combos[i].d3[1]=301.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=20; g_combos[i].nt[2]=27; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=5; g_combos[i].nok[2]=13; g_combos[i].nok[3]=3;
   i++;

   // CB2MG | ZC/BUY | n_ang=30 | Good | score=71.2
   g_combos[i].code="CB2MG"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=30; g_combos[i].tier=3; g_combos[i].signal_score=71.20;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=56.52; g_combos[i].p1[1]=26.92; g_combos[i].p1[2]=37.93; g_combos[i].p1[3]=17.24;
   g_combos[i].p2[0]=84.62; g_combos[i].p2[1]=42.86; g_combos[i].p2[2]=90.91; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=76.92; g_combos[i].p3[1]=28.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=178.3; g_combos[i].d1[1]=403.0; g_combos[i].d1[2]=237.9; g_combos[i].d1[3]=260.6;
   g_combos[i].d2[0]=316.6; g_combos[i].d2[1]=443.7; g_combos[i].d2[2]=287.5; g_combos[i].d2[3]=260.6;
   g_combos[i].d3[0]=471.2; g_combos[i].d3[1]=575.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=26; g_combos[i].nt[2]=29; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=7; g_combos[i].nok[2]=11; g_combos[i].nok[3]=5;
   i++;

   // EB1MO | ZE/BUY | n_ang=25 | Good | score=70.0
   g_combos[i].code="EB1MO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=25; g_combos[i].tier=3; g_combos[i].signal_score=70.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=63.64; g_combos[i].p1[1]=53.33; g_combos[i].p1[2]=22.73; g_combos[i].p1[3]=38.10;
   g_combos[i].p2[0]=78.57; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=236.9; g_combos[i].d1[1]=384.9; g_combos[i].d1[2]=234.8; g_combos[i].d1[3]=347.0;
   g_combos[i].d2[0]=393.7; g_combos[i].d2[1]=489.0; g_combos[i].d2[2]=390.8; g_combos[i].d2[3]=347.0;
   g_combos[i].d3[0]=474.9; g_combos[i].d3[1]=521.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=15; g_combos[i].nt[2]=22; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=8; g_combos[i].nok[2]=5; g_combos[i].nok[3]=8;
   i++;

   // FB4MF | ZF/BUY | n_ang=49 | Good | score=70.0
   g_combos[i].code="FB4MF"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=49; g_combos[i].tier=3; g_combos[i].signal_score=70.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=14.81; g_combos[i].p1[2]=15.56; g_combos[i].p1[3]=3.33;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=30.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=487.5; g_combos[i].d1[1]=779.2; g_combos[i].d1[2]=557.9; g_combos[i].d1[3]=210.0;
   g_combos[i].d2[0]=673.6; g_combos[i].d2[1]=733.5; g_combos[i].d2[2]=570.3; g_combos[i].d2[3]=210.0;
   g_combos[i].d3[0]=635.0; g_combos[i].d3[1]=753.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=40; g_combos[i].nt[1]=27; g_combos[i].nt[2]=45; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=4; g_combos[i].nok[2]=7; g_combos[i].nok[3]=1;
   i++;

   // EB1MB | ZE/BUY | n_ang=28 | Good | score=68.8
   g_combos[i].code="EB1MB"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=28; g_combos[i].tier=3; g_combos[i].signal_score=68.79;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=47.83; g_combos[i].p1[1]=66.67; g_combos[i].p1[2]=26.92; g_combos[i].p1[3]=52.00;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=42.86; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=36.36; g_combos[i].p3[1]=58.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=298.4; g_combos[i].d1[1]=375.7; g_combos[i].d1[2]=467.7; g_combos[i].d1[3]=237.7;
   g_combos[i].d2[0]=536.1; g_combos[i].d2[1]=400.5; g_combos[i].d2[2]=238.7; g_combos[i].d2[3]=237.7;
   g_combos[i].d3[0]=778.5; g_combos[i].d3[1]=503.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=18; g_combos[i].nt[2]=26; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=12; g_combos[i].nok[2]=7; g_combos[i].nok[3]=13;
   i++;

   // EB2MD | ZE/BUY | n_ang=30 | Good | score=65.7
   g_combos[i].code="EB2MD"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=30; g_combos[i].tier=3; g_combos[i].signal_score=65.73;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=13.04; g_combos[i].p1[1]=42.86; g_combos[i].p1[2]=42.86; g_combos[i].p1[3]=30.77;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=88.89; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=77.78; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=235.7; g_combos[i].d1[1]=282.2; g_combos[i].d1[2]=216.2; g_combos[i].d1[3]=349.0;
   g_combos[i].d2[0]=297.5; g_combos[i].d2[1]=426.8; g_combos[i].d2[2]=201.3; g_combos[i].d2[3]=349.0;
   g_combos[i].d3[0]=300.0; g_combos[i].d3[1]=503.6; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=21; g_combos[i].nt[2]=28; g_combos[i].nt[3]=26;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=9; g_combos[i].nok[2]=12; g_combos[i].nok[3]=8;
   i++;

   // DB4SG | ZD/BUY | n_ang=29 | Good | score=64.6
   g_combos[i].code="DB4SG"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=29; g_combos[i].tier=3; g_combos[i].signal_score=64.62;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=38.46; g_combos[i].p1[1]=43.48; g_combos[i].p1[2]=3.45; g_combos[i].p1[3]=48.00;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=90.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=90.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=83.4; g_combos[i].d1[1]=346.1; g_combos[i].d1[2]=185.0; g_combos[i].d1[3]=265.5;
   g_combos[i].d2[0]=194.2; g_combos[i].d2[1]=348.2; g_combos[i].d2[2]=187.0; g_combos[i].d2[3]=265.5;
   g_combos[i].d3[0]=312.2; g_combos[i].d3[1]=442.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=26; g_combos[i].nt[1]=23; g_combos[i].nt[2]=29; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=10; g_combos[i].nok[2]=1; g_combos[i].nok[3]=12;
   i++;

   // EB1LE | ZE/BUY | n_ang=34 | Good | score=64.1
   g_combos[i].code="EB1LE"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=64.14;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=16.13; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=22.58; g_combos[i].p1[3]=37.93;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=80.00; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=152.4; g_combos[i].d1[1]=426.9; g_combos[i].d1[2]=189.6; g_combos[i].d1[3]=213.5;
   g_combos[i].d2[0]=209.0; g_combos[i].d2[1]=655.6; g_combos[i].d2[2]=390.3; g_combos[i].d2[3]=213.5;
   g_combos[i].d3[0]=332.5; g_combos[i].d3[1]=656.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=22; g_combos[i].nt[2]=31; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=8; g_combos[i].nok[2]=7; g_combos[i].nok[3]=11;
   i++;

   // HB4SG | ZH/BUY | n_ang=34 | Good | score=64.1
   g_combos[i].code="HB4SG"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=64.14;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=28.12; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=2.94; g_combos[i].p1[3]=37.93;
   g_combos[i].p2[0]=88.89; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=88.89; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=212.6; g_combos[i].d1[1]=362.5; g_combos[i].d1[2]=235.0; g_combos[i].d1[3]=212.7;
   g_combos[i].d2[0]=347.4; g_combos[i].d2[1]=345.4; g_combos[i].d2[2]=235.0; g_combos[i].d2[3]=212.7;
   g_combos[i].d3[0]=351.4; g_combos[i].d3[1]=404.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=28; g_combos[i].nt[2]=34; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=1; g_combos[i].nok[3]=11;
   i++;

   // BB2ME | ZB/BUY | n_ang=38 | Good | score=61.6
   g_combos[i].code="BB2ME"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=38; g_combos[i].tier=3; g_combos[i].signal_score=61.64;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=32.26; g_combos[i].p1[1]=43.48; g_combos[i].p1[2]=17.65; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=90.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.00; g_combos[i].p3[1]=70.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=155.2; g_combos[i].d1[1]=406.4; g_combos[i].d1[2]=215.7; g_combos[i].d1[3]=358.9;
   g_combos[i].d2[0]=346.4; g_combos[i].d2[1]=518.4; g_combos[i].d2[2]=155.0; g_combos[i].d2[3]=358.9;
   g_combos[i].d3[0]=340.1; g_combos[i].d3[1]=537.6; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=23; g_combos[i].nt[2]=34; g_combos[i].nt[3]=28;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=10; g_combos[i].nok[2]=6; g_combos[i].nok[3]=7;
   i++;

   // EB1LD | ZE/BUY | n_ang=36 | Good | score=60.0
   g_combos[i].code="EB1LD"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=36; g_combos[i].tier=3; g_combos[i].signal_score=60.00;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=25.93; g_combos[i].p1[1]=41.67; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=23.33;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=85.71; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=219.0; g_combos[i].d1[1]=355.3; g_combos[i].d1[2]=243.3; g_combos[i].d1[3]=376.4;
   g_combos[i].d2[0]=306.6; g_combos[i].d2[1]=615.7; g_combos[i].d2[2]=264.3; g_combos[i].d2[3]=376.4;
   g_combos[i].d3[0]=355.2; g_combos[i].d3[1]=616.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=24; g_combos[i].nt[2]=28; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=10; g_combos[i].nok[2]=7; g_combos[i].nok[3]=7;
   i++;

   // BB3SH | ZB/BUY | n_ang=29 | Good | score=59.2
   g_combos[i].code="BB3SH"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=29; g_combos[i].tier=3; g_combos[i].signal_score=59.24;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=42.31; g_combos[i].p1[1]=41.18; g_combos[i].p1[2]=24.14; g_combos[i].p1[3]=52.38;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=63.64; g_combos[i].p3[1]=71.43; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=99.0; g_combos[i].d1[1]=348.1; g_combos[i].d1[2]=182.7; g_combos[i].d1[3]=311.5;
   g_combos[i].d2[0]=330.2; g_combos[i].d2[1]=589.9; g_combos[i].d2[2]=242.2; g_combos[i].d2[3]=311.5;
   g_combos[i].d3[0]=470.7; g_combos[i].d3[1]=611.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=26; g_combos[i].nt[1]=17; g_combos[i].nt[2]=29; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=7; g_combos[i].nok[2]=7; g_combos[i].nok[3]=11;
   i++;

   // DB3SG | ZD/BUY | n_ang=24 | Good | score=58.8
   g_combos[i].code="DB3SG"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=24; g_combos[i].tier=3; g_combos[i].signal_score=58.79;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=47.83; g_combos[i].p1[1]=41.67; g_combos[i].p1[2]=20.83; g_combos[i].p1[3]=66.67;
   g_combos[i].p2[0]=45.45; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=40.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=27.27; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=312.4; g_combos[i].d1[1]=527.0; g_combos[i].d1[2]=199.6; g_combos[i].d1[3]=297.3;
   g_combos[i].d2[0]=188.8; g_combos[i].d2[1]=635.2; g_combos[i].d2[2]=322.5; g_combos[i].d2[3]=297.3;
   g_combos[i].d3[0]=202.3; g_combos[i].d3[1]=708.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=12; g_combos[i].nt[2]=24; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=5; g_combos[i].nok[2]=5; g_combos[i].nok[3]=12;
   i++;

   // CB2LG | ZC/BUY | n_ang=34 | Good | score=58.3
   g_combos[i].code="CB2LG"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=58.31;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=30.77; g_combos[i].p1[2]=19.35; g_combos[i].p1[3]=14.81;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=462.0; g_combos[i].d1[1]=360.1; g_combos[i].d1[2]=545.8; g_combos[i].d1[3]=305.0;
   g_combos[i].d2[0]=595.5; g_combos[i].d2[1]=301.5; g_combos[i].d2[2]=673.0; g_combos[i].d2[3]=305.0;
   g_combos[i].d3[0]=749.6; g_combos[i].d3[1]=328.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=30; g_combos[i].nt[1]=26; g_combos[i].nt[2]=31; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=8; g_combos[i].nok[2]=6; g_combos[i].nok[3]=4;
   i++;

   // BB1MF | ZB/BUY | n_ang=23 | Good | score=57.5
   g_combos[i].code="BB1MF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=23; g_combos[i].tier=3; g_combos[i].signal_score=57.55;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=54.55; g_combos[i].p1[1]=46.15; g_combos[i].p1[2]=27.27; g_combos[i].p1[3]=47.62;
   g_combos[i].p2[0]=91.67; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.33; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=218.1; g_combos[i].d1[1]=336.7; g_combos[i].d1[2]=234.2; g_combos[i].d1[3]=428.2;
   g_combos[i].d2[0]=361.7; g_combos[i].d2[1]=617.2; g_combos[i].d2[2]=286.5; g_combos[i].d2[3]=428.2;
   g_combos[i].d3[0]=422.6; g_combos[i].d3[1]=626.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=13; g_combos[i].nt[2]=22; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=6; g_combos[i].nok[2]=6; g_combos[i].nok[3]=10;
   i++;

   // BB4SH | ZB/BUY | n_ang=33 | Good | score=57.5
   g_combos[i].code="BB4SH"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=33; g_combos[i].tier=3; g_combos[i].signal_score=57.45;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=43.48; g_combos[i].p1[1]=29.17; g_combos[i].p1[2]=15.15; g_combos[i].p1[3]=21.43;
   g_combos[i].p2[0]=70.00; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=154.4; g_combos[i].d1[1]=350.4; g_combos[i].d1[2]=115.8; g_combos[i].d1[3]=261.3;
   g_combos[i].d2[0]=398.1; g_combos[i].d2[1]=373.2; g_combos[i].d2[2]=136.0; g_combos[i].d2[3]=261.3;
   g_combos[i].d3[0]=553.0; g_combos[i].d3[1]=570.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=24; g_combos[i].nt[2]=33; g_combos[i].nt[3]=28;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=7; g_combos[i].nok[2]=5; g_combos[i].nok[3]=6;
   i++;

   // DB2SD | ZD/BUY | n_ang=27 | Good | score=57.2
   g_combos[i].code="DB2SD"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=27; g_combos[i].tier=3; g_combos[i].signal_score=57.16;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=42.86; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=42.31; g_combos[i].p1[3]=42.11;
   g_combos[i].p2[0]=44.44; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=72.73; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=201.3; g_combos[i].d1[1]=237.4; g_combos[i].d1[2]=100.5; g_combos[i].d1[3]=128.4;
   g_combos[i].d2[0]=294.0; g_combos[i].d2[1]=480.8; g_combos[i].d2[2]=284.9; g_combos[i].d2[3]=128.4;
   g_combos[i].d3[0]=438.0; g_combos[i].d3[1]=533.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=21; g_combos[i].nt[1]=15; g_combos[i].nt[2]=26; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=5; g_combos[i].nok[2]=11; g_combos[i].nok[3]=8;
   i++;

   // DB2ME | ZD/BUY | n_ang=31 | Good | score=55.7
   g_combos[i].code="DB2ME"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=31; g_combos[i].tier=3; g_combos[i].signal_score=55.68;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=36.00; g_combos[i].p1[1]=34.78; g_combos[i].p1[2]=35.71; g_combos[i].p1[3]=8.00;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=88.89; g_combos[i].p3[1]=87.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=124.0; g_combos[i].d1[1]=404.5; g_combos[i].d1[2]=183.5; g_combos[i].d1[3]=371.5;
   g_combos[i].d2[0]=249.7; g_combos[i].d2[1]=506.2; g_combos[i].d2[2]=312.5; g_combos[i].d2[3]=371.5;
   g_combos[i].d3[0]=276.0; g_combos[i].d3[1]=575.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=25; g_combos[i].nt[1]=23; g_combos[i].nt[2]=28; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=10; g_combos[i].nok[3]=2;
   i++;

   // BB2SE | ZB/BUY | n_ang=30 | Good | score=54.8
   g_combos[i].code="BB2SE"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=30; g_combos[i].tier=3; g_combos[i].signal_score=54.77;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=39.13; g_combos[i].p1[1]=53.33; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=45.45;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=90.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=22.22; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=215.8; g_combos[i].d1[1]=356.0; g_combos[i].d1[2]=194.1; g_combos[i].d1[3]=352.9;
   g_combos[i].d2[0]=358.7; g_combos[i].d2[1]=498.7; g_combos[i].d2[2]=251.1; g_combos[i].d2[3]=352.9;
   g_combos[i].d3[0]=638.5; g_combos[i].d3[1]=457.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=15; g_combos[i].nt[2]=30; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=10; g_combos[i].nok[3]=10;
   i++;

   // DB3SO | ZD/BUY | n_ang=37 | Good | score=54.7
   g_combos[i].code="DB3SO"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=37; g_combos[i].tier=3; g_combos[i].signal_score=54.74;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=24.24; g_combos[i].p1[1]=42.86; g_combos[i].p1[2]=16.22; g_combos[i].p1[3]=34.62;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=55.56; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=44.44; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=175.0; g_combos[i].d1[1]=370.8; g_combos[i].d1[2]=533.3; g_combos[i].d1[3]=287.0;
   g_combos[i].d2[0]=263.4; g_combos[i].d2[1]=482.8; g_combos[i].d2[2]=574.2; g_combos[i].d2[3]=287.0;
   g_combos[i].d3[0]=478.6; g_combos[i].d3[1]=615.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=33; g_combos[i].nt[1]=21; g_combos[i].nt[2]=37; g_combos[i].nt[3]=26;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=9; g_combos[i].nok[2]=6; g_combos[i].nok[3]=9;
   i++;

   // BB3MF | ZB/BUY | n_ang=29 | Good | score=53.9
   g_combos[i].code="BB3MF"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=29; g_combos[i].tier=3; g_combos[i].signal_score=53.85;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=35.71; g_combos[i].p1[3]=30.43;
   g_combos[i].p2[0]=55.56; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=90.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=232.2; g_combos[i].d1[1]=346.0; g_combos[i].d1[2]=265.3; g_combos[i].d1[3]=509.1;
   g_combos[i].d2[0]=386.2; g_combos[i].d2[1]=382.5; g_combos[i].d2[2]=278.9; g_combos[i].d2[3]=509.1;
   g_combos[i].d3[0]=274.8; g_combos[i].d3[1]=413.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=20; g_combos[i].nt[2]=28; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=4; g_combos[i].nok[2]=10; g_combos[i].nok[3]=7;
   i++;

   // CB2MF | ZC/BUY | n_ang=34 | Good | score=52.5
   g_combos[i].code="CB2MF"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=52.48;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=36.36; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=28.00; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=37.50; g_combos[i].p2[2]=42.86; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=12.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=246.6; g_combos[i].d1[1]=527.4; g_combos[i].d1[2]=284.3; g_combos[i].d1[3]=348.2;
   g_combos[i].d2[0]=237.5; g_combos[i].d2[1]=536.0; g_combos[i].d2[2]=376.7; g_combos[i].d2[3]=348.2;
   g_combos[i].d3[0]=500.2; g_combos[i].d3[1]=595.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=22; g_combos[i].nt[2]=25; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=8; g_combos[i].nok[2]=7; g_combos[i].nok[3]=9;
   i++;

   // HB4SO | ZH/BUY | n_ang=26 | Weak | score=51.0
   g_combos[i].code="HB4SO"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=26; g_combos[i].tier=4; g_combos[i].signal_score=50.99;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=43.48; g_combos[i].p1[1]=37.50; g_combos[i].p1[2]=12.00; g_combos[i].p1[3]=31.25;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=248.4; g_combos[i].d1[1]=437.8; g_combos[i].d1[2]=244.3; g_combos[i].d1[3]=452.6;
   g_combos[i].d2[0]=540.8; g_combos[i].d2[1]=405.0; g_combos[i].d2[2]=482.7; g_combos[i].d2[3]=452.6;
   g_combos[i].d3[0]=543.0; g_combos[i].d3[1]=397.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=16; g_combos[i].nt[2]=25; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=6; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // DB1MF | ZD/BUY | n_ang=25 | Weak | score=50.0
   g_combos[i].code="DB1MF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=25; g_combos[i].tier=4; g_combos[i].signal_score=50.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=43.48; g_combos[i].p1[1]=30.77; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=31.58;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=248.1; g_combos[i].d1[1]=463.0; g_combos[i].d1[2]=170.3; g_combos[i].d1[3]=346.3;
   g_combos[i].d2[0]=297.6; g_combos[i].d2[1]=403.5; g_combos[i].d2[2]=289.0; g_combos[i].d2[3]=346.3;
   g_combos[i].d3[0]=427.8; g_combos[i].d3[1]=433.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=13; g_combos[i].nt[2]=24; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=4; g_combos[i].nok[2]=6; g_combos[i].nok[3]=6;
   i++;

   // HB4SE | ZH/BUY | n_ang=36 | Weak | score=48.0
   g_combos[i].code="HB4SE"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=36; g_combos[i].tier=4; g_combos[i].signal_score=48.00;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=13.33; g_combos[i].p1[1]=32.00; g_combos[i].p1[2]=5.71; g_combos[i].p1[3]=26.92;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=242.0; g_combos[i].d1[1]=113.8; g_combos[i].d1[2]=13.5; g_combos[i].d1[3]=144.1;
   g_combos[i].d2[0]=335.0; g_combos[i].d2[1]=175.4; g_combos[i].d2[2]=44.0; g_combos[i].d2[3]=144.1;
   g_combos[i].d3[0]=365.5; g_combos[i].d3[1]=217.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=30; g_combos[i].nt[1]=25; g_combos[i].nt[2]=35; g_combos[i].nt[3]=26;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=8; g_combos[i].nok[2]=2; g_combos[i].nok[3]=7;
   i++;

   // CB1LO | ZC/BUY | n_ang=27 | Weak | score=46.8
   g_combos[i].code="CB1LO"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=27; g_combos[i].tier=4; g_combos[i].signal_score=46.77;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=32.00; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=36.00; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=40.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=37.50; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=379.0; g_combos[i].d1[1]=446.6; g_combos[i].d1[2]=451.6; g_combos[i].d1[3]=548.6;
   g_combos[i].d2[0]=484.0; g_combos[i].d2[1]=591.5; g_combos[i].d2[2]=482.5; g_combos[i].d2[3]=548.6;
   g_combos[i].d3[0]=517.7; g_combos[i].d3[1]=591.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=25; g_combos[i].nt[1]=15; g_combos[i].nt[2]=25; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=5; g_combos[i].nok[2]=9; g_combos[i].nok[3]=5;
   i++;

   // CB2MO | ZC/BUY | n_ang=27 | Weak | score=46.8
   g_combos[i].code="CB2MO"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=27; g_combos[i].tier=4; g_combos[i].signal_score=46.77;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=26.32; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=39.13;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=214.4; g_combos[i].d1[1]=400.8; g_combos[i].d1[2]=132.3; g_combos[i].d1[3]=191.4;
   g_combos[i].d2[0]=419.0; g_combos[i].d2[1]=401.2; g_combos[i].d2[2]=287.8; g_combos[i].d2[3]=191.4;
   g_combos[i].d3[0]=449.3; g_combos[i].d3[1]=436.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=20; g_combos[i].nt[2]=21; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=5; g_combos[i].nok[2]=6; g_combos[i].nok[3]=9;
   i++;

   // EB2SF | ZE/BUY | n_ang=20 | Weak | score=44.7
   g_combos[i].code="EB2SF"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=20; g_combos[i].tier=4; g_combos[i].signal_score=44.72;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=62.50; g_combos[i].p1[1]=41.67; g_combos[i].p1[2]=27.78; g_combos[i].p1[3]=53.33;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=20.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=150.3; g_combos[i].d1[1]=587.0; g_combos[i].d1[2]=192.8; g_combos[i].d1[3]=241.4;
   g_combos[i].d2[0]=319.2; g_combos[i].d2[1]=523.7; g_combos[i].d2[2]=285.5; g_combos[i].d2[3]=241.4;
   g_combos[i].d3[0]=471.3; g_combos[i].d3[1]=368.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=12; g_combos[i].nt[2]=18; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=5; g_combos[i].nok[2]=5; g_combos[i].nok[3]=8;
   i++;

   // DB2SH | ZD/BUY | n_ang=19 | Weak | score=43.6
   g_combos[i].code="DB2SH"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=19; g_combos[i].tier=4; g_combos[i].signal_score=43.59;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=66.67; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=21.05; g_combos[i].p1[3]=41.67;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=113.1; g_combos[i].d1[1]=348.6; g_combos[i].d1[2]=110.5; g_combos[i].d1[3]=210.8;
   g_combos[i].d2[0]=188.2; g_combos[i].d2[1]=390.7; g_combos[i].d2[2]=136.8; g_combos[i].d2[3]=210.8;
   g_combos[i].d3[0]=265.4; g_combos[i].d3[1]=573.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=10; g_combos[i].nt[2]=19; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=5; g_combos[i].nok[2]=4; g_combos[i].nok[3]=5;
   i++;

   // DB3SH | ZD/BUY | n_ang=19 | Weak | score=43.6
   g_combos[i].code="DB3SH"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=19; g_combos[i].tier=4; g_combos[i].signal_score=43.59;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=62.50; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=15.79; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.00; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=132.3; g_combos[i].d1[1]=270.2; g_combos[i].d1[2]=183.7; g_combos[i].d1[3]=243.3;
   g_combos[i].d2[0]=322.8; g_combos[i].d2[1]=277.5; g_combos[i].d2[2]=49.0; g_combos[i].d2[3]=243.3;
   g_combos[i].d3[0]=487.1; g_combos[i].d3[1]=601.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=11; g_combos[i].nt[2]=19; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=4; g_combos[i].nok[2]=3; g_combos[i].nok[3]=3;
   i++;

   // BB1MB | ZB/BUY | n_ang=23 | Weak | score=43.2
   g_combos[i].code="BB1MB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=23; g_combos[i].tier=4; g_combos[i].signal_score=43.16;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=27.27; g_combos[i].p1[1]=45.45; g_combos[i].p1[2]=40.91; g_combos[i].p1[3]=29.41;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=20.00; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=20.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=215.7; g_combos[i].d1[1]=725.0; g_combos[i].d1[2]=290.3; g_combos[i].d1[3]=490.6;
   g_combos[i].d2[0]=431.8; g_combos[i].d2[1]=859.0; g_combos[i].d2[2]=330.0; g_combos[i].d2[3]=490.6;
   g_combos[i].d3[0]=580.3; g_combos[i].d3[1]=962.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=11; g_combos[i].nt[2]=22; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=5; g_combos[i].nok[2]=9; g_combos[i].nok[3]=5;
   i++;

   // FB4MC | ZF/BUY | n_ang=37 | Weak | score=42.6
   g_combos[i].code="FB4MC"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=37; g_combos[i].tier=4; g_combos[i].signal_score=42.58;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=9.38; g_combos[i].p1[1]=31.82; g_combos[i].p1[2]=11.11; g_combos[i].p1[3]=0.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=0.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=362.7; g_combos[i].d1[1]=464.0; g_combos[i].d1[2]=326.0; g_combos[i].d1[3]=0.0;
   g_combos[i].d2[0]=712.5; g_combos[i].d2[1]=527.7; g_combos[i].d2[2]=329.2; g_combos[i].d2[3]=0.0;
   g_combos[i].d3[0]=712.5; g_combos[i].d3[1]=571.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=22; g_combos[i].nt[2]=36; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=7; g_combos[i].nok[2]=4; g_combos[i].nok[3]=0;
   i++;

   // EB2LG | ZE/BUY | n_ang=28 | Weak | score=42.3
   g_combos[i].code="EB2LG"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=28; g_combos[i].tier=4; g_combos[i].signal_score=42.33;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=20.83; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=20.00; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=554.2; g_combos[i].d1[1]=391.5; g_combos[i].d1[2]=515.8; g_combos[i].d1[3]=284.9;
   g_combos[i].d2[0]=611.3; g_combos[i].d2[1]=496.7; g_combos[i].d2[2]=577.8; g_combos[i].d2[3]=284.9;
   g_combos[i].d3[0]=642.5; g_combos[i].d3[1]=498.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=16; g_combos[i].nt[2]=25; g_combos[i].nt[3]=24;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=4; g_combos[i].nok[2]=5; g_combos[i].nok[3]=8;
   i++;

   // CB1MF | ZC/BUY | n_ang=21 | Weak | score=41.2
   g_combos[i].code="CB1MF"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=41.24;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=60.00; g_combos[i].p1[1]=47.06; g_combos[i].p1[2]=31.25; g_combos[i].p1[3]=36.84;
   g_combos[i].p2[0]=88.89; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=380.2; g_combos[i].d1[1]=384.5; g_combos[i].d1[2]=289.2; g_combos[i].d1[3]=413.7;
   g_combos[i].d2[0]=464.1; g_combos[i].d2[1]=443.5; g_combos[i].d2[2]=331.0; g_combos[i].d2[3]=413.7;
   g_combos[i].d3[0]=462.0; g_combos[i].d3[1]=458.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=17; g_combos[i].nt[2]=16; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=5; g_combos[i].nok[3]=7;
   i++;

   // CB2LB | ZC/BUY | n_ang=34 | Weak | score=40.8
   g_combos[i].code="CB2LB"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=34; g_combos[i].tier=4; g_combos[i].signal_score=40.82;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=8.70; g_combos[i].p1[1]=11.54; g_combos[i].p1[2]=26.92; g_combos[i].p1[3]=21.43;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=492.0; g_combos[i].d1[1]=583.0; g_combos[i].d1[2]=297.7; g_combos[i].d1[3]=301.6;
   g_combos[i].d2[0]=511.0; g_combos[i].d2[1]=401.0; g_combos[i].d2[2]=388.8; g_combos[i].d2[3]=301.6;
   g_combos[i].d3[0]=611.5; g_combos[i].d3[1]=401.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=26; g_combos[i].nt[2]=26; g_combos[i].nt[3]=28;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=3; g_combos[i].nok[2]=7; g_combos[i].nok[3]=6;
   i++;

   // EB2LE | ZE/BUY | n_ang=32 | Weak | score=39.6
   g_combos[i].code="EB2LE"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=32; g_combos[i].tier=4; g_combos[i].signal_score=39.60;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=18.18; g_combos[i].p1[1]=26.92; g_combos[i].p1[2]=21.74; g_combos[i].p1[3]=24.14;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=85.71; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=442.0; g_combos[i].d1[1]=381.7; g_combos[i].d1[2]=420.2; g_combos[i].d1[3]=437.3;
   g_combos[i].d2[0]=237.5; g_combos[i].d2[1]=575.8; g_combos[i].d2[2]=492.3; g_combos[i].d2[3]=437.3;
   g_combos[i].d3[0]=418.5; g_combos[i].d3[1]=576.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=26; g_combos[i].nt[2]=23; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=7; g_combos[i].nok[2]=5; g_combos[i].nok[3]=7;
   i++;

   // BB3MO | ZB/BUY | n_ang=31 | Weak | score=39.0
   g_combos[i].code="BB3MO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=31; g_combos[i].tier=4; g_combos[i].signal_score=38.97;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=35.00; g_combos[i].p1[2]=10.34; g_combos[i].p1[3]=16.67;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=71.43; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=246.2; g_combos[i].d1[1]=434.1; g_combos[i].d1[2]=211.3; g_combos[i].d1[3]=189.2;
   g_combos[i].d2[0]=456.0; g_combos[i].d2[1]=470.7; g_combos[i].d2[2]=281.7; g_combos[i].d2[3]=189.2;
   g_combos[i].d3[0]=568.5; g_combos[i].d3[1]=551.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=20; g_combos[i].nt[2]=29; g_combos[i].nt[3]=24;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=7; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // DB1MB | ZD/BUY | n_ang=18 | Weak | score=38.2
   g_combos[i].code="DB1MB"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=18; g_combos[i].tier=4; g_combos[i].signal_score=38.18;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=56.25; g_combos[i].p1[1]=44.44; g_combos[i].p1[2]=44.44; g_combos[i].p1[3]=15.38;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=25.00; g_combos[i].p2[2]=62.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=231.3; g_combos[i].d1[1]=387.5; g_combos[i].d1[2]=241.5; g_combos[i].d1[3]=389.0;
   g_combos[i].d2[0]=291.2; g_combos[i].d2[1]=231.0; g_combos[i].d2[2]=158.4; g_combos[i].d2[3]=389.0;
   g_combos[i].d3[0]=196.8; g_combos[i].d3[1]=234.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=9; g_combos[i].nt[2]=18; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=4; g_combos[i].nok[2]=8; g_combos[i].nok[3]=2;
   i++;

   // FB4MG | ZF/BUY | n_ang=40 | Weak | score=38.0
   g_combos[i].code="FB4MG"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=40; g_combos[i].tier=4; g_combos[i].signal_score=37.95;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=19.35; g_combos[i].p1[1]=13.33; g_combos[i].p1[2]=17.14; g_combos[i].p1[3]=10.00;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=421.0; g_combos[i].d1[1]=605.5; g_combos[i].d1[2]=442.3; g_combos[i].d1[3]=553.7;
   g_combos[i].d2[0]=644.8; g_combos[i].d2[1]=472.5; g_combos[i].d2[2]=489.7; g_combos[i].d2[3]=553.7;
   g_combos[i].d3[0]=651.0; g_combos[i].d3[1]=661.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=30; g_combos[i].nt[2]=35; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=4; g_combos[i].nok[2]=6; g_combos[i].nok[3]=3;
   i++;

   // HB4SH | ZH/BUY | n_ang=28 | Weak | score=37.0
   g_combos[i].code="HB4SH"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=28; g_combos[i].tier=4; g_combos[i].signal_score=37.04;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=25.93; g_combos[i].p1[1]=23.81; g_combos[i].p1[2]=10.71; g_combos[i].p1[3]=23.81;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=140.6; g_combos[i].d1[1]=82.6; g_combos[i].d1[2]=189.7; g_combos[i].d1[3]=102.8;
   g_combos[i].d2[0]=342.0; g_combos[i].d2[1]=104.6; g_combos[i].d2[2]=193.0; g_combos[i].d2[3]=102.8;
   g_combos[i].d3[0]=343.4; g_combos[i].d3[1]=101.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=21; g_combos[i].nt[2]=28; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=5; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // DB2MD | ZD/BUY | n_ang=21 | Weak | score=36.7
   g_combos[i].code="DB2MD"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=36.66;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=45.45; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=7.69;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=25.00; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=256.8; g_combos[i].d1[1]=103.6; g_combos[i].d1[2]=98.0; g_combos[i].d1[3]=43.0;
   g_combos[i].d2[0]=425.8; g_combos[i].d2[1]=188.0; g_combos[i].d2[2]=122.4; g_combos[i].d2[3]=43.0;
   g_combos[i].d3[0]=289.0; g_combos[i].d3[1]=198.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=11; g_combos[i].nt[2]=21; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=5; g_combos[i].nok[2]=7; g_combos[i].nok[3]=1;
   i++;

   // DB2SE | ZD/BUY | n_ang=21 | Weak | score=36.7
   g_combos[i].code="DB2SE"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=36.66;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=35.00; g_combos[i].p1[1]=63.64; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=66.67;
   g_combos[i].p2[0]=57.14; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.14; g_combos[i].p3[1]=57.14; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=162.7; g_combos[i].d1[1]=316.1; g_combos[i].d1[2]=166.5; g_combos[i].d1[3]=386.2;
   g_combos[i].d2[0]=382.5; g_combos[i].d2[1]=530.4; g_combos[i].d2[2]=405.2; g_combos[i].d2[3]=386.2;
   g_combos[i].d3[0]=478.2; g_combos[i].d3[1]=687.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=20; g_combos[i].nt[1]=11; g_combos[i].nt[2]=21; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=7; g_combos[i].nok[2]=6; g_combos[i].nok[3]=8;
   i++;

   // EB2LD | ZE/BUY | n_ang=27 | Weak | score=36.4
   g_combos[i].code="EB2LD"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=27; g_combos[i].tier=4; g_combos[i].signal_score=36.37;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=31.82; g_combos[i].p1[1]=26.67; g_combos[i].p1[2]=26.09; g_combos[i].p1[3]=11.76;
   g_combos[i].p2[0]=57.14; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=282.7; g_combos[i].d1[1]=515.0; g_combos[i].d1[2]=273.0; g_combos[i].d1[3]=547.5;
   g_combos[i].d2[0]=154.8; g_combos[i].d2[1]=568.5; g_combos[i].d2[2]=448.0; g_combos[i].d2[3]=547.5;
   g_combos[i].d3[0]=313.7; g_combos[i].d3[1]=523.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=15; g_combos[i].nt[2]=23; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=4; g_combos[i].nok[2]=6; g_combos[i].nok[3]=2;
   i++;

   // DB4SC | ZD/BUY | n_ang=19 | Weak | score=34.9
   g_combos[i].code="DB4SC"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=19; g_combos[i].tier=4; g_combos[i].signal_score=34.87;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=47.06; g_combos[i].p1[1]=35.29; g_combos[i].p1[2]=11.11; g_combos[i].p1[3]=23.53;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=238.1; g_combos[i].d1[1]=438.2; g_combos[i].d1[2]=169.0; g_combos[i].d1[3]=177.0;
   g_combos[i].d2[0]=374.7; g_combos[i].d2[1]=406.8; g_combos[i].d2[2]=169.0; g_combos[i].d2[3]=177.0;
   g_combos[i].d3[0]=395.7; g_combos[i].d3[1]=310.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=17; g_combos[i].nt[2]=18; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=6; g_combos[i].nok[2]=2; g_combos[i].nok[3]=4;
   i++;

   // EB2SO | ZE/BUY | n_ang=18 | Weak | score=33.9
   g_combos[i].code="EB2SO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=18; g_combos[i].tier=4; g_combos[i].signal_score=33.94;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=21.43; g_combos[i].p1[1]=66.67; g_combos[i].p1[2]=26.67; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=410.3; g_combos[i].d1[1]=227.9; g_combos[i].d1[2]=240.8; g_combos[i].d1[3]=106.2;
   g_combos[i].d2[0]=505.0; g_combos[i].d2[1]=401.0; g_combos[i].d2[2]=337.8; g_combos[i].d2[3]=106.2;
   g_combos[i].d3[0]=523.5; g_combos[i].d3[1]=459.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=12; g_combos[i].nt[2]=15; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=8; g_combos[i].nok[2]=4; g_combos[i].nok[3]=8;
   i++;

   // BB3MG | ZB/BUY | n_ang=23 | Weak | score=33.6
   g_combos[i].code="BB3MG"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=23; g_combos[i].tier=4; g_combos[i].signal_score=33.57;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=21.05; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=13.64; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=401.2; g_combos[i].d1[1]=396.0; g_combos[i].d1[2]=334.7; g_combos[i].d1[3]=314.0;
   g_combos[i].d2[0]=353.0; g_combos[i].d2[1]=650.0; g_combos[i].d2[2]=365.0; g_combos[i].d2[3]=314.0;
   g_combos[i].d3[0]=353.5; g_combos[i].d3[1]=623.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=14; g_combos[i].nt[2]=22; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=7; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // CB2LF | ZC/BUY | n_ang=29 | Weak | score=32.3
   g_combos[i].code="CB2LF"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=29; g_combos[i].tier=4; g_combos[i].signal_score=32.31;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=18.18; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=18.18; g_combos[i].p1[3]=8.33;
   g_combos[i].p2[0]=25.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=321.2; g_combos[i].d1[1]=326.0; g_combos[i].d1[2]=364.0; g_combos[i].d1[3]=495.0;
   g_combos[i].d2[0]=273.0; g_combos[i].d2[1]=401.2; g_combos[i].d2[2]=596.0; g_combos[i].d2[3]=495.0;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=414.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=21; g_combos[i].nt[2]=22; g_combos[i].nt[3]=24;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=6; g_combos[i].nok[2]=4; g_combos[i].nok[3]=2;
   i++;

   // BB2MC | ZB/BUY | n_ang=21 | Weak | score=32.1
   g_combos[i].code="BB2MC"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=32.08;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=36.84; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=7.69;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=83.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=255.3; g_combos[i].d1[1]=228.5; g_combos[i].d1[2]=298.6; g_combos[i].d1[3]=389.0;
   g_combos[i].d2[0]=474.0; g_combos[i].d2[1]=403.8; g_combos[i].d2[2]=375.4; g_combos[i].d2[3]=389.0;
   g_combos[i].d3[0]=522.6; g_combos[i].d3[1]=417.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=12; g_combos[i].nt[2]=20; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=6; g_combos[i].nok[2]=5; g_combos[i].nok[3]=1;
   i++;

   // DB2MG | ZD/BUY | n_ang=21 | Weak | score=32.1
   g_combos[i].code="DB2MG"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=32.08;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=29.41; g_combos[i].p1[1]=35.29; g_combos[i].p1[2]=41.18; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=342.6; g_combos[i].d1[1]=245.2; g_combos[i].d1[2]=470.7; g_combos[i].d1[3]=219.5;
   g_combos[i].d2[0]=553.8; g_combos[i].d2[1]=139.0; g_combos[i].d2[2]=376.2; g_combos[i].d2[3]=219.5;
   g_combos[i].d3[0]=308.0; g_combos[i].d3[1]=156.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=17; g_combos[i].nt[2]=17; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=6; g_combos[i].nok[2]=7; g_combos[i].nok[3]=2;
   i++;

   // DB2SG | ZD/BUY | n_ang=16 | Weak | score=32.0
   g_combos[i].code="DB2SG"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=4; g_combos[i].signal_score=32.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=53.33; g_combos[i].p1[1]=63.64; g_combos[i].p1[2]=18.75; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=71.43; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=344.4; g_combos[i].d1[1]=316.6; g_combos[i].d1[2]=217.0; g_combos[i].d1[3]=412.2;
   g_combos[i].d2[0]=300.7; g_combos[i].d2[1]=573.2; g_combos[i].d2[2]=274.7; g_combos[i].d2[3]=412.2;
   g_combos[i].d3[0]=350.8; g_combos[i].d3[1]=610.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=11; g_combos[i].nt[2]=16; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=7; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // BB2MH | ZB/BUY | n_ang=20 | Weak | score=31.3
   g_combos[i].code="BB2MH"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=20; g_combos[i].tier=4; g_combos[i].signal_score=31.30;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=38.89; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=21.05; g_combos[i].p1[3]=7.14;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=169.6; g_combos[i].d1[1]=373.8; g_combos[i].d1[2]=342.2; g_combos[i].d1[3]=89.0;
   g_combos[i].d2[0]=198.0; g_combos[i].d2[1]=425.7; g_combos[i].d2[2]=415.8; g_combos[i].d2[3]=89.0;
   g_combos[i].d3[0]=250.8; g_combos[i].d3[1]=277.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=18; g_combos[i].nt[1]=14; g_combos[i].nt[2]=19; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=4; g_combos[i].nok[2]=4; g_combos[i].nok[3]=1;
   i++;

   // CB2SO | ZC/BUY | n_ang=15 | Very Weak | score=31.0
   g_combos[i].code="CB2SO"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=30.98;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=72.73; g_combos[i].p1[1]=53.85; g_combos[i].p1[2]=40.00; g_combos[i].p1[3]=38.46;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=28.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=159.2; g_combos[i].d1[1]=287.4; g_combos[i].d1[2]=82.7; g_combos[i].d1[3]=135.2;
   g_combos[i].d2[0]=250.8; g_combos[i].d2[1]=424.8; g_combos[i].d2[2]=318.3; g_combos[i].d2[3]=135.2;
   g_combos[i].d3[0]=394.0; g_combos[i].d3[1]=610.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=13; g_combos[i].nt[2]=15; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=7; g_combos[i].nok[2]=6; g_combos[i].nok[3]=5;
   i++;

   // EB1LH | ZE/BUY | n_ang=19 | Very Weak | score=30.5
   g_combos[i].code="EB1LH"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=19; g_combos[i].tier=5; g_combos[i].signal_score=30.51;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=43.75; g_combos[i].p1[1]=23.08; g_combos[i].p1[2]=31.25; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=85.71; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=348.6; g_combos[i].d1[1]=570.3; g_combos[i].d1[2]=357.8; g_combos[i].d1[3]=514.5;
   g_combos[i].d2[0]=425.1; g_combos[i].d2[1]=812.0; g_combos[i].d2[2]=433.2; g_combos[i].d2[3]=514.5;
   g_combos[i].d3[0]=457.5; g_combos[i].d3[1]=812.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=13; g_combos[i].nt[2]=16; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=3; g_combos[i].nok[2]=5; g_combos[i].nok[3]=4;
   i++;

   // CB1LD | ZC/BUY | n_ang=24 | Very Weak | score=29.4
   g_combos[i].code="CB1LD"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=24; g_combos[i].tier=5; g_combos[i].signal_score=29.39;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=27.27; g_combos[i].p1[1]=42.86; g_combos[i].p1[2]=22.73; g_combos[i].p1[3]=29.41;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=40.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=16.67; g_combos[i].p3[1]=83.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=302.7; g_combos[i].d1[1]=308.8; g_combos[i].d1[2]=225.0; g_combos[i].d1[3]=303.4;
   g_combos[i].d2[0]=243.5; g_combos[i].d2[1]=589.0; g_combos[i].d2[2]=333.5; g_combos[i].d2[3]=303.4;
   g_combos[i].d3[0]=98.0; g_combos[i].d3[1]=595.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=14; g_combos[i].nt[2]=22; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=6; g_combos[i].nok[2]=5; g_combos[i].nok[3]=5;
   i++;

   // EB1LC | ZE/BUY | n_ang=17 | Very Weak | score=28.9
   g_combos[i].code="EB1LC"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=28.86;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=17.65; g_combos[i].p1[1]=42.86; g_combos[i].p1[2]=23.53; g_combos[i].p1[3]=63.64;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=156.3; g_combos[i].d1[1]=567.3; g_combos[i].d1[2]=491.2; g_combos[i].d1[3]=387.0;
   g_combos[i].d2[0]=534.0; g_combos[i].d2[1]=427.0; g_combos[i].d2[2]=728.7; g_combos[i].d2[3]=387.0;
   g_combos[i].d3[0]=728.7; g_combos[i].d3[1]=427.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=7; g_combos[i].nt[2]=17; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=3; g_combos[i].nok[2]=4; g_combos[i].nok[3]=7;
   i++;

   // EB2SE | ZE/BUY | n_ang=15 | Very Weak | score=27.1
   g_combos[i].code="EB2SE"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=27.11;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=63.64; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=46.67;
   g_combos[i].p2[0]=57.14; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=28.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=216.9; g_combos[i].d1[1]=359.0; g_combos[i].d1[2]=120.8; g_combos[i].d1[3]=142.7;
   g_combos[i].d2[0]=271.2; g_combos[i].d2[1]=595.2; g_combos[i].d2[2]=326.5; g_combos[i].d2[3]=142.7;
   g_combos[i].d3[0]=341.3; g_combos[i].d3[1]=663.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=11; g_combos[i].nt[2]=14; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=7; g_combos[i].nok[2]=4; g_combos[i].nok[3]=7;
   i++;

   // EB1LG | ZE/BUY | n_ang=20 | Very Weak | score=26.8
   g_combos[i].code="EB1LG"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=20; g_combos[i].tier=5; g_combos[i].signal_score=26.83;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=35.29; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=27.78; g_combos[i].p1[3]=38.46;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=403.0; g_combos[i].d1[1]=375.0; g_combos[i].d1[2]=613.0; g_combos[i].d1[3]=320.8;
   g_combos[i].d2[0]=540.3; g_combos[i].d2[1]=475.3; g_combos[i].d2[2]=600.0; g_combos[i].d2[3]=320.8;
   g_combos[i].d3[0]=624.0; g_combos[i].d3[1]=555.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=8; g_combos[i].nt[2]=18; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=4; g_combos[i].nok[2]=5; g_combos[i].nok[3]=5;
   i++;

   // FB4MD | ZF/BUY | n_ang=27 | Very Weak | score=26.0
   g_combos[i].code="FB4MD"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=27; g_combos[i].tier=5; g_combos[i].signal_score=25.98;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=10.00; g_combos[i].p1[1]=9.09; g_combos[i].p1[2]=19.23; g_combos[i].p1[3]=18.18;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=567.5; g_combos[i].d1[1]=279.0; g_combos[i].d1[2]=110.0; g_combos[i].d1[3]=533.5;
   g_combos[i].d2[0]=327.0; g_combos[i].d2[1]=391.0; g_combos[i].d2[2]=150.4; g_combos[i].d2[3]=533.5;
   g_combos[i].d3[0]=327.0; g_combos[i].d3[1]=502.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=20; g_combos[i].nt[1]=22; g_combos[i].nt[2]=26; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=2; g_combos[i].nok[2]=5; g_combos[i].nok[3]=4;
   i++;

   // FB4SH | ZF/BUY | n_ang=41 | Very Weak | score=25.6
   g_combos[i].code="FB4SH"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=41; g_combos[i].tier=5; g_combos[i].signal_score=25.61;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=8.57; g_combos[i].p1[1]=12.50; g_combos[i].p1[2]=7.32; g_combos[i].p1[3]=14.81;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=474.7; g_combos[i].d1[1]=428.0; g_combos[i].d1[2]=185.3; g_combos[i].d1[3]=629.8;
   g_combos[i].d2[0]=736.0; g_combos[i].d2[1]=499.5; g_combos[i].d2[2]=250.0; g_combos[i].d2[3]=629.8;
   g_combos[i].d3[0]=732.0; g_combos[i].d3[1]=618.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=24; g_combos[i].nt[2]=41; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=3; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // BB3ME | ZB/BUY | n_ang=18 | Very Weak | score=25.5
   g_combos[i].code="BB3ME"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=18; g_combos[i].tier=5; g_combos[i].signal_score=25.46;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=29.41; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=194.2; g_combos[i].d1[1]=271.8; g_combos[i].d1[2]=157.0; g_combos[i].d1[3]=455.5;
   g_combos[i].d2[0]=330.8; g_combos[i].d2[1]=384.7; g_combos[i].d2[2]=215.8; g_combos[i].d2[3]=455.5;
   g_combos[i].d3[0]=326.3; g_combos[i].d3[1]=393.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=8; g_combos[i].nt[2]=17; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=4; g_combos[i].nok[2]=5; g_combos[i].nok[3]=4;
   i++;

   // CB1MB | ZC/BUY | n_ang=17 | Very Weak | score=24.7
   g_combos[i].code="CB1MB"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=24.74;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=15.38; g_combos[i].p1[1]=35.71; g_combos[i].p1[2]=40.00; g_combos[i].p1[3]=14.29;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=152.5; g_combos[i].d1[1]=483.4; g_combos[i].d1[2]=301.7; g_combos[i].d1[3]=491.0;
   g_combos[i].d2[0]=338.5; g_combos[i].d2[1]=600.7; g_combos[i].d2[2]=367.7; g_combos[i].d2[3]=491.0;
   g_combos[i].d3[0]=477.0; g_combos[i].d3[1]=730.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=14; g_combos[i].nt[2]=15; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=5; g_combos[i].nok[2]=6; g_combos[i].nok[3]=2;
   i++;

   // CB2LO | ZC/BUY | n_ang=17 | Very Weak | score=24.7
   g_combos[i].code="CB2LO"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=24.74;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=9.09; g_combos[i].p1[2]=31.25; g_combos[i].p1[3]=23.08;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=230.5; g_combos[i].d1[1]=786.0; g_combos[i].d1[2]=485.6; g_combos[i].d1[3]=351.3;
   g_combos[i].d2[0]=485.6; g_combos[i].d2[1]=829.0; g_combos[i].d2[2]=528.0; g_combos[i].d2[3]=351.3;
   g_combos[i].d3[0]=528.0; g_combos[i].d3[1]=830.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=11; g_combos[i].nt[2]=16; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=1; g_combos[i].nok[2]=5; g_combos[i].nok[3]=3;
   i++;

   // EB2SB | ZE/BUY | n_ang=17 | Very Weak | score=24.7
   g_combos[i].code="EB2SB"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=24.74;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=35.71; g_combos[i].p1[2]=42.86; g_combos[i].p1[3]=6.67;
   g_combos[i].p2[0]=0.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=539.5; g_combos[i].d1[1]=122.4; g_combos[i].d1[2]=67.3; g_combos[i].d1[3]=152.0;
   g_combos[i].d2[0]=0.0; g_combos[i].d2[1]=683.2; g_combos[i].d2[2]=269.8; g_combos[i].d2[3]=152.0;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=577.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=6; g_combos[i].nt[1]=14; g_combos[i].nt[2]=14; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=5; g_combos[i].nok[2]=6; g_combos[i].nok[3]=1;
   i++;

   // EB3SO | ZE/BUY | n_ang=17 | Very Weak | score=24.7
   g_combos[i].code="EB3SO"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=24.74;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=30.77; g_combos[i].p1[1]=38.46; g_combos[i].p1[2]=7.14; g_combos[i].p1[3]=42.86;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=167.8; g_combos[i].d1[1]=175.8; g_combos[i].d1[2]=160.0; g_combos[i].d1[3]=368.8;
   g_combos[i].d2[0]=537.0; g_combos[i].d2[1]=285.3; g_combos[i].d2[2]=401.0; g_combos[i].d2[3]=368.8;
   g_combos[i].d3[0]=727.7; g_combos[i].d3[1]=399.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=13; g_combos[i].nt[2]=14; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=5; g_combos[i].nok[2]=1; g_combos[i].nok[3]=6;
   i++;

   // BB3MD | ZB/BUY | n_ang=16 | Very Weak | score=24.0
   g_combos[i].code="BB3MD"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=24.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=12.50; g_combos[i].p1[3]=10.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=253.3; g_combos[i].d1[1]=875.0; g_combos[i].d1[2]=170.0; g_combos[i].d1[3]=355.0;
   g_combos[i].d2[0]=415.5; g_combos[i].d2[1]=908.0; g_combos[i].d2[2]=136.0; g_combos[i].d2[3]=355.0;
   g_combos[i].d3[0]=429.5; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=9; g_combos[i].nt[2]=16; g_combos[i].nt[3]=10;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=2; g_combos[i].nok[2]=2; g_combos[i].nok[3]=1;
   i++;

   // OB4MD | ZO/BUY | n_ang=16 | Very Weak | score=24.0
   g_combos[i].code="OB4MD"; g_combos[i].cls="ZO"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=24.00;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=38.46; g_combos[i].p1[1]=18.75; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=37.50;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=384.8; g_combos[i].d1[1]=204.0; g_combos[i].d1[2]=554.7; g_combos[i].d1[3]=340.8;
   g_combos[i].d2[0]=436.2; g_combos[i].d2[1]=428.7; g_combos[i].d2[2]=556.7; g_combos[i].d2[3]=340.8;
   g_combos[i].d3[0]=437.4; g_combos[i].d3[1]=581.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=16; g_combos[i].nt[2]=13; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=3; g_combos[i].nok[2]=3; g_combos[i].nok[3]=6;
   i++;

   // HB4SC | ZH/BUY | n_ang=22 | Very Weak | score=23.4
   g_combos[i].code="HB4SC"; g_combos[i].cls="ZH"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=22; g_combos[i].tier=5; g_combos[i].signal_score=23.45;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=16.67; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=4.76; g_combos[i].p1[3]=27.78;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=123.0; g_combos[i].d1[1]=41.5; g_combos[i].d1[2]=45.0; g_combos[i].d1[3]=57.2;
   g_combos[i].d2[0]=158.0; g_combos[i].d2[1]=61.0; g_combos[i].d2[2]=45.0; g_combos[i].d2[3]=57.2;
   g_combos[i].d3[0]=158.5; g_combos[i].d3[1]=212.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=18; g_combos[i].nt[1]=18; g_combos[i].nt[2]=21; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=4; g_combos[i].nok[2]=1; g_combos[i].nok[3]=5;
   i++;

   // BB2LO | ZB/BUY | n_ang=15 | Very Weak | score=23.2
   g_combos[i].code="BB2LO"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=23.24;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=11.11; g_combos[i].p1[2]=7.69; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=374.3; g_combos[i].d1[1]=329.0; g_combos[i].d1[2]=338.0; g_combos[i].d1[3]=252.0;
   g_combos[i].d2[0]=439.6; g_combos[i].d2[1]=411.0; g_combos[i].d2[2]=444.0; g_combos[i].d2[3]=252.0;
   g_combos[i].d3[0]=461.0; g_combos[i].d3[1]=412.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=12; g_combos[i].nt[1]=9; g_combos[i].nt[2]=13; g_combos[i].nt[3]=9;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=1; g_combos[i].nok[2]=1; g_combos[i].nok[3]=1;
   i++;

   // BB3MB | ZB/BUY | n_ang=21 | Very Weak | score=22.9
   g_combos[i].code="BB3MB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=21; g_combos[i].tier=5; g_combos[i].signal_score=22.91;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=15.79; g_combos[i].p1[1]=45.45; g_combos[i].p1[2]=10.00; g_combos[i].p1[3]=18.18;
   g_combos[i].p2[0]=33.33; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=529.7; g_combos[i].d1[1]=383.6; g_combos[i].d1[2]=169.5; g_combos[i].d1[3]=482.0;
   g_combos[i].d2[0]=187.0; g_combos[i].d2[1]=635.4; g_combos[i].d2[2]=175.0; g_combos[i].d2[3]=482.0;
   g_combos[i].d3[0]=188.0; g_combos[i].d3[1]=408.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=11; g_combos[i].nt[2]=20; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=5; g_combos[i].nok[2]=2; g_combos[i].nok[3]=2;
   i++;

   // EB2MC | ZE/BUY | n_ang=17 | Very Weak | score=20.6
   g_combos[i].code="EB2MC"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=20.62;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=36.36; g_combos[i].p1[1]=41.67; g_combos[i].p1[2]=41.67; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=131.8; g_combos[i].d1[1]=327.6; g_combos[i].d1[2]=334.2; g_combos[i].d1[3]=163.0;
   g_combos[i].d2[0]=324.0; g_combos[i].d2[1]=460.0; g_combos[i].d2[2]=525.3; g_combos[i].d2[3]=163.0;
   g_combos[i].d3[0]=635.3; g_combos[i].d3[1]=329.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=12; g_combos[i].nt[2]=12; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=5; g_combos[i].nok[2]=5; g_combos[i].nok[3]=4;
   i++;

   // BB2SC | ZB/BUY | n_ang=16 | Very Weak | score=20.0
   g_combos[i].code="BB2SC"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=20.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.71; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=181.0; g_combos[i].d1[1]=372.5; g_combos[i].d1[2]=115.0; g_combos[i].d1[3]=339.6;
   g_combos[i].d2[0]=235.2; g_combos[i].d2[1]=454.7; g_combos[i].d2[2]=318.5; g_combos[i].d2[3]=339.6;
   g_combos[i].d3[0]=471.0; g_combos[i].d3[1]=599.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=8; g_combos[i].nt[2]=16; g_combos[i].nt[3]=10;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=4; g_combos[i].nok[2]=4; g_combos[i].nok[3]=5;
   i++;

   // EB2MH | ZE/BUY | n_ang=16 | Very Weak | score=20.0
   g_combos[i].code="EB2MH"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=20.00;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=30.77; g_combos[i].p1[1]=55.56; g_combos[i].p1[2]=20.00; g_combos[i].p1[3]=28.57;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.8; g_combos[i].d1[1]=460.8; g_combos[i].d1[2]=359.3; g_combos[i].d1[3]=348.0;
   g_combos[i].d2[0]=434.3; g_combos[i].d2[1]=627.4; g_combos[i].d2[2]=253.0; g_combos[i].d2[3]=348.0;
   g_combos[i].d3[0]=309.5; g_combos[i].d3[1]=658.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=9; g_combos[i].nt[2]=15; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=5; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // OB4MO | ZO/BUY | n_ang=16 | Very Weak | score=20.0
   g_combos[i].code="OB4MO"; g_combos[i].cls="ZO"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=20.00;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=18.18; g_combos[i].p1[1]=7.69; g_combos[i].p1[2]=38.46; g_combos[i].p1[3]=23.08;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=229.0; g_combos[i].d1[1]=516.0; g_combos[i].d1[2]=287.0; g_combos[i].d1[3]=155.0;
   g_combos[i].d2[0]=314.0; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=287.6; g_combos[i].d2[3]=155.0;
   g_combos[i].d3[0]=314.5; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=13; g_combos[i].nt[2]=13; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=1; g_combos[i].nok[2]=5; g_combos[i].nok[3]=3;
   i++;

   // CB2LE | ZC/BUY | n_ang=20 | Very Weak | score=17.9
   g_combos[i].code="CB2LE"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=20; g_combos[i].tier=5; g_combos[i].signal_score=17.89;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=0.00; g_combos[i].p1[1]=30.77; g_combos[i].p1[2]=12.50; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=0.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=0.0; g_combos[i].d1[1]=135.8; g_combos[i].d1[2]=505.0; g_combos[i].d1[3]=657.3;
   g_combos[i].d2[0]=0.0; g_combos[i].d2[1]=169.8; g_combos[i].d2[2]=539.0; g_combos[i].d2[3]=657.3;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=190.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=13; g_combos[i].nt[2]=16; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=0; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=3;
   i++;

   // BB2LB | ZB/BUY | n_ang=17 | Very Weak | score=16.5
   g_combos[i].code="BB2LB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=16.49;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=9.09; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=13.33;
   g_combos[i].p2[0]=33.33; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=25.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=475.0; g_combos[i].d1[1]=205.0; g_combos[i].d1[2]=530.0; g_combos[i].d1[3]=580.5;
   g_combos[i].d2[0]=179.0; g_combos[i].d2[1]=852.0; g_combos[i].d2[2]=179.0; g_combos[i].d2[3]=580.5;
   g_combos[i].d3[0]=179.0; g_combos[i].d3[1]=852.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=11; g_combos[i].nt[2]=14; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=1; g_combos[i].nok[2]=4; g_combos[i].nok[3]=2;
   i++;

   // CB2MD | ZC/BUY | n_ang=17 | Very Weak | score=16.5
   g_combos[i].code="CB2MD"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=16.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=11.76; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=25.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=413.0; g_combos[i].d1[1]=153.0; g_combos[i].d1[2]=192.0; g_combos[i].d1[3]=321.2;
   g_combos[i].d2[0]=492.5; g_combos[i].d2[1]=249.5; g_combos[i].d2[2]=260.5; g_combos[i].d2[3]=321.2;
   g_combos[i].d3[0]=183.0; g_combos[i].d3[1]=291.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=9; g_combos[i].nt[2]=17; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=2; g_combos[i].nok[2]=2; g_combos[i].nok[3]=4;
   i++;

   // CB1LE | ZC/BUY | n_ang=15 | Very Weak | score=15.5
   g_combos[i].code="CB1LE"; g_combos[i].cls="ZC"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=15.49;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=44.44; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=91.0; g_combos[i].d1[1]=219.0; g_combos[i].d1[2]=186.7; g_combos[i].d1[3]=182.0;
   g_combos[i].d2[0]=134.0; g_combos[i].d2[1]=156.5; g_combos[i].d2[2]=216.0; g_combos[i].d2[3]=182.0;
   g_combos[i].d3[0]=148.7; g_combos[i].d3[1]=156.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=9; g_combos[i].nt[2]=13; g_combos[i].nt[3]=9;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=4; g_combos[i].nok[2]=3; g_combos[i].nok[3]=1;
   i++;

   // DB2LF | ZD/BUY | n_ang=15 | Very Weak | score=15.5
   g_combos[i].code="DB2LF"; g_combos[i].cls="ZD"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=15.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.77; g_combos[i].p1[1]=11.11; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=9.09;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=242.2; g_combos[i].d1[1]=780.0; g_combos[i].d1[2]=506.7; g_combos[i].d1[3]=324.0;
   g_combos[i].d2[0]=329.8; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=502.5; g_combos[i].d2[3]=324.0;
   g_combos[i].d3[0]=484.3; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=9; g_combos[i].nt[2]=13; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=1; g_combos[i].nok[2]=3; g_combos[i].nok[3]=1;
   i++;

   // FB4MH | ZF/BUY | n_ang=18 | Very Weak | score=12.7
   g_combos[i].code="FB4MH"; g_combos[i].cls="ZF"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=18; g_combos[i].tier=5; g_combos[i].signal_score=12.73;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=12.50; g_combos[i].p1[1]=9.09; g_combos[i].p1[2]=16.67; g_combos[i].p1[3]=18.18;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=184.5; g_combos[i].d1[1]=396.0; g_combos[i].d1[2]=112.7; g_combos[i].d1[3]=546.0;
   g_combos[i].d2[0]=411.5; g_combos[i].d2[1]=403.0; g_combos[i].d2[2]=112.7; g_combos[i].d2[3]=546.0;
   g_combos[i].d3[0]=635.0; g_combos[i].d3[1]=500.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=11; g_combos[i].nt[2]=18; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=1; g_combos[i].nok[2]=3; g_combos[i].nok[3]=2;
   i++;

   // EB2LH | ZE/BUY | n_ang=16 | Very Weak | score=12.0
   g_combos[i].code="EB2LH"; g_combos[i].cls="ZE"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=12.00;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=10.00; g_combos[i].p1[1]=0.00; g_combos[i].p1[2]=16.67; g_combos[i].p1[3]=30.00;
   g_combos[i].p2[0]=0.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=554.0; g_combos[i].d1[1]=0.0; g_combos[i].d1[2]=140.5; g_combos[i].d1[3]=505.7;
   g_combos[i].d2[0]=0.0; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=209.0; g_combos[i].d2[3]=505.7;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=10; g_combos[i].nt[1]=8; g_combos[i].nt[2]=12; g_combos[i].nt[3]=10;
   g_combos[i].nok[0]=1; g_combos[i].nok[1]=0; g_combos[i].nok[2]=2; g_combos[i].nok[3]=3;
   i++;

   // BB1LB | ZB/BUY | n_ang=15 | Very Weak | score=11.6
   g_combos[i].code="BB1LB"; g_combos[i].cls="ZB"; g_combos[i].dir="BUY";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=11.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=21.43; g_combos[i].p1[1]=60.00; g_combos[i].p1[2]=7.14; g_combos[i].p1[3]=42.86;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=284.7; g_combos[i].d1[1]=526.3; g_combos[i].d1[2]=709.0; g_combos[i].d1[3]=284.0;
   g_combos[i].d2[0]=461.0; g_combos[i].d2[1]=756.0; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=284.0;
   g_combos[i].d3[0]=571.5; g_combos[i].d3[1]=758.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=5; g_combos[i].nt[2]=14; g_combos[i].nt[3]=7;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=3; g_combos[i].nok[2]=1; g_combos[i].nok[3]=3;
   i++;

   // BS4SB | ZB/SELL | n_ang=112 | Full Margin | score=423.3
   g_combos[i].code="BS4SB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=112; g_combos[i].tier=1; g_combos[i].signal_score=423.32;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=43.01; g_combos[i].p1[1]=22.86; g_combos[i].p1[2]=2.68; g_combos[i].p1[3]=22.78;
   g_combos[i].p2[0]=55.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=56.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=170.3; g_combos[i].d1[1]=484.7; g_combos[i].d1[2]=114.7; g_combos[i].d1[3]=549.5;
   g_combos[i].d2[0]=343.0; g_combos[i].d2[1]=497.4; g_combos[i].d2[2]=290.7; g_combos[i].d2[3]=549.5;
   g_combos[i].d3[0]=387.9; g_combos[i].d3[1]=632.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=93; g_combos[i].nt[1]=70; g_combos[i].nt[2]=112; g_combos[i].nt[3]=79;
   g_combos[i].nok[0]=40; g_combos[i].nok[1]=16; g_combos[i].nok[2]=3; g_combos[i].nok[3]=18;
   i++;

   // BS4SE | ZB/SELL | n_ang=102 | Full Margin | score=414.1
   g_combos[i].code="BS4SE"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=102; g_combos[i].tier=1; g_combos[i].signal_score=414.08;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=47.67; g_combos[i].p1[1]=32.35; g_combos[i].p1[2]=3.96; g_combos[i].p1[3]=27.63;
   g_combos[i].p2[0]=60.98; g_combos[i].p2[1]=77.27; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=56.10; g_combos[i].p3[1]=59.09; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=262.8; g_combos[i].d1[1]=399.3; g_combos[i].d1[2]=278.0; g_combos[i].d1[3]=394.9;
   g_combos[i].d2[0]=426.1; g_combos[i].d2[1]=437.0; g_combos[i].d2[2]=318.2; g_combos[i].d2[3]=394.9;
   g_combos[i].d3[0]=457.0; g_combos[i].d3[1]=488.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=86; g_combos[i].nt[1]=68; g_combos[i].nt[2]=101; g_combos[i].nt[3]=76;
   g_combos[i].nok[0]=41; g_combos[i].nok[1]=22; g_combos[i].nok[2]=4; g_combos[i].nok[3]=21;
   i++;

   // BS4SF | ZB/SELL | n_ang=111 | Full Margin | score=410.9
   g_combos[i].code="BS4SF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=111; g_combos[i].tier=1; g_combos[i].signal_score=410.89;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=40.21; g_combos[i].p1[1]=36.51; g_combos[i].p1[2]=2.70; g_combos[i].p1[3]=34.29;
   g_combos[i].p2[0]=64.10; g_combos[i].p2[1]=78.26; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.85; g_combos[i].p3[1]=47.83; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.6; g_combos[i].d1[1]=355.5; g_combos[i].d1[2]=34.0; g_combos[i].d1[3]=373.0;
   g_combos[i].d2[0]=410.5; g_combos[i].d2[1]=390.1; g_combos[i].d2[2]=67.0; g_combos[i].d2[3]=373.0;
   g_combos[i].d3[0]=446.0; g_combos[i].d3[1]=461.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=97; g_combos[i].nt[1]=63; g_combos[i].nt[2]=111; g_combos[i].nt[3]=70;
   g_combos[i].nok[0]=39; g_combos[i].nok[1]=23; g_combos[i].nok[2]=3; g_combos[i].nok[3]=24;
   i++;

   // BS3SO | ZB/SELL | n_ang=81 | Full Margin | score=315.0
   g_combos[i].code="BS3SO"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=81; g_combos[i].tier=1; g_combos[i].signal_score=315.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=51.47; g_combos[i].p1[1]=42.59; g_combos[i].p1[2]=22.78; g_combos[i].p1[3]=36.07;
   g_combos[i].p2[0]=77.14; g_combos[i].p2[1]=69.57; g_combos[i].p2[2]=94.44; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=52.17; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=195.0; g_combos[i].d1[1]=299.3; g_combos[i].d1[2]=200.3; g_combos[i].d1[3]=327.0;
   g_combos[i].d2[0]=345.7; g_combos[i].d2[1]=378.0; g_combos[i].d2[2]=286.0; g_combos[i].d2[3]=327.0;
   g_combos[i].d3[0]=419.4; g_combos[i].d3[1]=280.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=68; g_combos[i].nt[1]=54; g_combos[i].nt[2]=79; g_combos[i].nt[3]=61;
   g_combos[i].nok[0]=35; g_combos[i].nok[1]=23; g_combos[i].nok[2]=18; g_combos[i].nok[3]=22;
   i++;

   // BS4SO | ZB/SELL | n_ang=100 | Full Margin | score=300.0
   g_combos[i].code="BS4SO"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=100; g_combos[i].tier=1; g_combos[i].signal_score=300.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=34.88; g_combos[i].p1[1]=42.37; g_combos[i].p1[2]=7.00; g_combos[i].p1[3]=38.46;
   g_combos[i].p2[0]=46.67; g_combos[i].p2[1]=76.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=43.33; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=159.4; g_combos[i].d1[1]=384.8; g_combos[i].d1[2]=178.7; g_combos[i].d1[3]=369.6;
   g_combos[i].d2[0]=353.3; g_combos[i].d2[1]=474.3; g_combos[i].d2[2]=334.7; g_combos[i].d2[3]=369.6;
   g_combos[i].d3[0]=420.4; g_combos[i].d3[1]=497.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=86; g_combos[i].nt[1]=59; g_combos[i].nt[2]=100; g_combos[i].nt[3]=65;
   g_combos[i].nok[0]=30; g_combos[i].nok[1]=25; g_combos[i].nok[2]=7; g_combos[i].nok[3]=25;
   i++;

   // BS3SF | ZB/SELL | n_ang=80 | Full Margin | score=277.3
   g_combos[i].code="BS3SF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=80; g_combos[i].tier=1; g_combos[i].signal_score=277.27;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=46.27; g_combos[i].p1[1]=32.65; g_combos[i].p1[2]=11.84; g_combos[i].p1[3]=50.88;
   g_combos[i].p2[0]=70.97; g_combos[i].p2[1]=68.75; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.06; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=201.3; g_combos[i].d1[1]=372.1; g_combos[i].d1[2]=166.9; g_combos[i].d1[3]=324.1;
   g_combos[i].d2[0]=438.2; g_combos[i].d2[1]=470.5; g_combos[i].d2[2]=254.6; g_combos[i].d2[3]=324.1;
   g_combos[i].d3[0]=570.5; g_combos[i].d3[1]=532.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=67; g_combos[i].nt[1]=49; g_combos[i].nt[2]=76; g_combos[i].nt[3]=57;
   g_combos[i].nok[0]=31; g_combos[i].nok[1]=16; g_combos[i].nok[2]=9; g_combos[i].nok[3]=29;
   i++;

   // BS3SB | ZB/SELL | n_ang=104 | Full Margin | score=244.8
   g_combos[i].code="BS3SB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=104; g_combos[i].tier=1; g_combos[i].signal_score=244.75;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=27.91; g_combos[i].p1[1]=36.84; g_combos[i].p1[2]=12.50; g_combos[i].p1[3]=22.54;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=52.38; g_combos[i].p2[2]=92.31; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.83; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=202.5; g_combos[i].d1[1]=363.0; g_combos[i].d1[2]=166.8; g_combos[i].d1[3]=291.4;
   g_combos[i].d2[0]=343.9; g_combos[i].d2[1]=392.0; g_combos[i].d2[2]=212.8; g_combos[i].d2[3]=291.4;
   g_combos[i].d3[0]=329.4; g_combos[i].d3[1]=591.1; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=86; g_combos[i].nt[1]=57; g_combos[i].nt[2]=104; g_combos[i].nt[3]=71;
   g_combos[i].nok[0]=24; g_combos[i].nok[1]=21; g_combos[i].nok[2]=13; g_combos[i].nok[3]=16;
   i++;

   // ES2MF | ZE/SELL | n_ang=102 | Full Margin | score=242.4
   g_combos[i].code="ES2MF"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=102; g_combos[i].tier=1; g_combos[i].signal_score=242.39;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.88; g_combos[i].p1[1]=29.33; g_combos[i].p1[2]=30.38; g_combos[i].p1[3]=18.60;
   g_combos[i].p2[0]=85.71; g_combos[i].p2[1]=59.09; g_combos[i].p2[2]=79.17; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=40.91; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=387.8; g_combos[i].d1[1]=350.0; g_combos[i].d1[2]=294.3; g_combos[i].d1[3]=414.9;
   g_combos[i].d2[0]=475.4; g_combos[i].d2[1]=419.6; g_combos[i].d2[2]=419.4; g_combos[i].d2[3]=414.9;
   g_combos[i].d3[0]=591.7; g_combos[i].d3[1]=376.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=68; g_combos[i].nt[1]=75; g_combos[i].nt[2]=79; g_combos[i].nt[3]=86;
   g_combos[i].nok[0]=21; g_combos[i].nok[1]=22; g_combos[i].nok[2]=24; g_combos[i].nok[3]=16;
   i++;

   // FS4SB | ZF/SELL | n_ang=114 | Full Margin | score=234.9
   g_combos[i].code="FS4SB"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=114; g_combos[i].tier=1; g_combos[i].signal_score=234.90;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=23.91; g_combos[i].p1[1]=22.86; g_combos[i].p1[2]=3.54; g_combos[i].p1[3]=16.67;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=68.75; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=68.18; g_combos[i].p3[1]=37.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=194.5; g_combos[i].d1[1]=489.8; g_combos[i].d1[2]=261.8; g_combos[i].d1[3]=307.1;
   g_combos[i].d2[0]=392.1; g_combos[i].d2[1]=466.1; g_combos[i].d2[2]=275.5; g_combos[i].d2[3]=307.1;
   g_combos[i].d3[0]=412.5; g_combos[i].d3[1]=403.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=92; g_combos[i].nt[1]=70; g_combos[i].nt[2]=113; g_combos[i].nt[3]=72;
   g_combos[i].nok[0]=22; g_combos[i].nok[1]=16; g_combos[i].nok[2]=4; g_combos[i].nok[3]=12;
   i++;

   // BS4SG | ZB/SELL | n_ang=81 | Full Margin | score=234.0
   g_combos[i].code="BS4SG"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=81; g_combos[i].tier=1; g_combos[i].signal_score=234.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=38.81; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=3.75; g_combos[i].p1[3]=28.30;
   g_combos[i].p2[0]=57.69; g_combos[i].p2[1]=88.24; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=47.06; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=238.7; g_combos[i].d1[1]=424.0; g_combos[i].d1[2]=345.3; g_combos[i].d1[3]=459.1;
   g_combos[i].d2[0]=430.6; g_combos[i].d2[1]=517.9; g_combos[i].d2[2]=381.7; g_combos[i].d2[3]=459.1;
   g_combos[i].d3[0]=452.3; g_combos[i].d3[1]=706.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=67; g_combos[i].nt[1]=51; g_combos[i].nt[2]=80; g_combos[i].nt[3]=53;
   g_combos[i].nok[0]=26; g_combos[i].nok[1]=17; g_combos[i].nok[2]=3; g_combos[i].nok[3]=15;
   i++;

   // BS2MB | ZB/SELL | n_ang=73 | Full Margin | score=230.7
   g_combos[i].code="BS2MB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=73; g_combos[i].tier=1; g_combos[i].signal_score=230.69;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=45.76; g_combos[i].p1[1]=23.81; g_combos[i].p1[2]=28.17; g_combos[i].p1[3]=22.92;
   g_combos[i].p2[0]=59.26; g_combos[i].p2[1]=40.00; g_combos[i].p2[2]=90.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=55.56; g_combos[i].p3[1]=10.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.7; g_combos[i].d1[1]=534.5; g_combos[i].d1[2]=373.2; g_combos[i].d1[3]=415.8;
   g_combos[i].d2[0]=358.7; g_combos[i].d2[1]=665.2; g_combos[i].d2[2]=459.7; g_combos[i].d2[3]=415.8;
   g_combos[i].d3[0]=493.3; g_combos[i].d3[1]=689.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=59; g_combos[i].nt[1]=42; g_combos[i].nt[2]=71; g_combos[i].nt[3]=48;
   g_combos[i].nok[0]=27; g_combos[i].nok[1]=10; g_combos[i].nok[2]=20; g_combos[i].nok[3]=11;
   i++;

   // BS2MF | ZB/SELL | n_ang=73 | Full Margin | score=222.1
   g_combos[i].code="BS2MF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=73; g_combos[i].tier=1; g_combos[i].signal_score=222.14;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=43.33; g_combos[i].p1[1]=28.21; g_combos[i].p1[2]=27.94; g_combos[i].p1[3]=17.31;
   g_combos[i].p2[0]=61.54; g_combos[i].p2[1]=36.36; g_combos[i].p2[2]=73.68; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=27.27; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=290.5; g_combos[i].d1[1]=449.5; g_combos[i].d1[2]=281.1; g_combos[i].d1[3]=295.8;
   g_combos[i].d2[0]=453.8; g_combos[i].d2[1]=549.0; g_combos[i].d2[2]=352.9; g_combos[i].d2[3]=295.8;
   g_combos[i].d3[0]=578.7; g_combos[i].d3[1]=458.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=60; g_combos[i].nt[1]=39; g_combos[i].nt[2]=68; g_combos[i].nt[3]=52;
   g_combos[i].nok[0]=26; g_combos[i].nok[1]=11; g_combos[i].nok[2]=19; g_combos[i].nok[3]=9;
   i++;

   // FS4SE | ZF/SELL | n_ang=109 | Full Margin | score=219.2
   g_combos[i].code="FS4SE"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=109; g_combos[i].tier=1; g_combos[i].signal_score=219.25;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=21.21; g_combos[i].p1[1]=23.88; g_combos[i].p1[2]=11.11; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=47.62; g_combos[i].p2[1]=81.25; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.62; g_combos[i].p3[1]=56.25; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=226.0; g_combos[i].d1[1]=453.2; g_combos[i].d1[2]=339.7; g_combos[i].d1[3]=431.0;
   g_combos[i].d2[0]=626.4; g_combos[i].d2[1]=409.2; g_combos[i].d2[2]=346.6; g_combos[i].d2[3]=431.0;
   g_combos[i].d3[0]=673.5; g_combos[i].d3[1]=533.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=99; g_combos[i].nt[1]=67; g_combos[i].nt[2]=108; g_combos[i].nt[3]=75;
   g_combos[i].nok[0]=21; g_combos[i].nok[1]=16; g_combos[i].nok[2]=12; g_combos[i].nok[3]=20;
   i++;

   // FS4SO | ZF/SELL | n_ang=125 | Full Margin | score=212.4
   g_combos[i].code="FS4SO"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=125; g_combos[i].tier=1; g_combos[i].signal_score=212.43;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=18.45; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=4.84; g_combos[i].p1[3]=21.92;
   g_combos[i].p2[0]=47.37; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.37; g_combos[i].p3[1]=37.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=280.4; g_combos[i].d1[1]=379.8; g_combos[i].d1[2]=308.7; g_combos[i].d1[3]=492.9;
   g_combos[i].d2[0]=393.6; g_combos[i].d2[1]=440.1; g_combos[i].d2[2]=338.0; g_combos[i].d2[3]=492.9;
   g_combos[i].d3[0]=400.0; g_combos[i].d3[1]=486.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=103; g_combos[i].nt[1]=72; g_combos[i].nt[2]=124; g_combos[i].nt[3]=73;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=16; g_combos[i].nok[2]=6; g_combos[i].nok[3]=16;
   i++;

   // ES2MB | ZE/SELL | n_ang=84 | Full Margin | score=210.8
   g_combos[i].code="ES2MB"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=84; g_combos[i].tier=1; g_combos[i].signal_score=210.80;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.38; g_combos[i].p1[1]=27.12; g_combos[i].p1[2]=27.03; g_combos[i].p1[3]=30.88;
   g_combos[i].p2[0]=78.26; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=85.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=65.22; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=364.6; g_combos[i].d1[1]=382.6; g_combos[i].d1[2]=419.4; g_combos[i].d1[3]=438.3;
   g_combos[i].d2[0]=517.4; g_combos[i].d2[1]=529.3; g_combos[i].d2[2]=462.6; g_combos[i].d2[3]=438.3;
   g_combos[i].d3[0]=576.4; g_combos[i].d3[1]=547.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=65; g_combos[i].nt[1]=59; g_combos[i].nt[2]=74; g_combos[i].nt[3]=68;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=16; g_combos[i].nok[2]=20; g_combos[i].nok[3]=21;
   i++;

   // DS4SO | ZD/SELL | n_ang=70 | Full Margin | score=209.2
   g_combos[i].code="DS4SO"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=70; g_combos[i].tier=1; g_combos[i].signal_score=209.17;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=44.64; g_combos[i].p1[1]=45.83; g_combos[i].p1[2]=7.25; g_combos[i].p1[3]=42.59;
   g_combos[i].p2[0]=68.00; g_combos[i].p2[1]=72.73; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=201.4; g_combos[i].d1[1]=373.0; g_combos[i].d1[2]=118.2; g_combos[i].d1[3]=302.5;
   g_combos[i].d2[0]=330.2; g_combos[i].d2[1]=472.8; g_combos[i].d2[2]=142.6; g_combos[i].d2[3]=302.5;
   g_combos[i].d3[0]=340.1; g_combos[i].d3[1]=581.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=56; g_combos[i].nt[1]=48; g_combos[i].nt[2]=69; g_combos[i].nt[3]=54;
   g_combos[i].nok[0]=25; g_combos[i].nok[1]=22; g_combos[i].nok[2]=5; g_combos[i].nok[3]=23;
   i++;

   // DS4SB | ZD/SELL | n_ang=65 | Full Margin | score=185.4
   g_combos[i].code="DS4SB"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=65; g_combos[i].tier=1; g_combos[i].signal_score=185.43;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=38.98; g_combos[i].p1[1]=36.00; g_combos[i].p1[2]=4.69; g_combos[i].p1[3]=32.08;
   g_combos[i].p2[0]=73.91; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=69.57; g_combos[i].p3[1]=55.56; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=186.3; g_combos[i].d1[1]=386.8; g_combos[i].d1[2]=166.7; g_combos[i].d1[3]=256.5;
   g_combos[i].d2[0]=360.6; g_combos[i].d2[1]=395.9; g_combos[i].d2[2]=290.3; g_combos[i].d2[3]=256.5;
   g_combos[i].d3[0]=458.4; g_combos[i].d3[1]=401.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=59; g_combos[i].nt[1]=50; g_combos[i].nt[2]=64; g_combos[i].nt[3]=53;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=18; g_combos[i].nok[2]=3; g_combos[i].nok[3]=17;
   i++;

   // BS4SD | ZB/SELL | n_ang=68 | Full Margin | score=181.4
   g_combos[i].code="BS4SD"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=68; g_combos[i].tier=1; g_combos[i].signal_score=181.42;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=38.89; g_combos[i].p1[1]=36.84; g_combos[i].p1[2]=7.35; g_combos[i].p1[3]=44.00;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=28.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=122.5; g_combos[i].d1[1]=397.1; g_combos[i].d1[2]=76.0; g_combos[i].d1[3]=344.6;
   g_combos[i].d2[0]=332.7; g_combos[i].d2[1]=622.0; g_combos[i].d2[2]=93.8; g_combos[i].d2[3]=344.6;
   g_combos[i].d3[0]=300.9; g_combos[i].d3[1]=853.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=54; g_combos[i].nt[1]=38; g_combos[i].nt[2]=68; g_combos[i].nt[3]=50;
   g_combos[i].nok[0]=21; g_combos[i].nok[1]=14; g_combos[i].nok[2]=5; g_combos[i].nok[3]=22;
   i++;

   // BS2SF | ZB/SELL | n_ang=56 | Full Margin | score=179.6
   g_combos[i].code="BS2SF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=56; g_combos[i].tier=1; g_combos[i].signal_score=179.60;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=54.55; g_combos[i].p1[1]=48.15; g_combos[i].p1[2]=38.89; g_combos[i].p1[3]=32.50;
   g_combos[i].p2[0]=54.17; g_combos[i].p2[1]=53.85; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=29.17; g_combos[i].p3[1]=46.15; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=281.4; g_combos[i].d1[1]=464.8; g_combos[i].d1[2]=166.1; g_combos[i].d1[3]=215.8;
   g_combos[i].d2[0]=499.2; g_combos[i].d2[1]=469.7; g_combos[i].d2[2]=201.3; g_combos[i].d2[3]=215.8;
   g_combos[i].d3[0]=535.1; g_combos[i].d3[1]=413.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=44; g_combos[i].nt[1]=27; g_combos[i].nt[2]=54; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=24; g_combos[i].nok[1]=13; g_combos[i].nok[2]=21; g_combos[i].nok[3]=13;
   i++;

   // DS3SB | ZD/SELL | n_ang=53 | Full Margin | score=167.4
   g_combos[i].code="DS3SB"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=53; g_combos[i].tier=1; g_combos[i].signal_score=167.44;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=20.75; g_combos[i].p1[3]=42.86;
   g_combos[i].p2[0]=65.22; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=90.91; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.83; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=271.6; g_combos[i].d1[1]=446.6; g_combos[i].d1[2]=146.0; g_combos[i].d1[3]=273.9;
   g_combos[i].d2[0]=444.6; g_combos[i].d2[1]=588.5; g_combos[i].d2[2]=193.1; g_combos[i].d2[3]=273.9;
   g_combos[i].d3[0]=477.0; g_combos[i].d3[1]=570.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=36; g_combos[i].nt[2]=53; g_combos[i].nt[3]=42;
   g_combos[i].nok[0]=23; g_combos[i].nok[1]=8; g_combos[i].nok[2]=11; g_combos[i].nok[3]=18;
   i++;

   // DS4SE | ZD/SELL | n_ang=57 | Full Margin | score=166.1
   g_combos[i].code="DS4SE"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=57; g_combos[i].tier=1; g_combos[i].signal_score=166.10;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=42.31; g_combos[i].p1[1]=23.68; g_combos[i].p1[2]=1.79; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=63.64; g_combos[i].p2[1]=88.89; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=63.64; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=150.9; g_combos[i].d1[1]=205.3; g_combos[i].d1[2]=83.0; g_combos[i].d1[3]=194.6;
   g_combos[i].d2[0]=286.6; g_combos[i].d2[1]=384.5; g_combos[i].d2[2]=766.0; g_combos[i].d2[3]=194.6;
   g_combos[i].d3[0]=306.9; g_combos[i].d3[1]=604.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=52; g_combos[i].nt[1]=38; g_combos[i].nt[2]=56; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=22; g_combos[i].nok[1]=9; g_combos[i].nok[2]=1; g_combos[i].nok[3]=10;
   i++;

   // ES2MO | ZE/SELL | n_ang=58 | Full Margin | score=144.7
   g_combos[i].code="ES2MO"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=58; g_combos[i].tier=1; g_combos[i].signal_score=144.70;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=23.81; g_combos[i].p1[2]=26.67; g_combos[i].p1[3]=36.54;
   g_combos[i].p2[0]=83.33; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=256.1; g_combos[i].d1[1]=403.3; g_combos[i].d1[2]=397.2; g_combos[i].d1[3]=308.9;
   g_combos[i].d2[0]=548.9; g_combos[i].d2[1]=518.1; g_combos[i].d2[2]=579.8; g_combos[i].d2[3]=308.9;
   g_combos[i].d3[0]=577.8; g_combos[i].d3[1]=539.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=45; g_combos[i].nt[1]=42; g_combos[i].nt[2]=45; g_combos[i].nt[3]=52;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=10; g_combos[i].nok[2]=12; g_combos[i].nok[3]=19;
   i++;

   // BS3SG | ZB/SELL | n_ang=56 | Full Margin | score=142.2
   g_combos[i].code="BS3SG"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=56; g_combos[i].tier=1; g_combos[i].signal_score=142.18;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=41.30; g_combos[i].p1[1]=21.88; g_combos[i].p1[2]=16.67; g_combos[i].p1[3]=28.21;
   g_combos[i].p2[0]=68.42; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.11; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=202.5; g_combos[i].d1[1]=447.3; g_combos[i].d1[2]=275.6; g_combos[i].d1[3]=423.0;
   g_combos[i].d2[0]=417.8; g_combos[i].d2[1]=561.0; g_combos[i].d2[2]=305.2; g_combos[i].d2[3]=423.0;
   g_combos[i].d3[0]=478.0; g_combos[i].d3[1]=444.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=32; g_combos[i].nt[2]=54; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=7; g_combos[i].nok[2]=9; g_combos[i].nok[3]=11;
   i++;

   // ES1LF | ZE/SELL | n_ang=69 | Full Margin | score=141.2
   g_combos[i].code="ES1LF"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=69; g_combos[i].tier=1; g_combos[i].signal_score=141.21;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=26.53; g_combos[i].p1[1]=20.45; g_combos[i].p1[2]=27.45; g_combos[i].p1[3]=29.31;
   g_combos[i].p2[0]=84.62; g_combos[i].p2[1]=77.78; g_combos[i].p2[2]=64.29; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.54; g_combos[i].p3[1]=77.78; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=386.2; g_combos[i].d1[1]=325.1; g_combos[i].d1[2]=434.8; g_combos[i].d1[3]=438.9;
   g_combos[i].d2[0]=496.6; g_combos[i].d2[1]=476.9; g_combos[i].d2[2]=433.7; g_combos[i].d2[3]=438.9;
   g_combos[i].d3[0]=515.2; g_combos[i].d3[1]=477.1; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=49; g_combos[i].nt[1]=44; g_combos[i].nt[2]=51; g_combos[i].nt[3]=58;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=9; g_combos[i].nok[2]=14; g_combos[i].nok[3]=17;
   i++;

   // FS4MB | ZF/SELL | n_ang=67 | Full Margin | score=139.2
   g_combos[i].code="FS4MB"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=67; g_combos[i].tier=1; g_combos[i].signal_score=139.15;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=30.91; g_combos[i].p1[1]=19.44; g_combos[i].p1[2]=12.70; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=47.06; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=29.41; g_combos[i].p3[1]=71.43; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=460.6; g_combos[i].d1[1]=416.7; g_combos[i].d1[2]=356.0; g_combos[i].d1[3]=548.6;
   g_combos[i].d2[0]=504.8; g_combos[i].d2[1]=544.0; g_combos[i].d2[2]=379.0; g_combos[i].d2[3]=548.6;
   g_combos[i].d3[0]=505.2; g_combos[i].d3[1]=773.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=55; g_combos[i].nt[1]=36; g_combos[i].nt[2]=63; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=7; g_combos[i].nok[2]=8; g_combos[i].nok[3]=8;
   i++;

   // BS3SD | ZB/SELL | n_ang=52 | Full Margin | score=137.0
   g_combos[i].code="BS3SD"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=52; g_combos[i].tier=1; g_combos[i].signal_score=137.01;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=43.18; g_combos[i].p1[1]=35.14; g_combos[i].p1[2]=14.00; g_combos[i].p1[3]=32.50;
   g_combos[i].p2[0]=63.16; g_combos[i].p2[1]=61.54; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=63.16; g_combos[i].p3[1]=53.85; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=288.3; g_combos[i].d1[1]=369.6; g_combos[i].d1[2]=273.4; g_combos[i].d1[3]=467.0;
   g_combos[i].d2[0]=345.3; g_combos[i].d2[1]=424.2; g_combos[i].d2[2]=340.9; g_combos[i].d2[3]=467.0;
   g_combos[i].d3[0]=414.3; g_combos[i].d3[1]=520.4; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=44; g_combos[i].nt[1]=37; g_combos[i].nt[2]=50; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=13; g_combos[i].nok[2]=7; g_combos[i].nok[3]=13;
   i++;

   // ES1LB | ZE/SELL | n_ang=70 | Full Margin | score=133.9
   g_combos[i].code="ES1LB"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=70; g_combos[i].tier=1; g_combos[i].signal_score=133.87;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=29.63; g_combos[i].p1[1]=32.43; g_combos[i].p1[2]=16.36; g_combos[i].p1[3]=29.09;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=41.67; g_combos[i].p2[2]=55.56; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=25.00; g_combos[i].p3[1]=41.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=400.3; g_combos[i].d1[1]=408.1; g_combos[i].d1[2]=507.6; g_combos[i].d1[3]=449.0;
   g_combos[i].d2[0]=618.6; g_combos[i].d2[1]=581.8; g_combos[i].d2[2]=445.0; g_combos[i].d2[3]=449.0;
   g_combos[i].d3[0]=503.2; g_combos[i].d3[1]=590.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=54; g_combos[i].nt[1]=37; g_combos[i].nt[2]=55; g_combos[i].nt[3]=55;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=12; g_combos[i].nok[2]=9; g_combos[i].nok[3]=16;
   i++;

   // DS2SB | ZD/SELL | n_ang=44 | Strong | score=132.7
   g_combos[i].code="DS2SB"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=44; g_combos[i].tier=2; g_combos[i].signal_score=132.66;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=46.51; g_combos[i].p1[1]=62.96; g_combos[i].p1[2]=22.73; g_combos[i].p1[3]=38.89;
   g_combos[i].p2[0]=85.00; g_combos[i].p2[1]=58.82; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=65.00; g_combos[i].p3[1]=41.18; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=153.7; g_combos[i].d1[1]=465.9; g_combos[i].d1[2]=90.7; g_combos[i].d1[3]=309.9;
   g_combos[i].d2[0]=262.5; g_combos[i].d2[1]=582.0; g_combos[i].d2[2]=203.9; g_combos[i].d2[3]=309.9;
   g_combos[i].d3[0]=366.8; g_combos[i].d3[1]=644.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=43; g_combos[i].nt[1]=27; g_combos[i].nt[2]=44; g_combos[i].nt[3]=36;
   g_combos[i].nok[0]=20; g_combos[i].nok[1]=17; g_combos[i].nok[2]=10; g_combos[i].nok[3]=14;
   i++;

   // FS4SG | ZF/SELL | n_ang=77 | Strong | score=131.6
   g_combos[i].code="FS4SG"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=77; g_combos[i].tier=2; g_combos[i].signal_score=131.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=22.39; g_combos[i].p1[1]=29.27; g_combos[i].p1[2]=2.60; g_combos[i].p1[3]=19.51;
   g_combos[i].p2[0]=53.33; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=53.33; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=284.5; g_combos[i].d1[1]=492.4; g_combos[i].d1[2]=72.0; g_combos[i].d1[3]=373.2;
   g_combos[i].d2[0]=508.5; g_combos[i].d2[1]=616.1; g_combos[i].d2[2]=72.5; g_combos[i].d2[3]=373.2;
   g_combos[i].d3[0]=521.2; g_combos[i].d3[1]=607.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=67; g_combos[i].nt[1]=41; g_combos[i].nt[2]=77; g_combos[i].nt[3]=41;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=12; g_combos[i].nok[2]=2; g_combos[i].nok[3]=8;
   i++;

   // BS2SB | ZB/SELL | n_ang=52 | Strong | score=129.8
   g_combos[i].code="BS2SB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=52; g_combos[i].tier=2; g_combos[i].signal_score=129.80;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=39.13; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=24.00; g_combos[i].p1[3]=43.59;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=42.86; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=210.6; g_combos[i].d1[1]=462.3; g_combos[i].d1[2]=250.0; g_combos[i].d1[3]=430.9;
   g_combos[i].d2[0]=395.4; g_combos[i].d2[1]=630.7; g_combos[i].d2[2]=350.4; g_combos[i].d2[3]=430.9;
   g_combos[i].d3[0]=573.4; g_combos[i].d3[1]=646.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=28; g_combos[i].nt[2]=50; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=7; g_combos[i].nok[2]=12; g_combos[i].nok[3]=17;
   i++;

   // DS4SF | ZD/SELL | n_ang=62 | Strong | score=126.0
   g_combos[i].code="DS4SF"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=62; g_combos[i].tier=2; g_combos[i].signal_score=125.98;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=28.57; g_combos[i].p1[1]=32.56; g_combos[i].p1[2]=0.00; g_combos[i].p1[3]=28.26;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=78.57; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=43.75; g_combos[i].p3[1]=57.14; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=164.5; g_combos[i].d1[1]=274.0; g_combos[i].d1[2]=0.0; g_combos[i].d1[3]=373.8;
   g_combos[i].d2[0]=419.9; g_combos[i].d2[1]=314.2; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=373.8;
   g_combos[i].d3[0]=448.7; g_combos[i].d3[1]=329.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=56; g_combos[i].nt[1]=43; g_combos[i].nt[2]=62; g_combos[i].nt[3]=46;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=14; g_combos[i].nok[2]=0; g_combos[i].nok[3]=13;
   i++;

   // ES1MF | ZE/SELL | n_ang=39 | Strong | score=124.9
   g_combos[i].code="ES1MF"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=39; g_combos[i].tier=2; g_combos[i].signal_score=124.90;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=55.88; g_combos[i].p1[1]=34.78; g_combos[i].p1[2]=31.58; g_combos[i].p1[3]=62.50;
   g_combos[i].p2[0]=68.42; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=47.37; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=302.3; g_combos[i].d1[1]=486.9; g_combos[i].d1[2]=382.8; g_combos[i].d1[3]=326.4;
   g_combos[i].d2[0]=361.2; g_combos[i].d2[1]=494.5; g_combos[i].d2[2]=596.7; g_combos[i].d2[3]=326.4;
   g_combos[i].d3[0]=579.7; g_combos[i].d3[1]=520.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=34; g_combos[i].nt[1]=23; g_combos[i].nt[2]=38; g_combos[i].nt[3]=32;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=8; g_combos[i].nok[2]=12; g_combos[i].nok[3]=20;
   i++;

   // BS3SE | ZB/SELL | n_ang=48 | Strong | score=124.7
   g_combos[i].code="BS3SE"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=48; g_combos[i].tier=2; g_combos[i].signal_score=124.71;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=47.37; g_combos[i].p1[1]=42.42; g_combos[i].p1[2]=11.36; g_combos[i].p1[3]=19.44;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.11; g_combos[i].p3[1]=57.14; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=206.7; g_combos[i].d1[1]=377.6; g_combos[i].d1[2]=198.6; g_combos[i].d1[3]=418.6;
   g_combos[i].d2[0]=360.0; g_combos[i].d2[1]=589.1; g_combos[i].d2[2]=226.2; g_combos[i].d2[3]=418.6;
   g_combos[i].d3[0]=468.8; g_combos[i].d3[1]=559.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=38; g_combos[i].nt[1]=33; g_combos[i].nt[2]=44; g_combos[i].nt[3]=36;
   g_combos[i].nok[0]=18; g_combos[i].nok[1]=14; g_combos[i].nok[2]=5; g_combos[i].nok[3]=7;
   i++;

   // ES2MD | ZE/SELL | n_ang=47 | Strong | score=123.4
   g_combos[i].code="ES2MD"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=47; g_combos[i].tier=2; g_combos[i].signal_score=123.40;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=31.58; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=43.90; g_combos[i].p1[3]=32.43;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=268.8; g_combos[i].d1[1]=423.9; g_combos[i].d1[2]=263.9; g_combos[i].d1[3]=325.8;
   g_combos[i].d2[0]=438.6; g_combos[i].d2[1]=605.9; g_combos[i].d2[2]=382.5; g_combos[i].d2[3]=325.8;
   g_combos[i].d3[0]=537.4; g_combos[i].d3[1]=542.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=38; g_combos[i].nt[1]=30; g_combos[i].nt[2]=41; g_combos[i].nt[3]=37;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=10; g_combos[i].nok[2]=18; g_combos[i].nok[3]=12;
   i++;

   // CS2MO | ZC/SELL | n_ang=38 | Strong | score=123.3
   g_combos[i].code="CS2MO"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=38; g_combos[i].tier=2; g_combos[i].signal_score=123.29;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=34.38; g_combos[i].p1[1]=40.00; g_combos[i].p1[2]=58.82; g_combos[i].p1[3]=40.00;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.45; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.5; g_combos[i].d1[1]=204.9; g_combos[i].d1[2]=319.8; g_combos[i].d1[3]=377.6;
   g_combos[i].d2[0]=401.2; g_combos[i].d2[1]=323.6; g_combos[i].d2[2]=378.3; g_combos[i].d2[3]=377.6;
   g_combos[i].d3[0]=437.2; g_combos[i].d3[1]=457.1; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=25; g_combos[i].nt[2]=34; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=10; g_combos[i].nok[2]=20; g_combos[i].nok[3]=14;
   i++;

   // DS2SF | ZD/SELL | n_ang=40 | Strong | score=120.2
   g_combos[i].code="DS2SF"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=40; g_combos[i].tier=2; g_combos[i].signal_score=120.17;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=51.35; g_combos[i].p1[1]=54.17; g_combos[i].p1[2]=35.00; g_combos[i].p1[3]=56.67;
   g_combos[i].p2[0]=78.95; g_combos[i].p2[1]=61.54; g_combos[i].p2[2]=78.57; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.89; g_combos[i].p3[1]=23.08; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=145.4; g_combos[i].d1[1]=466.1; g_combos[i].d1[2]=195.9; g_combos[i].d1[3]=367.8;
   g_combos[i].d2[0]=405.5; g_combos[i].d2[1]=570.5; g_combos[i].d2[2]=322.8; g_combos[i].d2[3]=367.8;
   g_combos[i].d3[0]=560.8; g_combos[i].d3[1]=408.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=37; g_combos[i].nt[1]=24; g_combos[i].nt[2]=40; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=19; g_combos[i].nok[1]=13; g_combos[i].nok[2]=14; g_combos[i].nok[3]=17;
   i++;

   // HS4SB | ZH/SELL | n_ang=48 | Strong | score=117.8
   g_combos[i].code="HS4SB"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=48; g_combos[i].tier=2; g_combos[i].signal_score=117.78;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=40.48; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=6.38; g_combos[i].p1[3]=25.64;
   g_combos[i].p2[0]=88.24; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=88.24; g_combos[i].p3[1]=84.62; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=111.5; g_combos[i].d1[1]=266.7; g_combos[i].d1[2]=21.7; g_combos[i].d1[3]=245.0;
   g_combos[i].d2[0]=361.6; g_combos[i].d2[1]=313.1; g_combos[i].d2[2]=29.7; g_combos[i].d2[3]=245.0;
   g_combos[i].d3[0]=370.1; g_combos[i].d3[1]=387.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=42; g_combos[i].nt[1]=39; g_combos[i].nt[2]=47; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=17; g_combos[i].nok[1]=13; g_combos[i].nok[2]=3; g_combos[i].nok[3]=10;
   i++;

   // FS4SC | ZF/SELL | n_ang=60 | Strong | score=116.2
   g_combos[i].code="FS4SC"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=60; g_combos[i].tier=2; g_combos[i].signal_score=116.19;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=29.41; g_combos[i].p1[1]=17.39; g_combos[i].p1[2]=5.17; g_combos[i].p1[3]=21.74;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=80.00; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=224.1; g_combos[i].d1[1]=533.2; g_combos[i].d1[2]=441.7; g_combos[i].d1[3]=450.1;
   g_combos[i].d2[0]=490.3; g_combos[i].d2[1]=570.9; g_combos[i].d2[2]=498.0; g_combos[i].d2[3]=450.1;
   g_combos[i].d3[0]=513.2; g_combos[i].d3[1]=663.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=51; g_combos[i].nt[1]=46; g_combos[i].nt[2]=58; g_combos[i].nt[3]=46;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=8; g_combos[i].nok[2]=3; g_combos[i].nok[3]=10;
   i++;

   // FS4SF | ZF/SELL | n_ang=93 | Strong | score=115.7
   g_combos[i].code="FS4SF"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=93; g_combos[i].tier=2; g_combos[i].signal_score=115.72;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=15.79; g_combos[i].p1[1]=14.75; g_combos[i].p1[2]=7.61; g_combos[i].p1[3]=17.74;
   g_combos[i].p2[0]=58.33; g_combos[i].p2[1]=77.78; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=314.8; g_combos[i].d1[1]=607.7; g_combos[i].d1[2]=277.1; g_combos[i].d1[3]=492.6;
   g_combos[i].d2[0]=577.3; g_combos[i].d2[1]=577.7; g_combos[i].d2[2]=282.6; g_combos[i].d2[3]=492.6;
   g_combos[i].d3[0]=550.5; g_combos[i].d3[1]=246.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=76; g_combos[i].nt[1]=61; g_combos[i].nt[2]=92; g_combos[i].nt[3]=62;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=9; g_combos[i].nok[2]=7; g_combos[i].nok[3]=11;
   i++;

   // CS1LF | ZC/SELL | n_ang=56 | Strong | score=112.2
   g_combos[i].code="CS1LF"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=56; g_combos[i].tier=2; g_combos[i].signal_score=112.25;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=32.43; g_combos[i].p1[2]=21.95; g_combos[i].p1[3]=21.74;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=58.33; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=58.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=306.1; g_combos[i].d1[1]=550.8; g_combos[i].d1[2]=352.4; g_combos[i].d1[3]=375.8;
   g_combos[i].d2[0]=385.0; g_combos[i].d2[1]=700.0; g_combos[i].d2[2]=512.7; g_combos[i].d2[3]=375.8;
   g_combos[i].d3[0]=552.0; g_combos[i].d3[1]=710.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=40; g_combos[i].nt[1]=37; g_combos[i].nt[2]=41; g_combos[i].nt[3]=46;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=12; g_combos[i].nok[2]=9; g_combos[i].nok[3]=10;
   i++;

   // DS4SD | ZD/SELL | n_ang=46 | Strong | score=108.5
   g_combos[i].code="DS4SD"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=46; g_combos[i].tier=2; g_combos[i].signal_score=108.52;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=35.48; g_combos[i].p1[2]=4.35; g_combos[i].p1[3]=45.45;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=81.82; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=36.36; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=158.9; g_combos[i].d1[1]=477.8; g_combos[i].d1[2]=104.5; g_combos[i].d1[3]=297.6;
   g_combos[i].d2[0]=233.8; g_combos[i].d2[1]=599.2; g_combos[i].d2[2]=114.5; g_combos[i].d2[3]=297.6;
   g_combos[i].d3[0]=321.4; g_combos[i].d3[1]=469.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=40; g_combos[i].nt[1]=31; g_combos[i].nt[2]=46; g_combos[i].nt[3]=33;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=11; g_combos[i].nok[2]=2; g_combos[i].nok[3]=15;
   i++;

   // HS4SO | ZH/SELL | n_ang=48 | Strong | score=103.9
   g_combos[i].code="HS4SO"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=48; g_combos[i].tier=2; g_combos[i].signal_score=103.92;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.71; g_combos[i].p1[1]=31.03; g_combos[i].p1[2]=6.25; g_combos[i].p1[3]=32.26;
   g_combos[i].p2[0]=40.00; g_combos[i].p2[1]=88.89; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=122.7; g_combos[i].d1[1]=229.0; g_combos[i].d1[2]=61.7; g_combos[i].d1[3]=154.0;
   g_combos[i].d2[0]=238.5; g_combos[i].d2[1]=206.9; g_combos[i].d2[2]=162.7; g_combos[i].d2[3]=154.0;
   g_combos[i].d3[0]=239.3; g_combos[i].d3[1]=450.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=42; g_combos[i].nt[1]=29; g_combos[i].nt[2]=48; g_combos[i].nt[3]=31;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=9; g_combos[i].nok[2]=3; g_combos[i].nok[3]=10;
   i++;

   // HS4SE | ZH/SELL | n_ang=47 | Strong | score=102.8
   g_combos[i].code="HS4SE"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=47; g_combos[i].tier=2; g_combos[i].signal_score=102.83;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=34.15; g_combos[i].p1[1]=39.47; g_combos[i].p1[2]=2.13; g_combos[i].p1[3]=22.50;
   g_combos[i].p2[0]=85.71; g_combos[i].p2[1]=86.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=85.71; g_combos[i].p3[1]=86.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=198.7; g_combos[i].d1[1]=145.1; g_combos[i].d1[2]=11.0; g_combos[i].d1[3]=350.4;
   g_combos[i].d2[0]=302.7; g_combos[i].d2[1]=177.9; g_combos[i].d2[2]=14.0; g_combos[i].d2[3]=350.4;
   g_combos[i].d3[0]=304.8; g_combos[i].d3[1]=302.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=41; g_combos[i].nt[1]=38; g_combos[i].nt[2]=47; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=15; g_combos[i].nok[2]=1; g_combos[i].nok[3]=9;
   i++;

   // BS4SC | ZB/SELL | n_ang=39 | Strong | score=99.9
   g_combos[i].code="BS4SC"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=39; g_combos[i].tier=2; g_combos[i].signal_score=99.92;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=45.71; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=5.13; g_combos[i].p1[3]=41.38;
   g_combos[i].p2[0]=68.75; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=37.50; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.0; g_combos[i].d1[1]=376.0; g_combos[i].d1[2]=85.5; g_combos[i].d1[3]=315.8;
   g_combos[i].d2[0]=439.0; g_combos[i].d2[1]=296.8; g_combos[i].d2[2]=88.5; g_combos[i].d2[3]=315.8;
   g_combos[i].d3[0]=387.3; g_combos[i].d3[1]=396.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=22; g_combos[i].nt[2]=39; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=16; g_combos[i].nok[1]=8; g_combos[i].nok[2]=2; g_combos[i].nok[3]=12;
   i++;

   // ES2ME | ZE/SELL | n_ang=44 | Strong | score=99.5
   g_combos[i].code="ES2ME"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=44; g_combos[i].tier=2; g_combos[i].signal_score=99.50;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=44.12; g_combos[i].p1[1]=39.29; g_combos[i].p1[2]=27.03; g_combos[i].p1[3]=18.92;
   g_combos[i].p2[0]=73.33; g_combos[i].p2[1]=54.55; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=45.45; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=329.3; g_combos[i].d1[1]=371.4; g_combos[i].d1[2]=352.3; g_combos[i].d1[3]=376.7;
   g_combos[i].d2[0]=367.2; g_combos[i].d2[1]=382.0; g_combos[i].d2[2]=399.2; g_combos[i].d2[3]=376.7;
   g_combos[i].d3[0]=401.7; g_combos[i].d3[1]=387.6; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=34; g_combos[i].nt[1]=28; g_combos[i].nt[2]=37; g_combos[i].nt[3]=37;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=11; g_combos[i].nok[2]=10; g_combos[i].nok[3]=7;
   i++;

   // FS4MO | ZF/SELL | n_ang=62 | Strong | score=94.5
   g_combos[i].code="FS4MO"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=62; g_combos[i].tier=2; g_combos[i].signal_score=94.49;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=8.89; g_combos[i].p1[1]=30.00; g_combos[i].p1[2]=15.09; g_combos[i].p1[3]=15.00;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=190.0; g_combos[i].d1[1]=394.4; g_combos[i].d1[2]=382.2; g_combos[i].d1[3]=694.8;
   g_combos[i].d2[0]=371.5; g_combos[i].d2[1]=564.9; g_combos[i].d2[2]=385.4; g_combos[i].d2[3]=694.8;
   g_combos[i].d3[0]=375.0; g_combos[i].d3[1]=620.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=45; g_combos[i].nt[1]=40; g_combos[i].nt[2]=53; g_combos[i].nt[3]=40;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=12; g_combos[i].nok[2]=8; g_combos[i].nok[3]=6;
   i++;

   // BS2MO | ZB/SELL | n_ang=39 | Strong | score=93.7
   g_combos[i].code="BS2MO"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=39; g_combos[i].tier=2; g_combos[i].signal_score=93.67;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=44.12; g_combos[i].p1[1]=30.43; g_combos[i].p1[2]=14.71; g_combos[i].p1[3]=25.93;
   g_combos[i].p2[0]=86.67; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=57.14; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=177.8; g_combos[i].d1[1]=390.3; g_combos[i].d1[2]=628.6; g_combos[i].d1[3]=382.6;
   g_combos[i].d2[0]=405.4; g_combos[i].d2[1]=516.8; g_combos[i].d2[2]=624.0; g_combos[i].d2[3]=382.6;
   g_combos[i].d3[0]=451.3; g_combos[i].d3[1]=562.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=34; g_combos[i].nt[1]=23; g_combos[i].nt[2]=34; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=15; g_combos[i].nok[1]=7; g_combos[i].nok[2]=5; g_combos[i].nok[3]=7;
   i++;

   // ES2LB | ZE/SELL | n_ang=72 | Strong | score=93.3
   g_combos[i].code="ES2LB"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=72; g_combos[i].tier=2; g_combos[i].signal_score=93.34;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=23.91; g_combos[i].p1[1]=19.57; g_combos[i].p1[2]=18.75; g_combos[i].p1[3]=15.79;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=44.44; g_combos[i].p2[2]=88.89; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=54.55; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=380.6; g_combos[i].d1[1]=392.3; g_combos[i].d1[2]=289.0; g_combos[i].d1[3]=493.0;
   g_combos[i].d2[0]=423.6; g_combos[i].d2[1]=676.8; g_combos[i].d2[2]=354.5; g_combos[i].d2[3]=493.0;
   g_combos[i].d3[0]=406.0; g_combos[i].d3[1]=585.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=46; g_combos[i].nt[1]=46; g_combos[i].nt[2]=48; g_combos[i].nt[3]=57;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=9; g_combos[i].nok[2]=9; g_combos[i].nok[3]=9;
   i++;

   // ES2LF | ZE/SELL | n_ang=59 | Strong | score=92.2
   g_combos[i].code="ES2LF"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=59; g_combos[i].tier=2; g_combos[i].signal_score=92.17;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=27.91; g_combos[i].p1[1]=15.79; g_combos[i].p1[2]=15.91; g_combos[i].p1[3]=15.91;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=57.14; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=368.6; g_combos[i].d1[1]=402.3; g_combos[i].d1[2]=413.6; g_combos[i].d1[3]=482.4;
   g_combos[i].d2[0]=457.9; g_combos[i].d2[1]=578.8; g_combos[i].d2[2]=345.5; g_combos[i].d2[3]=482.4;
   g_combos[i].d3[0]=491.8; g_combos[i].d3[1]=586.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=43; g_combos[i].nt[1]=38; g_combos[i].nt[2]=44; g_combos[i].nt[3]=44;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=6; g_combos[i].nok[2]=7; g_combos[i].nok[3]=7;
   i++;

   // ES2LO | ZE/SELL | n_ang=42 | Strong | score=90.7
   g_combos[i].code="ES2LO"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=42; g_combos[i].tier=2; g_combos[i].signal_score=90.73;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=42.42; g_combos[i].p1[1]=31.43; g_combos[i].p1[2]=41.18; g_combos[i].p1[3]=13.16;
   g_combos[i].p2[0]=78.57; g_combos[i].p2[1]=27.27; g_combos[i].p2[2]=92.86; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=27.27; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=367.8; g_combos[i].d1[1]=461.0; g_combos[i].d1[2]=505.1; g_combos[i].d1[3]=574.4;
   g_combos[i].d2[0]=431.1; g_combos[i].d2[1]=458.7; g_combos[i].d2[2]=581.8; g_combos[i].d2[3]=574.4;
   g_combos[i].d3[0]=459.8; g_combos[i].d3[1]=458.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=33; g_combos[i].nt[1]=35; g_combos[i].nt[2]=34; g_combos[i].nt[3]=38;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=11; g_combos[i].nok[2]=14; g_combos[i].nok[3]=5;
   i++;

   // DS2MB | ZD/SELL | n_ang=41 | Strong | score=89.6
   g_combos[i].code="DS2MB"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=41; g_combos[i].tier=2; g_combos[i].signal_score=89.64;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=45.16; g_combos[i].p1[1]=43.75; g_combos[i].p1[2]=32.43; g_combos[i].p1[3]=34.21;
   g_combos[i].p2[0]=85.71; g_combos[i].p2[1]=64.29; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=315.1; g_combos[i].d1[1]=424.8; g_combos[i].d1[2]=265.8; g_combos[i].d1[3]=513.2;
   g_combos[i].d2[0]=375.8; g_combos[i].d2[1]=578.1; g_combos[i].d2[2]=318.5; g_combos[i].d2[3]=513.2;
   g_combos[i].d3[0]=443.3; g_combos[i].d3[1]=606.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=32; g_combos[i].nt[2]=37; g_combos[i].nt[3]=38;
   g_combos[i].nok[0]=14; g_combos[i].nok[1]=14; g_combos[i].nok[2]=12; g_combos[i].nok[3]=13;
   i++;

   // ES2MG | ZE/SELL | n_ang=38 | Strong | score=86.3
   g_combos[i].code="ES2MG"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=38; g_combos[i].tier=2; g_combos[i].signal_score=86.30;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=42.42; g_combos[i].p1[2]=23.33; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=85.71; g_combos[i].p3[1]=78.57; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=250.0; g_combos[i].d1[1]=322.1; g_combos[i].d1[2]=244.9; g_combos[i].d1[3]=376.9;
   g_combos[i].d2[0]=370.3; g_combos[i].d2[1]=354.0; g_combos[i].d2[2]=218.5; g_combos[i].d2[3]=376.9;
   g_combos[i].d3[0]=330.7; g_combos[i].d3[1]=416.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=28; g_combos[i].nt[1]=33; g_combos[i].nt[2]=30; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=14; g_combos[i].nok[2]=7; g_combos[i].nok[3]=7;
   i++;

   // CS2MF | ZC/SELL | n_ang=42 | Strong | score=84.2
   g_combos[i].code="CS2MF"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=42; g_combos[i].tier=2; g_combos[i].signal_score=84.25;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=46.43; g_combos[i].p1[1]=31.43; g_combos[i].p1[2]=24.24; g_combos[i].p1[3]=25.64;
   g_combos[i].p2[0]=69.23; g_combos[i].p2[1]=72.73; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=61.54; g_combos[i].p3[1]=63.64; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=484.8; g_combos[i].d1[1]=343.3; g_combos[i].d1[2]=442.1; g_combos[i].d1[3]=423.9;
   g_combos[i].d2[0]=537.3; g_combos[i].d2[1]=492.0; g_combos[i].d2[2]=490.3; g_combos[i].d2[3]=423.9;
   g_combos[i].d3[0]=566.9; g_combos[i].d3[1]=510.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=28; g_combos[i].nt[1]=35; g_combos[i].nt[2]=33; g_combos[i].nt[3]=39;
   g_combos[i].nok[0]=13; g_combos[i].nok[1]=11; g_combos[i].nok[2]=8; g_combos[i].nok[3]=10;
   i++;

   // BS4SH | ZB/SELL | n_ang=41 | Strong | score=83.2
   g_combos[i].code="BS4SH"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=41; g_combos[i].tier=2; g_combos[i].signal_score=83.24;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=34.38; g_combos[i].p1[1]=54.17; g_combos[i].p1[2]=2.44; g_combos[i].p1[3]=48.15;
   g_combos[i].p2[0]=36.36; g_combos[i].p2[1]=84.62; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=36.36; g_combos[i].p3[1]=46.15; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=318.7; g_combos[i].d1[1]=318.8; g_combos[i].d1[2]=423.0; g_combos[i].d1[3]=170.3;
   g_combos[i].d2[0]=564.5; g_combos[i].d2[1]=417.7; g_combos[i].d2[2]=423.0; g_combos[i].d2[3]=170.3;
   g_combos[i].d3[0]=661.5; g_combos[i].d3[1]=535.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=24; g_combos[i].nt[2]=41; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=13; g_combos[i].nok[2]=1; g_combos[i].nok[3]=13;
   i++;

   // DS2MF | ZD/SELL | n_ang=45 | Good | score=80.5
   g_combos[i].code="DS2MF"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=45; g_combos[i].tier=3; g_combos[i].signal_score=80.50;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=32.43; g_combos[i].p1[1]=34.62; g_combos[i].p1[2]=19.51; g_combos[i].p1[3]=18.18;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=55.56; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.33; g_combos[i].p3[1]=55.56; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=227.2; g_combos[i].d1[1]=374.1; g_combos[i].d1[2]=246.1; g_combos[i].d1[3]=173.2;
   g_combos[i].d2[0]=251.2; g_combos[i].d2[1]=453.0; g_combos[i].d2[2]=287.3; g_combos[i].d2[3]=173.2;
   g_combos[i].d3[0]=323.6; g_combos[i].d3[1]=502.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=37; g_combos[i].nt[1]=26; g_combos[i].nt[2]=41; g_combos[i].nt[3]=33;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=9; g_combos[i].nok[2]=8; g_combos[i].nok[3]=6;
   i++;

   // DS3SD | ZD/SELL | n_ang=31 | Good | score=78.0
   g_combos[i].code="DS3SD"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=31; g_combos[i].tier=3; g_combos[i].signal_score=77.95;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=46.15; g_combos[i].p1[1]=66.67; g_combos[i].p1[2]=3.23; g_combos[i].p1[3]=43.48;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=71.43; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.33; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=205.9; g_combos[i].d1[1]=411.4; g_combos[i].d1[2]=172.0; g_combos[i].d1[3]=411.0;
   g_combos[i].d2[0]=358.9; g_combos[i].d2[1]=547.7; g_combos[i].d2[2]=328.0; g_combos[i].d2[3]=411.0;
   g_combos[i].d3[0]=498.6; g_combos[i].d3[1]=556.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=26; g_combos[i].nt[1]=21; g_combos[i].nt[2]=31; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=14; g_combos[i].nok[2]=1; g_combos[i].nok[3]=10;
   i++;

   // FS4SD | ZF/SELL | n_ang=60 | Good | score=77.5
   g_combos[i].code="FS4SD"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=60; g_combos[i].tier=3; g_combos[i].signal_score=77.46;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=18.87; g_combos[i].p1[1]=27.78; g_combos[i].p1[2]=10.17; g_combos[i].p1[3]=8.11;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=70.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=307.6; g_combos[i].d1[1]=458.1; g_combos[i].d1[2]=149.7; g_combos[i].d1[3]=381.0;
   g_combos[i].d2[0]=485.7; g_combos[i].d2[1]=509.0; g_combos[i].d2[2]=186.7; g_combos[i].d2[3]=381.0;
   g_combos[i].d3[0]=472.6; g_combos[i].d3[1]=483.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=53; g_combos[i].nt[1]=36; g_combos[i].nt[2]=59; g_combos[i].nt[3]=37;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=10; g_combos[i].nok[2]=6; g_combos[i].nok[3]=3;
   i++;

   // DS3SF | ZD/SELL | n_ang=40 | Good | score=75.9
   g_combos[i].code="DS3SF"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=40; g_combos[i].tier=3; g_combos[i].signal_score=75.89;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=36.36; g_combos[i].p1[1]=36.00; g_combos[i].p1[2]=12.50; g_combos[i].p1[3]=37.93;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=55.56; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=58.33; g_combos[i].p3[1]=55.56; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=112.4; g_combos[i].d1[1]=412.3; g_combos[i].d1[2]=257.6; g_combos[i].d1[3]=352.2;
   g_combos[i].d2[0]=226.4; g_combos[i].d2[1]=406.2; g_combos[i].d2[2]=323.2; g_combos[i].d2[3]=352.2;
   g_combos[i].d3[0]=255.1; g_combos[i].d3[1]=639.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=33; g_combos[i].nt[1]=25; g_combos[i].nt[2]=40; g_combos[i].nt[3]=29;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=9; g_combos[i].nok[2]=5; g_combos[i].nok[3]=11;
   i++;

   // ES1LO | ZE/SELL | n_ang=47 | Good | score=75.4
   g_combos[i].code="ES1LO"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=47; g_combos[i].tier=3; g_combos[i].signal_score=75.41;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=39.29; g_combos[i].p1[1]=31.25; g_combos[i].p1[2]=25.81; g_combos[i].p1[3]=14.63;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=30.00; g_combos[i].p2[2]=37.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=36.36; g_combos[i].p3[1]=20.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=238.5; g_combos[i].d1[1]=438.9; g_combos[i].d1[2]=275.1; g_combos[i].d1[3]=143.2;
   g_combos[i].d2[0]=258.9; g_combos[i].d2[1]=542.0; g_combos[i].d2[2]=394.3; g_combos[i].d2[3]=143.2;
   g_combos[i].d3[0]=460.2; g_combos[i].d3[1]=425.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=28; g_combos[i].nt[1]=32; g_combos[i].nt[2]=31; g_combos[i].nt[3]=41;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=10; g_combos[i].nok[2]=8; g_combos[i].nok[3]=6;
   i++;

   // BS2MD | ZB/SELL | n_ang=44 | Good | score=73.0
   g_combos[i].code="BS2MD"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=44; g_combos[i].tier=3; g_combos[i].signal_score=72.97;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=34.38; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=25.71; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=88.89; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=63.64; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=342.9; g_combos[i].d1[1]=351.0; g_combos[i].d1[2]=132.1; g_combos[i].d1[3]=262.4;
   g_combos[i].d2[0]=307.2; g_combos[i].d2[1]=355.5; g_combos[i].d2[2]=160.2; g_combos[i].d2[3]=262.4;
   g_combos[i].d3[0]=309.9; g_combos[i].d3[1]=437.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=30; g_combos[i].nt[2]=35; g_combos[i].nt[3]=36;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=6; g_combos[i].nok[2]=9; g_combos[i].nok[3]=9;
   i++;

   // CS2MB | ZC/SELL | n_ang=36 | Good | score=72.0
   g_combos[i].code="CS2MB"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=36; g_combos[i].tier=3; g_combos[i].signal_score=72.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=46.15; g_combos[i].p1[1]=27.27; g_combos[i].p1[2]=37.50; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=58.33; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=370.1; g_combos[i].d1[1]=391.7; g_combos[i].d1[2]=247.2; g_combos[i].d1[3]=239.4;
   g_combos[i].d2[0]=467.1; g_combos[i].d2[1]=433.0; g_combos[i].d2[2]=350.4; g_combos[i].d2[3]=239.4;
   g_combos[i].d3[0]=422.0; g_combos[i].d3[1]=315.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=26; g_combos[i].nt[1]=22; g_combos[i].nt[2]=32; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=6; g_combos[i].nok[2]=12; g_combos[i].nok[3]=8;
   i++;

   // ES2LE | ZE/SELL | n_ang=42 | Good | score=71.3
   g_combos[i].code="ES2LE"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=42; g_combos[i].tier=3; g_combos[i].signal_score=71.29;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=20.00; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=31.43; g_combos[i].p1[3]=12.12;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=63.64; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=346.3; g_combos[i].d1[1]=266.4; g_combos[i].d1[2]=539.9; g_combos[i].d1[3]=485.0;
   g_combos[i].d2[0]=529.4; g_combos[i].d2[1]=389.1; g_combos[i].d2[2]=394.0; g_combos[i].d2[3]=485.0;
   g_combos[i].d3[0]=318.0; g_combos[i].d3[1]=391.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=35; g_combos[i].nt[1]=30; g_combos[i].nt[2]=35; g_combos[i].nt[3]=33;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=10; g_combos[i].nok[2]=11; g_combos[i].nok[3]=4;
   i++;

   // BS2MG | ZB/SELL | n_ang=38 | Good | score=67.8
   g_combos[i].code="BS2MG"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=38; g_combos[i].tier=3; g_combos[i].signal_score=67.81;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=16.13; g_combos[i].p1[1]=36.84; g_combos[i].p1[2]=29.73; g_combos[i].p1[3]=25.00;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=90.91; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=57.14; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=173.8; g_combos[i].d1[1]=311.1; g_combos[i].d1[2]=197.5; g_combos[i].d1[3]=469.3;
   g_combos[i].d2[0]=466.7; g_combos[i].d2[1]=490.0; g_combos[i].d2[2]=175.4; g_combos[i].d2[3]=469.3;
   g_combos[i].d3[0]=293.0; g_combos[i].d3[1]=588.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=19; g_combos[i].nt[2]=37; g_combos[i].nt[3]=24;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=7; g_combos[i].nok[2]=11; g_combos[i].nok[3]=6;
   i++;

   // DS2MO | ZD/SELL | n_ang=38 | Good | score=67.8
   g_combos[i].code="DS2MO"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=38; g_combos[i].tier=3; g_combos[i].signal_score=67.81;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=6.25; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=27.03; g_combos[i].p1[3]=42.31;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=70.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=170.0; g_combos[i].d1[1]=473.2; g_combos[i].d1[2]=311.5; g_combos[i].d1[3]=340.4;
   g_combos[i].d2[0]=278.0; g_combos[i].d2[1]=439.2; g_combos[i].d2[2]=438.6; g_combos[i].d2[3]=340.4;
   g_combos[i].d3[0]=316.5; g_combos[i].d3[1]=388.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=32; g_combos[i].nt[1]=21; g_combos[i].nt[2]=37; g_combos[i].nt[3]=26;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=6; g_combos[i].nok[2]=10; g_combos[i].nok[3]=11;
   i++;

   // CS1LB | ZC/SELL | n_ang=45 | Good | score=67.1
   g_combos[i].code="CS1LB"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=45; g_combos[i].tier=3; g_combos[i].signal_score=67.08;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.30; g_combos[i].p1[1]=21.43; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=14.29;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=90.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=442.7; g_combos[i].d1[1]=268.7; g_combos[i].d1[2]=532.7; g_combos[i].d1[3]=332.4;
   g_combos[i].d2[0]=542.3; g_combos[i].d2[1]=310.0; g_combos[i].d2[2]=641.9; g_combos[i].d2[3]=332.4;
   g_combos[i].d3[0]=616.8; g_combos[i].d3[1]=319.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=33; g_combos[i].nt[1]=28; g_combos[i].nt[2]=35; g_combos[i].nt[3]=35;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=6; g_combos[i].nok[2]=10; g_combos[i].nok[3]=5;
   i++;

   // DS2ME | ZD/SELL | n_ang=28 | Good | score=63.5
   g_combos[i].code="DS2ME"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=28; g_combos[i].tier=3; g_combos[i].signal_score=63.50;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=52.17; g_combos[i].p1[2]=22.22; g_combos[i].p1[3]=24.00;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=91.67; g_combos[i].p2[2]=83.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=115.4; g_combos[i].d1[1]=320.0; g_combos[i].d1[2]=250.7; g_combos[i].d1[3]=200.7;
   g_combos[i].d2[0]=262.5; g_combos[i].d2[1]=471.1; g_combos[i].d2[2]=309.8; g_combos[i].d2[3]=200.7;
   g_combos[i].d3[0]=256.9; g_combos[i].d3[1]=428.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=23; g_combos[i].nt[2]=27; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=12; g_combos[i].nok[2]=6; g_combos[i].nok[3]=6;
   i++;

   // CS1MB | ZC/SELL | n_ang=22 | Good | score=61.0
   g_combos[i].code="CS1MB"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=22; g_combos[i].tier=3; g_combos[i].signal_score=60.98;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=38.89; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=42.11; g_combos[i].p1[3]=61.90;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=237.0; g_combos[i].d1[1]=386.7; g_combos[i].d1[2]=225.7; g_combos[i].d1[3]=393.3;
   g_combos[i].d2[0]=313.0; g_combos[i].d2[1]=591.0; g_combos[i].d2[2]=294.5; g_combos[i].d2[3]=393.3;
   g_combos[i].d3[0]=338.7; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=18; g_combos[i].nt[1]=12; g_combos[i].nt[2]=19; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=3; g_combos[i].nok[2]=8; g_combos[i].nok[3]=13;
   i++;

   // DS3SO | ZD/SELL | n_ang=34 | Good | score=58.3
   g_combos[i].code="DS3SO"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=58.31;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=37.04; g_combos[i].p1[1]=15.79; g_combos[i].p1[2]=9.09; g_combos[i].p1[3]=26.09;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=133.7; g_combos[i].d1[1]=320.0; g_combos[i].d1[2]=215.7; g_combos[i].d1[3]=194.3;
   g_combos[i].d2[0]=288.7; g_combos[i].d2[1]=556.0; g_combos[i].d2[2]=270.3; g_combos[i].d2[3]=194.3;
   g_combos[i].d3[0]=387.0; g_combos[i].d3[1]=644.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=19; g_combos[i].nt[2]=33; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=3; g_combos[i].nok[2]=3; g_combos[i].nok[3]=6;
   i++;

   // DS4SG | ZD/SELL | n_ang=33 | Good | score=57.5
   g_combos[i].code="DS4SG"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=33; g_combos[i].tier=3; g_combos[i].signal_score=57.45;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=32.14; g_combos[i].p1[1]=37.04; g_combos[i].p1[2]=6.06; g_combos[i].p1[3]=29.63;
   g_combos[i].p2[0]=55.56; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=262.4; g_combos[i].d1[1]=138.1; g_combos[i].d1[2]=47.5; g_combos[i].d1[3]=219.5;
   g_combos[i].d2[0]=249.0; g_combos[i].d2[1]=171.5; g_combos[i].d2[2]=121.0; g_combos[i].d2[3]=219.5;
   g_combos[i].d3[0]=190.8; g_combos[i].d3[1]=327.1; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=28; g_combos[i].nt[1]=27; g_combos[i].nt[2]=33; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=10; g_combos[i].nok[2]=2; g_combos[i].nok[3]=8;
   i++;

   // FS4ME | ZF/SELL | n_ang=48 | Good | score=55.4
   g_combos[i].code="FS4ME"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=48; g_combos[i].tier=3; g_combos[i].signal_score=55.43;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=14.63; g_combos[i].p1[1]=15.38; g_combos[i].p1[2]=17.78; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=87.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=363.2; g_combos[i].d1[1]=500.0; g_combos[i].d1[2]=154.2; g_combos[i].d1[3]=381.0;
   g_combos[i].d2[0]=464.2; g_combos[i].d2[1]=649.2; g_combos[i].d2[2]=158.9; g_combos[i].d2[3]=381.0;
   g_combos[i].d3[0]=476.5; g_combos[i].d3[1]=733.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=41; g_combos[i].nt[1]=26; g_combos[i].nt[2]=45; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=4; g_combos[i].nok[2]=8; g_combos[i].nok[3]=3;
   i++;

   // BS2SO | ZB/SELL | n_ang=25 | Good | score=55.0
   g_combos[i].code="BS2SO"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=25; g_combos[i].tier=3; g_combos[i].signal_score=55.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=52.38; g_combos[i].p1[1]=53.85; g_combos[i].p1[2]=44.00; g_combos[i].p1[3]=36.84;
   g_combos[i].p2[0]=72.73; g_combos[i].p2[1]=85.71; g_combos[i].p2[2]=72.73; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=27.27; g_combos[i].p3[1]=71.43; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=218.6; g_combos[i].d1[1]=486.7; g_combos[i].d1[2]=135.8; g_combos[i].d1[3]=288.4;
   g_combos[i].d2[0]=399.6; g_combos[i].d2[1]=473.8; g_combos[i].d2[2]=254.0; g_combos[i].d2[3]=288.4;
   g_combos[i].d3[0]=643.0; g_combos[i].d3[1]=586.6; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=21; g_combos[i].nt[1]=13; g_combos[i].nt[2]=25; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=7; g_combos[i].nok[2]=11; g_combos[i].nok[3]=7;
   i++;

   // CS2LF | ZC/SELL | n_ang=24 | Good | score=53.9
   g_combos[i].code="CS2LF"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=24; g_combos[i].tier=3; g_combos[i].signal_score=53.89;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=29.41; g_combos[i].p1[1]=68.75; g_combos[i].p1[2]=10.53; g_combos[i].p1[3]=5.00;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=54.55; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=20.00; g_combos[i].p3[1]=54.55; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=270.4; g_combos[i].d1[1]=609.0; g_combos[i].d1[2]=365.0; g_combos[i].d1[3]=525.0;
   g_combos[i].d2[0]=443.3; g_combos[i].d2[1]=775.2; g_combos[i].d2[2]=205.0; g_combos[i].d2[3]=525.0;
   g_combos[i].d3[0]=816.0; g_combos[i].d3[1]=786.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=16; g_combos[i].nt[2]=19; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=11; g_combos[i].nok[2]=2; g_combos[i].nok[3]=1;
   i++;

   // ES1MB | ZE/SELL | n_ang=29 | Good | score=53.9
   g_combos[i].code="ES1MB"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=29; g_combos[i].tier=3; g_combos[i].signal_score=53.85;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=38.46; g_combos[i].p1[1]=12.50; g_combos[i].p1[2]=25.93; g_combos[i].p1[3]=43.48;
   g_combos[i].p2[0]=70.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=250.0; g_combos[i].d1[1]=319.0; g_combos[i].d1[2]=399.0; g_combos[i].d1[3]=384.3;
   g_combos[i].d2[0]=397.9; g_combos[i].d2[1]=844.0; g_combos[i].d2[2]=537.2; g_combos[i].d2[3]=384.3;
   g_combos[i].d3[0]=565.3; g_combos[i].d3[1]=858.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=26; g_combos[i].nt[1]=16; g_combos[i].nt[2]=27; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=2; g_combos[i].nok[2]=7; g_combos[i].nok[3]=10;
   i++;

   // FS4MG | ZF/SELL | n_ang=34 | Good | score=52.5
   g_combos[i].code="FS4MG"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=34; g_combos[i].tier=3; g_combos[i].signal_score=52.48;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=32.00; g_combos[i].p1[1]=4.55; g_combos[i].p1[2]=28.12; g_combos[i].p1[3]=8.70;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=229.5; g_combos[i].d1[1]=541.0; g_combos[i].d1[2]=287.2; g_combos[i].d1[3]=415.5;
   g_combos[i].d2[0]=362.0; g_combos[i].d2[1]=547.0; g_combos[i].d2[2]=306.0; g_combos[i].d2[3]=415.5;
   g_combos[i].d3[0]=363.0; g_combos[i].d3[1]=567.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=25; g_combos[i].nt[1]=22; g_combos[i].nt[2]=32; g_combos[i].nt[3]=23;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=1; g_combos[i].nok[2]=9; g_combos[i].nok[3]=2;
   i++;

   // BS2SD | ZB/SELL | n_ang=27 | Good | score=52.0
   g_combos[i].code="BS2SD"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=27; g_combos[i].tier=3; g_combos[i].signal_score=51.96;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=41.67; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=26.92; g_combos[i].p1[3]=31.82;
   g_combos[i].p2[0]=90.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=70.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=182.0; g_combos[i].d1[1]=671.0; g_combos[i].d1[2]=210.7; g_combos[i].d1[3]=348.0;
   g_combos[i].d2[0]=396.3; g_combos[i].d2[1]=719.0; g_combos[i].d2[2]=389.0; g_combos[i].d2[3]=348.0;
   g_combos[i].d3[0]=557.6; g_combos[i].d3[1]=799.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=18; g_combos[i].nt[2]=26; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=10; g_combos[i].nok[1]=4; g_combos[i].nok[2]=7; g_combos[i].nok[3]=7;
   i++;

   // DS1MF | ZD/SELL | n_ang=18 | Good | score=50.9
   g_combos[i].code="DS1MF"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=18; g_combos[i].tier=3; g_combos[i].signal_score=50.91;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=70.59; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=18.75;
   g_combos[i].p2[0]=91.67; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=241.8; g_combos[i].d1[1]=331.8; g_combos[i].d1[2]=222.0; g_combos[i].d1[3]=189.3;
   g_combos[i].d2[0]=293.3; g_combos[i].d2[1]=374.0; g_combos[i].d2[2]=409.0; g_combos[i].d2[3]=189.3;
   g_combos[i].d3[0]=437.9; g_combos[i].d3[1]=377.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=14; g_combos[i].nt[2]=18; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=12; g_combos[i].nok[1]=4; g_combos[i].nok[2]=6; g_combos[i].nok[3]=3;
   i++;

   // FS4MF | ZF/SELL | n_ang=40 | Good | score=50.6
   g_combos[i].code="FS4MF"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=40; g_combos[i].tier=3; g_combos[i].signal_score=50.60;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=6.67; g_combos[i].p1[1]=29.63; g_combos[i].p1[2]=13.89; g_combos[i].p1[3]=14.81;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=62.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=296.5; g_combos[i].d1[1]=362.2; g_combos[i].d1[2]=280.0; g_combos[i].d1[3]=247.2;
   g_combos[i].d2[0]=618.0; g_combos[i].d2[1]=265.8; g_combos[i].d2[2]=294.0; g_combos[i].d2[3]=247.2;
   g_combos[i].d3[0]=618.0; g_combos[i].d3[1]=261.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=30; g_combos[i].nt[1]=27; g_combos[i].nt[2]=36; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=8; g_combos[i].nok[2]=5; g_combos[i].nok[3]=4;
   i++;

   // BS1MF | ZB/SELL | n_ang=21 | Good | score=50.4
   g_combos[i].code="BS1MF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=21; g_combos[i].tier=3; g_combos[i].signal_score=50.41;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=52.38; g_combos[i].p1[1]=54.55; g_combos[i].p1[2]=38.10; g_combos[i].p1[3]=43.75;
   g_combos[i].p2[0]=81.82; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=45.45; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=192.5; g_combos[i].d1[1]=357.0; g_combos[i].d1[2]=211.0; g_combos[i].d1[3]=461.1;
   g_combos[i].d2[0]=334.7; g_combos[i].d2[1]=442.3; g_combos[i].d2[2]=338.8; g_combos[i].d2[3]=461.1;
   g_combos[i].d3[0]=616.0; g_combos[i].d3[1]=445.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=21; g_combos[i].nt[1]=11; g_combos[i].nt[2]=21; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=11; g_combos[i].nok[1]=6; g_combos[i].nok[2]=8; g_combos[i].nok[3]=7;
   i++;

   // BS2SE | ZB/SELL | n_ang=25 | Good | score=50.0
   g_combos[i].code="BS2SE"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=25; g_combos[i].tier=3; g_combos[i].signal_score=50.00;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=25.00; g_combos[i].p1[1]=42.86; g_combos[i].p1[2]=32.00; g_combos[i].p1[3]=58.82;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=87.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=137.8; g_combos[i].d1[1]=321.0; g_combos[i].d1[2]=203.9; g_combos[i].d1[3]=263.6;
   g_combos[i].d2[0]=441.8; g_combos[i].d2[1]=282.0; g_combos[i].d2[2]=242.3; g_combos[i].d2[3]=263.6;
   g_combos[i].d3[0]=511.7; g_combos[i].d3[1]=379.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=14; g_combos[i].nt[2]=25; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=6; g_combos[i].nok[2]=8; g_combos[i].nok[3]=10;
   i++;

   // ES2SF | ZE/SELL | n_ang=20 | Good | score=49.2
   g_combos[i].code="ES2SF"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=20; g_combos[i].tier=3; g_combos[i].signal_score=49.19;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=46.67; g_combos[i].p1[1]=46.67; g_combos[i].p1[2]=55.56; g_combos[i].p1[3]=61.11;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=57.14; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=42.86; g_combos[i].p3[1]=42.86; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=195.3; g_combos[i].d1[1]=425.4; g_combos[i].d1[2]=202.1; g_combos[i].d1[3]=236.0;
   g_combos[i].d2[0]=255.8; g_combos[i].d2[1]=390.0; g_combos[i].d2[2]=408.1; g_combos[i].d2[3]=236.0;
   g_combos[i].d3[0]=363.3; g_combos[i].d3[1]=384.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=15; g_combos[i].nt[2]=18; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=7; g_combos[i].nok[2]=10; g_combos[i].nok[3]=11;
   i++;

   // BS3MB | ZB/SELL | n_ang=28 | Good | score=47.6
   g_combos[i].code="BS3MB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=28; g_combos[i].tier=3; g_combos[i].signal_score=47.62;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=27.27; g_combos[i].p1[1]=21.05; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=38.10;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=25.00; g_combos[i].p2[2]=77.78; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=318.3; g_combos[i].d1[1]=341.5; g_combos[i].d1[2]=217.7; g_combos[i].d1[3]=473.5;
   g_combos[i].d2[0]=417.0; g_combos[i].d2[1]=739.0; g_combos[i].d2[2]=450.9; g_combos[i].d2[3]=473.5;
   g_combos[i].d3[0]=466.8; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=19; g_combos[i].nt[2]=27; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=4; g_combos[i].nok[2]=9; g_combos[i].nok[3]=8;
   i++;

   // CS2MG | ZC/SELL | n_ang=28 | Good | score=47.6
   g_combos[i].code="CS2MG"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=28; g_combos[i].tier=3; g_combos[i].signal_score=47.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=47.37; g_combos[i].p1[1]=33.33; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=26.92;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=283.7; g_combos[i].d1[1]=426.4; g_combos[i].d1[2]=414.1; g_combos[i].d1[3]=273.3;
   g_combos[i].d2[0]=433.7; g_combos[i].d2[1]=440.0; g_combos[i].d2[2]=553.2; g_combos[i].d2[3]=273.3;
   g_combos[i].d3[0]=487.5; g_combos[i].d3[1]=536.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=24; g_combos[i].nt[2]=21; g_combos[i].nt[3]=26;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=7; g_combos[i].nok[3]=7;
   i++;

   // HS4SG | ZH/SELL | n_ang=28 | Good | score=47.6
   g_combos[i].code="HS4SG"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=28; g_combos[i].tier=3; g_combos[i].signal_score=47.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=5.26; g_combos[i].p1[2]=3.57; g_combos[i].p1[3]=26.32;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=178.7; g_combos[i].d1[1]=390.0; g_combos[i].d1[2]=87.0; g_combos[i].d1[3]=342.8;
   g_combos[i].d2[0]=182.5; g_combos[i].d2[1]=391.0; g_combos[i].d2[2]=90.0; g_combos[i].d2[3]=342.8;
   g_combos[i].d3[0]=188.3; g_combos[i].d3[1]=886.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=19; g_combos[i].nt[2]=28; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=1; g_combos[i].nok[2]=1; g_combos[i].nok[3]=5;
   i++;

   // BS3SC | ZB/SELL | n_ang=27 | Weak | score=46.8
   g_combos[i].code="BS3SC"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=27; g_combos[i].tier=4; g_combos[i].signal_score=46.77;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=40.91; g_combos[i].p1[1]=35.29; g_combos[i].p1[2]=11.11; g_combos[i].p1[3]=22.22;
   g_combos[i].p2[0]=44.44; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=240.7; g_combos[i].d1[1]=479.2; g_combos[i].d1[2]=347.3; g_combos[i].d1[3]=406.8;
   g_combos[i].d2[0]=408.0; g_combos[i].d2[1]=669.7; g_combos[i].d2[2]=351.0; g_combos[i].d2[3]=406.8;
   g_combos[i].d3[0]=483.8; g_combos[i].d3[1]=745.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=17; g_combos[i].nt[2]=27; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=6; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // ES1LE | ZE/SELL | n_ang=27 | Weak | score=46.8
   g_combos[i].code="ES1LE"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=27; g_combos[i].tier=4; g_combos[i].signal_score=46.77;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=40.91; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=27.27; g_combos[i].p1[3]=19.05;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=77.78; g_combos[i].p3[1]=87.50; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=494.9; g_combos[i].d1[1]=321.2; g_combos[i].d1[2]=448.5; g_combos[i].d1[3]=337.5;
   g_combos[i].d2[0]=452.7; g_combos[i].d2[1]=522.4; g_combos[i].d2[2]=500.2; g_combos[i].d2[3]=337.5;
   g_combos[i].d3[0]=510.1; g_combos[i].d3[1]=523.9; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=16; g_combos[i].nt[2]=22; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=8; g_combos[i].nok[2]=6; g_combos[i].nok[3]=4;
   i++;

   // HS4SF | ZH/SELL | n_ang=33 | Weak | score=46.0
   g_combos[i].code="HS4SF"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=33; g_combos[i].tier=4; g_combos[i].signal_score=45.96;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=17.86; g_combos[i].p1[1]=29.63; g_combos[i].p1[2]=12.12; g_combos[i].p1[3]=22.22;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=87.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=81.4; g_combos[i].d1[1]=222.8; g_combos[i].d1[2]=78.2; g_combos[i].d1[3]=198.2;
   g_combos[i].d2[0]=492.7; g_combos[i].d2[1]=320.6; g_combos[i].d2[2]=85.8; g_combos[i].d2[3]=198.2;
   g_combos[i].d3[0]=492.7; g_combos[i].d3[1]=560.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=28; g_combos[i].nt[1]=27; g_combos[i].nt[2]=33; g_combos[i].nt[3]=27;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=8; g_combos[i].nok[2]=4; g_combos[i].nok[3]=6;
   i++;

   // FS4MD | ZF/SELL | n_ang=43 | Weak | score=45.9
   g_combos[i].code="FS4MD"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=43; g_combos[i].tier=4; g_combos[i].signal_score=45.90;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=16.67; g_combos[i].p1[1]=13.79; g_combos[i].p1[2]=17.50; g_combos[i].p1[3]=6.67;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=227.0; g_combos[i].d1[1]=312.5; g_combos[i].d1[2]=321.3; g_combos[i].d1[3]=368.0;
   g_combos[i].d2[0]=500.2; g_combos[i].d2[1]=435.5; g_combos[i].d2[2]=327.3; g_combos[i].d2[3]=368.0;
   g_combos[i].d3[0]=347.3; g_combos[i].d3[1]=86.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=30; g_combos[i].nt[1]=29; g_combos[i].nt[2]=40; g_combos[i].nt[3]=30;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=4; g_combos[i].nok[2]=7; g_combos[i].nok[3]=2;
   i++;

   // BS2MC | ZB/SELL | n_ang=25 | Weak | score=45.0
   g_combos[i].code="BS2MC"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=25; g_combos[i].tier=4; g_combos[i].signal_score=45.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=45.00; g_combos[i].p1[1]=35.29; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=71.43; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=55.56; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=307.4; g_combos[i].d1[1]=645.5; g_combos[i].d1[2]=457.1; g_combos[i].d1[3]=576.8;
   g_combos[i].d2[0]=588.4; g_combos[i].d2[1]=672.7; g_combos[i].d2[2]=363.2; g_combos[i].d2[3]=576.8;
   g_combos[i].d3[0]=616.8; g_combos[i].d3[1]=706.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=20; g_combos[i].nt[1]=17; g_combos[i].nt[2]=21; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=6; g_combos[i].nok[2]=7; g_combos[i].nok[3]=4;
   i++;

   // BS3SH | ZB/SELL | n_ang=23 | Weak | score=43.2
   g_combos[i].code="BS3SH"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=23; g_combos[i].tier=4; g_combos[i].signal_score=43.16;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=45.00; g_combos[i].p1[1]=52.94; g_combos[i].p1[2]=13.64; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=55.56; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=33.33; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=44.44; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=346.6; g_combos[i].d1[1]=354.7; g_combos[i].d1[2]=270.3; g_combos[i].d1[3]=339.9;
   g_combos[i].d2[0]=291.0; g_combos[i].d2[1]=424.2; g_combos[i].d2[2]=35.0; g_combos[i].d2[3]=339.9;
   g_combos[i].d3[0]=235.2; g_combos[i].d3[1]=574.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=20; g_combos[i].nt[1]=17; g_combos[i].nt[2]=22; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=9; g_combos[i].nok[2]=3; g_combos[i].nok[3]=9;
   i++;

   // DS2SE | ZD/SELL | n_ang=23 | Weak | score=43.2
   g_combos[i].code="DS2SE"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=23; g_combos[i].tier=4; g_combos[i].signal_score=43.16;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=53.33; g_combos[i].p1[1]=26.32; g_combos[i].p1[2]=31.82; g_combos[i].p1[3]=42.86;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=258.0; g_combos[i].d1[1]=370.4; g_combos[i].d1[2]=159.1; g_combos[i].d1[3]=247.1;
   g_combos[i].d2[0]=548.8; g_combos[i].d2[1]=304.0; g_combos[i].d2[2]=265.6; g_combos[i].d2[3]=247.1;
   g_combos[i].d3[0]=588.6; g_combos[i].d3[1]=319.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=19; g_combos[i].nt[2]=22; g_combos[i].nt[3]=21;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=5; g_combos[i].nok[2]=7; g_combos[i].nok[3]=9;
   i++;

   // DS3SE | ZD/SELL | n_ang=29 | Weak | score=43.1
   g_combos[i].code="DS3SE"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=29; g_combos[i].tier=4; g_combos[i].signal_score=43.08;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=29.63; g_combos[i].p1[1]=26.67; g_combos[i].p1[2]=7.14; g_combos[i].p1[3]=23.53;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=238.6; g_combos[i].d1[1]=357.8; g_combos[i].d1[2]=75.5; g_combos[i].d1[3]=301.8;
   g_combos[i].d2[0]=356.3; g_combos[i].d2[1]=551.3; g_combos[i].d2[2]=291.5; g_combos[i].d2[3]=301.8;
   g_combos[i].d3[0]=667.7; g_combos[i].d3[1]=591.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=27; g_combos[i].nt[1]=15; g_combos[i].nt[2]=28; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=4;
   i++;

   // BS1MB | ZB/SELL | n_ang=18 | Weak | score=42.4
   g_combos[i].code="BS1MB"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=18; g_combos[i].tier=4; g_combos[i].signal_score=42.43;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=60.00; g_combos[i].p1[2]=58.82; g_combos[i].p1[3]=30.77;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=60.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=281.1; g_combos[i].d1[1]=240.7; g_combos[i].d1[2]=323.4; g_combos[i].d1[3]=373.5;
   g_combos[i].d2[0]=458.3; g_combos[i].d2[1]=434.8; g_combos[i].d2[2]=360.5; g_combos[i].d2[3]=373.5;
   g_combos[i].d3[0]=621.0; g_combos[i].d3[1]=344.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=10; g_combos[i].nt[2]=17; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=6; g_combos[i].nok[2]=10; g_combos[i].nok[3]=4;
   i++;

   // BS2ME | ZB/SELL | n_ang=28 | Weak | score=42.3
   g_combos[i].code="BS2ME"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=28; g_combos[i].tier=4; g_combos[i].signal_score=42.33;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.00; g_combos[i].p1[1]=29.41; g_combos[i].p1[2]=30.77; g_combos[i].p1[3]=15.79;
   g_combos[i].p2[0]=33.33; g_combos[i].p2[1]=40.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=20.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=334.0; g_combos[i].d1[1]=395.6; g_combos[i].d1[2]=149.0; g_combos[i].d1[3]=282.0;
   g_combos[i].d2[0]=585.5; g_combos[i].d2[1]=397.5; g_combos[i].d2[2]=207.2; g_combos[i].d2[3]=282.0;
   g_combos[i].d3[0]=599.0; g_combos[i].d3[1]=277.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=20; g_combos[i].nt[1]=17; g_combos[i].nt[2]=26; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=5; g_combos[i].nok[2]=8; g_combos[i].nok[3]=3;
   i++;

   // DS2SO | ZD/SELL | n_ang=21 | Weak | score=41.2
   g_combos[i].code="DS2SO"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=21; g_combos[i].tier=4; g_combos[i].signal_score=41.24;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=37.50; g_combos[i].p1[1]=50.00; g_combos[i].p1[2]=42.86; g_combos[i].p1[3]=31.58;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=44.44; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=44.44; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=340.3; g_combos[i].d1[1]=365.7; g_combos[i].d1[2]=89.7; g_combos[i].d1[3]=188.2;
   g_combos[i].d2[0]=241.5; g_combos[i].d2[1]=398.2; g_combos[i].d2[2]=130.0; g_combos[i].d2[3]=188.2;
   g_combos[i].d3[0]=314.7; g_combos[i].d3[1]=670.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=18; g_combos[i].nt[2]=21; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=9; g_combos[i].nok[2]=9; g_combos[i].nok[3]=6;
   i++;

   // CS2LB | ZC/SELL | n_ang=33 | Weak | score=40.2
   g_combos[i].code="CS2LB"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=33; g_combos[i].tier=4; g_combos[i].signal_score=40.21;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=30.43; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=20.83; g_combos[i].p1[3]=27.27;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=471.1; g_combos[i].d1[1]=365.0; g_combos[i].d1[2]=468.2; g_combos[i].d1[3]=537.2;
   g_combos[i].d2[0]=570.6; g_combos[i].d2[1]=753.5; g_combos[i].d2[2]=682.0; g_combos[i].d2[3]=537.2;
   g_combos[i].d3[0]=674.8; g_combos[i].d3[1]=754.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=20; g_combos[i].nt[2]=24; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=4; g_combos[i].nok[2]=5; g_combos[i].nok[3]=6;
   i++;

   // BS3MO | ZB/SELL | n_ang=23 | Weak | score=38.4
   g_combos[i].code="BS3MO"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=23; g_combos[i].tier=4; g_combos[i].signal_score=38.37;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=50.00; g_combos[i].p1[1]=29.41; g_combos[i].p1[2]=31.58; g_combos[i].p1[3]=23.53;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=40.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=40.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=392.4; g_combos[i].d1[1]=282.4; g_combos[i].d1[2]=181.5; g_combos[i].d1[3]=416.2;
   g_combos[i].d2[0]=506.4; g_combos[i].d2[1]=355.5; g_combos[i].d2[2]=408.7; g_combos[i].d2[3]=416.2;
   g_combos[i].d3[0]=534.3; g_combos[i].d3[1]=356.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=17; g_combos[i].nt[2]=19; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=5; g_combos[i].nok[2]=6; g_combos[i].nok[3]=4;
   i++;

   // DS2SD | ZD/SELL | n_ang=17 | Weak | score=37.1
   g_combos[i].code="DS2SD"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=17; g_combos[i].tier=4; g_combos[i].signal_score=37.11;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=69.23; g_combos[i].p1[1]=55.56; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=55.56; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=263.0; g_combos[i].d1[1]=291.2; g_combos[i].d1[2]=163.5; g_combos[i].d1[3]=378.0;
   g_combos[i].d2[0]=523.6; g_combos[i].d2[1]=519.8; g_combos[i].d2[2]=302.8; g_combos[i].d2[3]=378.0;
   g_combos[i].d3[0]=458.7; g_combos[i].d3[1]=423.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=9; g_combos[i].nt[2]=16; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=5; g_combos[i].nok[2]=4; g_combos[i].nok[3]=6;
   i++;

   // ES2SO | ZE/SELL | n_ang=16 | Weak | score=36.0
   g_combos[i].code="ES2SO"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=4; g_combos[i].signal_score=36.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=60.00; g_combos[i].p1[1]=46.15; g_combos[i].p1[2]=46.67; g_combos[i].p1[3]=37.50;
   g_combos[i].p2[0]=77.78; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=85.71; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=265.6; g_combos[i].d1[1]=357.0; g_combos[i].d1[2]=208.1; g_combos[i].d1[3]=268.8;
   g_combos[i].d2[0]=279.0; g_combos[i].d2[1]=415.3; g_combos[i].d2[2]=270.8; g_combos[i].d2[3]=268.8;
   g_combos[i].d3[0]=369.2; g_combos[i].d3[1]=513.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=13; g_combos[i].nt[2]=15; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=9; g_combos[i].nok[1]=6; g_combos[i].nok[2]=7; g_combos[i].nok[3]=6;
   i++;

   // BS2SG | ZB/SELL | n_ang=20 | Weak | score=35.8
   g_combos[i].code="BS2SG"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=20; g_combos[i].tier=4; g_combos[i].signal_score=35.78;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=42.11; g_combos[i].p1[1]=45.45; g_combos[i].p1[2]=35.00; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=57.14; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=62.50; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=319.1; g_combos[i].d1[1]=270.0; g_combos[i].d1[2]=277.0; g_combos[i].d1[3]=219.0;
   g_combos[i].d2[0]=420.8; g_combos[i].d2[1]=415.2; g_combos[i].d2[2]=244.0; g_combos[i].d2[3]=219.0;
   g_combos[i].d3[0]=496.8; g_combos[i].d3[1]=451.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=19; g_combos[i].nt[1]=11; g_combos[i].nt[2]=20; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=5; g_combos[i].nok[2]=7; g_combos[i].nok[3]=3;
   i++;

   // DS4SH | ZD/SELL | n_ang=20 | Weak | score=35.8
   g_combos[i].code="DS4SH"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=20; g_combos[i].tier=4; g_combos[i].signal_score=35.78;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=47.06; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=10.00; g_combos[i].p1[3]=31.25;
   g_combos[i].p2[0]=62.50; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=208.4; g_combos[i].d1[1]=353.5; g_combos[i].d1[2]=84.0; g_combos[i].d1[3]=536.2;
   g_combos[i].d2[0]=315.6; g_combos[i].d2[1]=399.0; g_combos[i].d2[2]=104.0; g_combos[i].d2[3]=536.2;
   g_combos[i].d3[0]=299.0; g_combos[i].d3[1]=369.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=14; g_combos[i].nt[2]=20; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=5;
   i++;

   // HS4SD | ZH/SELL | n_ang=33 | Weak | score=34.5
   g_combos[i].code="HS4SD"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=33; g_combos[i].tier=4; g_combos[i].signal_score=34.47;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=19.35; g_combos[i].p1[1]=15.00; g_combos[i].p1[2]=0.00; g_combos[i].p1[3]=10.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=86.3; g_combos[i].d1[1]=334.3; g_combos[i].d1[2]=0.0; g_combos[i].d1[3]=318.5;
   g_combos[i].d2[0]=353.0; g_combos[i].d2[1]=508.0; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=318.5;
   g_combos[i].d3[0]=379.5; g_combos[i].d3[1]=572.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=31; g_combos[i].nt[1]=20; g_combos[i].nt[2]=33; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=3; g_combos[i].nok[2]=0; g_combos[i].nok[3]=2;
   i++;

   // CS2LO | ZC/SELL | n_ang=17 | Weak | score=33.0
   g_combos[i].code="CS2LO"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=17; g_combos[i].tier=4; g_combos[i].signal_score=32.98;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=63.64; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=66.67; g_combos[i].p1[3]=17.65;
   g_combos[i].p2[0]=85.71; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=87.50; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=71.43; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=216.3; g_combos[i].d1[1]=252.3; g_combos[i].d1[2]=177.2; g_combos[i].d1[3]=215.7;
   g_combos[i].d2[0]=250.0; g_combos[i].d2[1]=72.0; g_combos[i].d2[2]=246.9; g_combos[i].d2[3]=215.7;
   g_combos[i].d3[0]=292.0; g_combos[i].d3[1]=72.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=15; g_combos[i].nt[2]=12; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=3; g_combos[i].nok[2]=8; g_combos[i].nok[3]=3;
   i++;

   // FS4SH | ZF/SELL | n_ang=29 | Weak | score=32.3
   g_combos[i].code="FS4SH"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=29; g_combos[i].tier=4; g_combos[i].signal_score=32.31;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=26.09; g_combos[i].p1[1]=11.76; g_combos[i].p1[2]=0.00; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=265.7; g_combos[i].d1[1]=272.0; g_combos[i].d1[2]=0.0; g_combos[i].d1[3]=514.0;
   g_combos[i].d2[0]=341.7; g_combos[i].d2[1]=232.0; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=514.0;
   g_combos[i].d3[0]=240.5; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=23; g_combos[i].nt[1]=17; g_combos[i].nt[2]=29; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=2; g_combos[i].nok[2]=0; g_combos[i].nok[3]=2;
   i++;

   // OS4SO | ZO/SELL | n_ang=16 | Weak | score=32.0
   g_combos[i].code="OS4SO"; g_combos[i].cls="ZO"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=4; g_combos[i].signal_score=32.00;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=8.33; g_combos[i].p1[1]=57.14; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=42.86;
   g_combos[i].p2[0]=0.00; g_combos[i].p2[1]=62.50; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=270.0; g_combos[i].d1[1]=127.2; g_combos[i].d1[2]=219.3; g_combos[i].d1[3]=115.3;
   g_combos[i].d2[0]=0.0; g_combos[i].d2[1]=146.0; g_combos[i].d2[2]=221.3; g_combos[i].d2[3]=115.3;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=142.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=12; g_combos[i].nt[1]=14; g_combos[i].nt[2]=13; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=1; g_combos[i].nok[1]=8; g_combos[i].nok[2]=3; g_combos[i].nok[3]=6;
   i++;

   // BS2MH | ZB/SELL | n_ang=15 | Weak | score=31.0
   g_combos[i].code="BS2MH"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=4; g_combos[i].signal_score=30.98;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=57.14; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=35.71; g_combos[i].p1[3]=0.00;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=0.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=235.6; g_combos[i].d1[1]=343.5; g_combos[i].d1[2]=379.6; g_combos[i].d1[3]=0.0;
   g_combos[i].d2[0]=482.0; g_combos[i].d2[1]=228.0; g_combos[i].d2[2]=373.0; g_combos[i].d2[3]=0.0;
   g_combos[i].d3[0]=535.8; g_combos[i].d3[1]=297.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=10; g_combos[i].nt[2]=14; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=2; g_combos[i].nok[2]=5; g_combos[i].nok[3]=0;
   i++;

   // ES1MO | ZE/SELL | n_ang=15 | Weak | score=31.0
   g_combos[i].code="ES1MO"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=4; g_combos[i].signal_score=30.98;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=66.67; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=38.46; g_combos[i].p1[3]=14.29;
   g_combos[i].p2[0]=87.50; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=80.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=336.9; g_combos[i].d1[1]=219.0; g_combos[i].d1[2]=368.4; g_combos[i].d1[3]=606.5;
   g_combos[i].d2[0]=349.3; g_combos[i].d2[1]=445.0; g_combos[i].d2[2]=539.8; g_combos[i].d2[3]=606.5;
   g_combos[i].d3[0]=369.5; g_combos[i].d3[1]=445.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=12; g_combos[i].nt[1]=10; g_combos[i].nt[2]=13; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=8; g_combos[i].nok[1]=2; g_combos[i].nok[2]=5; g_combos[i].nok[3]=2;
   i++;

   // BS3MF | ZB/SELL | n_ang=19 | Weak | score=30.5
   g_combos[i].code="BS3MF"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=19; g_combos[i].tier=4; g_combos[i].signal_score=30.51;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=43.75; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=22.22; g_combos[i].p1[3]=0.00;
   g_combos[i].p2[0]=28.57; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=75.00; g_combos[i].p2[3]=0.00;
   g_combos[i].p3[0]=28.57; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=246.4; g_combos[i].d1[1]=402.0; g_combos[i].d1[2]=320.5; g_combos[i].d1[3]=0.0;
   g_combos[i].d2[0]=302.5; g_combos[i].d2[1]=358.0; g_combos[i].d2[2]=337.3; g_combos[i].d2[3]=0.0;
   g_combos[i].d3[0]=353.5; g_combos[i].d3[1]=368.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=9; g_combos[i].nt[2]=18; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=2; g_combos[i].nok[2]=4; g_combos[i].nok[3]=0;
   i++;

   // CS2MD | ZC/SELL | n_ang=19 | Weak | score=30.5
   g_combos[i].code="CS2MD"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=19; g_combos[i].tier=4; g_combos[i].signal_score=30.51;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=46.15; g_combos[i].p1[1]=46.15; g_combos[i].p1[2]=26.67; g_combos[i].p1[3]=41.18;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=289.7; g_combos[i].d1[1]=353.2; g_combos[i].d1[2]=303.5; g_combos[i].d1[3]=395.1;
   g_combos[i].d2[0]=233.5; g_combos[i].d2[1]=520.2; g_combos[i].d2[2]=423.0; g_combos[i].d2[3]=395.1;
   g_combos[i].d3[0]=267.7; g_combos[i].d3[1]=539.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=13; g_combos[i].nt[2]=15; g_combos[i].nt[3]=17;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=6; g_combos[i].nok[2]=4; g_combos[i].nok[3]=7;
   i++;

   // BS3MG | ZB/SELL | n_ang=24 | Very Weak | score=29.4
   g_combos[i].code="BS3MG"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=24; g_combos[i].tier=5; g_combos[i].signal_score=29.39;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=27.27; g_combos[i].p1[1]=31.25; g_combos[i].p1[2]=13.04; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=80.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=304.0; g_combos[i].d1[1]=362.8; g_combos[i].d1[2]=591.3; g_combos[i].d1[3]=294.3;
   g_combos[i].d2[0]=588.3; g_combos[i].d2[1]=545.2; g_combos[i].d2[2]=645.0; g_combos[i].d2[3]=294.3;
   g_combos[i].d3[0]=489.0; g_combos[i].d3[1]=460.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=22; g_combos[i].nt[1]=16; g_combos[i].nt[2]=23; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=5; g_combos[i].nok[2]=3; g_combos[i].nok[3]=6;
   i++;

   // ES2LD | ZE/SELL | n_ang=23 | Very Weak | score=28.8
   g_combos[i].code="ES2LD"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=23; g_combos[i].tier=5; g_combos[i].signal_score=28.77;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.29; g_combos[i].p1[1]=18.75; g_combos[i].p1[2]=21.05; g_combos[i].p1[3]=30.00;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=33.33; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=83.33; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=233.2; g_combos[i].d1[1]=551.7; g_combos[i].d1[2]=530.2; g_combos[i].d1[3]=239.8;
   g_combos[i].d2[0]=487.2; g_combos[i].d2[1]=448.0; g_combos[i].d2[2]=247.5; g_combos[i].d2[3]=239.8;
   g_combos[i].d3[0]=506.2; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=17; g_combos[i].nt[1]=16; g_combos[i].nt[2]=19; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=3; g_combos[i].nok[2]=4; g_combos[i].nok[3]=6;
   i++;

   // ES2LG | ZE/SELL | n_ang=33 | Very Weak | score=28.7
   g_combos[i].code="ES2LG"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=33; g_combos[i].tier=5; g_combos[i].signal_score=28.72;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=12.50; g_combos[i].p1[1]=18.18; g_combos[i].p1[2]=11.54; g_combos[i].p1[3]=20.00;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=335.3; g_combos[i].d1[1]=550.8; g_combos[i].d1[2]=493.7; g_combos[i].d1[3]=441.8;
   g_combos[i].d2[0]=266.0; g_combos[i].d2[1]=740.3; g_combos[i].d2[2]=592.7; g_combos[i].d2[3]=441.8;
   g_combos[i].d3[0]=288.5; g_combos[i].d3[1]=742.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=24; g_combos[i].nt[1]=22; g_combos[i].nt[2]=26; g_combos[i].nt[3]=25;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=4; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // FS4MC | ZF/SELL | n_ang=32 | Very Weak | score=28.3
   g_combos[i].code="FS4MC"; g_combos[i].cls="ZF"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=32; g_combos[i].tier=5; g_combos[i].signal_score=28.28;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=1; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=12.00; g_combos[i].p1[1]=14.29; g_combos[i].p1[2]=17.24; g_combos[i].p1[3]=13.64;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=33.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=351.3; g_combos[i].d1[1]=262.3; g_combos[i].d1[2]=194.4; g_combos[i].d1[3]=672.0;
   g_combos[i].d2[0]=592.5; g_combos[i].d2[1]=638.5; g_combos[i].d2[2]=226.0; g_combos[i].d2[3]=672.0;
   g_combos[i].d3[0]=667.0; g_combos[i].d3[1]=721.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=25; g_combos[i].nt[1]=21; g_combos[i].nt[2]=29; g_combos[i].nt[3]=22;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=3; g_combos[i].nok[2]=5; g_combos[i].nok[3]=3;
   i++;

   // CS2ME | ZC/SELL | n_ang=16 | Very Weak | score=28.0
   g_combos[i].code="CS2ME"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=28.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=63.64; g_combos[i].p1[1]=10.00; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=50.00;
   g_combos[i].p2[0]=71.43; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=66.67; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=57.14; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=258.0; g_combos[i].d1[1]=59.0; g_combos[i].d1[2]=164.7; g_combos[i].d1[3]=313.3;
   g_combos[i].d2[0]=433.2; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=282.5; g_combos[i].d2[3]=313.3;
   g_combos[i].d3[0]=558.8; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=10; g_combos[i].nt[2]=13; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=7; g_combos[i].nok[1]=1; g_combos[i].nok[2]=3; g_combos[i].nok[3]=7;
   i++;

   // ES2MC | ZE/SELL | n_ang=19 | Very Weak | score=26.1
   g_combos[i].code="ES2MC"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=19; g_combos[i].tier=5; g_combos[i].signal_score=26.15;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=46.15; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=83.33; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=83.33; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.8; g_combos[i].d1[1]=342.3; g_combos[i].d1[2]=291.5; g_combos[i].d1[3]=205.8;
   g_combos[i].d2[0]=310.3; g_combos[i].d2[1]=451.0; g_combos[i].d2[2]=342.5; g_combos[i].d2[3]=205.8;
   g_combos[i].d3[0]=354.3; g_combos[i].d3[1]=478.2; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=13; g_combos[i].nt[2]=16; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=6; g_combos[i].nok[2]=4; g_combos[i].nok[3]=5;
   i++;

   // ES2MH | ZE/SELL | n_ang=19 | Very Weak | score=26.1
   g_combos[i].code="ES2MH"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=19; g_combos[i].tier=5; g_combos[i].signal_score=26.15;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=18.18; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=14.29; g_combos[i].p1[3]=40.00;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=25.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=101.5; g_combos[i].d1[1]=399.5; g_combos[i].d1[2]=163.0; g_combos[i].d1[3]=353.8;
   g_combos[i].d2[0]=209.0; g_combos[i].d2[1]=543.0; g_combos[i].d2[2]=176.0; g_combos[i].d2[3]=353.8;
   g_combos[i].d3[0]=434.0; g_combos[i].d3[1]=544.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=11; g_combos[i].nt[2]=14; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=6;
   i++;

   // BS2SC | ZB/SELL | n_ang=16 | Very Weak | score=24.0
   g_combos[i].code="BS2SC"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=24.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=46.15; g_combos[i].p1[1]=0.00; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=66.67;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=203.5; g_combos[i].d1[1]=0.0; g_combos[i].d1[2]=61.8; g_combos[i].d1[3]=471.8;
   g_combos[i].d2[0]=399.3; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=211.8; g_combos[i].d2[3]=471.8;
   g_combos[i].d3[0]=409.0; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=8; g_combos[i].nt[2]=16; g_combos[i].nt[3]=9;
   g_combos[i].nok[0]=6; g_combos[i].nok[1]=0; g_combos[i].nok[2]=4; g_combos[i].nok[3]=6;
   i++;

   // HS4SC | ZH/SELL | n_ang=22 | Very Weak | score=23.4
   g_combos[i].code="HS4SC"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=22; g_combos[i].tier=5; g_combos[i].signal_score=23.45;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=18.75; g_combos[i].p1[1]=27.78; g_combos[i].p1[2]=13.64; g_combos[i].p1[3]=26.32;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=80.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=50.0; g_combos[i].d1[1]=440.8; g_combos[i].d1[2]=35.0; g_combos[i].d1[3]=237.6;
   g_combos[i].d2[0]=232.7; g_combos[i].d2[1]=454.0; g_combos[i].d2[2]=35.0; g_combos[i].d2[3]=237.6;
   g_combos[i].d3[0]=332.0; g_combos[i].d3[1]=588.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=18; g_combos[i].nt[2]=22; g_combos[i].nt[3]=19;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=5; g_combos[i].nok[2]=3; g_combos[i].nok[3]=5;
   i++;

   // CS2LG | ZC/SELL | n_ang=20 | Very Weak | score=22.4
   g_combos[i].code="CS2LG"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=20; g_combos[i].tier=5; g_combos[i].signal_score=22.36;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=31.25; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=17.65; g_combos[i].p1[3]=6.25;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=80.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=277.2; g_combos[i].d1[1]=360.0; g_combos[i].d1[2]=424.0; g_combos[i].d1[3]=116.0;
   g_combos[i].d2[0]=317.0; g_combos[i].d2[1]=483.0; g_combos[i].d2[2]=439.3; g_combos[i].d2[3]=116.0;
   g_combos[i].d3[0]=345.8; g_combos[i].d3[1]=509.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=15; g_combos[i].nt[2]=17; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=3; g_combos[i].nok[2]=3; g_combos[i].nok[3]=1;
   i++;

   // DS4SC | ZD/SELL | n_ang=17 | Very Weak | score=20.6
   g_combos[i].code="DS4SC"; g_combos[i].cls="ZD"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=20.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=38.46; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=11.76; g_combos[i].p1[3]=33.33;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=40.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=99.6; g_combos[i].d1[1]=162.5; g_combos[i].d1[2]=80.5; g_combos[i].d1[3]=208.8;
   g_combos[i].d2[0]=215.7; g_combos[i].d2[1]=211.2; g_combos[i].d2[2]=169.0; g_combos[i].d2[3]=208.8;
   g_combos[i].d3[0]=166.5; g_combos[i].d3[1]=422.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=11; g_combos[i].nt[2]=17; g_combos[i].nt[3]=12;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=4;
   i++;

   // ES3MD | ZE/SELL | n_ang=17 | Very Weak | score=20.6
   g_combos[i].code="ES3MD"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=20.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.71; g_combos[i].p1[1]=27.27; g_combos[i].p1[2]=14.29; g_combos[i].p1[3]=38.46;
   g_combos[i].p2[0]=60.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=60.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=357.0; g_combos[i].d1[1]=227.7; g_combos[i].d1[2]=376.0; g_combos[i].d1[3]=378.2;
   g_combos[i].d2[0]=499.7; g_combos[i].d2[1]=339.5; g_combos[i].d2[2]=456.5; g_combos[i].d2[3]=378.2;
   g_combos[i].d3[0]=554.3; g_combos[i].d3[1]=355.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=11; g_combos[i].nt[2]=14; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=3; g_combos[i].nok[2]=2; g_combos[i].nok[3]=5;
   i++;

   // ES1LH | ZE/SELL | n_ang=16 | Very Weak | score=20.0
   g_combos[i].code="ES1LH"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=20.00;
   g_combos[i].test_rank[0]=3; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=12.50; g_combos[i].p1[1]=38.46; g_combos[i].p1[2]=0.00; g_combos[i].p1[3]=14.29;
   g_combos[i].p2[0]=0.00; g_combos[i].p2[1]=60.00; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=0.00; g_combos[i].p3[1]=60.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=179.0; g_combos[i].d1[1]=346.6; g_combos[i].d1[2]=0.0; g_combos[i].d1[3]=112.5;
   g_combos[i].d2[0]=0.0; g_combos[i].d2[1]=487.0; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=112.5;
   g_combos[i].d3[0]=0.0; g_combos[i].d3[1]=488.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=8; g_combos[i].nt[1]=13; g_combos[i].nt[2]=8; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=1; g_combos[i].nok[1]=5; g_combos[i].nok[2]=0; g_combos[i].nok[3]=2;
   i++;

   // OS4ME | ZO/SELL | n_ang=25 | Very Weak | score=20.0
   g_combos[i].code="OS4ME"; g_combos[i].cls="ZO"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=25; g_combos[i].tier=5; g_combos[i].signal_score=20.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=22.22; g_combos[i].p1[1]=20.00; g_combos[i].p1[2]=5.00; g_combos[i].p1[3]=5.00;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=25.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=374.2; g_combos[i].d1[1]=541.8; g_combos[i].d1[2]=738.0; g_combos[i].d1[3]=643.0;
   g_combos[i].d2[0]=513.0; g_combos[i].d2[1]=807.0; g_combos[i].d2[2]=738.0; g_combos[i].d2[3]=643.0;
   g_combos[i].d3[0]=525.0; g_combos[i].d3[1]=687.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=18; g_combos[i].nt[1]=20; g_combos[i].nt[2]=20; g_combos[i].nt[3]=20;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=4; g_combos[i].nok[2]=1; g_combos[i].nok[3]=1;
   i++;

   // BS3ME | ZB/SELL | n_ang=15 | Very Weak | score=19.4
   g_combos[i].code="BS3ME"; g_combos[i].cls="ZB"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=19.36;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=20.00; g_combos[i].p1[1]=25.00; g_combos[i].p1[2]=13.33; g_combos[i].p1[3]=55.56;
   g_combos[i].p2[0]=33.33; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=341.7; g_combos[i].d1[1]=505.5; g_combos[i].d1[2]=214.0; g_combos[i].d1[3]=242.8;
   g_combos[i].d2[0]=475.0; g_combos[i].d2[1]=609.0; g_combos[i].d2[2]=426.0; g_combos[i].d2[3]=242.8;
   g_combos[i].d3[0]=476.0; g_combos[i].d3[1]=615.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=15; g_combos[i].nt[1]=8; g_combos[i].nt[2]=15; g_combos[i].nt[3]=9;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=2; g_combos[i].nok[2]=2; g_combos[i].nok[3]=5;
   i++;

   // HS4SH | ZH/SELL | n_ang=15 | Very Weak | score=19.4
   g_combos[i].code="HS4SH"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=19.36;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=35.71; g_combos[i].p1[1]=10.00; g_combos[i].p1[2]=13.33; g_combos[i].p1[3]=30.00;
   g_combos[i].p2[0]=80.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=80.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=156.8; g_combos[i].d1[1]=201.0; g_combos[i].d1[2]=33.5; g_combos[i].d1[3]=311.3;
   g_combos[i].d2[0]=292.2; g_combos[i].d2[1]=203.0; g_combos[i].d2[2]=33.5; g_combos[i].d2[3]=311.3;
   g_combos[i].d3[0]=315.8; g_combos[i].d3[1]=656.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=14; g_combos[i].nt[1]=10; g_combos[i].nt[2]=15; g_combos[i].nt[3]=10;
   g_combos[i].nok[0]=5; g_combos[i].nok[1]=1; g_combos[i].nok[2]=2; g_combos[i].nok[3]=3;
   i++;

   // OS4MO | ZO/SELL | n_ang=22 | Very Weak | score=18.8
   g_combos[i].code="OS4MO"; g_combos[i].cls="ZO"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=22; g_combos[i].tier=5; g_combos[i].signal_score=18.76;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=18.75; g_combos[i].p1[1]=22.22; g_combos[i].p1[2]=6.25; g_combos[i].p1[3]=11.11;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=502.3; g_combos[i].d1[1]=384.0; g_combos[i].d1[2]=220.0; g_combos[i].d1[3]=262.0;
   g_combos[i].d2[0]=475.0; g_combos[i].d2[1]=277.0; g_combos[i].d2[2]=225.0; g_combos[i].d2[3]=262.0;
   g_combos[i].d3[0]=476.0; g_combos[i].d3[1]=286.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=16; g_combos[i].nt[1]=18; g_combos[i].nt[2]=16; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=4; g_combos[i].nok[2]=1; g_combos[i].nok[3]=2;
   i++;

   // ES1LG | ZE/SELL | n_ang=21 | Very Weak | score=18.3
   g_combos[i].code="ES1LG"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=21; g_combos[i].tier=5; g_combos[i].signal_score=18.33;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=16.67; g_combos[i].p1[1]=18.18; g_combos[i].p1[2]=16.67; g_combos[i].p1[3]=26.67;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=66.67; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=301.3; g_combos[i].d1[1]=420.5; g_combos[i].d1[2]=494.0; g_combos[i].d1[3]=419.0;
   g_combos[i].d2[0]=122.0; g_combos[i].d2[1]=920.0; g_combos[i].d2[2]=544.0; g_combos[i].d2[3]=419.0;
   g_combos[i].d3[0]=245.0; g_combos[i].d3[1]=920.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=18; g_combos[i].nt[1]=11; g_combos[i].nt[2]=18; g_combos[i].nt[3]=15;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=2; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // CS1LD | ZC/SELL | n_ang=19 | Very Weak | score=17.4
   g_combos[i].code="CS1LD"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=19; g_combos[i].tier=5; g_combos[i].signal_score=17.44;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=30.77; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=28.57; g_combos[i].p1[3]=22.22;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=217.2; g_combos[i].d1[1]=278.8; g_combos[i].d1[2]=403.5; g_combos[i].d1[3]=559.8;
   g_combos[i].d2[0]=235.0; g_combos[i].d2[1]=511.5; g_combos[i].d2[2]=471.5; g_combos[i].d2[3]=559.8;
   g_combos[i].d3[0]=307.8; g_combos[i].d3[1]=511.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=14; g_combos[i].nt[2]=14; g_combos[i].nt[3]=18;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=4; g_combos[i].nok[2]=4; g_combos[i].nok[3]=4;
   i++;

   // CS1LO | ZC/SELL | n_ang=18 | Very Weak | score=17.0
   g_combos[i].code="CS1LO"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=18; g_combos[i].tier=5; g_combos[i].signal_score=16.97;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=9.09; g_combos[i].p1[1]=28.57; g_combos[i].p1[2]=18.18; g_combos[i].p1[3]=12.50;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=66.0; g_combos[i].d1[1]=406.2; g_combos[i].d1[2]=547.5; g_combos[i].d1[3]=710.5;
   g_combos[i].d2[0]=287.0; g_combos[i].d2[1]=571.0; g_combos[i].d2[2]=612.0; g_combos[i].d2[3]=710.5;
   g_combos[i].d3[0]=300.0; g_combos[i].d3[1]=571.8; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=14; g_combos[i].nt[2]=11; g_combos[i].nt[3]=16;
   g_combos[i].nok[0]=1; g_combos[i].nok[1]=4; g_combos[i].nok[2]=2; g_combos[i].nok[3]=2;
   i++;

   // ES1MD | ZE/SELL | n_ang=17 | Very Weak | score=16.5
   g_combos[i].code="ES1MD"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=17; g_combos[i].tier=5; g_combos[i].signal_score=16.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=2; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=36.36; g_combos[i].p1[1]=44.44; g_combos[i].p1[2]=33.33; g_combos[i].p1[3]=23.08;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=50.00; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=75.00; g_combos[i].p3[1]=50.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=193.5; g_combos[i].d1[1]=351.0; g_combos[i].d1[2]=293.2; g_combos[i].d1[3]=177.3;
   g_combos[i].d2[0]=236.2; g_combos[i].d2[1]=593.5; g_combos[i].d2[2]=325.5; g_combos[i].d2[3]=177.3;
   g_combos[i].d3[0]=335.3; g_combos[i].d3[1]=688.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=11; g_combos[i].nt[1]=9; g_combos[i].nt[2]=12; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=4; g_combos[i].nok[2]=4; g_combos[i].nok[3]=3;
   i++;

   // CS1LG | ZC/SELL | n_ang=16 | Very Weak | score=16.0
   g_combos[i].code="CS1LG"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=16.00;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=33.33; g_combos[i].p1[1]=18.18; g_combos[i].p1[2]=25.00; g_combos[i].p1[3]=15.38;
   g_combos[i].p2[0]=75.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=200.2; g_combos[i].d1[1]=731.0; g_combos[i].d1[2]=247.3; g_combos[i].d1[3]=182.5;
   g_combos[i].d2[0]=213.3; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=329.0; g_combos[i].d2[3]=182.5;
   g_combos[i].d3[0]=288.5; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=12; g_combos[i].nt[1]=11; g_combos[i].nt[2]=12; g_combos[i].nt[3]=13;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=2; g_combos[i].nok[2]=3; g_combos[i].nok[3]=2;
   i++;

   // HS4MD | ZH/SELL | n_ang=16 | Very Weak | score=16.0
   g_combos[i].code="HS4MD"; g_combos[i].cls="ZH"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=16.00;
   g_combos[i].test_rank[0]=4; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=15.38; g_combos[i].p1[1]=36.36; g_combos[i].p1[2]=23.08; g_combos[i].p1[3]=36.36;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=75.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=75.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=268.5; g_combos[i].d1[1]=256.8; g_combos[i].d1[2]=289.0; g_combos[i].d1[3]=339.2;
   g_combos[i].d2[0]=533.0; g_combos[i].d2[1]=321.3; g_combos[i].d2[2]=297.0; g_combos[i].d2[3]=339.2;
   g_combos[i].d3[0]=533.0; g_combos[i].d3[1]=395.7; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=11; g_combos[i].nt[2]=13; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=2; g_combos[i].nok[1]=4; g_combos[i].nok[2]=3; g_combos[i].nok[3]=4;
   i++;

   // ES3SB | ZE/SELL | n_ang=15 | Very Weak | score=15.5
   g_combos[i].code="ES3SB"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=15.49;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=2;
   g_combos[i].p1[0]=40.00; g_combos[i].p1[1]=14.29; g_combos[i].p1[2]=16.67; g_combos[i].p1[3]=36.36;
   g_combos[i].p2[0]=50.00; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=50.00; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=283.2; g_combos[i].d1[1]=188.0; g_combos[i].d1[2]=144.0; g_combos[i].d1[3]=377.8;
   g_combos[i].d2[0]=495.5; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=312.5; g_combos[i].d2[3]=377.8;
   g_combos[i].d3[0]=544.0; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=10; g_combos[i].nt[1]=7; g_combos[i].nt[2]=12; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=4; g_combos[i].nok[1]=1; g_combos[i].nok[2]=2; g_combos[i].nok[3]=4;
   i++;

   // GS4MO | ZG/SELL | n_ang=15 | Very Weak | score=15.5
   g_combos[i].code="GS4MO"; g_combos[i].cls="ZG"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=15.49;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=3; g_combos[i].test_rank[2]=4; g_combos[i].test_rank[3]=1;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=27.27; g_combos[i].p1[2]=0.00; g_combos[i].p1[3]=36.36;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=66.67; g_combos[i].p2[2]=0.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=66.67; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=342.7; g_combos[i].d1[1]=489.7; g_combos[i].d1[2]=0.0; g_combos[i].d1[3]=453.2;
   g_combos[i].d2[0]=489.3; g_combos[i].d2[1]=496.0; g_combos[i].d2[2]=0.0; g_combos[i].d2[3]=453.2;
   g_combos[i].d3[0]=518.3; g_combos[i].d3[1]=505.5; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=11; g_combos[i].nt[2]=14; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=3; g_combos[i].nok[2]=0; g_combos[i].nok[3]=4;
   i++;

   // ES1LC | ZE/SELL | n_ang=16 | Very Weak | score=12.0
   g_combos[i].code="ES1LC"; g_combos[i].cls="ZE"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=16; g_combos[i].tier=5; g_combos[i].signal_score=12.00;
   g_combos[i].test_rank[0]=2; g_combos[i].test_rank[1]=1; g_combos[i].test_rank[2]=3; g_combos[i].test_rank[3]=4;
   g_combos[i].p1[0]=10.00; g_combos[i].p1[1]=30.00; g_combos[i].p1[2]=10.00; g_combos[i].p1[3]=7.14;
   g_combos[i].p2[0]=100.00; g_combos[i].p2[1]=100.00; g_combos[i].p2[2]=100.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=100.00; g_combos[i].p3[1]=100.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=186.0; g_combos[i].d1[1]=586.7; g_combos[i].d1[2]=206.0; g_combos[i].d1[3]=65.0;
   g_combos[i].d2[0]=206.0; g_combos[i].d2[1]=846.0; g_combos[i].d2[2]=966.0; g_combos[i].d2[3]=65.0;
   g_combos[i].d3[0]=966.0; g_combos[i].d3[1]=846.3; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=10; g_combos[i].nt[1]=10; g_combos[i].nt[2]=10; g_combos[i].nt[3]=14;
   g_combos[i].nok[0]=1; g_combos[i].nok[1]=3; g_combos[i].nok[2]=1; g_combos[i].nok[3]=1;
   i++;

   // CS2LE | ZC/SELL | n_ang=15 | Very Weak | score=11.6
   g_combos[i].code="CS2LE"; g_combos[i].cls="ZC"; g_combos[i].dir="SELL";
   g_combos[i].n_ang=15; g_combos[i].tier=5; g_combos[i].signal_score=11.62;
   g_combos[i].test_rank[0]=1; g_combos[i].test_rank[1]=4; g_combos[i].test_rank[2]=2; g_combos[i].test_rank[3]=3;
   g_combos[i].p1[0]=23.08; g_combos[i].p1[1]=0.00; g_combos[i].p1[2]=15.38; g_combos[i].p1[3]=9.09;
   g_combos[i].p2[0]=66.67; g_combos[i].p2[1]=0.00; g_combos[i].p2[2]=50.00; g_combos[i].p2[3]=100.00;
   g_combos[i].p3[0]=33.33; g_combos[i].p3[1]=0.00; g_combos[i].p3[2]=0.00; g_combos[i].p3[3]=0.00;
   g_combos[i].d1[0]=160.7; g_combos[i].d1[1]=0.0; g_combos[i].d1[2]=761.5; g_combos[i].d1[3]=972.0;
   g_combos[i].d2[0]=465.0; g_combos[i].d2[1]=0.0; g_combos[i].d2[2]=577.0; g_combos[i].d2[3]=972.0;
   g_combos[i].d3[0]=577.0; g_combos[i].d3[1]=0.0; g_combos[i].d3[2]=0.0; g_combos[i].d3[3]=0.0;
   g_combos[i].nt[0]=13; g_combos[i].nt[1]=8; g_combos[i].nt[2]=13; g_combos[i].nt[3]=11;
   g_combos[i].nok[0]=3; g_combos[i].nok[1]=0; g_combos[i].nok[2]=2; g_combos[i].nok[3]=1;
   i++;

   g_combos_init = true;
}

//──────────────────────────────────────────────────────────────
// ComboCode() — build 5-char code from angle parameters
//   ratio_pct : U1/U2 ratio %  (e.g. 125.0)
//   L_u1_pct  : L/U1 ratio %   (e.g. 55.3)
//   prev_ltr  : single letter of prev angle class (e.g. "B"), or "X"
//──────────────────────────────────────────────────────────────
string ComboCode(string cls, string dir,
                 double ratio_pct, double L_u1_pct, string prev_ltr)
{
   string c = StringSubstr(cls, 1, 1);
   string d = (dir=="BUY") ? "B" : "S";
   string r;
   if(ratio_pct > 140)        r = "4";
   else if(ratio_pct >= 100)  r = "3";
   else if(ratio_pct >= 60)   r = "2";
   else                       r = "1";
   string l;
   if(L_u1_pct <= COMBO_P33)       l = "S";
   else if(L_u1_pct <= COMBO_P67)  l = "M";
   else                             l = "L";
   string p = (prev_ltr=="" || prev_ltr=="X" || StringLen(prev_ltr)==0) ? "X" : prev_ltr;
   return c+d+r+l+p;
}

//──────────────────────────────────────────────────────────────
// ComboFind() — linear search, returns index or -1
//──────────────────────────────────────────────────────────────
int ComboFind(string code)
{
   if(!g_combos_init) ComboTable_Init();
   for(int i = 0; i < COMBO_COUNT; i++)
      if(g_combos[i].code == code) return i;
   return -1;
}

// Test name → array index
int ComboTestIdx(string tp)
{
   if(tp=="U1X1") return 0;
   if(tp=="U2X1") return 1;
   if(tp=="DLX1") return 2;
   if(tp=="DRX1") return 3;
   return -1;
}