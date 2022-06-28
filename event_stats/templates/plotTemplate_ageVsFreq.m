g=gramm('x',age,'y',inputFreq.data,'color',cellstr(inputFreq.facility),'marker',cellstr(inputFreq.sex));
g.facet_grid([],cellstr(inputFreq.condition));
g.set_point_options('markers',{'o' 'd'});
g.set_order_options("column",["naive" "ctrl" "msew" "lbn"],"color",["mit" "brown" "bathLab"],"marker",["m" "f"]);
g.geom_point();
g.stat_glm();
g.set_names('x','Age (PD)','y','mEPSC frequency (Hz)','marker','','color','','column','');
figure('Position',[100 100 1200 400]);
g.draw();
