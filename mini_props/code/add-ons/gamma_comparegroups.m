% compare exponential and amplitude model

function stats = gamma_comparegroups(group1,group2);

% Load precomputed stats
gr1=load([group1 'gammastats_all.mat']);
gr2=load([group2 'gammastats_all.mat']);



%% compare 

gr1alpha=gr1.allparams(:,1);
gr1alphaCI=gr1.allparams(:,2);
gr2alpha=gr2.allparams(:,1);
gr2alphaCI=gr2.allparams(:,2);

gr1beta=gr1.allparams(:,3);
gr1betaCI=gr1.allparams(:,4);
gr2beta=gr2.allparams(:,3);
gr2betaCI=gr2.allparams(:,4);

gr1mean=gr1.allparams(:,5);
gr2mean=gr2.allparams(:,5);



[p h]=ranksum(gr1alpha,gr2alpha);
stats(1,:)=[p h];
[p h]=ranksum(gr1beta,gr2beta);
stats(2,:)=[p h];
[p h]=ranksum(gr1mean,gr2mean);
stats(3,:)=[p h];
disp('         p-val       H')
disp(['Alpha: ' num2str(stats(1,:))]);
disp(['Beta: ' num2str(stats(2,:))]);
disp(['Mean: ' num2str(stats(3,:))]);

figure
hold on
boxplot([gr1mean; gr2mean],[ones(size(gr1mean)); 2*ones(size(gr2mean))],'whisker',3);
title('Mean amplitude')

[adelta aci]=ranksumci(gr2alpha,gr1alpha);
[bdelta bci]=ranksumci(gr2beta,gr1beta);
[mdelta mci]=ranksumci(gr2mean,gr1mean);


disp(sprintf('Alpha estimate: Group1: %0.2f Group2: %0.2f  Difference: %0.2f (%0.2f to %0.2f)', ...
    median(gr1alpha),median(gr2alpha),adelta,aci(1),aci(2)));
disp(sprintf('Beta estimate: Group1: %0.2f Group2: %0.2f  Difference: %0.2f (%0.2f to %0.2f)', ...
    median(gr1beta),median(gr2beta),bdelta,bci(1),bci(2)));
disp(sprintf('Mean amplitude estimate: Group1: %0.2f Group2: %0.2f  Difference: %0.2f (%0.2f to %0.2f)', ...
    median(gr1mean),median(gr2mean),mdelta,mci(1),mci(2)));

