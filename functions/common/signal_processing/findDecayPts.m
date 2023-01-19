function [peakIdx,decayStartIdx,decayEndIdx,endReached] = ...
                                    findDecayPts(trace, settings)
%% Find indices for the peak, and the start and end point of the decay.
% This function find the nearest points to the target start/end point of
% the decay (e.g. 100% and 10% of peak). If the target start/end points are
% set to 100% and 0%, the start point will be the peak location and the end
% point will be the last point of the trace. The function also test if the
% decay reached the target end point (see comment in code).
% Man Ho Wong, University of Pittsburgh, 2023-01-18
% -------------------------------------------------------------------------
% Input: - trace : an 1D array of amplitudes (*filtered by dropBadTraces.m)
%        - settings : a struct containing following fields
%          - settings.baseStartT : baseline start time, ms
%          - settings.baseEndT : baseline end time, ms
%          - settings.tailLength : tail (end of trace) length, ms
%          - settings.decayStart : decay start point, %peak
%          - settings.decayEnd : decay end point, %peak
%          - settings.sFreq : sampling frequency, Hz
%            WARNING: If you are using a narrow decay window for mEPSC
%                     decay, the script cannot find a decay window long
%                     enough for good fitting (this is due to the short
%                     duration of mEPSCs and relatively low signal-to-noise
%                     ratio). You may receive an "insufficent data" error.
%                     To avoid the error, use broader decay window for
%                     mEPSCs (especially for noisy data).
% -------------------------------------------------------------------------
% Output: - peakIdx : index of peak
%         - decayStartIdx : index of nearest point to target start point
%         - decayEndIdx : index of nearest point to target end point
%         - endReached : 0 if decay did not reach target end point;
%                        1 if reached
%
% See comments in the code for more info.

%% Recording properties
baseStartT = settings.baseStartT;  % baseline start time, ms
baseEndT = settings.baseEndT;      % baseline length, ms
tailLength = settings.tailLength;  % tail (end of trace) length, ms
decayStart = settings.decayStart;  % decay start point, % peak
decayEnd = settings.decayEnd;      % decay end point, % peak
sFreq = settings.sFreq;            % sampling frequency, Hz

baseStartPt = sFreq*baseStartT/1000 + 1; % Get baseline locations
baseEndPt = sFreq*baseEndT/1000 + 1;     % Get baseline locations

%% Find peak location

% peak is the minimum point
% in case there are more than 1 minimum point, get the first one
peakIdx = find(trace==min(trace), 1 , 'first');

% Alternatively, find peak of smoothed trace (see findPeaks.m)
%       For this method, add t as an input argument of the function:
%       t : an 1D array of time stamps for every point in trace; unit: s
% peakIdx = find(t == findPeaks(trace, t, sFreq), 1, 'first');

%% Find decay phase start point

if decayStart == 1
    decayStartIdx = peakIdx;
else
    % Theoretical amplitude at decay phase start point
    targetStartAmpl = trace(peakIdx)*decayStart;
    % Find nearest position of decay phase start point
    [~, relativeIdx] = min(abs(avgThreePts(trace(peakIdx:end))-targetStartAmpl));
    decayStartIdx = relativeIdx + (peakIdx - 1);
end

%% Find decay phase end point

if decayEnd == 0
    decayEndIdx = length(trace);
    endReached = true;
else
    % Theoretical amplitude at decay phase end point
    targetEndAmpl   = trace(peakIdx)*decayEnd;
    % Find nearest position of decay phase end point
    [~, relativeIdx] = min(abs(avgThreePts(trace(peakIdx:end))-targetEndAmpl));
    decayEndIdx   = relativeIdx + (peakIdx - 1);

    % Check if decay reached targetEndAmpl
    nearestEndAmpl = trace(decayEndIdx);  % amplitude nearest to targetEndAmpl
    % max. background noise (i.e. max. absolute baseline ampl.) as threshold
    detectThreshold = max(abs(trace(baseStartPt:baseEndPt)));
    endReached = true;
    if nearestEndAmpl < targetEndAmpl & ...
        diff([nearestEndAmpl,targetEndAmpl]) > detectThreshold
        endReached = false;
    end
end



