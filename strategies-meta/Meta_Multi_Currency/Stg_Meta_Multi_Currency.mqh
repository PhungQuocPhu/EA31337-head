/**
 * @file
 * Implements Multi Currency meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_MULTI_CURRENCY_MQH
#define STG_META_MULTI_CURRENCY_MQH

// User input params.
INPUT2_GROUP("Meta Multi Currency strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Multi_Strategy_Symbol1 = STRAT_NONE;  // Strategy for symbol 1
INPUT2 ENUM_STRATEGY Meta_Multi_Strategy_Symbol2 = STRAT_NONE;  // Strategy for symbol 2
INPUT2 ENUM_STRATEGY Meta_Multi_Strategy_Symbol3 = STRAT_NONE;  // Strategy for symbol 3
INPUT2 ENUM_STRATEGY Meta_Multi_Strategy_Symbol4 = STRAT_NONE;  // Strategy for symbol 4
INPUT3_GROUP("Meta Multi Currency strategy: common params");
INPUT3 float Meta_Multi_Currency_LotSize = 0;                // Lot size
INPUT3 int Meta_Multi_Currency_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Multi_Currency_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Multi_Currency_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Multi_Currency_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Multi_Currency_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Multi_Currency_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Multi_Currency_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Multi_Currency_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Multi_Currency_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Multi_Currency_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Multi_Currency_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Multi_Currency_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Multi_Currency_Shift = 0;                  // Shift
INPUT3 float Meta_Multi_Currency_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Multi_Currency_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Multi_Currency_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Multi_Currency_Params_Defaults : StgParams {
  Stg_Meta_Multi_Currency_Params_Defaults()
      : StgParams(::Meta_Multi_Currency_SignalOpenMethod, ::Meta_Multi_Currency_SignalOpenFilterMethod,
                  ::Meta_Multi_Currency_SignalOpenLevel, ::Meta_Multi_Currency_SignalOpenBoostMethod,
                  ::Meta_Multi_Currency_SignalCloseMethod, ::Meta_Multi_Currency_SignalCloseFilter,
                  ::Meta_Multi_Currency_SignalCloseLevel, ::Meta_Multi_Currency_PriceStopMethod,
                  ::Meta_Multi_Currency_PriceStopLevel, ::Meta_Multi_Currency_TickFilterMethod,
                  ::Meta_Multi_Currency_MaxSpread, ::Meta_Multi_Currency_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Multi_Currency_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Multi_Currency_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Multi_Currency_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Multi_Currency_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Multi_Currency_SignalOpenFilterTime);
  }
};

class Stg_Meta_Multi_Currency : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;

 public:
  Stg_Meta_Multi_Currency(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Multi_Currency *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Multi_Currency_Params_Defaults stg_meta_multi_currency_defaults;
    StgParams _stg_params(stg_meta_multi_currency_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Multi_Currency(_stg_params, _tparams, _cparams, "(Meta) Multi Currency");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize strategies.
    StrategyAdd(Meta_Multi_Strategy_Symbol1, 1);
    StrategyAdd(Meta_Multi_Strategy_Symbol2, 2);
    StrategyAdd(Meta_Multi_Strategy_Symbol3, 3);
    StrategyAdd(Meta_Multi_Strategy_Symbol4, 4);
    // Assigns strategies to different symbols.
    Ref<Strategy> _strat_ref1 = strats.GetByKey(1);
    if (_strat_ref1.IsSet()) {
      // _strat_ref1.Ptr().Set<string>(CHART_PARAM_SYMBOL, _Symbol); // @fixme
    }
    Ref<Strategy> _strat_ref2 = strats.GetByKey(2);
    if (_strat_ref2.IsSet()) {
      // _strat_ref2.Ptr().Set<string>(CHART_PARAM_SYMBOL, _Symbol); // @fixme
    }
    Ref<Strategy> _strat_ref3 = strats.GetByKey(3);
    if (_strat_ref3.IsSet()) {
      // _strat_ref3.Ptr().Set<string>(CHART_PARAM_SYMBOL, _Symbol); // @fixme
    }
    Ref<Strategy> _strat_ref4 = strats.GetByKey(4);
    if (_strat_ref4.IsSet()) {
      // _strat_ref4.Ptr().Set<string>(CHART_PARAM_SYMBOL, _Symbol); // @fixme
    }
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
   * Gets strategy.
   */
  /*
  Ref<Strategy> GetStrategy(int _shift = 0) {
    // IndicatorBase *_indi = GetIndicator();
    uint _ishift = _shift + 1;  // + _indi.GetShift()?
    Ref<Strategy> _strat_ref;
    //_strat_ref = strats.GetByKey(0);
    return _strat_ref;
  }
  */

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
  virtual bool TradeRequest(ENUM_ORDER_TYPE _cmd, string _symbol = NULL, Strategy *_strat = NULL, int _shift = 0) {
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
    _request.comment = /*_strat_ref.Ptr().*/ GetOrderOpenComment();
    _request.magic = /*_strat_ref.Ptr().*/ Get<long>(STRAT_PARAM_ID);
    _request.price = SymbolInfoStatic::GetOpenOffer(_symbol, _cmd);
    _request.symbol = _symbol;
    _request.volume = fmax(/*_strat_ref.Ptr().*/ Get<float>(STRAT_PARAM_LS), SymbolInfoStatic::GetVolumeMin(_symbol));
    _request.volume = strade.NormalizeLots(_request.volume);
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
    Ref<Strategy> _strat_ref = strats.GetByKey(1);  // @todo: Support for multi-currency.
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
    bool _result = true, _result1 = false, _result2 = false, _result3 = false, _result4 = false;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    string _symbol = NULL;
    // Process strategy 1.
    Ref<Strategy> _strat_ref1 = strats.GetByKey(1);
    if (_strat_ref1.IsSet()) {
      _level = _level == 0.0f ? _strat_ref1.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref1.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref1.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result1 = _strat_ref1.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      if (_result1) {
        _symbol = SymbolName(0, true);
        TradeRequest(_cmd, _symbol, GetPointer(this), _shift);
      }
    }
    // Process strategy 2.
    Ref<Strategy> _strat_ref2 = strats.GetByKey(2);
    if (_strat_ref2.IsSet()) {
      _level = _level == 0.0f ? _strat_ref2.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref2.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref2.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result2 = _strat_ref2.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      if (_result2) {
        _symbol = SymbolName(1, true);
        TradeRequest(_cmd, _symbol, GetPointer(this), _shift);
      }
    }
    // Process strategy 3.
    Ref<Strategy> _strat_ref3 = strats.GetByKey(3);
    if (_strat_ref3.IsSet()) {
      _level = _level == 0.0f ? _strat_ref3.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref3.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref3.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result3 = _strat_ref3.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      if (_result3) {
        _symbol = SymbolName(2, true);
        TradeRequest(_cmd, _symbol, GetPointer(this), _shift);
      }
    }
    // Process strategy 4.
    Ref<Strategy> _strat_ref4 = strats.GetByKey(4);
    if (_strat_ref4.IsSet()) {
      _level = _level == 0.0f ? _strat_ref4.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
      _method = _method == 0 ? _strat_ref4.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
      _shift = _shift == 0 ? _strat_ref4.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
      _result3 = _strat_ref4.Ptr().SignalOpen(_cmd, _method, _level, _shift);
      if (_result4) {
        _symbol = SymbolName(3, true);
        TradeRequest(_cmd, _symbol, GetPointer(this), _shift);
      }
    }
    return _result1 || _result2 || _result3 || _result4;
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

#endif  // STG_META_MULTI_CURRENCY_MQH
