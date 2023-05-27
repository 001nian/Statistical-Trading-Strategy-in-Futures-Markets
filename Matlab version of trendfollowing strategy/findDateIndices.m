%Code to find the indices of each starting month

function [monthsIndices] = findDateIndices(date)

%Length between data points (in minutes)
barTime = 5;
%Daily trading time (in minutes). This is for TU and TY from sheet.
dailyTradingTime = 400;
dailyTicks = dailyTradingTime / barTime;

n = size(date, 1);
monthsIndices = zeros(n,1);

index = 1;
i = 2;

while (i <= n)
    if month(date(i)) ~= month(date(i-1))
        monthsIndices(index) = i;
        
        %We know we won't hit the next month for a while, so let's skip
        %ahead. I'm being conservative with adding dailyTick * 13.
        i = i + dailyTicks*13;
        index = index + 1;
    end
    i = i+1;
end
monthsIndices = monthsIndices(monthsIndices~=0);

