/**
 * @file
 * Implements Limit meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_LIMIT_MQH
#define STG_META_LIMIT_MQH

// Limit conditions.
enum ENUM_STG_LIMIT_CONDITION {
  STG_LIMIT_COND_0_NONE = 0,  // None
  // STG_LIMIT_COND_IS_PEAK = TRADE_COND_IS_PEAK,    // Market is at peak level
  // STG_LIMIT_COND_IS_PIVOT = TRADE_COND_IS_PIVOT,  // Market is in pivot levels
};

// User input params.
INPUT2_GROUP("Meta Limit strategy: main params");
INPUT2 uint Meta_Limit_Max_Trades_Per_Day = 30;  // Maximum active trades per day (0=off)
// INPUT2 float Meta_Limit_Max_Lots_Per_Day = 1.0f;   // Maximum lots to trade per day
// INPUT2 ENUM_STG_LIMIT_CONDITION Meta_Limit_Condition1 = STG_LIMIT_COND_IS_PEAK;   // Limit condition 1
INPUT2 ENUM_STRATEGY Meta_Limit_Strategy_Main = STRAT_MA_BREAKOUT;  // Strategy
INPUT3_GROUP("Meta Limit strategy: common params");
INPUT3 float Meta_Limit_LotSize = 0;                // Lot size
INPUT3 int Meta_Limit_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Limit_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Limit_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Limit_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Limit_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Limit_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Limit_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Limit_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Limit_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Limit_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Limit_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Limit_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Limit_Shift = 0;                  // Shift
INPUT3 float Meta_Limit_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Limit_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Limit_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Limit_Params_Defaults : StgParams {
  Stg_Meta_Limit_Params_Defaults()
      : StgParams(::Meta_Limit_SignalOpenMethod, ::Meta_Limit_SignalOpenFilterMethod, ::Meta_Limit_SignalOpenLevel,
                  ::Meta_Limit_SignalOpenBoostMethod, ::Meta_Limit_SignalCloseMethod, ::Meta_Limit_SignalCloseFilter,
                  ::Meta_Limit_SignalCloseLevel, ::Meta_Limit_PriceStopMethod, ::Meta_Limit_PriceStopLevel,
                  ::Meta_Limit_TickFilterMethod, ::Meta_Limit_MaxSpread, ::Meta_Limit_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Limit_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Limit_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Limit_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Limit_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Limit_SignalOpenFilterTime);
  }
};

class Stg_Meta_Limit : public Strategy {
 protected:
  float daily_lots;
  uint daily_trades;
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;  // Trade instance.

 public:
  Stg_Meta_Limit(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams), daily_lots(0.0f) {}

  static Stg_Meta_Limit *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Limit_Params_Defaults stg_meta_limit_defaults;
    StgParams _stg_params(stg_meta_limit_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Limit(_stg_params, _tparams, _cparams, "(Meta) Limit");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() { StrategyAdd(Meta_Limit_Strategy_Main, 1); }

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
   * Event on new time periods.
   */
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      daily_trades = 0;
    }
  }

  /**
   * Event on strategy's order open.
   */
  virtual void OnOrderOpen(OrderParams &_oparams) {
    // @todo: EA31337-classes/issues/723
    Strategy::OnOrderOpen(_oparams);
    // daily_lots += _request.volume;
    daily_trades++;
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
    Ref<Strategy> _strat_ref = strats.GetByKey(1);
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
    if (::Meta_Limit_Max_Trades_Per_Day > 0 && daily_trades >= ::Meta_Limit_Max_Trades_Per_Day) {
      // Do not open trades when limit is reached.
      return false;
    }
    Ref<Strategy> _strat_ref;
    _strat_ref = strats.GetByKey(1);
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
    Ref<Strategy> _strat_ref;
    _strat_ref = strats.GetByKey(1);
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
};

#endif  // STG_META_LIMIT_MQH
