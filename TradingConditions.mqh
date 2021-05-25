//+------------------------------------------------------------------+
//|                                            TradingConditions.mqh |
//|                                                         B Gabela |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "B Gabela"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>

#include "AutumnHarvest.mq5"


bool isTradingPossible(CAccountInfo& accountInfo) {
   
   if(TRADE_CUTOFF_TIME != "") {
      datetime finishTime = StringToTime(TRADE_CUTOFF_TIME) % 86400;
      datetime serverTimeOfDay = TimeCurrent() % 86400;
      
      if(serverTimeOfDay >= finishTime) {
         printHelper(LOG_INFO, StringFormat("Trading not allowed after %s", TRADE_CUTOFF_TIME));
         return false;
      }
   }
   
   //Check spread
   int spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   if(spread > MAX_SPREAD) {
      return false;
   }

   //Check recent deals
   if(recentDealExist()) {
      return false;
   }
   
   if(numberOfHeavyDrawDownDeals() >= MAX_HEAVY_DD_DEALS) {
      printHelper(LOG_WARN, StringFormat("Trading not possible due to heavy DD limit of %d", MAX_HEAVY_DD_DEALS));
      return false;
   }

   //Do we have enougn funds
   double totalAllowedUsedMargin = GlobalVariableGet("TOTAL_ALLOWED_USED_MARGIN");
   if(totalAllowedUsedMargin == 0.00) {
      totalAllowedUsedMargin = accountInfo.Balance();
   }
   double usedMargin = accountInfo.Margin();
   if((usedMargin + MathMax(FIXED_DEAL_AMOUNT_BUY,FIXED_DEAL_AMOUNT_SELL)) > totalAllowedUsedMargin) {
      printHelper(LOG_WARN, StringFormat("Used margin is already on %f, Can't place deal of %f as it puts us above [%f]", usedMargin, MathMax(FIXED_DEAL_AMOUNT_BUY,FIXED_DEAL_AMOUNT_SELL), totalAllowedUsedMargin));
      return false;
   }

   return true;
}

int numberOfHeavyDrawDownDeals() {
   int count = 0;
   for (int i = PositionsTotal()-1; i >= 0; i--) { 
      PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      string symbol = PositionGetString(POSITION_SYMBOL);
      double profit = PositionGetDouble(POSITION_PROFIT);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      int positionType = PositionGetInteger(POSITION_TYPE);
      
      //Calc margin
      double volume = PositionGetDouble(POSITION_VOLUME);
      double margin = 0.00;
      ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
      if(positionType == POSITION_TYPE_SELL) {
         orderType = ORDER_TYPE_SELL;
      }
      OrderCalcMargin(orderType, symbol,volume,openPrice,margin);
      
      if(profit < 0.00 && baseMagic == getMagicWithoutTimeframe(magic)) {
         if(MathAbs(profit) >= (margin/2)) {
            count++;
         }
      }
   }

   return count;
}

bool recentDealExist() {
   //Don't place trade if one exists within last number of bars (number input by TRADE_INTERVAL_BARS)
   for (int i = PositionsTotal()-1; i >= 0; i--) { 
      PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      string symbol = PositionGetString(POSITION_SYMBOL);
      long posTicket = PositionGetInteger(POSITION_TICKET);
      long posSeconds = PositionGetInteger(POSITION_TIME_MSC) / 1000;
      long currSeconds = (long)TimeCurrent();

      if(symbol == _Symbol && magic == getMagicWithTimeframe()) {
         long secondsBetweenDeals = currSeconds - posSeconds;
         long secondsToSkip = PeriodSeconds(PERIOD_CURRENT) * TRADE_INTERVAL_BARS;
   
         if(secondsBetweenDeals < secondsToSkip) {
            printHelper(LOG_INFO, StringFormat("Not placing trade as ticket %d is not older than %d seconds...possible duplication", posTicket, secondsToSkip));
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
