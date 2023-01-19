function zeroedTraces = zeroTraces(allTraces, baseStartT, baseEndT, sFreq)
%% Zero every trace in a recording by its own baseline.
% Man Ho Wong, University of Pittsburgh, 2022-04-18
% -------------------------------------------------------------------------
% Inputs: - allTraces : traces of a recording; imported into MATLAB by
%                       importTraces.m
%         - baseStartT : baseline start time, ms
%         - baseEndT : baseline end time, ms
%         - sFreq : sampling frequency, Hz
% -------------------------------------------------------------------------
% Outputs: - zeroedTraces : allTraces zeroed

%% Get mean amplitude of original baseline of every trace

baseStartPt = sFreq*baseStartT/1000 + 1;
baseEndPt = sFreq*baseEndT/1000 + 1;

% get mean value of every trace by array operation
baseMean_original = mean(allTraces{baseStartPt:baseEndPt,2:end},1);

%% Zero every trace by its own baseline's mean value

zeroedTraces = allTraces;  % Copy allTraces to get all row/column labels
zeroedTraces{:, 2:end} = allTraces{:, 2:end} - baseMean_original;

end