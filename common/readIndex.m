function [index] = readIndex(indexDir)
%% Read index.xlsx

indexFile = 'groupIndex.xlsx';
indexPath = [indexDir indexFile];
index = readtable(indexPath);

% Set variable type to categorical
index.researcher = categorical(index.researcher);
index.mouseID = categorical(index.mouseID);
index.condition = categorical(index.condition);
index.facility = categorical(index.facility);
index.sex = categorical(index.sex);
index.cellType = categorical(index.cellType);
index.genotype = categorical(index.genotype);
index.treatment = categorical(index.treatment);

end