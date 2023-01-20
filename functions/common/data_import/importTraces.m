function allTraces = importTraces(fname, tracesDir, sFreq)
%% Import traces into MATLAB from a txt file and detect sampling frequency.
% Man Ho Wong, University of Pittsburgh, 2022-04-04
% -------------------------------------------------------------------------
% File needed: Aligned traces (.txt)
%              - See instructions in ../../resources/prepare_data.md
%              - See examples in: ../../demo_data/event_trace/
% -------------------------------------------------------------------------
% Inputs: - fname : file name of recording; char
%         - tracesDir : directory of aligned traces files; char
%         - sFreq : sampling frequency, Hz
% -------------------------------------------------------------------------
% Outputs: - allTraces : a table containing the following column
%               - time : time points
%               - avgTrace : amplitudes of average trace at each time point
%               - Each of the other columns are amplitudes of each trace
%          - sFreq : sampling frequency computed from interval between two
%                    time points

%% Read data from .txt files into MATLAB table

% Add tracesDir and subfolders to path
addpath(tracesDir);
path = genpath(tracesDir);
addpath(path); 

% Check if file exists
tracePath = [tracesDir '/' fname];
if ~available(tracePath,'r')
    allTraces = [];  % return empty array
    return;
end

allTraces = readtable(tracePath, 'ReadVariableNames', false);

%% Insert time and average trace as at the beginning of table
%  (except for files exported from the Mini Analysis Program; they already
%  have these two columns)

 opts = detectImportOptions(tracePath);
 if opts.DataLines(1) ~= 7  % files from Mini Analysis Program has 7 lines
     intvl = 1/sFreq*1000;
     time = [0:intvl:intvl*(height(allTraces)-1)]';
     allTraces = addvars(allTraces,time,'Before','Var1');
     avgTrace = mean(allTraces{:,3:end},2);
     allTraces = addvars(allTraces,avgTrace,'after','time');
 end

%% Add column names

% Trace ID is simply a number from 1 to number of traces
traceID = linspace(1, width(allTraces)-2, width(allTraces)-2)';

% Add column names to 'allTraces' table for easier manipulation:
%   1st column is time, 2nd column is the average trace ('avgTrace')
columnNames = ['time'; 'avgTrace'; cellstr(string(traceID))];
allTraces.Properties.VariableNames = columnNames;

end