/**
 * @file
 * Implements Spread meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_SPREAD_MQH
#define STG_META_SPREAD_MQH

// User input params.
INPUT2_GROUP("Meta Spread strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Spread_Strategy_Spread_LT_1p = STRAT_RSI;                     // Strategy on spread 1 pip
INPUT2 ENUM_STRATEGY Meta_Spread_Strategy_Spread_LT_2p = STRAT_OSCILLATOR_TREND;        // Strategy on spread 1-2 pips
INPUT2 ENUM_STRATEGY Meta_Spread_Strategy_Spread_LT_4p = STRAT_OSCILLATOR_CROSS_SHIFT;  // Strategy on spread 2-4 pips
INPUT2 ENUM_STRATEGY Meta_Spread_Strategy_Spread_GT_4p = STRAT_ASI;  // Strategy on spread greater than 4 pips
INPUT3_GROUP("Meta Spread strategy: common params");
INPUT3 float Meta_Spread_LotSize = 0;                // Lot size
INPUT3 int Meta_Spread_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Spread_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Spread_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Spread_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Spread_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Spread_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Spread_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Spread_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Spread_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Spread_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Spread_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Spread_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Spread_Shift = 0;                  // Shift
INPUT3 float Meta_Spread_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Spread_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Spread_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Spread_Params_Defaults : StgParams {
  Stg_Meta_Spread_Params_Defaults()
      : StgParams(::Meta_Spread_SignalOpenMethod, ::Meta_Spread_SignalOpenFilterMethod, ::Meta_Spread_SignalOpenLevel,
                  ::Meta_Spread_SignalOpenBoostMethod, ::Meta_Spread_SignalCloseMethod, ::Meta_Spread_SignalCloseFilter,
                  ::Meta_Spread_SignalCloseLevel, ::Meta_Spread_PriceStopMethod, ::Meta_Spread_PriceStopLevel,
                  ::Meta_Spread_TickFilterMethod, ::Meta_Spread_MaxSpread, ::Meta_Spread_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Spread_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Spread_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Spread_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Spread_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Spread_SignalOpenFilterTime);
  }
};

class Stg_Meta_Spread : public Strategy {
 protected:
  Trade strade;
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Spread(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Spread *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Spread_Params_Defaults stg_meta_spread_defaults;
    StgParams _stg_params(stg_meta_spread_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Spread(_stg_params, _tparams, _cparams, "(Meta) Spread");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Spread_Strategy_Spread_LT_1p, 0);
    StrategyAdd(Meta_Spread_Strategy_Spread_LT_2p, 1);
    StrategyAdd(Meta_Spread_Strategy_Spread_LT_4p, 2);
    StrategyAdd(Meta_Spread_Strategy_Spread_GT_4p, 3);
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
  Ref<Strategy> GetStrategy(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    bool _result_signal = true;
    Chart *_chart = trade.GetChart();
    Ref<Strategy> _strat_ref;
    double _spread = _chart.GetSpreadInPips();
    if (_spread < 1.0f) {
      // Strategy on spread 0-10pts.
      _strat_ref = strats.GetByKey(0);
    } else if (_spread < 2.0f) {
      // Strategy on spread 10-20pts.
      _strat_ref = strats.GetByKey(1);
    } else if (_spread < 4.0f) {
      // Strategy on spread 20-40pts.
      _strat_ref = strats.GetByKey(2);
    } else if (_spread >= 4.0f) {
      // Strategy on spread >40pts.
      _strat_ref = strats.GetByKey(3);
    }
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
    Ref<Strategy> _strat_ref = GetStrategy(_cmd, _method, _level, _ishift);  // @todo: Add shift.
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
    // double _margin_free =
    uint _ishift = _shift;
    Ref<Strategy> _strat_ref = GetStrategy(_cmd, _method, _level, _shift);
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

#endif  // STG_META_SPREAD_MQH
