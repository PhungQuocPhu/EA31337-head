/**
 * @file
 * Implements Reversal meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_REVERSAL_MQH
#define STG_META_REVERSAL_MQH

// User input params.
INPUT2_GROUP("Meta Reversal strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Reversal_Strategy = STRAT_OSCILLATOR_CROSS;  // Strategy to reverse signals
INPUT3_GROUP("Meta Reversal strategy: common params");
INPUT3 float Meta_Reversal_LotSize = 0;                // Lot size
INPUT3 int Meta_Reversal_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Reversal_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Reversal_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Reversal_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Reversal_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Reversal_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Reversal_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Reversal_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Reversal_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Reversal_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Reversal_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Reversal_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Reversal_Shift = 0;                  // Shift
INPUT3 float Meta_Reversal_OrderCloseLoss = 30;        // Order close loss
INPUT3 float Meta_Reversal_OrderCloseProfit = 30;      // Order close profit
INPUT3 int Meta_Reversal_OrderCloseTime = -10;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Reversal_Params_Defaults : StgParams {
  Stg_Meta_Reversal_Params_Defaults()
      : StgParams(::Meta_Reversal_SignalOpenMethod, ::Meta_Reversal_SignalOpenFilterMethod,
                  ::Meta_Reversal_SignalOpenLevel, ::Meta_Reversal_SignalOpenBoostMethod,
                  ::Meta_Reversal_SignalCloseMethod, ::Meta_Reversal_SignalCloseFilter,
                  ::Meta_Reversal_SignalCloseLevel, ::Meta_Reversal_PriceStopMethod, ::Meta_Reversal_PriceStopLevel,
                  ::Meta_Reversal_TickFilterMethod, ::Meta_Reversal_MaxSpread, ::Meta_Reversal_Shift) {
    Set(STRAT_PARAM_LS, Meta_Reversal_LotSize);
    Set(STRAT_PARAM_OCL, Meta_Reversal_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Meta_Reversal_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Meta_Reversal_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Meta_Reversal_SignalOpenFilterTime);
  }
};

class Stg_Meta_Reversal : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Reversal(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Reversal *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Reversal_Params_Defaults stg_reversal_defaults;
    StgParams _stg_params(stg_reversal_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Reversal(_stg_params, _tparams, _cparams, "(Meta) Reversal");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() { StrategyAdd(Meta_Reversal_Strategy, 0); }

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
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return _result;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result |= _strat.Ptr().SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = false;
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return _result;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SCL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SCM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result |= _strat.Ptr().SignalClose(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_REVERSAL_MQH
