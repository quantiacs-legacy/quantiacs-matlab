function [resultField] = optimize(tsN, plotEquity, reloadData)
if ~exist('tsN', 'var') 
    disp('Please specify a Tradingsystem you want to run.');
    return;
end
if exist(tsN, 'file') ~= 2; 
    disp(['Tradingsystem ' tsN ' not found.']);
    return;
else
    if numel(tsN) > 1
       if ~strcmp(tsN(end-1:end), '.m')
            tsN = [tsN '.m'];           
       end
    else
       tsN = [tsN '.m'];           
    end 
end

if ~exist('plotEquity', 'var')
    plotEquity = false;
end
if ~exist('reloadData', 'var') 
    reloadData = false;
end 

% Look for Optimizer Variables in TS file
parLine = '[^(\n)]*?#\[[\s\S]*?\]#';
text = fileread(tsN);
[sIndex, ~, ~, matchStr, ~, ~, splitStr] = regexp(text, parLine);
instances = 1;
v = [];
if any(sIndex) 
    for k= 1:numel(sIndex)
        [~, ~, ~, vRange,~, ~, ~] = regexp(matchStr{k}, '#\[[\s\S]*?\]#');
        [~, ~, ~, ~,~, ~, vStr] = regexp(matchStr{k}, '=');
        v.(strtrim(vStr{1})) = str2num(vRange{1}(3:end-2)); 
        instances = instances * size(v.(strtrim(vStr{1})),2);
    end
else
    disp('Unable to identify optimizing parameters. Please use #[values]# as a comment directly after the assingment of the variable.')
    return;
end

namePars = fieldnames(v); 
numPars  = numel(namePars);

disp(' ');
disp(['Counting ' num2str(numPars) ' parameters and ' num2str(instances) ' instances.']);
disp(' ');
disp(v);
disp(' ');

numSearch = '=[\s\S]*?(;|%)';
parLookup = v.(namePars{1});
parLookup = parLookup(:);
if numPars > 1
    for j = 2:numPars
       newPar = v.(namePars{j});
       newPar = newPar(:);
       parLookup = [repmat(parLookup,size(newPar,1),1) sort(repmat(newPar,size(parLookup,1),1))];
    end 
end

timePassed  = 0;
resultField = [];
for j = 1:instances
    tic;
    textOut = '';
    for k = 1:numPars;
       [~,~, ~, mStr, ~, ~, sStr] = regexp(matchStr{k}, numSearch);
       mStr = char(mStr);
       newParLine = char([sStr{1} ' = ' num2str(parLookup(j,k)) mStr(end) sStr{2}]);
       textOut = [textOut splitStr{k} newParLine]; 
    end
    textOut = [textOut splitStr{end}];
    textOut = regexprep(textOut, '%', '%%');
    textOut = regexprep(textOut, tsN(1:end-2), char(['optimizeTS' num2str(j)]));
    fid = fopen(char(['optimizeTS' num2str(j) '.m']), 'w');
    fprintf(fid, textOut);
    fclose(fid); 

    ret = runts(char(['optimizeTS' num2str(j)]), plotEquity, reloadData);  
    delete(char(['optimizeTS' num2str(j) '.m']));

    resultField.instNum(j) = j;
    for k = 1:numPars;
        resultField.(namePars{k})(j) = parLookup(j,k); 
    end
    fNames = fieldnames(ret.stats);
    for k = 1:numel(fNames)    
        resultField.(fNames{k})(j) = ret.stats.(fNames{k});
    end
    timePassed = timePassed + toc;
    timeEstimator = timePassed / j * (instances-j);
    h = floor(timeEstimator / 3600);
    m = floor((timeEstimator - h * 3600) / 60);
    s = floor((timeEstimator - h * 3600 - m * 60));
    
    disp([num2str(j) '/' num2str(instances) ' instances processed. Estimated time left (hh:mm:ss): ' num2str(h,'%02.0f') ':' num2str(m,'%02.0f'), ':'  num2str(s,'%02.0f')]); 
end

end