//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

CAccountInfo m_account;
CTrade       m_trade; 

ulong    baseMagic = 11223300000;//First six digits represent ea base, last three represent minutes in timeframe
ulong    m_slippage=5;

const int LOG_NONE  = 0;
const int LOG_ERROR = 1;
const int LOG_WARN  = 2;
const int LOG_INFO  = 3;
const int LOG_DEBUG = 4;

//+------------------------------------------------------------------+
//| Returns magic number which includes timeframe info                                                                 |
//+------------------------------------------------------------------+
ulong getMagicWithTimeframe()
  {
   long tfMinutes = PeriodSeconds(PERIOD_CURRENT) / 60;
   long withTimeframe = baseMagic + tfMinutes;
   printHelper(LOG_DEBUG, StringFormat("Base magic %I64u becomes %I64u with timeframe",baseMagic,withTimeframe));
   return withTimeframe;
  }

//+------------------------------------------------------------------+
//| Returns given magic number with timeframe info removed                                                              |
//+------------------------------------------------------------------+
ulong getMagicWithoutTimeframe(ulong magic)
  {
   long withoutTimeframe = MathFloor(magic / 10000) * 10000;
   printHelper(LOG_DEBUG, StringFormat("Magic %I64u becomes %I64u without timeframe",magic,withoutTimeframe));
   return withoutTimeframe;
  }

//+------------------------------------------------------------------+
//| Adjusts the point size according to symbol digits                                                                 |
//+------------------------------------------------------------------+
double getAdjustedPoint()
  {
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 3 || SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 5)
      digits_adjust=10;

   double m_adjusted_point = SymbolInfoDouble(_Symbol,SYMBOL_POINT) * digits_adjust;
   printHelper(LOG_DEBUG, StringFormat("_Point value is %f",m_adjusted_point));
   printHelper(LOG_DEBUG, StringFormat("_Period value is %d",_Period));

   return m_adjusted_point;
  }

//+------------------------------------------------------------------+
//| Normalizes the volume so that it aligns to lot step size                                                                 |
//+------------------------------------------------------------------+
double getNormalizedVolume(ENUM_ORDER_TYPE orderType, double price, double fixedAmount)
  {
//--- Get margin for one stepvol
   double stepvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double lot = stepvol;
   double stepMargin = m_account.MarginCheck( _Symbol,orderType,stepvol,price);
   
   if(stepMargin > 0.00) {
      lot = stepvol*(fixedAmount/stepMargin);
   }

   lot=stepvol*NormalizeDouble(lot/stepvol,0);

   double minvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(lot<minvol)
      lot=minvol;

   double maxvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(lot>maxvol)
      lot=maxvol;

   return lot;
  }

//+------------------------------------------------------------------+
//| Places a buy order                                                                 |
//+------------------------------------------------------------------+
void placeBuyOrder(CTrade &m_trade, double sl, double tp, double fixedAmount, string commentPrefix)
  {
   double price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   sl = NormalizeDouble(sl,SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double volume = getNormalizedVolume(ORDER_TYPE_BUY, price, fixedAmount);

//---BEGIN Calc margin
   double margin = 0.00;
   ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
   OrderCalcMargin(orderType, _Symbol,volume,price,margin);
//---END Calc margin

   printHelper(LOG_INFO, StringFormat("About to place buy order of volume %f and amount %f ", volume, margin));
   string comment = commentPrefix + AccountInfoString(ACCOUNT_CURRENCY) + DoubleToString(margin, 2) + " on timeframe " + _Period;
   m_trade.Buy(volume,_Symbol,price,sl,tp,comment);
  }
  
//+------------------------------------------------------------------+
//| Places a buy limit                                                                 |
//+------------------------------------------------------------------+
void placeBuyLimit(CTrade &m_trade, double price, double sl, double tp, double fixedAmount, string commentPrefix)
  {
   sl = NormalizeDouble(sl,SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double volume = getNormalizedVolume(ORDER_TYPE_BUY, price, fixedAmount);

//---BEGIN Calc margin
   double margin = 0.00;
   ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY;
   OrderCalcMargin(orderType, _Symbol,volume,price,margin);
//---END Calc margin

   printHelper(LOG_INFO, StringFormat("About to place buy limit of volume %f and amount %f ", volume, margin));
   string comment = commentPrefix + AccountInfoString(ACCOUNT_CURRENCY) + DoubleToString(margin, 2) + " L on timeframe " + _Period;
   m_trade.BuyLimit(volume,price,_Symbol,sl,tp,0,0,comment);
  }

//+------------------------------------------------------------------+
//| Places a sell order                                                                 |
//+------------------------------------------------------------------+
void placeSellOrder(CTrade &m_trade, double sl, double tp, double fixedAmount, string commentPrefix)
  {
   double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   sl = NormalizeDouble(sl,SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double volume = getNormalizedVolume(ORDER_TYPE_SELL, price, fixedAmount);

//---BEGIN Calc margin
   double margin = 0.00;
   ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
   OrderCalcMargin(orderType, _Symbol,volume,price,margin);
//---END Calc margin

   printHelper(LOG_INFO, StringFormat("About to place sell order of volume %f and amount %f", volume, margin));
   string comment = commentPrefix + AccountInfoString(ACCOUNT_CURRENCY) + DoubleToString(margin, 2) + " on timeframe " + _Period;
   m_trade.Sell(volume,_Symbol,price,sl,tp,comment);
  }
  
//+------------------------------------------------------------------+
//| Places a sell limit                                                                 |
//+------------------------------------------------------------------+
void placeSellLimit(CTrade &m_trade, double price, double sl, double tp, double fixedAmount, string commentPrefix)
  {
   sl = NormalizeDouble(sl,SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double volume = getNormalizedVolume(ORDER_TYPE_SELL, price, fixedAmount);

//---BEGIN Calc margin
   double margin = 0.00;
   ENUM_ORDER_TYPE orderType = ORDER_TYPE_SELL;
   OrderCalcMargin(orderType, _Symbol,volume,price,margin);
//---END Calc margin

   printHelper(LOG_INFO, StringFormat("About to place sell limit of volume %f and amount %f", volume, margin));
   string comment = commentPrefix + AccountInfoString(ACCOUNT_CURRENCY) + DoubleToString(margin, 2) + " L on timeframe " + _Period;
   m_trade.SellLimit(volume,price,_Symbol,sl,tp,0,0,comment);
  }

//+------------------------------------------------------------------+
//| Checks whether the index represents a green/bull bar                                                                 |
//+------------------------------------------------------------------+
bool isGreen(int index)
  {
   double open  = iOpen(NULL,0,index);
   double close = iClose(NULL,0,index);

   return open < close;
  }

//+------------------------------------------------------------------+
//| Checks whether the index represents a red/bear bar                                                                 |
//+------------------------------------------------------------------+
bool isRed(int index)
  {
   double open  = iOpen(NULL,0,index);
   double close = iClose(NULL,0,index);

   return open > close;
  }

//+------------------------------------------------------------------+
//| Locates the most recent green bar in the series                                                                 |
//+------------------------------------------------------------------+
int findLastGreenBar(int maxBars)
  {
   for(int i = 1; i <= maxBars; i++)   //surely we will find our bar within maxBars?
     {
      if(isGreen(i))
        {
         return i;
        }
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Locates the most recent red bar in the series                                                                 |
//+------------------------------------------------------------------+
int findLastRedBar(int maxBars)
  {
   for(int i = 1; i <= maxBars; i++)   //surely we will find our bar within MaxBars?
     {
      if(isRed(i))
        {
         return i;
        }
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Prints a formatted string according to log level set                                                                 |
//+------------------------------------------------------------------+
void printHelper(int level, string formattedText)
  {
   int logLevel = GlobalVariableGet("LOG_LEVEL");
   if(level <= logLevel)
     {
      Print(formattedText);
     }
  }
//+------------------------------------------------------------------+
