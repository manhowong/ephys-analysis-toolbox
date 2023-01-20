function fig = plotPeaks(trace,t,sFreq)
%% Plot individual trace and its peak(s) for visual inspection.
% This function calls findPeaks() to get the peak time, smoothed trace and
% gradients (i.e. slopes at each sampling point). 
% Man Ho Wong, University of Pittsburgh, 2022-05-25
% -------------------------------------------------------------------------
% Inputs: - trace : a column vector of amplitudes
%         - t : a column vector of time points, ms
%         - sFreq : sampling frequency, Hz
% *trace and t must have the same length!
% -------------------------------------------------------------------------
% Outputs: - figure

%% Get peak time, smoothed trace and gradients
[peaks, smoothTrace, g] = findPeaks(trace,t,sFreq);

%% Plot
fig = figure();
hold on

% Plot trace and smoothTrace
plot(t,trace, Color=[.7 .7 .7]);
plot(t,smoothTrace, Color='k');
xlim([0 t(end)]);  % set x-axis length to trace length
xlabel('Time (ms)');
ylabel('Current amplitude (pA)');

% Plot gradients on right y-axis
yyaxis right  % add right y-axis
yline(0);
plot(t,g, Color='g');
ylabel('Gradient (pA/ms)');
ax = gca;
ax.YAxis(2).Color = 'k';  % set right y-axis color to black

% link ylim of left and right y-axis (works for scrolliing on fig as well)
linkprop([ax.YAxis(1) ax.YAxis(2)],'Limits');

% Set legend
if ~isempty(peaks)
    xline(peaks,'--');
    legend({'Raw trace','Smoothed trace','','Gradient','Peak location'}, Location="best");
else
    legend({'Raw trace','Smoothed trace','','Gradient'}, Location="best");
end
legend boxoff
hold off

end