%Code to brute force optimize the channel length and stop loss.

function [portfolio] = tradingStrategy(t, tau, date, open, high, low, close, capital)
%t refers to the length of our backtest (in years)
%tau referes to the length of our out-of-sample testings (in months)
%tic;
%Define what channels to test.
chnLenStart = 500; %roughly one week
chnLenEnd = 600; %roughly two months
chnLenStep = 50; %roughly one day
chnLenVector = chnLenStart:chnLenStep:chnLenEnd;

optimizedChannel = zeros(size(open, 1), 1);
%Define what stop losses to test.
stpPctStart = .005;
stpPctEnd = .01;
stpPctStep = .005;
%global stpPctVector;
stpPctVector = stpPctStart:stpPctStep:stpPctEnd;
optimizedStp = zeros(size(open, 1), 1);

n = length(chnLenVector);
m = length(stpPctVector);

%Create an array that will correspond to each chnLen and stpPct pair.
myArray = zeros(n,m);

l = size(high, 1);
%We want to store a runningMax vector, runningMin vector, and signal vector
%for each of our chnlen's we are testing.
%global runningMax;
%global runningMin;
%global signal;
runningMax = zeros(n, l);
runningMin = zeros(n, l);
signal = zeros(n, l);

global portTrades;
global portPrices;
portTrades = zeros(l, 1, 'int8');
portPrices = zeros(l, 1);
%trades = zeros(n, m, l, 'int8');
%prices = zeros(n, m, l);

%global currentPosition;
%currentPosition = zeros(n, m, l, 'int8');
%currentPosition(:) = -2;

for i = 1:n
    %disp(n-i);
    %Calculate our trailing max, trailing min, and signal for this chnLen
    runningMax(i,:) = movmax(high, [chnLenVector(i) 0]);
    %calculateMax(chnLenVector(i), high);
    runningMin(i,:) = movmin(low, [chnLenVector(i) 0]);
    %(chnLenVector(i), low);
    signal(i,:) = calculateSignal(chnLenVector(i), runningMax(i,:), runningMin(i,:), high, low);
    %signal(i,:) = calculateSignal(chnLenVector(i), i, high, low);
    
end

%I'm assuming we will start trading out of sample on the first trading day
%of the month. As such, I want to find the indices of those days.
dateIndices = findDateIndices(date);
ld = length(dateIndices);


%Need to make sure we have enough data to backtest to start off.
%yearsOfTrading refers to how many years we will test our trading strategy.
%E.g. 10 means we will test our trading strategy through the last 10 years.
yearsOfTrading = 9-t;
startingPoint = size(dateIndices,1) - 12*yearsOfTrading;
i = startingPoint;

portfolio = zeros(length(open), 1);
portfolio((dateIndices(i)-1)) = capital;
%portfolio = portfolio(portfolio~=0);

while i <= (size(dateIndices,1)-tau)
    tic;
    
    %First baplcktest to find chnLen and stpPct
    %This is the optimization step that is currently doing basic grid
    %search.
    start = dateIndices(i-12*t);
    stop = dateIndices(i)-1;
    
    check = -1;
    
    for j = 1:n
        for k = 1:m
                        
            %Find our backtest portfolio, drawdown for each chnLen and stpPct
            %testPortfolio = tradingCalculatePortfolio(start, stop, j, k, ...
                %open, high, low, close, capital);
            testPortfolio = tradingCalculatePortfolio(start, stop, stpPctVector(k), ...
                        signal(j,:), runningMax(j,:), runningMin(j,:), ...
                        open, high, low, close, capital, check);
                    
            drawdown = calculateDrawdown(testPortfolio, start, stop);

            myArray(j,k) = (testPortfolio(stop)-testPortfolio(start)) / max(abs(drawdown));
        end
    end
    
    %Find the max of our array and its indices.
    [~,I] = max(myArray(:));
    [rowIndex, colIndex] = ind2sub(size(myArray),I);
    
    %Use the indices to find the optimal channel length and stop loss.
    optimalChnLen = chnLenStart + (rowIndex-1) * chnLenStep;
    optimalStpPct = stpPctStart + (colIndex-1) * stpPctStep;
    
    optimizedChannel(i) = optimalChnLen;
    optimizedStp(i) = optimalStpPct;
    
    %Some sanity checking.
    disp(optimalChnLen);
    disp(optimalStpPct);
    
    %Now we are going to run the portfolio out of sample.
    start = dateIndices(i);
    stop = dateIndices(i+tau)-1;
    
    %Find where our portfolio currently stands before starting the next out
    %of sample trading session.
    capital = portfolio(dateIndices(i)-1);
    check = 0;
    
    %Calculate the next out of sample portfolio.
    newPortfolioAddition = tradingCalculatePortfolio(start, stop, optimalStpPct, ...
       signal(rowIndex,:), runningMax(rowIndex,:), runningMin(rowIndex,:), ...
       open, high, low, close, capital, check);
    
    %Get rid of all the zeros that are before and after our trading range.
    temp = newPortfolioAddition(newPortfolioAddition~=0);

    %Append this out of sample portfolio to our existing portfolio.
    portfolio(dateIndices(i):(dateIndices(i+tau)-1)) = temp;
    
    %Increament i by tau; go to the next start of out of sample trading.
    i = i+tau;
    
    %Just for sanity while the code is running.
    disp(i);
    toc;
end
portfolio = portfolio(portfolio~=0);
%filename = strcat(int2str(t), ' ', int2str(tau), ' ', 'data'); 
filename = strcat('co', int2str(t), ' ', int2str(tau), ' ', 'data'); 
save(filename) 
%, portTrades, portfolio, optimizedChannel, optimizedStp);

%toc;
