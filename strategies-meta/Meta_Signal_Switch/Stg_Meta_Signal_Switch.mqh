/**
 * @file
 * Implements Signal Switch meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_SIGNAL_SWITCH_MQH
#define STG_META_SIGNAL_SWITCH_MQH

// User input params.
INPUT2_GROUP("Meta Signal Switch strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Signal_Switch_Strategy_Main = STRAT_RSI;              // Main strategy
INPUT2 ENUM_STRATEGY Meta_Signal_Switch_Strategy_Signal2Check = STRAT_CHAIKIN;  // Strategy to check for signal
INPUT2 ENUM_STRATEGY Meta_Signal_Switch_Strategy_Signal2Switch = STRAT_RVI;     // Strategy to run on signal
INPUT3_GROUP("Meta Signal Switch strategy: common params");
INPUT3 float Meta_Signal_Switch_LotSize = 0;                // Lot size
INPUT3 int Meta_Signal_Switch_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Signal_Switch_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Signal_Switch_SignalOpenSwitchMethod = 32;  // Signal open filter method
INPUT3 int Meta_Signal_Switch_SignalOpenSwitchTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Signal_Switch_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Signal_Switch_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Signal_Switch_SignalCloseSwitch = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Signal_Switch_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Signal_Switch_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Signal_Switch_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Signal_Switch_TickSwitchMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Signal_Switch_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Signal_Switch_Shift = 0;                  // Shift
INPUT3 float Meta_Signal_Switch_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Signal_Switch_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Signal_Switch_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Signal_Switch_Params_Defaults : StgParams {
  Stg_Meta_Signal_Switch_Params_Defaults()
      : StgParams(::Meta_Signal_Switch_SignalOpenMethod, ::Meta_Signal_Switch_SignalOpenSwitchMethod,
                  ::Meta_Signal_Switch_SignalOpenLevel, ::Meta_Signal_Switch_SignalOpenBoostMethod,
                  ::Meta_Signal_Switch_SignalCloseMethod, ::Meta_Signal_Switch_SignalCloseSwitch,
                  ::Meta_Signal_Switch_SignalCloseLevel, ::Meta_Signal_Switch_PriceStopMethod,
                  ::Meta_Signal_Switch_PriceStopLevel, ::Meta_Signal_Switch_TickSwitchMethod,
                  ::Meta_Signal_Switch_MaxSpread, ::Meta_Signal_Switch_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Signal_Switch_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Signal_Switch_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Signal_Switch_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Signal_Switch_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Signal_Switch_SignalOpenSwitchTime);
  }
};

class Stg_Meta_Signal_Switch : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Signal_Switch(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Signal_Switch *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Signal_Switch_Params_Defaults stg_meta_signal_switch_defaults;
    StgParams _stg_params(stg_meta_signal_switch_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Signal_Switch(_stg_params, _tparams, _cparams, "(Meta) Signal Switch");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(::Meta_Signal_Switch_Strategy_Main, 0);
    StrategyAdd(::Meta_Signal_Switch_Strategy_Signal2Check, 1);
    StrategyAdd(::Meta_Signal_Switch_Strategy_Signal2Switch, 2);
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
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    Ref<Strategy> _strat_signal = strats.GetByKey(1);
    if (!_strat_signal.IsSet()) {
      // Returns false when indicator data is not valid.
      return _strat_ref;
    }
    _level = _level == 0.0f ? _strat_signal.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_signal.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_signal.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result_signal &= _strat_signal.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    if (_result_signal) {
      // On signal, switch the main strategy.
      _strat_ref = strats.GetByKey(2);
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
    bool _result = true;
    Ref<Strategy> _strat_ref = GetStrategy(_cmd, _method, _level, _shift);
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

#endif  // STG_META_SIGNAL_SWITCH_MQH
