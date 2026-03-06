/**
 * @file
 * Implements Hedge meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_HEDGE_MQH
#define STG_META_HEDGE_MQH

// User input params.
INPUT2_GROUP("Meta Hedge strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Hedge_Strategy = STRAT_MA_BREAKOUT;  // Strategy
INPUT3_GROUP("Meta Hedge strategy: common params");
INPUT3 float Meta_Hedge_LotSize = 0;                // Lot size
INPUT3 int Meta_Hedge_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Hedge_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Hedge_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Hedge_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Hedge_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Hedge_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Hedge_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Hedge_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Hedge_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Hedge_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Hedge_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Hedge_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Hedge_Shift = 0;                  // Shift
INPUT3 float Meta_Hedge_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Hedge_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Hedge_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Hedge_Params_Defaults : StgParams {
  Stg_Meta_Hedge_Params_Defaults()
      : StgParams(::Meta_Hedge_SignalOpenMethod, ::Meta_Hedge_SignalOpenFilterMethod, ::Meta_Hedge_SignalOpenLevel,
                  ::Meta_Hedge_SignalOpenBoostMethod, ::Meta_Hedge_SignalCloseMethod, ::Meta_Hedge_SignalCloseFilter,
                  ::Meta_Hedge_SignalCloseLevel, ::Meta_Hedge_PriceStopMethod, ::Meta_Hedge_PriceStopLevel,
                  ::Meta_Hedge_TickFilterMethod, ::Meta_Hedge_MaxSpread, ::Meta_Hedge_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Hedge_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Hedge_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Hedge_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Hedge_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Hedge_SignalOpenFilterTime);
  }
};

class Stg_Meta_Hedge : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;

 public:
  Stg_Meta_Hedge(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Hedge *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Hedge_Params_Defaults stg_meta_hedge_defaults;
    StgParams _stg_params(stg_meta_hedge_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Hedge(_stg_params, _tparams, _cparams, "(Meta) Hedge");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Hedge_Strategy, 0);
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
   * Gets lots ratio value.
   *
   * @returns
   *   Returns ratio of buys and sells between -1.0 and 1.0.
   */
  float GetLotsRatio(int _shift = 0) {
    float _lots_buys = 0.0f, _lots_sells = 0.0f, _lots_ratio = 0.0f;
    if (strade.Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
      DictStruct<long, Ref<Order>> _orders_active = strade.GetOrdersActive();
      Ref<OrderQuery> _oquery_ref;
      if (_orders_active.Size() > 0) {
        _oquery_ref = OrderQuery::GetInstance(_orders_active);
        _lots_buys =
            _oquery_ref.Ptr()
                .CalcSumByPropWithCond<ENUM_ORDER_PROPERTY_DOUBLE, ENUM_ORDER_PROPERTY_INTEGER, ENUM_ORDER_TYPE, float>(
                    ORDER_VOLUME_CURRENT, ORDER_TYPE, ORDER_TYPE_BUY);
        _lots_sells =
            _oquery_ref.Ptr()
                .CalcSumByPropWithCond<ENUM_ORDER_PROPERTY_DOUBLE, ENUM_ORDER_PROPERTY_INTEGER, ENUM_ORDER_TYPE, float>(
                    ORDER_VOLUME_CURRENT, ORDER_TYPE, ORDER_TYPE_SELL);
        float _lots_max = fmax(_lots_buys, _lots_sells);
        _lots_ratio = (1 / _lots_max * _lots_buys) - (1 / _lots_max * _lots_sells);
      }
    }
    return _lots_ratio;
  }

  /**
   * Loads active orders by magic number.
   */
  bool OrdersLoadByMagic() {
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
            _order.Ptr().Refresh(ORDER_VOLUME_CURRENT);
            if (_order.Ptr().Get<float>(ORDER_VOLUME_CURRENT) <= 0.0f) {
              // @fixme
              _order.Ptr().Set(ORDER_VOLUME_CURRENT, strade.GetChart().GetVolumeMin());
              ResetLastError();
            }
            _orders_active.Set(_ticket, _order);
          }
        }
      }
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
    if (_result) {
      float _lots_ratio = GetLotsRatio(_shift);
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result &= _lots_ratio <= 0;
          if (_result && _method != 0) {
            // if (METHOD(_method, 0)) _result &= _lots_ratio < ?;
            // if (METHOD(_method, 1)) _result &= _lots_ratio ...; // @todo
          }
          break;
        case ORDER_TYPE_SELL:
          _result &= _lots_ratio >= 0;
          if (_result && _method != 0) {
            // if (METHOD(_method, 0)) _result &= _lots_ratio > ?;
            // if (METHOD(_method, 1)) _result &= _lots_ratio ...; // @todo
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

#endif  // STG_META_HEDGE_MQH
