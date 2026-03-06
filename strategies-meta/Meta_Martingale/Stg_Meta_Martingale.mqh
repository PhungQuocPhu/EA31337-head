/**
 * @file
 * Implements Martingale meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_MARTINGALE_MQH
#define STG_META_MARTINGALE_MQH

// User input params.
INPUT2_GROUP("Meta Martingale strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Martingale_Strategy = STRAT_RSI;  // Strategy
INPUT3_GROUP("Meta Martingale strategy: common params");
INPUT3 float Meta_Martingale_LotSize = 0;                // Lot size
INPUT3 int Meta_Martingale_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Martingale_SignalOpenLevel = 20;       // Signal open level
INPUT3 int Meta_Martingale_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Martingale_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Martingale_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Martingale_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Martingale_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Martingale_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Martingale_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Martingale_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Martingale_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Martingale_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Martingale_Shift = 0;                  // Shift
INPUT3 float Meta_Martingale_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Martingale_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Martingale_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Martingale_Params_Defaults : StgParams {
 protected:
  double opricemax, opricemin;

 public:
  Stg_Meta_Martingale_Params_Defaults()
      : StgParams(::Meta_Martingale_SignalOpenMethod, ::Meta_Martingale_SignalOpenFilterMethod,
                  ::Meta_Martingale_SignalOpenLevel, ::Meta_Martingale_SignalOpenBoostMethod,
                  ::Meta_Martingale_SignalCloseMethod, ::Meta_Martingale_SignalCloseFilter,
                  ::Meta_Martingale_SignalCloseLevel, ::Meta_Martingale_PriceStopMethod,
                  ::Meta_Martingale_PriceStopLevel, ::Meta_Martingale_TickFilterMethod, ::Meta_Martingale_MaxSpread,
                  ::Meta_Martingale_Shift),
        opricemax(0.0),
        opricemin(DBL_MAX) {
    Set(STRAT_PARAM_LS, ::Meta_Martingale_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Martingale_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Martingale_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Martingale_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Martingale_SignalOpenFilterTime);
  }
  // Getters.
  double GetPriceMax() { return opricemax; }
  double GetPriceMin() { return opricemin; }
  // Setters.
  void SetPriceMax(double _value) { opricemax = _value > 0.0 ? _value : 0.0; }
  void SetPriceMin(double _value) { opricemin = _value > 0.0 && _value != DBL_MAX ? _value : 0.0; }
};

class Stg_Meta_Martingale : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Stg_Meta_Martingale_Params_Defaults ssparams;
  Trade strade;

 public:
  Stg_Meta_Martingale(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Martingale *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Martingale_Params_Defaults stg_meta_martingale_defaults;
    StgParams _stg_params(stg_meta_martingale_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Martingale(_stg_params, _tparams, _cparams, "(Meta) Martingale");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Martingale_Strategy, 0);
    // Initialize indicators.
    {}
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
   * Loads active orders by magic number.
   */
  bool OrdersLoadByMagic() {
    double _opricemax = 0.0, _opricemin = DBL_MAX;
    ResetLastError();
    int _total_active = TradeStatic::TotalActive();
    unsigned long _magic_no = Get<long>(STRAT_PARAM_ID);  // strade.Get<long>(TRADE_PARAM_MAGIC_NO);
    DictStruct<long, Ref<Order>> *_orders_active = strade.GetOrdersActive();
    for (int pos = 0; pos < _total_active; pos++) {
      if (OrderStatic::SelectByPosition(pos)) {
        unsigned long _magic_no_order = OrderStatic::MagicNumber();
        if (_magic_no_order == _magic_no) {
          unsigned long _ticket = OrderStatic::Ticket();
          if (!_orders_active.KeyExists(_ticket)) {
            Ref<Order> _order = new Order(_ticket);
            double _order_price_open = _order.Ptr().Get<float>(ORDER_PROP_PRICE_OPEN);
            if (_order_price_open > _opricemax) {
              _opricemax = _order_price_open;
            } else if (_order_price_open < _opricemin) {
              _opricemin = _order_price_open;
            }
            _orders_active.Set(_ticket, _order);
          }
        }
      }
    }
    if (_opricemax != 0.0) {
      ssparams.SetPriceMax(_opricemax);
    }
    if (_opricemin != 0.0) {
      ssparams.SetPriceMin(_opricemin);
    }
    return GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Event on new time periods.
   */
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
      strade.UpdateStates();
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
      OrdersLoadByMagic();
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      DictStruct<long, Ref<Order>> _orders_active = strade.GetOrdersActive();
      _orders_active.Clear();
      OrdersLoadByMagic();
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
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _strat.Ptr().Get<int>(STRAT_PARAM_SOM);
    //_shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result = _strat.Ptr().PriceStop(_cmd, _mode, _method, _level /*, _shift*/);
    return (float)_result;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    // uint _ishift = _indi.GetShift();
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    if (!_result && strade.Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
      _result = true;
      double _level_pips = _level * Chart().GetPipSize();
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result &= ssparams.GetPriceMin() != 0.0;
          _result &= strade.GetChart().GetOpenOffer(_cmd) < ssparams.GetPriceMin() - _level_pips;
          if (_result && _method != 0) {
            // if (METHOD(_method, 0)) _result &= _martingale_ratio < 0;
            // if (METHOD(_method, 1)) _result &= _martingale_ratio <= _lots_ratio;
          }
          break;
        case ORDER_TYPE_SELL:
          _result &= ssparams.GetPriceMax() != 0.0;
          _result &= strade.GetChart().GetOpenOffer(_cmd) > ssparams.GetPriceMax() + _level_pips;
          if (_result && _method != 0) {
            // if (METHOD(_method, 0)) _result &= _martingale_ratio > 0;
            // if (METHOD(_method, 1)) _result &= _martingale_ratio >= _lots_ratio;
          }
          break;
      }
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

#endif  // STG_META_MARTINGALE_MQH
