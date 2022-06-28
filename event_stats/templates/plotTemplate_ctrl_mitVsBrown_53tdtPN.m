% This is a template for plotting bar charts and cdfs as different panels
% on the same figure. The add-on GRAMM is required. For more info, see
% GRAMM's documentation.
% Example: ctrl_mitVsBrown_53tdtPN.fig

%% Group data according to both condition and cell type
inputFreq.group = inputFreq.cellType(:,1)+'-'+inputFreq.condition(:,1);
inputAmpl.group = inputAmpl.cellType(:,1)+'-'+inputAmpl.condition(:,1);

%% Define panels in the 1st row of the figure

% Create a "gramm" object and put your data in it so this add-on can
% process the data.
% g is the name of the "gramm" object here. Indices of g indicate in which row
% and column the panels will be plotted. e.g. If you put your data in
% g(1,1), the panels will be plotted in row 1, column 1.
% For input arguments and data structure, please see the documentation for
% gramm().
g(1,1)=gramm('x',cellstr(inputFreq.cellType),'y',inputFreq.data,...
    'color',cellstr(inputFreq.group)); % cellstr to convert input data
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
g(1,1).set_order_options("column",["m" "f"],"color",...
    ["tdtN-ctrl" "tdtN-naive" "tdtP-ctrl" "tdtP-naive"]);

% Set the color map (i.e. color scheme for different groups).
g(1,1).set_color_options('map',[0.3 1 0.8;0.7 1 0.9;1 0 0.7;1 0.6 0.9]);

% Indicate that jittered datapoints will be plotted.
g(1,1).geom_jitter('dodge',1.7);

% Calculate the average and sem and specify how these will be plotted (e.g. bar).
g(1,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1.5,'dodge',1.7);

%% Define panels in the 2nd row of the figure

g(2,1)=gramm('x',inputFreq.data,'color',cellstr(inputFreq.group));
g(2,1).facet_grid([],cellstr(inputFreq.sex),"column_labels",0);
g(2,1).set_names('x','Frequency (Hz)','color','','column','');
g(2,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(2,1).set_order_options("column",["m" "f"],"color",...
    ["tdtN-ctrl" "tdtN-naive" "tdtP-ctrl" "tdtP-naive"]);
g(2,1).set_color_options('map',[0.3 1 0.8;0.7 1 0.9;1 0 0.7;1 0.6 0.9]);
g(2,1).stat_bin('normalization','cdf','geom','stairs');

%% Define panels in the 3rd row of the figure

g(3,1)=gramm('x',cellstr(inputAmpl.cellType),'y',inputAmpl.data,...
    'color',cellstr(inputFreq.group));
g(3,1).facet_grid([],cellstr(inputAmpl.sex));
g(3,1).set_title('Amplitude');
g(3,1).set_names('x','','y','Amplitude (-pA)','color','','column','');
g(3,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:5:max(inputAmpl.data)]);
g(3,1).set_order_options("column",["m" "f"],"color",...
    ["tdtN-ctrl" "tdtN-naive" "tdtP-ctrl" "tdtP-naive"]);
g(3,1).set_color_options('map',[0.4 1 0.3;0.8 1 0.7;0.7 0 1;0.8 0.7 1]);
g(3,1).geom_jitter('dodge',1.7);
g(3,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1.5,'dodge',1.7);

%% Define panels in the last row of the figure

g(4,1)=gramm('x',inputAmpl.data,'color',cellstr(inputAmpl.group));
g(4,1).facet_grid([],cellstr(inputAmpl.sex),"column_labels",0);
g(4,1).set_names('x','Amplitude (-pA)','color','','column','');
g(4,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(4,1).set_order_options("column",["m" "f"],"color",...
    ["tdtN-ctrl" "tdtN-naive" "tdtP-ctrl" "tdtP-naive"]);
g(4,1).set_color_options('map',[0.4 1 0.3;0.8 1 0.9;1 0 0.7;1 0.6 0.9]);
g(4,1).stat_bin('normalization','cdf','geom','stairs');

%% Plot all the panels on the same figure

figure('Position',[1000 100 500 800]); % create a figure and specify the position/size
g.draw();                              % Draw all the panels