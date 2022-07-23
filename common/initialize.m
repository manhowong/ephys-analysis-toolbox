function initialize(codeDir, dataDir, sessionDir, resume)
%% Initialize analysis session.
% This function sets paths, creates a new directory for outputs and load
% previous analysis session if requested.
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% Inputs: - codeDir : directory of the code
%         - dataDir : directory of the data
%         - sessionDir : directory of previous analysis session
%         - resume : true or false; resume previous session if true
% Example of a directory path: 'C:\Users' (Windows: '\' or '/'; Mac: '/')

%% Clear current Workspace
quest = {'Current Workspace will be cleared. Continue?'};
response = questdlg(quest,'Initializing analysis session...','Yes','No','No');
switch response
    case {'Yes'}            
        clearvars -except codeDir dataDir sessionDir resume
    case {'No',''}
        return
end

%% Create new session folder if it does not exist
if ~exist(sessionDir, 'dir')
    mkdir(sessionDir);
end

%% Add paths
addpath(codeDir,dataDir,sessionDir);
p = genpath(codeDir);
addpath(p); % add all subfolders in codeDir to path

%% Resume previous session if requested
if resume == true
    % load sortedData.mat
    fprintf('Resuming previous analysis session...\n');
    if exist([sessionDir '/sortedData.mat'],"file")        
        load([sessionDir '/sortedData.mat'],'sortedData');
        fprintf('sortedData.mat loaded.\n');
    end
    % load group_index.mat
    if exist([sessionDir '/group_index.mat'],"file")
        load([sessionDir '/group_index.mat'],'groupIndex');
        fprintf('group_index.mat loaded.\n');
    end
    % load nsfaReport.mat
    if exist([sessionDir '/nsfaReport.mat'],"file")
        load([sessionDir '/nsfaReport.mat'],'nsfaReport');
        fprintf('nsfaReport.mat loaded.\n');
    end
    % load decayReport.mat
    if exist([sessionDir '/decayReport.mat'],"file")
        load([sessionDir '/decayReport.mat'],'decayReport');
        fprintf('decayReport.mat loaded.\n');
    end
end
