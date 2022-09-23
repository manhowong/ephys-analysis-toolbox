function summary = summarize(sortedData,groupIndex,var)
%% Calculate summary statistics of the selected variable by groups.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - sortedData : Sorted recording data; 
%                        generated by importRecordings.m
%         - groupIndex : A table containing grouping info;
%                        can be generated with addGroup.m
%         - var : String; dependent variable in sortedData to be summarized
% Output: - summary : A table containing the following statistics
%                     - n_recordings (number of recordings)
%                     - n_animals (number of recordings)
%                     - mean
%                     - median
%                     - SD (standard deviation)
%                     - CV (coefficient of variance)
%                     - SEM (standard error of the mean)

%%

summary = table;

nGroups = height(groupIndex);
for g = 1:nGroups
    % Get data by group
    groupName = groupIndex.Properties.RowNames(g);
    filteredData = applyFilters(sortedData,groupIndex,groupName);
    % Statistics
    nRecordings = height(filteredData);
    nAnimals = length(unique(filteredData.mouseID));
    mean = groupsummary(filteredData.(var),[],"mean");
    median = groupsummary(filteredData.(var),[],"median");
    SD = groupsummary(filteredData.(var),[],"std");
    CV = SD/mean;
    SEM = SD/sqrt(nRecordings);
    % Copy statistics to 'summary'
    summary{groupName,1:7} = {nRecordings,nAnimals,mean,median,SD,CV,SEM};
end
% Change 'summary' column names
statList = {'n_recordings','n_animals','mean','median','SD','CV','SEM'};
summary.Properties.VariableNames = statList;

end