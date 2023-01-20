%% This is a script for analyzing membrane properties in batch.
% 
% Man Ho Wong, University of Pittsburgh, 2022-09-20
% -------------------------------------------------------------------------
% File needed: capacitance transient trace files (.txt)
%              - See instructions in ../../resources/prepare_data.md
%              - See examples in: ../../demo_data/transient_trace/
% -------------------------------------------------------------------------
% User settings: See next section
% -------------------------------------------------------------------------
% Outputs: - Command window: values of membrane properties
%          - memPropReport.mat*: report for membrane properties
%          - memPropReport.xlsx*: report in Excel format
% *Reports are saved in user-designated folder (see below).

%% User settings
% Specify your file directories and preferences below.

%--------------------------------------------------------------------------
% Directories and files

% If running NSFA only on one recording, enter the file name of the 
%   recording below; otherwise, leave blank for batch analysis.
% Include '.txt' in file name
fname = '';

% Directory of aligned traces file(s)
transientDir = 'path/to/transient_trace_files';

% Directory where you want the script to create and store the results
%   ATTENTION: If this directory already exists, files with same names will 
%              be overwritten. Use a different name if needed.
outputDir = 'path/to/output_directory';

% Recording properties
settings.tp = -5;
settings.sFreq = 20000;
settings.baseStartT = 0;
settings.baseEndT = 50;
settings.decayEndT = 150;


%% Run membraneProps
% (No user settings below)

% progress window
progress = 0;
wait = waitbar(0,'Start fitting...');

% Create a report table
memPropReport = table();
report_columns = {'series R, MOhm', 'input R, MOhm', 'tau, ms', ...
                  'membrane capacitance, pF', 'r2'};

% Check if outputDir exists
if ~available(outputDir,'w')
    return
else
    mkdir(outputDir);
end

if ~isempty(fname)  % run on one recording in the folder
    waitbar(progress,wait,strrep(sprintf('Processing %s...',fname), '_', '\_'));
    results = membraneProps(fname, transientDir, settings);
    % Empty results will be returned if file not found; Stop script.
    if isempty(results), return; end
    new = array2table(results, 'RowNames', {fname}, 'VariableNames', report_columns);
    memPropReport = [memPropReport; new];

else  % run on all recordings in the folder

    transientFiles = dir(transientDir);
    nFiles = length(transientFiles);
    for f = 1:nFiles
        fname = transientFiles(f).name;
        progress = f/nFiles;
        waitbar(progress,wait,strrep(sprintf('Processing %s...   %0.0f%%',fname, progress*100), '_', '\_'));
        if length(fname) > 4 & fname(end-2:end) == 'txt'
            results = membraneProps(fname, transientDir, settings);
            % Empty results will be returned if file not found; Stop script.
            if isempty(results), return; end
            new = array2table(results, 'RowNames', {fname}, 'VariableNames', report_columns);
            memPropReport = [memPropReport; new];
        end
    end
end

% Close progress window
close(wait)
delete(wait)

% Save results
save([outputDir 'memPropReport'],'memPropReport');
writetable(memPropReport,[outputDir 'memPropReport.xlsx'],'WriteRowNames',true);
fprintf('\nDone! Results were saved in:\n%s.\n', outputDir);
open memPropReport