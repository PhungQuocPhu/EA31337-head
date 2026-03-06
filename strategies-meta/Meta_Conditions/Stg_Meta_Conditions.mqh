/**
 * @file
 * Implements Conditions meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_CONDITIONS_MQH
#define STG_META_CONDITIONS_MQH

// Trade conditions.
enum ENUM_STG_CONDITIONS_CONDITION {
  STG_CONDITIONS_COND_0_NONE = 0,                      // None
  STG_CONDITIONS_COND_IS_PEAK = TRADE_COND_IS_PEAK,    // Market is at peak level
  STG_CONDITIONS_COND_IS_PIVOT = TRADE_COND_IS_PIVOT,  // Market is in pivot levels
  // STG_CONDITIONS_COND_ORDERS_PROFIT_GT_01PC = TRADE_COND_ORDERS_PROFIT_GT_01PC,  // Equity > 1%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_LT_01PC = TRADE_COND_ORDERS_PROFIT_LT_01PC,  // Equity < 1%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_GT_02PC = TRADE_COND_ORDERS_PROFIT_GT_02PC,  // Equity > 2%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_LT_02PC = TRADE_COND_ORDERS_PROFIT_LT_02PC,  // Equity < 2%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_GT_05PC = TRADE_COND_ORDERS_PROFIT_GT_05PC,  // Equity > 5%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_LT_05PC = TRADE_COND_ORDERS_PROFIT_LT_05PC,  // Equity < 5%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_GT_10PC = TRADE_COND_ORDERS_PROFIT_GT_10PC,  // Equity > 10%
  // STG_CONDITIONS_COND_ORDERS_PROFIT_LT_10PC = TRADE_COND_ORDERS_PROFIT_LT_10PC,  // Equity < 10%
};

// User input params.
INPUT2_GROUP("Meta Conditions strategy: main params");
INPUT2 ENUM_STG_CONDITIONS_CONDITION Meta_Conditions_Condition1 = STG_CONDITIONS_COND_IS_PEAK;  // Trade condition 1
INPUT2 ENUM_STRATEGY Meta_Conditions_Strategy1 = STRAT_AMA;  // Strategy 1 on condition 1
INPUT2 ENUM_STG_CONDITIONS_CONDITION Meta_Conditions_Condition2 = STG_CONDITIONS_COND_IS_PIVOT;  // Trade condition 2
INPUT2 ENUM_STRATEGY Meta_Conditions_Strategy2 = STRAT_AWESOME;  // Strategy 2 on condition 2
INPUT2 ENUM_STG_CONDITIONS_CONDITION Meta_Conditions_Condition3 = STG_CONDITIONS_COND_0_NONE;  // Trade condition 3
INPUT2 ENUM_STRATEGY Meta_Conditions_Strategy3 = STRAT_NONE;  // Strategy 3 on condition 3
INPUT3_GROUP("Meta Conditions strategy: common params");
INPUT3 float Meta_Conditions_LotSize = 0;                // Lot size
INPUT3 int Meta_Conditions_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Conditions_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Conditions_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Conditions_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Conditions_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Conditions_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Conditions_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Conditions_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Conditions_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Conditions_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Conditions_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Conditions_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Conditions_Shift = 0;                  // Shift
INPUT3 float Meta_Conditions_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Conditions_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Conditions_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Conditions_Params_Defaults : StgParams {
  Stg_Meta_Conditions_Params_Defaults()
      : StgParams(::Meta_Conditions_SignalOpenMethod, ::Meta_Conditions_SignalOpenFilterMethod,
                  ::Meta_Conditions_SignalOpenLevel, ::Meta_Conditions_SignalOpenBoostMethod,
                  ::Meta_Conditions_SignalCloseMethod, ::Meta_Conditions_SignalCloseFilter,
                  ::Meta_Conditions_SignalCloseLevel, ::Meta_Conditions_PriceStopMethod,
                  ::Meta_Conditions_PriceStopLevel, ::Meta_Conditions_TickFilterMethod, ::Meta_Conditions_MaxSpread,
                  ::Meta_Conditions_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Conditions_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Conditions_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Conditions_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Conditions_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Conditions_SignalOpenFilterTime);
  }
};

class Stg_Meta_Conditions : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;  // Trade instance.

 public:
  Stg_Meta_Conditions(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Conditions *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Conditions_Params_Defaults stg_conditions_defaults;
    StgParams _stg_params(stg_conditions_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Conditions(_stg_params, _tparams, _cparams, "(Meta) Conditions");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Conditions_Strategy1, 1);
    StrategyAdd(Meta_Conditions_Strategy2, 2);
    StrategyAdd(Meta_Conditions_Strategy3, 3);
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
    bool _result = false;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    Ref<Strategy> _strat_ref;
    if (!_result && Meta_Conditions_Condition1 != STG_CONDITIONS_COND_0_NONE &&
        strade.CheckCondition((ENUM_TRADE_CONDITION)Meta_Conditions_Condition1)) {
      _strat_ref = strats.GetByKey(1);
      if (_strat_ref.IsSet()) {
        _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
        _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
        _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
        _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      }
    }
    if (!_result && Meta_Conditions_Condition2 != STG_CONDITIONS_COND_0_NONE &&
        strade.CheckCondition((ENUM_TRADE_CONDITION)Meta_Conditions_Condition2)) {
      _strat_ref = strats.GetByKey(2);
      if (_strat_ref.IsSet()) {
        _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
        _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
        _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
        _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      }
    }
    if (!_result && Meta_Conditions_Condition3 != STG_CONDITIONS_COND_0_NONE &&
        strade.CheckCondition((ENUM_TRADE_CONDITION)Meta_Conditions_Condition3)) {
      _strat_ref = strats.GetByKey(3);
      if (_strat_ref.IsSet()) {
        _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
        _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
        _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
        _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      }
    }
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
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

#endif  // STG_META_CONDITIONS_MQH
