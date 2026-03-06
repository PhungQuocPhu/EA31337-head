/**
 * @file
 * Implements Profit meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_PROFIT_MQH
#define STG_META_PROFIT_MQH

// User input params.
INPUT2_GROUP("Meta Profit strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Profit_Strategy_Profit_D_LT_1PCT = STRAT_RSI;  // Strategy for daily profit below 1%
INPUT2 ENUM_STRATEGY Meta_Profit_Strategy_Profit_D_GT_1PCT = STRAT_AMA;  // Strategy for daily profit above 1%
// INPUT2 ENUM_STRATEGY Meta_Profit_Strategy_Profit_W_GT_5PCT = STRAT_NONE;  // Strategy for weekly profit above 5%
// (>5%)
INPUT3_GROUP("Meta Profit strategy: common params");
INPUT3 float Meta_Profit_LotSize = 0;                // Lot size
INPUT3 int Meta_Profit_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Profit_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Profit_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Profit_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Profit_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Profit_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Profit_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Profit_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Profit_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Profit_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Profit_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Profit_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Profit_Shift = 0;                  // Shift
INPUT3 float Meta_Profit_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Profit_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Profit_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Profit_Params_Defaults : StgParams {
  Stg_Meta_Profit_Params_Defaults()
      : StgParams(::Meta_Profit_SignalOpenMethod, ::Meta_Profit_SignalOpenFilterMethod, ::Meta_Profit_SignalOpenLevel,
                  ::Meta_Profit_SignalOpenBoostMethod, ::Meta_Profit_SignalCloseMethod, ::Meta_Profit_SignalCloseFilter,
                  ::Meta_Profit_SignalCloseLevel, ::Meta_Profit_PriceStopMethod, ::Meta_Profit_PriceStopLevel,
                  ::Meta_Profit_TickFilterMethod, ::Meta_Profit_MaxSpread, ::Meta_Profit_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Profit_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Profit_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Profit_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Profit_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Profit_SignalOpenFilterTime);
  }
};

class Stg_Meta_Profit : public Strategy {
 protected:
  float dbalance;
  Account account;
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Profit(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Profit *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Profit_Params_Defaults stg_meta_profit_defaults;
    StgParams _stg_params(stg_meta_profit_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Profit(_stg_params, _tparams, _cparams, "(Meta) Profit");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Profit_Strategy_Profit_D_LT_1PCT, 1);
    StrategyAdd(Meta_Profit_Strategy_Profit_D_GT_1PCT, 2);
    // StrategyAdd(Meta_Profit_Strategy_Profit_W_GT_5PCT, 3);
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
   * Event on new time periods.
   */
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      // Reset current daily balance.
      dbalance = account.GetTotalBalance();
    }
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
    float _profit_daily_pct = (float)Math::ChangeInPct(dbalance, account.GetTotalBalance(), true);
    float _profit_weekly_pct = 0;
    Ref<Strategy> _strat_ref;
    if (_profit_daily_pct < 1.0f) {
      // Daily profit below 1%.
      _strat_ref = strats.GetByKey(1);
    } else if (_profit_daily_pct >= 1.0f) {
      // Daily profit above 1%.
      _strat_ref = strats.GetByKey(2);
    } else if (_profit_weekly_pct >= 5.0f) {
      // Daily profit above 5%.
      _strat_ref = strats.GetByKey(3);
    }

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
    // uint _ishift = _indi.GetShift();
    float _profit_daily_pct = (float)Math::ChangeInPct(dbalance, account.GetTotalBalance(), true);
    float _profit_weekly_pct = 0;
    Ref<Strategy> _strat_ref;
    if (_profit_daily_pct < 1.0f) {
      // Daily profit below 1%.
      _strat_ref = strats.GetByKey(1);
    } else if (_profit_daily_pct >= 1.0f) {
      // Daily profit above 1%.
      _strat_ref = strats.GetByKey(2);
    } else if (_profit_weekly_pct >= 5.0f) {
      // Daily profit above 5%.
      _strat_ref = strats.GetByKey(3);
    }

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
    bool _result = false;
    _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_PROFIT_MQH
