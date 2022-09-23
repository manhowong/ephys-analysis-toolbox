function [distReport, fig] = fitGroupDist(decayReport, groupName, r2Thres,...
                                          nBoot, nResample, jitter)
%% Fit GM distribution to each recording and a group of recordings.
% The function calls bootstrapData.m to bootstrap the input data (i.e.
% decay parameters of each recording). The distribution of decay parameters
% for each recording is fitted to a gaussian mixture distribution. In
% addition, data of all recordings from the same group are merged and then
% fitted to a gaussian mixture distribution.
% Man Ho Wong, University of Pittsburgh, 2022-05-18
% -------------------------------------------------------------------------
% Inputs: - decayReport : decay parameters computed by runFitDecay.m
%         - groupName : Group name enclosed by single quotes (e.g. 'ctrl')
%         - r2Thres : Event's R-squared threshold (from decay fitting);
%                     events with R-squared smaller than this are excluded
%         - nBoot : number of bootstrap runs
%         - nResample : number of data points to be sampled from each
%                       recording
%         - jitter : add simulated jitter to resampled data points
% To configure fitting preferences, see next section.
% -------------------------------------------------------------------------
% Outputs: - distReport : distribution fitting summary
%               - I0_mean/ tau_mean : means of component distributions
%               - I0_var/ tau_var : variances of component distributions
%               - I0_proportions/ tau_proportions : component proportions
%          - fig : Figure of I_0 and tau distributions with fitted curves
% -------------------------------------------------------------------------
% Example:
% [distReport, fig] = fitGroupDist(decayReport,'ctrlF53',0.5,100,500,true);

%% Fitting preferences

kI_0 = 2;  % number of components to fit I_0 distribution
kTau = 2;  % number of components to fit tau distribution
rng(0);    % use the same random seed for reproducibility

%% Fit I_0 or tau distribution of each recording

nFiles = height(decayReport);
mergedI_0 = zeros(nFiles*nBoot*nResample,1);
mergedTau = zeros(nFiles*nBoot*nResample,1);
distReport = table();

for f = 1:nFiles
    % Get event info from each recording
    events = decayReport.events{f};
    events = events(events.('r^2') > r2Thres, :); % only well fitted events
    I_0s = events.I_0;
    taus = events.tau;
    % Bootstrap data
    bootI_0 = bootstrapData(I_0s, nBoot, nResample, jitter);
    bootTau = bootstrapData(taus, nBoot, nResample, jitter);
    % Fit I_0 or tau distribution of each recording
    I_0Fit = fitgmdist(bootI_0(:),kI_0,'Options',statset('MaxIter',1500),'SharedCovariance',true);
    tauFit = fitgmdist(bootTau(:),kTau,'Options',statset('MaxIter',1500),'SharedCovariance',true);
    % Store fitting results into a table
    results = {I_0Fit.mu, I_0Fit.Sigma(:), I_0Fit.ComponentProportion,...
               tauFit.mu, tauFit.Sigma(:), tauFit.ComponentProportion};
    % Append fitting results for this recording to distReport
    fname = decayReport.Properties.RowNames{f};
    distReport{fname,:} = results;
    distReport.Properties.VariableNames = ...
    {'I0_mean','I0_var','I0_proportions','tau_mean','tau_var','tau_proportions'};  
    % Merge data from all recordings for group fitting (see next section)
    nPoints = nBoot*nResample;
    mergedI_0( (1+(f-1)*nPoints) : f*nPoints ) = bootI_0(:);
    mergedTau( (1+(f-1)*nPoints) : f*nPoints ) = bootTau(:);

end

%% Fit distribution for the entire group

mergedI_0Fit = fitgmdist(mergedI_0,kI_0,'Options',statset('MaxIter',1500),'SharedCovariance',true);
mergedTauFit = fitgmdist(mergedTau,kTau,'Options',statset('MaxIter',1500),'SharedCovariance',true);

%% Look for best k

% for k = 1:6
%     mergedTauFit = fitgmdist(mergedTau,k,'Options',statset('MaxIter',1500),'SharedCovariance',true);
%     AIC(k)= mergedTauFit.AIC;
% end
% [minAIC,numComponents] = min(AIC);

%% Plot fitting results

fig = figure('Position', [50 50 700 700]); 
t = tiledlayout(2,1);
nBin = 200;

% Plot panel 1
nexttile
hold on;

histogram(mergedI_0, nBin, Normalization='pdf', FaceColor='none', EdgeColor=[.8 .8 .8]);
[xMin, xMax] = bounds(mergedI_0);
x = xMin:0.1:xMax;
gmPDF = pdf(mergedI_0Fit,x');
plot(x, gmPDF, 'r', LineWidth=1.3)

sd = sqrt(mergedI_0Fit.Sigma);
for c = 1:kI_0
    componentPDF = normpdf(x,mergedI_0Fit.mu(c),sd)*mergedI_0Fit.ComponentProportion(c);
    plot(x, componentPDF, 'k-.')
end

% Panel 1 settings
title('Estimated peak current, I');
xlabel('Current amplitude (pA)');                 % x-axis title
ylabel('PDF');                                    % y-axis title
set(gca,'TickDir','out');                         % axis ticks direction

% Plot panel 2
nexttile
hold on;

histogram(mergedTau, nBin, Normalization='pdf', FaceColor='none', EdgeColor=[.8 .8 .8]);
[xMin, xMax] = bounds(mergedTau);
x = xMin:0.1:xMax;
gmPDF = pdf(mergedTauFit,x');
plot(x, gmPDF, 'r', LineWidth=1.3)

sd = sqrt(mergedTauFit.Sigma);
for c = 1:kTau
    componentPDF = normpdf(x,mergedTauFit.mu(c),sd)*mergedTauFit.ComponentProportion(c);
    plot(x, componentPDF, 'k-.')
end

% Panel 2 settings 
title('Estimated time constant, Tau');
xlabel('Tau (ms)');                               % x-axis title
ylabel('PDF');                                    % y-axis title
set(gca,'TickDir','out');                         % axis ticks direction

% figure title 
title(t, groupName, 'Interpreter', 'none');  % underscore in string is kept
