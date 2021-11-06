//+------------------------------------------------------------------+
/*
    AutumnHarvest.mq5 

    Copyright (C) 2021  Bheki Gabela

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
//+------------------------------------------------------------------+

#property strict

#include <Expert\Expert.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "BarAnalysis.mqh"
#include "TradingConditions.mqh"
#include "TradeHelper.mqh"

//--- Global Variables
/*
LOG_LEVEL                        //Sets log level: LOG_NONE  = 0; LOG_ERROR = 1; LOG_WARN  = 2; LOG_INFO  = 3; LOG_DEBUG = 4;
TOTAL_ALLOWED_USED_MARGIN        //Total amount allowed for used margin, EA won't open new trades beyond this total
PAUSE_ORDER_OPENING     //Pause trading for all symbols, paused if value greater than 0...but still maintains open positions
PAUSE_POSITION_MAINTENANCE    //Pause position maintenance for all symbols, paused if value greater than 0...position closing and SL adjustment will be done manually
*/

//--- input parameters
input group           "Trading"
input double   FIXED_DEAL_AMOUNT_BUY = 1000.00; //FIXED_DEAL_AMOUNT_BUY: Fixed amount to use per buy trade
input double   FIXED_DEAL_AMOUNT_SELL = 1000.00; //FIXED_DEAL_AMOUNT_SELL: Fixed amount to use per sell trade
input bool     ALLOW_BUYING = true; //ALLOW_BUYING: EA is allowed to open BUY orders
input bool     ALLOW_SELLING = true; //ALLOW_SELLING: EA is allowed to open SELL orders
input bool     MAINTAIN_ANY_TIMEFRAME = false; //MAINTAIN_ANY_TIMEFRAME: EA allowed to maintain any position even if not matching current timeframe
input bool     MAINTAIN_ANY_DEAL = true; //MAINTAIN_ANY_DEAL: EA allowed to maintain any position even if not opened by it
input int      MAX_SPREAD = 10; //MAX_SPREAD: Max spread, won't place trade if spread is above this value
input string   TRADE_CUTOFF_TIME = "20:00"; //TRADE_CUTOFF_TIME: No trading after this time
input group           "Strategies"
input bool     USE_IGNORED_BAR = true; //USE_IGNORED_BAR: Use ignored bar strategy by OV
input bool     USE_RSI_REVERSAL_BUY = true; //USE_RSI_REVERSAL_BUY: Use rsi reversal strategy on BUY
input bool     USE_RSI_REVERSAL_SELL = true; //USE_RSI_REVERSAL_SELL: Use rsi reversal strategy on SELL
input double   RSI_OB_LEVEL = 70.00; //RSI_OB_LEVEL: OverBought level marker
input double   RSI_OS_LEVEL = 30.00; //RSI_OS_LEVEL: OverSold level marker
input double   PEAK_OB_LEVEL = 60.00; //PEAK_OB_LEVEL: OverBought level for peak reversal
input double   PEAK_OS_LEVEL = 40.00; //PEAK_OS_LEVEL: OverSold level for peak reversal
input bool     USE_PEAK_REVERSAL_BUY = true; //USE_PEAK_REVERSAL_BUY: Use peak bar reversal strategy on BUY
input bool     USE_PEAK_REVERSAL_SELL = true; //USE_PEAK_REVERSAL_SELL: Use peak bar reversal strategy on SELL
input double   MA_AWAY_PERC = 0.0005; //MA_AWAY_PERC: Percentage by which price can be away from MA
input bool     USE_LONG_MA_IB = false; //USE_LONG_MA_IB: Use long MA (200MA) for trend IB guidance, this results in fewer but more accurate entries
input bool     USE_LONG_MA_PEAK = false; //USE_LONG_MA_PEAK: Use long MA (200MA) for trend PEAK guidance, this results in fewer but more accurate entries
input bool     USE_LONG_MA_RSI = false; //USE_LONG_MA_RSI: Use long MA (200MA) for trend RSI guidance, this results in fewer but more accurate entries
input double   PRICE_TO_TRADEMA_ATR_PERC = 1.50; //PRICE_TO_TRADEMA_ATR: Minimum distance between price and TradeMA
input group           "Risk Management"
input int      TRADE_INTERVAL_BARS = 3; //TRADE_INTERVAL_BARS: Don't place trade if one exists within this interval (avoid duplicate)
input int      MAX_LOSING_DEALS = 2; //MAX_LOSING_DEALS: Max number of open losing deals for current symbol
input int      MAX_HEAVY_DD_DEALS = 6; //MAX_HEAVY_DD_DEALS: Max number of open deals whose drawndown is above 50% (no more deals till cleared)
input bool     ALLOW_ADD_TO_LOSING_BUY_POSITION = true; //ALLOW_ADD_TO_LOSING_BUY_POSITION: Allow adding to losing buy position
input bool     ALLOW_ADD_TO_LOSING_SELL_POSITION = true; //ALLOW_ADD_TO_LOSING_SELL_POSITION: Allow adding to losing sell position
input group           "Entry/Exit"
input bool     TRAIL_PROFIT = true; //TRAIL_PROFIT: Enable trailing profit after reaching a certain level
input bool     TRAIL_LOSS = false; //TRAIL_LOSS: Adjust initial stoploss while still in negative (follows positive move until breakeven)
input double   BUY_MAX_LOSS_PERC = 0.00; //BUY_MAX_LOSS_PERC: If > 0.00 then deal will be closed at this loss level to limit exposure
input double   SELL_MAX_LOSS_PERC = 0.00; //SELL_MAX_LOSS_PERC: If > 0.00 then deal will be closed at this loss level to limit exposure
input double   TP_TRAIL_BUY_PERC = 0.025; //TP_TRAIL_BUY_PERC: Distance between TP and current price when LONG
input double   TP_TRAIL_SELL_PERC = 0.020; //TP_TRAIL_SELL_PERC: Distance between TP and current price when SHORT
input double   TP_PERC = 0.05; //TP_PERC: Acceptable profit on deal, can start trailing from there
input bool     CLOSE_ON_REVERSAL = true; //CLOSE_ON_REVERSAL: Close position and take profit when price starts reversing
input double   CLOSE_ON_REVERSAL_MIN_PROFIT_PERC = 0.01; //CLOSE_ON_REVERSAL_MIN_PROFIT_PERC: Minimum required profit before closing on reversal
input bool     ADD_ATR_TO_SL = false; //ADD_ATR_TO_SL: Whether to add ATR to stoploss as a buffer
//input int      MAX_ATR_ON_SELL = 15; //MAX_ATR_ON_SELL: No selling if volatility is at or above this level to avoid unnecessary SL hits
input bool     USE_SL_ON_BUY = true; //USE_SL_ON_BUY: Use stop loss on Long position
input bool     USE_SL_ON_SELL = true; //USE_SL_ON_SELL: Use stop loss on Short position
input double   SL_BUFFER_POINT_PERC = 0.60; //SL_BUFFER_POINT_PERC: Point percentage to add to stoploss as a buffer
input group           "Trade Opportunity Alerts"
/*Configure the email tab under options for this to work*/
input bool     ALERT_IGNORED_BAR_BUY = false; //ALERT_IGNORED_BAR_BUY: Whether to send an email alert when this trade opportunity occurs
input bool     ALERT_IGNORED_BAR_SELL = false; //ALERT_IGNORED_BAR_SELL: Whether to send an email alert when this trade opportunity occurs
input bool     ALERT_RSI_REVERSAL_BUY = false; //ALERT_RSI_REVERSAL_BUY: Whether to send an email alert when this trade opportunity occurs
input bool     ALERT_RSI_REVERSAL_SELL = false; //ALERT_RSI_REVERSAL_SELL: Whether to send an email alert when this trade opportunity occurs
input bool     ALERT_PEAK_REVERSAL_BUY = false; //ALERT_PEAK_REVERSAL_BUY: Whether to send an email alert when this trade opportunity occurs
input bool     ALERT_PEAK_REVERSAL_SELL = false; //ALERT_PEAK_REVERSAL_SELL: Whether to send an email alert when this trade opportunity occurs
input int      ALERT_INTERVAL_BARS = 3; //ALERT_INTERVAL_BARS: Number of bars to skip before we can send another alert for this symbol and timeframe
input group           "Monitoring"
input string   HEARTBEAT_URL = ""; //HEARTBEAT_URL: Url to send heartbeat to
input int      HEARTBEAT_INTERVAL_MINUTES = 5; //HEARTBEAT_INTERVAL_MINUTES: How often to send the heartbeat

//CAccountInfo m_account;
//CTrade       m_trade; 

int tradeMAHandle = 0;
int slowMAHandle = 0;
int rsiHandle = 0;
int atrHandle = 0;

double tradeMA[];
double slowMA[];
double rsi[];
double atr[];

datetime lastBuyTime;
datetime lastSellTime;

ulong lastHeartbeatTime = 0;
ulong lastOrderOpeningStatusTime = 0;
int   ORDER_OPENING_STATUS_MINUTES = 5;

long lastIgnoredBarAlert = 0;
long lastRsiReversalAlert = 0;
long lastPeakReversalAlert = 0;

/*
   Strategies:
   U = Unkown
   M = Manual
   C = Colour game
   P = Peak reveral
   R = RSI reversal
*/
string strategy = "U";

double sl = 0.00; //SL will be set during bar analysis, to be used during buy/sell
double tp = 0.00;//TP is not used in this EA, remains zero

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   m_trade.SetExpertMagicNumber(getMagicWithTimeframe());
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(_Symbol);
   m_trade.SetDeviationInPoints(m_slippage);

   //--- 10MA init
   tradeMAHandle = iMA(_Symbol,_Period,10,0,MODE_SMA,PRICE_CLOSE);
   if(tradeMAHandle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating 10 MA indicator");
      return(INIT_FAILED);
   }
   //--- 100MA init
   slowMAHandle = iMA(_Symbol,_Period,100,0,MODE_SMA,PRICE_CLOSE);
   if(slowMAHandle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating 100 MA indicator");
      return(INIT_FAILED);
   }
   
   //--- RSI init
   rsiHandle = iRSI(_Symbol,_Period,10,PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating RSI indicator");
      return(INIT_FAILED);
   }

   //--- ATR init
   atrHandle = iATR(_Symbol,_Period,10);
   if(atrHandle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating ATR indicator");
      return(INIT_FAILED);
   }

   EventSetTimer(30); //30 seconds
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   //--- Release indicator handles
   IndicatorRelease(tradeMAHandle);
   IndicatorRelease(slowMAHandle);
   IndicatorRelease(rsiHandle);
   IndicatorRelease(atrHandle);

   EventKillTimer();
}

void OnTimer() {
   if(StringLen(HEARTBEAT_URL) > 4) { //Surely can't have url shorter than this...
      processHeartbeat();
   }
   
   //--- Log to file status of whether BUY/SELL is allowed. Used for easy tracking.
   logOrderOpeningStatus();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   //--- Maintain positions
   maintainPositions();

   //--- Copy tradeMA values
   ArraySetAsSeries(tradeMA,true);
   int copied = CopyBuffer(tradeMAHandle,0,0,10,tradeMA);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the trade iMA indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 10) {
      printHelper(LOG_ERROR, StringFormat("Moving Average trade indicator: %d elements out of 10 were copied",copied));
      return;
   }
   
   copied = 0;
   //--- Copy slowMA values
   ArraySetAsSeries(slowMA,true);
   copied = CopyBuffer(slowMAHandle,0,0,10,slowMA);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the slow iMA indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 10) {
      printHelper(LOG_ERROR, StringFormat("Moving Average slow indicator: %d elements out of 10 were copied",copied));
      return;
   }
   
   copied = 0;
   //--- Copy rsi values
   ArraySetAsSeries(rsi,true);
   copied = CopyBuffer(rsiHandle,0,0,10,rsi);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 10) {
      printHelper(LOG_ERROR, StringFormat("RSI indicator: %d elements out of 10 were copied",copied));
      return;
   }

   copied = 0;
   //--- Copy atr values
   ArraySetAsSeries(atr,true);
   copied = CopyBuffer(atrHandle,0,0,10,atr);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 10) {
      printHelper(LOG_ERROR, StringFormat("RSI indicator: %d elements out of 10 were copied",copied));
      return;
   }
   
   //--- Check if trading possible
   if(!isTradingPossible(m_account)) {
      printHelper(LOG_DEBUG, "Trading not possible...returning");
      return;
   }

   //--- Get signal and place market order
   TRADE_DECISION tradeDecision = getDecision();
   
   //Check if trading is paused
   int pauseOrderOpening = GlobalVariableGet("PAUSE_ORDER_OPENING");
   if(pauseOrderOpening > 0) {
      printHelper(LOG_DEBUG, "Trading is paused...returning");
      return;
   }
   
   if(tradeDecision == BUY_DECISION && ALLOW_BUYING) {
      //DebugBreak();
      if((!ALLOW_ADD_TO_LOSING_BUY_POSITION) && hasOpenLosingPositions(ORDER_TYPE_BUY)) {
         printHelper(LOG_WARN, "Not opening position as we already have a losing one for same symbol and timeframe");
      } else if(lastBuyTime > iTime(NULL,0,SIGNAL_BAR)) {
         printHelper(LOG_WARN, "Already had a Buy within this bar....not executing");
      } else if(numberOfOpenLosingDeals(ORDER_TYPE_BUY) >= MAX_LOSING_DEALS) {
         printHelper(LOG_WARN, "Not opening position as we are at max open losing deals on symbol");
      } else {
         if(!USE_SL_ON_BUY) {
            sl = 0.00;
         }
         
         placeBuyOrder(m_trade, sl, tp, FIXED_DEAL_AMOUNT_BUY, strategy);
         if(TRADE_RETCODE_DONE == m_trade.ResultRetcode()) {
            lastBuyTime = TimeCurrent();
         }
      }
   } else if(tradeDecision == SELL_DECISION && ALLOW_SELLING) {
      //DebugBreak();
      if((!ALLOW_ADD_TO_LOSING_SELL_POSITION) && hasOpenLosingPositions(ORDER_TYPE_SELL)) {
         printHelper(LOG_WARN, "Not opening position as we already have one for same symbol and timeframe");
      } else if(lastSellTime > iTime(NULL,0,SIGNAL_BAR)) {
         printHelper(LOG_WARN, "Already had a Sell within this bar....not executing");
      } else if(numberOfOpenLosingDeals(ORDER_TYPE_SELL) >= MAX_LOSING_DEALS) {
         printHelper(LOG_WARN, "Not opening position as we are at max open losing deals on symbol");
      } else {
         if(!USE_SL_ON_SELL) {
            sl = 0.00;
         }
         
         placeSellOrder(m_trade, sl, tp, FIXED_DEAL_AMOUNT_SELL, strategy);
         if(TRADE_RETCODE_DONE == m_trade.ResultRetcode()) {
            lastSellTime = TimeCurrent();
         }
      }
   }
   
}

int numberOfOpenLosingDeals(int orderType) {
   int count = 0;
   for (int i = PositionsTotal()-1; i >= 0; i--) { 
      PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      string symbol = PositionGetString(POSITION_SYMBOL);
      long posTicket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      int positionType = PositionGetInteger(POSITION_TYPE);
      double profit = PositionGetDouble(POSITION_PROFIT);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(profit < 0.00 && symbol == _Symbol && baseMagic == getMagicWithoutTimeframe(magic) && ("[M]" != StringSubstr(comment, 0, 3))) {
         if((orderType == ORDER_TYPE_BUY && positionType == POSITION_TYPE_BUY) || (orderType == ORDER_TYPE_SELL && positionType == POSITION_TYPE_SELL)) {
            count++;
         }
      }
   }

   return count;
}

bool hasOpenLosingPositions(int orderType) {
   for (int i = PositionsTotal()-1; i >= 0; i--) { 
      PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      string symbol = PositionGetString(POSITION_SYMBOL);
      long posTicket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      int positionType = PositionGetInteger(POSITION_TYPE);
      double profit = PositionGetDouble(POSITION_PROFIT);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(profit < 0.00 && symbol == _Symbol && magic == getMagicWithTimeframe() && ("[M]" != StringSubstr(comment, 0, 3))) {
         if((orderType == ORDER_TYPE_BUY && positionType == POSITION_TYPE_BUY) || (orderType == ORDER_TYPE_SELL && positionType == POSITION_TYPE_SELL)) {
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void maintainPositions() {
   //Check if maintenance is paused
   int pausePositionMaintenance = GlobalVariableGet("PAUSE_POSITION_MAINTENANCE");
   if(pausePositionMaintenance > 0) {
      printHelper(LOG_DEBUG, "Maintenance is paused...returning");
      return;
   }
   
   MqlTick tick_array[];
   MqlTick previousTick;
   int received=CopyTicks(_Symbol,tick_array,COPY_TICKS_INFO,0,2);
   if(2 == received) {
      previousTick = tick_array[0];
   }
   
   for(int i = PositionsTotal()-1; i >= 0; i--) { 
      PositionGetSymbol(i);
      string symbol = PositionGetString(POSITION_SYMBOL);
      if(symbol != _Symbol) {
         printHelper(LOG_DEBUG, StringFormat("Skipping maintenance as position symbol %s does not match chart's %s", symbol, _Symbol));
         continue;
      }
      
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      long ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double profit = PositionGetDouble(POSITION_PROFIT);
      double tp = PositionGetDouble(POSITION_TP);
      double sl = PositionGetDouble(POSITION_SL);
      int positionType = PositionGetInteger(POSITION_TYPE);
      string comment = PositionGetString(POSITION_COMMENT);
      
      
      printHelper(LOG_DEBUG, StringFormat("Ticket %d has %f profit", ticket, profit));
      
      if((!MAINTAIN_ANY_DEAL) && baseMagic != getMagicWithoutTimeframe(magic)) {
         printHelper(LOG_DEBUG, StringFormat("Skipping maintenance of position %d as it wasn't opened by us", ticket));
         continue;
      }
      
      if((!MAINTAIN_ANY_TIMEFRAME) && (magic != getMagicWithTimeframe())) {
         printHelper(LOG_DEBUG, StringFormat("Skipping maintenance of position %d as it has a different timeframe from current chart", ticket));
         continue;
      }
      
      if(TRAIL_LOSS) {
         trailLosses(ticket, openPrice, currentPrice, profit, tp, sl, positionType, previousTick);
      }
      
      //BEGIN Calc margin
      double volume = PositionGetDouble(POSITION_VOLUME);
      double margin = 0.00;
      ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
      if(positionType == POSITION_TYPE_SELL) {
         orderType = ORDER_TYPE_SELL;
      }
      OrderCalcMargin(orderType, _Symbol,volume,openPrice,margin);
      //END Calc margin

      if(TRAIL_PROFIT && tp == 0.00) {
         trailProfits(ticket, openPrice, currentPrice, profit, tp, sl, positionType, previousTick, margin);
      } 
      
      double stepAmount = positionType == POSITION_TYPE_BUY ? margin * TP_TRAIL_BUY_PERC : margin * TP_TRAIL_SELL_PERC;
      
      if(CLOSE_ON_REVERSAL && profit >= (margin*CLOSE_ON_REVERSAL_MIN_PROFIT_PERC) && tp == 0.00) {
         //Only do this if timeframe is same otherwise we could mess up deals using incorrect price action data
         ulong magicWithTimeFrame = getMagicWithTimeframe();
         if(magic != magicWithTimeFrame) {
            printHelper(LOG_DEBUG, StringFormat("Skipping maintenance as position magic %d and chart magic %d do not have matching timeframes", magic, magicWithTimeFrame));
            continue;
         }
      
         long posSeconds = PositionGetInteger(POSITION_TIME_MSC) / 1000;
         long currSeconds = (long)TimeCurrent();
         long secondsPassed = currSeconds - posSeconds;
         long secondsToSkip = PeriodSeconds(PERIOD_CURRENT) * 1; //At least one bar
      
         if(secondsPassed > secondsToSkip) {//Avoid being on same bar
            if(positionType == POSITION_TYPE_BUY) {
               bool priceOk = SymbolInfoDouble(_Symbol,SYMBOL_BID) < iLow(NULL,0,PEAK_CONTROL_BAR);
               if(isRed(SIGNAL_BAR) && priceOk) {
                  m_trade.PositionClose(ticket);
               }
            } else {
               bool priceOk = SymbolInfoDouble(_Symbol,SYMBOL_ASK) > iHigh(NULL,0,PEAK_CONTROL_BAR);
               if(isGreen(SIGNAL_BAR) && priceOk) {
                  m_trade.PositionClose(ticket);
               }
            }
         }
      }
      
      //Close position if we are at max loss
      /*Don't trigger on MANUAL deals: 
         [M] = Manual
      */
      if("[M]" != StringSubstr(comment, 0, 3)) { 
         if(positionType == POSITION_TYPE_BUY && BUY_MAX_LOSS_PERC > 0.00 && profit < 0.0) {
            double maxLoss = margin*BUY_MAX_LOSS_PERC;
            if(MathAbs(profit) >= maxLoss) {
               printHelper(LOG_INFO, StringFormat("Closing position %d due to max loss", ticket));
               m_trade.PositionClose(ticket);
            }
         } else if(positionType == POSITION_TYPE_SELL && SELL_MAX_LOSS_PERC > 0.00 && profit < 0.0) {
            double maxLoss = margin*SELL_MAX_LOSS_PERC;
            if(MathAbs(profit) >= maxLoss) {
               printHelper(LOG_INFO, StringFormat("Closing position %d due to max loss", ticket));
               m_trade.PositionClose(ticket);
            }
         }
      }
   }
}

void trailProfits(long ticket, double openPrice, double currentPrice, double profit, double tp, double sl, int positionType, MqlTick &previousTick, double margin) {
   double trailPips = 0.0;
   double stepAmount = positionType == POSITION_TYPE_BUY ? margin * TP_TRAIL_BUY_PERC : margin * TP_TRAIL_SELL_PERC;
   
   if(profit > stepAmount) {
      double pieces =  profit / stepAmount;
      double priceDifference = MathAbs(currentPrice - openPrice);
      if(priceDifference > 0) {
         double stepPips = priceDifference / pieces;
         double targetProfit = margin * TP_PERC;
         if(profit > targetProfit) { //We reached our target so trail closer
            trailPips = stepPips / 2;
         } else {
            trailPips = stepPips;
         }
      }
   }

   if(positionType == POSITION_TYPE_BUY) {
      //Trail profit
      if(trailPips > 0) {
         double newSL = NormalizeDouble(currentPrice - trailPips, SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
         if(sl == 0.00 || newSL > sl) {
            printHelper(LOG_DEBUG, StringFormat("Setting trailing stop at %f, trail pips is %f", newSL, trailPips));
            
            int stops_level = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
            if(stops_level != 0)
              {               
                double bidPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                
                bool slOk = (newSL == 0) || (bidPrice-newSL > stops_level*_Point);
                bool tpOk = (tp == 0) || (tp-bidPrice > stops_level*_Point);
                if(!(slOk && tpOk)) 
                  {
                    printHelper(LOG_ERROR, StringFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must not be nearer than %d points from the open price when buying",stops_level,stops_level));
                    return;
                  }
              }
              
            m_trade.PositionModify(ticket,newSL,tp);
         }
      }
   } else {
      //Trail profit
      if(trailPips > 0) {
         double newSL = NormalizeDouble(currentPrice + trailPips, SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
         if(sl == 0.00 || newSL < sl) {
            printHelper(LOG_DEBUG, StringFormat("Setting trailing tp at %f, trail pips is %f", newSL, trailPips));
            
            int stops_level = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
            if(stops_level != 0)
              { 
                double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                  
                bool slOk = (newSL == 0) || (newSL-askPrice > stops_level*_Point);
                bool tpOk = (tp == 0) || (askPrice-tp > stops_level*_Point);
                if(!(slOk && tpOk)) 
                  {
                    printHelper(LOG_ERROR, StringFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must not be nearer than %d points from the open price when selling",stops_level,stops_level));
                    return;
                  }
              }
              
            m_trade.PositionModify(ticket,newSL,tp);
         }
      }
   }
}

//Trail losses until break even point
void trailLosses(long ticket, double openPrice, double currentPrice, double profit, double tp, double sl, int positionType, MqlTick &previousTick) {
   if(positionType == POSITION_TYPE_BUY) {
      if(sl > 0.00 && sl <= openPrice) {
         double previousPrice = previousTick.ask;
         if(currentPrice > previousPrice) {
            double newSL = NormalizeDouble(sl + (currentPrice - previousPrice), SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
            if(newSL > sl) {
               printHelper(LOG_DEBUG, StringFormat("Still in negative, adjusting sl to %f", newSL));
               
               int stops_level = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
               if(stops_level != 0)
                 { 
                   double bidPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                                 
                   bool slOk = (newSL == 0) || (bidPrice-newSL > stops_level*_Point);
                   bool tpOk = (tp == 0) || (tp-bidPrice > stops_level*_Point);
                   if(!(slOk && tpOk)) 
                     {
                       printHelper(LOG_ERROR, StringFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must not be nearer than %d points from the open price when buying",stops_level,stops_level));
                       return;
                     }
                 }
                 
               m_trade.PositionModify(ticket,newSL,tp);
            }
         }
      }
   } else {
      if(sl > 0.00 && sl >= openPrice) {
         double previousPrice = previousTick.bid;
         if(currentPrice < previousPrice) {
            double newSL = NormalizeDouble(sl - (previousPrice - currentPrice), SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
            if(newSL < sl) {
               printHelper(LOG_DEBUG, StringFormat("Still in negative, adjusting sl to %f", newSL));
               
               int stops_level = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
               if(stops_level != 0)
                 { 
                   double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                     
                   bool slOk = (newSL == 0) || (newSL-askPrice > stops_level*_Point);
                   bool tpOk = (tp == 0) || (askPrice-tp > stops_level*_Point);
                   if(!(slOk && tpOk)) 
                     {
                       printHelper(LOG_ERROR, StringFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must not be nearer than %d points from the open price when selling",stops_level,stops_level));
                       return;
                     }
                 }
              
               m_trade.PositionModify(ticket,newSL,tp);
            }
         }
      } 
   }
}

void processHeartbeat() {
   ulong now =GetTickCount64();
   if((now-lastHeartbeatTime) < (HEARTBEAT_INTERVAL_MINUTES*60*1000)) {
      return;
   }
   
   string cookie=NULL,headers;
   char   data[],result[];
   
   ResetLastError();
   
   int res=WebRequest("POST",HEARTBEAT_URL,cookie,NULL,500,data,0,result,headers);
   if(res == -1) {
      printHelper(LOG_WARN, StringFormat("Error in heartbeat WebRequest. Error code %s",GetLastError()));
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      printHelper(LOG_WARN, StringFormat("Add the address %s to the list of allowed URLs on tab 'Expert Advisors'",HEARTBEAT_URL));
   } else {
      if(res == 200) {
         //--- Successful transmission
         printHelper(LOG_INFO, StringFormat("Heartbeat sent, Server Result: %s", CharArrayToString(result)));
      } else{
         printHelper(LOG_WARN, StringFormat("Heartbeat transmission '%s' failed, error code %d",HEARTBEAT_URL,res));
      }
   }
   
   lastHeartbeatTime = GetTickCount64();
}

void logOrderOpeningStatus() {
   ulong now =GetTickCount64();
   if((now-lastOrderOpeningStatusTime) < (ORDER_OPENING_STATUS_MINUTES*60*1000)) {
      return;
   }
   
   ulong fileAccount = AccountInfoInteger(ACCOUNT_LOGIN);
   string disabledBuyFileName = "autumn-harvest\\"+fileAccount+"\\DISABLED_BUY-"+_Symbol;
   string disabledSellFileName = "autumn-harvest\\"+fileAccount+"\\DISABLED_SELL-"+_Symbol;
   
   FileDelete(disabledBuyFileName,FILE_COMMON);
   FileDelete(disabledSellFileName,FILE_COMMON);
   
   if(ALLOW_BUYING == false) {
      int disabledBuyFileHandle = FileOpen(disabledBuyFileName,FILE_WRITE|FILE_COMMON|FILE_TXT);
      FileClose(disabledBuyFileHandle);
   }
   
   if(ALLOW_SELLING == false) {
      int disabledSellFileHandle = FileOpen(disabledSellFileName,FILE_WRITE|FILE_COMMON|FILE_TXT);
      FileClose(disabledSellFileHandle);
   }
   
   lastOrderOpeningStatusTime = GetTickCount64();
}

//+------------------------------------------------------------------+
