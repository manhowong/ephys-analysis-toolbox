% This is a template for plotting bar charts and cdfs as different panels
% on the same figure. The add-on GRAMM is required. For more info, see
% GRAMM's documentation.
% Example: naiveVsCtrl53u.fig

%% Define panels in the 1st row of the figure

% Create a "gramm" object and put your data in it so this add-on can
% process the data.
% g is the name of the "gramm" object here. Indices of g indicate in which row
% and column the panels will be plotted. e.g. If you put your data in
% g(1,1), the panels will be plotted in row 1, column 1.
% For input arguments and data structure, please see the documentation for
% gramm().
g(1,1)=gramm('x',cellstr(inputFreq.condition),'y',inputFreq.data,...
    'color',cellstr(inputFreq.condition)); % cellstr to convert input data
                                            % to cells of string

% Sort data into two groups according to sexes and create two columns in
% the first row, each will contain a panel for one sex.
g(1,1).facet_grid([],cellstr(inputFreq.sex));

% Set panel title, axis titles, column title/ legend title (not
% applicable here) and tick length.
g(1,1).set_title('Frequency');
g(1,1).set_names('x','','y','Frequency (Hz)','color','','column','');
g(1,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:2:max(inputFreq.data)]);

% By default, variables are sorted by alphabetical/ascending order. The
% function allows user to change the order.
g(1,1).set_order_options("column",["m" "f"]);

% Set the color map (i.e. color scheme for different groups).
g(1,1).set_color_options('map',[0 0 0;0.6 0.6 0.6]);

% Set the relative position and size of the panels in the 1st row.
% [distanceFromLeft distanceFromBottom width height]
g(1,1).set_layout_options("position",[0.02 0.75 0.86 0.25],"legend",0);

% Indicate that jittered datapoints will be plotted.
g(1,1).geom_jitter();

% Calculate the average and sem and specify how these will be plotted (e.g. bar).
g(1,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);

%% Define panels in the 2nd row of the figure

g(2,1)=gramm('x',inputFreq.data,'color',cellstr(inputFreq.condition));
g(2,1).facet_grid([],cellstr(inputFreq.sex),"column_labels",0);
g(2,1).set_names('x','Frequency (Hz)','color','','column','');
g(2,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(2,1).set_order_options("column",["m" "f"]);
g(2,1).set_color_options('map',[0 0 0;0.6 0.6 0.6]);
g(2,1).stat_bin('normalization','cdf','geom','stairs');

%% Define panels in the 3rd row of the figure

g(3,1)=gramm('x',cellstr(inputAmpl.condition),'y',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(3,1).facet_grid([],cellstr(inputAmpl.sex));
g(3,1).set_title('Amplitude');
g(3,1).set_names('x','','y','Amplitude (-pA)','color','','column','');
g(3,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:5:max(inputAmpl.data)]);
g(3,1).set_order_options("column",["m" "f"]);
g(3,1).set_color_options('map',[0 0 0;0.6 0.6 0.6]);
g(3,1).set_layout_options("position",[0.01 0.25 0.87 0.25],"legend",0);
g(3,1).geom_jitter();
g(3,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);

%% Define panels in the last row of the figure

g(4,1)=gramm('x',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(4,1).facet_grid([],cellstr(inputAmpl.sex),"column_labels",0);
g(4,1).set_names('x','Amplitude (-pA)','color','','column','');
g(4,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(4,1).set_order_options("column",["m" "f"]);
g(4,1).set_color_options('map',[0 0 0;0.6 0.6 0.6]);
g(4,1).stat_bin('normalization','cdf','geom','stairs');

%% Plot all the panels on the same figure

figure('Position',[1000 100 500 800]); % create a figure and specify the position/size
g.draw();                              % Draw all the panels