/**
 * @file
 * Implements Oscillator Conditions meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_OSCILLATOR_CONDITIONS_MQH
#define STG_META_OSCILLATOR_CONDITIONS_MQH

// Oscillator conditions.
enum ENUM_STG_META_OSCILLATOR_CONDITIONS_COND {
  STG_META_OSCILLATOR_CONDITIONS_COND_0_NONE = 0,                    // None
  STG_META_OSCILLATOR_CONDITIONS_COND_IS_PEAK = TRADE_COND_IS_PEAK,  // Oscillator value is at peak level
};

enum ENUM_STG_META_OSCILLATOR_CONDITIONS_TYPE {
  STG_META_OSCILLATOR_CONDITIONS_TYPE_0_NONE = 0,  // (None)
  STG_META_OSCILLATOR_CONDITIONS_TYPE_AC,          // AC: Accelerator/Decelerator
  STG_META_OSCILLATOR_CONDITIONS_TYPE_AD,          // AD: Accumulation/Distribution
  STG_META_OSCILLATOR_CONDITIONS_TYPE_AO,          // AO: Awesome
  STG_META_OSCILLATOR_CONDITIONS_TYPE_ATR,         // ATR
  STG_META_OSCILLATOR_CONDITIONS_TYPE_BEARS,       // Bears Power
  STG_META_OSCILLATOR_CONDITIONS_TYPE_BULLS,       // Bulls Power
  STG_META_OSCILLATOR_CONDITIONS_TYPE_BWMFI,       // BWMFI
  STG_META_OSCILLATOR_CONDITIONS_TYPE_CCI,         // CCI
  STG_META_OSCILLATOR_CONDITIONS_TYPE_CHO,         // CHO: Chaikin
  STG_META_OSCILLATOR_CONDITIONS_TYPE_CHV,         // CHV: Chaikin Volatility
  STG_META_OSCILLATOR_CONDITIONS_TYPE_DEMARKER,    // DeMarker
  STG_META_OSCILLATOR_CONDITIONS_TYPE_MFI,         // MFI
  STG_META_OSCILLATOR_CONDITIONS_TYPE_MOM,         // MOM: Momentum
  STG_META_OSCILLATOR_CONDITIONS_TYPE_OBV,         // OBV: On Balance Volume
  STG_META_OSCILLATOR_CONDITIONS_TYPE_PVT,         // PVT: Price and Volume Trend
  STG_META_OSCILLATOR_CONDITIONS_TYPE_ROC,         // ROC: Rate of Change
  STG_META_OSCILLATOR_CONDITIONS_TYPE_RSI,         // RSI
  STG_META_OSCILLATOR_CONDITIONS_TYPE_STDDEV,      // StdDev: Standard Deviation
  STG_META_OSCILLATOR_CONDITIONS_TYPE_STOCH,       // Stochastic
  STG_META_OSCILLATOR_CONDITIONS_TYPE_TRIX,        // TRIX: Triple Exponential Average
  STG_META_OSCILLATOR_CONDITIONS_TYPE_UO,          // UO: Ultimate Oscillator
  STG_META_OSCILLATOR_CONDITIONS_TYPE_WAD,         // WAD: Larry Williams' Accumulation/Distribution
  STG_META_OSCILLATOR_CONDITIONS_TYPE_WPR,         // WPR
  STG_META_OSCILLATOR_CONDITIONS_TYPE_VOL,         // VOL: Volumes
};

// User input params.
INPUT2_GROUP("Meta Oscillator Conditions strategy: main params");
INPUT2 ENUM_STG_META_OSCILLATOR_CONDITIONS_COND Meta_Oscillator_Conditions_Condition =
    STG_META_OSCILLATOR_CONDITIONS_COND_IS_PEAK;  // Oscillator condition
INPUT2 ENUM_STRATEGY Meta_Oscillator_Conditions_Strategy_False =
    STRAT_OSCILLATOR_RANGE;                                                 // Strategy when condition is False
INPUT2 ENUM_STRATEGY Meta_Oscillator_Conditions_Strategy_True = STRAT_CCI;  // Strategy when condition is True
INPUT2 ENUM_STG_META_OSCILLATOR_CONDITIONS_TYPE Meta_Oscillator_Conditions_Type =
    STG_META_OSCILLATOR_CONDITIONS_TYPE_ATR;                       // Oscillator type
INPUT2 ENUM_TIMEFRAMES Meta_Oscillator_Conditions_Tf = PERIOD_D1;  // Timeframe for oscillator
INPUT3_GROUP("Meta Oscillator Conditions strategy: common params");
INPUT3 float Meta_Oscillator_Conditions_LotSize = 0;                    // Lot size
INPUT3 int Meta_Oscillator_Conditions_SignalOpenMethod = 0;             // Signal open method
INPUT3 float Meta_Oscillator_Conditions_SignalOpenLevel = 0;            // Signal open level
INPUT3 int Meta_Oscillator_Conditions_SignalOpenConditionsMethod = 32;  // Signal open filter method
INPUT3 int Meta_Oscillator_Conditions_SignalOpenConditionsTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Oscillator_Conditions_SignalOpenBoostMethod = 0;        // Signal open boost method
INPUT3 int Meta_Oscillator_Conditions_SignalCloseMethod = 0;            // Signal close method
INPUT3 int Meta_Oscillator_Conditions_SignalCloseConditions = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Oscillator_Conditions_SignalCloseLevel = 0;           // Signal close level
INPUT3 int Meta_Oscillator_Conditions_PriceStopMethod = 0;              // Price limit method
INPUT3 float Meta_Oscillator_Conditions_PriceStopLevel = 2;             // Price limit level
INPUT3 int Meta_Oscillator_Conditions_TickConditionsMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Oscillator_Conditions_MaxSpread = 4.0;                // Max spread to trade (in pips)
INPUT3 short Meta_Oscillator_Conditions_Shift = 0;                      // Shift
INPUT3 float Meta_Oscillator_Conditions_OrderCloseLoss = 200;           // Order close loss
INPUT3 float Meta_Oscillator_Conditions_OrderCloseProfit = 200;         // Order close profit
INPUT3 int Meta_Oscillator_Conditions_OrderCloseTime = 2880;            // Order close time in mins (>0) or bars (<0)
INPUT3_GROUP("Meta Oscillator Conditions strategy: AC oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_AC_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_AC_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: AD oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_AD_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_AD_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: ATR oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_ATR_Period = 13;                                    // Period
INPUT3 int Meta_Oscillator_Conditions_Indi_ATR_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_ATR_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Awesome oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_Awesome_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_Awesome_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: BearsPower oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_BearsPower_Period = 30;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_BearsPower_Applied_Price = PRICE_CLOSE;     // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_BearsPower_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_BearsPower_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: BullsPower oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_BullsPower_Period = 30;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_BullsPower_Applied_Price = PRICE_CLOSE;     // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_BullsPower_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_BullsPower_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: BWMFI oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_BWMFI_Shift = 1;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_BWMFI_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: CCI oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_CCI_Period = 20;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_CCI_Applied_Price = PRICE_TYPICAL;   // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_CCI_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_CCI_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Chaikin oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_CHO_InpFastMA = 10;                                 // Fast EMA period
INPUT3 int Meta_Oscillator_Conditions_Indi_CHO_InpSlowMA = 30;                                 // Slow MA period
INPUT3 ENUM_MA_METHOD Meta_Oscillator_Conditions_Indi_CHO_InpSmoothMethod = MODE_SMMA;         // MA method
INPUT3 ENUM_APPLIED_VOLUME Meta_Oscillator_Conditions_Indi_CHO_InpVolumeType = VOLUME_TICK;    // Volumes
INPUT3 int Meta_Oscillator_Conditions_Indi_CHO_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_CHO_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Chaikin Volatility oscillator params");
INPUT3 unsigned int Meta_Oscillator_Conditions_Indi_CHV_Smooth_Period;                         // Smooth period
INPUT3 unsigned int Meta_Oscillator_Conditions_Indi_CHV_Period;                                // Period
INPUT3 ENUM_CHV_SMOOTH_METHOD Meta_Oscillator_Conditions_Indi_CHV_Smooth_Method;               // Smooth method
INPUT3 int Meta_Oscillator_Conditions_Indi_CHV_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_CHV_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: DeMarker indicator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_DeMarker_Period = 23;                                    // Period
INPUT3 int Meta_Oscillator_Conditions_Indi_DeMarker_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_DeMarker_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: MFI oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_MFI_MA_Period = 22;  // MA Period
INPUT3 ENUM_APPLIED_VOLUME Meta_Oscillator_Conditions_Indi_MFI_Applied_Volume =
    (ENUM_APPLIED_VOLUME)0;                                                                    // Applied volume.
INPUT3 int Meta_Oscillator_Conditions_Indi_MFI_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_MFI_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Momentum oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_Momentum_Period = 12;                                    // Averaging period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_Momentum_Applied_Price = PRICE_CLOSE;     // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_Momentum_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_Momentum_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: OBV oscillator params");
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_OBV_Applied_Price = PRICE_CLOSE;     // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_OBV_Shift = 1;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_OBV_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: PVT oscillator params");
INPUT3 ENUM_APPLIED_VOLUME Meta_Oscillator_Conditions_Indi_PVT_InpVolumeType = VOLUME_TICK;    // Volumes
INPUT3 int Meta_Oscillator_Conditions_Indi_PVT_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_PVT_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: ROC oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_ROC_Period = 16;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_ROC_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_ROC_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_ROC_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: RSI oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_RSI_Period = 16;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_RSI_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_RSI_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_RSI_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: StdDev oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_StdDev_MA_Period = 24;                                 // Period
INPUT3 int Meta_Oscillator_Conditions_Indi_StdDev_MA_Shift = 0;                                   // MA Shift
INPUT3 ENUM_MA_METHOD Meta_Oscillator_Conditions_Indi_StdDev_MA_Method = (ENUM_MA_METHOD)3;       // MA Method
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_StdDev_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_StdDev_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_StdDev_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Stochastic oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_Stochastic_KPeriod = 8;                      // K line period
INPUT3 int Meta_Oscillator_Conditions_Indi_Stochastic_DPeriod = 12;                     // D line period
INPUT3 int Meta_Oscillator_Conditions_Indi_Stochastic_Slowing = 12;                     // Slowing
INPUT3 ENUM_MA_METHOD Meta_Oscillator_Conditions_Indi_Stochastic_MA_Method = MODE_EMA;  // Moving Average method
INPUT3 ENUM_STO_PRICE Meta_Oscillator_Conditions_Indi_Stochastic_Price_Field =
    0;                                                            // Price (0 - Low/High or 1 - Close/Close)
INPUT3 int Meta_Oscillator_Conditions_Indi_Stochastic_Shift = 0;  // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_Stochastic_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: TRIX oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_TRIX_InpPeriodEMA = 14;                              // EMA period
INPUT3 ENUM_APPLIED_PRICE Meta_Oscillator_Conditions_Indi_TRIX_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_Oscillator_Conditions_Indi_TRIX_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_TRIX_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Ultimate oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpFastPeriod = 7;                              // Fast ATR period
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpMiddlePeriod = 14;                           // Middle ATR period
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpSlowPeriod = 28;                             // Slow ATR period
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpFastK = 4;                                   // Fast K
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpMiddleK = 2;                                 // Middle K
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_InpSlowK = 1;                                   // Slow K
INPUT3 int Meta_Oscillator_Conditions_Indi_UO_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_UO_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Williams' Accumulation/Distribution oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_WAD_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_WAD_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: WPR oscillator params");
INPUT3 int Meta_Oscillator_Conditions_Indi_WPR_Period = 18;                                    // Period
INPUT3 int Meta_Oscillator_Conditions_Indi_WPR_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_WPR_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Oscillator Conditions strategy: Volumes oscillator params");
INPUT3 ENUM_APPLIED_VOLUME Meta_Oscillator_Conditions_Indi_VOL_InpVolumeType = VOLUME_TICK;    // Volumes
INPUT3 int Meta_Oscillator_Conditions_Indi_VOL_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Oscillator_Conditions_Indi_VOL_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Oscillator_Conditions_Params_Defaults : StgParams {
  Stg_Meta_Oscillator_Conditions_Params_Defaults()
      : StgParams(::Meta_Oscillator_Conditions_SignalOpenMethod,
                  ::Meta_Oscillator_Conditions_SignalOpenConditionsMethod, ::Meta_Oscillator_Conditions_SignalOpenLevel,
                  ::Meta_Oscillator_Conditions_SignalOpenBoostMethod, ::Meta_Oscillator_Conditions_SignalCloseMethod,
                  ::Meta_Oscillator_Conditions_SignalCloseConditions, ::Meta_Oscillator_Conditions_SignalCloseLevel,
                  ::Meta_Oscillator_Conditions_PriceStopMethod, ::Meta_Oscillator_Conditions_PriceStopLevel,
                  ::Meta_Oscillator_Conditions_TickConditionsMethod, ::Meta_Oscillator_Conditions_MaxSpread,
                  ::Meta_Oscillator_Conditions_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Oscillator_Conditions_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Oscillator_Conditions_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Oscillator_Conditions_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Oscillator_Conditions_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Oscillator_Conditions_SignalOpenConditionsTime);
  }
};

class Stg_Meta_Oscillator_Conditions : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Oscillator_Conditions(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Oscillator_Conditions *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Oscillator_Conditions_Params_Defaults stg_meta_oscillator_conditions_defaults;
    StgParams _stg_params(stg_meta_oscillator_conditions_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat =
        new Stg_Meta_Oscillator_Conditions(_stg_params, _tparams, _cparams, "(Meta) Oscillator Conditions");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(::Meta_Oscillator_Conditions_Strategy_False, 0);
    StrategyAdd(::Meta_Oscillator_Conditions_Strategy_True, 1);
    // Initialize indicators.
    switch (::Meta_Oscillator_Conditions_Type) {
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_AC:  // AC
      {
        IndiACParams _indi_params(::Meta_Oscillator_Conditions_Indi_AC_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_AC_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_AC(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_AD:  // AD
      {
        IndiADParams _indi_params(::Meta_Oscillator_Conditions_Indi_AD_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_AD_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_AD(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_AO:  // AO
      {
        IndiAOParams _indi_params(::Meta_Oscillator_Conditions_Indi_Awesome_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_Awesome_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_AO(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_ATR:  // ATR
      {
        IndiATRParams _indi_params(::Meta_Oscillator_Conditions_Indi_ATR_Period,
                                   ::Meta_Oscillator_Conditions_Indi_ATR_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_ATR_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_ATR(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_BEARS:  // Bears
      {
        IndiBearsPowerParams _indi_params(::Meta_Oscillator_Conditions_Indi_BearsPower_Period,
                                          ::Meta_Oscillator_Conditions_Indi_BearsPower_Applied_Price,
                                          ::Meta_Oscillator_Conditions_Indi_BearsPower_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_BearsPower_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_BearsPower(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_BULLS:  // Bulls
      {
        IndiBullsPowerParams _indi_params(::Meta_Oscillator_Conditions_Indi_BullsPower_Period,
                                          ::Meta_Oscillator_Conditions_Indi_BullsPower_Applied_Price,
                                          ::Meta_Oscillator_Conditions_Indi_BullsPower_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_BullsPower_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_BullsPower(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_BWMFI:  // BWMFI
      {
        IndiBWIndiMFIParams _indi_params(::Meta_Oscillator_Conditions_Indi_BWMFI_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_BWMFI_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_BWMFI(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_CCI:  // CCI
      {
        IndiCCIParams _indi_params(::Meta_Oscillator_Conditions_Indi_CCI_Period,
                                   ::Meta_Oscillator_Conditions_Indi_CCI_Applied_Price,
                                   ::Meta_Oscillator_Conditions_Indi_CCI_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_CCI_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_CCI(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_CHO:  // Chaikin (CHO)
      {
        IndiCHOParams _indi_params(
            ::Meta_Oscillator_Conditions_Indi_CHO_InpFastMA, ::Meta_Oscillator_Conditions_Indi_CHO_InpSlowMA,
            ::Meta_Oscillator_Conditions_Indi_CHO_InpSmoothMethod, ::Meta_Oscillator_Conditions_Indi_CHO_InpVolumeType,
            ::Meta_Oscillator_Conditions_Indi_CHO_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_CHO_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_CHO(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_CHV:  // Chaikin Volatility (CHV)
      {
        IndiCHVParams _indi_params(
            ::Meta_Oscillator_Conditions_Indi_CHV_Smooth_Period, ::Meta_Oscillator_Conditions_Indi_CHV_Period,
            ::Meta_Oscillator_Conditions_Indi_CHV_Smooth_Method, ::Meta_Oscillator_Conditions_Indi_CHV_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_CHV_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_CHV(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_DEMARKER:  // DeMarker
      {
        IndiDeMarkerParams _indi_params(::Meta_Oscillator_Conditions_Indi_DeMarker_Period,
                                        ::Meta_Oscillator_Conditions_Indi_DeMarker_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_DeMarker_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_DeMarker(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_MFI:  // MFI
      {
        IndiMFIParams _indi_params(::Meta_Oscillator_Conditions_Indi_MFI_MA_Period,
                                   ::Meta_Oscillator_Conditions_Indi_MFI_Applied_Volume,
                                   ::Meta_Oscillator_Conditions_Indi_MFI_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_MFI_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_MFI(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_MOM:  // MOM
      {
        IndiMomentumParams _indi_params(::Meta_Oscillator_Conditions_Indi_Momentum_Period,
                                        ::Meta_Oscillator_Conditions_Indi_Momentum_Applied_Price,
                                        ::Meta_Oscillator_Conditions_Indi_Momentum_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_Momentum_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_Momentum(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_OBV:  // OBV
      {
        IndiOBVParams _indi_params(::Meta_Oscillator_Conditions_Indi_OBV_Applied_Price,
                                   ::Meta_Oscillator_Conditions_Indi_OBV_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_OBV_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_OBV(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_PVT:  // PVT
      {
        IndiPriceVolumeTrendParams _indi_params(::Meta_Oscillator_Conditions_Indi_PVT_InpVolumeType,
                                                ::Meta_Oscillator_Conditions_Indi_PVT_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_PVT_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_PriceVolumeTrend(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_ROC:  // ROC
      {
        IndiRateOfChangeParams _indi_params(::Meta_Oscillator_Conditions_Indi_ROC_Period,
                                            ::Meta_Oscillator_Conditions_Indi_ROC_Applied_Price,
                                            ::Meta_Oscillator_Conditions_Indi_ROC_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_ROC_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_RateOfChange(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_RSI:  // RSI
      {
        IndiRSIParams _indi_params(::Meta_Oscillator_Conditions_Indi_RSI_Period,
                                   ::Meta_Oscillator_Conditions_Indi_RSI_Applied_Price,
                                   ::Meta_Oscillator_Conditions_Indi_RSI_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_RSI_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_RSI(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_STDDEV:  // StdDev
      {
        IndiStdDevParams _indi_params(
            ::Meta_Oscillator_Conditions_Indi_StdDev_MA_Period, ::Meta_Oscillator_Conditions_Indi_StdDev_MA_Shift,
            ::Meta_Oscillator_Conditions_Indi_StdDev_MA_Method, ::Meta_Oscillator_Conditions_Indi_StdDev_Applied_Price,
            ::Meta_Oscillator_Conditions_Indi_StdDev_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_StdDev_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_StdDev(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_STOCH:  // Stochastic
      {
        IndiStochParams _indi_params(::Meta_Oscillator_Conditions_Indi_Stochastic_KPeriod,
                                     ::Meta_Oscillator_Conditions_Indi_Stochastic_DPeriod,
                                     ::Meta_Oscillator_Conditions_Indi_Stochastic_Slowing,
                                     ::Meta_Oscillator_Conditions_Indi_Stochastic_MA_Method,
                                     ::Meta_Oscillator_Conditions_Indi_Stochastic_Price_Field,
                                     ::Meta_Oscillator_Conditions_Indi_Stochastic_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_Stochastic_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_Stochastic(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_TRIX:  // TRIX
      {
        IndiTRIXParams _indi_params(::Meta_Oscillator_Conditions_Indi_TRIX_InpPeriodEMA,
                                    ::Meta_Oscillator_Conditions_Indi_TRIX_Applied_Price,
                                    ::Meta_Oscillator_Conditions_Indi_TRIX_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_TRIX_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_TRIX(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_UO:  // UO
      {
        IndiUltimateOscillatorParams _indi_params(
            ::Meta_Oscillator_Conditions_Indi_UO_InpFastPeriod, ::Meta_Oscillator_Conditions_Indi_UO_InpMiddlePeriod,
            ::Meta_Oscillator_Conditions_Indi_UO_InpSlowPeriod, ::Meta_Oscillator_Conditions_Indi_UO_InpFastK,
            ::Meta_Oscillator_Conditions_Indi_UO_InpMiddleK, ::Meta_Oscillator_Conditions_Indi_UO_InpSlowK,
            ::Meta_Oscillator_Conditions_Indi_UO_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_UO_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_UltimateOscillator(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_WAD:  // Williams' AD
      {
        IndiWilliamsADParams _indi_params(::Meta_Oscillator_Conditions_Indi_WAD_Shift);
        _indi_params.SetDataSourceType(Meta_Oscillator_Conditions_Indi_WAD_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_WilliamsAD(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_WPR:  // WPR
      {
        IndiWPRParams _indi_params(::Meta_Oscillator_Conditions_Indi_WPR_Period,
                                   ::Meta_Oscillator_Conditions_Indi_WPR_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_WPR_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_WPR(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_VOL:  // Volumes
      {
        IndiVolumesParams _indi_params(::Meta_Oscillator_Conditions_Indi_VOL_InpVolumeType,
                                       ::Meta_Oscillator_Conditions_Indi_VOL_Shift);
        _indi_params.SetDataSourceType(::Meta_Oscillator_Conditions_Indi_VOL_SourceType);
        _indi_params.SetTf(::Meta_Oscillator_Conditions_Tf);
        SetIndicator(new Indi_Volumes(_indi_params), ::Meta_Oscillator_Conditions_Type);
        break;
      }
      case STG_META_OSCILLATOR_CONDITIONS_TYPE_0_NONE:  // (None)
      default:
        break;
    }
  }

  /**
   * Sets strategy.
   */
  bool StrategyAdd(ENUM_STRATEGY _sid, long _index = -1) {
    ENUM_TIMEFRAMES _tf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);
    Ref<Strategy> _strat = StrategiesManager::StrategyInitByEnum(_sid, _tf);
#ifdef __strategies_meta__
    if (!_strat.IsSet()) {
      _strat = StrategiesMetaManager::StrategyInitByEnum((ENUM_STRATEGY_META)_sid, _tf);
    }
#endif
    if (_strat.IsSet()) {
      _strat.Ptr().Set<long>(STRAT_PARAM_ID, Get<long>(STRAT_PARAM_ID));
      _strat.Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
      _strat.Ptr().Set<int>(STRAT_PARAM_TYPE, _sid);
      _strat.Ptr().OnInit();
      if (_index >= 0) {
        strats.Set(_index, _strat);
      } else {
        strats.Push(_strat);
      }
    }
    return _strat.IsSet();
  }

  /**
   * Returns the highest bar's index (shift).
   */
  template <typename T>
  int GetIndiHighest(int count = WHOLE_ARRAY, int start_bar = 0) {
    IndicatorBase *_indi = GetIndicator(::Meta_Oscillator_Conditions_Type);
    int max_idx = -1;
    double max = -DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(_indi.GetBarShift(_indi.GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = _indi.GetEntry(shift).GetMax<T>(_indi.GetModeCount());
      if (value > max) {
        max = value;
        max_idx = shift;
      }
    }

    return max_idx;
  }

  /**
   * Returns the lowest bar's index (shift).
   */
  template <typename T>
  int GetIndiLowest(int count = WHOLE_ARRAY, int start_bar = 0) {
    IndicatorBase *_indi = GetIndicator(::Meta_Oscillator_Conditions_Type);
    int min_idx = -1;
    double min = DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(_indi.GetBarShift(_indi.GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = _indi.GetEntry(shift).GetMin<T>(_indi.GetModeCount());
      if (value < min) {
        min = value;
        min_idx = shift;
      }
    }

    return min_idx;
  }

  /**
   * Gets strategy.
   */
  Ref<Strategy> GetStrategy(uint _shift = 0) {
    IndicatorBase *_indi = GetIndicator(::Meta_Oscillator_Conditions_Type);
    Chart *_chart = (Chart *)_indi;
    uint _ishift = _shift;  // @fixme
    bool _result = true;
    // bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID,
    // _ishift + 1);
    Ref<Strategy> _strat_ref;
    switch (::Meta_Oscillator_Conditions_Condition) {
      case STG_META_OSCILLATOR_CONDITIONS_COND_IS_PEAK:
        _result &= _indi[_ishift][0] >= GetIndiHighest<double>(4, _ishift) ||
                   _indi[_ishift][0] <= GetIndiLowest<double>(4, _ishift);
        break;
      case STG_META_OSCILLATOR_CONDITIONS_COND_0_NONE:
      default:
        break;
    }
    _strat_ref = strats.GetByKey(_result ? 1 : 0);
    return _strat_ref;
  }

  /**
   * Gets price stop value.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    uint _ishift = 0;  // @fixme
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = GetStrategy(_ishift);  // @todo: Add shift.
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }

    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM);
    //_shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result = _strat_ref.Ptr().PriceStop(_cmd, _mode, _method, _level /*, _shift*/);
    return (float)_result;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = ::Meta_Oscillator_Conditions_Type !=
                   STG_META_OSCILLATOR_CONDITIONS_TYPE_0_NONE;  // && IsValidEntry(_indi, _shift);
    Ref<Strategy> _strat_ref = GetStrategy(_shift);
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = ::Meta_Oscillator_Conditions_Type !=
                   STG_META_OSCILLATOR_CONDITIONS_TYPE_0_NONE;  // && IsValidEntry(_indi, _shift);
    Ref<Strategy> _strat_ref = GetStrategy(_shift);
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_OSCILLATOR_CONDITIONS_MQH
