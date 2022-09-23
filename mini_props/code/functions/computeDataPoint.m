function [sortedData] = computeDataPoint(sortedData,varList,statistic)

fprintf('Computing data points...');

% create a new column 'dataPoints' to sortedData with size matching that of sortedData 
nRecording = height(sortedData);
if ~ismember('dataPoints',sortedData.Properties.VariableNames)
    for iRecording = 1:nRecording
        sortedData.dataPoints{iRecording} = table;
    end
else
    % Assign NaN as the default value for each of the fields.
    for iRecording = 1:nRecording
        if sortedData.include(iRecording) == 1
            sortedData.dataPoints{iRecording}{statistic,:} = NaN;
        end
    end
end


%%
switch statistic
    case "mean"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if sortedData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(sortedData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(mean(sortedData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to sortedData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    sortedData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
                % freq is added separately because freq does not exist in the original event file
                sortedData.dataPoints{iRecording}.('freq')(statistic) = 1/results.iei*1000;
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    case "median"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if sortedData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(sortedData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(median(sortedData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to sortedData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    sortedData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "sd"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if sortedData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(sortedData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(sortedData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to sortedData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    sortedData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "cv"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if sortedData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(sortedData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(sortedData.events{iRecording}{:,varFilter})./...
                    mean(sortedData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to sortedData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    sortedData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "sem"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if sortedData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(sortedData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(sortedData.events{iRecording}{:,varFilter})./...
                    sqrt(height(sortedData.events{iRecording})));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to sortedData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    sortedData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

end



%%
fprintf('Done!\nData points were stored in the column ''dataPoints'' in ''sortedData''.\n');
fprintf('***\nRemember to save sortedData in the next step before you close MATLAB.\n');
end
