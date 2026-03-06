/**
 * @file
 * Implements Trend meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_TREND_MQH
#define STG_META_TREND_MQH

// User input params.
INPUT2_GROUP("Meta Trend strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Trend_Strategy = STRAT_OSCILLATOR_RANGE;  // Strategy to filter by trend
INPUT3_GROUP("Meta Trend strategy: common params");
INPUT3 float Meta_Trend_LotSize = 0;                // Lot size
INPUT3 int Meta_Trend_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Trend_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Trend_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Trend_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Trend_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Trend_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Trend_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Trend_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Trend_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_Trend_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Trend_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Trend_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Trend_Shift = 0;                  // Shift
INPUT3 float Meta_Trend_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Trend_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Trend_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta Trend strategy: RSI oscillator params");
INPUT int Meta_Trend_RSI_Period = 16;                                    // Period
INPUT ENUM_APPLIED_PRICE Meta_Trend_RSI_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT int Meta_Trend_RSI_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_Trend_RSI_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Trend_Params_Defaults : StgParams {
  Stg_Meta_Trend_Params_Defaults()
      : StgParams(::Meta_Trend_SignalOpenMethod, ::Meta_Trend_SignalOpenFilterMethod, ::Meta_Trend_SignalOpenLevel,
                  ::Meta_Trend_SignalOpenBoostMethod, ::Meta_Trend_SignalCloseMethod, ::Meta_Trend_SignalCloseFilter,
                  ::Meta_Trend_SignalCloseLevel, ::Meta_Trend_PriceStopMethod, ::Meta_Trend_PriceStopLevel,
                  ::Meta_Trend_TickFilterMethod, ::Meta_Trend_MaxSpread, ::Meta_Trend_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Trend_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Trend_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Trend_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Trend_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Trend_SignalOpenFilterTime);
  }
};

class Stg_Meta_Trend : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Trend(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Trend *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Trend_Params_Defaults stg_trend_defaults;
    StgParams _stg_params(stg_trend_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Trend(_stg_params, _tparams, _cparams, "(Meta) Trend");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Trend_Strategy, 0);
    // Initialize indicators.
    {
      IndiRSIParams _indi_params(::Meta_Trend_RSI_Period, ::Meta_Trend_RSI_Applied_Price, ::Meta_Trend_RSI_Shift);
      _indi_params.SetDataSourceType(::Meta_Trend_RSI_SourceType);
      _indi_params.SetTf(PERIOD_D1);
      SetIndicator(new Indi_RSI(_indi_params));
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
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    Ref<Strategy> _strat = strats.GetByKey(0);
    if (!_strat.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    IndicatorBase *_indi = GetIndicator();
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] >= 50 - _level && _indi[_shift + 1][0] >= 50 - _level;
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] <= 50 + _level && _indi[_shift + 1][0] <= 50 + _level;
        break;
    }
    _level = _level == 0.0f ? _strat.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat.Ptr().SignalOpen(_cmd, _method, _level, _shift);
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
    IndicatorBase *_indi = GetIndicator();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] <= 50 + _level && _indi[_shift + 1][0] <= 50 + _level;
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] >= 50 - _level && _indi[_shift + 1][0] >= 50 - _level;
        break;
    }
    return _result;
  }
};

#endif  // STG_META_TREND_MQH
