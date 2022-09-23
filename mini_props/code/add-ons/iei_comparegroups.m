% compare exponential and amplitude model

function [pgroup hgroup] = iei_comparegroups(group1,group2);

% Load precomputed stats
gr1=load([group1 'ieistats_all.mat']);
gr2=load([group2 'ieistats_all.mat']);



%% compare 

sigdiff=zeros(length(gr1.allfiles),2);

gr1rate=gr1.allparams(:,1);
gr1CI=gr1.allparams(:,2);
gr2rate=gr2.allparams(:,1);
gr2CI=gr2.allparams(:,2);

[pgroup hgroup]=ranksum(gr1rate,gr2rate);
disp('p-val       H');
disp([pgroup hgroup]);

figure
hold on
boxplot([gr1rate; gr2rate],[ones(size(gr1rate)); 2*ones(size(gr2rate))],'whisker',3);
title('Event rate')



[delta ci]=ranksumci(gr2rate,gr1rate);

disp(sprintf('Rate estimate: Group1: %0.2f Group2: %0.2f  Difference: %0.2f (%0.2f to %0.2f)', ...
    median(gr1rate),median(gr2rate),delta,ci(1),ci(2)));




