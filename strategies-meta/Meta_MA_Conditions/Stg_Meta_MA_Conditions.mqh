/**
 * @file
 * Implements MA Conditions meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_MA_CONDITIONS_MQH
#define STG_META_MA_CONDITIONS_MQH

// MA conditions.
enum ENUM_STG_META_MA_CONDITIONS_COND {
  STG_META_MA_CONDITIONS_COND_0_NONE = 0,      // None
  STG_META_MA_CONDITIONS_COND_IS_PEAK,         // MA value is at peak level
  STG_META_MA_CONDITIONS_COND_IN_PRICE_RANGE,  // MA value within price range
};

enum ENUM_STG_META_MA_CONDITIONS_TYPE {
  STG_META_MA_CONDITIONS_TYPE_0_NONE = 0,     // (None)
  STG_META_MA_CONDITIONS_TYPE_AMA,            // AMA: Adaptive Moving Average
  STG_META_MA_CONDITIONS_TYPE_DEMA,           // DEMA: Double Exponential Moving Average
  STG_META_MA_CONDITIONS_TYPE_FRAMA,          // FrAMA: Fractal Adaptive Moving Average
  STG_META_MA_CONDITIONS_TYPE_ICHIMOKU,       // Ichimoku
  STG_META_MA_CONDITIONS_TYPE_MA,             // MA: Moving Average
  STG_META_MA_CONDITIONS_TYPE_PRICE_CHANNEL,  // Price Channel
  STG_META_MA_CONDITIONS_TYPE_SAR,            // SAR: Parabolic Stop and Reverse
  STG_META_MA_CONDITIONS_TYPE_TEMA,           // TEMA: Triple Exponential Moving Average
  STG_META_MA_CONDITIONS_TYPE_VIDYA,          // VIDYA: Variable Index Dynamic Average
};

// User input params.
INPUT2_GROUP("Meta MA Conditions strategy: main params");
INPUT2 ENUM_STRATEGY Meta_MA_Conditions_Strategy_False = STRAT_RSI;     // Strategy when condition is False
INPUT2 ENUM_STRATEGY Meta_MA_Conditions_Strategy_True = STRAT_CHAIKIN;  // Strategy when condition is True
INPUT2 ENUM_STG_META_MA_CONDITIONS_COND Meta_MA_Conditions_Condition =
    STG_META_MA_CONDITIONS_COND_IN_PRICE_RANGE;  // MA condition
INPUT2 ENUM_STG_META_MA_CONDITIONS_TYPE Meta_MA_Conditions_Type =
    STG_META_MA_CONDITIONS_TYPE_DEMA;                      // Indicator MA type
INPUT2 ENUM_TIMEFRAMES Meta_MA_Conditions_Tf = PERIOD_D1;  // Timeframe for MA
INPUT3_GROUP("Meta MA Conditions strategy: common params");
INPUT3 float Meta_MA_Conditions_LotSize = 0;                // Lot size
INPUT3 int Meta_MA_Conditions_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_MA_Conditions_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_MA_Conditions_SignalOpenSwitchMethod = 32;  // Signal open filter method
INPUT3 int Meta_MA_Conditions_SignalOpenSwitchTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_MA_Conditions_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_MA_Conditions_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_MA_Conditions_SignalCloseSwitch = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_MA_Conditions_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_MA_Conditions_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_MA_Conditions_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_MA_Conditions_TickSwitchMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_MA_Conditions_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_MA_Conditions = 0;                        // Shift
INPUT3 float Meta_MA_Conditions_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_MA_Conditions_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_MA_Conditions_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT3_GROUP("Meta MA Conditions Shift strategy: AMA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_AMA_InpPeriodAMA = 20;                              // AMA period
INPUT3 int Meta_MA_Conditions_Indi_AMA_InpFastPeriodEMA = 4;                           // Fast EMA period
INPUT3 int Meta_MA_Conditions_Indi_AMA_InpSlowPeriodEMA = 30;                          // Slow EMA period
INPUT3 int Meta_MA_Conditions_Indi_AMA_InpShiftAMA = 4;                                // AMA shift
INPUT3 int Meta_MA_Conditions_Indi_AMA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_AMA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_AMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: DEMA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_DEMA_Period = 25;                                    // Period
INPUT3 int Meta_MA_Conditions_Indi_DEMA_MA_Shift = 6;                                   // MA Shift
INPUT3 ENUM_APPLIED_PRICE Meta_MA_Conditions_Indi_DEMA_Applied_Price = PRICE_TYPICAL;   // Applied Price
INPUT3 int Meta_MA_Conditions_Indi_DEMA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_DEMA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_DEMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: FrAMA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_FrAMA_Period = 10;                                    // Period
INPUT3 ENUM_APPLIED_PRICE Meta_MA_Conditions_Indi_FrAMA_Applied_Price = PRICE_MEDIAN;    // Applied Price
INPUT3 int Meta_MA_Conditions_Indi_FrAMA_MA_Shift = 0;                                   // MA Shift
INPUT3 int Meta_MA_Conditions_Indi_FrAMA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_FrAMA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_FrAMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: Ichimoku indicator params");
// INPUT3 ENUM_ICHIMOKU_LINE Meta_MA_Conditions_Indi_Ichimoku_MA_Line = LINE_TENKANSEN; // Ichimoku line for MA
INPUT3 int Meta_MA_Conditions_Indi_Ichimoku_Period_Tenkan_Sen = 30;                         // Period Tenkan Sen
INPUT3 int Meta_MA_Conditions_Indi_Ichimoku_Period_Kijun_Sen = 10;                          // Period Kijun Sen
INPUT3 int Meta_MA_Conditions_Indi_Ichimoku_Period_Senkou_Span_B = 30;                      // Period Senkou Span B
INPUT3 int Meta_MA_Conditions_Indi_Ichimoku_Shift = 1;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_Ichimoku_Shift2 = 1;                                     // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_Ichimoku_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: MA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_MA_Period = 26;                                    // Period
INPUT3 int Meta_MA_Conditions_Indi_MA_MA_Shift = 0;                                   // MA Shift
INPUT3 ENUM_MA_METHOD Meta_MA_Conditions_Indi_MA_Method = MODE_LWMA;                  // MA Method
INPUT3 ENUM_APPLIED_PRICE Meta_MA_Conditions_Indi_MA_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_MA_Conditions_Indi_MA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_MA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_MA_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: Price Channel indicator params");
INPUT3 int Meta_MA_Conditions_Indi_PriceChannel_Period = 26;                                    // Period
INPUT3 int Meta_MA_Conditions_Indi_PriceChannel_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_PriceChannel_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_PriceChannel_SourceType = IDATA_ICUSTOM;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: SAR indicator params");
INPUT3 float Meta_MA_Conditions_Indi_SAR_Step = 0.04f;                                 // Step
INPUT3 float Meta_MA_Conditions_Indi_SAR_Maximum_Stop = 0.4f;                          // Maximum stop
INPUT3 int Meta_MA_Conditions_Indi_SAR_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_SAR_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_SAR_SourceType = IDATA_ICUSTOM;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: TEMA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_TEMA_Period = 10;                                    // Period
INPUT3 int Meta_MA_Conditions_Indi_TEMA_MA_Shift = 0;                                   // MA Shift
INPUT3 ENUM_APPLIED_PRICE Meta_MA_Conditions_Indi_TEMA_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_MA_Conditions_Indi_TEMA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_TEMA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_TEMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta MA Conditions Shift strategy: VIDYA indicator params");
INPUT3 int Meta_MA_Conditions_Indi_VIDYA_Period = 30;                                    // Period
INPUT3 int Meta_MA_Conditions_Indi_VIDYA_MA_Period = 20;                                 // MA Period
INPUT3 int Meta_MA_Conditions_Indi_VIDYA_MA_Shift = 1;                                   // MA Shift
INPUT3 ENUM_APPLIED_PRICE Meta_MA_Conditions_Indi_VIDYA_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_MA_Conditions_Indi_VIDYA_Shift = 0;                                      // Shift
INPUT3 int Meta_MA_Conditions_Indi_VIDYA_Shift2 = 10;                                    // Shift 2
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_MA_Conditions_Indi_VIDYA_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_MA_Conditions_Params_Defaults : StgParams {
  uint shift1, shift2;
  Stg_Meta_MA_Conditions_Params_Defaults()
      : StgParams(::Meta_MA_Conditions_SignalOpenMethod, ::Meta_MA_Conditions_SignalOpenSwitchMethod,
                  ::Meta_MA_Conditions_SignalOpenLevel, ::Meta_MA_Conditions_SignalOpenBoostMethod,
                  ::Meta_MA_Conditions_SignalCloseMethod, ::Meta_MA_Conditions_SignalCloseSwitch,
                  ::Meta_MA_Conditions_SignalCloseLevel, ::Meta_MA_Conditions_PriceStopMethod,
                  ::Meta_MA_Conditions_PriceStopLevel, ::Meta_MA_Conditions_TickSwitchMethod,
                  ::Meta_MA_Conditions_MaxSpread, ::Meta_MA_Conditions) {
    Set(STRAT_PARAM_LS, ::Meta_MA_Conditions_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_MA_Conditions_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_MA_Conditions_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_MA_Conditions_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_MA_Conditions_SignalOpenSwitchTime);
  }
  // Getters.
  uint GetShift1() { return shift1; }
  uint GetShift2() { return shift2; }
  // Setters.
  void SetShift1(uint _value) { shift1 = _value; }
  void SetShift2(uint _value) { shift2 = _value; }
};

class Stg_Meta_MA_Conditions : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Stg_Meta_MA_Conditions_Params_Defaults ssparams;

 public:
  Stg_Meta_MA_Conditions(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_MA_Conditions *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_MA_Conditions_Params_Defaults stg_meta_ma_conditions_defaults;
    StgParams _stg_params(stg_meta_ma_conditions_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_MA_Conditions(_stg_params, _tparams, _cparams, "(Meta) MA Conditions");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(::Meta_MA_Conditions_Strategy_False, 0);
    StrategyAdd(::Meta_MA_Conditions_Strategy_True, 1);
    // Initialize indicators.
    switch (::Meta_MA_Conditions_Type) {
      case STG_META_MA_CONDITIONS_TYPE_AMA:  // AMA
      {
        IndiAMAParams _indi_params(
            ::Meta_MA_Conditions_Indi_AMA_InpPeriodAMA, ::Meta_MA_Conditions_Indi_AMA_InpFastPeriodEMA,
            ::Meta_MA_Conditions_Indi_AMA_InpSlowPeriodEMA, ::Meta_MA_Conditions_Indi_AMA_InpShiftAMA, PRICE_TYPICAL,
            ::Meta_MA_Conditions_Indi_AMA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_AMA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_AMA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_AMA_Shift2);
        SetIndicator(new Indi_AMA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_AMA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_AMA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_DEMA:  // DEMA
      {
        IndiDEIndiMAParams _indi_params(::Meta_MA_Conditions_Indi_DEMA_Period, ::Meta_MA_Conditions_Indi_DEMA_MA_Shift,
                                        ::Meta_MA_Conditions_Indi_DEMA_Applied_Price,
                                        ::Meta_MA_Conditions_Indi_DEMA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_DEMA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_DEMA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_DEMA_Shift2);
        SetIndicator(new Indi_DEMA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_DEMA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_DEMA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_FRAMA:  // FrAMA
      {
        IndiFrAIndiMAParams _indi_params(
            ::Meta_MA_Conditions_Indi_FrAMA_Period, ::Meta_MA_Conditions_Indi_FrAMA_MA_Shift,
            ::Meta_MA_Conditions_Indi_FrAMA_Applied_Price, ::Meta_MA_Conditions_Indi_FrAMA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_FrAMA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_FrAMA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_FrAMA_Shift2);
        SetIndicator(new Indi_FrAMA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_FrAMA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_FrAMA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_ICHIMOKU:  // Ichimoku
      {
        IndiIchimokuParams _indi_params(
            ::Meta_MA_Conditions_Indi_Ichimoku_Period_Tenkan_Sen, ::Meta_MA_Conditions_Indi_Ichimoku_Period_Kijun_Sen,
            ::Meta_MA_Conditions_Indi_Ichimoku_Period_Senkou_Span_B, ::Meta_MA_Conditions_Indi_Ichimoku_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_Ichimoku_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_Ichimoku(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_Ichimoku_Shift2);
        SetIndicator(new Indi_Ichimoku(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_Ichimoku_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_Ichimoku_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_MA:  // MA
      {
        IndiMAParams _indi_params(::Meta_MA_Conditions_Indi_MA_Period, ::Meta_MA_Conditions_Indi_MA_MA_Shift,
                                  ::Meta_MA_Conditions_Indi_MA_Method, ::Meta_MA_Conditions_Indi_MA_Applied_Price,
                                  ::Meta_MA_Conditions_Indi_MA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_MA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_MA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_MA_Shift2);
        SetIndicator(new Indi_MA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_MA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_MA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_PRICE_CHANNEL:  // Price Channel
      {
        IndiPriceChannelParams _indi_params(::Meta_MA_Conditions_Indi_PriceChannel_Period,
                                            ::Meta_MA_Conditions_Indi_PriceChannel_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_PriceChannel_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_PriceChannel(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_PriceChannel_Shift2);
        SetIndicator(new Indi_PriceChannel(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_PriceChannel_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_PriceChannel_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_SAR:  // SAR
      {
        IndiSARParams _indi_params(::Meta_MA_Conditions_Indi_SAR_Step, ::Meta_MA_Conditions_Indi_SAR_Maximum_Stop,
                                   ::Meta_MA_Conditions_Indi_SAR_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_SAR_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_SAR(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_SAR_Shift2);
        SetIndicator(new Indi_SAR(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_SAR_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_SAR_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_TEMA:  // TEMA
      {
        IndiTEMAParams _indi_params(::Meta_MA_Conditions_Indi_TEMA_Period, ::Meta_MA_Conditions_Indi_TEMA_MA_Shift,
                                    ::Meta_MA_Conditions_Indi_TEMA_Applied_Price, ::Meta_MA_Conditions_Indi_TEMA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_TEMA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_TEMA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_TEMA_Shift2);
        SetIndicator(new Indi_TEMA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_TEMA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_TEMA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_VIDYA:  // VIDYA
      {
        IndiVIDYAParams _indi_params(::Meta_MA_Conditions_Indi_VIDYA_Period, ::Meta_MA_Conditions_Indi_VIDYA_MA_Period,
                                     ::Meta_MA_Conditions_Indi_VIDYA_MA_Shift,
                                     ::Meta_MA_Conditions_Indi_VIDYA_Applied_Price,
                                     ::Meta_MA_Conditions_Indi_VIDYA_Shift);
        _indi_params.SetDataSourceType(::Meta_MA_Conditions_Indi_VIDYA_SourceType);
        _indi_params.SetTf(::Meta_MA_Conditions_Tf);
        SetIndicator(new Indi_VIDYA(_indi_params), ::Meta_MA_Conditions_Type);
        _indi_params.SetShift(::Meta_MA_Conditions_Indi_VIDYA_Shift2);
        SetIndicator(new Indi_VIDYA(_indi_params), ::Meta_MA_Conditions_Type + 1);
        ssparams.SetShift1(::Meta_MA_Conditions_Indi_VIDYA_Shift);
        ssparams.SetShift2(::Meta_MA_Conditions_Indi_VIDYA_Shift2);
        break;
      }
      case STG_META_MA_CONDITIONS_TYPE_0_NONE:  // (None)
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
    IndicatorBase *_indi = GetIndicator(::Meta_MA_Conditions_Type);
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
    IndicatorBase *_indi = GetIndicator(::Meta_MA_Conditions_Type);
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
    IndicatorBase *_indi = GetIndicator(::Meta_MA_Conditions_Type);
    Chart *_chart = (Chart *)_indi;
    uint _ishift = _shift;  // @fixme
    bool _result = true;
    // bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID,
    // _ishift + 1);
    Ref<Strategy> _strat_ref;
    switch (::Meta_MA_Conditions_Condition) {
      case STG_META_MA_CONDITIONS_COND_IS_PEAK:
        _result &= _indi[_ishift][0] >= GetIndiHighest<double>(4, _ishift) ||
                   _indi[_ishift][0] <= GetIndiLowest<double>(4, _ishift);
        break;
      case STG_META_MA_CONDITIONS_COND_IN_PRICE_RANGE:
        _result &= _indi[_ishift][0] < _chart.GetHigh() && _indi[_ishift][0] > _chart.GetLow();
        break;
      case STG_META_MA_CONDITIONS_COND_0_NONE:
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
    bool _result = true;  // && IsValidEntry(_indi, _shift);
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
    bool _result = ::Meta_MA_Conditions_Type != STG_META_MA_CONDITIONS_TYPE_0_NONE;  // && IsValidEntry(_indi, _shift);
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

#endif  // STG_META_MA_CONDITIONS_MQH
