nGroup = height(groupIndex);
groupedData = table;

for iGroup = 1:nGroup
    % Retrieve filter values and group name from groupInfo
    filterValue = struct;
    filterValue.researcher = groupIndex.researcher{iGroup};
    filterValue.condition = groupIndex.condition{iGroup};
    filterValue.facility = groupIndex.facility{iGroup};
    filterValue.sex = groupIndex.sex{iGroup};
    filterValue.minAge = groupIndex.minAge{iGroup};
    filterValue.maxAge = groupIndex.maxAge{iGroup};
    filterValue.cellType = groupIndex.cellType{iGroup};
    filterValue.genotype = groupIndex.genotype{iGroup};
    filterValue.treatment = groupIndex.treatment{iGroup};
    newGroup = groupIndex.Properties.RowNames{iGroup};
    % Call groupedData
    groupedData = groupRecordings(compiledData,groupedData,filterValue,newGroup,varListInclFreq);
end
