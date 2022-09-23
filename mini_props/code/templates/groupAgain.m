groupedData = table;
factor = ["minAge" "maxAge" "researcher" "condition" "facility" "sex" "cellType" "genotype" "treatment"];
nFactor = length(factor);
newGroup = groupedDataOld.Properties.RowNames;
nNewGroup = length(newGroup);

for iNewGroup = 1:nNewGroup
    % read filter values from old groupedData table
    filterValue = struct;
    for iFactor = 1:nFactor
        filterValue.(factor(iFactor)) = groupedDataOld.(factor(iFactor)){iNewGroup};
    end
    % group recordings
    currNewGroup = string(newGroup(iNewGroup));
    groupedData = groupRecordings(compiledData,groupedData,filterValue,currNewGroup,varListInclFreq);
end

