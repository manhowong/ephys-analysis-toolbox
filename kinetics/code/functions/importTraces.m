function [allTraces, sFreq] = importTraces(fname, tracesDir)
%% Import traces into MATLAB from a txt file and detect sampling frequency.
% Man Ho Wong, University of Pittsburgh, 2022-04-04
% -------------------------------------------------------------------------
% File needed: Aligned traces (.txt) by MiniAnalysis software
%              (See examples in the folder ../demoData/traces/)
% -------------------------------------------------------------------------
% Inputs: - fname : file name of recording
%         - tracesDir : directory of aligned traces files (must end in '/')
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

% Check if files exist
tracesPath = [tracesDir fname];
if ~isfile(tracesPath)
    fprintf(['This file does not exist: %s\n', ...
             'Please check if the path is correct.\n'], tracesPath);
    allTraces = [];  % return empty array for checking outside the function
    sFreq = [];  % return empty array for checking outside the function
    return;
end

allTraces = readtable(tracesPath, 'ReadVariableNames', false);

%% Add column names

% Trace ID is simply a number from 1 to number of traces
traceID = linspace(1, width(allTraces)-2, width(allTraces)-2)';

% Add column names to 'allTraces' table for easier manipulation:
%   1st column is time, 2nd column is the average trace ('avgTrace')
columnNames = ['time'; 'avgTrace'; cellstr(string(traceID))];
allTraces.Properties.VariableNames = columnNames;

%%  Compute sampling frequency from time duration per sampling point
sFreq = 1/(allTraces.time(2)/1000);  % Sampling frequency, Hz

end