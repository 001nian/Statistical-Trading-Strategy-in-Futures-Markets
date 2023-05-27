%Code to find the lowest low over a give channel length

function [runningMin] = calculateMin(t, low)
%Returns an array of the trailing minimum given a given channel length.

%Initialize our running minimum vector
n = size(low, 1);
runningMin = zeros(n, 1);

%Find our first trailing maximum.
runningMin(t) = min(low(1:t));

for i = (t+1):n
    
    %If our next low is less than our previous trailing min.
    if low(i) <= runningMin(i-1)
        runningMin(i) = low(i);
        
    %If our previous trailing min is equal to the low that will exit out channel.
    %Since our previous min left the window, need to recalculate min from
    %the whole channel.
    elseif runningMin(i-1) == low(i-t)
        runningMin(i) = min(low(i-t+1:i));
        
    %If neither case, then our trailing max stays the same.
    else
        runningMin(i) = runningMin(i-1);
    end
end
    
