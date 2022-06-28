% This is a template for plotting bar charts and cdfs as different panels
% on the same figure. The add-on GRAMM is required. For more info, see
% GRAMM's documentation.
% Example: Unch_vs_Ch_53u.fig
% 2021-12-14, Man Ho Wong

%% Define panels in the 1st row of the figure

% Create a "gramm" object and put your data in it so this add-on can
% process the data.
    % g is the name of the "gramm" object here. Indices of g indicate in
    % which row and column the panels will be plotted. e.g. If you put your
    % data in g(1,1), the panels will be plotted in row 1, column 1.
    % For input arguments and data structure, please see the documentation
    % for gramm().
g(1,1)=gramm('x',cellstr(inputFreq.cellType),'y',inputFreq.data,...
    'color',cellstr(inputFreq.cellType)); % cellstr to convert input data
                                            % to cells of string

% Sort data into two groups according to conditions and create two 
% subcolumns, each will contain a panel for each condition.
g(1,1).facet_grid([],cellstr(inputFreq.condition));

% Set panel title, axis titles, column title/ legend title (not
% applicable here) and tick length.
g(1,1).set_names('x','','y','Frequency (Hz)','color','','column','');
g(1,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:2:max(inputFreq.data)]);

% Set the color map (i.e. color scheme for different groups).
g(1,1).set_color_options('map',[0 .5 0;.5 .5 .5;1 .5 .5;1 0 0;0 0 0]);

% Change x-axis data order
g(1,1).set_order_options("x",["unmarked","tdtP","tdtN","tdtP-pitt","gfpP-pitt"]);

% Indicate that jittered datapoints will be plotted.
g(1,1).geom_jitter();

% Calculate the average and sem and specify how these will be plotted (e.g. bar or boxplot).
%g(1,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(1,1).stat_boxplot('width',3);

g(1,1).set_title('mEPSC Frequency - Adult');

%% Define panels in the 2nd row of the figure

g(2,1)=gramm('x',inputFreq.data,'color',cellstr(inputFreq.cellType));
g(2,1).facet_grid([],cellstr(inputFreq.condition),"column_labels",0);
g(2,1).set_names('x','Frequency (Hz)','y','Normalized CDF','color','','column','');
g(2,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(2,1).set_color_options('map',[0 .5 0;.5 .5 .5;1 .5 .5;1 0 0;0 0 0]);
g(2,1).stat_bin('normalization','cdf','geom','stairs');



%% Define panels in the 3rd row of the figure

g(3,1)=gramm('x',cellstr(inputAmpl.cellType),'y',inputAmpl.data,'color',cellstr(inputAmpl.cellType));
g(3,1).facet_grid([],cellstr(inputAmpl.condition));
g(3,1).set_names('x','','y','Amplitude (-pA)','color','','column','');
g(3,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:5:max(inputAmpl.data)]);
g(3,1).set_color_options('map',[0 .5 0;.5 .5 .5;1 .5 .5;1 0 0;0 0 0]);
g(3,1).set_order_options("x",["unmarked","tdtP","tdtN","tdtP-pitt","gfpP-pitt"]);
g(3,1).geom_jitter();
%g(3,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(3,1).stat_boxplot('width',3);
g(3,1).set_title('mEPSC amplitude - Adult');

%% Define panels in the last row of the figure

g(4,1)=gramm('x',inputAmpl.data,'color',cellstr(inputAmpl.cellType));
g(4,1).facet_grid([],cellstr(inputAmpl.condition),"column_labels",0);
g(4,1).set_names('x','Amplitude (-pA)','y','Normalized CDF','color','','column','');
g(4,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(4,1).set_color_options('map',[0 .5 0;.5 .5 .5;1 .5 .5;1 0 0;0 0 0]);
g(4,1).stat_bin('normalization','cdf','geom','stairs');

%% Plot all the panels on the same figure

figure('Position',[1000 0 640 1000]); % create a figure and specify the position/size
g.draw();                              % Draw all the panels
clear g;                               % clear the gramm object to prevent
                                       % errors when plotting next figure

%% Adjust figure properties

% remove boxplot face color
h = findobj('FaceAlpha',1);     % all boxplot objects share this property
set(h,'FaceColor','none','edgeColor','k');

% Change filled markers to open markers
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(h,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[0 .5 0]);
set(h,'MarkerEdgeColor',[0 .5 0],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5]);
set(h,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[1 .5 .5]);
set(h,'MarkerEdgeColor',[1 .5 .5],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);
set(h,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none');



