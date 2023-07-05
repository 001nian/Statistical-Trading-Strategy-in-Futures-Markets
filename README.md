# Statistical-Trading-Strategy-in-Futures-Markets

- **Functions Descriptions:**

`calculatePortfolio` will generate a vector consisting of the value of the portfolio during each bar (5 minute window).

	-Takes in the following inputs:
		-chnLen is the channel length
		-stpPct is the stop loss percentage (in decimal format)
		-open is the vector of open prices the professor provided us
		-high is the vector of high prices the professor provided us
		-low is the vector of low prices the professor provided us
		-close is the vector of close prices the professor provided us
		-capital is the amount of capital we have to start (I'm not sure if this is necessary)

`calculateDrawdown` will generate a vector consisting of the current drawdown of the portfolio for each bar (5 minute window).

	-Takes in the following inputs:
		-portfolio is the vector of portfolio values calculated from 'calculatePortfolio'

`calculateMax, calculateMin, calculateSignal, and calculateTrades` are all helper functions used in `calculatePortfolio`.

	-Descriptions of each are located in the comments in the code

- **EasyLanguage Code Structure Description of the Strategies:**

_**MR—Stop—AvgPrice**_
```
/*
This trading system places mean-reverting trades around the moving average outside of a band of width related to expected slippage plus a certain number of local volatilities. It has a pre-determined per-trade loss size expressed in percent.
*/
Variable Parameters (5):
	N1(real), N2(real), VolLen(integer), MALen(integer), StpPct(real)
Constant Parameters (3):
	Kappa(real)=0.5, TradeSize(real)=1, Slpg(real)=0.001
Internal functions of a current bar:
	MarketPosition – gives a position that a trading system has at the end of the bar with the sign;
	Buy a certain position size at the next bar at a Price Stop or Limit;
	Sell a certain position size at the next bar at a Price Stop or Limit;
	EntryPrice – gives an average entry price for all current open positions;
Internal Variables:
	BndPct1(real), BndPct2(real), Vol(real), CanTrade(logical), MA(real), r(real);
At any bar the price vector is available for that bar and all previous ones:
Price = [Open, High, Low, Close];
Indexing: no index=current bar, index +1 – previous bar;
 
MA=average(Close, MALen);
r=(Close-Close(1))/Close(1);
Vol=sqrt(average((r-average(r,VolLen))^2,VolLen));
BndPct1=N1*Vol+Kappa*Slpg;
BndPct2=BndPct1+N2*Vol;
 
/* exits from existing positions*/
If MarketPosition>0 then
begin
	Sell MarketPosition next bar at MA Limit;
	Sell MarketPosition next bar at EntryPrice*(1-StpPct) Stop;
end;
elseif MarketPosition<0 then
begin
	Buy Abs(MarketPosition) next bar at MA Limit;
	Buy Abs(MarketPosition) next bar at EntryPrice*(1+StpPct) Stop;
end;
 
/* blocking from further trades if stopped until re-set condition is satisfied */
If StoppedAbove then
	CanTrade = False
 
/* re-set condition */
If (Close(1)<MA(1) & High>=MA) or (Close(1)>MA(1) & Low<=MA) or (High>=MA & Low<=MA) then
	CanTrade = True;
 
/* trade entries of the 1-st level*/
If CanTrade=True & CurrentContracts=0 then
begin
	Buy TradeSize next bar at MA*(1-BndPct1);
	Sell TradeSize next bar at MA*(1+BndPct1);
end;
 
/* trade entries of the 2-nd level*/
If CanTrade=True & Abs(CurrentContracts)=TradeSize then
begin
	Buy TradeSize next bar at MA*(1-BndPct2);
	Sell TradeSize next bar at MA*(1+BndPct2);
end;
```
_**TF—Channel—Stop**_
```
/*
This trading system places trend-following (breakout) trades outside of a moving channel. It has a pre-determined per-trade loss size expressed in percent.
*/
Variable Parameters (5):
	ChnLen(real), StpPct(real)
Constant Parameters (3):
	TradeSize(real)=1
Internal functions of a current bar:
	MarketPosition – gives a position that a trading system has at the end of the bar with the sign;
	Buy a certain position size at the next bar at a Price Stop;
	Sell a certain position size at the next bar at a Price Stop;
	EntryPrice – gives an average entry price for all current open positions;
Internal Variables:
	HighestHigh(real), LowestLow(real), PrevPeak(real), PrevThrough(real);
 
HighestHigh = max(High,ChnLen);
LowestLow = min(Low,ChnLen);
 
/* new orders */
If MarketPosition=0 then
begin
	Buy TradeSize next bar at HighestHigh Stop;
	Sell TradeSize next bar at LowestLow Stop;
end;
 
/* trailing stops for the existing positions */
If MarketPosition>0 then
begin
	PrevPeak = EntryPrice; /* local running maximum */
	if Close>PrevPeak then PrevPeak=Close;
	Sell TradeSize next bar at PrevPeak*(1-StpPct) Stop;
end;
elseif MarketPosition<0 then
begin
	PrevTrough = EntryPrice; /* local running minimum */
	if Close<PrevTrough then PrevTrough=Close;
	Buy TradeSize next bar at PrevTrough*(1+StpPct) Stop;
end;
```

- **More trend following strategies:**

--Moving Average crossover.

    -Define two moving averages: one short-term and one long-term
    -When the short-term crosses above the long-term, go long.
    -When the short-term crosses below the long-term, go flat (or go short).
    
-Types of moving averages

    -Simple
        -Simple mean of the price of the past X number of days.
    -Weighted
        -Weighted average by placing more weight on the more recent prices.
    -Exponential
        -A type of weighted moving average.
        -For a price that occured i days ago, the weight would be a^i. With 0<a<1
        
-MACD (Moving Average Convergence Divergence)

    -Another popular signal is the MACD.
    -Define the MACD as the difference between two exponential moving averages (for example say 12-day and 26-day)
        -MACD = 12day EMA - 26day EMA
    -Take an EMA of the MACD as your signal.
        -When the signal turns positive, go long.
        -When the signal turns negative, go flat (or go short)

- **PnL Formula description:**
 ![image](https://github.com/DhyeyMavani2003/Statistical-Trading-Strategy-in-Futures-Markets/assets/82772894/a8f91d11-089f-428f-a26d-9f6e1b5071be)

- I also did the mirror image changes to get the similar formula for the shorts
