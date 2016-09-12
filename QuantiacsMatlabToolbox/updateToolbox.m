function [updateAvailable msg] = updateToolbox(doUpdate)
if ~exist('doUpdate', 'var'); doUpdate = true; end

updateAvailable = false;
msg = '';

try
    str = urlread('http://www.quantiacs.com/data/MatlabToolboxVersion.txt');
catch
    return;
end

if ~isempty(str)
    str = regexprep(str, '\r', '');
    lines = [regexp(str, '\n') numel(str)+1];
    updateList    = {};
    versionCheck  = str(1:lines(1)-1);
    versionCheck  = regexprep(versionCheck, 'Version:', '');
    versionCheck  = regexprep(versionCheck, 'version:','');
    versionNumber = str2num(versionCheck);

    if numel(lines) > 1
        messageCheck  = str(lines(1)+1:lines(2)-1);
        if any(regexp(messageCheck, 'Message:'))
            msg = regexprep(messageCheck, 'Message:', '');
        end
    end

    if exist('MatlabToolboxVersion.txt', 'file') == 2
        localStr  = fileread('MatlabToolboxVersion.txt');
        linesLocal = [regexp(localStr, '\n') numel(localStr)+1];
        localVersionCheck   = localStr(1:linesLocal(1)-1);
        localVersionCheck   = regexprep(localVersionCheck, 'Version:', '');
        localVersionCheck   = regexprep(localVersionCheck, 'version:','');
        localVersionNumber  = str2num(localVersionCheck);
        if localVersionNumber < versionNumber
            updateAvailable = true;
        end
    else
        updateAvailable = true;
    end
    
    if ~doUpdate
        return;
    end
    
    if numel(lines) > 1
        for k = 2:numel(lines)
            s = str(lines(k-1)+1:lines(k)-1);
            if ~any(regexp(s, 'Message:'));
                updateList{end+1} = s;
            end
        end
    end
    err = false(numel(updateList));
    if ~isempty(updateList)
        for k = 1:numel(updateList)
            disp(['Updating ' updateList{k}]);
            [~, err(k)] = urlwrite(['http://www.quantiacs.com/data/' updateList{k}], [updateList{k}]);
        end
    end
    if any(err)
        for k = 1:numel(err)
            if err(k)
                disp(['ERROR updating ' updateList{k}]);
            end
        end
    else
        if updateAvailable
            urlwrite('http://www.quantiacs.com/data/MatlabToolboxVersion.txt', 'MatlabToolboxVersion.txt');
            disp(['Update of Matlab Toolbox to version ' num2str(versionNumber) ' successful.']);
        else
            disp(['No Update available, version ' num2str(versionNumber) ' is current.']);
        end
    end
end

end