function [compiledData] = computeDataPoint(compiledData,varList,statistic)

fprintf('Computing data points...');

% create a new column 'dataPoints' to compiledData with size matching that of compiledData 
nRecording = height(compiledData);
if ~ismember('dataPoints',compiledData.Properties.VariableNames)
    for iRecording = 1:nRecording
        compiledData.dataPoints{iRecording} = table;
    end
else
    % Assign NaN as the default value for each of the fields.
    for iRecording = 1:nRecording
        if compiledData.include(iRecording) == 1
            compiledData.dataPoints{iRecording}{statistic,:} = NaN;
        end
    end
end


%%
switch statistic
    case "mean"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if compiledData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(compiledData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(mean(compiledData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to compiledData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    compiledData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
                % freq is added separately because freq does not exist in the original event file
                compiledData.dataPoints{iRecording}.('freq')(statistic) = 1/results.iei*1000;
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    case "median"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if compiledData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(compiledData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(median(compiledData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to compiledData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    compiledData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "sd"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if compiledData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(compiledData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(compiledData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to compiledData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    compiledData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "cv"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if compiledData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(compiledData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(compiledData.events{iRecording}{:,varFilter})./...
                    mean(compiledData.events{iRecording}{:,varFilter}));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to compiledData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    compiledData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case "sem"
        fprintf('......');
        nVar = length(varList);
        for iRecording = 1:nRecording
            if compiledData.include(iRecording) == 1
                % compute only variables in varList
                varFilter = ismember(compiledData.events{iRecording}.Properties.VariableNames,varList);
                % compute all variables at once
                results = array2table(std(compiledData.events{iRecording}{:,varFilter})./...
                    sqrt(height(compiledData.events{iRecording})));
                results.Properties.VariableNames = cellstr(varList);
                % move result of each variable to compiledData
                for iVar = 1:nVar
                    currVar = varList{iVar};
                    compiledData.dataPoints{iRecording}.(currVar)(statistic) = results.(currVar);
                end
            end
        end
        fprintf('...');

end



%%
fprintf('Done!\nData points were stored in the column ''dataPoints'' in ''compiledData''.\n');
fprintf('***\nRemember to save compiledData in the next step before you close MATLAB.\n');
end
