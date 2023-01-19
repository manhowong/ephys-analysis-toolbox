%% This is a script for fitting mEPSC decay.
% Each mEPSC event will be fitted to a first order exponential function.
% This script runs fitDecay.m automatically on one recording or a group of 
% recordings in a folder.
% Man Ho Wong, University of Pittsburgh, 2022-04-18
% -------------------------------------------------------------------------
% Files needed: Aligned traces (.txt) by MiniAnalysis software
%               (See examples in the folder ../demoData/traces/)
% -------------------------------------------------------------------------
% User settings: See next section
% -------------------------------------------------------------------------
% Outputs: - decayReport.mat* : analysis report
%            - events : contains fitted parameters of each event
%            - meanI0 : mean of initial amplitude (I0)
%            - meanTau : mean of time constant (Tau)
%            - sdI0 : standard deviation of I0
%            - sdTau : standard deviation of Tau
% *Report is saved in user-designated folder (see below).

%% User settings
% Specify your file directories and preferences below.

%--------------------------------------------------------------------------
% Directories and files

% If running anlysis only on one recording, enter the file name of the 
%   recording below; otherwise, leave blank for batch analysis.
% Include '.txt' in file name
fname = '';

% Directory of aligned traces file(s)
% Must ends in '/'
tracesDir = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\event_trace\';

% Directory to store results
% Must ends in '/'
outputDir = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\decay_new\';

% Recording properties
settings.baseStartT = 0;   % baseline start time, ms
settings.baseEndT = 4;     % baseline length, ms
settings.tailLength = 4;   % tail (end of trace) length, ms

%--------------------------------------------------------------------------
% Fitting preferences

% Window of decay phase to be analyzed:
% Decay phase start point and end point as fractions of avg. peak amplitude
% e.g. Set them to 1 and 0.1 to analyze from 100% peak to 10% peak.
% To include whole decay phase for fitting, enter 1 and 0 respectively.
% WARNING: If you are using narrow decay window for mEPSC decay, the script
% cannot find a decay window long enough for good fitting (this is due to 
% the short duration of mEPSCs and relatively low signal-to-noise ratio). 
% You may receive an "insufficent data" error. To avoid the error, use 
% broader decay window for mEPSCs (especially for noisy data).
settings.decayStart = 1;
settings.decayEnd = 0;

%% Run fitDecay
% (No user settings below)

% Check if tracesDir exists
if ~available(tracesDir,'r')
    return
end

% Check if outputDir exists
if ~available(outputDir,'w')
    return
else
    mkdir(outputDir);
end

% progress window
progress = 0;
wait = waitbar(0,'Start fitting...');

% Create a table to store results
decayReport = table;

if ~isempty(fname)  % run fitting on one recording in the folder
    waitbar(progress,wait,strrep(sprintf('Processing %s...',fname), '_', '\_'));
    decayInfo = fitDecay(fname, tracesDir, settings);
    if ~isempty(decayInfo)
        decayReport.events{fname} = decayInfo;
        [decayReport.minI0(fname), decayReport.maxI0(fname)] = bounds(decayInfo.("I_0"));
        decayReport.meanI0(fname) = mean(decayInfo.I_0);
        decayReport.sdI0(fname) = std(decayInfo.I_0);
        [decayReport.minTau(fname), decayReport.maxTau(fname)] = bounds(decayInfo.tau);
        decayReport.meanTau(fname) = mean(decayInfo.tau);
        decayReport.sdTau(fname) = std(decayInfo.tau);
    else
        decayReport{fname, {'events','minI0','maxI0','meanI0','sdI0', ...
                            'minTau','maxTau','meanTau','sdTau'}} = cell(1,1);
    end

else  % run fitting on all recordings in the folder
    tracesFiles = dir(tracesDir);
    nFiles = length(tracesFiles);
    for f = 1:nFiles
        fname = tracesFiles(f).name;
        progress = (f-1)/nFiles;
        waitbar(progress,wait,strrep(sprintf('Processing %s...   %0.0f%%',fname, progress*100), '_', '\_'));
        if length(fname) > 4 & fname(end-2:end) == 'txt'
            decayInfo = fitDecay(fname, tracesDir, settings);
            if ~isempty(decayInfo)
                decayReport.events{fname} = decayInfo;
                [decayReport.minI0(fname), decayReport.maxI0(fname)] = bounds(decayInfo.("I_0"));
                decayReport.meanI0(fname) = mean(decayInfo.I_0);
                decayReport.sdI0(fname) = std(decayInfo.I_0);
                [decayReport.minTau(fname), decayReport.maxTau(fname)] = bounds(decayInfo.tau);
                decayReport.meanTau(fname) = mean(decayInfo.tau);
                decayReport.sdTau(fname) = std(decayInfo.tau);
            else
                decayReport{fname, {'events','minI0','maxI0','meanI0','sdI0', ...
                                    'minTau','maxTau','meanTau','sdTau'}} = cell(1,1);
            end
        end
    end
end

% Close progress window
close(wait)
delete(wait)

%% Save decayReport

save([outputDir 'decayReport'],'decayReport');
fprintf('\nAnalysis completed! Decay info was saved in %s.\n', outputDir);
open decayReport
