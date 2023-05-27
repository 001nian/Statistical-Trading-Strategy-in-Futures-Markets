%Code to generate our portfolio vector.

function [portValue] = calculatePortfolio(chnLen, stpPct, open, high, low, close, capital)

%Calculate our running max and min.
runningMax = calculateMax(chnLen, high);
runningMin = calculateMin(chnLen, low);

%Generate our breakout signal vector.
signal = calculateSignal(chnLen, runningMax, runningMin, high, low);

%Based off the signal and our stpPct, generate our trade vector.
[trades, prices] = calculateTrades(chnLen, stpPct, signal, runningMax, runningMin, open, high, low, close);

%Initialize our portfolio vector
n = size(open, 1);
portValue = zeros(n, 1);
portValue(1:chnLen) = capital;

%Contract specifications from the professor's sheet
%contractSize = 1000; % TY
contractSize = 2000; % TU

slippage = 19;

currentPos = 0;
slippageThisTrade = 0;
priceTraded = 0;

for i = (chnLen+1):n
    
    %First calculate the change in our portfolio from the price change from
    %the previous bar's close to this bar's open.
    portValue(i) = portValue(i-1) + currentPos*contractSize*(open(i)-close(i-1));
    
    %If our trade vector is telling us to buy:
    if trades(i) == 1
        
        %Increase our current position by one.
        currentPos = currentPos + 1;
        
        %Only have slippage is we're back to being flat.
        slippageThisTrade = (1-abs(currentPos))*slippage;
        priceTraded = prices(i);
        
        %If we traded back to flat, we need to calculate the price change
        %from where we traded and where the price opened.
        portValue(i) = portValue(i) - (1-abs(currentPos))*contractSize*(priceTraded - open(i));
        
        %If we traded to go long, we need to calculate the price change
        %from the close and where we traded.
        portValue(i) = portValue(i) + currentPos*contractSize*(close(i) - priceTraded);
        
    %If our trade vector tells us to sell:     
    elseif trades(i) == -1
        
        %Decrease our current position by one.
        currentPos = currentPos - 1;
        slippageThisTrade = (1-abs(currentPos))*slippage;
        priceTraded = prices(i);
        portValue(i) = portValue(i) + (1-abs(currentPos))*contractSize*(priceTraded - open(i));
        portValue(i) = portValue(i) + currentPos*contractSize*(close(i) - priceTraded);
        
    elseif trades(i) == 0
        slippageThisTrade = 0;
        portValue(i) = portValue(i) + currentPos*contractSize*(close(i) - open(i));
    
    end

end
    
