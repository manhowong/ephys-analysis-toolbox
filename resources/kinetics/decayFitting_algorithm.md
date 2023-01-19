# Event decay fitting

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.

This page documents the algorithm of decay fitting, which is implemented through the function [`fitDecay.m`](../../functions/kinetics/fitDecay.m).

```


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
    %   In case more than 1 peak point are found, take the first point
    peakIdx = find(t == findPeaks(trace, t, sFreq), 1, 'first');
    % Get decay window and shift window so that t=0 equals decay start point
    window = t(peakIdx:end) - t(peakIdx);
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
```

---

# Procedures

## 1. Read traces from file

## 2. Remove noisy/ unstable traces and traces with overlapping events

NSFA is sensitive to noise and signal stability as amplitude fluctuation is being analyzed To control data quality, traces are removed from the analysis if one of the following criteria is matched:
1. The amplitude of a trace's tail falls outside a user-defined range (relative to the average trace). This indicates unstable recording.
2. The baseline falls outside a user-defined range (relative to the trace tail). This indicates unstable recording.
3. The event in the trace does not pass the detection thresholds or the trace has more than one event (i.e. overlapping events).
4. The peak occurs 1 ms or later after the average peak.

Event peaks in each trace are detected automatically as follows:
The trace is first smoothed to reduce noise. (Instead of smoothing, noise can also be removed by filters but it is probably less efficient and unnecessary for the purpose of peak detection.) The first derivative (gradient) at each time point of the smoothed trace is then computed. At a zero-crossing where the sign of gradient switches (e.g. for downward peaks, sign switches from negative to positive), if the rise gradient and the decay gradient surround the zero-crossing pass the gradient thresholds, and the amplitude passes the amplitude threshold, the zero-crossing will be detected as an event peak.