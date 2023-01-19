function decayInfo = fitDecay(fname, tracesDir, settings)
%% Fit each mEPSC event in a file with first order exponential function.
% This function fits one recording at a time. You can call this function
% directly, or use the script runFitDecay.m to run it automatically on
% multiple recordings.
% Man Ho Wong, University of Pittsburgh, 2022-04-04
% -------------------------------------------------------------------------
% File needed: Aligned traces (.txt)
%              - See instructions in ../../resources/prepare_data.md
%              - See examples in: ../../demo_data/event_trace/
% -------------------------------------------------------------------------
% Input: - fname : file name of recording
%        - tracesDir : directory of aligned traces files (must end in '/')
%        - settings : a struct containing following fields
%          - settings.baseStartT : baseline start time, ms
%          - settings.baseEndT : baseline end time, ms
%          - settings.tailLength : tail (end of trace) length, ms
%          - settings.decayStart : decay start point, %peak
%          - settings.decayEnd : decay end point, %peak
%            WARNING: If you are using a narrow decay window for mEPSC
%                     decay, the script cannot find a decay window long
%                     enough for good fitting (this is due to the short
%                     duration of mEPSCs and relatively low signal-to-noise
%                     ratio). You may receive an "insufficent data" error.
%                     To avoid the error, use broader decay window for
%                     mEPSCs (especially for noisy data).
% -------------------------------------------------------------------------
% Output: - decayInfo : a table containing fitted parameters of each event
%           - I_0 : initial amplitude
%           - I_0 lowLim, I_0 upLim : lower and upper CI limit for I_0
%           - tau : initial amplitude
%           - tau lowLim, tau upLim : lower and upper CI limit for tau
%           - r^2 : R-squared
%           - nObs : number of observations
%
% See comments in the code for more info.
%% Recording properties

baseStartT = settings.baseStartT;  % baseline start time, ms
baseEndT = settings.baseEndT;      % baseline length, ms
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

settings.sFreq = sFreq; % add sFreq to settings

%% Drop funky traces and traces with more than one event

% zero every trace first before dropping bad traces:
% Each trace is shifted by its own baseline's mean value.
allTraces = zeroTraces(allTraces, baseStartT, baseEndT, sFreq);

[filteredTraces, ~] = dropBadTraces(allTraces, baseStartT, baseEndT,...
                                          tailLength, sFreq);


%% fit each trace in zeroedTraces

% Create a table to store decay info
decayInfo = array2table(zeros(width(filteredTraces)-2,8), ...
                        'VariableNames',{'I_0','I_0 lowLim','I_0 upLim',...
                                         'tau','tau lowLim','tau upLim',...
                                         'r^2','nObs'});
% time points
t = filteredTraces.time;

for i = 3:width(filteredTraces)
    trace = filteredTraces{:, i};
    [peakIdx, decayStartIdx, decayEndIdx, ~] = findDecayPts(trace,settings);
    % Get decay window and shift window so that t=0 equals decay start point
    window = t(decayStartIdx:decayEndIdx) - t(peakIdx);
    % Fit decay to first order exponential function
    % I = I_0*exp(-t/tau), where I_0 is initial current
    [xfit, gof, info] = fit(window,trace(decayStartIdx:decayEndIdx),'exp1',opt);
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
