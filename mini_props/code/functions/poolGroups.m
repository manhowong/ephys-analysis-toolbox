function [groupIndex] = poolGroups(groupIndex,targets,new)
%% Merge two or more groups into a new group.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - groupIndex : A table containing grouping info;
%                        can be generated with addGroup.m
%         - targets : A cell array of groups selected via selectGroups.m
%         - new : name of the new group to be added
% Output: - groupIndex : New group will be added as a new row;
%                        existing group will be overwritten with new values

%% Setup

% Set initial values for comparing age
groupIndex.minAge{new} = groupIndex.minAge{targets{1}};
groupIndex.maxAge{new} = groupIndex.maxAge{targets{1}};

% Get a list of factors
factors = groupIndex.Properties.VariableNames;

% Remove 'minAge' and 'maxAge' as they will be processed separately
factors = factors(~ismember(factors,{'minAge','maxAge'}));


%% Concatenate factor values of selected groups

nFactors = length(factors);
nTargets = length(targets);
for g = 1:nTargets
    % 'minAge' and 'maxAge' of the pooled group:
    % the lowest and the highest values of all the groups    
    groupIndex.minAge{new} = min([groupIndex.minAge{new}, ...
                                  groupIndex.minAge{targets{g}}]);
    groupIndex.maxAge{new} = max([groupIndex.maxAge{new}, ...
                                  groupIndex.maxAge{targets{g}}]);
    % Concatenate other factors
    for k=1:nFactors
        groupIndex.(factors{k}){new} = [groupIndex.(factors{k}){new}; ...
                                        groupIndex.(factors{k}){targets{g}}];
    end
end

%% To remove repeated items

%   e.g. After combining two ctrl groups, you will have two entries of
%   'ctrl' in the field 'condition'. To remove the extra entry, use the 
%   function 'unique' to include only unique entries.

for k=1:nFactors
    groupIndex.(factors{k}){new} = unique(groupIndex.(factors{k}){new});
end

fprintf('Done!\n''%s'' was added to ''groupIndex''.\n', new);
end