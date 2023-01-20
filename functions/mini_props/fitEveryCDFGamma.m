function [allparams,allgof,allxTrunc] = fitEveryCDFGamma(sortedData,groupIndex,fileIndex, ...
                                              groupName,outputDir)
%% Fit every recording of a group to truncated gamma model.
% This function runs gammafit.m on every recording of the target group.
% Graphs and CDF parameters for each recording will be generated.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - sortedData : must have file names as row names,
%                       or file names stored in a column named 'fileName'
%        - groupIndex : A table containing grouping info;
%                       can be generated with addGroup.m
%        - fileIndex : A table containing file info;
%                      can be imported from xlsx file by readIndex.m
%        - groupName : Name of the target group (in groupIndex)
%        - outputDir : directory to store output data
% Output:
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
%
% Note: This function was adapted from run_gammafit.m (Liu et al. (2014))
%
% Reference:
% Liu, M., Lewis, L. D., Shi, R., Brown, E. N., & Xu, W. (2014). 
% Differential requirement for NMDAR activity in SAP97β-mediated regulation
% of the number and strength of glutamatergic AMPAR-containing synapses. 
% Journal of Neurophysiology, 111(3), 648–658. 

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

outputDir = [outputDir '/gamma_cdf/' char(groupName) '/'];
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
fprintf('Done! Output files were saved at:\n %s\n',outputDir);
end
