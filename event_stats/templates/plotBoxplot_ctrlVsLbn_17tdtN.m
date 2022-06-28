% This is a template for plotting bar charts and cdfs as different panels
% on the same figure. The add-on GRAMM is required. For more info, see
% GRAMM's documentation.
% Example: ctrl_vs_msew_p17tdtN.fig
% 2021-12-14, Man Ho Wong

%% Define panels in the 1st row of the figure

%%%%% 1st column

% Create a "gramm" object and put your data in it so this add-on can
% process the data.
    % g is the name of the "gramm" object here. Indices of g indicate in
    % which row and column the panels will be plotted. e.g. If you put your
    % data in g(1,1), the panels will be plotted in row 1, column 1.
    % For input arguments and data structure, please see the documentation
    % for gramm().
g(1,1)=gramm('x',cellstr(inputFreq.condition),'y',inputFreq.data,...
    'color',cellstr(inputFreq.condition)); % cellstr to convert input data
                                            % to cells of string

% Set panel title, axis titles, column title/ legend title (not
% applicable here) and tick length.
g(1,1).set_names('x','','y','Frequency (Hz)','color','');
g(1,1).set_title('Sexes combined','FontSize',12);
g(1,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:2:max(inputFreq.data)]);

% Set the color map (i.e. color scheme for different groups).
g(1,1).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);

% Set the relative position and size of the panels in the 1st row.
% [distanceFromLeft distanceFromBottom width height]
g(1,1).set_layout_options("position",[0 0.77 0.361 0.24],"legend",0);

% Indicate that jittered datapoints will be plotted.
g(1,1).geom_jitter();

% Calculate the average and sem and specify how these will be plotted (e.g. bar or boxplot).
%g(1,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(1,1).stat_boxplot('width',1);

%%%%% 2nd and 3rd columns

g(1,2)=gramm('x',cellstr(inputFreq.condition),'y',inputFreq.data,...
    'color',cellstr(inputFreq.condition));

% Sort data into two groups according to sexes and create two subcolumns in
% column 2 of the first row, each will contain a panel for each sex.
g(1,2).facet_grid([],cellstr(inputFreq.sex));

% By default, variables are sorted by alphabetical/ascending order. The
% function allows user to change the order.
g(1,2).set_order_options("column",["m" "f"]);

g(1,2).set_names('x','','y','','color','','column','');
g(1,2).axe_property('TickLength',[0.02 0.02],'ytick',[0:2:max(inputFreq.data)],'yticklabel','');
g(1,2).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(1,2).set_layout_options("position",[0.35 0.77 0.58 0.24],"legend",0);
g(1,2).geom_jitter();
%g(1,2).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(1,2).stat_boxplot('width',1);

g.set_title('mEPSC Frequency - P17-18, tdT-');

%% Define panels in the 2nd row of the figure

%%%%% 1st column
g(2,1)=gramm('x',inputFreq.data,'color',cellstr(inputFreq.condition));
g(2,1).set_names('x','Frequency (Hz)','y','Normalized CDF','color','','column','');
g(2,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(2,1).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(2,1).set_layout_options("position",[0 0.53 0.361 0.24],"legend",0);
g(2,1).stat_bin('normalization','cdf','geom','stairs');

%%%%% 2nd and 3rd columns
g(2,2)=gramm('x',inputFreq.data,'color',cellstr(inputFreq.condition));
g(2,2).facet_grid([],cellstr(inputFreq.sex),"column_labels",0);
g(2,2).set_names('x','Frequency (Hz)','y','','color','','column','');
g(2,2).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1],'yticklabel','');
g(2,2).set_order_options("column",["m" "f"]);
g(2,2).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(2,2).set_layout_options("position",[0.35 0.53 0.58 0.24],'legend_position',[0.92 0.55 0.16 0.1]);
g(2,2).stat_bin('normalization','cdf','geom','stairs');

%% Define panels in the 3rd row of the figure

%%%%% 1st column
g(3,1)=gramm('x',cellstr(inputAmpl.condition),'y',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(3,1).set_names('x','','y','Amplitude (-pA)','color','','column','');
g(3,1).set_title('Sexes combined','FontSize',12);
g(3,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:5:max(inputAmpl.data)]);
g(3,1).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(3,1).set_layout_options("position",[0 0.24 0.361 0.24],"legend",0);
g(3,1).geom_jitter();
%g(3,1).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(3,1).stat_boxplot('width',1);

%%%%% 2nd and 3rd columns
g(3,2)=gramm('x',cellstr(inputAmpl.condition),'y',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(3,2).facet_grid([],cellstr(inputAmpl.sex));
g(3,2).set_names('x','','y','','color','','column','');
g(3,2).axe_property('TickLength',[0.02 0.02],'ytick',[0:5:max(inputAmpl.data)],'yticklabel','');
g(3,2).set_order_options("column",["m" "f"]);
g(3,2).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(3,2).set_layout_options("position",[0.35 0.24 0.58 0.24],"legend",0);
g(3,2).geom_jitter();
%g(3,2).stat_summary('type','sem','geom',{'bar' 'black_errorbar'},'width',1);
g(3,2).stat_boxplot('width',1);

%% Define panels in the last row of the figure

%%%%% 1st column
g(4,1)=gramm('x',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(4,1).set_names('x','Amplitude (-pA)','y','Normalized CDF','color','','column','');
g(4,1).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1]);
g(4,1).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(4,1).set_layout_options("position",[0 0 0.361 0.24],"legend",0);
g(4,1).stat_bin('normalization','cdf','geom','stairs');

%%%%% 2nd and 3rd columns
g(4,2)=gramm('x',inputAmpl.data,'color',cellstr(inputAmpl.condition));
g(4,2).facet_grid([],cellstr(inputAmpl.sex),"column_labels",0);
g(4,2).set_names('x','Amplitude (-pA)','y','','color','','column','');
g(4,2).axe_property('TickLength',[0.02 0.02],'ytick',[0:0.2:1],'yticklabel','');
g(4,2).set_order_options("column",["m" "f"]);
g(4,2).set_color_options('map',[0 0 0;0 0.5 1;1 0 0]);
g(4,2).set_layout_options("position",[0.35 0 0.58 0.24],'legend_position',[0.92 0.05 0.16 0.1]);
g(4,2).stat_bin('normalization','cdf','geom','stairs');

%% Plot all the panels on the same figure

figure('Position',[1000 100 718 800]); % create a figure and specify the position/size
g.draw();                              % Draw all the panels
clear g;                               % clear the gramm object to prevent
                                       % errors when plotting next figure

%% Adjust figure properties

% add title for 3rd and 4th rows
annotation('textbox', [0.5 0.49 0 0], 'string', 'mEPSC Amplitude - P17-18, tdT-',...
           'FontSize',14,'FontWeight','bold','FitBoxToText','on',...
           'LineStyle','none',HorizontalAlignment='center');

% remove boxplot face color
h = findobj('FaceAlpha',1);     % all boxplot objects share this property
set(h,'FaceColor','none','edgeColor','k');

% Change m and f to male and female
h = findobj('String','m');
set(h,'String','Male');
h = findobj('String','f');
set(h,'String','Female');

% Change filled markers to open markers
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(h,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[0 0.5 1]);
set(h,'MarkerEdgeColor',[0 0.5 1],'MarkerFaceColor','none');
h = findobj('Marker','o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);
set(h,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none');