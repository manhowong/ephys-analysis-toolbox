function plotBootstrapData_exp(group,newFig,rgbColor)
% plotBootstrapData_exp: Plot exponential CDF for bootstrap data of IEI.

% Input
%   group: name of the group of recordings
%   newPlot: create new figure if it's 1; plot on current figure if it's 0
%   rgbColor: RGB color code of the plot; must be an array of 3 numbers

% Output
%   Plot of exponential CDF with median (solid line) and CI (shaded patch).

% Example
%   plotBootstrapData_exp('control',1,[1 1 0.5])

%% Load CDF X-/Y-coordinate values

inputDir = ['analysis/exponFitting_bootstrap/'];
inputFile = ['cdfParamsAndXyValues_' char(group) '.mat'];

if ~isfile([inputDir inputFile])
    fprintf(['''%s%s'' does not exist!\nPlease bootstrap ' ...
        'the selected group first. Use analyzeMini.mlx or ' ...
        'the function bootstrapExp().\n'],inputDir,inputFile);
    return;
end

load([inputDir inputFile],'outcdf','y');

%% Plot cdf

if newFig == 1
   figure;
end
hold on;

% Show figure window even when the fucntion is called in live script
set(gcf,'Visible','on');

% plot median of cdf
plot(y,outcdf(2,:),'DisplayName',string(group),'Color',rgbColor);

%plot CI of cdf as patches
valX = [y,fliplr(y)];
valY = [outcdf(3,:), fliplr(outcdf(1,:))];
ci = hggroup;   % Create a group for CI patches
                % (this group of objects can then be excluded from legend easily)
patch(valX,valY,1,'Parent',ci,'FaceColor',rgbColor,'EdgeColor','none');
alpha(.2);      % make patch transparent

ylim([0 1]);
xlabel('IEI (ms)');
ylabel('Exponential CDF');
legend(gca);       % Legend includes only direct children of current axis, no CI patch
legend("boxoff");  % Remove legend box
hold off;
end


