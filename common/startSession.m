function startSession(codeDir, dataDir, idxPath, sessionDir, resume) %#ok<INUSL> 
%% Initialize analysis session.
% This function sets paths, creates a new directory for outputs and load
% previous analysis session if requested.
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% Inputs: - codeDir : path of the code directory
%         - dataDir : path of the data directory
%         - idxPath : path of the file index (see example: file_index.xlsx)
%         - sessionDir : path of the directory of previous analysis session
%         - resume : true or false; resume previous session if true
% Path example: 'C:\Users' (Windows: use '\' or '/'; Mac & Linux: use '/')

%% Clear current Workspace

quest = {'Current Workspace will be cleared. Continue?'};
response = questdlg(quest,'Initializing analysis session...','Yes','No','No');
switch response
    case {'Yes'}
        % Clear base Workspace variables via 'evalin'
        evalin('base', ['clearvars ' ...
               '-except codeDir dataDir idxPath sessionDir resume']);
    case {'No',''}
        fprintf('Action cancelled.\n');
        return
end

%% Create new session folder if it does not exist

if ~exist(sessionDir, "dir")
    mkdir(sessionDir);
end

%% Add paths

addpath(codeDir,dataDir,sessionDir);
p = genpath(codeDir);
addpath(p); % add all subfolders in codeDir to path

%% Read file index

evalin('base', 'fileIndex = readIndex(idxPath);');
fprintf('fileIndex loaded.\n');

%% Resume previous session if requested
%  Data will be loaded into the base Workspace via 'evalin'

if resume == true
    % load sortedData.mat
    fprintf('Resuming previous analysis session...\n');
    if exist([sessionDir '/sortedData.mat'],"file")      
        evalin('base', 'load([sessionDir ''/sortedData.mat''])');
        fprintf('sortedData loaded.\n');
    end
    % load group_index.mat
    if exist([sessionDir '/groupIndex.mat'],"file")
        evalin('base', 'load([sessionDir ''/groupIndex.mat''])');
        fprintf('groupIndex loaded.\n');
    end
    % load nsfaReport.mat
    if exist([sessionDir '/nsfaReport.mat'],"file")
        evalin('base', 'load([sessionDir ''/nsfaReport.mat''])');
        fprintf('nsfaReport loaded.\n');
    end
    % load decayReport.mat
    if exist([sessionDir '/decayReport.mat'],"file")
        evalin('base', 'load([sessionDir ''/decayReport.mat''])');
        fprintf('decayReport loaded.\n');
    end
end
