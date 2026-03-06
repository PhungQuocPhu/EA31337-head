/**
 * @file
 * Implements Timezone meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_TIMEZONE_MQH
#define STG_META_TIMEZONE_MQH

// User input params.
INPUT2_GROUP("Meta Timezone strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Timezone_Strategy_London = STRAT_OSCILLATOR_TREND;        // London market hours strategy
INPUT2 ENUM_STRATEGY Meta_Timezone_Strategy_NewYork = STRAT_MA_BREAKOUT;            // New York market hours strategy
INPUT2 ENUM_STRATEGY Meta_Timezone_Strategy_Sydney = STRAT_OSCILLATOR_CROSS_SHIFT;  // Sydney market hours strategy
INPUT2 ENUM_STRATEGY Meta_Timezone_Strategy_Tokyo = STRAT_AD;                       // Tokyo market hours strategy
INPUT3_GROUP("Meta Timezone strategy: common params");
INPUT3 float Meta_Timezone_LotSize = 0;                // Lot size
INPUT3 int Meta_Timezone_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Timezone_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Timezone_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Timezone_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Timezone_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Timezone_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Timezone_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Timezone_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Timezone_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Timezone_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Timezone_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Timezone_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Timezone_Shift = 0;                  // Shift
INPUT3 float Meta_Timezone_OrderCloseLoss = 30;        // Order close loss
INPUT3 float Meta_Timezone_OrderCloseProfit = 30;      // Order close profit
INPUT3 int Meta_Timezone_OrderCloseTime = -10;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Timezone_Params_Defaults : StgParams {
  Stg_Meta_Timezone_Params_Defaults()
      : StgParams(::Meta_Timezone_SignalOpenMethod, ::Meta_Timezone_SignalOpenFilterMethod,
                  ::Meta_Timezone_SignalOpenLevel, ::Meta_Timezone_SignalOpenBoostMethod,
                  ::Meta_Timezone_SignalCloseMethod, ::Meta_Timezone_SignalCloseFilter,
                  ::Meta_Timezone_SignalCloseLevel, ::Meta_Timezone_PriceStopMethod, ::Meta_Timezone_PriceStopLevel,
                  ::Meta_Timezone_TickFilterMethod, ::Meta_Timezone_MaxSpread, ::Meta_Timezone_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Timezone_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Timezone_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Timezone_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Timezone_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Timezone_SignalOpenFilterTime);
  }
};

class Stg_Meta_Timezone : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Timezone(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Timezone *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Timezone_Params_Defaults stg_timezone_defaults;
    StgParams _stg_params(stg_timezone_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Timezone(_stg_params, _tparams, _cparams, "(Meta) Timezone");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Timezone_Strategy_London, STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_LONDON));
    StrategyAdd(Meta_Timezone_Strategy_NewYork, STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_NEWYORK));
    StrategyAdd(Meta_Timezone_Strategy_Sydney, STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_SYDNEY));
    StrategyAdd(Meta_Timezone_Strategy_Tokyo, STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_TOKYO));
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
    MarketTimeForex _mtf;
    Ref<Strategy> _strat_ref;
    _strat_ref = strats.GetByKey(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_LONDON));
    if (_strat_ref.IsSet() && _mtf.CheckHours(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_LONDON))) {
      _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    }
    _strat_ref = strats.GetByKey(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_NEWYORK));
    if (_strat_ref.IsSet() && _mtf.CheckHours(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_NEWYORK))) {
      _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    }
    _strat_ref = strats.GetByKey(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_SYDNEY));
    if (_strat_ref.IsSet() && _mtf.CheckHours(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_SYDNEY))) {
      _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result |= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    }
    _strat_ref = strats.GetByKey(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_TOKYO));
    if (_strat_ref.IsSet() && _mtf.CheckHours(STRUCT_ENUM(MarketTimeForex, MARKET_TIME_FOREX_HOURS_TOKYO))) {
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

#endif  // STG_META_TIMEZONE_MQH
