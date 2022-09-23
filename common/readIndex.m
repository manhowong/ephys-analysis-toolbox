function fileIndex = readIndex(idxPath)
%% Read index from excel file and convert some variables to categorical.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - idxPath : path of the file with info of each recording
% Output: - fileIndex : A table containing info imported from idxPath

%%
fileIndex = readtable(idxPath);

%% Convert variable type to categorical

% Variables to be converted to categorical
catVars = {'researcher','mouseID','condition','facility', ...
           'sex','cellType','genotype','treatment'};

% Convert
for k = 1:length(catVars)
    fileIndex.(catVars{k}) = categorical(fileIndex.(catVars{k}));
end