/**
 * @file
 * Implements Mirror meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_MIRROR_MQH
#define STG_META_MIRROR_MQH

// User input params.
// INPUT2_GROUP("Meta Mirror strategy: main params");
INPUT3_GROUP("Meta Mirror strategy: common params");
INPUT3 float Meta_Mirror_LotSize = 0;                // Lot size
INPUT3 int Meta_Mirror_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Mirror_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Mirror_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Mirror_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Mirror_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Mirror_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Mirror_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Mirror_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Mirror_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Mirror_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Mirror_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Mirror_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Mirror_Shift = 0;                  // Shift
INPUT3 float Meta_Mirror_OrderCloseLoss = 80;        // Order close loss
INPUT3 float Meta_Mirror_OrderCloseProfit = 80;      // Order close profit
INPUT3 int Meta_Mirror_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Mirror_Params_Defaults : StgParams {
  Stg_Meta_Mirror_Params_Defaults()
      : StgParams(::Meta_Mirror_SignalOpenMethod, ::Meta_Mirror_SignalOpenFilterMethod, ::Meta_Mirror_SignalOpenLevel,
                  ::Meta_Mirror_SignalOpenBoostMethod, ::Meta_Mirror_SignalCloseMethod, ::Meta_Mirror_SignalCloseFilter,
                  ::Meta_Mirror_SignalCloseLevel, ::Meta_Mirror_PriceStopMethod, ::Meta_Mirror_PriceStopLevel,
                  ::Meta_Mirror_TickFilterMethod, ::Meta_Mirror_MaxSpread, ::Meta_Mirror_Shift) {
    Set(STRAT_PARAM_LS, Meta_Mirror_LotSize);
    Set(STRAT_PARAM_OCL, Meta_Mirror_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Meta_Mirror_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Meta_Mirror_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Meta_Mirror_SignalOpenFilterTime);
  }
};

class Stg_Meta_Mirror : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Mirror(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Mirror *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Mirror_Params_Defaults stg_mirror_defaults;
    StgParams _stg_params(stg_mirror_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Mirror(_stg_params, _tparams, _cparams, "(Meta) Mirror");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {}

  /**
   * Copies strategies from EA.
   */
  bool SetStrategies(EA *_ea = NULL) {
    bool _result = true;
    long _magic_no = Get<long>(STRAT_PARAM_ID);
    ENUM_TIMEFRAMES _tf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);
    for (DictStructIterator<long, Ref<Strategy>> iter = _ea.GetStrategies().Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      ENUM_STRATEGY _sid = _strat.Get<ENUM_STRATEGY>(STRAT_PARAM_TYPE);
      _result &= StrategyAdd(_sid);
    }
    return _result;
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
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid() && !_result; ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _level = _level == 0.0f ? _strat.Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat.Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat.Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat.SignalOpen(_cmd, _method, _level, _shift);
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = false;
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid() && !_result; ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _level = _level == 0.0f ? _strat.Get<float>(STRAT_PARAM_SCL) : _level;
      _method = _method == 0 ? _strat.Get<int>(STRAT_PARAM_SCM) : _method;
      _shift = _shift == 0 ? _strat.Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat.SignalClose(_cmd, _method, _level, _shift);
    }
    return _result;
  }
};

#endif  // STG_META_MIRROR_MQH
