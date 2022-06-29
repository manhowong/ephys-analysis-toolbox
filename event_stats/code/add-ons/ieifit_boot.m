% fitexp: fit exponential model to IEI data. Uses format given by Mingna.

% Input:
% data: in format givein by MiniAnalysis software (input in mingnastats.m)
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

function params = ieifit_boot(iei)


rectime=sum(iei);
n=length(iei);

%%%%% ANALYSIS
% Frequency analysis
freq = n/(rectime/1000);
lambda = n/(rectime);
fweight = n/(freq^2);
%disp(['Frequency (events/s): ' num2str(freq) ' +/- ' num2str(1.96*((1/fweight)^0.5))]);
fvar = (freq^2)/n;
fCI=1.96*(fvar^0.5);

params = [freq,fCI,n];

