function [allparams,allgof,allxTrunc] = fitEachRecGamma(sortedData,groupIndex,fileIndex, ...
                                              groupName,outputDir)
%% Fit each recording of a group to truncated gamma model.
% This function requires data organized in Man Ho's data structure (see
% analyzeMini.mlx). It runs the function gammafit on each recording of a
% user-defined group. Graphs and parameter values of left-truncated gamma
% model for each recording are generated.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - sortedData : must have file names as row names,
%                        or file names stored in a column named 'fileName'
%         - groupIndex : A table containing grouping info;
%                        can be generated with addGroup.m
%         - fileIndex : A table containing file info;
%                       can be imported into MATLAB with readIndex.m
%         - groupName : Name of the group (in groupIndex) to be filtered
%         - outputDir : directory to store output data
% Outputs:
%   allparams and allgof are optional
%   allparams: parameters of left-truncated gamma model
%              (column 1-6: alpha, alpha CI, beta, beta CI, mean, mean CI)
%   allgof: goodness-of-fit results otained by comparing amplitude data to
%           left-truncated Gamma model with MATLAB function kstest2
%           (column 1-3: null hypothesis decision, p value, KS statistic)
%   
%   The function generates:
%   - screen output: number of analyzed events each recording
%   - a figure containing plots of the fitted data for each recording;
%   - gammastats_all.mat containing allparams, allgof, allfiles (file names
%     of recordings) for the group.
%   - The above files are saved in ../analysis/gammaFitting/groupName/

% Note: This function was adapted from run_gammafit.m to fit Man Ho's data
% structure. 

%% Read data and initialize variables

data = applyFilters(sortedData,groupIndex,fileIndex,groupName);
allfiles=data.fileName(:,1);
allparams=zeros(height(data),6);
allgof=zeros(height(data),3);
allxTrunc=zeros(height(data),1);

%threshold: event filtering thresholds (4 numbers):
%           {min iei, [min rise time, max rise time], min amplitude}
%           by default: {0, [0 99], 0} (should include all events)
threshold = {0, [0 99], 0}; 

outputDir = [outputDir '/' char(groupName) '/'];
if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Fit each recording to gamma model and save outputs

for f=1:height(data)
    % Fit gamma model
    [allparams(f,:),allgof(f,:),allxTrunc(f)]= ...
        gammafit(table2array(data.events{f}),threshold);
    % Save plot of interest
    saveas(gcf,[outputDir data.fileName{f}(1:end-4) '_gamma.fig']);
    close(gcf);
end
save([outputDir 'gammastats_all.mat'],'allfiles','allparams','allgof','allxTrunc');
addpath(genpath(outputDir)); % Add newly created folders/files to path
end
