/**
 * @file
 * Implements Pattern meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_PATTERN_MQH
#define STG_META_PATTERN_MQH

// User input params.
INPUT2_GROUP("Meta Pattern strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Pattern_Strategy_Pattern_Main = STRAT_AWESOME;  // Main strategy
INPUT2 ENUM_PATTERN_1CANDLE Meta_Pattern_Strategy_Pattern_1CandlePattern =
    PATTERN_1CANDLE_BODY_GT_WICKS;                                                         // 1-candle pattern
INPUT2 ENUM_STRATEGY Meta_Pattern_Strategy_Pattern_1CandlePatternStrat = STRAT_INDICATOR;  // 1-candle pattern strategy
INPUT2 ENUM_PATTERN_2CANDLE Meta_Pattern_Strategy_Pattern_2CandlePattern =
    PATTERN_2CANDLE_WICKS_GT_WICKS;                                                         // 2-candle pattern
INPUT2 ENUM_STRATEGY Meta_Pattern_Strategy_Pattern_2CandlePatternStrat = STRAT_STOCHASTIC;  // 2-candle pattern strategy
INPUT3_GROUP("Meta Pattern strategy: common params");
INPUT3 float Meta_Pattern_LotSize = 0;                // Lot size
INPUT3 int Meta_Pattern_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Pattern_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Pattern_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Pattern_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Pattern_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Pattern_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Pattern_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Pattern_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Pattern_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Pattern_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Pattern_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Pattern_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Pattern_Shift = 0;                  // Shift
INPUT3 float Meta_Pattern_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Pattern_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Pattern_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta Pattern strategy: Pattern oscillator params");
INPUT int Meta_Pattern_Pattern_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_Pattern_Pattern_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Pattern_Params_Defaults : StgParams {
  Stg_Meta_Pattern_Params_Defaults()
      : StgParams(::Meta_Pattern_SignalOpenMethod, ::Meta_Pattern_SignalOpenFilterMethod,
                  ::Meta_Pattern_SignalOpenLevel, ::Meta_Pattern_SignalOpenBoostMethod,
                  ::Meta_Pattern_SignalCloseMethod, ::Meta_Pattern_SignalCloseFilter, ::Meta_Pattern_SignalCloseLevel,
                  ::Meta_Pattern_PriceStopMethod, ::Meta_Pattern_PriceStopLevel, ::Meta_Pattern_TickFilterMethod,
                  ::Meta_Pattern_MaxSpread, ::Meta_Pattern_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Pattern_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Pattern_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Pattern_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Pattern_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Pattern_SignalOpenFilterTime);
  }
};

class Stg_Meta_Pattern : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Pattern(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Pattern *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Pattern_Params_Defaults stg_meta_pattern_defaults;
    StgParams _stg_params(stg_meta_pattern_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Pattern(_stg_params, _tparams, _cparams, "(Meta) Pattern");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(::Meta_Pattern_Strategy_Pattern_Main, 0);
    StrategyAdd(::Meta_Pattern_Strategy_Pattern_1CandlePatternStrat, 1);
    StrategyAdd(::Meta_Pattern_Strategy_Pattern_2CandlePatternStrat, 2);
    // Initialize indicators.
    {
      IndiPatternParams _indi_params(::Meta_Pattern_Pattern_Shift);
      _indi_params.SetDataSourceType(::Meta_Pattern_Pattern_SourceType);
      _indi_params.SetTf(PERIOD_D1);
      SetIndicator(new Indi_Pattern(_indi_params));
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
  Ref<Strategy> GetStrategy(int _shift = 0) {
    IndicatorBase *_indi = GetIndicator();
    uint _ishift = _shift + 1;  // + _indi.GetShift()?
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    Chart *_chart = trade.GetChart();
    // PatternCandle1 _pattern1 = (uint)_indi[_ishift][0]; // @todo
    // PatternCandle2 _pattern2 = (uint)_indi[_ishift][1]; // @todo
    BarOHLC _ohlc[2];
    _ohlc[0] = _chart.GetOHLC(_ishift);
    _ohlc[1] = _chart.GetOHLC(_ishift + 1);
    if (_ohlc[0].open > 0 && _ohlc[1].open > 0) {  // Checks for invalid candles.
      PatternCandle1 _pattern1(_ohlc[0]);
      PatternCandle2 _pattern2(_ohlc);
      if (PatternCandle2::CheckPattern((ENUM_PATTERN_2CANDLE)::Meta_Pattern_Strategy_Pattern_2CandlePattern, _ohlc)) {
        _strat_ref = strats.GetByKey(2);
        if (_strat_ref.IsSet()) {
          return _strat_ref;
        }
      }
      if (PatternCandle1::CheckPattern((ENUM_PATTERN_1CANDLE)::Meta_Pattern_Strategy_Pattern_1CandlePattern, _ohlc[0])) {
        _strat_ref = strats.GetByKey(1);
      }
    }
    return _strat_ref;
  }

  /**
   * Gets price stop value.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    uint _ishift = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = GetStrategy(_ishift);
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
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
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
    bool _result = false;
    _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_PATTERN_MQH
