/**
 * @file
 * Implements Interval meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_INTERVAL_MQH
#define STG_META_INTERVAL_MQH

// User input params.
INPUT2_GROUP("Meta Interval strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Interval_Strategy_Main = STRAT_RSI;                   // Main strategy
INPUT2 ENUM_STRATEGY Meta_Interval_Strategy_Interval = STRAT_OSCILLATOR_TREND;  // Interval strategy
INPUT2 ushort Meta_Interval_Strategy_MinutesEach = 15;                          // Interval per minute
INPUT2 ushort Meta_Interval_Strategy_MinutesAfter = 2;                          // Minutes after interval
INPUT2 ushort Meta_Interval_Strategy_MinutesBefore = 2;                         // Minutes before interval
INPUT3_GROUP("Meta Interval strategy: common params");
INPUT3 float Meta_Interval_LotSize = 0;                // Lot size
INPUT3 int Meta_Interval_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Interval_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Interval_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Interval_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Interval_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Interval_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Interval_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Interval_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Interval_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Interval_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Interval_TickFilterMethod = 1;         // Tick filter method (0-255)
INPUT3 float Meta_Interval_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Interval_Shift = 0;                  // Shift
INPUT3 float Meta_Interval_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Interval_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Interval_OrderCloseTime = 1440;        // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Interval_Params_Defaults : StgParams {
  Stg_Meta_Interval_Params_Defaults()
      : StgParams(::Meta_Interval_SignalOpenMethod, ::Meta_Interval_SignalOpenFilterMethod,
                  ::Meta_Interval_SignalOpenLevel, ::Meta_Interval_SignalOpenBoostMethod,
                  ::Meta_Interval_SignalCloseMethod, ::Meta_Interval_SignalCloseFilter,
                  ::Meta_Interval_SignalCloseLevel, ::Meta_Interval_PriceStopMethod, ::Meta_Interval_PriceStopLevel,
                  ::Meta_Interval_TickFilterMethod, ::Meta_Interval_MaxSpread, ::Meta_Interval_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Interval_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Interval_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Interval_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Interval_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Interval_SignalOpenFilterTime);
  }
};

class Stg_Meta_Interval : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Interval(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Interval *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Interval_Params_Defaults stg_meta_interval_defaults;
    StgParams _stg_params(stg_meta_interval_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Interval(_stg_params, _tparams, _cparams, "(Meta) Time");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Interval_Strategy_Main, 0);
    StrategyAdd(Meta_Interval_Strategy_Interval, 1);
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
   * Gets price stop value.
   */
  Ref<Strategy> GetStrategyPerInterval() {
    datetime _timestamp = TimeCurrent();
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    int _reminder = int(_timestamp % (::Meta_Interval_Strategy_MinutesEach * 60));
    if ((_reminder / 60) >= (::Meta_Interval_Strategy_MinutesEach - ::Meta_Interval_Strategy_MinutesBefore) &&
        (_reminder / 60) <= (::Meta_Interval_Strategy_MinutesEach + ::Meta_Interval_Strategy_MinutesAfter)) {
      _strat_ref = strats.GetByKey(1);
    }
    return _strat_ref;
  }

  /**
   * Gets price stop value.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = GetStrategyPerInterval();
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
    bool _result = true;  // strats.Size() > 0;
    Ref<Strategy> _strat_ref = GetStrategyPerInterval();
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
    bool _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_INTERVAL_MQH
