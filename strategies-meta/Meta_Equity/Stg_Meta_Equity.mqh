/**
 * @file
 * Implements Equity meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_EQUITY_MQH
#define STG_META_EQUITY_MQH

// User input params.
INPUT2_GROUP("Meta Equity strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Equity_Strategy_Equity_Normal = STRAT_MA_BREAKOUT;  // Strategy for normal equity (-5-5%)
INPUT2 ENUM_STRATEGY Meta_Equity_Strategy_Equity_GT_5 = STRAT_MA_TREND;       // Strategy for high equity (5-10%)
INPUT2 ENUM_STRATEGY Meta_Equity_Strategy_Equity_LT_5 = STRAT_MA_TREND;       // Strategy for low equity (-5-10%)
INPUT2 ENUM_STRATEGY Meta_Equity_Strategy_Equity_GT_10 = STRAT_NONE;          // Strategy for very high equity (>10%)
INPUT2 ENUM_STRATEGY Meta_Equity_Strategy_Equity_LT_10 = STRAT_NONE;          // Strategy for very low equity (<-10%)
INPUT3_GROUP("Meta Equity strategy: common params");
INPUT3 float Meta_Equity_LotSize = 0;                // Lot size
INPUT3 int Meta_Equity_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Equity_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Equity_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Equity_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Equity_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Equity_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Equity_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Equity_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Equity_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Equity_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Equity_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Equity_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Equity_Shift = 0;                  // Shift
INPUT3 float Meta_Equity_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Equity_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Equity_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Equity_Params_Defaults : StgParams {
  Stg_Meta_Equity_Params_Defaults()
      : StgParams(::Meta_Equity_SignalOpenMethod, ::Meta_Equity_SignalOpenFilterMethod, ::Meta_Equity_SignalOpenLevel,
                  ::Meta_Equity_SignalOpenBoostMethod, ::Meta_Equity_SignalCloseMethod, ::Meta_Equity_SignalCloseFilter,
                  ::Meta_Equity_SignalCloseLevel, ::Meta_Equity_PriceStopMethod, ::Meta_Equity_PriceStopLevel,
                  ::Meta_Equity_TickFilterMethod, ::Meta_Equity_MaxSpread, ::Meta_Equity_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Equity_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Equity_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Equity_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Equity_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Equity_SignalOpenFilterTime);
  }
};

class Stg_Meta_Equity : public Strategy {
 protected:
  Account account;
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Equity(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Equity *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Equity_Params_Defaults stg_meta_equity_defaults;
    StgParams _stg_params(stg_meta_equity_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Equity(_stg_params, _tparams, _cparams, "(Meta) Equity");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Equity_Strategy_Equity_Normal, 1);
    StrategyAdd(Meta_Equity_Strategy_Equity_GT_5, 2);
    StrategyAdd(Meta_Equity_Strategy_Equity_LT_5, 3);
    StrategyAdd(Meta_Equity_Strategy_Equity_GT_10, 4);
    StrategyAdd(Meta_Equity_Strategy_Equity_LT_10, 5);
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
    float _equity_pct = (float)Math::ChangeInPct(account.GetTotalBalance(), account.AccountEquity());
    Ref<Strategy> _strat_ref;
    if (_equity_pct > -5.0f && _equity_pct < 5.0f) {
      // Equity value is in normal range (between -5% and 5%).
      _strat_ref = strats.GetByKey(1);
    } else if (_equity_pct >= 10.0f) {
      // Equity value is very high (greater than 10%).
      _strat_ref = strats.GetByKey(4);
    } else if (_equity_pct <= -10.0f) {
      // Equity value is very low (lower than 10%).
      _strat_ref = strats.GetByKey(5);
    } else if (_equity_pct >= 5.0f) {
      // Equity value is high (between 5% and 10%).
      _strat_ref = strats.GetByKey(2);
    } else if (_equity_pct <= -5.0f) {
      // Equity value is low (between -5% and -10%).
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
    float _equity_pct = (float)Math::ChangeInPct(account.GetTotalBalance(), account.AccountEquity(), true);
    Ref<Strategy> _strat_ref;
    if (_equity_pct > -5.0f && _equity_pct < 5.0f) {
      // Equity value is in normal range (between -5% and 5%).
      _strat_ref = strats.GetByKey(1);
    } else if (_equity_pct >= 10.0f) {
      // Equity value is very high (greater than 10%).
      _strat_ref = strats.GetByKey(4);
    } else if (_equity_pct <= -10.0f) {
      // Equity value is very low (lower than 10%).
      _strat_ref = strats.GetByKey(5);
    } else if (_equity_pct >= 5.0f) {
      // Equity value is high (between 5% and 10%).
      _strat_ref = strats.GetByKey(2);
    } else if (_equity_pct <= -5.0f) {
      // Equity value is low (between -5% and -10%).
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

#endif  // STG_META_EQUITY_MQH
