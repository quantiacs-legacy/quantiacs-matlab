function [settings] = getSettings(tsN)
%GETSETTINGS scans a trading system file for its global settings and
% returns them in struct settings.
% getSettings is called once from runts prior to the first call of a
% trading system.
%
% USAGE:
%
% s = getSettings('tsName') parses trading system tsName and stores its
% settings in struct s.
%
% ARGUMENTS:
%
% tsName       required. STRING.  Specifies the trading system to be
%                                 scanned
%
% RETURNS:
%
% settings               STRUCT
% settings.arguments     CELL ARRAY of strings with arguments of the trading system
% settings.markets       CELL ARRAY of strings with the list of market
%                                 identifiers
% settings.samplebegin   INTEGER  Date in the format YYYYMMDD
%                                 the date specifies the beginning of
%                                 the in sample period, market data before that date
%                                 is ignored by runts.
%                                 DEFAULT: 0 (no sample begin)
% settings.sampleend     INTEGER  Date in the format YYYYMMDD
%                                 the date specifies the end of the in in sample
%                                 market data before that date is ignored by runts.
%                                 DEFAULT: inf (no sample end)
% settings.lookback      INTEGER  specifies the size of the lookback window, i.e.
%                                 the amount of data given to the trading
%                                 system in each call. Limiting the
%                                 lookback to the absolute necessary
%                                 usually reduces the runtime.
%                                 DEFAULT: 504 - roughly two years of daily
%                                 market data
% settings.budget        DOUBLE   Starting capital in USD for the backtest.
%                                 DEFAULT: 1,000,000.00
% settings.slippage      DOUBLE   Multiplier of the daily range (HIGH-LOW)
%                                 that is used to simulate the impact of
%                                 transaction costs.
%                                 DEFAULT: 0.05
%
% RETURNS (master TS evaluation)
% settings.participation          Ignored by open source version of runts
% settings.rollbug                Ignored by open source version of runts
% settings.incentivefee           Ignored by open source version of runts
% settings.managementfee          Ignored by open source version of runts
% settings.generateorders         Ignored by open source version of runts
% settings.discrete               Ignored by open source version of runts
%
% Copyright Quantiacs LLC - March 2015

if ~exist('tsN', 'var')
    disp('getSettings: Please specify a Tradingsystem file.');
    return;
end

if numel(tsN) > 1
    if ~strcmp(tsN(end-1:end), '.m')
        tsN = [tsN '.m'];
    end
else
    disp('getSettings: Invalid TS name.');
    return;
end

if exist(tsN, 'file') ~= 2
    disp(['getSettings: Tradingsystem ' tsN ' not found.']);
    return;
end

% Look for Settings in TS file

text = fileread(tsN);

% Scan Function Arguments
lineBreaks = regexp(text,'\n');
lineStarts = [1 lineBreaks(1:end-1)];
for j=numel(lineBreaks)
    thisLine = text(lineStarts:lineBreaks-1);
    
    comment = regexp(thisLine, '%');
    fun     = regexp(thisLine, 'function');
    equ     = regexp(thisLine, '=');
    braket1 = regexp(thisLine, '\(');
    braket2 = regexp(thisLine, '\)');
    
    if ~any(comment); comment = inf; end
    if ~any(fun);     fun = 0;       end
    if ~any(equ);     equ = 0;       end
    if ~any(braket1); braket1 = 0;   end
    if ~any(braket2); braket2 = 0;   end
    
    if fun(1) < comment && equ(1) < comment  && braket1(1) < comment && ...
            braket2(1) < comment && fun && braket1 && braket2 && equ
        
        [sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(thisLine, '\((.*?)\)');
        if ~isempty(matchStr)
            matchStr = matchStr{1};
            matchStr = matchStr(2:end-1);
            argumentList = regexp(matchStr,'(.[^,]*)', 'tokens');
            for k = 1:numel(argumentList)
                newArgument = argumentList{k};
                newArgument = regexprep(regexprep(newArgument, ',', ''), ' ','');
                settings.arguments{k} = (newArgument{1});
            end
        else
            disp('getSettings: Error parsing function arguments.');
        end
    end
end

% Pre-set the fields to default values
settings.markets = {};
settings.lookback = 504;
settings.budget = 1000000;
settings.slippage = 0.05;
settings.participation = 0.1;
settings.rollbug = 0;
settings.incentivefee = 0;
settings.managementfee = 0;
settings.generateorders = 0;
settings.discrete = 0;
settings.samplebegin = 0;
settings.sampleend = inf;

% Set each field in settings
fields = fieldnames(settings);
for ii = 1:length(fields)
    setSettingsField(fields{ii})
end

% A nested function in getSettings()
% Parse the file to find settings for corresponding fieldName.
% If a field is not set in the file (or commented out), a default value is used.
    function setSettingsField(fieldName)
        % exp_pre - regex before equal sign. e.g, settings.lookback
        % exp_post - regex after (included) eqaul sign. e.g., = 504
        exp_pre = '\s*%*\s*settings.';
        if strcmp(fieldName, 'markets')
            exp_post = '\s*=\s*{(.*?)}';
        else
            % since all the non-markets fields are set set to number, we
            % can use the same regex expression
            exp_post = '\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
        end
        % build regex expression
        parLine = strcat(exp_pre, fieldName, exp_post);
        [sIndex, ~, ~, matchStrs, ~, ~, ~] = regexp(text, parLine);
        
        if any(sIndex)
            for i = 1:(numel(matchStrs))
                matchStr = matchStrs{i};
                if strContains(matchStr, '%')
                    % skip if current line is a comment
                    continue
                end
                if strcmp(fieldName, 'markets')
                    % set markets list
                    marketList = regexp(matchStr, '''(.[^'']*)''', 'tokens');
                    settings.markets = {}; % reset markets list
                    for m = 1:size(marketList,2)
                        newMarket = marketList{m};
                        settings.markets{m} = newMarket{1};
                    end
                else
                    % set the other fields
                    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
                    settings.(fieldName) = str2double(matchStr{1});
                end
            end
        end
    end
end

% Helper function
% Return a boolean indicates whether str contains pattern
function [bool_contains] = strContains(str, pattern)
index = strfind(str, pattern);
bool_contains = any(index);
end
