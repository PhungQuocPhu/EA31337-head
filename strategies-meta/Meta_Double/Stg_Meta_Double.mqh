/**
 * @file
 * Implements Double meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_DOUBLE_MQH
#define STG_META_DOUBLE_MQH

// User input params.
INPUT2_GROUP("Meta Double strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Double_Strategy1 = STRAT_OSCILLATOR;        // Strategy 1
INPUT2 ENUM_STRATEGY Meta_Double_Strategy2 = STRAT_OSCILLATOR_TREND;  // Strategy 2
INPUT3_GROUP("Meta Double strategy: common params");
INPUT3 float Meta_Double_LotSize = 0;                // Lot size
INPUT3 int Meta_Double_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Double_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Double_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Double_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Double_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Double_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Double_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Double_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Double_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Double_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Double_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Double_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Double_Shift = 0;                  // Shift
INPUT3 float Meta_Double_OrderCloseLoss = 30;        // Order close loss
INPUT3 float Meta_Double_OrderCloseProfit = 30;      // Order close profit
INPUT3 int Meta_Double_OrderCloseTime = -10;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Double_Params_Defaults : StgParams {
  Stg_Meta_Double_Params_Defaults()
      : StgParams(::Meta_Double_SignalOpenMethod, ::Meta_Double_SignalOpenFilterMethod, ::Meta_Double_SignalOpenLevel,
                  ::Meta_Double_SignalOpenBoostMethod, ::Meta_Double_SignalCloseMethod, ::Meta_Double_SignalCloseFilter,
                  ::Meta_Double_SignalCloseLevel, ::Meta_Double_PriceStopMethod, ::Meta_Double_PriceStopLevel,
                  ::Meta_Double_TickFilterMethod, ::Meta_Double_MaxSpread, ::Meta_Double_Shift) {
    Set(STRAT_PARAM_LS, Meta_Double_LotSize);
    Set(STRAT_PARAM_OCL, Meta_Double_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Meta_Double_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Meta_Double_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Meta_Double_SignalOpenFilterTime);
  }
};

class Stg_Meta_Double : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Double(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Double *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Double_Params_Defaults stg_double_defaults;
    StgParams _stg_params(stg_double_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Double(_stg_params, _tparams, _cparams, "(Meta) Double");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Double_Strategy1, 0);
    StrategyAdd(Meta_Double_Strategy2, 1);
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
    bool _result = strats.Size() > 0;
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _level = _level == 0.0f ? _strat.Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat.Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat.Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result &= _strat.SignalOpen(_cmd, _method, _level, _shift);
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = strats.Size() > 0;
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _level = _level == 0.0f ? _strat.Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat.Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat.Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result &= _strat.SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    }
    return _result;
  }
};

#endif  // STG_META_DOUBLE_MQH
