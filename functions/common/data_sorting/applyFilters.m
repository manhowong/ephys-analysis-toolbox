function groupData = applyFilters(targetData,groupIndex,fileIndex,groupName)
%% Filter data in sortedData by grouping factors defined in groupIndex.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - targetData : data to be filtered;
%                        must have file names as row names,
%                        or file names stored in a column named 'fileName'
%         - groupIndex : A table containing grouping info;
%                        can be generated with addGroup.m
%         - groupName : Name of the group (in groupIndex) to be filtered
% Output: - groupData : Data filtered by grouping factors in groupIndex.

%% Check if groupName is correct

if ~ismember(groupName, groupIndex.Properties.RowNames)
    fprintf('The group ''%s'' does not exist.\n', groupName)
    groupData = [];
    return
end

%% Create a merged filter from the combination of grouping factors and 
%  apply the filter to sortedData

factors = groupIndex.Properties.VariableNames;
factors = factors(~ismember(factors,{'minAge', 'maxAge'}));


% Get a filter from the combination of all factors beside age
resultFilter = ones([height(fileIndex),1]);
nFactors = length(factors);
for k=1:nFactors
    resultFilter = resultFilter & ismember(fileIndex.(factors{k}), ...
                                           groupIndex.(factors{k}){groupName});
end

% Add 'age' and 'include' to 'resultFilter'
resultFilter = resultFilter & ...
               fileIndex.age >= groupIndex.minAge{groupName} & ...
               fileIndex.age <= groupIndex.maxAge{groupName} & ...
               fileIndex.include==1;

% Apply merged filter to fileIndex and get a list of file names
fileNames = fileIndex(resultFilter,:).fileName;

%% Select data by file names

if ismember('fileName', targetData.Properties.VariableNames)
    % if targetData has file names stored in a column named 'fileName'
    groupData = targetData(ismember(targetData.fileName, fileNames),:);
else
    % if targetData has file names as row names
    groupData = targetData(fileNames,:);
end
