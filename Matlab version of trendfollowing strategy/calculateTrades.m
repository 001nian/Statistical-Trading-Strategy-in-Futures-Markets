%Code to generate our trading signals.
%Will use our boolean signals based on breakouts and stop percentage.

function [trade, price] = calculateTrades(t, stpPct, signal, runningMax, runningMin, open, high, low, close)

%Initialize our trade and price vector.
n = size(open, 1);
trade = zeros(n, 1);
price = zeros(n,1);

currentPos = 0;
prevPeak = 0.00;
prevTrough = 0.00;

for i = (t+1):(n-1)
    
    %If we currently are flat, we need to simply look at our breakout
    %signals we generated in calculateSignal.
    if currentPos == 0
        
        %If the signal for the previous bar is 1, that is telling us there is a breakout to the
        %upside and to go long the future. Need to initialize prevPeak to
        %where we bought the futures contract at.
        if signal(i) == 1
            trade(i) = 1;
            currentPos = 1;
            %We use the max function in case there was a gap in the price.
            price(i) = max(runningMax(i-1), open(i));
            prevPeak = price(i);
            
        %If the signal for the previous bar is -1, that is telling us there is a breakout to the
        %downside and to go short the future. Need to initialize prevTrough
        %to where we sold the futures ocntract at
        elseif signal(i) == -1
            trade(i) = -1;
            currentPos = -1;
            %We use the min function in case there was a gap in the price.
            price(i) = min(runningMin(i-1),open(i));
            prevTrough = price(i);
        end
        
    %If we are currently long the futures contract, we now don't need to
    %look at the signal. We simply keep updating prevPeak (if necessary)
    %and exit the position when we hit our stop loss.   
    elseif currentPos == 1
        
        if high(i-1) > prevPeak
            prevPeak = high(i-1);
        elseif low(i) < (1-stpPct) * prevPeak
            trade(i) = -1;
            %We use the min function in case there was a gap in the price.
            price(i) = min(open(i), (1-stpPct)*prevPeak);
            currentPos = 0;
        end
    
    %If we are currently short the futures contract, we now don't need to
    %look at the signal. We simply keep updating prevTrough (if necessary)
    %and exit the position when we hit our stop loss.   
    elseif currentPos == -1
        if low(i-1) < prevTrough
            prevTrough = low(i-1);
        elseif high(i-1) > (1+stpPct) * prevTrough
            trade(i) = 1;
            %We use the max function in case there was a gap in the price.
            price(i) = max(open(i), (1+stpPct)*prevTrough);
            currentPos = 0;
        end
    end
end 

%Make sure we close out any position we have at the end of the sample.
if currentPos == 1
    trade(n) = -1;
    price(n) = close(n);
elseif currentPos == -1
    trade(n) = 1;
    price(n) = close(n);
end
        
        
