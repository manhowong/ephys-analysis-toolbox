function pass = available(objName, action)
%% Check file/folder/variable's availability for reading or writing.
% User needs to specify the target file/folder/variable and the action to
% be taken (reading or writing). If the target already exists, the function
% will ask the user to confirm the action.
%
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - objName : name of directory, file or variable
%        - action : 'r' or 'w' (read or write)
% Output: - pass : 0 if action is cancelled; 1 if confirmed

%%

pass = 1;
allVars = evalin("base","who"); % get variables in base Workspace

if objName == ""
    disp("Action cancelled: Incomplete user input.");
    pass = 0;
elseif action == 'w' && ( exist(objName,"dir") || exist(objName,"file") || ismember(objName,allVars) )
    % check if target is a folder
    if isfolder(objName)
        quest = {objName '...already exists. Existing files in this folder will be overwritten when saving files using the same file name. Continue?'};
    else
        quest = {objName '...already exists in the Workspace or in the directory. Continue?'};
    end
    % prompt
    response = questdlg(quest,'Overwrite Warning','Yes','No','No');
    if response == "No" || isempty(response)
            disp('Action cancelled by user.');
            pass = 0;
    end
elseif action == 'r' && ~( exist(objName,"dir") || exist(objName,"file") || ismember(objName,allVars) )
    fprintf('Action cancelled: %s not found.\n', objName);
    pass = 0;    
end
