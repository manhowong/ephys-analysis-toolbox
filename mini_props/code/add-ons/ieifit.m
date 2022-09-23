% fitexp: fit exponential model to IEI data. Uses format given by Mingna.

% Input:
% data: same format as MiniAnalysis software (input in mingnastats.m)
% threshold: {IEI threshold [Risetime threshold], Ampl. threshold}
% mode: either 'events' for # of events, or 'time' for selected time.
% criteria: number of events or time interval (1x2 array)

% Script then makes three types of figures:
% 1. Histograms with model overlays
% 2. Q-Q plots
% 3. KS plots
% 4. Time-rescaling and autocorrelation plots

% Output:
% freq: rate in Hz
% n: number of analyzed events
% fCI: CI for freq
% results: KS stats

function [params gof] = fitexp(data,threshold,mode,criteria)


% Select data - sort and identify variables
[evtimes, evorder] = sort(data(:,2));
sdata = data(evorder,:);
iei = [sdata(1,2); diff(evtimes)];
ampl = sdata(:,3);
rise = sdata(:,11);
group = sdata(:,9);

% Retrieve thresholds from input
ieith = threshold{1};
riseth = threshold{2};
amplth = threshold{3};

% Apply thresholds
index=(iei>ieith & rise>riseth(1) & rise<riseth(2) & ampl>amplth);
numrej=size(sdata,1)-sum(index);
sdata=sdata(index,:);
disp([ num2str(numrej) ' trials rejected based on thresholds'])

% If selection mode is listed, apply.
if nargin>3
    switch mode
        case 'events'
            if size(sdata,1)<criteria
                disp('Warning - fewer events than requested')
            else
                sdata=sdata(1:criteria,:);
            end
        case 'time'
            if (length(criteria)~=2)
                disp('Error - recording interval must be a 1 x 2 matrix')
            else
                if (criteria(2) > (max(data(:,2)+5000)))
                    disp('Warning: input recording interval is much later than occurrence of last event.')
                end
                goodtime=sdata(:,2)>=criteria(1)&sdata(:,2)<=criteria(2);
                sdata=sdata(goodtime,:);
            end
    end
end
rectime=sdata(end,2)-sdata(1,2);

disp(['Analyzing ' num2str(size(sdata,1)) ' events.']);

% Extract variables from selected dataset
iei=[diff(sdata(:,2))];
n=length(iei);

%%%%% ANALYSIS
% Frequency analysis
freq = n/(rectime/1000);
lambda = n/(rectime)
fweight = n/(freq^2);
%disp(['Frequency (events/s): ' num2str(freq) ' +/- ' num2str(1.96*((1/fweight)^0.5))]);
fvar = (freq^2)/n;
fCI=1.96*(fvar^0.5);

% IEI Histogram
%figure
scrsz = get(0,'ScreenSize');
figure;
hold on;
[counts xout]=hist(iei, 50);
bar(xout, counts/sum(counts)*100)
xlabel('Inter-event interval (ms)')
ylabel('Percent')
ys=ylim;
ylim([0 (ys(2)+2)]);

% Get exponential model overlay
bin = (xout(2)-xout(1))/2;
for i=1:length(xout)
    y(i)=expcdf(xout(i)+bin,mean(iei))-expcdf(xout(i)-bin,mean(iei));
end
plot(xout,y*100,'r')
title('IEI Histogram - Exponential model')
legend('IEI data','Exponential model')

exponfish = [n/(mean(iei))^2];
exponinvfish = inv(exponfish);
exponvar = exponinvfish(1,1);
exponCI = 1.96*(exponvar^0.5);

% Generate q-q plots.

step=1/(2*n);
qqcdf=step:2*step:1;

% Inter-event intervals - Normal
figure; hold on;

% Inter-event intervals - Exponential
expqq = expinv(qqcdf,mean(iei));
qqplot(iei,expqq);
title('Q-Q plot - Exponential model')


% KS tests and plots - IEI, ampl, and log ampl vs normal distribution
figure; hold on;
cdfplot(iei);
step=(max(iei)-min(iei))/1000;
x=min(iei):step:max(iei);

y=expcdf(x,mean(iei));
plot(x,y,'r')
%[H,Piei,KSiei] = kstest2(iei,expqq);
legend('Observed','Theoretical')
title('KS plot for IEIs and exponential CDF')

[l(1) p(1) ks(1)] = kstest2(iei,expqq);

gof = [l' p' ks'];

% Generate time-scaling plots and autocorrelation plots
% Rescale the time intervals (exponential)
z = iei*lambda;
u = 1-exp(-z);
intervals = 1:n;
empirical = (intervals-0.5)/n;
uniform = intervals/n;

% Generate time-rescaling plot
figure; hold on;
subplot(2,1,1)
hold on
plot(uniform,uniform,'r')
plot(uniform,uniform+1.36/sqrt(n),'r--')
plot(uniform,uniform-1.36/sqrt(n),'r--')
scatter(sort(u),empirical,'bx')
title(['Time-rescaling plot of inter-event intervals - Exponential'])
xlim([0 1]); ylim([0 1]);
ylabel('Theoretical Quantiles')
xlabel('Empirical Quantiles')

%% Generate autocorrelation plot
subplot(2,1,2)
a = norminv(u);

% Check for Econometrics Toolbox
toolboxList = ver;
if ~ismember('Econometrics Toolbox', {toolboxList.Name})
    warning('Econometrics Toolbox not installed: skipping autocorrelation plot...\n');
else
    autocorr(a,n-1);
    title(['Autocorrelation of inter-event intervals -- Exponential']);
end

%output = [freq,n,fCI,mean(iei),muCI,std(iei),sigmaCI,mean(iei),exponCI,khatiei,khatieiCI,alphahatiei,alphaieiCI,betahatiei,betaieiCI,results(1,1),results(2,1),results(3,1),results(4,1),results(1,2),results(2,2),results(3,2),results(4,2),results(1,3),results(2,3),results(3,3),results(4,3)];

params = [freq,fCI,n];

