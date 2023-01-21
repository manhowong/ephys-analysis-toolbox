function fig = plotTransient(tp,transient,t)
%% Plot a capacitance transient trace and the test pulse.
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% Input: - tp : test pulse trace, mV 
%        - transient : capacitance transient trace, pA
%        - t : a column vector of time points, ms
% *transient and t must have the same length!
% -------------------------------------------------------------------------
% Output: - figure with test pulse in upper panel and capacitance transient
%           in lower panel
% Example:
% tp = [zeros(1000,1);ones(2000,1)*-5;zeros(1000,1)];    % -5 mV test pulse
% allTransients = readmatrix('path/to/transient file'); 
% transient = allTransients(:,3);              % plot third transient trace
% t = 0:1/sFreq*1000:199.95;                   % time points
% transient = transients(:,3);
% plotTransient(tp,transient,t);

%% Plot
fig = figure();
tiledlayout(3,1,"TileSpacing","tight","Padding","tight");

% Plot test pulse
nexttile
plot(t,tp, Color='g',LineWidth=1);

% Figure settings
ylim([min(tp) max(tp)]);
yticks([min(tp) max(tp)]);
ylabel('mV');
ax = gca;
ax.XAxis.Visible = 'off';
set(ax,'box','off');
title('Test pulse');

% Plot transient trace
nexttile([2 1]);
plot(t,transient, Color='b',LineWidth=0.8);

% Figure settings
yline(0, 'Color',[.5 .5 .5]);  % zero line
xlim([0 t(end)]);  % set x-axis length to transient length
xlabel('Time (ms)');
ylabel('pA');
ax = gca;
set(ax,'box','off');
title('Capacitance transient');

legend off

end