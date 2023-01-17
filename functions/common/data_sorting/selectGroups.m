function [targets,check] = selectGroups(groupIndex,modeID)
%% Display listbox and ask user to select groups.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - groupIndex : A table containing grouping info;
%                        can be generated with addGroup.m
%         - modeID : 0 for selecting multiple groups;
%                    1 for single group; 2 for two groups
% Outputs: - targets : A cell array of groups selected by user
%          - check : for checking if correct number of groups were selected

%% modeID determines Listbox prompt and mode

switch modeID
    case 0
        prompt = {'Select group(s) below.', ...
            'Press and hold ''Ctrl'' key to select multiple groups.'};
        mode = 'multiple';
    case 2
        prompt = {'Select TWO groups below.', ...
            'Press and hold ''Ctrl'' key to select two groups.'};
        mode = 'multiple';
    otherwise
        prompt = {'Select a group below.'};
        mode = 'single';
end

%% Listbox for selecting groups

groupList = groupIndex.Properties.RowNames;
[index,check] = listdlg('PromptString',prompt,'ListSize',[250,300], ...
                        'ListString',groupList,'SelectionMode',mode);
targets = groupList(index);

%% If modeID is 2, check if two groups are selected

nTargets = length(targets);
if modeID == 2 & nTargets ~= 2
    fprintf('%d group(s) selected - Please select TWO groups to proceed.\n',nTargets);
    % reset variables
    targets = {};
    check = 0;
    return;
end
