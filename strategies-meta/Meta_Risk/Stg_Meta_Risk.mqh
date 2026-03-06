/**
 * @file
 * Implements Risk meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_RISK_MQH
#define STG_META_RISK_MQH

// User input params.
INPUT2_GROUP("Meta Risk strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Risk_Strategy_Risk_Low = STRAT_RSI;         // Strategy for low risk
INPUT2 ENUM_STRATEGY Meta_Risk_Strategy_Risk_Medium = STRAT_CHAIKIN;  // Strategy for medium risk
INPUT2 ENUM_STRATEGY Meta_Risk_Strategy_Risk_High = STRAT_RSI;        // Strategy for high risk
INPUT3_GROUP("Meta Risk strategy: common params");
INPUT3 float Meta_Risk_LotSize = 0;                // Lot size
INPUT3 int Meta_Risk_SignalOpenMethod = 255;       // Signal open method
INPUT3 float Meta_Risk_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Risk_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Risk_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Risk_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Risk_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Risk_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Risk_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Risk_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Risk_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Risk_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Risk_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Risk_Shift = 0;                  // Shift
INPUT3 float Meta_Risk_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Risk_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Risk_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta Risk strategy: Risk oscillator params");
INPUT int Meta_Risk_Risk_Period = 14;                                    // Period
INPUT ENUM_APPLIED_PRICE Meta_Risk_Risk_Applied_Price = PRICE_TYPICAL;   // Applied Price
INPUT int Meta_Risk_Risk_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_Risk_Risk_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Risk_Params_Defaults : StgParams {
  Stg_Meta_Risk_Params_Defaults()
      : StgParams(::Meta_Risk_SignalOpenMethod, ::Meta_Risk_SignalOpenFilterMethod, ::Meta_Risk_SignalOpenLevel,
                  ::Meta_Risk_SignalOpenBoostMethod, ::Meta_Risk_SignalCloseMethod, ::Meta_Risk_SignalCloseFilter,
                  ::Meta_Risk_SignalCloseLevel, ::Meta_Risk_PriceStopMethod, ::Meta_Risk_PriceStopLevel,
                  ::Meta_Risk_TickFilterMethod, ::Meta_Risk_MaxSpread, ::Meta_Risk_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Risk_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Risk_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Risk_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Risk_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Risk_SignalOpenFilterTime);
  }
};

class Stg_Meta_Risk : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Risk(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Risk *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Risk_Params_Defaults stg_meta_risk_defaults;
    StgParams _stg_params(stg_meta_risk_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Risk(_stg_params, _tparams, _cparams, "(Meta) Risk");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Risk_Strategy_Risk_Low, 0);
    StrategyAdd(Meta_Risk_Strategy_Risk_Medium, 1);
    StrategyAdd(Meta_Risk_Strategy_Risk_High, 2);
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
   * Gets strategy risk.
   */
  Ref<Strategy> GetRiskStrategy(ENUM_ORDER_TYPE _cmd, uint _method = 0) {
    float _risk = GetRiskValue(_cmd, _method);
    Ref<Strategy> _strat_ref = strats.GetByKey(1);
    Chart *_chart = trade.GetChart();
    if (_risk > 0.6f) {
      // Risk value is high.
      _strat_ref = strats.GetByKey(2);
    } else if (_risk < 0.4f) {
      // Risk value is low.
      _strat_ref = strats.GetByKey(0);
    }
    return _strat_ref;
  }

  /**
   * Gets the risk value.
   */
  float GetRiskValue(ENUM_ORDER_TYPE _cmd, uint _method = 0, int _shift = 0) {
    float _risk = 0.5f;
    Chart *_c = trade.GetChart();
    if (METHOD(_method, 0)) _risk += trade.IsPeak(_cmd, _shift) ? 0.1f : -0.1f;
    if (METHOD(_method, 1)) _risk += !trade.IsPivot(_cmd, _shift) ? 0.1f : -0.1f;
    if (METHOD(_method, 2)) _risk += !IsTrend(_cmd) ? 0.1f : -0.1f;
    if (METHOD(_method, 3))
      _risk += _c.GetVolume(PERIOD_D1, _shift) > _c.GetVolume(PERIOD_D1, _shift + 1) ? 0.1f : -0.1f;
    if (METHOD(_method, 4))
      _risk += _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_R1) || _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_S1)
                   ? 0.1f
                   : -0.0f;
    if (METHOD(_method, 5))
      _risk += _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_R2) || _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_S2)
                   ? 0.1f
                   : -0.0f;
    if (METHOD(_method, 6))
      _risk += _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_R3) || _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_S3)
                   ? 0.1f
                   : -0.0f;
    if (METHOD(_method, 7))
      _risk += _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_R4) || _c.CheckCondition(CHART_COND_BAR_CLOSE_GT_PP_S4)
                   ? 0.1f
                   : -0.0f;
    return _risk;
  }

  /**
   * Checks if the current price is in trend given the order type.
   */
  bool IsTrend(ENUM_ORDER_TYPE _cmd) {
    bool _result = false;
    double _tvalue = GetTrendStrength();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _tvalue > sparams.trend_threshold;
        break;
      case ORDER_TYPE_SELL:
        _result = _tvalue < -sparams.trend_threshold;
        break;
    }
    return _result;
  }

  /**
   * Gets trend strength value.
   */
  float GetTrendStrength(ENUM_TIMEFRAMES _tf = PERIOD_D1, int _shift = 1) {
    float _result = 0;
    Chart *_c = trade.GetChart();
    if (_c.IsValidShift(_shift)) {
      ChartEntry _bar1 = _c.GetEntry(_tf, _shift);
      float _range = _bar1.bar.ohlc.GetRange();
      if (_range > 0) {
        float _open = (float)_c.GetOpen(_tf);
        float _pp = _bar1.bar.ohlc.GetPivot();
        _result = 1 / _range * (_open - _pp);
        _result = fmin(1, fmax(-1, _result));
      }
    }
    return _result;
  };

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
    Ref<Strategy> _strat_ref = GetRiskStrategy(_cmd, _method);
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
    Ref<Strategy> _strat_ref = GetRiskStrategy(_cmd, _method);
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

#endif  // STG_META_RISK_MQH
