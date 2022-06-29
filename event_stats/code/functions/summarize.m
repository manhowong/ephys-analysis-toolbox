function [summary] = summarize(groupedData,pointStat,variable)
summary = table;
nGroup = height(groupedData);
groupStat = ["nOfRecording" "nOfAnimal" "groupMean" "groupMedian" "groupMin" "groupMax" "groupSD" "groupCV" "groupSEM"];
nGroupStat = length(groupStat);
for iGroupStat = 1:nGroupStat
    currGroupStat = groupStat(iGroupStat);
    switch currGroupStat
        case "nOfRecording"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    height(groupedData.dataPoints{iGroup}.(variable){pointStat});
            end
        case "nOfAnimal"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    length(unique(groupedData.dataPoints{iGroup}.(variable){pointStat}.mouseID));
            end
        case "groupMean"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    mean(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupMedian"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    median(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupMin"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    min(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupMax"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    max(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupSD"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    std(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupCV"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    std(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:))/...
                        mean(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:));
            end
        case "groupSEM"
            for iGroup = 1:nGroup
                summary.(currGroupStat){groupedData.Properties.RowNames(iGroup)} = ...
                    std(groupedData.dataPoints{iGroup}.(variable){pointStat}.dataPoints(:))/...
                    sqrt(height(groupedData.dataPoints{iGroup}.(variable){pointStat}));
            end
end
end