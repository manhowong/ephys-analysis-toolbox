function sortedData = getMeanValue(sortedData,varList)
%% Calculate the mean of each selected variable (column) in the data.
% To select variables, specify the variables in 'varList'.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - sortedData : table generated by importRecordings.m
%         - varList : a string array of variable names
% Output: - sortedData : results will be added as a new column, 'meanValue'

%% Compute mean

nRecordings = height(sortedData);

% Create a table and preallocate space to store results
results = zeros(nRecordings,length(varList));
results = array2table(results,'VariableNames',varList);

fprintf('Calculating mean values... ');
for ii = 1:nRecordings
    if sortedData.include(ii) == 1
        % compute means of the variables in 'varList'
        results{ii,:} = mean(sortedData.events{ii}{:,varList});    
    end
end

% freq is calculated from iei and added to the table
results.('freq') = 1./results.iei*1000;

% Append 'results' to 'sortedData'
sortedData(:, results.Properties.VariableNames) = results;
% Note: Don't use this >> sortedData = [sortedData, results]; It won't
%       work if this function is called on 'sortedData' the second time
%       because the same variables(columns) already exist and adding
%       columns of same names is not allowed

fprintf('Done!\nColumn ''meanValue'' was added to ''sortedData''.\n');

end