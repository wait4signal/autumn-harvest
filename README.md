# **Autumn-Harvest** [MT5]

## **Features**
- Multiple strategies for entry and exit
- Open buy and sell positions and set applicable amounts for each
- Smart stop-loss and trailing stops levels
- EA can be set to only maintain own deals or any open deal
- eMail alerts on buy/sell signals
- Monitoring using heartbeat checks

## **About**
This a MetaTrader 5 EA and capable of opening trades using various strategies.   
Once the trades are open it also manages them and closes them accordingly based on profit targets or loss tolerance levels.   
The strategies used are mostly derived from the teachings of Oliver Velez. Especially the use of the two moving averages and the “Space Concept” applicable to them.

### **Timeframes**:
 The EA and it’s strategies work on any timeframe due to the fractal nature of the chart formations. However, my preferred time-frame is the 2 and 5 minute, and occasionally the 1 minute.

### **Stop-loss**: 
The use of stop-loss is highly recommended to ensure that lossed are kept under control.  
Oliver advises that a trade should be killed once the reason for entering has been invalidated. As such, one should never lose more than one bar since the entries are usually based on the bar formations, especially the bar preceding the current one.

### **Profitability**: 
The truth is that markets and trading are largely driven by human sentiment and as such it is currently difficult to code a successful/profitable EA that can beat competent human/manual traders.   
Luckily this market behaviour does result in repeating patterns that can be coded and traded through technical analysis and price action.   
On its own and using conservative risk management without drawdowns, this EA has been tested to break even. Meaning it wins some trades and loses some so over a given timeframe the balance remains the same. However it is quite flexible in settings that can be tweaked so it can be made profitable based on one’s risk appetite.   
More risk equals better rewards so each person needs to decide whether they are willing to endure drawdowns for more profit.

### **Ideal use-cases**:
In my case I use the EA mostly for its trade management capabilities. While I do let it enter trades automatically, the lot size or amount used is a ⅕ of what I use when trading manually

## **Code and License**
The source code for this EA is released under GPL v3 and is available at https://github.com/wait4signal/autumn-harvest/blob/main/AutumnHarvest.mq5   
   
# **Getting Started**

## **Installation**
The EA can be installed using the binaries from the MT5 marketplace at the following link:    
(https://www.mql5.com/en/market/product/68609)   

Altenatively you can compile the source code locally using the MT5 editor.   
You need to attach the EA to the corresponding chart for each instrument you want to trade/manage.   
If the chart already has another EA then you can just open another chart for this one.   
You can then configure accordingly.

## **Utility Scripts**
The project also contains the following utility scripts which can be useful for opening trades:   
**ScriptBuy**: opens a buy position using specified amount. (https://www.mql5.com/en/market/product/67868)    
**ScriptBuyLimit**: opens a buy limit order using specified amount. (https://www.mql5.com/en/market/product/73247)   
**ScriptSell**: opens a sell position using specified amount. (https://www.mql5.com/en/market/product/67796)   
**ScriptSellLimit**: opens a sell limit order using specified amount. (https://www.mql5.com/en/market/product/73245)   

## **Monitoring**
The EA can be set to send health checks to a monitoring server so that alerts can be sent out if no heartbeat pings are received within a set timeframe.   
We recommend the https://healthchecks.io/ platform for this as it is open-source and supports a large number of alerting mechanisms such as email,telegram,phone call etc. Plus it offers up to 20 free monitoring licenses.   
Note that your alert interval needs to be longer than the heartbeat interval e.g if heartbeat is set to 5 minutes then on the monitoring server you can set alerting to something like 7 minutes so that you get notified if the terminal has not sent a ping in 7 minutes.   
**Configure the email tab under options for this to work*

## **Terminal global variables**
The following global variables can be set at terminal level to control certain program behaviour:

| Variable                                | Description `[valid values in brackets]`                                                                                               |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| LOG_LEVEL                               | Sets log level: `[0 \| 1 \| 2 \| 3 \| 4]` where LOG_NONE  = 0; LOG_ERROR = 1; LOG_WARN  = 2; LOG_INFO  = 3; LOG_DEBUG = 4              |
| TOTAL_ALLOWED_USED_MARGIN               | Total amount allowed for used margin, EA won't open new trades beyond this total                                                       |
| PAUSE_ORDER_OPENING                     | Pause trading for all symbols, paused if value greater than 0...but still maintains open positions                                     |
| PAUSE_POSITION_MAINTENANCE              | Pause position maintenance for all symbols, paused if value greater than 0...position closing and SL adjustment will be done manually  |

## **Settings**
See the following link for detailed explanation of the available settings:   
(https://github.com/wait4signal/autumn-harvest/blob/main/Autumn-Harvest-settings.md)


