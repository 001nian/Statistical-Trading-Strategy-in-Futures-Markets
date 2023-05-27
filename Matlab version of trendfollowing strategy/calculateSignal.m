%Code to generate our boolean trading signals simply based on breakouts.
%I.e. these signals only used if position=0

function [signal] = calculateSignal(t, max, min, high, low)
%Will return a vector consisting of 1s, 0s, and -1s.
%1 corresponds to the next bar's high being greater than the trailing max.
%-1 corresponds to the next bar's low being less than the trailing min.
%0 indicates neither option.

%Initialize our signal vector
n = size(max, 1);
signal = zeros(n, 1);

for i = (t+1):n
    
    %If the next high is greater than the trailing max:
    if high(i) > max(i-1)
        
        %Make sure we didn't breakout up and down within the bar.
        %Not sure this will ever happen but figured it's a good safety net.
        if low(i) < min(i-1)
            signal(i) = 0;
            
        %Make the signal 1 since the futures contract is breaking out to
        %the upside.
        else
            signal(i) = 1;
        end
    
    %If the next low is less than the trailing min, make the signal -1
    %since the futures contract is breaking out to the downside.
    elseif low(i) < min(i-1)
        signal(i) = -1;
    end
end
