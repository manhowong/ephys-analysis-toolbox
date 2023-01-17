function varList = getDependentVar(sortedData,fileIndex)
%% Generate a list of dependent variables, e.g., for dropdown list.
% Man Ho Wong, University of Pittsburgh.

%%

allVars = sortedData.Properties.VariableNames;
independentVars = [fileIndex.Properties.VariableNames, 'events']; 
varList = allVars(~ismember(allVars, independentVars));
varList = string(varList); % dropdown list only accepts string array

end