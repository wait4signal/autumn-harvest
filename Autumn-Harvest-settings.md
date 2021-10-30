# **Autumn-Harvest EA**

**Settings**:   
The program allows for the following configurations to be set.    
Defaults are indicated in brackets. Where applicable, options are in brackets at the end of the description.

| Item `[defaults in brackets]`       | Description `[valid values in brackets]`                                                                                                                                                                            |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **"Trading"**                       |   |
| FIXED_DEAL_AMOUNT_BUY `[1000.00]`   | Fixed amount to use per buy trade  |
| FIXED_DEAL_AMOUNT_SELL = 1000.00; //FIXED_DEAL_AMOUNT_SELL: Fixed amount to use per sell trade  |   |
| ALLOW_BUYING = true; //ALLOW_BUYING: EA is allowed to open BUY orders  |   |
| ALLOW_SELLING = true; //ALLOW_SELLING: EA is allowed to open SELL orders  |   |
| MAINTAIN_ANY_TIMEFRAME = false; //MAINTAIN_ANY_TIMEFRAME: EA allowed to maintain any position even if not matching current timeframe  |   |
| MAINTAIN_ANY_DEAL = true; //MAINTAIN_ANY_DEAL: EA allowed to maintain any position even if not opened by it  |   |
| MAX_SPREAD = 10; //MAX_SPREAD: Max spread, won't place trade if spread is above this value  |   |
| TRADE_CUTOFF_TIME = "20:00"; //TRADE_CUTOFF_TIME: No trading after this time  |   |
| **"Strategies"**                    |   |
| USE_IGNORED_BAR = true; //USE_IGNORED_BAR: Use ignored bar strategy by OV  |   |
| USE_RSI_REVERSAL_BUY = true; //USE_RSI_REVERSAL_BUY: Use rsi reversal strategy on BUY  |   |
| USE_RSI_REVERSAL_SELL = true; //USE_RSI_REVERSAL_SELL: Use rsi reversal strategy on SELL  |   |
| RSI_OB_LEVEL = 70.00; //RSI_OB_LEVEL: OverBought level marker  |   |
| RSI_OS_LEVEL = 30.00; //RSI_OS_LEVEL: OverSold level marker  |   |
| PEAK_OB_LEVEL = 60.00; //PEAK_OB_LEVEL: OverBought level for peak reversal  |   |
| PEAK_OS_LEVEL = 40.00; //PEAK_OS_LEVEL: OverSold level for peak reversal  |   |
| USE_PEAK_REVERSAL_BUY = true; //USE_PEAK_REVERSAL_BUY: Use peak bar reversal strategy on BUY  |   |
| USE_PEAK_REVERSAL_SELL = true; //USE_PEAK_REVERSAL_SELL: Use peak bar reversal strategy on SELL  |   |
| MA_AWAY_PERC = 0.0005; //MA_AWAY_PERC: Percentage by which price can be away from MA  |   |
| USE_LONG_MA_IB = false; //USE_LONG_MA_IB: Use long MA (200MA) for trend IB guidance, this results in fewer but more accurate entries  |   |
| USE_LONG_MA_PEAK = false; //USE_LONG_MA_PEAK: Use long MA (200MA) for trend PEAK guidance, this results in fewer but more accurate entries  |   |
| USE_LONG_MA_RSI = false; //USE_LONG_MA_RSI: Use long MA (200MA) for trend RSI guidance, this results in fewer but more accurate entries  |   |
| PRICE_TO_TRADEMA_ATR_PERC = 1.50; //PRICE_TO_TRADEMA_ATR: Minimum distance between price and TradeMA  |   |
| **"Risk Management"**               |   |
| TRADE_INTERVAL_BARS = 3; //TRADE_INTERVAL_BARS: Don't place trade if one exists within this interval (avoid duplicate)  |   |
| MAX_LOSING_DEALS = 2; //MAX_LOSING_DEALS: Max number of open losing deals for current symbol  |   |
| MAX_HEAVY_DD_DEALS = 6; //MAX_HEAVY_DD_DEALS: Max number of open deals whose drawndown is above 50% (no more deals till cleared)  |   |
| ALLOW_ADD_TO_LOSING_BUY_POSITION = true; //ALLOW_ADD_TO_LOSING_BUY_POSITION: Allow adding to losing buy position  |   |
| ALLOW_ADD_TO_LOSING_SELL_POSITION = true; //ALLOW_ADD_TO_LOSING_SELL_POSITION: Allow adding to losing sell position  |   |
| **"Entry/Exit"**                    |   |
| TRAIL_PROFIT = true; //TRAIL_PROFIT: Enable trailing profit after reaching a certain level  |   |
| TRAIL_LOSS = false; //TRAIL_LOSS: Adjust initial stoploss while still in negative (follows positive move until breakeven)  |   |
| BUY_MAX_LOSS_PERC = 0.00; //BUY_MAX_LOSS_PERC: If > 0.00 then deal will be closed at this loss level to limit exposure  |   |
| SELL_MAX_LOSS_PERC = 0.00; //SELL_MAX_LOSS_PERC: If > 0.00 then deal will be closed at this loss level to limit exposure  |   |
| TP_TRAIL_BUY_PERC = 0.025; //TP_TRAIL_BUY_PERC: Distance between TP and current price when LONG  |   |
| TP_TRAIL_SELL_PERC = 0.020; //TP_TRAIL_SELL_PERC: Distance between TP and current price when SHORT  |   |
| TP_PERC = 0.05; //TP_PERC: Acceptable profit on deal, can start trailing from there  |   |
| CLOSE_ON_REVERSAL = true; //CLOSE_ON_REVERSAL: Close position and take profit when price starts reversing  |   |
| CLOSE_ON_REVERSAL_MIN_PROFIT_PERC = 0.01; //CLOSE_ON_REVERSAL_MIN_PROFIT_PERC: Minimum required profit before closing on reversal  |   |
| ADD_ATR_TO_SL = false; //ADD_ATR_TO_SL: Whether to add ATR to stoploss as a buffer  |   |
| USE_SL_ON_BUY = true; //USE_SL_ON_BUY: Use stop loss on Long position  |   |
| USE_SL_ON_SELL = true; //USE_SL_ON_SELL: Use stop loss on Short position  |   |
| SL_BUFFER_POINT_PERC = 0.60; //SL_BUFFER_POINT_PERC: Point percentage to add to stoploss as a buffer  |   |
| **"Trade Opportunity Alerts"**      |   |
| ALERT_IGNORED_BAR_BUY = false; //ALERT_IGNORED_BAR_BUY: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_IGNORED_BAR_SELL = false; //ALERT_IGNORED_BAR_SELL: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_RSI_REVERSAL_BUY = false; //ALERT_RSI_REVERSAL_BUY: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_RSI_REVERSAL_SELL = false; //ALERT_RSI_REVERSAL_SELL: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_PEAK_REVERSAL_BUY = false; //ALERT_PEAK_REVERSAL_BUY: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_PEAK_REVERSAL_SELL = false; //ALERT_PEAK_REVERSAL_SELL: Whether to send an email alert when this trade opportunity occurs  |   |
| ALERT_INTERVAL_BARS = 3; //ALERT_INTERVAL_BARS: Number of bars to skip before we can send another alert for this symbol and timeframe  |   |
| **"Monitoring"**                    |   |
| HEARTBEAT_URL = ""; //HEARTBEAT_URL: Url to send heartbeat to  |   |
| HEARTBEAT_INTERVAL_MINUTES = 5; //HEARTBEAT_INTERVAL_MINUTES: How ofter to send the heartbeat  |   |
|   |   |