function ret = runts(tsName, plotEquity, reloadData, state)
%RUNTS backtests a trading system. 
% runts evaluates the trading system function specified in the argument
% tsName and returns the struct ret. 
% runts calls the trading system for each period with sufficient market
% data, and collets the returns of each call to compose a backtest.
%
% USAGE:
%
% s = runts('tsName') evaluates the trading system specified in string
% tsName, and stores the result in struct s.
%
% ARGUMENTS:
%
% tsName       required  STRING   Specifies the trading system to be backtested
% plotEquity   optional  BOOLEAN  Show the equity curve plot after the evaluation
%              default   TRUE
% reloadData   optional  BOOLEAN  Force reload of market data.
%              default   FALSE
% state        optional  STRUCT   Resume computation of an existing backtest. state
%                                 needs to be of the same form as ret.
%
% RETURNS:
%
% ret                 STRUCT
% ret.tsName          STRING    Name of the trading system, same as tsName
% ret.fundDate        INTEGERS  All dates of the backtest in the format YYYYMMDD
% ret.fundEquity      DOUBLE    Equity curve for the fund (collection of
%                               all markets)
% ret.marketEquity    DOUBLE    Equity curves for each market in the fund
% ret.marketExposure  DOUBLE    Collection of the returns p of the trading system
%                               function. Equivalent to the percent
%                               exposure of each market in the fund.
%                               Normalized between -1 and 1
% ret.settings        STRUCT    The settings of the trading system as
%                               defined in file tsName
% ret.errorLog        CELL ARRAY of strings with error messages
% ret.runtime         DOUBLE    Runtime of the evaluation in seconds
% ret.stats           STRUCT    Performance numbers of the backtest
% ret.evalDate        INTEGER   Last market data present in the backtest
%
% Copyright Quantiacs LLC - March 2015

theClock = tic;

% Check if trading system specified in tsName exists
if ~exist('tsName', 'var'); disp('Please specify a Tradingsystem you want to run.'); return; end
if numel(tsName) > 1; if strcmp(tsName(end-1:end),'.m'); tsName = tsName(1:end-2); end; end
if exist([tsName '.m'], 'file') ~= 2; disp(['Tradingsystem ' tsName ' not found.']); return; end

% If optional arguments are not present set them to their defaults.
if ~exist('plotEquity', 'var'); plotEquity = true; end
if ~exist('reloadData', 'var'); reloadData = false; end

% Prepare DATA_CACHE and SETTINGS CACHE to speed up consecutive 
% evaluations of the same trading system 
global DATA_CACHE; global SETTINGS_CACHE;

% Read the settings of the trading system
settings = getSettings(tsName);

% If the settings changed reload market data. 
if isempty(SETTINGS_CACHE)
    SETTINGS_CACHE = settings;
else
    if ~isequal(SETTINGS_CACHE, settings)
        DATA_CACHE     = struct;
        SETTINGS_CACHE = settings;
        reloadData = true;
    end
end

% If state struct is present set ret to state, otherwise initialize ret
if ~exist('state', 'var'); state = struct; end;
if ~isstruct(state); state = struct; end;
ret = state;

% Set runtimeInterrupt to default false if not present
if ~any(strcmp(fieldnames(ret),'runtimeInterrupt')); ret.runtimeInterrupt = false; end

% Construct function handle from function name
ts = str2func(tsName);

% Load data
errorlog = cellstr('');
if reloadData || isempty(DATA_CACHE)
    DATA_CACHE = loaddata(settings,0);
end

% Get backtest relevant market data from DATA_CACHE
[DATE, OPEN, HIGH, LOW, CLOSE, VOL, OI, P, R, RINFO] = deal(DATA_CACHE.DATE, DATA_CACHE.OPEN, DATA_CACHE.HIGH, DATA_CACHE.LOW, DATA_CACHE.CLOSE, DATA_CACHE.VOL, DATA_CACHE.OI, DATA_CACHE.P, DATA_CACHE.R, DATA_CACHE.RINFO);

% Initialize variables 
nMarkets = numel(settings.markets);
nDays = size(DATE,1);

% Estimate slippage (the trading costs) as percentage of the daily range (ex-post)
SLIPPAGE = fillnans([NaN(1,nMarkets); (HIGH(2:end,:) - LOW(2:end,:)) ./ CLOSE(1:end-1,:)]) .* settings.slippage;

if isnan(settings.lookback); startLoop = 3; else startLoop = max(settings.lookback,3); end

exposure   = zeros(nDays,nMarkets);
equity     = ones(nDays,nMarkets);
fundEquity = ones(nDays,1);
realP      = zeros(nDays,nMarkets);
returns    = zeros(nDays,nMarkets);
sessions   = fillnans([NaN(1,nMarkets); (CLOSE(2:end,:) - OPEN(2:end,:)) ./ CLOSE(1:end-1,:)]);
gaps       = fillnans([NaN(1,nMarkets); (OPEN(2:end,:) - CLOSE(1:end-1,:) - RINFO(2:end,:)) ./ CLOSE(1:end-1,:)]);

% Create boolean matrix with contract rolls
Rix   = RINFO ~= 0;

% Compose cell array with arguments of the trading system function
[DATA_CACHE.exposure, DATA_CACHE.equity, DATA_CACHE.settings] = deal(exposure, equity, settings);
args = {};
for k = 1:numel(settings.arguments)
    args{k} = DATA_CACHE.(settings.arguments{k});
end

% Indices of distinguished fields in the arguments cell array
settingsIx = ismember(settings.arguments, {'settings'});
exposureIx = ismember(settings.arguments, {'exposure'});
equityIx   = ismember(settings.arguments, {'equity'});
ohlcIx     = ismember(settings.arguments, {'OPEN', 'HIGH', 'LOW', 'CLOSE'});
volIx      = ismember(settings.arguments, {'VOL'});
oiIx       = ismember(settings.arguments, {'OI'});

% If a state from a previous evaluation is present resume computation
if any(strcmp(fieldnames(ret), 'fundDate')) && any(strcmp(fieldnames(ret), 'marketEquity')) && any(strcmp(fieldnames(ret), 'marketExposure')) && any(strcmp(fieldnames(ret), 'settings'))
    ixNew = ~ismember(DATE, ret.fundDate);
    if ~any(ixNew)
        if plotEquity
            plotts(ret);
        end
        return;
    end
    equity(~ixNew,:)   = ret.marketEquity;
    exposure(~ixNew,:) = ret.marketExposure;
    startLoop          = max(startLoop, find(ixNew,1,'first'));
    disp(['Resuming ' tsName ' | computing ' num2str(nDays - startLoop + 1) ' new bars.']);
end

runtime = toc(theClock);

% Main evaluation loop. Calls the trading system for each day in the backtest period. 
for t = startLoop:nDays
    theClock    = tic;
    
    % Exposure (normalized vector p, output of the trading system function) of the last and current period. 
    todaysP     = exposure(t-1,:);
    yesterdaysP = realP(t-2,:);
    deltaP      = todaysP - yesterdaysP;
    
    % Orders are always placed at the open of the exchange session. The overnight gap
    % is traded with yesterdaysP. At the open the exposure changes to todaysP. 

    newGap = yesterdaysP .* gaps(t,:);
    newGap(isnan(newGap)) = 0;
    
    % Session open: Update the equity curve with the performance of the overnight gap 
    
    newRet = todaysP .* sessions(t,:) - abs(deltaP .*  SLIPPAGE(t,:));
    newRet(isnan(newRet)) = 0;
    
    % Session close: Update the equity curve with the performance during 
    % the exchange session 
    returns(t,:)  = newRet + newGap;
    equity(t,:)   = equity(t-1,:) .* (1+returns(t,:));
    fundEquity(t) = fundEquity(t-1) * (1+sum(returns(t,:)));
    realP(t-1,:)  = CLOSE(t,:) ./ CLOSE(t-1,:) .* fundEquity(t-1) ./ fundEquity(t) .* todaysP;
    
    if any(equityIx)
        args{equityIx} = equity;
    end
    
    % Perform roll if the current Futures contract approaches expiration
    if any(Rix(t,:))
        rollGap = zeros(size(CLOSE));
        rollGap(1:t-1,Rix(t,:)) = repmat(RINFO(t,Rix(t,:)), t-1,1);
        args(ohlcIx) = cellfun(@(x) x+rollGap , args(ohlcIx), 'UniformOutput', false);
    end
    
    % Compose argument list for the next call of the trading system.
    % The cell array arg contains the most recent input data available at time t.
    tIx = false(nDays,1);
    tIx(t-settings.lookback + 1:t) = true;
    
    arg = args;
    arg(~settingsIx) = cellfun(@(x) x(tIx,:), arg(~settingsIx), 'UniformOutput', false);
    arg{settingsIx}  = settings;
    
    % Call the trading system function and throw eventually ocurring errors.
    try
        [p, settings] = ts(arg{:});
    catch exception
        errorlog(end+1) = cellstr([num2str(DATE(t)) ': ' exception.message]);
        equity(t:end,:) = repmat(equity(t,:),nDays-t+1,1);
        throw(exception);
        break;
    end
    
    % Normalize and store the trading system's output vector p in the exposure matrix.
    p(isnan(p)) = 0;
    p(isinf(p)) = 0;
    p = real(p);

    if any(p)
        p = p ./ sum(abs(p));
    end
    
    exposure(t,:) = p;
    if any(exposureIx)
        args{exposureIx} = exposure;
    end
    
    % Check runtime and interrupt if it exceeds 300 seconds.
    runtime = runtime + toc(theClock);
    if runtime > 300 && ret.runtimeInterrupt
        errorlog(end+1) = cellstr('Evaluation stopped: Runtime exceeds 5 minutes.');
        break;
    end
end

% Define function outputs
ret.tsName         = tsName;
ret.fundDate       = DATE;
ret.fundEquity     = settings.budget .* cumprod(1+sum(returns,2));
ret.marketEquity   = equity;
ret.marketExposure = exposure;
ret.returns        = returns;
ret.settings       = settings;
ret.errorLog       = errorlog(2:end);
ret.runtime        = runtime;
ret.stats          = stats(ret.fundEquity);
ret.settings       = settings;
ret.evalDate       = DATE(t);

marketRets = fillnans([NaN(1,nMarkets); (CLOSE(2:end,:) - CLOSE(1:end-1,:) - RINFO(2:end,:)) ./ CLOSE(1:end-1,:)]);
marketRets(isnan(marketRets)) = 0;
ret.marketReturns  = marketRets;

% Plot results
if plotEquity
    plotts(ret);
end

end