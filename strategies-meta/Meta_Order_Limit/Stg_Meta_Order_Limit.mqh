/**
 * @file
 * Implements Order Limit meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_ORDER_LIMIT_MQH
#define STG_META_ORDER_LIMIT_MQH

// User input params.
INPUT2_GROUP("Meta Order Limit strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Order_Limit_Strategy = STRAT_RSI;  // Strategy for order limits
INPUT3_GROUP("Meta Order Limit strategy: common params");
INPUT3 float Meta_Order_Limit_LotSize = 0;                // Lot size
INPUT3 int Meta_Order_Limit_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Order_Limit_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Order_Limit_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Order_Limit_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Order_Limit_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Order_Limit_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Order_Limit_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Order_Limit_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Order_Limit_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Order_Limit_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Order_Limit_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Order_Limit_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Order_Limit_Shift = 0;                  // Shift
INPUT3 float Meta_Order_Limit_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Order_Limit_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Order_Limit_OrderCloseTime = 1440;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Order_Limit_Params_Defaults : StgParams {
  Stg_Meta_Order_Limit_Params_Defaults()
      : StgParams(::Meta_Order_Limit_SignalOpenMethod, ::Meta_Order_Limit_SignalOpenFilterMethod,
                  ::Meta_Order_Limit_SignalOpenLevel, ::Meta_Order_Limit_SignalOpenBoostMethod,
                  ::Meta_Order_Limit_SignalCloseMethod, ::Meta_Order_Limit_SignalCloseFilter,
                  ::Meta_Order_Limit_SignalCloseLevel, ::Meta_Order_Limit_PriceStopMethod,
                  ::Meta_Order_Limit_PriceStopLevel, ::Meta_Order_Limit_TickFilterMethod, ::Meta_Order_Limit_MaxSpread,
                  ::Meta_Order_Limit_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Order_Limit_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Order_Limit_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Order_Limit_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Order_Limit_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Order_Limit_SignalOpenFilterTime);
  }
};

class Stg_Meta_Order_Limit : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;

 public:
  Stg_Meta_Order_Limit(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Order_Limit *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Order_Limit_Params_Defaults stg_meta_order_limit_defaults;
    StgParams _stg_params(stg_meta_order_limit_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Order_Limit(_stg_params, _tparams, _cparams, "(Meta) Order Limit");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(Meta_Order_Limit_Strategy, 0);
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
   * Gets symbol.
   */
  string GetSymbol(int _index) {
    int _total_symbols = SymbolsTotal(true);
    return SymbolName(_index, true);
  }

  /**
   * Process a trade request.
   *
   * @return
   *   Returns true on successful request.
   */
  virtual bool TradeRequest(ENUM_ORDER_TYPE _cmd, Strategy *_strat = NULL, int _shift = 0) {
    bool _result = false;
    double _offset =
        strade.GetChart().GetPointSize() * 50;  // Offset from the current price to place the order in points.
    /*
    Ref<Strategy> _strat_ref = GetStrategy(_shift);
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    */
    // Prepare a request.
    MqlTradeRequest _request = strade.GetTradeOpenRequest(_cmd);
    _request.action = TRADE_ACTION_PENDING;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _request.price -= _offset;
        _request.type = ORDER_TYPE_BUY_LIMIT;
        break;
      case ORDER_TYPE_SELL:
        _request.price += _offset;
        _request.type = ORDER_TYPE_SELL_LIMIT;
        break;
    }
    _request.magic = /*_strat_ref.Ptr().*/ Get<long>(STRAT_PARAM_ID);
    // Prepare an order parameters.
    OrderParams _oparams;
    /*_strat_ref.Ptr().*/ OnOrderOpen(_oparams);
    // Send the request.
    _result = strade.RequestSend(_request, _oparams);
    return _result;
  }

  /**
   * Event on strategy's order open.
   */
  virtual void OnOrderOpen(OrderParams &_oparams) {
    // @todo: EA31337-classes/issues/723
    Strategy::OnOrderOpen(_oparams);
  }

  /**
   * Gets price stop value.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    uint _shift = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
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
    bool _result = true, _result1 = false;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    // Process strategy.
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    if (_strat_ref.IsSet()) {
      _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result1 = _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      if (_result1) {
        // @todo: Move to OnOrderOpen().
        TradeRequest(_cmd, GetPointer(this), _shift);
      }
    }
    return _result && _result1;
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

#endif  // STG_META_ORDER_LIMIT_MQH
