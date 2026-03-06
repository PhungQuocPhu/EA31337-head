/**
 * @file
 * Implements Trio meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_TRIO_MQH
#define STG_META_TRIO_MQH

// User input params.
INPUT2_GROUP("Meta Trio strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Trio_Strategy_SignalOpen = STRAT_OSCILLATOR_RANGE;  // Strategy for signal open
INPUT2 ENUM_STRATEGY Meta_Trio_Strategy_SignalClose = STRAT_NONE;             // Strategy for signal close
INPUT2 ENUM_STRATEGY Meta_Trio_Strategy_Stops = STRAT_MA_TREND;               // Strategy for price stops
INPUT3_GROUP("Meta Trio strategy: common params");
INPUT3 float Meta_Trio_LotSize = 0;                // Lot size
INPUT3 int Meta_Trio_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Trio_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Trio_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Trio_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Trio_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Trio_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Trio_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Trio_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Trio_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Trio_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Trio_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Trio_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Trio_Shift = 0;                  // Shift
INPUT3 float Meta_Trio_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Trio_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Trio_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Trio_Params_Defaults : StgParams {
  Stg_Meta_Trio_Params_Defaults()
      : StgParams(::Meta_Trio_SignalOpenMethod, ::Meta_Trio_SignalOpenFilterMethod, ::Meta_Trio_SignalOpenLevel,
                  ::Meta_Trio_SignalOpenBoostMethod, ::Meta_Trio_SignalCloseMethod, ::Meta_Trio_SignalCloseFilter,
                  ::Meta_Trio_SignalCloseLevel, ::Meta_Trio_PriceStopMethod, ::Meta_Trio_PriceStopLevel,
                  ::Meta_Trio_TickFilterMethod, ::Meta_Trio_MaxSpread, ::Meta_Trio_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Trio_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Trio_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Trio_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Trio_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Trio_SignalOpenFilterTime);
  }
};

class Stg_Meta_Trio : public Strategy {
 protected:
  Account account;
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Trio(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Trio *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Trio_Params_Defaults stg_meta_trio_defaults;
    StgParams _stg_params(stg_meta_trio_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Trio(_stg_params, _tparams, _cparams, "(Meta) Trio");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Trio_Strategy_SignalOpen, 1);
    StrategyAdd(Meta_Trio_Strategy_SignalClose, 2);
    StrategyAdd(Meta_Trio_Strategy_Stops, 3);
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
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = strats.GetByKey(3);
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
    Ref<Strategy> _strat_ref = strats.GetByKey(1);
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
    bool _result = true;
    Ref<Strategy> _strat_ref = strats.GetByKey(2);
    if (!_strat_ref.IsSet()) {
      // Returns signal from default strategy used for signal open.
      return SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalClose(_cmd, _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_TRIO_MQH
