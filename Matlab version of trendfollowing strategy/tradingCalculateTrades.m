%Code to generate our trading signals.
%Will use our boolean signals based on breakouts and stop percentage.

function [trades, prices] = tradingCalculateTrades(start, stop, stpPct, signal,...
    runningMax, runningMin, open, high, low, close, check)

%Initialize our trade vector.
n = size(open, 1);
%global trades;
%global prices;
%global runningMax;
%global runningMin;
%global signal;
trades = zeros(n, 1);
prices = zeros(n, 1);

pointValue = 10; %PL
%pointValue = 100; %CO

%global currentPosition;
currentPos = 0;
prevPeak = 0.00;
prevTrough = 0.00;

global portTrades;
global portPrices;

if check ~= 0
    
    for i = start:stop

        %If we currently are flat, we need to simply look at our breakout
        %signals we generated in calculateSignal.
        if currentPos == 0

            %If the signal for the previous bar is 1, that is telling us there is a breakout to the
            %upside and to go long the future. Need to initialize prevPeak to
            %where we bought the futures contract at.
            if signal(i) == 1
                %trades(j,k,i) = 1;
                trades(i) = 1;
                currentPos = 1;
                %We use the max function in case there was a gap in the price.
                %prices(j,k,i) = max(runningMax(i-1), open(i));
                %prevPeak = prices(j,k,i);
                prices(i) = max(runningMax(i-1), open(i));
                prevPeak = prices(i);

            %If the signal for the previous bar is -1, that is telling us there is a breakout to the
            %downside and to go short the future. Need to initialize prevTrough
            %to where we sold the futures ocntract at
            elseif signal(i) == -1
                %trades(j,k,i) = -1;
                trades(i) = -1;
                currentPos = -1;
                %We use the min function in case there was a gap in the price.
                %prices(j,k,i) = min(runningMin(i-1),open(i));
                %prevTrough = prices(j,k,i);
                prices(i) = min(runningMin(i-1), open(i));
                prevTrough = prices(i);

            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
            end

        %If we are currently long the futures contract, we now don't need to
        %look at the signal. We simply keep updating prevPeak (if necessary)
        %and exit the position when we hit our stop loss.   
        elseif currentPos == 1

            if high(i-1) > prevPeak
                prevPeak = high(i-1);
                %trades(j,k,i)=0;
                trades(i) = 0;
            elseif low(i) < (1-stpPct) * prevPeak
                %trades(j,k,i) = -1;
                trades(i) = -1;
                %We use the min function in case there was a gap in the price.
                %prices(j,k,i) = min(open(i), (1-stpPct)*prevPeak);
                prices(i) = min(open(i), ( floor( pointValue*(1-stpPct)*prevPeak) /pointValue) );
                currentPos = 0;
            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
            end

        %If we are currently short the futures contract, we now don't need to
        %look at the signal. We simply keep updating prevTrough (if necessary)
        %and exit the position when we hit our stop loss.   
        elseif currentPos == -1
            if low(i-1) < prevTrough
                prevTrough = low(i-1);
                %trades(j,k,i) = 0;
                trades(i) = 0;
            elseif high(i-1) > (1+stpPct) * prevTrough
                %trades(j,k,i) = 1;
                trades(i) = 1;
                %We use the max function in case there was a gap in the price.
                %prices(j,k,i) = max(open(i), (1+stpPct)*prevTrough);
                prices(i) = max(open(i), ( ceil( pointValue*(1+stpPct)*prevTrough) )/ pointValue);
                currentPos = 0;
            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
            end
        end

        %{
        if currentPosition(j,k,i) == 0 && currentPos == 0
            return;
        end
        %}
        %currentPosition(j,k,i) = currentPos;

    end 
    
else
    
    for i = start:stop

        %If we currently are flat, we need to simply look at our breakout
        %signals we generated in calculateSignal.
        if currentPos == 0

            %If the signal for the previous bar is 1, that is telling us there is a breakout to the
            %upside and to go long the future. Need to initialize prevPeak to
            %where we bought the futures contract at.
            if signal(i) == 1
                %trades(j,k,i) = 1;
                trades(i) = 1;
                portTrades(i) = 1;
                currentPos = 1;
                %We use the max function in case there was a gap in the price.
                %prices(j,k,i) = max(runningMax(i-1), open(i));
                %prevPeak = prices(j,k,i);
                prices(i) = max(runningMax(i-1), open(i));
                portPrices(i) = prices(i);
                prevPeak = prices(i);

            %If the signal for the previous bar is -1, that is telling us there is a breakout to the
            %downside and to go short the future. Need to initialize prevTrough
            %to where we sold the futures ocntract at
            elseif signal(i) == -1
                %trades(j,k,i) = -1;
                trades(i) = -1;
                portTrades(i) = -1;
                currentPos = -1;
                %We use the min function in case there was a gap in the price.
                %prices(j,k,i) = min(runningMin(i-1),open(i));
                %prevTrough = prices(j,k,i);
                prices(i) = min(runningMin(i-1), open(i));
                portPrices(i) = prices(i);
                prevTrough = prices(i);

            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
                portTrades(i) = 0;
            end

        %If we are currently long the futures contract, we now don't need to
        %look at the signal. We simply keep updating prevPeak (if necessary)
        %and exit the position when we hit our stop loss.   
        elseif currentPos == 1

            if high(i-1) > prevPeak
                prevPeak = high(i-1);
                %trades(j,k,i)=0;
                trades(i) = 0;
                portTrades(i) = 0;
            elseif low(i) < (1-stpPct) * prevPeak
                %trades(j,k,i) = -1;
                trades(i) = -1;
                portTrades(i) = -1;
                %We use the min function in case there was a gap in the price.
                %prices(j,k,i) = min(open(i), (1-stpPct)*prevPeak);
                prices(i) = min(open(i), ( floor( pointValue*(1-stpPct)*prevPeak) /pointValue) );
                portPrices(i) = prices(i);
                currentPos = 0;
            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
                portTrades(i) = 0;
            end

        %If we are currently short the futures contract, we now don't need to
        %look at the signal. We simply keep updating prevTrough (if necessary)
        %and exit the position when we hit our stop loss.   
        elseif currentPos == -1
            if low(i-1) < prevTrough
                prevTrough = low(i-1);
                %trades(j,k,i) = 0;
                trades(i) = 0;
                portTrades(i) = 0;
            elseif high(i-1) > (1+stpPct) * prevTrough
                %trades(j,k,i) = 1;
                trades(i) = 1;
                portTrades(i) = 1;
                %We use the max function in case there was a gap in the price.
                %prices(j,k,i) = max(open(i), (1+stpPct)*prevTrough);
                prices(i) = max(open(i), ( ceil( pointValue*(1+stpPct)*prevTrough) )/ pointValue);
                portPrices(i) = prices(i);
                currentPos = 0;
            else
                %trades(j,k,i) = 0;
                trades(i) = 0;
                portTrades(i) = 0;
            end
        end

        %{
        if currentPosition(j,k,i) == 0 && currentPos == 0
            return;
        end
        %}
        %currentPosition(j,k,i) = currentPos;

    end
end
%Make sure we close out any position we have at the end of the sample.
if currentPos == 1
    %trades(j,k,stop) = -1;
    trades(stop) = -1;
    portTrades(stop) = -1;
    %prices(j,k,stop) = close(stop);
    prices(stop) = close(stop);
    portPrices(stop) = close(stop);
elseif currentPos == -1
    %trades(j,k,stop) = 1;
    trades(stop) = 1;
    portTrades(stop) = 1;
    %prices(j,k,stop) = close(stop);
    prices(stop) = close(stop);
    portPrices(stop) = close(stop);
end
%disp(sum(abs(trades)));       
        
        
