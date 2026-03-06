/**
 * @file
 * Implements SAR meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_SAR_MQH
#define STG_META_SAR_MQH

// User input params.
INPUT2_GROUP("Meta SAR strategy: main params");
INPUT2 ENUM_STRATEGY Meta_SAR_Strategy_SAR_1st = STRAT_RVI;               // Strategy on 1st SAR value after change
INPUT2 ENUM_STRATEGY Meta_SAR_Strategy_SAR_2nd = STRAT_ASI;               // Strategy on 2nd SAR value after change
INPUT2 ENUM_STRATEGY Meta_SAR_Strategy_SAR_3rd = STRAT_MA_CROSS_SUP_RES;  // Strategy on 3rd+ SAR value after change
INPUT3_GROUP("Meta SAR strategy: common params");
INPUT3 float Meta_SAR_LotSize = 0;                // Lot size
INPUT3 int Meta_SAR_SignalOpenMethod = 0;         // Signal open method
INPUT3 float Meta_SAR_SignalOpenLevel = 0;        // Signal open level
INPUT3 int Meta_SAR_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT3 int Meta_SAR_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT3 int Meta_SAR_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT3 int Meta_SAR_SignalCloseMethod = 0;        // Signal close method
INPUT3 int Meta_SAR_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT3 float Meta_SAR_SignalCloseLevel = 0;       // Signal close level
INPUT3 int Meta_SAR_PriceStopMethod = 0;          // Price limit method
INPUT3 float Meta_SAR_PriceStopLevel = 2;         // Price limit level
INPUT3 int Meta_SAR_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT3 float Meta_SAR_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT3 short Meta_SAR_Shift = 0;                  // Shift
INPUT3 float Meta_SAR_OrderCloseLoss = 200;       // Order close loss
INPUT3 float Meta_SAR_OrderCloseProfit = 200;     // Order close profit
INPUT3 int Meta_SAR_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Meta SAR strategy: SAR indicator params");
INPUT float Meta_SAR_Indi_SAR_Step = 0.011f;                           // Step
INPUT float Meta_SAR_Indi_SAR_Maximum_Stop = 0.1f;                     // Maximum stop
INPUT int Meta_SAR_Indi_SAR_Shift = 0;                                 // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Meta_SAR_SAR_SourceType = IDATA_BUILTIN;  // Source type

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_SAR_Params_Defaults : StgParams {
  Stg_Meta_SAR_Params_Defaults()
      : StgParams(::Meta_SAR_SignalOpenMethod, ::Meta_SAR_SignalOpenFilterMethod, ::Meta_SAR_SignalOpenLevel,
                  ::Meta_SAR_SignalOpenBoostMethod, ::Meta_SAR_SignalCloseMethod, ::Meta_SAR_SignalCloseFilter,
                  ::Meta_SAR_SignalCloseLevel, ::Meta_SAR_PriceStopMethod, ::Meta_SAR_PriceStopLevel,
                  ::Meta_SAR_TickFilterMethod, ::Meta_SAR_MaxSpread, ::Meta_SAR_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_SAR_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_SAR_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_SAR_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_SAR_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_SAR_SignalOpenFilterTime);
  }
};

class Stg_Meta_SAR : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_SAR(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_SAR *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_SAR_Params_Defaults stg_meta_sar_defaults;
    StgParams _stg_params(stg_meta_sar_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_SAR(_stg_params, _tparams, _cparams, "(Meta) SAR");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_SAR_Strategy_SAR_1st, 0);
    StrategyAdd(Meta_SAR_Strategy_SAR_2nd, 1);
    StrategyAdd(Meta_SAR_Strategy_SAR_3rd, 2);
    // Initialize indicators.
    {
      IndiSARParams _indi_params(::Meta_SAR_Indi_SAR_Step, ::Meta_SAR_Indi_SAR_Maximum_Stop, ::Meta_SAR_Indi_SAR_Shift);
      _indi_params.SetDataSourceType(::Meta_SAR_SAR_SourceType);
      _indi_params.SetTf(PERIOD_D1);
      SetIndicator(new Indi_SAR(_indi_params));
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
  Ref<Strategy> GetStrategy() {
    uint _ishift = 0;
    Chart *_chart = trade.GetChart();
    IndicatorBase *_indi = GetIndicator();
    Ref<Strategy> _strat_ref;
    double _price_open = _chart.GetOpen();
    bool _sar_gt_p = _indi[_ishift][0] > _price_open;
    bool _sar_lt_p = _indi[_ishift][0] < _price_open;
    bool _sar_dn1 = _sar_gt_p && _indi[_ishift + 1][0] < _indi[_ishift][0];
    bool _sar_up1 = _sar_lt_p && _indi[_ishift + 1][0] > _indi[_ishift][0];
    bool _sar_dn2 = _sar_gt_p && _indi[_ishift + 2][0] < _indi[_ishift][0];
    bool _sar_up2 = _sar_lt_p && _indi[_ishift + 2][0] > _indi[_ishift][0];
    bool _sar_dn3 = _sar_gt_p && _indi[_ishift + 3][0] < _indi[_ishift][0];
    bool _sar_up3 = _sar_lt_p && _indi[_ishift + 3][0] > _indi[_ishift][0];
    if (_sar_dn1 || _sar_up1) {
      _strat_ref = strats.GetByKey(0);
    } else if (_sar_dn2 || _sar_up2) {
      _strat_ref = strats.GetByKey(1);
    } else if (_sar_dn3 || _sar_up3) {
      _strat_ref = strats.GetByKey(2);
    }
    return _strat_ref;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    // uint _ishift = _indi.GetShift();
    uint _ishift = _shift;
    Ref<Strategy> _strat_ref = GetStrategy();
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

#endif  // STG_META_SAR_MQH
