/**
 * @file
 * Implements Bears & Bulls meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_BEARS_BULLS_MQH
#define STG_META_BEARS_BULLS_MQH

// User input params.
INPUT2_GROUP("Meta Bears & Bulls strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Bears_Bulls_Strategy_Bears = STRAT_BEARS_POWER;  // Strategy for bears
INPUT2 ENUM_STRATEGY Meta_Bears_Bulls_Strategy_Bulls = STRAT_BULLS_POWER;  // Strategy for bulls
INPUT3_GROUP("Meta Bears & Bulls strategy: common params");
INPUT3 float Meta_Bears_Bulls_LotSize = 0;                // Lot size
INPUT3 int Meta_Bears_Bulls_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Bears_Bulls_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Bears_Bulls_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Bears_Bulls_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Bears_Bulls_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Bears_Bulls_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Bears_Bulls_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Bears_Bulls_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Bears_Bulls_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Bears_Bulls_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Bears_Bulls_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Bears_Bulls_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Bears_Bulls_Shift = 0;                  // Shift
INPUT3 float Meta_Bears_Bulls_OrderCloseLoss = 30;        // Order close loss
INPUT3 float Meta_Bears_Bulls_OrderCloseProfit = 30;      // Order close profit
INPUT3 int Meta_Bears_Bulls_OrderCloseTime = -10;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Bears_Bulls_Params_Defaults : StgParams {
  Stg_Meta_Bears_Bulls_Params_Defaults()
      : StgParams(::Meta_Bears_Bulls_SignalOpenMethod, ::Meta_Bears_Bulls_SignalOpenFilterMethod,
                  ::Meta_Bears_Bulls_SignalOpenLevel, ::Meta_Bears_Bulls_SignalOpenBoostMethod,
                  ::Meta_Bears_Bulls_SignalCloseMethod, ::Meta_Bears_Bulls_SignalCloseFilter,
                  ::Meta_Bears_Bulls_SignalCloseLevel, ::Meta_Bears_Bulls_PriceStopMethod,
                  ::Meta_Bears_Bulls_PriceStopLevel, ::Meta_Bears_Bulls_TickFilterMethod, ::Meta_Bears_Bulls_MaxSpread,
                  ::Meta_Bears_Bulls_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Bears_Bulls_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Bears_Bulls_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Bears_Bulls_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Bears_Bulls_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Bears_Bulls_SignalOpenFilterTime);
  }
};

class Stg_Meta_Bears_Bulls : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Bears_Bulls(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Bears_Bulls *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Bears_Bulls_Params_Defaults stg_bears_bulls_defaults;
    StgParams _stg_params(stg_bears_bulls_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Bears_Bulls(_stg_params, _tparams, _cparams, "(Meta) Bears_Bulls");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Bears_Bulls_Strategy_Bears, ORDER_TYPE_SELL);
    StrategyAdd(Meta_Bears_Bulls_Strategy_Bulls, ORDER_TYPE_BUY);
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
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = false;  // strats.Size() > 0;
    Ref<Strategy> _strat_ref;
    _strat_ref = strats.GetByKey(_cmd);
    if (_strat_ref.IsSet()) {
      _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    }
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

#endif  // STG_META_BEARS_BULLS_MQH
