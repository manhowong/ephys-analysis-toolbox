function medCDF = plotBootstrapData_gamma(group,newFig,rgbColor, inputDir)
%% Plot left-truncated gamma CDF for bootstrap data of amplitude.

% Input
%   group: name of the group of recordings
%   newPlot: create new figure if it's 1; plot on current figure if it's 0
%   rgbColor: RGB color code of the plot; must be an array of 3 numbers

% Output
%   Plot of exponential CDF with median (solid line) and CI (shaded patch).

% Note
%   To plot subsequent groups on the same figure, keep current figure
%   window open. Set newFig to 0 and run the code for each group.

% Example
%   plotBootstrapData_gamma('control',1,[1 1 0.5])

%% Load CDF X-/Y-coordinate values

inputFile = ['/cdfParamsAndXyValues_' char(group) '.mat'];
if ~isfile([inputDir inputFile])
    fprintf(['''%s%s'' not found.\nPlease check if the path is correct' ...
             ' or run CDF fitting again.\n'],inputDir,inputFile);
    return;
end

load([inputDir inputFile],'outcdf','x');

%% Plot cdf

if newFig == 1
    figure;
end
hold on;

% Show figure window even when the fucntion is called in live script
set(gcf,'Visible','on');

% plot median of cdf
medCDF = plot(x,outcdf(2,:),'DisplayName',string(group),'Color',rgbColor);

%plot CI of cdf as patches
valX = [x,fliplr(x)];
valY = [outcdf(3,:), fliplr(outcdf(1,:))];
ci = hggroup;   % Create a group for CI patches
                % (this group of objects can then be excluded from legend easily)
patch(valX,valY,1,'Parent',ci,'FaceColor',rgbColor,'EdgeColor','none');
alpha(.2);      % make patch transparent

ylim([0 1]);
xlabel('Amplitude (-pA)');
ylabel('Gamma CDF');
legend(gca);       % Legend includes only direct children of current axis, no CI patch
legend("boxoff");  % Remove legend box
hold off;

end


