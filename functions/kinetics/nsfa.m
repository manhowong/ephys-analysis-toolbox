function [results, fig] = nsfa(fname, tracesDir, settings)
%% Run peak-scaled NSFA on one recording.
% In this analysis, the average trace of a recording is scaled according to
% the ratio between its peak and the amplitude at the equivalent time point
% of an aligned trace it is being compared to.
% This function fits one recording at a time. You can call this function in
% your own script, or use the script "runNSFA.m" to run it automatically.
% Man Ho Wong, University of Pittsburgh, 2022-04-04
% -------------------------------------------------------------------------
% File needed: Aligned traces (.txt) by MiniAnalysis software
%              (See examples in the folder ../demoData/traces/)
% -------------------------------------------------------------------------
% Fitting options: - window of decay phase to be analyzed
%                  - binning and bin size
%                  - fitting with background noise
% -------------------------------------------------------------------------
% Inputs: - fname : file name of recording
%         - tracesDir : directory of aligned traces files (must end in '/')
%         - settings : a struct containing following fields
%           - settings.baseStartT : baseline start time, ms
%           - settings.baseEndT : baseline end time, ms
%           - settings.tailLength : tail (end of trace) length, ms
%           - settings.decayStart : Decay phase start point, % peak
%           - settings.decayEnd : Decay phase end point, % peak
%           - settings.membraneV : membrane potential, mV
%           - settings.reversalV : reversal potential of target channel, mV
%           - settings.binning : binning datapoints (true or false)
%           - settings.nBin :  number of bins
%           - settings.includeBaseVar : Include empirical baseline in model
%                                       (true or false)
%           See comments in the code for more info.
% -------------------------------------------------------------------------
% Outputs: - Command window: values for i, N, g, R^2, etc.
%          - Figure: plot of variance vs mean current and the fitted curve
%                     and plot of traces analyzed
%          - nsfaReport: summary report for NSFA

%% Recording properties

baseStartT = settings.baseStartT;  % baseline start time, ms
baseEndT = settings.baseEndT;      % baseline length, ms
tailLength = settings.tailLength;  % tail (end of trace) length, ms
membraneV = settings.membraneV;    % membrane potential, mV
reversalV = settings.reversalV;    % reversal potential of target channel, mV
% Note: sFreq (sampling frequency) will be computed from data by
%       the function importTraces

%% Fitting preferences

% Window of decay phase to be analyzed:
% Decay phase start point and end point as fractions of avg. peak amplitude
% e.g. Set them to 0.95 and 0.1 to analyze from 95%peak to 10%peak.
% Note:
% Setting start point to 100%peak is not recommended: Since the analysis
% is done with average peak scaled to individual traces, variance of
% sampling points near the peak would be very small and you will likely see
% a data point with unusually small variance on the graph. This may affect 
% the fitting of the model. (You can try setting start point to 100% or 95%
% and compare.)
decayStart = settings.decayStart;
decayEnd = settings.decayEnd;

% binning datapoints?
binning = settings.binning;  % true or false
nBin = settings.nBin;        % number of bins

% Include empirical baseline (background noise) variance in the model?
%  If not, baseline variance will be estimated by fitting.
includeBaseVar = settings.includeBaseVar;  % true or false

%% Model for fitting

% Model for NSFA:
% var = i*mean - (mean^2/N) + baseVar
% i is single-channel current; N is number of channels;
%   baseVar is baseline variance

% Fitting options and functions (depends on fitting baseVar or not)
opt = fitoptions('Method','NonlinearLeastSquares');
if includeBaseVar == true
    opt.Lower = [0,1];        % Lower limits for i and N, optional
    opt.Upper = [1000,1000];  % Upper limits for i and N, optional
    opt.StartPoint = [1,5];   % Where algorithm should start to guess, optional
    model = fittype('a*x-(x^2/b) + c', 'problem', 'c', 'options', opt);
else % also fit baseVar
    opt.Lower = [0,1,0];        % Lower limits for i, N and baseVar, optional
    opt.Upper = [1000,1000,5]; % Upper limits for i, N and baseVar, optional
    opt.StartPoint = [1,5,4];   % Where algorithm should start to guess, optional
    model = fittype('a*x-(x^2/b) + c', 'options', opt);
end

%% Read traces from file
[allTraces, sFreq] = importTraces(fname, tracesDir);
if isempty(allTraces)  % stop running if traces not imported
    results = [];
    fig = [];
    return; 
end

%% Truncate traces
% baseTruncT = 14;  % sampling points before this time will be removed; ms
% traceLength = 60;  % sampling points after this time will be removed; ms
% baseTruncPt = sFreq*baseTruncT/1000;
% traceLengthPt = sFreq*traceLength/1000;
% allTraces(1:baseTruncPt,:) = [];  % truncate baseline
% allTraces(traceLengthPt:end,:) = [];  % truncate tail
% allTraces.time = allTraces.time - 14;  % reset time point after truncation

%% Drop funky traces and traces with more than one event
% zero traces first before dropping bad traces!
allTraces = zeroTraces(allTraces, baseStartT, baseEndT, sFreq);
[filteredTraces, dropped] = dropBadTraces(allTraces, baseStartT, baseEndT,...
                                          tailLength, sFreq);

% To skip screening traces, comment the above line and uncomment the
%   following line:
% filteredTraces = allTraces;

%% Under development...
% Check time stability
% Test for correlations between waveform parameters
% Re-align events and recalculate avgTrace

%% Zero all traces by original average baseline
% Traces should have been zeroed to their own baselines by the MiniAnalysis
% Program, but we don't know what the exact range of baseline the program
% used to zero the traces, and therefore the baseline position might not be
% what you want (though the difference is probably very small).
% Using the zeroTraces function, the baseline position can be adjusted by 
% shifting all the traces to your desired position (e.g., you want to use 
% 0 to 4 ms of the average trace as the Baseline position).
% Note that changing baseline position will change the variance-mean 
% relationship slightly. Binning will also differ slightly as amplitude
% intervals will have different values. Therefore, it is recommended to use
% consistent baseline position to get the same fitting results.
zeroedTraces = zeroTraces(filteredTraces, baseStartT, baseEndT, sFreq);

%% Find position of the peak of avgTrace

% Peak amplitude of avgTrace
avgPeak = min(zeroedTraces.avgTrace);

% Position of avgTrace peak
%   in case more than 1 sampling point matching avgPeak are found, get the
%   first one
avgPeakIdx = find(zeroedTraces.avgTrace==avgPeak, 1 , 'first');

%% Find decay phase start point and end point

% Theoretical amplitude at decay phase start / end point
targetStartAmpl = avgPeak*decayStart;
targetEndAmpl   = avgPeak*decayEnd;

% Find nearest positions of decay phase start point and end point
[~, startIdx] = min(abs(avgThreePts(zeroedTraces.avgTrace(avgPeakIdx:end))-targetStartAmpl));
decayStartIdx = startIdx + (avgPeakIdx - 1);
[~, endIdx] = min(abs(avgThreePts(zeroedTraces.avgTrace(avgPeakIdx:end))-targetEndAmpl));
decayEndIdx = endIdx + (avgPeakIdx - 1);

% Check if targetEndAmpl is reached
%   amplitude nearest to targetEndAmpl
nearestEndAmpl = zeroedTraces.avgTrace(decayEndIdx);
%   max. background noise (i.e. max. absolute baseline ampl.) as threshold
baseStartPt = sFreq*baseStartT/1000 + 1; % Get baseline locations
baseEndPt = sFreq*baseEndT/1000 + 1;     % Get baseline locations
detectThreshold = max(abs(zeroedTraces.avgTrace(baseStartPt:baseEndPt)));
targetReached = true;
if nearestEndAmpl < targetEndAmpl & ...
    diff([nearestEndAmpl,targetEndAmpl]) > detectThreshold
    targetReached = false;
end

%% Compute variance of amplitude during decay phase

% Peak-scaled method
% First, scale average trace so that its peak amplitude equals to the
%   amplitude of the trace being compared to at the same time point
scaleRatios = zeroedTraces{avgPeakIdx, 3:end}/avgPeak;
avgTraceAmpl_scaled = zeroedTraces{:, 'avgTrace'}*scaleRatios;

% Compute amplitude difference between each trace and the scaled avgTrace
%   at each sampling point
ampls = zeroedTraces{:, 3:end};
amplDiff_scaled = ampls - avgTraceAmpl_scaled;

% Compute variance from amplDiff_scaled at each sampling point:
% - note: variance of amplDiff_scaled is the same as variance of ampls:
%         var(amplVar_scaled, 0, 2) gets the same result as
%         sum(amplVar_scaled.^2, 2)/(width(ampls)-1)
%         but the latter one is more efficient
% - set 2nd argument to 2 (sum across 2nd dimension, i.e rows)
amplVar_scaled = sum(amplDiff_scaled.^2, 2)/(width(ampls)-1);

% Amplitude and amplitude variance during decay phase
decayAmpl = zeroedTraces.avgTrace(decayStartIdx:decayEndIdx);
decayVar = amplVar_scaled(decayStartIdx:decayEndIdx);

%% Binning

skipBin = false;
if binning == true

    % get boundaries of intervals determined by number of bins
    boundaries = table(linspace(targetStartAmpl,targetEndAmpl,nBin+1)', 'VariableNames', {'ampl'});

    % search for sampling points which are nearest to interval boundaries
    lowerBoundIdx = 1;
    for i = 1:nBin+1
        [~, boundaries.idx(i)] = min(abs(avgThreePts(decayAmpl(lowerBoundIdx:end))-boundaries.ampl(i)));
        boundaries.idx(i) = boundaries.idx(i) + (lowerBoundIdx - 1);
        lowerBoundIdx = boundaries.idx(i) + 1;
        % if end of analysis window reached but not all boundaries found
        %   (happens when bin interval < smallest possible interval in the recording)
        if i < nBin+1 & boundaries.idx(i) == height(decayAmpl)
            nBin0 = nBin;  % store original nBin (for reporting)
            nBin = i-1;  % update nBin: current iteration number (loop break point) -1 (offset)
            skipBin = true;  % for warning user
            break
        end
    end
    
    % Bin sampling points according to interval boundaries found above
    binned = table(zeros(nBin,1), zeros(nBin,1), 'VariableNames', {'ampl','var'});
    for i = 1:nBin
        lowerBoundIdx = boundaries.idx(i);
        upperBoundIdx = boundaries.idx(i+1) - 1;
        binned.ampl(i) = mean(decayAmpl(lowerBoundIdx:upperBoundIdx));
        binned.var(i) = mean(decayVar(lowerBoundIdx:upperBoundIdx));
    end
    x = abs(binned.ampl);
    y = binned.var;
else
    x = abs(decayAmpl);
    y = decayVar;
    nBin = 0;
end

%% Fit data to model

% Include measured baseVar or not
if includeBaseVar == true

    % Get amplitude variance without scaling average trace
    avgTraceAmpl = zeroedTraces{:, 'avgTrace'};  % No need to scale
    amplDiff = ampls - avgTraceAmpl;
    amplVar = sum(amplDiff.^2, 2)/(width(ampls)-1);

    % Get amplitude variance within baseline
    baseVar = amplVar(baseStartPt:baseEndPt);  % variance at each point
    baseVar_mean = mean(baseVar);  % mean variance across all points in baseline

    % Fitting
    [fitResults, gof] = fit(x, y, model, 'problem', baseVar_mean);
    baseVarType = 'measured';

else
    
    % Fitting
    [fitResults, gof] = fit(x, y, model);
    baseVar_mean = fitResults.c;
    baseVarType = 'estimated';

end

% Retrive fitting results
current  = fitResults.a;  % single channel current, pA
nChannel = fitResults.b;  % number of channels
g = abs( current/(membraneV-reversalV) )*1000;  % conductance, pS
r2 = gof.rsquare;
results = {current, nChannel, g, baseVar_mean, baseVarType, r2, ...
           width(allTraces)-2, length(dropped), ...
           decayStart*100, decayEnd*100, targetReached, nBin};

%% Plot fitting results

fig = figure('Position', [0 0 400 700]); 
tiles = tiledlayout(2,1);

% figure title; keep underscore in string
title(tiles, fname, 'Interpreter', 'none');

% Plot panel 1
nexttile;
hold on;

% Plot all analyzed traces
for i = 3:width(zeroedTraces)
    plot(zeroedTraces.time,zeroedTraces.(i), "Color", [.9 .9 .9]);
end

% Plot avgTrace
avgLine = plot(zeroedTraces.time,zeroedTraces.avgTrace, LineWidth=1.5, Color='k');

% Plot window of analysis
t1 = zeroedTraces.time(decayStartIdx);
t2 = zeroedTraces.time(decayEndIdx);
window = xline([t1,t2],':', Color='k');           % analysis window

% Figure settings for panel 1
title('Analyzed traces');
xlabel('Time (ms)');                              % x-axis title
ylabel('Amplitude (pA)');                % y-axis title
xlim([0 max(zeroedTraces.time)]);                % x-axis range equals trace
set(gca,'TickDir','out');                         % axis ticks direction
legend([avgLine,window(1)], {'Average trace','Analysis start/end point'}, ...
       Location='southeast');                     % legend
legend boxoff;

% Plot panel 2
nexttile;
hold on;

scatter(x, y, MarkerEdgeColor='k', LineWidth=1);  % plot datapoints
h = plot(fitResults,'r');                         % plot fitted curve

% Figure settings for panel 2
title('Amplitude variance vs. mean');
set(h,'LineWidth',1.5);                           % fitted curve width
xlabel('Mean current, Î (-pA)');                        % x-axis title
ylabel('Variance (pA^2)');                        % y-axis title
xAxis = xlim;                                     % get x-axis range
xlim([0 xAxis(2)]);                               % make x-axis starts at 0
yAxis = ylim;                                     % get y-axis range
ylim([0 yAxis(2)]);                               % make y-axis starts at 0
set(gca,'TickDir','out');                         % axis ticks direction
legend('Data bin','Fit', Location='northwest');       % legend
legend boxoff;
% Display fitting results in panel 1:
annotation = sprintf("i = %0.2f pA, N = %0.2f", current, nChannel);
text(diff(xlim)*0.05, diff(ylim)*0.08, annotation);

%% Print fitting results

fprintf('\n---------- Below: %s ----------\n', fname);
fprintf('i = %0.6f pA \nN = %0.6f \ng = %0.6f pS \nR^2 = %0.6f \n', ...
        current, nChannel, g, r2);
if includeBaseVar
    fprintf('- Measured baseline variance [%0.6f pA^2] was used for fitting.\n', ...
            baseVar_mean);
else
    fprintf('Estimated baseline variance = %0.6f\n', baseVar_mean);
end
fprintf('- [%d events] found in the recording.\n', width(allTraces)-2);
fprintf('- [%d events] were excluded from the analysis.\n', length(dropped));
fprintf('- [%d%% to %d%%] decay phase was specified for the fitting.\n', ...
        decayStart*100, decayEnd*100);

% Warn user if actual number of bins is not same as configured
if skipBin
    fprintf(['*ATTENTION*\n- [%d bins] specified, but only [%d bins] were made since some bin intervals are\n', ...
             '  below the smallest possible interval (resolution) in the selected range of decay phase.\n'], nBin0, nBin);
elseif binning
    fprintf('- [%d bins] were made.\n', nBin);
end

% Warn user if decay may not reach decayEnd
if targetReached == false
    fprintf(['*ATTENTION*\n- Decay may not reach [%d%%] of the peak!\n' ...
             '-- Calculated amplitude at [%d%%] peak: [%0.2f pA]. Nearest amplitude found: [%0.2f pA].\n' ...
             '-- Difference between the two is larger than background noise range,\n' ...
             '-- i.e. maximum absolute amplitude in baseline of average trace, [%0.2f pA].\n'], ...
             decayEnd*100, decayEnd*100, targetEndAmpl, nearestEndAmpl, detectThreshold);

end
end