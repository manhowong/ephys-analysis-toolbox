function [compiledData] = importRecordings(docPath,resultDir)
% organize mini data for further analysis
% sort events by time
% calculate iei of each event
% save compiled data as compiledData.mat
% 6 Oct, 2021. Man Ho Wong

% Input
%   docPath: Path of the file which contains the info about the event files
%            may include path
% Output
%   compiledData



%% Create a table called compiledData, from recordingInfo.xlsx

compiledData = readtable(docPath);
compiledData.events{1} = [];   % add a column "events" for storing event data

% Set variable type to categorical
compiledData.researcher = categorical(compiledData.researcher);
compiledData.mouseID = categorical(compiledData.mouseID);
compiledData.condition = categorical(compiledData.condition);
compiledData.facility = categorical(compiledData.facility);
compiledData.sex = categorical(compiledData.sex);
compiledData.cellType = categorical(compiledData.cellType);
compiledData.genotype = categorical(compiledData.genotype);
compiledData.treatment = categorical(compiledData.treatment);



%% Copy data in event files to compiledData

fprintf('Compiling data. Please wait...\n')
nRecording = height(compiledData);
for i = 1:nRecording
    if compiledData.include(i) == 1
        compiledData.events{i} = readtable(compiledData.fileName{i},'ReadVariableNames',true);
        warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
        compiledData.events{i} = sortrows(compiledData.events{i},'Time_ms_','ascend');
        compiledData.events{i}.iei(1) = compiledData.events{i}.Time_ms_(1);
        compiledData.events{i}.iei(2:end) = diff(compiledData.events{i}.Time_ms_);
        compiledData.events{i}(1,:) = [];
    end
end


%% Save
fprintf('Saving data. Please wait...\n')
save(resultDir + '/compiledData.mat','compiledData');
fprintf('Done! Compiled data was saved as \n''compiledData.mat'' in the your result directory.\n');

end