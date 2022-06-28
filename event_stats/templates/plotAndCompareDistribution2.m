fprintf('-----------------------\n');
expGp2 = char(projFolder + "\analysis\exponFitting\" + "msewMitM53u\");
expGp3 = char(projFolder + "\analysis\exponFitting\" + "msewBathF53u\");
expGp4 = char(projFolder + "\analysis\exponFitting\" + "msewMitF53u\");
fprintf('msewBathF53u vs msewMitF53u\n');
[p2,h2] = iei_comparegroups(expGp3,expGp4);
fprintf('-----------------------\n');
gammaGp2 = char(projFolder + "\analysis\gammaFitting\" + "msewMitM53u\");
gammaGp3 = char(projFolder + "\analysis\gammaFitting\" + "msewBathF53u\");
gammaGp4 = char(projFolder + "\analysis\gammaFitting\" + "msewMitF53u\");
fprintf('msewBathF53u vs msewMitF53u\n');
stats2 = gamma_comparegroups(gammaGp3,gammaGp4);



figure;

fig = tiledlayout(2,2,TileSpacing="compact",Padding="compact");
t = title(fig,'Event distribution (bootstrap data)');
t.FontWeight = 'bold';

nexttile
title('>=P53 Male (MSEW)');
plotBootstrapData_exp('msewMitM53u',0,[1 0.6 0.6]);
legend(["MIT"]);
set(gca,'TickLength',[0.02, 0.02]);

nexttile
title('>=P53 Female (MSEW)');
plotBootstrapData_exp('msewBathF53u',0,[1 0 0]);
plotBootstrapData_exp('msewMitF53u',0,[1 0.6 0.6]);
legend(["Bath","MIT"]);
set(gca,'TickLength',[0.02, 0.02],'YTickLabel',[],'YLabel',[]);
txt = "\mu: p = " + p2;
text('Units','normalized','Position',[0.5 0.2],'String',txt,FontSize=9);

nexttile
title('>=P53 Male (MSEW)');
plotBootstrapData_gamma('msewMitM53u',0,[1 0.6 0.6]);
legend(["MIT"]);
set(gca,'TickLength',[0.02, 0.02]);

nexttile
title('>=P53 Female (MSEW)');
plotBootstrapData_gamma('msewBathF53u',0,[1 0 0]);
plotBootstrapData_gamma('msewMitF53u',0,[1 0.6 0.6]);
legend(["Bath","MIT"]);
set(gca,'TickLength',[0.02, 0.02],'YTickLabel',[],'YLabel',[]);
txt = {"\mu: p = " + stats2(3,1),...
       "\alpha: p = " + stats2(1,1),...
       "\beta: p = " + stats2(2,1)};
text('Units','normalized','Position',[0.5 0.3],'String',txt,FontSize=9);






