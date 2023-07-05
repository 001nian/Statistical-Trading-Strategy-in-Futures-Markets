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

_**1. MR—Stop—AvgPrice**_

This strategy aims to place mean-reverting trades around a moving average, using a band of width related to expected slippage and local volatilities. The strategy has a predetermined per-trade loss size expressed as a percentage.

**Variable Parameters:**

- **N1:** A real number used to calculate the width of the band around the moving average.
- **N2:** A real number used to calculate an extended width of the band around the moving average.
- **VolLen:** An integer representing the length of the volatility calculation period.
- **MALen:** An integer representing the length of the moving average.
- **StpPct:** A real number representing the predetermined per-trade loss size as a percentage.

**Constant Parameters:**

- **Kappa:** A fixed value of 0.5.
- **TradeSize:** The size of each trade position.
- **Slpg:** Expected slippage value.

**Internal functions:**

- **MarketPosition:** Returns the position that the trading system holds at the end of the current bar (positive for long, negative for short).
- **Buy:** Places a buy order for a specified position size at the next bar, using a price stop or limit.
- **Sell:** Places a sell order for a specified position size at the next bar, using a price stop or limit.
- **EntryPrice:** Calculates the average entry price for all current open positions.

**Internal Variables:**

- **BndPct1:** A real number representing the lower band width around the moving average.
- **BndPct2:** A real number representing the upper band width around the moving average.
- **Vol:** The calculated volatility value.
- **CanTrade:** A logical variable indicating whether further trades are allowed.
- **MA:** The moving average value.
- **r:** The percentage change in price.

At each bar, the strategy calculates the moving average (MA) and the percentage change in price (r). It also calculates the volatility (Vol) based on the average squared difference between the percentage changes and their mean over a specified period.

The band widths (BndPct1 and BndPct2) are calculated using the volatility and predefined constants. These bands define the trading zones around the moving average.

The strategy first handles exits from existing positions by placing sell orders when the market position is positive and buy orders when the market position is negative. The sell and buy orders have limits and stops based on the moving average and the average entry price.

Next, the strategy checks if trading is blocked due to a previous stop, and if so, it sets the CanTrade variable to False.

Then, the strategy determines the re-entry condition by checking if the previous bar's close is on one side of the moving average and the current bar's high or low is on the opposite side of the moving average.

Finally, the strategy executes trade entries at two levels. If the re-entry condition is satisfied and there are no open positions, it places buy and sell orders at the moving average multiplied by the respective band widths (BndPct1). If there are existing positions with a size equal to TradeSize, it places additional buy and sell orders at the moving average multiplied by the extended band widths (BndPct2).

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
_**2. TF—Channel—Stop**_

The TF—Channel—Stop trading strategy is a trend-following strategy that identifies breakout trades outside of a moving channel. The strategy aims to take advantage of upward or downward price trends by entering positions when the price breaks out of the channel. It also includes a predetermined per-trade loss size expressed as a percentage.

**Variable Parameters:**

- **ChnLen:** A real number representing the length of the channel. It determines the number of bars used to calculate the highest high and lowest low within the channel.
- **StpPct:** A real number representing the predetermined per-trade loss size as a percentage. It determines the stop level for protecting the trade in case the price moves against the desired direction.

**Constant Parameters:**

- **TradeSize:** The size of each trade position.

**Internal functions:**

- **MarketPosition:** Returns the position that the trading system holds at the end of the current bar (positive for long, negative for short, 0 for no position).
- **Buy:** Places a buy order for a specified position size at the next bar, using a price stop.
- **Sell:** Places a sell order for a specified position size at the next bar, using a price stop.
- **EntryPrice:** Calculates the average entry price for all current open positions.

**Internal Variables:**

- **HighestHigh:** The highest high value within the channel.
- **LowestLow:** The lowest low value within the channel.
- **PrevPeak:** A variable to keep track of the previous peak price within the channel.
- **PrevThrough:** A variable to keep track of the previous trough price within the channel.

The strategy starts by calculating the highest high and lowest low values within the channel based on the ChnLen parameter. These values help define the boundaries of the channel.

If the market position is 0 (no open positions), the strategy places new orders. It sets a buy order at the HighestHigh value as a stop order, indicating that if the price exceeds the channel's upper boundary, it triggers a buy entry. Similarly, it sets a sell order at the LowestLow value as a stop order, indicating that if the price falls below the channel's lower boundary, it triggers a sell entry.

For existing positions, the strategy implements trailing stops to protect profits and manage risk. If the market position is positive (indicating a long position), it updates the PrevPeak variable as the highest of the EntryPrice and the current bar's close. It then places a sell order at PrevPeak multiplied by (1 - StpPct), which serves as a trailing stop to protect profits.

Conversely, if the market position is negative (indicating a short position), the strategy updates the PrevThrough variable as the lowest of the EntryPrice and the current bar's close. It then places a buy order at PrevThrough multiplied by (1 + StpPct), serving as a trailing stop for the short position.

By using trailing stops, the strategy allows profitable positions to continue running while limiting potential losses if the price reverses.

The TF—Channel—Stop strategy combines breakout entry orders with trailing stops to capture and protect profits in trending markets. It dynamically adjusts the stop levels based on the channel boundaries and the predetermined loss size, allowing traders to participate in price movements while managing risk.

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
