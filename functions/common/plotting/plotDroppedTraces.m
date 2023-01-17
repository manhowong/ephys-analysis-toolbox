function fig = plotDroppedTraces(fname, allTraces, filteredTraces, dropped)
%% Plot dropped traces for visual inspection.
% Run dropBadTraces.m first to get the table "filteredTraces" and the list
% "dropped" (see below).
% Man Ho Wong, University of Pittsburgh, 2022-04-11
% -------------------------------------------------------------------------
% Inputs: - fname : file name
%         - allTraces : traces of a recording; imported into MATLAB by
%                       importTraces.m and zeroed by zeroTraces.m
%         - filteredTraces : traces filtered by dropBadTraces.m
%         - dropped : a list of traces dropped by dropBadTraces.m
% -------------------------------------------------------------------------
% Outputs: - figure

%% Plot traces before and after dropping

fig = figure;
hold on;

droppedTraces = plot(allTraces.time,allTraces{:,dropped}, Color = 'r');
remainTraces = plot(allTraces.time,filteredTraces{:,3:end}, Color = [.7 .7 .7]);
avgLine = plot(allTraces.time,filteredTraces.avgTrace,color='k');

% Figure settings
title(fname, 'Interpreter', 'none');            % keep underscore in title
xlabel('Time (ms)');                            % x-axis title
ylabel('Current amplitude (pA)');               % y-axis title
xlim([0 max(allTraces.time)]);                  % x-axis range equals trace
set(gca,'TickDir','out');                       % axis ticks direction
legend([droppedTraces(1), remainTraces(1), avgLine], ...
       {'Dropped traces', 'Remaining traces', 'Average trace'}, ...
       Location='southeast');                   % legend
legend boxoff;

end