/**
 * @file
 * Implements Weekday meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_WEEKDAY_MQH
#define STG_META_WEEKDAY_MQH

// User input params.
INPUT2_GROUP("Meta Weekday strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Weekday_Strategy_1_Monday = STRAT_ICHIMOKU;            // Monday's strategy
INPUT2 ENUM_STRATEGY Meta_Weekday_Strategy_2_Tuesday = STRAT_ICHIMOKU;           // Tuesday's strategy
INPUT2 ENUM_STRATEGY Meta_Weekday_Strategy_3_Wednesday = STRAT_HEIKEN_ASHI;      // Wednesday's strategy
INPUT2 ENUM_STRATEGY Meta_Weekday_Strategy_4_Thursday = STRAT_OSCILLATOR_TREND;  // Thursday's strategy
INPUT2 ENUM_STRATEGY Meta_Weekday_Strategy_5_Friday = STRAT_MACD;                // Friday's strategy
INPUT3_GROUP("Meta Weekday strategy: common params");
INPUT3 float Meta_Weekday_LotSize = 0;                // Lot size
INPUT3 int Meta_Weekday_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Weekday_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Weekday_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Weekday_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Weekday_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Weekday_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Weekday_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Weekday_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Weekday_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Weekday_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Weekday_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Weekday_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Weekday_Shift = 0;                  // Shift
INPUT3 float Meta_Weekday_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Weekday_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Weekday_OrderCloseTime = 720;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Weekday_Params_Defaults : StgParams {
  Stg_Meta_Weekday_Params_Defaults()
      : StgParams(::Meta_Weekday_SignalOpenMethod, ::Meta_Weekday_SignalOpenFilterMethod,
                  ::Meta_Weekday_SignalOpenLevel, ::Meta_Weekday_SignalOpenBoostMethod,
                  ::Meta_Weekday_SignalCloseMethod, ::Meta_Weekday_SignalCloseFilter, ::Meta_Weekday_SignalCloseLevel,
                  ::Meta_Weekday_PriceStopMethod, ::Meta_Weekday_PriceStopLevel, ::Meta_Weekday_TickFilterMethod,
                  ::Meta_Weekday_MaxSpread, ::Meta_Weekday_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Weekday_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Weekday_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Weekday_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Weekday_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Weekday_SignalOpenFilterTime);
  }
};

class Stg_Meta_Weekday : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Weekday(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Weekday *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Weekday_Params_Defaults stg_meta_weekday_defaults;
    StgParams _stg_params(stg_meta_weekday_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Weekday(_stg_params, _tparams, _cparams, "(Meta) Weekday");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Weekday_Strategy_1_Monday, 1);
    StrategyAdd(Meta_Weekday_Strategy_2_Tuesday, 2);
    StrategyAdd(Meta_Weekday_Strategy_3_Wednesday, 3);
    StrategyAdd(Meta_Weekday_Strategy_4_Thursday, 4);
    StrategyAdd(Meta_Weekday_Strategy_5_Friday, 5);
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
    Ref<Strategy> _strat_ref = strats.GetByKey(DateTimeStatic::DayOfWeek());
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
    Ref<Strategy> _strat_ref = strats.GetByKey(DateTimeStatic::DayOfWeek());
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

#endif  // STG_META_WEEKDAY_MQH
