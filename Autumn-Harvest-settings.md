# **Autumn-Harvest EA**

**Settings**:   
The program allows for the following configurations to be set.    
Defaults are indicated in brackets. Where applicable, options are in brackets at the end of the description.

| Item `[defaults in brackets]`       | Description `[valid values in brackets]`                                                                                                                                                                            |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **"Trading"**                       |   |
| FIXED_DEAL_AMOUNT_BUY `[1000.00]`   | Fixed amount to use per buy trade  |
| FIXED_DEAL_AMOUNT_SELL `[1000.00]`  | Fixed amount to use per sell trade  |
| ALLOW_BUYING `[true]`               | EA is allowed to open BUY orders  |
| ALLOW_SELLING `[true]`              | EA is allowed to open SELL orders  |
| MAINTAIN_ANY_TIMEFRAME `[false]`    | EA allowed to maintain any position even if not matching current timeframe  |
| MAINTAIN_ANY_DEAL `[true]`          | EA allowed to maintain any position even if not opened by it  |
| MAX_SPREAD `[10]`                   | Max spread, won't place trade if spread is above this value  |
| TRADE_CUTOFF_TIME `["20:00"]`       | No trading after this time  (Trade server time) |
| **"Strategies"**                    |   |
| USE_IGNORED_BAR `[true]`            | Use ignored bar strategy by OV  |
| USE_RSI_REVERSAL_BUY `[true]`       | Use rsi reversal strategy on BUY  |
| USE_RSI_REVERSAL_SELL `[true]`      | Use rsi reversal strategy on SELL  |
| RSI_OB_LEVEL `[70.00]`              | OverBought level marker  |
| RSI_OS_LEVEL `[30.00]`              | OverSold level marker  |
| PEAK_OB_LEVEL `[60.00]`             | OverBought level for peak reversal  |
| PEAK_OS_LEVEL `[40.00]`             | OverSold level for peak reversal  |
| USE_PEAK_REVERSAL_BUY `[true]`      | Use peak bar reversal strategy on BUY  |
| USE_PEAK_REVERSAL_SELL `[true]`     | Use peak bar reversal strategy on SELL  |
| MA_AWAY_PERC `[0.0005]`             | Percentage by which price can be away from MA  |
| USE_LONG_MA_IB `[false]`            | Use long MA (200MA) for trend IB guidance, this results in fewer but more accurate entries  |
| USE_LONG_MA_PEAK `[false]`          | Use long MA (200MA) for trend PEAK guidance, this results in fewer but more accurate entries  |
| USE_LONG_MA_RSI `[false]`           | Use long MA (200MA) for trend RSI guidance, this results in fewer but more accurate entries  |
| PRICE_TO_TRADEMA_ATR_PERC `[1.50]`  | Minimum distance between price and TradeMA  |
| **"Risk Management"**               |   |
| TRADE_INTERVAL_BARS `[3]`           | Don't place trade if one exists within this interval (avoid duplicate)  |
| MAX_LOSING_DEALS `[2]`              | Max number of open losing deals for current symbol  |
| MAX_HEAVY_DD_DEALS `[6]`            | Max number of open deals whose drawndown is above 50% (no more deals till cleared)  |
| ALLOW_ADD_TO_LOSING_BUY_POSITION `[true]` | Allow adding to losing buy position  |
| ALLOW_ADD_TO_LOSING_SELL_POSITION `[true]` | Allow adding to losing sell position  |
| **"Entry/Exit"**                    |   |
| TRAIL_PROFIT `[true]`               | Enable trailing profit after reaching a certain level  |
| TRAIL_LOSS `[false]`                | Adjust initial stoploss while still in negative (follows positive move until breakeven)  |
| BUY_MAX_LOSS_PERC `[0.00]`          | If > 0.00 then deal will be closed at this loss level to limit exposure  |
| SELL_MAX_LOSS_PERC `[0.00]`         | If > 0.00 then deal will be closed at this loss level to limit exposure  |
| TP_TRAIL_BUY_PERC `[0.025]`         | Distance between TP and current price when LONG  |
| TP_TRAIL_SELL_PERC `[0.020]`        | Distance between TP and current price when SHORT  |
| TP_PERC `[0.05]`                    | Acceptable profit on deal, can start trailing from there  |
| CLOSE_ON_REVERSAL `[true]`          | Close position and take profit when price starts reversing  |
| CLOSE_ON_REVERSAL_MIN_PROFIT_PERC `[0.01]` | Minimum required profit before closing on reversal  |
| ADD_ATR_TO_SL `[false]`             | Whether to add ATR to stoploss as a buffer  |
| USE_SL_ON_BUY `[true]`              | Use stop loss on Long position  |
| USE_SL_ON_SELL `[true]`             | Use stop loss on Short position  |
| SL_BUFFER_POINT_PERC `[0.60]`       | Point percentage to add to stoploss as a buffer  |
| **"Trade Opportunity Alerts"**      |   |
| ALERT_IGNORED_BAR_BUY `[false]`     | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_IGNORED_BAR_SELL `[false]`    | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_RSI_REVERSAL_BUY `[false]`    | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_RSI_REVERSAL_SELL `[false]`   | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_PEAK_REVERSAL_BUY `[false]`   | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_PEAK_REVERSAL_SELL `[false]`  | Whether to send an email alert when this trade opportunity occurs  |
| ALERT_INTERVAL_BARS `[3]`           | Number of bars to skip before we can send another alert for this symbol and timeframe  |
| **"Monitoring"**                    |   |
| HEARTBEAT_URL `[""]`                | Url to send heartbeat to  |
| HEARTBEAT_INTERVAL_MINUTES `[5]`    | How often to send the heartbeat  |
|   |   |