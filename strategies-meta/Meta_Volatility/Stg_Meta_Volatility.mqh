/**
 * @file
 * Implements Volatility meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_VOLATILITY_MQH
#define STG_META_VOLATILITY_MQH

// User input params.
INPUT2_GROUP("Meta Volatility strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Volatility_Strategy_Volatility_Normal = STRAT_MA;          // Strategy for neutral volatility
INPUT2 ENUM_STRATEGY Meta_Volatility_Strategy_Volatility_Strong = STRAT_STOCHASTIC;  // Strategy for strong volatility
INPUT2 ENUM_STRATEGY Meta_Volatility_Strategy_Volatility_Strong_Very =
    STRAT_STDDEV;  // Strategy for very strong volatility
INPUT3_GROUP("Meta Volatility strategy: common params");
INPUT3 float Meta_Volatility_LotSize = 0;                // Lot size
INPUT3 int Meta_Volatility_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_Volatility_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_Volatility_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_Volatility_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_Volatility_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_Volatility_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_Volatility_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_Volatility_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_Volatility_PriceStopMethod = 1;          // Price limit method
INPUT3 float Meta_Volatility_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_Volatility_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_Volatility_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_Volatility_Shift = 0;                  // Shift
INPUT3 float Meta_Volatility_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_Volatility_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_Volatility_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT3_GROUP("Meta Volatility strategy: RSI oscillator params");
INPUT3 int Meta_Volatility_RSI_Period = 8;                                     // Period
INPUT3 ENUM_APPLIED_PRICE Meta_Volatility_RSI_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT3 int Meta_Volatility_RSI_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Volatility_RSI_SourceType = IDATA_BUILTIN;  // Source type
INPUT3_GROUP("Meta Volatility: Volumes oscillator params");
INPUT3 ENUM_APPLIED_VOLUME Meta_Volatility_VOL_InpVolumeType = VOLUME_TICK;    // Volumes
INPUT3 int Meta_Volatility_VOL_Shift = 0;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Volatility_VOL_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Volatility_Params_Defaults : StgParams {
  Stg_Meta_Volatility_Params_Defaults()
      : StgParams(::Meta_Volatility_SignalOpenMethod, ::Meta_Volatility_SignalOpenFilterMethod,
                  ::Meta_Volatility_SignalOpenLevel, ::Meta_Volatility_SignalOpenBoostMethod,
                  ::Meta_Volatility_SignalCloseMethod, ::Meta_Volatility_SignalCloseFilter,
                  ::Meta_Volatility_SignalCloseLevel, ::Meta_Volatility_PriceStopMethod,
                  ::Meta_Volatility_PriceStopLevel, ::Meta_Volatility_TickFilterMethod, ::Meta_Volatility_MaxSpread,
                  ::Meta_Volatility_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Volatility_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Volatility_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Volatility_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Volatility_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Volatility_SignalOpenFilterTime);
  }
};

class Stg_Meta_Volatility : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Volatility(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Volatility *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Volatility_Params_Defaults stg_meta_volatility_defaults;
    StgParams _stg_params(stg_meta_volatility_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Volatility(_stg_params, _tparams, _cparams, "(Meta) Volatility");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Volatility_Strategy_Volatility_Normal, 0);
    StrategyAdd(Meta_Volatility_Strategy_Volatility_Strong, 1);
    StrategyAdd(Meta_Volatility_Strategy_Volatility_Strong_Very, 2);
    // Initialize indicators.
    // Initialize RSI.
    IndiRSIParams _indi_params0(::Meta_Volatility_RSI_Period, ::Meta_Volatility_RSI_Applied_Price,
                                ::Meta_Volatility_RSI_Shift);
    _indi_params0.SetDataSourceType(::Meta_Volatility_RSI_SourceType);
    _indi_params0.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    //_indi_params0.SetTf(PERIOD_D1);
    SetIndicator(new Indi_RSI(_indi_params0), 0);
    // Initialize Volumes.
    IndiVolumesParams _indi_params1(::Meta_Volatility_VOL_InpVolumeType, ::Meta_Volatility_VOL_Shift);
    _indi_params1.SetDataSourceType(::Meta_Volatility_VOL_SourceType);
    _indi_params1.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    //_indi_params1.SetTf(PERIOD_D1);
    SetIndicator(new Indi_Volumes(_indi_params1), 1);
    // Initialize RSI over Volumes.
    IndicatorBase *_indi_rsi = GetIndicator(0);
    IndicatorBase *_indi_vol = GetIndicator(1);
    _indi_rsi.SetDataSource(_indi_vol);
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
    IndicatorBase *_indi = GetIndicator();
    Ref<Strategy> _strat_ref;
    uint _ishift = 0;
    float _value = (float)_indi[_ishift][0];
    if (_indi[_ishift][0] == 0) {
      // @fixme
      return false;
    }
    if (_indi[_ishift][0] <= 20 || _indi[_ishift][0] >= 80) {
      // Volatility value is at peak range (0-20 or 80-100).
      _strat_ref = strats.GetByKey(2);
    } else if (_indi[_ishift][0] < 40 || _indi[_ishift][0] > 60) {
      // Volatility value is at trend range (20-40 or 60-80).
      _strat_ref = strats.GetByKey(1);
    } else if (_indi[_ishift][0] > 40 && _indi[_ishift][0] < 60) {
      // Volatility value is at neutral range (40-60).
      _strat_ref = strats.GetByKey(0);
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
    uint _ishift = _shift;
    IndicatorBase *_indi = GetIndicator();
    Ref<Strategy> _strat_ref;
    float _value = (float)_indi[_ishift][0];
    if (_indi[_ishift][0] == 0) {
      // @fixme
      return false;
    }
    if (_indi[_ishift][0] <= 20 || _indi[_ishift][0] >= 80) {
      // Volatility value is at peak range (0-20 or 80-100).
      _strat_ref = strats.GetByKey(2);
    } else if (_indi[_ishift][0] < 40 || _indi[_ishift][0] > 60) {
      // Volatility value is at trend range (20-40 or 60-80).
      _strat_ref = strats.GetByKey(1);
    } else if (_indi[_ishift][0] > 40 && _indi[_ishift][0] < 60) {
      // Volatility value is at neutral range (40-60).
      _strat_ref = strats.GetByKey(0);
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

#endif  // STG_META_VOLATILITY_MQH
