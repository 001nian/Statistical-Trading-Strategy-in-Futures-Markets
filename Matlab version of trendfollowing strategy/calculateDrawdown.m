%Code to generate our drawdown vector.
function [drawdown] = calculateDrawdown(portfolio, start, stop)

%Initialize drawdown vector.
n = size(portfolio, 1);
drawdown = zeros(n, 1);

%Initialize our previous peak.
prevPeak = portfolio(start);

for i = start:stop
    
    %If our portfolio is below its previous peak, the drawdown is the
    %difference between the two.
    if portfolio(i) < prevPeak
        drawdown(i) = portfolio(i) - prevPeak;
        
    %If our portfolio is above its previous peak, we need to update the
    %previous peak to the current portfolio value.
    elseif portfolio(i) > prevPeak
        prevPeak = portfolio(i);
    end
end

        