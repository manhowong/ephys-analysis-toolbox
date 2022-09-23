function [peaks, smoothTrace, g] = findPeaks(trace,t,sFreq)
%% This function detects approx. positions of downward peaks in a trace.
% Man Ho Wong, University of Pittsburgh, 2022-05-25
% -------------------------------------------------------------------------
% Inputs: - trace : a column vector of amplitudes
%         - t : a column vector of time points, ms
%         - sFreq : sampling frequency, kHz
% *trace and t must have the same length!
% -------------------------------------------------------------------------
% Outputs: - peaks : a column vector of peak locations, ms
%          - smoothTrace : a column vector of amplitudes of smoothed trace
%          - g : a column vector of gradients (slope at each sampling pt.)
% -------------------------------------------------------------------------
% Tip: It is easier to test this function by running ../tools/plotPeaks.m

%% User settings

riseThres = -2;  % Threshold for peak gradient in rising phase,
                 %   e.g. -2 pA/ms (negative sign for downward peak)
decayThres = 0.5;  % Threshold for gradient at early decay, e.g. 0.5 pA/ms
peakThres = 5;  % Threshold for ABSOLUTE peak current of smooth trace,
                %   e.g. 5 pA
decayCheckLength = 1;  % Period after peak to check decay gradient, eg. 1 ms

%% Compute gradients

timePerPt = 1/sFreq*1000;    % time duration per sampling point, ms
decayCheckPt = sFreq*decayCheckLength/1000;  % Sampling point equivalent to decayLength
smoothWindow = sFreq*3/1000;  % Window for smoothing the trace/gradients

% smooth trace as the theoretical signal without noise
smoothTrace = smoothdata(trace, "sgolay", smoothWindow);

% get gradient of each sampling point and correct for time
g = gradient(smoothTrace)/timePerPt;

% smooth gradients
g = smoothdata(g, "sgolay", smoothWindow);

% get signs (i.e. directions) of gradients
signs = sign(g);  

%% Find peaks (i.e. where gradients switch direction)

% Find gradient switching points (where sign switches)
%   and check if they are peaks
peaks = [];
prevSwitchPt = 1;  % keep track of previous switching point
for i = 1:length(signs)-1
    if (signs(i) - signs(i+1)) ~= 0  % check for if sign switches
        currSwitchPt = i;
        % Get position of peak gradient in rising phase (which should be
        %   between two current and previous switching points)
        PeakRisePt = find(g==min(g(prevSwitchPt : currSwitchPt)),1);
        % Set baseline check point (approximate point where event starts)
        baseCheckPt = currSwitchPt - 2*(currSwitchPt-PeakRisePt);
        % decide if the switching point is a peak:
        if baseCheckPt > 0 &&...  % prevent index exceeding range
           currSwitchPt > baseCheckPt &&...  % prevent index exceeding range
           currSwitchPt <= length(signs)-decayCheckPt &&...  % prevent index exceeding range
           g(PeakRisePt) <= riseThres &&...  % peak rise gradient must pass riseThres
           max(g(currSwitchPt : currSwitchPt+decayCheckPt)) >= decayThres &&...  % early decay gradient must pass decayThres
           max(abs(smoothTrace(currSwitchPt) - smoothTrace(baseCheckPt:currSwitchPt))) >= peakThres  % peak current must pass peakThres
            peaks = [peaks;t(currSwitchPt)];  % keep track of peaks found
        end
        prevSwitchPt = currSwitchPt;  % keep track of prevSwitchPt
    end    
end
end