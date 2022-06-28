function [groupedData] = groupRecordings(compiledData,groupedData,filterValue,newGroup,varList)
% This script selects recordings with filters specified by user and
% save the group of selected recordings in a file specified by user.
% This script can be used to select recordings for analysis later.
% Required files:
%   compiledData.mat in current folder
%
% History:
%   Oct 6, 2021. Man Ho Wong



%% Read filter values assigned by user

% Specify filter values below to select recordings.
% Input argument 'filterValue' is a struct with each field name after each
% of the following factors (e.g. condition, sex, etc.). Each field contains
% the filter value of the corresponding factor. Note: minAge and maxAge is
% numerical.

RESEARCHER = filterValue.researcher;
CONDITION = filterValue.condition;
FACILITY = filterValue.facility;
SEX = filterValue.sex;
MINAGE = filterValue.minAge;      % Minimum age
MAXAGE = filterValue.maxAge;      % Maximum age
CELLTYPE = filterValue.cellType;
GENOTYPE = filterValue.genotype;
TREATMENT = filterValue.treatment;

filterValue.include = 1;          % 1 or 0. To exclude recordings, enter 0
INCLUDE = filterValue.include;    % in the 'include' field in compiledData.
                                  % Default is 1.


%% To avoid overwriting groups defined previously

if ismember(newGroup,groupedData.Properties.RowNames) == true
    quest = "'"+ newGroup + "' already exists! Do you want to overwrite it?";
    response = questdlg(quest,'Oops','Yes','No','No');
    switch response
        case {'No',''}
            fprintf('No change is made!\n');
            return
    end
end



%% To get all existing filtering options/ variable categories.

allResearchers = categories(compiledData.researcher);
allConditions = categories(compiledData.condition);
allFacilities = categories(compiledData.facility);
allSexes = categories(compiledData.sex);
allCellTypes = categories(compiledData.cellType);
allGenotypes = categories(compiledData.genotype);
allTreatments = categories(compiledData.treatment);



%% To ensure all values entered by the user exist.
% If one or more value(s) do not exist, or user entered 'all',
% all existing values of the respective variable will be included.

if any(ismember(RESEARCHER,allResearchers)==false)
    disp('Undefined researcher(s) - All researchers are included!')
    RESEARCHER = allResearchers;
end

if any(ismember(CONDITION,allConditions)==false)
    disp('Undefined condition(s) - All conditions are included!')
    CONDITION = allConditions;
end

if any(ismember(FACILITY,allFacilities)==false)
    disp('Undefined facility(s) - All facilities are included!')
    FACILITY = allFacilities;
end

if any(ismember(SEX,allSexes)==false)
    disp('Undefined sex(s) - All sexes are included!')
    SEX = allSexes;
end

if any(ismember(CELLTYPE,allCellTypes)==false)
    disp('Undefined cell type(s) - All cell types are included!')
    CELLTYPE = allCellTypes;
end

if any(ismember(GENOTYPE,allGenotypes)==false)
    disp('Undefined genotype(s) - All genotypes are included!')
    GENOTYPE = allGenotypes;
end

if any(ismember(TREATMENT,allTreatments)==false)
    disp('Undefined treatment(s) - All treatments are included!')
    TREATMENT = allTreatments;
end
fprintf('\n');


%% A filter is set with the values specified by the user.

filter = ismember(compiledData.researcher,RESEARCHER) &...
    ismember(compiledData.condition,CONDITION) &...
    ismember(compiledData.facility,FACILITY) &...
    ismember(compiledData.sex,SEX) &...
    compiledData.age >= MINAGE & compiledData.age <= MAXAGE &...
    ismember(compiledData.cellType,CELLTYPE) &...
    ismember(compiledData.genotype,GENOTYPE) &...
    ismember(compiledData.treatment,TREATMENT) &...
    compiledData.include == INCLUDE;



%% Store grouping info in groupedData.

warning('off','MATLAB:table:RowsAddedExistingVars');
groupedData.researcher{newGroup} = RESEARCHER;
groupedData.condition{newGroup} = CONDITION;
groupedData.facility{newGroup} = FACILITY;
groupedData.sex{newGroup} = SEX;
groupedData.minAge{newGroup} = MINAGE;
groupedData.maxAge{newGroup} = MAXAGE;
groupedData.cellType{newGroup} = CELLTYPE;
groupedData.genotype{newGroup} = GENOTYPE;
groupedData.treatment{newGroup} = TREATMENT;



%% Select recordings and copy events/ data points and other info into groupedData.

fprintf('Grouping recordings. Please wait...');

% Select recordings with the filter
filteredData = compiledData(filter,:);

% copy each recording in the group to groupedData, excluding dataPoints
column = string(compiledData.Properties.VariableNames);
column = column(column ~= 'dataPoints');    % remove dataPoints column
groupedData.events{newGroup} = filteredData(:,column);

% copy all info about the recordings to temporary table, level3.
column = column(column ~= 'events');   % remove events column
level3 = filteredData(:,column);

level2 = table;     % a temporary table for transfering data
nRecording = height(filteredData);
nVar = length(varList);

% copy data points from filteredData
statList = compiledData.dataPoints{1}.Properties.RowNames;
nStatistic = length(statList);
for iStatistic = 1:nStatistic
    fprintf('..');
    currStatistic = statList(iStatistic);
    for iVar = 1:nVar
        currVar = varList{iVar};
        for iRecording = 1:nRecording
            level3.ageGroup(iRecording,1) = categorical("P" + ... % add age group column
                num2str(MINAGE) + "-" + num2str(MAXAGE));
            level3.dataPoints(iRecording,1) = ...
                filteredData.dataPoints{iRecording}.(currVar)(currStatistic);
        end
        level2.(currVar){currStatistic} = level3;
    end
end
groupedData.dataPoints{newGroup} = level2;


% % concatenate all events of the same groups
% 
%     level2 = table;
%     for iRecording = 1:nRecording
%         level2 = [level2;filteredData.events{iRecording}(:,2:end)];
%     end
% groupedData.pooledEvents{newGroup} = level2;

fprintf('Done!\n''%s'' was added to ''groupedData'' in Workspace.\n', newGroup);
fprintf('\n********* Reminder *********\n- If you have computed new data points, you will need to\ngroup the data again to include those points.\n');
fprintf('- Remember to save groupedData in the next step before you close MATLAB.\n');
end