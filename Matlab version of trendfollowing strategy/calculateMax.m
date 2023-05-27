%Code to find the highest high over a give channel length
function [runningMax] = calculateMax(t, high)
%Returns an array of the trailing maximum given a given channel length.

%Initialize our running maximum vector
n = size(high, 1);
runningMax = zeros(n, 1);

%Find our first trailing maximum.
runningMax(t) = max(high(1:t));

for i = (t+1):n
    
    %If our next high is greater than our previous trailing max.
    if high(i) >= runningMax(i-1)
        runningMax(i) = high(i);
        
    %If our previous trailing max is equal to the high that will become out of our channel.
    %Since our previous max left the window, need to recalculate max from
    %the whole channel.
    elseif runningMax(i-1) == high(i-t)
        runningMax(i) = max(high(i-t+1:i));
        
    %If neither case, then our trailing max stays the same.
    else
        runningMax(i) = runningMax(i-1);
    end
end
    
