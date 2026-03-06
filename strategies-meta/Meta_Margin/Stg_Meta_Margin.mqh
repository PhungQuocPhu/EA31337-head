/**
 * @file
 * Implements Margin meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_MARGIN_MQH
#define STG_META_MARGIN_MQH

// User input params.
INPUT2_GROUP("Meta Margin strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Margin_Strategy_Margin_GT_80 = STRAT_RSI;       // Strategy for free margin > 80%
INPUT2 ENUM_STRATEGY Meta_Margin_Strategy_Margin_GT_50 = STRAT_MA_TREND;  // Strategy for free margin (50%-80%)
INPUT2 ENUM_STRATEGY Meta_Margin_Strategy_Margin_LT_50 = STRAT_AMA;       // Strategy for free margin (20-50%)
INPUT2 ENUM_STRATEGY Meta_Margin_Strategy_Margin_LT_20 = STRAT_NONE;      // Strategy for free margin < 20%
INPUT3_GROUP("Meta Margin strategy: common params");
INPUT3 float Meta_Margin_LotSize = 0;                // Lot size
INPUT3 int Meta_Margin_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Margin_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Margin_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Margin_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Margin_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Margin_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Margin_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Margin_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Margin_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Margin_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Margin_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Margin_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Margin_Shift = 0;                  // Shift
INPUT3 float Meta_Margin_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Margin_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Margin_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Margin_Params_Defaults : StgParams {
  Stg_Meta_Margin_Params_Defaults()
      : StgParams(::Meta_Margin_SignalOpenMethod, ::Meta_Margin_SignalOpenFilterMethod, ::Meta_Margin_SignalOpenLevel,
                  ::Meta_Margin_SignalOpenBoostMethod, ::Meta_Margin_SignalCloseMethod, ::Meta_Margin_SignalCloseFilter,
                  ::Meta_Margin_SignalCloseLevel, ::Meta_Margin_PriceStopMethod, ::Meta_Margin_PriceStopLevel,
                  ::Meta_Margin_TickFilterMethod, ::Meta_Margin_MaxSpread, ::Meta_Margin_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Margin_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Margin_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Margin_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Margin_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Margin_SignalOpenFilterTime);
  }
};

class Stg_Meta_Margin : public Strategy {
 protected:
  Account account;
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Margin(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Margin *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Margin_Params_Defaults stg_margin_defaults;
    StgParams _stg_params(stg_margin_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Margin(_stg_params, _tparams, _cparams, "(Meta) Margin");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Margin_Strategy_Margin_GT_80, 1);
    StrategyAdd(Meta_Margin_Strategy_Margin_GT_50, 2);
    StrategyAdd(Meta_Margin_Strategy_Margin_LT_50, 3);
    StrategyAdd(Meta_Margin_Strategy_Margin_LT_20, 4);
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
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    // double _margin_free = account.GetMarginFreeInPct(); // GH-720: @fixme
    double _margin_free = 100 / account.GetBalance() * account.GetMarginFree();
    // double _margin_free =
    uint _ishift = _shift;
    Ref<Strategy> _strat_ref;
    if (_margin_free >= 80) {
      // Margin value is greater than 80% (between 80% and 100%).
      _strat_ref = strats.GetByKey(1);
    } else if (_margin_free >= 50) {
      // Margin value is greater than 50% (between 50% and 80%).
      _strat_ref = strats.GetByKey(2);
    } else if (_margin_free <= 20) {
      // Margin value is lesser than 20% (between 0% and 20%).
      _strat_ref = strats.GetByKey(4);
    } else if (_margin_free <= 50) {
      // Margin value is lesser than 50% (between 20% and 50%).
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

#endif  // STG_META_MARGIN_MQH
