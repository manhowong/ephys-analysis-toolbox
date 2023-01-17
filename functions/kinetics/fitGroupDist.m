function [distReport, grpResults, fig] = fitGroupDist(data, subTableCol, varName, ...
                                                      r2Thres, bootSettings, groupName, k)
%% Fit GM distribution to each recording and a group of recordings.
% The function calls bootstrapData.m to bootstrap the input data (i.e.
% decay parameters of each recording). The distribution of decay parameters
% for each recording is fitted to a gaussian mixture distribution. In
% addition, data of all recordings from the same group are merged and then
% fitted to a gaussian mixture distribution.
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% Inputs: - data : table with each subtable storing data of one recording
%         - subTableCol : name of sub table storing the recording data
%         - varName : variable name of the data to be merged, e.g. 'tau' 
%         - r2Thres : r-squared threshold for filtering data;
%                     if not used, set it to 0;
%         - bootSettings : struct; settings for bootstrapping*. Contains
%           following fields:
%           - nBoot : number of bootstrap runs
%           - nResample : number of data points to be sampled from each
%                         recording
%           - jitter : add random jitter to resampled data points if true
%           *set all fields to 0 to opt out bootstrapping
%         - groupName : Group name enclosed by single quotes (e.g. 'ctrl')
%         - k : % number of components for GM model
% -------------------------------------------------------------------------
% Outputs: - distReport : table containing fitting summary
%               - mean : means of component distributions
%               - var : variances of component distributions
%               - component_proportions : component proportions
%          - grpResults : fitting summary for merged data;
%                         one-row cell array containing:
%                         mean, var, and component_proportions (see above)
%          - fig : Figure of data distributions with fitted curves

%% Bootstrapping and Fitting settings

nBoot = bootSettings.nBoot;
nResample = bootSettings.nResample;
jitter = bootSettings.jitter;
rng(0);    % use the same random seed for reproducibility

%% Fit I_0 or tau distribution of each recording

distReport = table();
nFiles = height(data);
for f = 1:nFiles
    % Get event info from each recording
    oneFile = data.(subTableCol){f};
    oneFile = oneFile(oneFile.('r^2') > r2Thres, :); % only well fitted events
    dataPts = oneFile.(varName);
    % Bootstrap data
    bootDataPts = bootstrapData(dataPts, nBoot, nResample, jitter);
    % Fit distribution of each recording
    fit = fitgmdist(bootDataPts(:),k,'Options',statset('MaxIter',1500),'SharedCovariance',true);
    % Store fitting results into a table
    results = {fit.mu, fit.Sigma(:), fit.ComponentProportion};
    % get file name
    if ismember('fileName', data.Properties.VariableNames)
        fname = data.fileName{f};  % file names stored in column 'fileName'
    else
        fname = data.Properties.RowNames{f};  % us row names as file name
    end
    % Append fitting results for this recording to distReport
    distReport{fname,:} = results;
    distReport.Properties.VariableNames = ...
    {'mean','var','component_proportions'};
end

%% Fit distribution for the entire group

mergedData = mergeData(data, subTableCol, varName, r2Thres, bootSettings);
mergedFit = fitgmdist(mergedData,k,'Options',statset('MaxIter',1500),'SharedCovariance',true);
grpResults = {mergedFit.mu, mergedFit.Sigma(:), mergedFit.ComponentProportion,mergedData};

%% Look for best k

% for k = 1:6
%     mergedTauFit = fitgmdist(mergedTau,k,'Options',statset('MaxIter',1500),'SharedCovariance',true);
%     AIC(k)= mergedTauFit.AIC;
% end
% [minAIC,numComponents] = min(AIC);

%% Plot group fitting results

fig = figure('Position', [50 50 700 350]); 
nBin = 200;

hold on;

histogram(mergedData, nBin, Normalization='pdf', FaceColor='none', EdgeColor=[.8 .8 .8]);
[xMin, xMax] = bounds(mergedData);
x = xMin:0.1:xMax;
gmPDF = pdf(mergedFit,x');
plot(x, gmPDF, 'r', LineWidth=1.3)

sd = sqrt(mergedFit.Sigma);
for c = 1:k
    componentPDF = normpdf(x,mergedFit.mu(c),sd)*mergedFit.ComponentProportion(c);
    plot(x, componentPDF, 'k-.')
end

% figure settings
title(varName, groupName, 'Interpreter', 'none'); % underscore in string is kept
xlabel(varName);                                  % x-axis title
ylabel('PDF');                                    % y-axis title
set(gca,'TickDir','out');                         % axis ticks direction