function [selections,check] = selectGroups(groupedData,n)
% groupSelector: Display listbox and ask user to select groups.
% groupedData: Name of grouped data table
% n: 0 for selecting multiple groups; 1 for single group; 2 for two groups

%% Check if groupedData is loaded

if ~exist('groupedData','var')
    fprintf('Please load ''groupedData.mat'' first!');
end

%% Define prompt and mode according to n

switch n
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

%% Listbox

groupList = groupedData.Properties.RowNames;
[index,check] = listdlg('PromptString',prompt,'ListSize',[250,300], ...
    'ListString',groupList,'SelectionMode',mode);
selections = groupList(index);

%% If n is set to 2, check if two groups are selected.

nSelections = length(selections);
if n == 2 & nSelections ~= 2
    fprintf('%d group(s) selected - Please select TWO groups to proceed.\n',nSelections);
    % reset variables
    selections = {};
    check = 0;
    return;
end
