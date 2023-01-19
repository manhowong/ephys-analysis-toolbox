function [filteredTraces, dropped] = dropBadTraces(allTraces,baseStartT,...
                                                   baseEndT,tailLength,...
                                                   sFreq)
%% Drop bad traces that are not suited for NSFA/ decay fitting.
% Criteria of a bad trace:
%   1 Trace tail falls outside a user-defined range (relative to the
%     average trace). This indicates unstable recording.
%   2 Trace baseline falls outside a user-defined range (relative to the
%     trace tail). This indicates unstable recording.
%   3 Trace has no detectable events or has more than one event.
%   4 The peak occurs 1 ms or later after the average peak.
% The algorithm first drops traces matching criteria 1 to 3, then updates 
% the average trace, and lastly drops traces matching criteria 4 and
% updates the average trace again.
% Man Ho Wong, University of Pittsburgh, 2022-04-18
% -------------------------------------------------------------------------
% Inputs: - allTraces : traces of a recording; imported into MATLAB by
%                       importTraces.m and zeroed by zeroTraces.m
%         - baseStartT : baseline start time, ms
%         - baseEndT : baseline end time, ms
%         - tailLength : tail (end of trace) length, ms
%         - sFreq : sampling frequency, Hz
% -------------------------------------------------------------------------
% Outputs: - filteredTraces : allTraces with bad traces removed and
%                             average trace updated
%          - dropped : a list of traces dropped by the function
% -------------------------------------------------------------------------
% Tip: To visually inspect dropped traces, run this function first and then
%      run ../plotting/plotPeaks.m

%% User settings

% Set threshold range relative to the average trace (multiple of S.D.)
%   e.g. to exclude traces outside +/- 1 SD of average, set thres to 1.
thres = 1;  % 1 is recommended

%% Get baseline/tail positions and compute tail S.D.

baseStartPt = sFreq*baseStartT/1000 + 1;
baseEndPt = sFreq*baseEndT/1000 + 1;
tailStartPt = height(allTraces) - sFreq*tailLength/1000;
tailSD = std(mean(allTraces{tailStartPt:end, 3:end}));

%% Filter 1: drop unstable traces and traces with 0 or multiple events

% Screen for bad traces
toDrop = [];  % IDs (not indices!) of traces to be dropped
for i = 3:width(allTraces)
    traceBase = mean(allTraces{baseStartPt:baseEndPt, i});
    traceTail = mean(allTraces{tailStartPt:end, i});
    nPeaks = length(findPeaks(allTraces{:,i},allTraces.time,sFreq));
    if abs(traceTail) >= thres*tailSD ...  % check tail stability
       || abs(traceBase) >= thres*tailSD ...  % check if baseline and tail are within reasonable range
       || nPeaks ~= 1  % check if there are 0 or multiple events
        toDrop = [toDrop; allTraces.Properties.VariableNames(i)];
    end
end

% Drop bad traces detected above
filteredTraces = removevars(allTraces, toDrop);

% Keep track of traces dropped above (list of IDs of dropped traces)
dropped = toDrop;

%%  Update avgTrace and get avgTrace's peak time

filteredTraces.avgTrace = mean(filteredTraces{:, 3:end}, 2);
avgPeak = min(filteredTraces.avgTrace);
avgPeakIdx = find(filteredTraces.avgTrace == avgPeak);
avgPeakT = filteredTraces.time(avgPeakIdx);

%% Filter 2: drop traces with peak occurring >= 1 ms later than average peak

% Screen for bad traces
toDrop = [];  % IDs (not indices!) of traces to be dropped
for i = 3:width(filteredTraces)
    peak = findPeaks(filteredTraces{:,i},filteredTraces.time,sFreq);
    if peak >= avgPeakT + 1
        toDrop = [toDrop; filteredTraces.Properties.VariableNames(i)];
    end
end

% Drop bad traces detected above and update avgTrace
filteredTraces = removevars(filteredTraces, toDrop);
filteredTraces.avgTrace = mean(filteredTraces{:, 3:end}, 2);

% Keep track of all traces dropped (list of IDs of dropped traces)
dropped = [dropped; toDrop];
end