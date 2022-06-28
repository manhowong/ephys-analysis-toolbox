fprintf('-----------------------\n');
expGp1 = char(projFolder + "\analysis\exponFitting\" + "ctrlMitM17u\");
expGp2 = char(projFolder + "\analysis\exponFitting\" + "naiveMitM17u\");
expGp3 = char(projFolder + "\analysis\exponFitting\" + "ctrlMitF17u\");
expGp4 = char(projFolder + "\analysis\exponFitting\" + "naiveMitF17u\");
fprintf('ctrlMitM17u vs naiveMitM17u\n');
[p1,h1] = iei_comparegroups(expGp1,expGp2);
fprintf('ctrlMitF17u vs naiveMitF17u\n');
[p2,h2] = iei_comparegroups(expGp3,expGp4);
fprintf('-----------------------\n');
gammaGp1 = char(projFolder + "\analysis\gammaFitting\" + "ctrlMitM17u\");
gammaGp2 = char(projFolder + "\analysis\gammaFitting\" + "naiveMitM17u\");
gammaGp3 = char(projFolder + "\analysis\gammaFitting\" + "ctrlMitF17u\");
gammaGp4 = char(projFolder + "\analysis\gammaFitting\" + "naiveMitF17u\");
fprintf('ctrlMitM17u vs naiveMitM17u\n');
stats1 = gamma_comparegroups(gammaGp1,gammaGp2);
fprintf('ctrlMitF17u vs naiveMitF17u\n');
stats2 = gamma_comparegroups(gammaGp3,gammaGp4);



figure;

fig = tiledlayout(2,2,TileSpacing="compact",Padding="compact");
t = title(fig,'Event distribution (bootstrap data)');
t.FontWeight = 'bold';

nexttile
title('P17-18 Male');
plotBootstrapData_exp('ctrlMitM17u',0,[0 0 0]);
plotBootstrapData_exp('naiveMitM17u',0,[0.6 0.6 0.6]);
legend(["ctrl","naive"]);
set(gca,'TickLength',[0.02, 0.02]);
txt = "\mu: p = " + p1;
text('Units','normalized','Position',[0.5 0.2],'String',txt,FontSize=9);

nexttile
title('P17-18 Female');
plotBootstrapData_exp('ctrlMitF17u',0,[0 0 0]);
plotBootstrapData_exp('naiveMitF17u',0,[0.6 0.6 0.6]);
legend(["ctrl","naive"]);
set(gca,'TickLength',[0.02, 0.02],'YTickLabel',[],'YLabel',[]);
txt = "\mu: p = " + p2;
text('Units','normalized','Position',[0.5 0.2],'String',txt,FontSize=9);

nexttile
title('P17-18 Male');
plotBootstrapData_gamma('ctrlMitM17u',0,[0 0 0]);
plotBootstrapData_gamma('naiveMitM17u',0,[0.6 0.6 0.6]);
legend(["ctrl","naive"]);
set(gca,'TickLength',[0.02, 0.02]);
txt = {"\mu: p = " + stats1(3,1),...
       "\alpha: p = " + stats1(1,1),...
       "\beta: p = " + stats1(2,1)};
text('Units','normalized','Position',[0.5 0.3],'String',txt,FontSize=9);

nexttile
title('P17-18 Female');
plotBootstrapData_gamma('ctrlMitF17u',0,[0 0 0]);
plotBootstrapData_gamma('naiveMitF17u',0,[0.6 0.6 0.6]);
legend(["ctrl","naive"]);
set(gca,'TickLength',[0.02, 0.02],'YTickLabel',[],'YLabel',[]);
txt = {"\mu: p = " + stats2(3,1),...
       "\alpha: p = " + stats2(1,1),...
       "\beta: p = " + stats2(2,1)};
text('Units','normalized','Position',[0.5 0.3],'String',txt,FontSize=9);






