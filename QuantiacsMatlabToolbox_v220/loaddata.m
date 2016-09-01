function out = loaddata(settings, refresh)
%LOADDATA loads market data 
% loaddata is called from runts. It downloads and reads the market data 
% specified in argument settings.markets and returns the mandatory data 
% collection 
%
% DATE, OPEN, HIGH, LOW, CLOSE, VOL, OI, P, R, RINFO 
%
% and other data fields evenutally listed in settings.arguments. 
% The timeline of the data is standardized and trimmed to DATEs between
% settings.samplebegin and settings.sampleend.
% Missing data is interpolated with the last known value.
%
% USAGE:
%
% data = loaddata(settings) loads the market data specified in 
% settings.markets and returns a struct out with the mandatory data
% and user defined variables in settings.arguments
%
% ARGUMENTS:
%
% settings             required  STRUCT
% settings.markets     required  defines the markets to be loaded
% settings.arguments   required  defines the market data to be loaded 
% settings.samplebegin required  defines the begin of the in sample period
% settings.sampleend   required  defines the end of the in sample period
%
% refresh              optional  BOOLEAN Force download of market data
%                      default   FALSE
%
% RETURNS:
%
% out                 STRUCT     Collection of standardized, filled and
%                                trimmed market data
%
% Copyright Quantiacs LLC - March 2015


fNames = fieldnames(settings);

if any(strcmp(fNames, 'markets'))
    marketlist = settings.markets;
else
    disp('No marketlist found. Please define settings.markets first.');
    return;
end

if any(strcmp(fNames, 'arguments'))
    argumentlist = settings.arguments;
else
    disp('No arguments found. Please define the tradingsystems arguments prior to loading data.');
    return;
end

if isempty(marketlist)
    disp('Marketlist is empty. Please define settings.markets first.');
    return;
end

backtestlist = {'DATE', 'OPEN', 'HIGH', 'LOW', 'CLOSE', 'VOL', 'OI', 'P', 'R', 'RINFO'};

if ~exist('argumentlist', 'var') || isempty(argumentlist)
    argumentlist = backtestlist;
else
    argumentlist = ([backtestlist, argumentlist(~ismember(argumentlist,backtestlist)) ]);
end

if ~exist('refresh', 'var') || isempty(refresh)
    refresh = false;
end

% Argument list: Mandatory fields and escapes
delIx = strcmp(argumentlist, 'settings') | strcmp(argumentlist, 'exposure') | strcmp(argumentlist, 'equity');
argumentlist = argumentlist(~delIx);

nMarkets = size(marketlist,2);

% check data / refresh
err = true(1, nMarkets);
for j = 1:nMarkets
    if ~exist(fullfile('data', [(marketlist{j}) '.txt']), 'file') || refresh
        [~, err(j)] = urlwrite(['http://www.quantiacs.com/data/' (marketlist{j}) '.txt'], fullfile('data', [(marketlist{j}) '.txt']));
        disp(['Downloading ' (marketlist{j})]);
    end
end

if any(~err)
    marketlist(2,:) = repmat({' '}, 1, nMarkets);
    disp(['Unable to download: ' (marketlist{~repmat(err,2,1)})]);
    marketlist = marketlist(1,err);
end

% load markets
nMarkets = size(marketlist,2);

out.DATE = str2num(datestr(datenum(1900, 01, 01):datenum(date), 'yyyymmdd'));

out.DATE = out.DATE(out.DATE >= settings.samplebegin);
out.DATE = out.DATE(out.DATE <= settings.sampleend);

for j = 1:numel(argumentlist)
    if ~strcmp((argumentlist{j}), 'DATE')
        out.(argumentlist{j}) = nan(numel(out.DATE), nMarkets);
    end
end

fieldNameslist = ['DATE'];
for j = 1:nMarkets
    fid = fopen(fullfile('data', [(marketlist{j}) '.txt']));
    fieldNames = textscan(fgetl(fid),'%s', 'delimiter', ',');
    fieldNames = fieldNames{1}';
    fieldNameslist = unique([fieldNameslist, fieldNames]);
    
    disp(['Loading ' (marketlist{j})]);
    
    style = repmat(' %f', 1, size(fieldNames,2));
    data = textscan(fid, style, 'delimiter', ',');
    
    fclose(fid);
    
    ixNew  = ismember(out.DATE, data{1});
    ixGrab = ismember(data{1}, out.DATE);
    
    if any(ixNew)
        for k = 2:numel(argumentlist)
            kx = strcmp(argumentlist{k}, fieldNames);
            if any(kx)
                out.(argumentlist{k})(ixNew,j) = data{kx}(ixGrab);
            end
        end
    end
end

% Candidates for global data and fieldname typos
ixLookup = ~(ismember(argumentlist, backtestlist) | ismember(argumentlist, fieldNameslist));

if any(ixLookup)
    lookuplist = argumentlist(ixLookup);
    for j = 1:numel(lookuplist)
        
        if ~exist(fullfile('data', [(lookuplist{j}) '.txt']), 'file') || refresh
            disp(['Downloading ' (lookuplist{j})]);
            [~, err(j)] = urlwrite(['http://www.quantiacs.com/data/' (lookuplist{j}) '.txt'], fullfile('data', [(lookuplist{j}) '.txt']));
        end
        
        if any(~err)
            disp(['Could not find ' (lookuplist{j})]);
        else
            out.(lookuplist{j}) = nan(numel(out.DATE), 1);
            
            fid = fopen(fullfile('data', [(lookuplist{j}) '.txt']));
            
            % Skip first line
            textscan(fgetl(fid),'%s', 'delimiter', ',');
            
            style = repmat(' %f', 1, size(fieldNames,2));
            data = textscan(fid, style, 'delimiter', ',');
            
            fclose(fid);
            
            ixNew  = ismember(out.DATE, data{1});
            ixGrab = ismember(data{1}, out.DATE);
    
            if any(ixNew)
                out.(lookuplist{j})(ixNew) = data{2}(ixGrab);
            end
        end
    end
end


ixDel = true(numel(out.DATE), nMarkets);

for k = 2:numel(argumentlist)
    jx = isnan(out.(argumentlist{k}));
    if size(jx,2) == 1
        jx = repmat(jx,1,nMarkets);
    end
    ixDel = ixDel & jx;
end

ixKeep = ~(min(ixDel,[],2));
out.DATE   = out.DATE(ixKeep);

nRows  = numel(out.DATE);

for k = 2:numel(argumentlist)
    nCols = size(out.(argumentlist{k}),2);
    ixK   = repmat(ixKeep,1,nCols);
    out.(argumentlist{k}) = reshape(out.(argumentlist{k})(ixK),nRows,nCols);
end

out.CLOSE = fillnans(out.CLOSE);
[out.OPEN, out.HIGH, out.LOW] = deal(fillwith(out.OPEN,out.CLOSE), fillwith(out.HIGH,out.CLOSE), fillwith(out.LOW,out.CLOSE));

out.VOL(isnan(out.VOL)) = 0;
out.OI(isnan(out.OI)) = 0;
out.R(isnan(out.R)) = 0;
out.RINFO(isnan(out.RINFO)) = 0;
out.P(isnan(out.P)) = 0;

for k = 2:numel(argumentlist)
    out.(argumentlist{k}) = fillnans(out.(argumentlist{k}));
end

end
