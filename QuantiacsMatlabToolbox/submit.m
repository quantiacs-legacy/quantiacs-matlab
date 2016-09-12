function [success] = submit(filename, TSName)
success = false;
if ~exist('filename', 'var')
     disp('Please specify a file for uploading!');
    return;
end

if numel(filename) >= 2
    if ~strcmp(filename(end-1:end),'.m')
        filename = [filename '.m'];
    end
end

if ~exist(filename, 'file')
     disp(['File ' filename ' not found!']);
    return;
end

if ~exist('TSName', 'var')
    TSName = filename(1:end-2);
end

try
    txt = fileread(filename);
catch
    disp(['Could not read ' filename '.']);
    return;
end
version = '2.2';

try
    guid = urlread('https://www.quantiacs.com/quantnetsite/UploadTradingSystem.aspx','post',{'fileName',filename(1:end-2),'name', TSName, 'data', txt, 'version', version});
    web(['https://www.quantiacs.com/quantnetsite/UploadSuccess.aspx?guid=' guid], '-browser');
catch
    disp(['Submission of ' filename ' failed. Please check your Internet connection and the current availability of www.quantiacs.com.']);
    return;
end
success = true;
disp('Submission successful.');
end