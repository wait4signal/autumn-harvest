//+------------------------------------------------------------------+
/*
    ScriptBuyLimit.mq5 

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

enum ENUM_MA_PRICE {
   MA100, 
   MA200
};

enum ENUM_PRICE_BUFFER {
   ATR,
   HALF_ATR,
   NONE
};

input double   FIXED_DEAL_AMOUNT = 2000.00; //FIXED_DEAL_AMOUNT: Fixed amount to use per trade
input ENUM_MA_PRICE     MA_PRICE = MA200; //MA_PRICE: MA to use for price
input ENUM_PRICE_BUFFER     PRICE_BUFFER = HALF_ATR; //PRICE_BUFFER: Buffer to add to MA price

//--- Global Variables
/*
_Symbol+_MAX_SPREAD              //Max spread for given symbol
*/

int ma100Handle = 0;
int ma200Handle = 0;
int atrHandle = 0;

double ma100[];
double ma200[];
double atr[];

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   init();

   int spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   printHelper(LOG_INFO, StringFormat("Script: About to execute buy on %s with spread %d ", _Symbol, spread));
   
   double price = 0.00;
   
   if(MA_PRICE == MA100) {
      price = ma100[0];
   } else if(MA_PRICE == MA200) {
      price = ma200[0];
   }
   
   if(PRICE_BUFFER == ATR) {
      double atrValue = atr[0];
      price = price - atrValue;
   } else if(PRICE_BUFFER == HALF_ATR) {
      double atrValue = (atr[0]/2);
      price = price - atrValue;
   }

   placeBuyLimit(m_trade, price, 0.00, 0.00, FIXED_DEAL_AMOUNT, "[M] ");
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
   
   //--- 100MA init
   ma100Handle = iMA(_Symbol,_Period,100,0,MODE_SMA,PRICE_CLOSE);
   if(ma100Handle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating 100 MA indicator");
      return;
   }
   
   //--- 200MA init
   ma200Handle = iMA(_Symbol,_Period,200,0,MODE_SMA,PRICE_CLOSE);
   if(ma200Handle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating 200 MA indicator");
      return;
   }
   
   //--- ATR init
   atrHandle = iATR(_Symbol,_Period,10);
   if(atrHandle == INVALID_HANDLE) {
      printHelper(LOG_ERROR, "Error creating ATR indicator");
      return;
   }
   
   //--- Copy tradeMA values
   ArraySetAsSeries(ma100,true);
   int copied = CopyBuffer(ma100Handle,0,0,100,ma100);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the trade iMA indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 100) {
      printHelper(LOG_ERROR, StringFormat("Moving Average trade indicator: %d elements out of 100 were copied",copied));
      return;
   }
   
   copied = 0;
   //--- Copy slowMA values
   ArraySetAsSeries(ma200,true);
   copied = CopyBuffer(ma200Handle,0,0,200,ma200);
   if(copied < 0) {
      printHelper(LOG_ERROR, StringFormat("Failed to copy data from the slow iMA indicator, error code %d",GetLastError()));
      return;
   } else if(copied < 200) {
      printHelper(LOG_ERROR, StringFormat("Moving Average slow indicator: %d elements out of 200 were copied",copied));
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
  }

//+------------------------------------------------------------------+
