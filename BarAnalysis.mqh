//+------------------------------------------------------------------+
/*
    BarAnalysis.mqh 

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

#property version   "1.00"
#property strict

#include <Expert\Signal\SignalMA.mqh>

#include "AutumnHarvest.mq5"

const int CONTROL_BAR = 2;
const int IGNORED_BAR = 1;
const int SIGNAL_BAR = 0;

const int PEAK_CONTROL_BAR = 1;

//Strategies
const string STRATEGY_IGNORED_BAR = "IGNORED BAR";
const string STRATEGY_RSI_REVERSAL = "RSI REVERSAL";
const string STRATEGY_PEAK_REVERSAL = "PEAK REVERSAL";

enum TRADE_DECISION {
   BUY_DECISION,
   SELL_DECISION,
   DO_NOTHING_DECISION
};

enum TREND_TYPE {
   UP_TREND,
   DOWN_TREND,
   LATERAL_TREND
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isColourGame() {
   return isRBI() || isGBI();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRBI() {
   bool coloursOk = isRed(IGNORED_BAR) && isGreen(SIGNAL_BAR);
   bool bodiesOk = false;

   if(coloursOk) {
      double cbBodySize = MathAbs(iOpen(NULL,0,CONTROL_BAR) - iClose(NULL,0,CONTROL_BAR));
      double cbTotalSize = MathAbs(iLow(NULL,0,CONTROL_BAR) - iHigh(NULL,0,CONTROL_BAR));
      double ibBodySize = MathAbs(iOpen(NULL,0,IGNORED_BAR) - iClose(NULL,0,IGNORED_BAR));
      double ibTotalSize = MathAbs(iLow(NULL,0,IGNORED_BAR) - iHigh(NULL,0,IGNORED_BAR));
   
      bodiesOk = ibBodySize >= (ibTotalSize*0.40) && ibBodySize <= (cbBodySize*0.50) && ibTotalSize <= cbTotalSize*0.60 && iLow(NULL,0,SIGNAL_BAR) > iLow(NULL,0,IGNORED_BAR);
   }

   bool priceOk = (MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) > iHigh(NULL,0,IGNORED_BAR)) && (iOpen(NULL,0,SIGNAL_BAR) <= iClose(NULL,0,IGNORED_BAR));

   return coloursOk && bodiesOk && priceOk;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isGBI() {
   bool coloursOk = isGreen(IGNORED_BAR) && isRed(SIGNAL_BAR);
   bool bodiesOk = false;

   if(coloursOk) {
      double cbBodySize = MathAbs(iOpen(NULL,0,CONTROL_BAR) - iClose(NULL,0,CONTROL_BAR));
      double cbTotalSize = MathAbs(iLow(NULL,0,CONTROL_BAR) - iHigh(NULL,0,CONTROL_BAR));
      double ibBodySize = MathAbs(iOpen(NULL,0,IGNORED_BAR) - iClose(NULL,0,IGNORED_BAR));
      double ibTotalSize = MathAbs(iLow(NULL,0,IGNORED_BAR) - iHigh(NULL,0,IGNORED_BAR));
      
      bodiesOk = ibBodySize >= (ibTotalSize*0.40) && ibBodySize <= (cbBodySize*0.50) && ibTotalSize <= cbTotalSize*0.60 && iHigh(NULL,0,SIGNAL_BAR) < iHigh(NULL,0,IGNORED_BAR);
   }

   bool priceOk = (MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) < iLow(NULL,0,IGNORED_BAR)) && (iOpen(NULL,0,SIGNAL_BAR) >= iClose(NULL,0,IGNORED_BAR));
   
   return coloursOk && bodiesOk && priceOk;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getDecision() {
   double cbUpperBoundary = tradeMA[CONTROL_BAR]+(tradeMA[CONTROL_BAR]*MA_AWAY_PERC);
   double cbLowerBoundary = tradeMA[CONTROL_BAR]-(tradeMA[CONTROL_BAR]*MA_AWAY_PERC);

   double ibUpperBoundary = tradeMA[IGNORED_BAR]+(tradeMA[IGNORED_BAR]*MA_AWAY_PERC);
   double ibLowerBoundary = tradeMA[IGNORED_BAR]-(tradeMA[IGNORED_BAR]*MA_AWAY_PERC);

   double sbUpperBoundary = tradeMA[SIGNAL_BAR]+(tradeMA[SIGNAL_BAR]*MA_AWAY_PERC);
   double sbLowerBoundary = tradeMA[SIGNAL_BAR]-(tradeMA[SIGNAL_BAR]*MA_AWAY_PERC);
   
   int decision = DO_NOTHING_DECISION;
   strategy = "[U] ";
   
   if(USE_IGNORED_BAR) {
      if(isRBI() && isIgnoredBarUpTrend()) {
         bool closerToMA = iLow(NULL,0,CONTROL_BAR) < cbUpperBoundary || iLow(NULL,0,IGNORED_BAR) < ibUpperBoundary || iLow(NULL,0,SIGNAL_BAR) < sbUpperBoundary;
         if(closerToMA && (iOpen(NULL,0,IGNORED_BAR) >= tradeMA[IGNORED_BAR])) {
            decision = BUY_DECISION;
            strategy = "[C] ";
            sl = iLow(NULL,0,IGNORED_BAR) - (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl - atr[SIGNAL_BAR];
            }

            if(USE_LONG_MA_IB) {
               //double price = MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
               double sbMA = tradeMA[SIGNAL_BAR];
               double sbMA_S = slowMA[SIGNAL_BAR];
               if(!(sbMA >= sbMA_S)) {
                  decision = DO_NOTHING_DECISION;
                  strategy = "[U] ";
               }
            }

            if(ALERT_IGNORED_BAR_BUY) {
               sendAlert(decision, STRATEGY_IGNORED_BAR);
            }
         }
      } else if(isGBI() && isIgnoredBarDownTrend()) {
         double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         bool closerToMA = iHigh(NULL,0,CONTROL_BAR) > cbLowerBoundary || iHigh(NULL,0,IGNORED_BAR) > ibLowerBoundary || iHigh(NULL,0,SIGNAL_BAR) > sbLowerBoundary;
         if(closerToMA && (iOpen(NULL,0,IGNORED_BAR) <= tradeMA[IGNORED_BAR])) {
            decision = SELL_DECISION;
            strategy = "[C] ";
            sl = iHigh(NULL,0,IGNORED_BAR) + (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl + atr[SIGNAL_BAR];
            }

            if(USE_LONG_MA_IB) {
               //double price = MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
               double sbMA = tradeMA[SIGNAL_BAR];
               double sbMA_S = slowMA[SIGNAL_BAR];
               if(!(sbMA <= sbMA_S)) {
                  decision = DO_NOTHING_DECISION;
                  strategy = "[U] ";
               }
            }
            
            if(ALERT_IGNORED_BAR_SELL) {
               sendAlert(decision, STRATEGY_IGNORED_BAR);
            }
         }
      }
      
   }
   
   if((decision == DO_NOTHING_DECISION) && (USE_PEAK_REVERSAL_BUY || USE_PEAK_REVERSAL_SELL)) {
      decision = getPeakReveralDecision();
      
      if((decision == BUY_DECISION) && !USE_PEAK_REVERSAL_BUY) {
         decision = DO_NOTHING_DECISION;
         strategy = "[U] ";
      } else if((decision == SELL_DECISION) && !USE_PEAK_REVERSAL_SELL) {
         decision = DO_NOTHING_DECISION;
         strategy = "[U] ";
      }
   }
   
   if((decision == DO_NOTHING_DECISION) && (USE_RSI_REVERSAL_BUY || USE_RSI_REVERSAL_SELL)) {
      decision = getRsiDecision();
      
      if((decision == BUY_DECISION) && !USE_RSI_REVERSAL_BUY) {
         decision = DO_NOTHING_DECISION;
         strategy = "[U] ";
      } else if((decision == SELL_DECISION) && !USE_RSI_REVERSAL_SELL) {
         decision = DO_NOTHING_DECISION;
         strategy = "[U] ";
      }
   }

   return decision;
}

bool isIgnoredBarUpTrend() {
   if((iLow(NULL,0,2) < iLow(NULL,0,1)) && (iHigh(NULL,0,2) < iHigh(NULL,0,1))) {
      return true;
   }

   return false;
}

bool isIgnoredBarDownTrend() {
   if((iHigh(NULL,0,2) > iHigh(NULL,0,1)) && (iLow(NULL,0,2) > iLow(NULL,0,1))) {
      return true;
   }

   return false;
}

bool isRsiUpTrend() {
   if((iLow(NULL,0,3) < iLow(NULL,0,2) && iLow(NULL,0,2) < iLow(NULL,0,1)) && (iHigh(NULL,0,3) < iHigh(NULL,0,2) && iHigh(NULL,0,2) < iHigh(NULL,0,1))) {
      return true;
   }

   return false;
}

bool isRsiDownTrend() {
   if((iHigh(NULL,0,3) > iHigh(NULL,0,2) && iHigh(NULL,0,2) > iHigh(NULL,0,1)) && (iLow(NULL,0,3) > iLow(NULL,0,2) && iLow(NULL,0,2) > iLow(NULL,0,1))) {
      return true;
   }

   return false;
}

int getRsiDecision() {
   int decision = DO_NOTHING_DECISION;
   strategy = "[U] ";

   if(isRed(SIGNAL_BAR) && isRsiUpTrend()) {
      if(rsi[PEAK_CONTROL_BAR] >= RSI_OB_LEVEL && rsi[SIGNAL_BAR] < rsi[PEAK_CONTROL_BAR]) {
         bool priceOk = MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) < iLow(NULL,0,PEAK_CONTROL_BAR)-getAdjustedPoint();
         double cbBodySize = MathAbs(iOpen(NULL,0,PEAK_CONTROL_BAR) - iClose(NULL,0,PEAK_CONTROL_BAR));
         double cbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR) - iHigh(NULL,0,PEAK_CONTROL_BAR));
         double beforeCbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR+1) - iHigh(NULL,0,PEAK_CONTROL_BAR+1));
         bool bodyOk = cbBodySize >= cbTotalSize*0.20;
         bool sizeOk = cbTotalSize <= beforeCbTotalSize;
         double cbBodyTop = MathMax(iClose(NULL,0,PEAK_CONTROL_BAR),iOpen(NULL,0,PEAK_CONTROL_BAR));
         bool locationOk = iHigh(NULL,0,SIGNAL_BAR) >= cbBodyTop && iOpen(NULL,0,SIGNAL_BAR) >= cbBodyTop - (cbBodySize*0.50);
         bool distanceOk = (iClose(NULL,0,PEAK_CONTROL_BAR) - tradeMA[PEAK_CONTROL_BAR]) >= atr[PEAK_CONTROL_BAR]*PRICE_TO_TRADEMA_ATR_PERC;
      
         if(priceOk && bodyOk && locationOk && sizeOk && distanceOk) {
            sl = iHigh(NULL,0,PEAK_CONTROL_BAR) + (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl + atr[SIGNAL_BAR];
            }
            strategy = "[R] ";
            decision = SELL_DECISION;
         }
      }
      
      if(USE_LONG_MA_RSI) {
         //double price = MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
         double sbMA = tradeMA[SIGNAL_BAR];
         double sbMA_S = slowMA[SIGNAL_BAR];
         if(!(sbMA <= sbMA_S)) {
            decision = DO_NOTHING_DECISION;
            strategy = "[U] ";
         }
      }
      
      if(decision == SELL_DECISION && ALERT_RSI_REVERSAL_SELL) {
         sendAlert(SELL_DECISION, STRATEGY_RSI_REVERSAL);
      }
   } else if(isGreen(SIGNAL_BAR) && isRsiDownTrend()) {
      if(rsi[PEAK_CONTROL_BAR] <= RSI_OS_LEVEL && rsi[SIGNAL_BAR] > rsi[PEAK_CONTROL_BAR]) {
         bool priceOk = MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) > iHigh(NULL,0,PEAK_CONTROL_BAR)+getAdjustedPoint();
         double cbBodySize = MathAbs(iOpen(NULL,0,PEAK_CONTROL_BAR) - iClose(NULL,0,PEAK_CONTROL_BAR));
         double cbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR) - iHigh(NULL,0,PEAK_CONTROL_BAR));
         double beforeCbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR+1) - iHigh(NULL,0,PEAK_CONTROL_BAR+1));
         bool bodyOk = cbBodySize >= cbTotalSize*0.20;
         bool sizeOk = cbTotalSize <= beforeCbTotalSize;
         double cbBodyBottom = MathMin(iClose(NULL,0,PEAK_CONTROL_BAR),iOpen(NULL,0,PEAK_CONTROL_BAR));
         bool locationOk = iLow(NULL,0,SIGNAL_BAR) <= cbBodyBottom && iOpen(NULL,0,SIGNAL_BAR) <= cbBodyBottom + (cbBodySize*0.50);
         bool distanceOk = (tradeMA[PEAK_CONTROL_BAR] - iClose(NULL,0,PEAK_CONTROL_BAR)) >= atr[PEAK_CONTROL_BAR]*PRICE_TO_TRADEMA_ATR_PERC;
         
         if(priceOk && bodyOk && locationOk && sizeOk && distanceOk) {
            sl = iLow(NULL,0,PEAK_CONTROL_BAR) - (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl - atr[SIGNAL_BAR];
            }
            strategy = "[R] ";
            decision = BUY_DECISION;
         }
      }
      
      if(USE_LONG_MA_RSI) {
         //double price = MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
         double sbMA = tradeMA[SIGNAL_BAR];
         double sbMA_S = slowMA[SIGNAL_BAR];
         if(!(sbMA >= sbMA_S)) {
            decision = DO_NOTHING_DECISION;
            strategy = "[U] ";
         }
      }
      
      if(decision == BUY_DECISION && ALERT_RSI_REVERSAL_BUY) {
         sendAlert(BUY_DECISION, STRATEGY_RSI_REVERSAL);
      }
   }
   
   return decision;
}

bool isPeakUpTrend() {
   if((iLow(NULL,0,3) < iLow(NULL,0,2) && iLow(NULL,0,2) < iLow(NULL,0,1)) && (iHigh(NULL,0,3) < iHigh(NULL,0,2) && iHigh(NULL,0,2) < iHigh(NULL,0,1))) {
      return true;
   }

   return false;
}

bool isPeakDownTrend() {
   if((iHigh(NULL,0,3) > iHigh(NULL,0,2) && iHigh(NULL,0,2) > iHigh(NULL,0,1)) && (iLow(NULL,0,3) > iLow(NULL,0,2) && iLow(NULL,0,2) > iLow(NULL,0,1))) {
      return true;
   }

   return false;
}

int getPeakReveralDecision() {
   double points = _Point;
   int decision = DO_NOTHING_DECISION;
   strategy = "[U] ";

   if(isPeakUpTrend()) {
      if(rsi[PEAK_CONTROL_BAR] >= PEAK_OB_LEVEL) {
         bool isPriceOk = MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) < iLow(NULL,0,PEAK_CONTROL_BAR)-getAdjustedPoint();
         double cbBodySize = MathAbs(iOpen(NULL,0,PEAK_CONTROL_BAR) - iClose(NULL,0,PEAK_CONTROL_BAR));
         double cbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR) - iHigh(NULL,0,PEAK_CONTROL_BAR));
         double beforeCbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR+1) - iHigh(NULL,0,PEAK_CONTROL_BAR+1));
         bool sizeOk = cbTotalSize <= beforeCbTotalSize;
         double cbBodyTop = MathMax(iClose(NULL,0,PEAK_CONTROL_BAR),iOpen(NULL,0,PEAK_CONTROL_BAR));
         bool locationOk = iHigh(NULL,0,SIGNAL_BAR) >= cbBodyTop && iOpen(NULL,0,SIGNAL_BAR) >= cbBodyTop - (cbBodySize*0.50);
         bool distanceOk = (iClose(NULL,0,PEAK_CONTROL_BAR) - tradeMA[PEAK_CONTROL_BAR]) >= atr[PEAK_CONTROL_BAR]*PRICE_TO_TRADEMA_ATR_PERC;
         if(isPriceOk && locationOk && sizeOk && distanceOk) {
            sl = iHigh(NULL,0,PEAK_CONTROL_BAR) + (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl + atr[SIGNAL_BAR];
            }
            strategy = "[P] ";
            decision = SELL_DECISION;

            if(USE_LONG_MA_PEAK) {
               //double price = MathMax(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
               double sbMA = tradeMA[SIGNAL_BAR];
               double sbMA_S = slowMA[SIGNAL_BAR];
               if(!(sbMA <= sbMA_S)) {
                  decision = DO_NOTHING_DECISION;
                  strategy = "[U] ";
               }
            }
            
            if(ALERT_PEAK_REVERSAL_SELL) {
               sendAlert(SELL_DECISION, STRATEGY_PEAK_REVERSAL);
            }
         }
      }
   } else if(isPeakDownTrend()) {
      if(rsi[PEAK_CONTROL_BAR] <= PEAK_OS_LEVEL) {
         bool isPriceOk = MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID)) > iHigh(NULL,0,PEAK_CONTROL_BAR)+getAdjustedPoint();
         double cbBodySize = MathAbs(iOpen(NULL,0,PEAK_CONTROL_BAR) - iClose(NULL,0,PEAK_CONTROL_BAR));
         double cbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR) - iHigh(NULL,0,PEAK_CONTROL_BAR));
         double beforeCbTotalSize = MathAbs(iLow(NULL,0,PEAK_CONTROL_BAR+1) - iHigh(NULL,0,PEAK_CONTROL_BAR+1));
         bool sizeOk = cbTotalSize <= beforeCbTotalSize;
         double cbBodyBottom = MathMin(iClose(NULL,0,PEAK_CONTROL_BAR),iOpen(NULL,0,PEAK_CONTROL_BAR));
         bool locationOk = iLow(NULL,0,SIGNAL_BAR) <= cbBodyBottom && iOpen(NULL,0,SIGNAL_BAR) <= cbBodyBottom + (cbBodySize*0.50);
         bool distanceOk = (tradeMA[PEAK_CONTROL_BAR] - iClose(NULL,0,PEAK_CONTROL_BAR)) >= atr[PEAK_CONTROL_BAR]*PRICE_TO_TRADEMA_ATR_PERC;
         if(isPriceOk && locationOk && sizeOk && distanceOk) {
            sl = iLow(NULL,0,PEAK_CONTROL_BAR) - (getAdjustedPoint()*SL_BUFFER_POINT_PERC);
            if(ADD_ATR_TO_SL) {
               sl = sl - atr[SIGNAL_BAR];
            }
            strategy = "[P] ";
            decision = BUY_DECISION;

            if(USE_LONG_MA_PEAK) {
               //double price = MathMin(SymbolInfoDouble(_Symbol,SYMBOL_ASK),SymbolInfoDouble(_Symbol,SYMBOL_BID));
               double sbMA = tradeMA[SIGNAL_BAR];
               double sbMA_S = slowMA[SIGNAL_BAR];
               if(!(sbMA >= sbMA_S)) {
                  decision = DO_NOTHING_DECISION;
                  strategy = "[U] ";
               }
            }
            
            if(ALERT_PEAK_REVERSAL_BUY) {
               sendAlert(BUY_DECISION, STRATEGY_PEAK_REVERSAL);
            }
         }
      }
   }
   
   return decision;
}

int getTrend() {
   double cbMA = tradeMA[CONTROL_BAR];
   double ibMA = tradeMA[IGNORED_BAR];
   double sbMA = tradeMA[SIGNAL_BAR];
   printHelper(LOG_DEBUG, StringFormat("cbMA=%f, ibMA=%f, sbMA=%f", cbMA, ibMA, sbMA));
   
   double cbMA_S = slowMA[CONTROL_BAR];
   double ibMA_S = slowMA[IGNORED_BAR];
   double sbMA_S = slowMA[SIGNAL_BAR];

   TREND_TYPE trend = LATERAL_TREND;
   if(cbMA < ibMA && ibMA < sbMA) {
      trend = UP_TREND;
   } else if(cbMA > ibMA && ibMA > sbMA) {
      trend = DOWN_TREND;
   }
   
   printHelper(LOG_DEBUG, StringFormat("Final Trend is %s",EnumToString(trend)));

   return trend;
}

void sendAlert(int decision, string strategy) {
   long secondsToSkip = PeriodSeconds(PERIOD_CURRENT) * ALERT_INTERVAL_BARS;
   long now = (long)TimeLocal();
   
   if(strategy == STRATEGY_IGNORED_BAR) {
      long secondsLapsed = now - lastIgnoredBarAlert;
      if(secondsLapsed < secondsToSkip) {
         return;
      }
      lastIgnoredBarAlert = now;
   }
   
   if(strategy == STRATEGY_RSI_REVERSAL) {
      long secondsLapsed = now - lastRsiReversalAlert;
      if(secondsLapsed < secondsToSkip) {
         return;
      }
      lastRsiReversalAlert = now;
   }
   
   if(strategy == STRATEGY_PEAK_REVERSAL) {
      long secondsLapsed = now - lastPeakReversalAlert;
      if(secondsLapsed < secondsToSkip) {
         return;
      }
      lastPeakReversalAlert = now;
   }
   
   string decisionText = "UNKWOWN";
   if(decision == BUY_DECISION) {
      decisionText = "BUY";
   } else if(decision == SELL_DECISION) {
      decisionText = "SELL";
   }
   string subject = StringFormat("%s: %s on account %d", _Symbol, decisionText, AccountInfoInteger(ACCOUNT_LOGIN));
   string body = StringFormat("%s: %s %s opportunity found on %s timeframe for account %d", _Symbol, strategy, decisionText, EnumToString(Period()), AccountInfoInteger(ACCOUNT_LOGIN));
   
   if(EMAIL_ALERT == true) {
      SendMail(subject,body);
   }
   if(TELEGRAM_ALERT == true) {
      sendTelegram(body);
   }
   
}

void sendTelegram(string message) {
   string cookie=NULL,headers;
   char   data[],result[];
   
   ResetLastError();
   
   string url = TELEGRAM_HOST+"/bot"+TELEGRAM_BOT_TOKEN+"/sendMessage?chat_id="+TELEGRAM_CHAT_ID+"&text="+message;
   
   int res=WebRequest("POST",url,cookie,NULL,500,data,0,result,headers);
   if(res == -1) {
      printHelper(LOG_WARN, StringFormat("Error in heartbeat WebRequest. Error code %s",GetLastError()));
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      printHelper(LOG_WARN, StringFormat("Add the address %s to the list of allowed URLs on tab 'Expert Advisors'",TELEGRAM_HOST));
   } else {
      if(res == 200) {
         //--- Successful transmission
         printHelper(LOG_INFO, StringFormat("Telegram sent, Server Result: %s", CharArrayToString(result)));
      } else{
         printHelper(LOG_WARN, StringFormat("Telegram transmission '%s' failed, error code %d",url,res));
      }
   }
}

//+------------------------------------------------------------------+
