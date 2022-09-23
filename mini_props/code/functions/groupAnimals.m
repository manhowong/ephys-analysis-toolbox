function [groupedData_animals] = groupAnimals(groupedData)
% Group recordings by animals. Input data is groupedData (see
% analyzeMini.mlx).
% Output: groupedData_animals

%%

fprintf('Grouping recordings by animals...');
% copy everything from groupedData except last two columns i.e. events and dataPoints
groupedData_animals = groupedData(:,1:width(groupedData)-2);

%%

nGroup = height(groupedData);
for iGroup = 1:nGroup
    fprintf('.');
    animalList = unique(groupedData.events{iGroup}.mouseID);
    level2 = table;
    level2.mouseID = animalList;
    nAnimal = length(animalList);
    for iAnimal = 1:nAnimal
        filter = groupedData.events{iGroup}.mouseID==categorical(animalList(iAnimal));
        % group event data by animals
        level2.events{iAnimal} = groupedData.events{iGroup}(filter,:);
        % group data points by animals
        statList = groupedData.dataPoints{iGroup}.Properties.RowNames;
        varList = groupedData.dataPoints{iGroup}.Properties.VariableNames;
        nStat = length(statList);
        nVar = length(varList);
        level3 = table;
        for iVar = 1:nVar
            currVar = varList{iVar};
            for iStat = 1:nStat
                currStat = statList{iStat};
                level3.(currVar){currStat} = ...
                    groupedData.dataPoints{iGroup}.(currVar){currStat}(filter,:);
            end
        end
        level2.dataPoints{iAnimal} = level3;
    end
    groupedData_animals.animals{iGroup} = level2;
end

%%

fprintf('\nDone! Data was stored in the Workspace.\n');

