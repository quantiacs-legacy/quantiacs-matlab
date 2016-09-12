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

if exist(tsN, 'file') ~= 2;
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
    
    if ~any(comment); comment = inf; end;
    if ~any(fun);     fun = 0;       end;
    if ~any(equ);     equ = 0;       end;
    if ~any(braket1); braket1 = 0;   end;
    if ~any(braket2); braket2 = 0;   end;
    
    if fun(1) < comment && equ(1) < comment  && braket1(1) < comment && braket2(1) < comment && fun && braket1 && braket2 && equ
        
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

parLine = 'settings.markets\s*=\s*';
[sIndex, ~, ~, matchStr, ~, ~, splitStr] = regexp(text, parLine);

if any(sIndex)
    sIndex   = sIndex(1);
    splitStr = splitStr{2};
    [sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(splitStr, '{(.*?)}');
    if ~isempty(matchStr)
        matchStr = matchStr{1};
        matchStr = matchStr(2:end-1);
        marketList = regexp(matchStr, '''(.[^'']*)''','tokens');
        for k = 1:size(marketList,2)
            newMarket = marketList{k};
            settings.markets{k} = newMarket{1};
        end
    else
        disp('getSettings: Error parsing market settings.');
    end
else
    settings.markets   = {};
end

parLine = 'settings.lookback\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.lookback = str2double(matchStr{1});
else
    % Default lookback
    settings.lookback = 504;
end

parLine = 'settings.budget\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.budget = str2double(matchStr{1});
else
    % Default budget
    settings.budget = 1000000;
end

parLine = 'settings.slippage\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.slippage = str2double(matchStr{1});
else
    % Default slippage
    settings.slippage = 0.05;
end

parLine = 'settings.participation\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.participation = str2double(matchStr{1});
else
    % Default participation
    settings.participation = 0.1;
end


parLine = 'settings.rollbug\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.rollbug = str2double(matchStr{1});
else
    % Default lookback
    settings.rollbug = 0;
end


parLine = 'settings.incentivefee\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.incentivefee = str2double(matchStr{1});
else
    % Default lookback
    settings.incentivefee = 0;
end

parLine = 'settings.managementfee\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.managementfee = str2double(matchStr{1});
else
    % Default lookback
    settings.managementfee = 0;
end


parLine = 'settings.generateorders\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.generateorders = str2double(matchStr{1});
else
    % Default lookback
    settings.generateorders = 0;
end


parLine = 'settings.discrete\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.discrete = str2double(matchStr{1});
else
    settings.discrete = 0;
end


parLine = 'settings.samplebegin\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.samplebegin = str2double(matchStr{1});
else
    settings.samplebegin = 0;
end

parLine = 'settings.sampleend\s*=\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
[sIndex, ~, ~, matchStr, ~, ~, ~] = regexp(text, parLine);

if any(sIndex)
    matchStr = matchStr{1};
    [~, ~, ~, matchStr, ~, ~, ~] = regexp(matchStr, '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    settings.sampleend = str2double(matchStr{1});
else
    settings.sampleend = inf;
end

end