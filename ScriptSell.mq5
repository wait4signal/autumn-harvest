//+------------------------------------------------------------------+
/*
    ScriptSell.mq5 

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

#property version "1.00"
#property strict
#property script_show_inputs

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

#include "TradeHelper.mqh"

input double   FIXED_DEAL_AMOUNT = 5000.00; //FIXED_DEAL_AMOUNT: Fixed amount to use per trade
input bool     USE_SL_ON_SELL = false; //USE_SL_ON_SELL: Use stop loss on Short positions

//--- Global Variables
/*
_Symbol+_MAX_SPREAD              //Max spread for given symbol
*/

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   init();

   int spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   printHelper(LOG_INFO, StringFormat("Script: About to execute sell on %s with spread %d ", _Symbol, spread));

//Check spread
   int maxSpread = GlobalVariableGet(_Symbol+"_MAX_SPREAD");
   if((maxSpread > 0) && (spread > maxSpread))
     {
      printHelper(LOG_INFO, StringFormat("Script: Can't execute sell on %s as spread is above %d ", _Symbol, maxSpread));
      return;
     }

   int barIndex = findLastGreenBar(20);
   double sl = iHigh(NULL,0,barIndex) + (getAdjustedPoint()*0.60);
   if(!USE_SL_ON_SELL)
     {
      sl = 0.00;
     }

     placeSellOrder(m_trade, sl, 0.00, FIXED_DEAL_AMOUNT, "[M] ");
  }

//+------------------------------------------------------------------+
//| Initialisation of script                                                                 |
//+------------------------------------------------------------------+
void init()
  {
   m_trade.SetExpertMagicNumber(getMagicWithTimeframe());
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(_Symbol);
   m_trade.SetDeviationInPoints(m_slippage);
  }

//+------------------------------------------------------------------+
