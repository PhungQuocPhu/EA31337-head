/**
 * @file
 * Implements Enhance meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_ENHANCE_MQH
#define STG_META_ENHANCE_MQH

// User input params.
INPUT2_GROUP("Meta Enhance strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Enhance_Strategy = STRAT_CHAIKIN;  // Strategy to reverse signals
INPUT3_GROUP("Meta Enhance strategy: common params");
INPUT3 float Meta_Enhance_LotSize = 0;                // Lot size
INPUT3 int Meta_Enhance_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Enhance_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Enhance_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Enhance_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Enhance_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Enhance_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Enhance_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Enhance_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Enhance_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Enhance_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Enhance_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Enhance_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Enhance_Shift = 0;                  // Shift
INPUT3 float Meta_Enhance_OrderCloseLoss = 30;        // Order close loss
INPUT3 float Meta_Enhance_OrderCloseProfit = 30;      // Order close profit
INPUT3 int Meta_Enhance_OrderCloseTime = -10;         // Order close time in mins (>0) or bars (<0)

// Structs.

// Defines struct with default user strategy values.
struct Stg_Meta_Enhance_Params_Defaults : StgParams {
  Stg_Meta_Enhance_Params_Defaults()
      : StgParams(::Meta_Enhance_SignalOpenMethod, ::Meta_Enhance_SignalOpenFilterMethod,
                  ::Meta_Enhance_SignalOpenLevel, ::Meta_Enhance_SignalOpenBoostMethod,
                  ::Meta_Enhance_SignalCloseMethod, ::Meta_Enhance_SignalCloseFilter, ::Meta_Enhance_SignalCloseLevel,
                  ::Meta_Enhance_PriceStopMethod, ::Meta_Enhance_PriceStopLevel, ::Meta_Enhance_TickFilterMethod,
                  ::Meta_Enhance_MaxSpread, ::Meta_Enhance_Shift) {
    Set(STRAT_PARAM_LS, Meta_Enhance_LotSize);
    Set(STRAT_PARAM_OCL, Meta_Enhance_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Meta_Enhance_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Meta_Enhance_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Meta_Enhance_SignalOpenFilterTime);
  }
};

class Stg_Meta_Enhance : public Strategy {
 protected:
  bool should_enhance;
  ChartEntry centry;
  DictStruct<long, Ref<Strategy>> strats;
  Trade strade;

 public:
  Stg_Meta_Enhance(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name), strade(_tparams, _cparams) {}

  static Stg_Meta_Enhance *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Enhance_Params_Defaults stg_meta_enhance_defaults;
    StgParams _stg_params(stg_meta_enhance_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Enhance(_stg_params, _tparams, _cparams, "(Meta) Enhance");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() { StrategyAdd(Meta_Enhance_Strategy, 0); }

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
      should_enhance = false;
    }
  }

  /**
   * Event on strategy's order open.
   */
  virtual void OnOrderOpen(OrderParams &_oparams) {
    // @todo: EA31337-classes/issues/723
    Strategy::OnOrderOpen(_oparams);
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (_strat.IsSet()) {
      Chart *_chart = trade.GetChart();
      centry = _chart.GetEntry();
      should_enhance = true;
      // BarOHLC _ohlc[2];
      //_ohlc[0] = _chart.GetOHLC(_ishift);
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
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return (float)_result;
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
    Chart *_chart = trade.GetChart();
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    if (_result) {
      should_enhance = false;
    } else if (should_enhance) {
      ChartEntry _centry_curr = _chart.GetEntry(_shift);
      BarEntry _bentry_curr = _centry_curr.GetBar();
      BarEntry _bentry_prev = centry.GetBar();
      BarOHLC _ohlc_curr = _bentry_curr.GetOHLC();
      BarOHLC _ohlc_prev = _bentry_prev.GetOHLC();
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          // Buy signal.
          _result = _ohlc_curr.GetHigh() < _ohlc_prev.GetLow();
          break;
        case ORDER_TYPE_SELL:
          // Sell signal.
          _result = _ohlc_curr.GetLow() > _ohlc_prev.GetHigh();
          break;
      }
      if (_result) {
        should_enhance = false;
      }
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SCL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SCM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat.Ptr().SignalClose(_cmd, _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_ENHANCE_MQH
