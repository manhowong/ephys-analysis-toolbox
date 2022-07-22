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
tracesDir = 'C:\Users\MAW427\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\events_aligned\';

% Directory to store results
% Must ends in '/'
resultDir = 'C:\Users\MAW427\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\decay\';

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
settings.decayStart = 1;
settings.decayEnd = 0.1;

%% Run fitDecay
% (No user settings below)

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
        decayReport.meanI0{fname} = mean(decayInfo.I_0);
        decayReport.meanTau{fname} = mean(decayInfo.tau);
        decayReport.sdI0{fname} = std(decayInfo.I_0);
        decayReport.sdTau{fname} = std(decayInfo.tau);
    else
        decayReport{fname, {'events','meanI0','meanTau','sdI0','sdTau'}} = cell(1,1);
    end

else  % run fitting on all recordings in the folder
    tracesFiles = dir(tracesDir);
    nFiles = length(tracesFiles);
    for f = 1:nFiles
        fname = tracesFiles(f).name;
        progress = f/nFiles;
        waitbar(progress,wait,strrep(sprintf('Processing %s...   %0.0f%%',fname, progress*100), '_', '\_'));
        if length(fname) > 4 & fname(end-2:end) == 'txt'
            decayInfo = fitDecay(fname, tracesDir, settings);
            if ~isempty(decayInfo)
                decayReport.events{fname} = decayInfo;
                decayReport.meanI0{fname} = mean(decayInfo.I_0);
                decayReport.meanTau{fname} = mean(decayInfo.tau);
                decayReport.sdI0{fname} = std(decayInfo.I_0);
                decayReport.sdTau{fname} = std(decayInfo.tau);
            else
                decayReport{fname, {'events','meanI0','meanTau','sdI0','sdTau'}} = cell(1,1);
            end
        end
    end
end

% Close progress window
close(wait)
delete(wait)

% Save decayReport
[status, msg] = mkdir(resultDir);  % catch warning if folder already exists
save([resultDir 'decayReport'],'decayReport');
fprintf('\nAnalysis completed! Decay info was saved in %s.\n', resultDir);
open decayReport
