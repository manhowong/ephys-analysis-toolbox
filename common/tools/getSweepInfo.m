%% Read each files as cells of chars (required for string slicing later)

opts = delimitedTextImportOptions("NumVariables", 1);
paths = readmatrix("C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\paths.txt", opts);
fullnames = readmatrix("C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\filenames.txt", opts);
clear opts

%% Generate a table with recording name, path and range of sweeps

nFiles = length(fullnames);

% Create table
colNames = ["name","pxpPath","firstSweep","lastSweep"];
colTypes = ["string","string","double","double"];
sweepInfo = table('size',[nFiles,4],'VariableNames',colNames,'VariableTypes',colTypes);

for f = 1:nFiles
    underscores = strfind(fullnames{f},'_');
    dashes = strfind(fullnames{f},'-');
    pathDividers = strfind(fullnames{f},'\');
    lastPathDividerIdx = pathDividers(end);
    suffixDividerIdx = underscores(end);
    sweepDividerIdx = dashes(end);
    extNameStartIdx = strfind(fullnames{f},'.EVT');
    recordingName = fullnames{f}(lastPathDividerIdx+1:suffixDividerIdx-1);
    sweepInfo.name(f) = recordingName;
    sweepInfo.pxpPath(f) = paths(contains(paths,recordingName));
    sweepInfo.firstSweep(f) = str2double(fullnames{f}(suffixDividerIdx+1:sweepDividerIdx-1));
    sweepInfo.lastSweep(f) = str2double(fullnames{f}(sweepDividerIdx+1:extNameStartIdx-1)); 
end

%% Edit pxpPath format

% Escape backslash for Windows style file paths
sweepInfo.pxpPath = replace(sweepInfo.pxpPath, '\', '\\');

%% Save sweepInfo as .txt

writetable(sweepInfo, "C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\sweepInfo.txt");



