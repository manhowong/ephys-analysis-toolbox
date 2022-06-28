function decayInfo = fitDecay(fname, tracesDir, settings)
%% Fit each mEPSC event in a file to a first order exponential function.
% This function fits one recording at a time. You can call this function in
% your own script, or use the script runFitDecay.m to run it automatically.
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
%           - settings.binning : binning datapoints (true or false)
%           - settings.nBin :  number of bins
%           - settings.includeBaseVar : Include empirical baseline in model
%                                       (true or false)
%           See comments in the code for more info.
% -------------------------------------------------------------------------
% Output: - decayInfo : a table containing fitted parameters of each event
%           - I_0 : initial amplitude
%           - I_0 lowLim, I_0 upLim : lower and upper CI limit for I_0
%           - tau : initial amplitude
%           - tau lowLim, tau upLim : lower and upper CI limit for tau
%           - r^2 : R-squared
%           - nObs : number of observations

%% Recording properties

baseStartT = settings.baseStartT;  % baseline start time, ms
baseEndT = settings.baseEndT;  % baseline length, ms
tailLength = settings.tailLength;  % tail (end of trace) length, ms

%% Fitting preferences (optional)

opt = fitoptions('Method','NonlinearLeastSquares');
opt.Lower = [-200,-100];        % Lower limits for I_0 and -1/tau
opt.Upper = [0,20];             % Upper limits for I_0 and -1/tau
opt.StartPoint = [-15,-0.2];    % Where algorithm starts to guess, optional
I_0Thres = -5;
tauThres = 0;

%% Read traces from file
[allTraces, sFreq] = importTraces(fname, tracesDir);
if isempty(allTraces)  % stop running if traces not imported
    decayInfo = [];
    return; 
end

%% Drop funky traces and traces with more than one event
allTraces = zeroTraces(allTraces, baseStartT, baseEndT, sFreq);  % zero traces first
[filteredTraces, ~] = dropBadTraces(allTraces, baseStartT, baseEndT,...
                                          tailLength, sFreq);
zeroedTraces = zeroTraces(filteredTraces, baseStartT, baseEndT, sFreq);


t = zeroedTraces.time;

%% fit each trace in zeroedTraces

% Create a table to store decay info
decayInfo = array2table(zeros(width(zeroedTraces)-2,8), ...
                        'VariableNames',{'I_0','I_0 lowLim','I_0 upLim',...
                                         'tau','tau lowLim','tau upLim',...
                                         'r^2','nObs'});   
for i = 3:width(zeroedTraces)
    trace = zeroedTraces{:, i};
    % Get peak location
    %   In case more than 1 peak are found, take the first one
    peakIdx = find(t == findPeaks(trace, t, sFreq), 1, 'first');
    window = t(peakIdx:end) - t(peakIdx);  % set t=0 at peak time
    % Fit decay to first order exponential function
    % I = I_0*exp(-t/tau), where I_0 is initial current
    [xfit, gof, info] = fit(window,trace(peakIdx:end),'exp1',opt);

    CI = confint(xfit, 0.95);  % 95% confidence intervals
    results = [xfit.a, ...               % I_0
               CI(1,1),CI(2,1), ...      % lower and upper CI limit for I_0
               -1/xfit.b, ...            % tau
               -1/CI(1,2),-1/CI(2,2),... % lower and upper CI limit for tau
               gof.rsquare,info.numobs]; % r^2 and number of observations
    decayInfo(i-2,:) = array2table(results);
end
decayInfo(decayInfo.I_0 > I_0Thres,:) = [];
decayInfo(decayInfo.tau < tauThres,:) = [];
% decayInfo(decayInfo.('r^2') < 0.5, :) = [];

end
