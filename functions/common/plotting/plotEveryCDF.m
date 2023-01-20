function plotEveryCDF(newFig, color, cdfFile)
%% Plot CDF of every recording in a group instead of the group median CDF.
% This function takes CDF data from ieistats_all.mat or gammastats_all.mat.
% If you want to plot the median CDF of a group, use plotGroupCDF.m instead.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - newFig : set 1 to create new figure; 0 to plot on current figure
%        - color : RGB color code of the plot; e.g. [1 0 0] for red
%        - cdfFile : path to ieistats_all.mat or gammastats_all.mat
% Output: figure
% Example:
% plotEveryCDF(1, [0 0 1], 'path/to/ieistats_all.mat')
%% Load CDF data

if ~isfile(cdfFile)
    fprintf(['''%s'' not found.\nPlease check if the path is correct' ...
             ' or run CDF fitting again.\n'],cdfFile);
    return;
end

load(cdfFile);
%% plot CDF for each recordings

x=0:0.01:100;
if newFig == 1
    figure;
end
hold on;

for f=1:height(allparams)
    % Fit gamma model
    alpha=allparams(f,1);
    beta=allparams(f,3);
    xTrunc=allxTrunc(f);
    currcdf=gamcdf(x,alpha,beta);
    truncval=max(currcdf(x<xTrunc));
    currcdf=currcdf-truncval;
    currcdf(currcdf<0)=0;
    currcdf=currcdf/(1-truncval);
    plot(x,currcdf,Color=color);
end

end
