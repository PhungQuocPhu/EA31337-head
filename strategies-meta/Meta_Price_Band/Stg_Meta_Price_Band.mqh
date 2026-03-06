/**
 * @file
 * Implements Price Band meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_PRICE_BAND_MQH
#define STG_META_PRICE_BAND_MQH

// Defines enumeration for price band indicator types.
enum ENUM_STG_META_BAND_TYPE {
  STG_META_BAND_TYPE_0_NONE = 0,  // (None)
  STG_META_BAND_TYPE_BBANDS,      // Bollinger Bands
  STG_META_BAND_TYPE_ENVELOPES,   // Envelopes
};

// User input params.
INPUT2_GROUP("Meta Price Band strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Price_Band_Strategy_Price_Band_Inner = STRAT_CCI;          // Strategy for price inside band
INPUT2 ENUM_STRATEGY Meta_Price_Band_Strategy_Price_Band_Outer = STRAT_MA_BREAKOUT;  // Strategy for price outside band
INPUT2 ENUM_STG_META_BAND_TYPE Meta_Price_Band_Type = STG_META_BAND_TYPE_BBANDS;     // Price Band indicator type
INPUT2 ENUM_APPLIED_PRICE Meta_Price_Band_Applied_Price = PRICE_OPEN;  // Applied Price for Price Band indicator
INPUT2 ENUM_TIMEFRAMES Meta_Price_Band_Tf = PERIOD_D1;                 // Timeframe for Price Band indicator
INPUT3_GROUP("Meta Price Band strategy: common params");
INPUT3 float Meta_Price_Band_LotSize = 0;                // Lot size
INPUT3 int Meta_Price_Band_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Price_Band_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Price_Band_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Price_Band_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Price_Band_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Price_Band_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Price_Band_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Price_Band_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Price_Band_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Price_Band_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Price_Band_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Price_Band_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Price_Band_Shift = 0;                  // Shift
INPUT3 float Meta_Price_Band_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Price_Band_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Price_Band_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Bands strategy: Bollinger Bands indicator params");
INPUT3 int Meta_Price_Band_Indi_Bands_Period = 24;                                // Period
INPUT3 float Meta_Price_Band_Indi_Bands_Deviation = 1.0f;                         // Deviation
INPUT3 int Meta_Price_Band_Indi_Bands_HShift = 0;                                 // Horizontal shift
INPUT3 ENUM_APPLIED_PRICE Meta_Price_Band_Indi_Bands_Applied_Price = PRICE_OPEN;  // Applied Price
INPUT3 int Meta_Price_Band_Indi_Bands_Shift = 0;                                  // Shift
INPUT3 ENUM_BANDS_LINE Meta_Price_Band_Indi_Bands_Mode_Base = BAND_BASE;          // Mode for base band
INPUT3 ENUM_BANDS_LINE Meta_Price_Band_Indi_Bands_Mode_Lower = BAND_LOWER;        // Mode for lower band
INPUT3 ENUM_BANDS_LINE Meta_Price_Band_Indi_Bands_Mode_Upper = BAND_UPPER;        // Mode for upper band
INPUT3_GROUP("Bands strategy: Envelopes indicator params");
INPUT3 int Meta_Price_Band_Indi_Envelopes_MA_Period = 20;                             // Period
INPUT3 int Meta_Price_Band_Indi_Envelopes_MA_Shift = 0;                               // MA Shift
INPUT3 ENUM_MA_METHOD Meta_Price_Band_Indi_Envelopes_MA_Method = (ENUM_MA_METHOD)1;   // MA Method
INPUT3 ENUM_APPLIED_PRICE Meta_Price_Band_Indi_Envelopes_Applied_Price = PRICE_OPEN;  // Applied Price
INPUT3 float Meta_Price_Band_Indi_Envelopes_Deviation = 0.1f;                         // Deviation
INPUT3 int Meta_Price_Band_Indi_Envelopes_Shift = 0;                                  // Shift
INPUT3 ENUM_SIGNAL_LINE Meta_Price_Band_Indi_Envelopes_Mode_Base = LINE_MAIN;         // Mode for base band
INPUT3 ENUM_LO_UP_LINE Meta_Price_Band_Indi_Envelopes_Mode_Lower = LINE_LOWER;        // Mode for lower band
INPUT3 ENUM_LO_UP_LINE Meta_Price_Band_Indi_Envelopes_Mode_Upper = LINE_UPPER;        // Mode for upper band

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Price_Band_Params_Defaults : StgParams {
  int mode_base, mode_lower, mode_upper;
  Stg_Meta_Price_Band_Params_Defaults()
      : StgParams(::Meta_Price_Band_SignalOpenMethod, ::Meta_Price_Band_SignalOpenFilterMethod,
                  ::Meta_Price_Band_SignalOpenLevel, ::Meta_Price_Band_SignalOpenBoostMethod,
                  ::Meta_Price_Band_SignalCloseMethod, ::Meta_Price_Band_SignalCloseFilter,
                  ::Meta_Price_Band_SignalCloseLevel, ::Meta_Price_Band_PriceStopMethod,
                  ::Meta_Price_Band_PriceStopLevel, ::Meta_Price_Band_TickFilterMethod, ::Meta_Price_Band_MaxSpread,
                  ::Meta_Price_Band_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Price_Band_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Price_Band_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Price_Band_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Price_Band_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Price_Band_SignalOpenFilterTime);
  }
  // Getters.
  int GetModeBase() { return mode_base; }
  int GetModeLower() { return mode_lower; }
  int GetModeUpper() { return mode_upper; }
  // Setters.
  void SetModeBase(int _value) { mode_base = _value; }
  void SetModeLower(int _value) { mode_lower = _value; }
  void SetModeUpper(int _value) { mode_upper = _value; }
};

class Stg_Meta_Price_Band : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Stg_Meta_Price_Band_Params_Defaults ssparams;

 public:
  Stg_Meta_Price_Band(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Price_Band *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Price_Band_Params_Defaults stg_meta_price_band_defaults;
    StgParams _stg_params(stg_meta_price_band_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Price_Band(_stg_params, _tparams, _cparams, "(Meta) Price Band");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(::Meta_Price_Band_Strategy_Price_Band_Inner, 0);
    StrategyAdd(::Meta_Price_Band_Strategy_Price_Band_Outer, 1);
    // Initialize indicators.
    switch (::Meta_Price_Band_Type) {
      case STG_META_BAND_TYPE_BBANDS:  // Bollinger Bands
      {
        IndiBandsParams _indi_params(::Meta_Price_Band_Indi_Bands_Period, ::Meta_Price_Band_Indi_Bands_Deviation,
                                     ::Meta_Price_Band_Indi_Bands_HShift, ::Meta_Price_Band_Indi_Bands_Applied_Price,
                                     ::Meta_Price_Band_Indi_Bands_Shift);
        _indi_params.SetTf(::Meta_Price_Band_Tf);
        SetIndicator(new Indi_Bands(_indi_params), ::Meta_Price_Band_Type);
        ssparams.SetModeBase(::Meta_Price_Band_Indi_Bands_Mode_Base);
        ssparams.SetModeLower(::Meta_Price_Band_Indi_Bands_Mode_Lower);
        ssparams.SetModeUpper(::Meta_Price_Band_Indi_Bands_Mode_Upper);
        break;
      }
      case STG_META_BAND_TYPE_ENVELOPES:  // Envelopes
      {
        IndiEnvelopesParams _indi_params(
            ::Meta_Price_Band_Indi_Envelopes_MA_Period, ::Meta_Price_Band_Indi_Envelopes_MA_Shift,
            ::Meta_Price_Band_Indi_Envelopes_MA_Method, ::Meta_Price_Band_Indi_Envelopes_Applied_Price,
            ::Meta_Price_Band_Indi_Envelopes_Deviation, ::Meta_Price_Band_Indi_Envelopes_Shift);
        _indi_params.SetTf(::Meta_Price_Band_Tf);
        SetIndicator(new Indi_Envelopes(_indi_params), ::Meta_Price_Band_Type);
        ssparams.SetModeBase(::Meta_Price_Band_Indi_Envelopes_Mode_Base);
        ssparams.SetModeLower(::Meta_Price_Band_Indi_Envelopes_Mode_Lower);
        ssparams.SetModeUpper(::Meta_Price_Band_Indi_Envelopes_Mode_Upper);
        break;
      }
      case STG_META_BAND_TYPE_0_NONE:  // (None)
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
   * Gets strategy.
   */
  Ref<Strategy> GetStrategy() {
    uint _ishift = 0;
    Chart *_chart = trade.GetChart();
    IndicatorBase *_indi = GetIndicator(::Meta_Price_Band_Type);
    double _price_ap = _chart.GetPrice(::Meta_Price_Band_Applied_Price, _ishift);
    int _mode_base = ssparams.GetModeBase();
    int _mode_lower = ssparams.GetModeLower();
    int _mode_upper = ssparams.GetModeUpper();
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    // bool _is_valid = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, 0) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, 1);
    bool _is_valid = _indi.IsValid();
    if (!_is_valid) {
      return _strat_ref;
    }
    if (_price_ap <= _indi[_ishift][(int)_mode_lower] || _price_ap >= _indi[_ishift][(int)_mode_upper]) {
      _strat_ref = strats.GetByKey(1);
    }
    return _strat_ref;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    Ref<Strategy> _strat_ref = GetStrategy();
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
    bool _result = false;
    _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_PRICE_BAND_MQH
