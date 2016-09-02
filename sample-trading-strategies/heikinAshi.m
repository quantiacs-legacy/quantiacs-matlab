function [p, settings] = heikinAshi(DATE, OPEN, HIGH, LOW, CLOSE, VOL, exposure, equity, settings)
settings.markets     = {'BAC','UNH','TWX'};
settings.slippage    = 0.05;
settings.budget      = 1000000;
settings.samplebegin = 20150301;
settings.sampleend   = 20160301;
settings.lookback    = 11;

% Check if initial run
if ~exist('settings.HA_close','var')
    % Initial p vector, only need to define on first run
    settings.lastP = zeros(1,numel(settings.markets));
    % Initial Heikin Values
    settings.HA_close = (OPEN(1,:) + HIGH(1,:) + LOW(1,:) + CLOSE(1,:))/4;
    settings.HA_open = (OPEN(1,:) + CLOSE(1,:))/2;
    % Run across lookback period, starting with 2nd row
    for i=2:size(CLOSE,1)
        HAmatrix = HEIKIN(OPEN(i,:),HIGH(i,:),LOW(i,:),CLOSE(i,:),settings.HA_open,settings.HA_close);
        % To keep from running on latest value to use in trade logic
        if i < size(CLOSE,1)
            settings.HA_close = HAmatrix(1,:);
            settings.HA_open = HAmatrix(2,:);
        end
    end
else    % If not first run just get latest Heikin values
    HAmatrix = HEIKIN(OPEN(end,:),HIGH(end,:),LOW(end,:),CLOSE(end,:),settings.HA_open,settings.HA_close);
end

% Check Trade Logic
tLogic = TRADES(HAmatrix, settings.HA_open, settings.HA_close);

% Set new previous Heikin values for next run
settings.HA_close = HAmatrix(1,:);
settings.HA_open = HAmatrix(2,:);

% Execute Positions
p = EXECUTE_P(tLogic(1,:),tLogic(2,:),tLogic(3,:),tLogic(4,:),settings.lastP);

% Save positions to be able to do trade logic on next run
settings.lastP = p;

% Displays Date in the console while it's being processed
disp(['Processing ' num2str(DATE(end))]);

function out = HEIKIN(O, H, L, C, oldO, oldC)
    HA_close = (O+H+L+C)/4;
    HA_open = (oldO + oldC)/2;
    elements = [H; L; HA_open; HA_close];
    HA_high = max(elements,[],1);
    HA_low = min(elements,[],1);
    out = [HA_close; HA_open; HA_high; HA_low];
end

function out = TRADES(HA, oldO, oldC)
    % Trading Logic - Naive Reversal from earnForex
    % -------- Entry -----------
    % Buying
    % the latest completed HA candle is bearish, HA_close < HA_open
    long1 = HA(1,:) < HA(2,:);
    % body is longer than previous candle's body
    long2 = abs(HA(1,:) - HA(2,:)) > abs(oldC - oldO);
    % previous candle also bearish
    long3 = oldC < oldO;
    % latest candle has no upper wick HA_open == HA_high
    long4 = HA(2,:) == HA(3,:);
    long = long1 & long2 & long3 & long4;
    % Selling
    % latest candle is bullish
    % body is longer than previous candle's body
    % previous candle also bullish
    % latest candle has no lower wick HA_open == HA_low
    short4 = HA(2,:) == HA(4,:);
    short = ~long1 & long2 & ~long3 & short4;
    % --------------- Exit --------------
    % Exiting Long
    % same as short except for candle body length
    long_exit = ~long1 & ~long3 & short4;    
    % Exiting Short
    % same as long except for candle body length
    short_exit = long1 & long3 & long4;
    out = [long; short; long_exit; short_exit];
end

function out = EXECUTE_P(L, S, L_e, S_e, oldP)
    % Splitting buy and sell from P
    Pbought = oldP > 0;
    Psold = oldP < 0;
    % Close Long Positions
    closebuy = Pbought & L_e;
    oldP(closebuy) = 0;
    % Close Short Positions
    closesell = Psold & S_e;
    oldP(closesell) = 0;
    % Enter New Long Positions
    oldP(L) = 1;
    % Enter New Short Positions
    oldP(S) = -1;
    out = oldP;
end

end