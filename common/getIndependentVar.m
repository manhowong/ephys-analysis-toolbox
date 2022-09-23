function varList = getIndependentVar(fileIndex,var2remove)
%% Generate a list of independent variables available in fileIndex.
% Independent variables are the factors for grouping data.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - fileIndex : A table containing file info;
%                       can be imported from xlsx file by readIndex.m
%         - var2remove : A cell array of variables to be excluded, e.g.:
%                          {'fileName','mouseID','recordDate','DOB', ...
%                           'age','include','events','meanValue'}
% Output: - varList : a cell array of independent variables

%%

allVars = fileIndex.Properties.VariableNames;
varList = allVars(~ismember(allVars,var2remove));

end