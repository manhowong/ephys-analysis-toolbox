%% This is a script for peak-scaled NSFA.
% In this analysis, the average trace of a recording is scaled according to
% the ratio between its peak and the amplitude at the equivalent time point
% of an aligned trace it is being compared to.
% This script runs nsfa.m automatically on one recording or a group of
% recordings in a folder.
% Man Ho Wong, University of Pittsburgh, 2022-04-18
% -------------------------------------------------------------------------
% Files needed: Aligned traces (.txt) by MiniAnalysis software
%               (See examples in the folder ../demoData/traces/)
% -------------------------------------------------------------------------
% User settings: See next section
% -------------------------------------------------------------------------
% Outputs: - Command window: values for i, N, R^2, etc.
%          - Figure*: plot of variance vs mean current and the fitted curve
%                     and plot of traces analyzed
%          - nsfaReport.mat*: summary report for NSFA
%          - nsfaReport.xlsx*: report in Excel format
%          - textReport.txt*: report with text descriptions
% *Reports and figures are saved in user-designated folder (see below).

%% User settings
% Specify your file directories and preferences below.

%--------------------------------------------------------------------------
% Directories and files

% If running NSFA only on one recording, enter the file name of the 
%   recording below; otherwise, leave blank for batch analysis.
% Include '.txt' in file name
fname = '';

% Directory of aligned traces file(s)
% Must ends in '/'
tracesDir = 'C:\Users\MAW427\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\events_aligned\';

% Directory where you want the script to create and store the results
%   ATTENTION: If this directory already exists, all files in it will be 
%              overwritten! Use a different name if needed.
% Must ends in '/'
resultDir = 'C:\Users\MAW427\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\nsfa\';

% Recording properties
settings.baseStartT = 0;   % baseline start time, ms
settings.baseEndT = 4;     % baseline end time, ms
settings.tailLength = 4;   % tail (end of trace) length, ms

%--------------------------------------------------------------------------
% Fitting preferences

% Window of decay phase to be analyzed:
% Decay phase start point and end point as fractions of avg. peak amplitude
% e.g. Set them to 0.95 and 0.1 to analyze from 95%peak to 10%peak.
% Note:
% Setting start point to 100%peak is not recommended: Since the analysis
% is done with average peak scaled to individual traces, variance of
% sampling points near the peak would be very small and you will likely see
% a data point with unusually small variance on the graph. This may affect 
% the fitting of the model. (You can try setting start point to 100% or 95%
% and compare.)
settings.decayStart = 0.95;
settings.decayEnd = 0.1;

% binning datapoints?
settings.binning = true;  % true or false
settings.nBin = 50;       % number of bins

% Include empirical baseline (background noise) variance in the model?
%  If not, baseline variance will be estimated by fitting.
settings.includeBaseVar = false;  % true or false

% More settings in individual function files (but you probably won't need.)


%% Run NSFA
% (No user settings below)

addpath([cd '/functions']);

% Create a report table
nsfaReport = table();
report_columns = {'i, pA', 'N', 'baseVar, pA^2', 'baseVar Type', ...
                  'r^2', 'Total traces', 'Excluded traces', ...
                  'Analysis start, % Peak', 'Analysis end, % Peak', ...
                  'Decay end found, 0 if not', 'Bins'};

% Create directory to store results
[status, msg] = mkdir(resultDir);  % catch warning if folder already exists

% Save command window outputs to a temp file
tempLogPath = [resultDir 'tempLog.txt'];
fclose('all');  % close any openned files to avoid permission error
diary off  % turn off logging just in case tempLog.txt is opened

% Delete the old 'tempLog.txt' first to avoid appending new outputs to it
if exist(tempLogPath, 'file'), delete(tempLogPath); end

% Start logging command window outputs
diary(tempLogPath);
fprintf('%s\n', string(datetime('now')));

if ~isempty(fname)  % run on one recording in the folder

    [results, fig] = nsfa(fname,tracesDir,settings);
    % Empty results will be returned if file not found; Stop script.
    if isempty(results), diary off; return; end
    new = cell2table(results, 'RowNames', {fname}, 'VariableNames', report_columns);
    nsfaReport = [nsfaReport; new];
    fname_main = strrep(erase(fname,'.txt'),'.','_');
    saveas(fig, [resultDir fname_main], 'png');  % save as .png

else  % run on all recordings in the folder

    tracesFiles = dir(tracesDir);
    for f = 1:length(tracesFiles)
        fname = tracesFiles(f).name;
        if length(fname) > 4 & fname(end-2:end) == 'txt'
            [results, fig] = nsfa(fname,tracesDir,settings);
            % Empty results will be returned if file not found; Stop script.
            if isempty(results), diary off; return; end
            new = cell2table(results, 'RowNames', {fname}, 'VariableNames', report_columns);
            nsfaReport = [nsfaReport; new];
            fname_main = strrep(erase(fname,'.txt'),'.','_');
            saveas(fig, [resultDir fname_main], 'png');  % save as .png
            close(fig)  % close figure window
        end
    end
end

% Save analysis report
save([resultDir 'nsfaReport'],'nsfaReport');
writetable(nsfaReport,[resultDir 'nsfaReport.xlsx'],'WriteRowNames',true);
fprintf(['\nAnalysis completed!\n' ...
    'Figures and analysis reports were saved in %s.\n'], resultDir);
diary off
open nsfaReport

% Copy tempLog.txt to textReport.txt and then delete tempLog.txt
textReportPath = [resultDir 'textReport.txt'];
copyfile (tempLogPath, textReportPath)
delete(tempLogPath);