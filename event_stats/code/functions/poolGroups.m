function [groupedData] = poolGroups(groupedData,inputGroups,pooledGroup)
%Pool experimental groups together.
%   This script pools selected groups together by concatenating the
%   recordings of these groups and creates a new group. The group info
%   of the pooled group contains summary info of the selected groups,
%   e.g. minAge of the pooled group is the lowest minAge among the
%   selected groups. The pooled group is then added to 'groupedData' in
%   Workspace. 

%% Set up variables

% A new row needs to be created before adding combined group data to the table
groupedData.events{pooledGroup} = table;

% Set initial values for comparing age
groupedData.minAge{pooledGroup} = groupedData.minAge{inputGroups{1}};
groupedData.maxAge{pooledGroup} = groupedData.maxAge{inputGroups{1}};

% for groupping data points
statList = groupedData.dataPoints{inputGroups{1}}.Properties.RowNames;
varList = groupedData.dataPoints{inputGroups{1}}.Properties.VariableNames;
nStat = length(statList);
nVar = length(varList);
% Create a temporary table to hold the concatinated data:
level2 = cell2table(cell(nStat,nVar));
level2.Properties.RowNames = statList;
level2.Properties.VariableNames = varList;

%% Combine selected groups

fprintf('Combining groups. Please wait...');

nGroup = length(inputGroups);
for iGroup = 1:nGroup
    currGroup = inputGroups{iGroup};
    groupedData.researcher{pooledGroup} = [groupedData.researcher{pooledGroup};groupedData.researcher{currGroup}];
    groupedData.condition{pooledGroup} = [groupedData.condition{pooledGroup};groupedData.condition{currGroup}];
    groupedData.facility{pooledGroup} = [groupedData.facility{pooledGroup};groupedData.facility{currGroup}];
    groupedData.sex{pooledGroup} = [groupedData.sex{pooledGroup};groupedData.sex{currGroup}];
    groupedData.cellType{pooledGroup} = [groupedData.cellType{pooledGroup};groupedData.cellType{currGroup}];
    groupedData.genotype{pooledGroup} = [groupedData.genotype{pooledGroup};groupedData.genotype{currGroup}];
    groupedData.treatment{pooledGroup} = [groupedData.treatment{pooledGroup};groupedData.treatment{currGroup}];
    % minAge and maxAge of the pooled group are the
    % lowest and the highest values of all the groups!    
    groupedData.minAge{pooledGroup} = min([groupedData.minAge{pooledGroup},groupedData.minAge{currGroup}]);
    groupedData.maxAge{pooledGroup} = max([groupedData.maxAge{pooledGroup},groupedData.maxAge{currGroup}]);
    groupedData.events{pooledGroup} = [groupedData.events{pooledGroup};groupedData.events{currGroup}];

    % group data points by animals
    for iVar = 1:nVar
        currVar = varList{iVar};
        for iStat = 1:nStat
            currStat = statList{iStat};
            level2.(currVar){currStat} = ...
                [level2.(currVar){currStat};groupedData.dataPoints{currGroup}.(currVar){currStat}];
        end
    end
end
groupedData.dataPoints{pooledGroup} = level2;

%% To remove repeated items

%   e.g. After combining two ctrl groups, you will have two entries of 'ctrl'
%   in the field 'condition'. To remove the extra entry, use the function
%   'unique' to include only unique entries.

groupedData.researcher{pooledGroup}=unique(groupedData.researcher{pooledGroup});
groupedData.condition{pooledGroup}=unique(groupedData.condition{pooledGroup});
groupedData.facility{pooledGroup}=unique(groupedData.facility{pooledGroup});
groupedData.sex{pooledGroup}=unique(groupedData.sex{pooledGroup});
groupedData.cellType{pooledGroup}=unique(groupedData.cellType{pooledGroup});
groupedData.genotype{pooledGroup}=unique(groupedData.genotype{pooledGroup});
groupedData.treatment{pooledGroup}=unique(groupedData.treatment{pooledGroup});

%% Reminders
fprintf('Done!\n''%s'' was added to ''groupedData'' in Workspace.\n', pooledGroup);
fprintf('\n*********\nRemember to save groupedData before you close MATLAB.\n');
end