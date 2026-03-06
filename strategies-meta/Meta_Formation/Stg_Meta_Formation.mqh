/**
 * @file
 * Implements Formation meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_FORMATION_MQH
#define STG_META_FORMATION_MQH

// Enums.
enum ENUM_STG_META_FORMATION_TYPE {
  STG_META_FORMATION_TYPE_COS,  // Cosine
#ifdef __MQL5__
  STG_META_FORMATION_TYPE_COSH,  // Cosine Hyperbolic
#endif
  STG_META_FORMATION_TYPE_SIN,  // Sine
#ifdef __MQL5__
  STG_META_FORMATION_TYPE_SINH,  // Sine Hyperbolic
#endif
};

// User input params.
INPUT2_GROUP("Meta Formation strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Formation_Strategy = STRAT_STDDEV;                            // Strategy for order limits
INPUT2 ENUM_STG_META_FORMATION_TYPE Meta_Formation_Type = STG_META_FORMATION_TYPE_COS;  // Type of formation
INPUT2 int Meta_Formation_Size = 2;  // Formation size (number of pending orders per side)
INPUT3_GROUP("Meta Formation strategy: common params");
INPUT3 float Meta_Formation_LotSize = 0;                // Lot size
INPUT3 int Meta_Formation_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Formation_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Formation_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Formation_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Formation_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Formation_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Formation_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Formation_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Formation_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Formation_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Formation_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Formation_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Formation_Shift = 0;                  // Shift
INPUT3 float Meta_Formation_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Formation_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Formation_OrderCloseTime = 1440;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Formation_Params_Defaults : StgParams {
  Stg_Meta_Formation_Params_Defaults()
      : StgParams(::Meta_Formation_SignalOpenMethod, ::Meta_Formation_SignalOpenFilterMethod,
                  ::Meta_Formation_SignalOpenLevel, ::Meta_Formation_SignalOpenBoostMethod,
                  ::Meta_Formation_SignalCloseMethod, ::Meta_Formation_SignalCloseFilter,
                  ::Meta_Formation_SignalCloseLevel, ::Meta_Formation_PriceStopMethod, ::Meta_Formation_PriceStopLevel,
                  ::Meta_Formation_TickFilterMethod, ::Meta_Formation_MaxSpread, ::Meta_Formation_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Formation_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Formation_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Formation_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Formation_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Formation_SignalOpenFilterTime);
  }
};

// Defines struct for formation entry.
struct Stg_Meta_Formation_Entry {
  bool needs_update;
  double relative_price, target_price;
  Ref<Order> order;
};

class Stg_Meta_Formation : public Strategy {
 protected:
  DictStruct<int, Stg_Meta_Formation_Entry> formation_long, formation_short;
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;

 public:
  Stg_Meta_Formation(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Formation *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Formation_Params_Defaults stg_meta_formation_defaults;
    StgParams _stg_params(stg_meta_formation_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Formation(_stg_params, _tparams, _cparams, "(Meta) Formation");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(Meta_Formation_Strategy, 0);
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
   * Process a trade request.
   *
   * @return
   *   Returns true on successful request.
   */
  virtual MqlTradeRequest TradeRequest(ENUM_ORDER_TYPE _cmd, double _offset, int _shift = 0) {
    bool _result = false;
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
    //_result = strade.RequestSend(_request, _oparams);
    return _request;
  }

  /**
   * Updates a formation.
   */
  virtual void UpdateFormation() {
    // Define the diameter and the number of points
    int _num_points = ::Meta_Formation_Size;  // Number of points per diameter
    // Calculates daily range.
    int _shift = 0;
    Chart *_chart = trade.GetChart();
    ChartEntry _ohlc_d1_0 = _chart.GetEntry(PERIOD_D1, _shift, _chart.GetSymbol());
    ChartEntry _ohlc_d1_1 = _chart.GetEntry(PERIOD_D1, _shift + 1, _chart.GetSymbol());
    double _high0 = _chart.GetHigh(PERIOD_D1, _shift);
    double _high1 = _chart.GetHigh(PERIOD_D1, _shift + 1);
    double _low0 = _chart.GetLow(PERIOD_D1, _shift);
    double _low1 = _chart.GetLow(PERIOD_D1, _shift + 1);
    double _high = fmax(_high0, _high1);
    double _low = fmin(_low0, _low1);
    double _open = _chart.GetOpen(_shift);
    double _range = (_high - _low);
    // Calculate the coordinates
    double _diameter = _range * 0.1;  // Desired diameter.
    double _offset = _chart.GetPointSize() * 50;
    for (int i = 0; i < _num_points; i++) {
      double y;
      Stg_Meta_Formation_Entry _fentry_long, _fentry_short;
      if (formation_long.KeyExists(i)) {
        _fentry_long = formation_long.GetByKey(i);
      }
      if (formation_short.KeyExists(i)) {
        _fentry_short = formation_short.GetByKey(i);
      }
      switch (::Meta_Formation_Type) {
        case STG_META_FORMATION_TYPE_COS:
          y = _diameter / 2 + _diameter / 2.0 * cos(i * 1.0 * M_PI / _num_points);
          break;
#ifdef __MQL5__
        case STG_META_FORMATION_TYPE_COSH:
          y = _diameter / 2.0 * cosh(i * 1.0 * M_PI / _num_points);
          break;
#endif
        case STG_META_FORMATION_TYPE_SIN:
          y = _diameter / 1.0 * sin(i * 1.0 * M_PI / _num_points);
          break;
#ifdef __MQL5__
        case STG_META_FORMATION_TYPE_SINH:
          y = _diameter / 2.0 * sinh(i * 1.0 * M_PI / _num_points);
          break;
#endif
        default:
          y = 0.0;
          break;
      }
      // Long formation
      _fentry_long.relative_price = y;
      _fentry_long.target_price = _chart.GetOpenOffer(ORDER_TYPE_BUY) + y + _offset;
      MqlTradeRequest _request_long = TradeRequest(ORDER_TYPE_BUY, _fentry_long.relative_price, _shift);
      if (!_fentry_long.order.IsSet()) {
        _fentry_long.order = new Order(_request_long);
        // _fentry_long.order = @todo;
      } else {
        MqlTradeResult _result_long;
        _request_long.action = TRADE_ACTION_MODIFY;
        _request_long.order = _fentry_long.order.Ptr().Get<long>(ORDER_PROP_TICKET);
        _fentry_long.order.Ptr().OrderSend(_request_long, _result_long);
      }
      formation_long.Set(i, _fentry_long);
      // Short formation.
      _fentry_short.relative_price = y;
      _fentry_short.target_price = _chart.GetOpenOffer(ORDER_TYPE_SELL) - y - _offset;
      MqlTradeRequest _request_short = TradeRequest(ORDER_TYPE_SELL, _fentry_short.relative_price, _shift);
      if (!_fentry_short.order.IsSet()) {
        _fentry_short.order = new Order(_request_short);
      } else {
        MqlTradeResult _result_short;
        _request_short.action = TRADE_ACTION_MODIFY;
        _request_short.order = _fentry_short.order.Ptr().Get<long>(ORDER_PROP_TICKET);
        _fentry_short.order.Ptr().OrderSend(_request_short, _result_short);
      }
      formation_short.Set(i, _fentry_short);
    }
  }

  /**
   * Event on strategy's order open.
   */
  virtual void OnOrderOpen(OrderParams &_oparams) {
    // @todo: EA31337-classes/issues/723
    Strategy::OnOrderOpen(_oparams);
  }

  /**
   * Event on new time periods.
   */
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
      UpdateFormation();
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      formation_long.Clear();
      formation_short.Clear();
    }
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
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    // Process strategy.
    Ref<Strategy> _strat_ref = strats.GetByKey(0);
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    if (_result) {
      // @todo: Move to OnOrderOpen().
      // TradeRequest(_cmd, GetPointer(this), _shift);
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

#endif  // STG_META_FORMATION_MQH
