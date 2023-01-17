function fileIndex = readIndex(idxPath)
%% Read index from excel file and convert some variables to categorical.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - idxPath : path of the file with info of each recording
% Output: - fileIndex : A table containing info imported from idxPath

%% Read
fileIndex = readtable(idxPath);

%% Convert variable type to categorical
% (except fileName, datetime and numeric variables)

varNames = fileIndex.Properties.VariableNames;
for k = 1:length(varNames)
    if (varNames{k} ~= "fileName") && ...
        ~ismember(class( fileIndex.(varNames{k}) ), {'datetime' 'double'})
        fileIndex.(varNames{k}) = categorical(fileIndex.(varNames{k}));
    end
end
